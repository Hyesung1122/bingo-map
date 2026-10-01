/**
 * 페이지 로드 시 /api/session을 호출해서 로그인 상태를 확인하고,
 * 로그인 상태면 헤더의 "로그인" 버튼을 "{이름}님" + "로그아웃"으로 바꿔준다.
 * 모든 페이지 <body> 하단에 <script src="/js/header-auth.js"></script> 를 넣어서 사용한다.
 */
document.addEventListener("DOMContentLoaded", function () {
    renderSharedHeader();
    renderSharedFooter();

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
            const actions = document.querySelector(".site-header__actions");
            if (!actions) return;

            const loginLink = actions.querySelector("a.site-header__login");
            if (!data.loggedIn || !loginLink) return;

            // "로그인" 버튼 -> "{이름}님" 텍스트로 변경, 마이페이지로 이동하는 링크로 만듦
            loginLink.textContent = (data.name || "회원") + "님";
            loginLink.href = "/mypage";

            // 로그아웃 버튼 추가
            const logoutLink = document.createElement("a");
            logoutLink.href = "/logout";
            logoutLink.className = "site-header__aux";
            logoutLink.textContent = "로그아웃";
            loginLink.after(logoutLink);

            // 관리자/매니저면 관리 콘솔 링크 추가
            if (data.role === "ADMIN" || data.role === "MANAGER") {
                const adminLink = document.createElement("a");
                adminLink.href = "/admin";
                adminLink.className = "site-header__aux";
                adminLink.textContent = data.role === "ADMIN" ? "관리자 페이지" : "매니저 페이지";
                loginLink.after(adminLink);
                if (data.role === "ADMIN") startAdminReportAlert(adminLink);
            }

            // 메뉴 바(nav)에도 "마이페이지"를 추가 (비회원에게는 애초에 추가하지 않음)
            const nav = document.querySelector(".site-header__nav");
            if (nav && !nav.querySelector('a[href="/mypage"]')) {
                const mypageNavLink = document.createElement("a");
                mypageNavLink.href = "/mypage";
                mypageNavLink.textContent = "마이페이지";
                nav.appendChild(mypageNavLink);
            }

            // 로그인 상태면 알림(🔔 종 아이콘)도 붙인다
            loadNotifications(actions, data);
        })
        .catch(() => {
            // 세션 확인 실패 시 기존 "로그인" 버튼 그대로 둠
        });
});

/** 모든 페이지에서 같은 상단 로고와 메뉴를 사용합니다. */
function renderSharedHeader() {
    const previousHeader = document.querySelector("body > header");
    if (!previousHeader || previousHeader.dataset.sharedHeader === "true") return;

    // 주변 맛집 페이지와 동일한 Bootstrap 쓰레기통 아이콘을 공통 헤더에서 사용합니다.
    if (!document.querySelector('link[href*="bootstrap-icons"]')) {
        const iconStylesheet = document.createElement("link");
        iconStylesheet.rel = "stylesheet";
        iconStylesheet.href = "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css";
        document.head.appendChild(iconStylesheet);
    }

    const path = window.location.pathname;
    const navItems = [
        ["home", "홈", "/"],
        ["map", "지도", "/map"],
        ["restaurants", "주변 맛집", "/restaurants"],
        ["favorites", "즐겨찾기", "/favorites"],
        ["reviews", "리뷰", "/reviews"],
        ["community", "커뮤니티", "/community"],
        ["notices", "공지사항", "/notices"]
    ];
    const activeKey = path === "/" ? "home"
        : path.startsWith("/map") ? "map"
        : path.startsWith("/restaurants") ? "restaurants"
        : path.startsWith("/favorites") ? "favorites"
        : path.startsWith("/reviews") ? "reviews"
        : path.startsWith("/community") ? "community"
        : path.startsWith("/notices") ? "notices"
        : path.startsWith("/mypage") ? "mypage"
        : null;

    const header = document.createElement("header");
    header.className = "site-header";
    header.dataset.sharedHeader = "true";

    const inner = document.createElement("div");
    inner.className = "site-header__inner";
    if (path === "/") inner.classList.add("site-header__inner--with-translation");

    const brand = document.createElement("a");
    brand.className = "site-header__brand";
    brand.href = "/";
    brand.setAttribute("aria-label", "BinGo Map 홈");
    brand.innerHTML = '<i class="bi bi-trash3-fill site-brand__trash" aria-hidden="true"></i><span class="site-header__brand-copy"><strong>BinGo Map</strong><small>Clean &amp; Gourmet</small></span>';

    const nav = document.createElement("nav");
    nav.className = "site-header__nav";
    nav.setAttribute("aria-label", "주 메뉴");
    navItems.forEach(function (item) {
        const link = document.createElement("a");
        link.href = item[2];
        link.textContent = item[1];
        if (item[0] === activeKey) link.setAttribute("aria-current", "page");
        nav.appendChild(link);
    });

    const actions = document.createElement("div");
    actions.className = "site-header__actions";
    const login = document.createElement("a");
    login.className = "site-header__login";
    login.href = "/login";
    login.textContent = "로그인";
    actions.appendChild(login);

    inner.append(brand, nav, actions);
    if (path === "/") {
        const translationNote = document.createElement("div");
        translationNote.className = "site-header__translation-note";
        translationNote.setAttribute("aria-label", "Chrome 번역 안내");
        translationNote.innerHTML = '<span>영어·일본어는 Chrome 메뉴에서 ‘번역’을 선택해 주세요.</span><span lang="en">English: Choose “Translate” in Chrome.</span><span lang="ja">日本語：Chromeのメニューから「翻訳」を選択してください。</span>';
        inner.appendChild(translationNote);
    }

    header.appendChild(inner);
    previousHeader.replaceWith(header);
}

/** 푸터 로고도 헤더와 같은 Bootstrap 쓰레기통 아이콘으로 맞춥니다. */
function renderSharedFooter() {
    const footerBrand = document.querySelector("footer .footer-brand");
    if (!footerBrand) return;

    const oldIcon = footerBrand.querySelector(".logo-mark, .site-header__trash, .site-brand__trash");
    if (!oldIcon) return;

    const icon = document.createElement("i");
    icon.className = "bi bi-trash3-fill site-brand__trash";
    icon.setAttribute("aria-hidden", "true");
    oldIcon.replaceWith(icon);
}

/**
 * 알림 스크립트(/js/notifications.js)를 필요할 때만 불러와서 헤더에 🔔 종 아이콘을 붙인다.
 * header-auth.js 하나만 넣으면 알림이 함께 동작한다.
 */
function loadNotifications(actions, session) {
    if (window.BingoNotifications) {
        window.BingoNotifications.init(actions, session);
        return;
    }
    const script = document.createElement("script");
    script.src = "/js/notifications.js";
    script.onload = function () {
        if (window.BingoNotifications) window.BingoNotifications.init(actions, session);
    };
    document.head.appendChild(script);
}

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
