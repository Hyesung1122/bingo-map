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
        if (tabName === "settings") {
            loadSettings();
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

    // 4) 설정 탭: 다크모드 / 알림 / 위치정보
    const darkModeToggle = document.getElementById("setting-dark-mode");
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

    // 다크모드는 서버 저장 없이 즉시 적용 + localStorage에 기억
    darkModeToggle.addEventListener("change", function () {
        const isDark = darkModeToggle.checked;
        document.documentElement.setAttribute("data-theme", isDark ? "dark" : "light");
        localStorage.setItem("bingomap-theme", isDark ? "dark" : "light");
    });

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
        // 다크모드는 localStorage 기준으로 스위치 상태만 맞춰줌
        darkModeToggle.checked = localStorage.getItem("bingomap-theme") === "dark";

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
});