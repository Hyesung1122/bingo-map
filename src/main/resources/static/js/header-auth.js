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
            }
        })
        .catch(() => {
            // 세션 확인 실패 시 기존 "로그인" 버튼 그대로 둠
        });
});