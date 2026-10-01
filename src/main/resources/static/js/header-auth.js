/**
 * 다크모드는 화면이 다 그려지기 전에 최대한 빨리 적용해서 밝은 화면이 잠깐 보였다가
 * 어두워지는 깜빡임을 막는다. localStorage에 저장된 값을 읽어 <html>에 표시한다.
 */
(function () {
    if (localStorage.getItem("bingomap-theme") === "dark") {
        document.documentElement.setAttribute("data-theme", "dark");
    }
})();

/**
 * 페이지 로드 시 /api/session을 호출해서 로그인 상태를 확인하고,
 * 로그인 상태면 헤더의 "로그인" 버튼을 "{이름}님" + "로그아웃"으로 바꿔준다.
 * 모든 페이지 <body> 하단에 <script src="/js/header-auth.js"></script> 를 넣어서 사용한다.
 */
document.addEventListener("DOMContentLoaded", function () {
    // 점검 모드 배너 표시
    fetch("/api/settings/public")
        .then((res) => res.json())
        .then((data) => {
            if (!data.maintenanceMode) return;
            const banner = document.createElement("div");
            banner.className = "site-maintenance-banner";
            banner.textContent = data.maintenanceMessage || "현재 서버 점검 중입니다.";
            document.body.prepend(banner);
        })
        .catch(() => {});

    fetch("/api/session")
        .then((res) => res.json())
        .then((data) => {
            const actions = document.querySelector(".header-actions");
            if (!actions) return;

            const loginLink = actions.querySelector("a.login");
            if (!data.loggedIn || !loginLink) return;

            // "로그인" 버튼 -> "{이름}님" 텍스트로 변경, 마이페이지로 이동하는 링크로 만듦
            loginLink.textContent = (data.name || "회원") + "님";
            loginLink.href = "/mypage";

            // 로그아웃 버튼 추가
            const logoutLink = document.createElement("a");
            logoutLink.href = "/logout";
            logoutLink.className = "language";
            logoutLink.textContent = "로그아웃";
            loginLink.after(logoutLink);

            // 관리자면 "관리자 페이지" 링크 추가
            if (data.role === "ADMIN") {
                const adminLink = document.createElement("a");
                adminLink.href = "/admin";
                adminLink.className = "language";
                adminLink.textContent = "관리자 페이지";
                loginLink.after(adminLink);
                startAdminReportAlert(adminLink);
            }

            // 메뉴 바(nav)에도 "마이페이지"를 추가 (비회원에게는 애초에 추가하지 않음)
            const nav = document.querySelector(".header .nav");
            if (nav && !nav.querySelector('a[href="/mypage"]')) {
                const mypageNavLink = document.createElement("a");
                mypageNavLink.href = "/mypage";
                mypageNavLink.textContent = "마이페이지";
                nav.appendChild(mypageNavLink);
            }
        })
        .catch(() => {
            // 세션 확인 실패 시 기존 "로그인" 버튼 그대로 둠
        });
});

/**
 * 관리자 알림: 검수 대기(PENDING) 쓰레기통 제보 수를
 *  - "관리자 페이지" 링크 옆 빨간 배지로 항상 보여주고
 *  - 로그인 후 처음 확인했을 때 / 새 제보가 늘었을 때 화면 구석에 알림 토스트로 알려준다.
 * 30초마다 확인한다. (서버: GET /api/admin/reports/pending-count, 관리자만 호출 가능)
 */
function startAdminReportAlert(adminLink) {
    const SEEN_KEY = "bingomap-admin-pending-seen";

    const badge = document.createElement("span");
    badge.style.cssText = "display:none;margin-left:6px;min-width:18px;padding:1px 6px;border-radius:10px;" +
        "background:#e0392b;color:#fff;font-size:11px;font-weight:800;line-height:16px;text-align:center;";
    adminLink.appendChild(badge);

    function showToast(message) {
        const old = document.getElementById("admin-report-toast");
        if (old) old.remove();

        const toast = document.createElement("div");
        toast.id = "admin-report-toast";
        toast.textContent = message;
        toast.style.cssText = "position:fixed;right:24px;bottom:24px;z-index:99999;max-width:300px;padding:14px 18px;" +
            "border-radius:12px;background:#1b1e24;color:#fff;font-size:13px;font-weight:700;line-height:1.5;" +
            "box-shadow:0 8px 25px rgba(0,0,0,.3);cursor:pointer;";
        toast.addEventListener("click", function () {
            window.location.href = "/admin";
        });
        document.body.appendChild(toast);
        setTimeout(function () { toast.remove(); }, 8000);
    }

    function check() {
        if (document.hidden) return;

        fetch("/api/admin/reports/pending-count")
            .then(function (res) { return res.ok ? res.json() : null; })
            .then(function (data) {
                if (!data || typeof data.count !== "number") return;

                badge.textContent = data.count;
                badge.style.display = data.count > 0 ? "inline-block" : "none";

                let seen = null;
                try { seen = sessionStorage.getItem(SEEN_KEY); } catch (e) { /* 저장소 차단 시 무시 */ }

                if (data.count > 0 && (seen === null || data.count > Number(seen))) {
                    showToast(seen === null
                        ? "검수 대기 중인 쓰레기통 제보가 " + data.count + "건 있습니다. (클릭하면 관리자 페이지)"
                        : "새 쓰레기통 제보가 들어왔습니다. 대기 " + data.count + "건 (클릭하면 관리자 페이지)");
                }

                try { sessionStorage.setItem(SEEN_KEY, String(data.count)); } catch (e) { /* 무시 */ }
            })
            .catch(function () { /* 알림 확인 실패는 조용히 무시 */ });
    }

    check();
    setInterval(check, 30000);
}