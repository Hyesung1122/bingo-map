document.addEventListener("DOMContentLoaded", function () {

    let currentProfile = null; // 마지막으로 불러온 프로필 (취소 시 복원용)

    function renderProfile(data) {
        currentProfile = data;
        document.getElementById("mypage-name").textContent = data.name + "님";
        document.getElementById("mypage-nickname").textContent = data.nickname;
        document.getElementById("mypage-badge").textContent = data.role === "ADMIN" ? "관리자" : "일반회원";
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
});