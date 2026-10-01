/**
 * 헤더 알림: 종 아이콘 + 드롭다운 + 새 알림 팝업 + 30초마다 확인
 * header-auth.js가 로그인 상태일 때만 불러와서 BingoNotifications.init(...)을 호출한다.
 */
(function () {
    "use strict";
    if (window.BingoNotifications) return;

    var POLL_MS = 30000;
    var TOAST_MS = 6000;
    var MAX_TOASTS = 3;
    var ICONS = { NOTICE: "📢", COMMENT: "💬", REVIEW: "⭐", REPORT: "🗑️" };

    var els = {};
    var initialized = false;
    var stopped = false;
    var pollTimer = null;
    var lastSeenKey = "";
    var lastSeenId = null;

    function icon(type) { return ICONS[type] || "🔔"; }

    function timeAgo(iso) {
        var t = new Date(iso).getTime();
        if (isNaN(t)) return "";
        var s = Math.floor((Date.now() - t) / 1000);
        if (s < 60) return "방금 전";
        var m = Math.floor(s / 60);
        if (m < 60) return m + "분 전";
        var h = Math.floor(m / 60);
        if (h < 24) return h + "시간 전";
        var d = Math.floor(h / 24);
        if (d < 7) return d + "일 전";
        return String(iso).slice(0, 10).replace(/-/g, ".");
    }

    function ensureCss(done) {
        if (document.querySelector('link[href^="/css/notifications.css"]')) { done(); return; }
        var finished = false;
        function finish() { if (!finished) { finished = true; done(); } }
        var link = document.createElement("link");
        link.rel = "stylesheet";
        link.href = "/css/notifications.css";
        link.onload = finish;
        link.onerror = finish;
        document.head.appendChild(link);
        setTimeout(finish, 1500);
    }

    function readLastSeen() {
        try {
            var v = parseInt(localStorage.getItem(lastSeenKey), 10);
            return isNaN(v) ? null : v;
        } catch (e) { return null; }
    }

    function saveLastSeen(id) {
        lastSeenId = id;
        try { localStorage.setItem(lastSeenKey, String(id)); } catch (e) { /* 무시 */ }
    }

    function init(actions, session) {
        if (initialized || !actions || actions.querySelector(".notif-wrap")) return;
        initialized = true;
        lastSeenKey = "bingomap-notif-last-" + ((session && session.name) || "");
        lastSeenId = readLastSeen();

        ensureCss(function () {
            build(actions);
            refresh(true);
            pollTimer = setInterval(function () {
                if (document.visibilityState === "visible") refresh(true);
            }, POLL_MS);
            document.addEventListener("visibilitychange", function () {
                if (document.visibilityState === "visible") refresh(true);
            });
        });
    }

    function build(actions) {
        var wrap = document.createElement("div");
        wrap.className = "notif-wrap";
        wrap.innerHTML =
            '<button type="button" class="notif-bell" aria-label="알림">🔔<span class="notif-badge" hidden>0</span></button>' +
            '<div class="notif-panel" hidden>' +
            '<div class="notif-panel-head"><b>알림</b><button type="button" class="notif-readall">모두 읽음</button></div>' +
            '<div class="notif-list"></div>' +
            '<a class="notif-more" href="/mypage?tab=notifications">전체 알림 보기</a>' +
            "</div>";
        actions.insertBefore(wrap, actions.firstChild);

        els.wrap = wrap;
        els.bell = wrap.querySelector(".notif-bell");
        els.badge = wrap.querySelector(".notif-badge");
        els.panel = wrap.querySelector(".notif-panel");
        els.list = wrap.querySelector(".notif-list");

        els.bell.addEventListener("click", function (e) {
            e.stopPropagation();
            var willOpen = els.panel.hidden;
            els.panel.hidden = !willOpen;
            if (willOpen) refresh(false);
        });
        els.panel.addEventListener("click", function (e) { e.stopPropagation(); });
        document.addEventListener("click", closePanel);
        document.addEventListener("keydown", function (e) { if (e.key === "Escape") closePanel(); });

        wrap.querySelector(".notif-readall").addEventListener("click", function () {
            post("/api/notifications/read-all").then(function () { return refresh(false); });
        });
    }

    function closePanel() {
        if (els.panel && !els.panel.hidden) els.panel.hidden = true;
    }

    function post(url) {
        return fetch(url, { method: "POST" }).catch(function () {});
    }

    function open(n) {
        var target = n.linkUrl || "/mypage?tab=notifications";
        function go() { window.location.href = target; }
        if (n.read) { go(); return; }
        post("/api/notifications/" + n.id + "/read").then(go, go);
    }

    function render(data) {
        var count = data.unreadCount || 0;
        els.badge.textContent = count > 99 ? "99+" : String(count);
        els.badge.hidden = count === 0;

        els.list.innerHTML = "";
        if (!data.items.length) {
            var empty = document.createElement("p");
            empty.className = "notif-empty";
            empty.textContent = "아직 받은 알림이 없습니다.";
            els.list.appendChild(empty);
            return;
        }
        data.items.forEach(function (n) { els.list.appendChild(buildItem(n)); });
    }

    function buildItem(n) {
        var btn = document.createElement("button");
        btn.type = "button";
        btn.className = "notif-item" + (n.read ? "" : " unread");

        var ic = document.createElement("span");
        ic.className = "notif-item-icon";
        ic.textContent = icon(n.type);

        var body = document.createElement("span");
        body.className = "notif-item-body";
        var msg = document.createElement("span");
        msg.className = "notif-item-msg";
        msg.textContent = n.message;
        var time = document.createElement("span");
        time.className = "notif-item-time";
        time.textContent = timeAgo(n.createdAtIso);
        body.appendChild(msg);
        body.appendChild(time);

        btn.appendChild(ic);
        btn.appendChild(body);
        if (!n.read) {
            var dot = document.createElement("span");
            dot.className = "notif-item-dot";
            btn.appendChild(dot);
        }
        btn.addEventListener("click", function () { open(n); });
        return btn;
    }

    function refresh(allowToast) {
        if (stopped) return Promise.resolve();
        return fetch("/api/notifications/summary")
            .then(function (res) {
                if (res.status === 401) { stop(); return null; }
                return res.ok ? res.json() : null;
            })
            .then(function (data) {
                if (!data) return;
                render(data);
                if (allowToast) showNewToasts(data);
                else if (lastSeenId === null || data.latestId !== lastSeenId) saveLastSeen(data.latestId);
            })
            .catch(function () { /* 다음 확인 때 다시 시도 */ });
    }

    function stop() {
        stopped = true;
        if (pollTimer) clearInterval(pollTimer);
        if (els.wrap) els.wrap.remove();
    }

    // 마지막으로 본 알림 번호보다 큰 '안 읽은' 알림만 팝업으로. 처음 접속 때는 옛 알림이 한꺼번에 뜨지 않게 기록만 한다.
    function showNewToasts(data) {
        var latest = data.latestId || 0;
        if (lastSeenId === null || latest < lastSeenId) { saveLastSeen(latest); return; }
        var fresh = data.items
            .filter(function (n) { return !n.read && n.id > lastSeenId; })
            .sort(function (a, b) { return a.id - b.id; });
        fresh.slice(-MAX_TOASTS).forEach(showToast);
        if (latest > lastSeenId) saveLastSeen(latest);
    }

    function showToast(n) {
        var wrap = document.querySelector(".notif-toast-wrap");
        if (!wrap) {
            wrap = document.createElement("div");
            wrap.className = "notif-toast-wrap";
            document.body.appendChild(wrap);
        }
        while (wrap.children.length >= MAX_TOASTS) wrap.removeChild(wrap.firstChild);

        var toast = document.createElement("div");
        toast.className = "notif-toast";
        toast.setAttribute("role", "alert");

        var ic = document.createElement("span");
        ic.className = "notif-toast-icon";
        ic.textContent = icon(n.type);
        var msg = document.createElement("span");
        msg.className = "notif-toast-msg";
        msg.textContent = n.message;
        var close = document.createElement("button");
        close.type = "button";
        close.className = "notif-toast-close";
        close.textContent = "×";

        toast.appendChild(ic);
        toast.appendChild(msg);
        toast.appendChild(close);

        function remove() { if (toast.parentNode) toast.parentNode.removeChild(toast); }
        toast.addEventListener("click", function (e) {
            if (e.target === close) { remove(); return; }
            open(n);
        });
        wrap.appendChild(toast);
        setTimeout(remove, TOAST_MS);
    }

    window.BingoNotifications = {
        init: init,
        refresh: function () { return refresh(false); },
        icon: icon
    };
})();