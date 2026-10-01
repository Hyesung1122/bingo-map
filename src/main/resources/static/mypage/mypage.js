document.addEventListener("DOMContentLoaded", function () {

    let currentProfile = null; // 마지막으로 불러온 프로필 (취소 시 복원용)

    function renderProfile(data) {
        currentProfile = data;
        document.getElementById("mypage-name").textContent = data.name + "님";
        document.getElementById("mypage-nickname").textContent = data.nickname;
        document.getElementById("mypage-badge").textContent = data.role === "ADMIN" ? "관리자" : data.role === "MANAGER" ? "매니저" : "일반회원";
        document.getElementById("mypage-email").textContent = data.email;
        document.getElementById("mypage-avatar").textContent = data.name.charAt(0);
        document.getElementById("mypage-nationality").textContent = data.nationality;
        document.getElementById("mypage-joined").textContent = data.joinedAt;
    }

    // 1) 프로필 정보 로드
    fetch("/api/mypage/me")
        .then((res) => {
            if (!res.ok) throw new Error("failed");
            return res.text();
        })
        .then((text) => {
            if (!text) {
                window.location.href = "/login";
                return;
            }
            renderProfile(JSON.parse(text));
        })
        .catch(() => {
            window.location.href = "/login";
        });

    // 1-1) 통계 카드 (작성한 리뷰 / 받은 좋아요 등)
    function refreshStats() {
        fetch("/api/mypage/stats")
            .then((res) => (res.ok ? res.json() : null))
            .then((data) => {
                if (!data) return;
                document.getElementById("stat-post-count").textContent = data.postCount;
                document.getElementById("stat-comment-count").textContent = data.commentCount;
                document.getElementById("stat-review-count").textContent = data.reviewCount;
                document.getElementById("stat-report-count").textContent = data.reportCount;
            })
            .catch(() => {});
    }
    refreshStats();

    // 1-2) 내가 쓴 리뷰 (프로필 탭 '최근 작성한 리뷰' + 리뷰 탭 전체 목록에서 공용으로 사용)
    let myReviewsCache = null;

    function renderStars(rating) {
        if (rating === null || rating === undefined) return "-";
        return "★ " + rating.toFixed(1);
    }

    // 리뷰 내용/맛집 이름 같은 사용자 입력이 화면 태그로 해석되지 않도록 변환
    function escapeHtml(value) {
        const div = document.createElement("div");
        div.textContent = value == null ? "" : String(value);
        return div.innerHTML;
    }

    function reviewCardHtml(review) {
        const thumbStyle = review.thumbnailUrl
            ? ' style="background-image:url(\'' + encodeURI(review.thumbnailUrl) + '\')"'
            : "";
        const href = review.linkUrl || "/reviews/" + review.reviewId;
        return (
            '<div class="my-review-card">' +
            '<a class="my-review-link" href="' + escapeHtml(href) + '">' +
            '<div class="my-review-thumb"' + thumbStyle + '></div>' +
            '<div class="my-review-body">' +
            '<div class="my-review-top">' +
            '<span class="my-review-restaurant">' + escapeHtml(review.restaurantName) + "</span>" +
            '<span class="my-review-rating">' + renderStars(review.rating) + "</span>" +
            "</div>" +
            '<p class="my-review-content">' + escapeHtml(review.content) + "</p>" +
            '<span class="my-review-meta">' + escapeHtml(review.createdAt) + " · 도움이 돼요 " + review.helpCount + "</span>" +
            "</div>" +
            "</a>" +
            '<button type="button" class="mypage-delete-btn" data-delete-type="review" data-delete-id="' + escapeHtml(review.reviewId) + '">삭제</button>' +
            "</div>"
        );
    }

    function renderAllReviews(reviews) {
        const el = document.getElementById("reviews-tab-panel");
        if (!reviews.length) {
            el.innerHTML = '<p class="mypage-empty">아직 작성한 리뷰가 없습니다.<br>맛집 페이지에서 첫 리뷰를 남겨보세요.</p>';
            return;
        }
        el.innerHTML = reviews.map(reviewCardHtml).join("");
    }

    function loadMyReviews() {
        if (myReviewsCache) {
            return Promise.resolve(myReviewsCache);
        }
        return fetch("/api/mypage/reviews")
            .then((res) => (res.ok ? res.json() : []))
            .then((data) => {
                myReviewsCache = data || [];
                return myReviewsCache;
            })
            .catch(() => []);
    }

    // 1-3) 작성한 제보 (프로필 탭 '최근 제보 내역' + 제보 탭 전체 목록에서 공용으로 사용)
    let myReportsCache = null;

    const reportStatusLabel = { PENDING: "보류중", APPROVED: "승인됨", REJECTED: "반려됨" };
    const reportStatusClass = { PENDING: "pending", APPROVED: "approved", REJECTED: "rejected" };
    const reportCategoryLabel = { general: "일반", recycle: "재활용", can: "캔/병" };

    function reportCardHtml(r) {
        const rejectHtml = r.status === "REJECTED" && r.rejectReason
            ? '<p class="my-report-reject-reason">반려 사유: ' + r.rejectReason + "</p>"
            : "";
        return (
            '<div class="my-report-card">' +
            '<div class="my-report-body">' +
            "<b>" + (r.name || (reportCategoryLabel[r.category] || r.category) + " 쓰레기통") + "</b>" +
            '<p>' + (r.address || (r.latitude.toFixed(5) + ", " + r.longitude.toFixed(5))) + "</p>" +
            '<span class="my-report-meta">' + r.createdAt + "</span>" +
            rejectHtml +
            "</div>" +
            '<span class="my-report-status ' + reportStatusClass[r.status] + '">' + reportStatusLabel[r.status] + "</span>" +
            "</div>"
        );
    }

    function renderReports(reports) {
        const el = document.getElementById("reports-tab-panel");
        if (!reports.length) {
            el.innerHTML = '<p class="mypage-empty">아직 제보한 내역이 없습니다.<br><a href="/report">쓰레기통 위치 제보하러 가기</a></p>';
            return;
        }
        el.innerHTML = reports.map(reportCardHtml).join("");
    }

    function loadMyReports() {
        if (myReportsCache) {
            return Promise.resolve(myReportsCache);
        }
        return fetch("/api/reports/mine")
            .then((res) => (res.ok ? res.json() : []))
            .then((data) => {
                myReportsCache = data || [];
                return myReportsCache;
            })
            .catch(() => []);
    }

    // 1-4) 작성한 게시글
    let myPostsCache = null;

    function postCardHtml(p) {
        return (
            '<div class="my-post-card">' +
            '<a class="my-post-link" href="' + escapeHtml(p.linkUrl) + '">' +
            '<div class="my-post-body">' +
            "<b>" + escapeHtml(p.title) + "</b>" +
            '<p>' + escapeHtml(p.contentPreview) + "</p>" +
            '<span class="my-post-meta">' + escapeHtml(p.createdAt) + " · 조회 " + (p.viewCount != null ? p.viewCount : 0) + "</span>" +
            "</div>" +
            "</a>" +
            '<button type="button" class="mypage-delete-btn" data-delete-type="post" data-delete-id="' + escapeHtml(p.postId) + '">삭제</button>' +
            "</div>"
        );
    }

    function renderPosts(posts) {
        const el = document.getElementById("posts-tab-panel");
        if (!posts.length) {
            el.innerHTML = '<p class="mypage-empty">아직 작성한 게시글이 없습니다.<br><a href="/community/write">커뮤니티에 글 쓰러 가기</a></p>';
            return;
        }
        el.innerHTML = posts.map(postCardHtml).join("");
    }

    function loadMyPosts() {
        if (myPostsCache) {
            return Promise.resolve(myPostsCache);
        }
        return fetch("/api/mypage/posts")
            .then((res) => (res.ok ? res.json() : []))
            .then((data) => {
                myPostsCache = data || [];
                return myPostsCache;
            })
            .catch(() => []);
    }

    // 1-5) 작성한 댓글
    let myCommentsCache = null;

    function commentCardHtml(c) {
        return (
            '<div class="my-comment-card">' +
            '<a class="my-comment-link" href="' + escapeHtml(c.linkUrl) + '">' +
            '<div class="my-comment-body">' +
            '<span class="my-comment-post-title">' + escapeHtml(c.postTitle) + "</span>" +
            '<p>' + escapeHtml(c.content) + "</p>" +
            '<span class="my-comment-meta">' + escapeHtml(c.createdAt) + "</span>" +
            "</div>" +
            "</a>" +
            '<button type="button" class="mypage-delete-btn" data-delete-type="comment" data-delete-id="' + escapeHtml(c.commentId) + '">삭제</button>' +
            "</div>"
        );
    }

    function renderComments(comments) {
        const el = document.getElementById("comments-tab-panel");
        if (!comments.length) {
            el.innerHTML = '<p class="mypage-empty">아직 작성한 댓글이 없습니다.</p>';
            return;
        }
        el.innerHTML = comments.map(commentCardHtml).join("");
    }

    function loadMyComments() {
        if (myCommentsCache) {
            return Promise.resolve(myCommentsCache);
        }
        return fetch("/api/mypage/comments")
            .then((res) => (res.ok ? res.json() : []))
            .then((data) => {
                myCommentsCache = data || [];
                return myCommentsCache;
            })
            .catch(() => []);
    }

    // 마이페이지에서 본인 게시글/댓글/리뷰 삭제
    [
        { panelId: "posts-tab-panel", type: "post", idKey: "postId", getCache: () => myPostsCache, setCache: (items) => { myPostsCache = items; }, render: renderPosts, url: (id) => "/api/community/" + id },
        { panelId: "comments-tab-panel", type: "comment", idKey: "commentId", getCache: () => myCommentsCache, setCache: (items) => { myCommentsCache = items; }, render: renderComments, url: (id) => "/api/community/comments/" + id },
        { panelId: "reviews-tab-panel", type: "review", idKey: "reviewId", getCache: () => myReviewsCache, setCache: (items) => { myReviewsCache = items; }, render: renderAllReviews, url: (id) => "/api/mypage/reviews/" + id }
    ].forEach((config) => {
        const panel = document.getElementById(config.panelId);
        panel.addEventListener("click", function (event) {
            const button = event.target.closest("[data-delete-type]");
            if (!button || button.dataset.deleteType !== config.type) return;
            event.preventDefault();
            event.stopPropagation();
            if (!window.confirm("삭제한 내용은 복구할 수 없습니다. 삭제하시겠습니까?")) return;

            button.disabled = true;
            fetch(config.url(encodeURIComponent(button.dataset.deleteId)), { method: "DELETE" })
                .then((response) => {
                    if (!response.ok) {
                        throw new Error(response.status === 403
                            ? "본인이 작성한 내용만 삭제할 수 있습니다."
                            : "삭제하지 못했습니다. 다시 시도해 주세요.");
                    }
                    const remaining = (config.getCache() || []).filter(
                        (item) => String(item[config.idKey]) !== button.dataset.deleteId
                    );
                    config.setCache(remaining);
                    config.render(remaining);
                    if (config.type === "post" && myCommentsCache) {
                        myCommentsCache = myCommentsCache.filter((comment) => String(comment.postId) !== button.dataset.deleteId);
                        renderComments(myCommentsCache);
                    }
                    refreshStats();
                })
                .catch((error) => {
                    window.alert(error.message || "삭제하지 못했습니다. 다시 시도해 주세요.");
                    button.disabled = false;
                });
        });
    });

    // 2) 사이드바 메뉴 클릭 -> 페이지 이동 없이 해당 탭만 보여주기
    const navLinks = document.querySelectorAll(".mypage-nav a[data-tab]");
    const tabSections = document.querySelectorAll(".mypage-tab-content");

    function activateTab(tabName) {
        navLinks.forEach((link) => {
            link.classList.toggle("active", link.dataset.tab === tabName);
        });
        tabSections.forEach((section) => {
            section.hidden = section.id !== "tab-" + tabName;
        });
        if (tabName === "settings") {
            loadSettings();
        }
        if (tabName === "reviews") {
            loadMyReviews().then(renderAllReviews);
        }
        if (tabName === "reports") {
            loadMyReports().then(renderReports);
        }
        if (tabName === "posts") {
            loadMyPosts().then(renderPosts);
        }
        if (tabName === "comments") {
            loadMyComments().then(renderComments);
        }
        if (tabName === "notifications") {
            resetNotificationTab();
        }
    }

    navLinks.forEach((link) => {
        link.addEventListener("click", function (e) {
            e.preventDefault();
            activateTab(this.dataset.tab);
        });
    });

    document.querySelectorAll("[data-tab-link]").forEach((link) => {
        link.addEventListener("click", function (e) {
            e.preventDefault();
            activateTab(this.dataset.tabLink);
        });
    });

    // 3) "정보 수정" -> 수정 패널 열기/닫기/저장
    const editPanel = document.getElementById("mypage-edit-panel");
    const editBtn = document.getElementById("mypage-edit-btn");
    const saveBtn = document.getElementById("mypage-save-btn");
    const cancelBtn = document.getElementById("mypage-cancel-btn");
    const errorEl = document.getElementById("mypage-edit-error");

    function openEditPanel() {
        if (!currentProfile) return;
        document.getElementById("edit-name").value = currentProfile.name;
        document.getElementById("edit-nickname").value = currentProfile.nickname;

        const nationalitySelect = document.getElementById("edit-nationality");
        const currentNationality = currentProfile.nationality === "미입력" ? "대한민국" : currentProfile.nationality;
        if ([...nationalitySelect.options].some((opt) => opt.value === currentNationality)) {
            nationalitySelect.value = currentNationality;
        }

        errorEl.textContent = "";
        editPanel.hidden = false;
    }

    function closeEditPanel() {
        editPanel.hidden = true;
    }

    editBtn.addEventListener("click", function () {
        if (editPanel.hidden) {
            openEditPanel();
        } else {
            closeEditPanel();
        }
    });
    cancelBtn.addEventListener("click", closeEditPanel);

    saveBtn.addEventListener("click", function () {
        const payload = {
            name: document.getElementById("edit-name").value.trim(),
            nickname: document.getElementById("edit-nickname").value.trim(),
            nationality: document.getElementById("edit-nationality").value,
        };

        errorEl.textContent = "";

        fetch("/api/mypage/me", {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
        })
            .then(async (res) => {
                const data = await res.json();
                if (!res.ok) {
                    errorEl.textContent = data.message || "수정에 실패했습니다.";
                    return;
                }
                renderProfile(data);
                closeEditPanel();
            })
            .catch(() => {
                errorEl.textContent = "수정 중 오류가 발생했습니다. 다시 시도해주세요.";
            });
    });

    // 4) 설정 탭: 알림 / 위치정보
    const notifyToggle = document.getElementById("setting-notify-email");
    const locationToggle = document.getElementById("setting-location");
    const locationCheckPanel = document.getElementById("location-check-panel");
    const locationResult = document.getElementById("location-result");
    const saveMessageEl = document.getElementById("settings-save-message");

    let settingsLoaded = false;

    function showSaveMessage(text, isError) {
        saveMessageEl.textContent = text;
        saveMessageEl.className = "settings-save-message " + (isError ? "error" : "success");
    }

    // 알림/위치 설정은 서버에 저장
    function saveServerSettings() {
        fetch("/api/mypage/settings", {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                notifyEmail: notifyToggle.checked,
                locationEnabled: locationToggle.checked,
            }),
        })
            .then(async (res) => {
                const data = await res.json();
                if (!res.ok) {
                    showSaveMessage(data.message || "저장에 실패했습니다.", true);
                    return;
                }
                showSaveMessage("설정이 저장되었습니다.", false);
            })
            .catch(() => showSaveMessage("저장 중 오류가 발생했습니다.", true));
    }

    notifyToggle.addEventListener("change", saveServerSettings);
    locationToggle.addEventListener("change", function () {
        locationCheckPanel.hidden = !locationToggle.checked;
        locationResult.textContent = "";
        saveServerSettings();
    });

    document.getElementById("location-check-btn").addEventListener("click", function () {
        if (!navigator.geolocation) {
            locationResult.textContent = "이 브라우저는 위치 정보 기능을 지원하지 않습니다.";
            return;
        }
        locationResult.textContent = "위치 확인 중...";
        navigator.geolocation.getCurrentPosition(
            function (pos) {
                locationResult.textContent =
                    "현재 위치: 위도 " + pos.coords.latitude.toFixed(5) +
                    ", 경도 " + pos.coords.longitude.toFixed(5);
            },
            function () {
                locationResult.textContent = "위치 권한이 거부되었거나 확인할 수 없습니다.";
            }
        );
    });

    function loadSettings() {
        if (settingsLoaded) return; // 알림/위치는 서버에서 한 번만 불러오면 충분
        fetch("/api/mypage/settings")
            .then((res) => res.json())
            .then((data) => {
                notifyToggle.checked = data.notifyEmail;
                locationToggle.checked = data.locationEnabled;
                locationCheckPanel.hidden = !data.locationEnabled;
                settingsLoaded = true;
            })
            .catch(() => showSaveMessage("설정을 불러오지 못했습니다.", true));
    }

    // ===== 알림 탭: 받은 알림 목록(더 보기) / 읽음 / 삭제 =====
    const NOTIF_PAGE_SIZE = 10;
    const NOTIF_ICONS = { NOTICE: "📢", COMMENT: "💬", REVIEW: "⭐", REPORT: "🗑️" };
    let notifPage = 0;
    const notifListEl = document.getElementById("notif-tab-list");
    const notifEmptyEl = document.getElementById("notif-tab-empty");
    const notifMoreEl = document.getElementById("notif-tab-more");
    const notifUnreadEl = document.getElementById("notif-tab-unread");

    function refreshHeaderBell() {
        if (window.BingoNotifications) window.BingoNotifications.refresh();
    }

    function resetNotificationTab() {
        notifPage = 0;
        notifListEl.innerHTML = "";
        loadNotificationPage();
    }

    function loadNotificationPage() {
        fetch("/api/notifications?page=" + notifPage + "&size=" + NOTIF_PAGE_SIZE)
            .then((res) => {
                if (res.status === 401) { window.location.href = "/login"; return null; }
                return res.json();
            })
            .then((data) => {
                if (!data) return;
                data.items.forEach(appendNotificationRow);
                notifEmptyEl.hidden = data.totalElements > 0;
                notifUnreadEl.textContent = data.unreadCount > 0 ? "안 읽음 " + data.unreadCount : "";
                notifMoreEl.hidden = data.page + 1 >= data.totalPages;
            })
            .catch(() => {
                notifEmptyEl.hidden = false;
                notifEmptyEl.textContent = "알림을 불러오지 못했습니다.";
            });
    }

    function appendNotificationRow(n) {
        const row = document.createElement("div");
        row.className = "notif-tab-item" + (n.read ? "" : " unread");

        const ic = document.createElement("span");
        ic.className = "notif-item-icon";
        ic.textContent = NOTIF_ICONS[n.type] || "🔔";

        const body = document.createElement("div");
        body.className = "notif-tab-body";
        const msg = document.createElement("span");
        msg.className = "notif-tab-msg";
        msg.textContent = n.message;
        const time = document.createElement("span");
        time.className = "notif-tab-time";
        time.textContent = n.createdAt;
        body.appendChild(msg);
        body.appendChild(time);

        const del = document.createElement("button");
        del.type = "button";
        del.className = "notif-tab-delete";
        del.title = "삭제";
        del.textContent = "×";

        row.appendChild(ic);
        row.appendChild(body);
        row.appendChild(del);

        row.addEventListener("click", function (e) {
            if (e.target === del) return;
            const go = () => { window.location.href = n.linkUrl || "/mypage?tab=notifications"; };
            if (n.read) { go(); return; }
            fetch("/api/notifications/" + n.id + "/read", { method: "POST" }).then(go, go);
        });
        del.addEventListener("click", function () {
            fetch("/api/notifications/" + n.id, { method: "DELETE" })
                .then(() => { resetNotificationTab(); refreshHeaderBell(); });
        });
        notifListEl.appendChild(row);
    }

    notifMoreEl.addEventListener("click", function () {
        notifPage += 1;
        loadNotificationPage();
    });

    document.getElementById("notif-tab-readall").addEventListener("click", function () {
        fetch("/api/notifications/read-all", { method: "POST" })
            .then(() => { resetNotificationTab(); refreshHeaderBell(); });
    });

    // 알림 링크(/mypage?tab=reports 등)로 들어오면 해당 탭을 바로 열어준다
    const initialTab = new URLSearchParams(window.location.search).get("tab");
    if (initialTab && document.getElementById("tab-" + initialTab)) {
        activateTab(initialTab);
    }
});
