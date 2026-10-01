/* 재활용 필터 옆 제보 버튼 → 지도 위치 선택 → 기존 /report 제보 폼. */
(function (global) {
    'use strict';
    if (global.BinGoBinReport) return;
    const STORAGE_KEY = 'bingo.bin-report.location.v1';
    const instances = new WeakMap();

    function point(lat, lon) {
        if (lat == null || lon == null || String(lat).trim() === '' || String(lon).trim() === '') return null;
        const a = Number(lat), b = Number(lon);
        if (!Number.isFinite(a) || !Number.isFinite(b) || Math.abs(a) > 90 || Math.abs(b) > 180) return null;
        return {lat: Number(a.toFixed(7)), lon: Number(b.toFixed(7))};
    }
    function node(tag, className, text) {
        const item = document.createElement(tag);
        if (className) item.className = className;
        if (text != null) item.textContent = text;
        return item;
    }
    function remember(p) {
        try { sessionStorage.setItem(STORAGE_KEY, JSON.stringify({...p, savedAt: Date.now()})); } catch (_) {}
    }
    function remembered() {
        try {
            const value = JSON.parse(sessionStorage.getItem(STORAGE_KEY) || 'null');
            if (!value || !Number.isFinite(value.savedAt) || Date.now() - value.savedAt > 30 * 60 * 1000) return null;
            return point(value.lat, value.lon);
        } catch (_) { return null; }
    }
    function forget() { try { sessionStorage.removeItem(STORAGE_KEY); } catch (_) {} }
    function reportUrl(p) {
        return '/report?' + new URLSearchParams({from: 'map', lat: p.lat.toFixed(7), lon: p.lon.toFixed(7)});
    }
    function mapUrl(p) {
        const query = new URLSearchParams({report: 'pick'});
        if (p) { query.set('reportLat', p.lat.toFixed(7)); query.set('reportLon', p.lon.toFixed(7)); }
        return '/map/map.html?' + query;
    }
    function style() {
        if (document.getElementById('bbr-style')) return;
        const css = node('style'); css.id = 'bbr-style';
        css.textContent = `
.bbr-control{display:inline-flex;flex:0 0 auto;margin:0;font-family:inherit}
.filters.bbr-filter-row{display:flex;align-items:center;flex-wrap:wrap;gap:4px}
.filters.bbr-filter-row>.filter{padding:0 7px;font-size:11px;flex:0 0 auto}
.bbr-button,.bbr-popup .bbr-submit{display:inline-flex;justify-content:center;align-items:center;gap:6px;border:0;border-radius:10px;background:#8543a8;color:#fff!important;padding:11px 14px;font-family:inherit;font-size:13px;font-weight:700;line-height:1.4;text-decoration:none;cursor:pointer;box-shadow:0 2px 10px #35234020}
.bbr-control>.bbr-button{height:31px;padding:0 7px;border:1px solid #8543a8;border-radius:17px;font-size:11px;line-height:1;white-space:nowrap;box-shadow:none}
.bbr-control>.bbr-button:hover{background:#753995}.bbr-button:focus-visible{outline:2px solid #8543a8;outline-offset:2px}
.bbr-button[aria-pressed="true"]{background:#5f287d}.bbr-hint{margin:8px 0 0;padding:10px;border:1px solid #e8dced;border-radius:10px;background:#fff;color:#573767;text-align:left;font-size:12px;line-height:1.6;box-shadow:0 2px 10px #0001}
.bbr-hint[hidden]{display:none}.bbr-picking{cursor:crosshair!important}.bbr-picking .leaflet-grab{cursor:crosshair!important}
.bbr-draft-icon{background:transparent;border:0}.bbr-draft-dot{display:block;width:24px;height:24px;border:3px dashed #8543a8;background:#f9efff;border-radius:50%;box-shadow:0 0 0 5px #fff9;box-sizing:border-box}
/* 공통 map.css의 margin:0!important에 영향을 받지 않도록 내부 padding으로 여백을 줍니다. */
.bbr-popup .leaflet-popup-content-wrapper{padding:1px!important;border:1px solid #eee4f3;border-radius:24px!important;background:#fff;box-shadow:0 12px 36px #43255324}
.bbr-popup .leaflet-popup-content{margin:0!important;padding:24px 22px 18px!important;box-sizing:border-box;line-height:1.65}
.bbr-popup h3{margin:0 0 12px;padding-right:16px;font-size:16px;line-height:1.5;font-weight:700;color:#392b40}
.bbr-popup p{margin:0 0 12px;color:#74677b;font-size:13px;line-height:1.7;word-break:keep-all}
.bbr-popup .bbr-coordinates{margin:14px 0 0;padding:10px 12px;border-radius:14px;background:#f7f2fa;font-size:11px!important;color:#827388!important;overflow-wrap:anywhere;word-break:normal}
.bbr-popup .bbr-submit{width:100%;min-height:46px;box-sizing:border-box;margin-top:18px;padding:12px 16px;border-radius:999px;font-size:13px;box-shadow:0 4px 12px #8543a81f}
.bbr-popup .bbr-submit:hover{background:#753995}.bbr-popup .bbr-submit:focus-visible{outline:2px solid #8543a8;outline-offset:3px}
.bbr-popup .bbr-cancel{display:block;min-height:36px;margin:8px auto 0;border:0;border-radius:999px;background:none;color:#817486;font-family:inherit;font-size:12px;cursor:pointer;padding:8px 22px}
.bbr-popup .bbr-cancel:hover{background:#f7f2fa}
.leaflet-container .bbr-popup a.leaflet-popup-close-button{top:10px;right:10px;width:28px;height:28px;border-radius:50%;background:#f7f2fa;color:#8a7894;font-size:18px;line-height:28px;text-align:center}
.bbr-popup .leaflet-popup-tip{background:#fff;box-shadow:2px 2px 5px #43255312}
.bbr-map-entry,.bbr-map-return{display:inline-block;padding:8px 12px;border:1px solid #d9c6e2;border-radius:8px;color:#753995;text-decoration:none;font-size:13px;font-weight:700;margin-bottom:12px}.bbr-map-summary{padding:14px;margin-bottom:18px;border:1px solid #e6d8ed;background:#fbf7fd;border-radius:10px}.bbr-map-summary strong{display:block;color:#6c3486}.bbr-map-summary p{margin:7px 0;font-size:13px;color:#625869}.bbr-map-summary a{color:#753995;font-size:12px}.bbr-details{padding:12px;border:1px solid #e8e2eb;border-radius:8px;margin-bottom:16px}.bbr-details summary{cursor:pointer;font-size:13px;font-weight:700;color:#66566c}.bbr-details[open]>summary{margin-bottom:14px}.bbr-details .report-form-row:last-child{margin-bottom:0}.bbr-coordinate-details input[readonly]{background:#f5f5f5;color:#666}.bbr-coordinate-details .report-coord-row{grid-template-columns:1fr 1fr}.bingo-routing-active .bbr-control{display:none}
@media(max-width:600px){.bbr-coordinate-details .report-coord-row{grid-template-columns:1fr}}
`;
        document.head.append(css);
    }

    function attach(map) {
        if (instances.has(map)) return instances.get(map);
        if (!map || !global.L) throw new Error('Leaflet 지도 생성 후 BinGoBinReport.attach(map)을 호출해주세요.');
        const recycleButton = document.querySelector('.sidebar .filters [data-category="recycle"]');
        const filterRow = recycleButton?.closest('.filters') || document.querySelector('.sidebar .filters');
        if (!filterRow) {
            console.warn('쓰레기통 제보 버튼을 넣을 .sidebar .filters 영역을 찾지 못했습니다.');
            return null;
        }
        style();
        let picking = false, selected = null, marker = null, popup = null, deferred;
        const toolbar = node('div', 'bbr-control');
        const button = node('button', 'bbr-button', '＋ 쓰레기통 제보'); button.type = 'button';
        button.title = '버튼을 누른 뒤 지도에서 위치를 선택하세요. 마우스 오른쪽 클릭도 가능합니다.';
        button.setAttribute('aria-pressed', 'false');
        const hint = node('p', 'bbr-hint', '제보할 위치를 지도에서 클릭해주세요. Esc를 누르면 취소됩니다.');
        hint.hidden = true; hint.setAttribute('role', 'status');
        // .filter 클래스와 data-category는 기존 종류 필터 전용이므로 제보 버튼에는 붙이지 않습니다.
        toolbar.append(button);
        filterRow.classList.add('bbr-filter-row');
        if (recycleButton?.parentElement === filterRow) recycleButton.after(toolbar);
        else filterRow.append(toolbar);
        filterRow.after(hint);

        function setPicking(value) {
            picking = value; hint.hidden = !value;
            button.textContent = value ? '위치 선택 취소' : '＋ 쓰레기통 제보';
            button.setAttribute('aria-pressed', String(value));
            map.getContainer().classList.toggle('bbr-picking', value);
        }
        function clearDraft() {
            const oldPopup = popup; popup = null;
            if (marker) { map.removeLayer(marker); marker = null; }
            selected = null;
            if (oldPopup) map.closePopup(oldPopup);
        }
        function cancel() { setPicking(false); clearDraft(); }
        function isRouting() { return document.body.classList.contains('bingo-routing-active'); }
        function showPoint(p) {
            if (!p || isRouting()) return;
            clearDraft(); selected = p; setPicking(false);
            const box = node('div');
            box.append(node('h3', '', '이 위치에 쓰레기통 제보'));
            box.append(node('p', '', '핀을 움직여 위치를 맞춘 뒤, 아래 버튼을 눌러주세요.'));
            const coordinates = node('p', 'bbr-coordinates');
            const link = node('a', 'bbr-submit', '이 위치로 제보하기');
            const cancelButton = node('button', 'bbr-cancel', '취소'); cancelButton.type = 'button';
            cancelButton.addEventListener('click', cancel);
            function updateLink() {
                coordinates.textContent = '선택한 좌표: ' + selected.lat.toFixed(7) + ', ' + selected.lon.toFixed(7);
                link.href = reportUrl(selected);
            }
            link.addEventListener('click', function () { if (selected) remember(selected); });
            updateLink(); box.append(coordinates, link, cancelButton);
            const icon = L.divIcon({className: 'bbr-draft-icon', html: '<span class="bbr-draft-dot"></span>', iconSize: [24, 24], iconAnchor: [12, 12]});
            marker = L.marker([p.lat, p.lon], {icon, draggable: true, autoPan: true,
                title: '제보할 위치 — 아직 접수되지 않음', alt: '제보할 위치', bubblingMouseEvents: false}).addTo(map);
            popup = L.popup({className: 'bbr-popup', maxWidth: 310, minWidth: 280, offset: [0, -10], autoPanPadding: [20, 20]})
                .setLatLng([p.lat, p.lon]).setContent(box).openOn(map);
            marker.on('dragend', function () {
                if (!marker) return;
                const position = marker.getLatLng();
                const next = point(position.lat, position.lng);
                if (!next) { marker.setLatLng([selected.lat, selected.lon]); return; }
                selected = next; updateLink(); popup.setLatLng([next.lat, next.lon]);
            });
        }
        function backgroundEvent(event) {
            return !event.originalEvent?.target?.closest?.('.leaflet-control, .leaflet-popup, .leaflet-marker-icon, .leaflet-interactive');
        }
        function click(event) {
            if (isRouting()) { cancel(); return; }
            if (picking && backgroundEvent(event)) showPoint(point(event.latlng.lat, event.latlng.lng));
        }
        function rightClick(event) {
            if (isRouting() || !backgroundEvent(event)) return;
            event.originalEvent?.preventDefault?.();
            showPoint(point(event.latlng.lat, event.latlng.lng));
        }
        function popupClosed(event) { if (event.popup === popup) clearDraft(); }
        function key(event) { if (event.key === 'Escape' && (picking || marker)) cancel(); }
        button.addEventListener('click', function () {
            if (picking) cancel(); else { clearDraft(); setPicking(true); }
        });
        map.on('click', click); map.on('contextmenu', rightClick); map.on('popupclose', popupClosed);
        document.addEventListener('keydown', key);
        const routeObserver = global.MutationObserver ? new MutationObserver(function () {
            if (isRouting()) cancel();
        }) : null;
        routeObserver?.observe(document.body, {attributes: true, attributeFilter: ['class']});
        const query = new URLSearchParams(global.location.search);
        if (query.get('report') === 'pick') {
            deferred = setTimeout(function () {
                const initial = point(query.get('reportLat'), query.get('reportLon'));
                if (initial) map.setView([initial.lat, initial.lon], Math.max(map.getZoom(), 17), {animate: false});
                setPicking(true);
            }, 0);
        }
        const api = {destroy: function () {
            clearTimeout(deferred); cancel(); toolbar.remove(); hint.remove();
            filterRow.classList.remove('bbr-filter-row');
            routeObserver?.disconnect();
            map.off('click', click); map.off('contextmenu', rightClick); map.off('popupclose', popupClosed);
            document.removeEventListener('keydown', key); instances.delete(map);
        }};
        instances.set(map, api); return api;
    }

    function initReportPage() {
        const lat = document.getElementById('report-lat');
        const lon = document.getElementById('report-lon');
        if (!lat || !lon || lat.dataset.bbrInitialized) return;
        lat.dataset.bbrInitialized = 'true'; style();
        const row = lat.closest('.report-form-row');
        if (!row) return;
        const query = new URLSearchParams(global.location.search);
        const explicitlySelected = query.get('from') === 'map';
        const selected = explicitlySelected ? point(query.get('lat'), query.get('lon')) : remembered();
        const entry = node('a', 'bbr-map-entry', '지도에서 위치 선택'); entry.href = mapUrl(selected);
        row.before(entry);
        if (!selected) {
            if (explicitlySelected) {
                const hint = document.getElementById('report-location-hint');
                if (hint) hint.textContent = '좌표를 확인할 수 없습니다. 지도에서 위치를 다시 선택해주세요.';
            }
            return;
        }
        // 기존 report.js가 읽는 입력 항목/ID를 그대로 사용합니다.
        lat.value = selected.lat.toFixed(7); lon.value = selected.lon.toFixed(7);
        lat.readOnly = true; lon.readOnly = true;
        const current = document.getElementById('report-use-location'); if (current) current.hidden = true;
        const locationHint = document.getElementById('report-location-hint');
        if (locationHint) locationHint.textContent = '지도에서 선택한 위치입니다. 위치를 바꾸려면 다시 선택해주세요.';
        const summary = node('section', 'bbr-map-summary');
        summary.append(node('strong', '', '지도에서 위치를 선택했어요'));
        summary.append(node('p', '', '쓰레기통 종류를 선택하고 제보해주세요. 위치 설명은 선택 사항이에요.'));
        const change = node('a', '', '지도에서 위치 다시 선택'); change.href = mapUrl(selected); summary.append(change);
        entry.replaceWith(summary);
        const coordinateDetails = node('details', 'bbr-details bbr-coordinate-details');
        coordinateDetails.append(node('summary', '', '선택한 좌표 확인'));
        row.before(coordinateDetails); coordinateDetails.append(row);
        const optional = node('details', 'bbr-details');
        optional.append(node('summary', '', '장소명·상세 주소 추가 (선택)'));
        const nameRow = document.getElementById('report-name')?.closest('.report-form-row');
        const addressRow = document.getElementById('report-address')?.closest('.report-form-row');
        if (nameRow || addressRow) {
            (nameRow || addressRow).before(optional);
            if (nameRow) optional.append(nameRow); if (addressRow) optional.append(addressRow);
        }
        const description = document.getElementById('report-description');
        if (description) description.placeholder = '예: 편의점 입구 오른쪽, 건물 1층 바깥쪽 (선택)';
        const submit = document.getElementById('report-submit-btn');
        if (submit) {
            const back = node('a', 'bbr-map-return', '지도로 돌아가기');
            back.href = '/map/map.html'; back.style.marginLeft = '10px'; submit.after(back);
        }
        const success = document.getElementById('report-form-success');
        if (success && global.MutationObserver) {
            const observer = new MutationObserver(function () {
                if (!success.textContent.trim()) return;
                forget();
                const url = new URL(global.location.href);
                ['from', 'lat', 'lon'].forEach(key => url.searchParams.delete(key));
                global.history.replaceState(global.history.state, '', url.pathname + url.search + url.hash);
                observer.disconnect();
            });
            observer.observe(success, {childList: true, subtree: true, characterData: true});
        }
    }
    global.BinGoBinReport = Object.freeze({attach, initReportPage});
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', initReportPage, {once: true});
    else initReportPage();
})(window);
