/* 목록 거리와 길찾기가 공유하는 출발지. 지도 중심/드래그 이벤트로 바꾸지 않습니다. */
(function (global) {
    'use strict';
    // 시설 전체가 아닌 지정 기준점입니다. 좌표 출처/선정 범위는 적용안내.md 참고.
    const SPOTS = Object.freeze([
        Object.freeze({id: 'usj', label: '유니버셜 스튜디오', short: '유니버셜',
            detail: 'USJ · 관광 안내 지도 기준점', lat: 34.6672, lon: 135.43583,
            aliases: ['유니버셜 스튜디오 재팬', '유니버설 스튜디오', '유니버설', 'USJ', 'Universal Studios Japan', 'ユニバーサル・スタジオ・ジャパン']}),
        Object.freeze({id: 'castle', label: '오사카성', short: '오사카성',
            detail: '오사카성 · 관광 안내 지도 기준점', lat: 34.68625, lon: 135.52579,
            aliases: ['오사카 성', '大阪城', 'Osaka Castle']}),
        Object.freeze({id: 'dotonbori', label: '도톤보리 · 에비스바시', short: '도톤보리',
            detail: '에비스 다리 · 글리코상 주변', lat: 34.6690561, lon: 135.5013611,
            aliases: ['도톤보리', '에비스바시', '에비스 다리', '에비스교', '글리코상', '글리코', 'Dotonbori', 'Dōtonbori', 'Ebisubashi', 'Ebisu Bridge', '道頓堀', '戎橋']})
    ]);
    const STORAGE_KEY = 'bingo.origin.spot.v1';
    const valid = p => p && Number.isFinite(p.lat) && Number.isFinite(p.lon)
        && Math.abs(p.lat) <= 90 && Math.abs(p.lon) <= 180;
    const normalize = s => String(s || '').normalize('NFKD').replace(/\p{M}/gu, '')
        .toLowerCase().replace(/[\s·・()_-]/g, '');
    const find = id => SPOTS.find(p => p.id === id);
    const search = text => {
        const term = normalize(text);
        return term ? SPOTS.filter(p => [p.label, ...p.aliases].some(s => normalize(s).includes(term))) : [];
    };
    function distance(a, b) {
        if (!valid(a) || !valid(b)) return NaN;
        const rad = Math.PI / 180;
        const h = Math.sin((b.lat - a.lat) * rad / 2) ** 2
            + Math.cos(a.lat * rad) * Math.cos(b.lat * rad) * Math.sin((b.lon - a.lon) * rad / 2) ** 2;
        return 12742000 * Math.asin(Math.sqrt(Math.max(0, Math.min(1, h))));
    }
    const formatDistance = m => !Number.isFinite(m) ? '거리 정보 없음'
        : m < 1000 ? Math.round(m) + 'm' : (m / 1000).toFixed(1) + 'km';
    function element(tag, cls, text) {
        const el = document.createElement(tag); el.className = cls;
        if (text != null) el.textContent = text;
        return el;
    }
    function create(map, options = {}) {
        let initial = find('dotonbori');
        try { initial = find(global.sessionStorage.getItem(STORAGE_KEY)) || initial; } catch (_) { /* 저장 차단 시 기본 스팟 */ }
        let reference = {...initial, kind: 'spot'}, revision = 0, gpsRequest = 0;
        const marker = global.L.marker([reference.lat, reference.lon], {
            icon: global.L.divIcon({className: 'bsp-marker-wrap', html: '<span class="bsp-marker"></span>',
                iconSize: [22, 22], iconAnchor: [11, 11]}), zIndexOffset: 600
        }).addTo(map);
        const tooltip = element('span', '', '');
        marker.bindTooltip(tooltip, {direction: 'top', offset: [0, -12], className: 'bsp-tooltip'});
        const bar = element('section', 'bsp-bar'); bar.setAttribute('aria-label', '거리 기준과 출발지 선택');
        const heading = element('div', 'bsp-heading');
        const caption = element('strong', '', '거리 기준 · 출발지');
        const current = element('button', 'bsp-current', '내 위치'); current.type = 'button';
        current.addEventListener('click', requestCurrent);
        heading.append(caption, current);
        const choices = element('div', 'bsp-choices');
        for (const spot of SPOTS) {
            const button = element('button', 'bsp-choice', spot.short); button.type = 'button';
            button.dataset.spot = spot.id; button.title = spot.label;
            button.addEventListener('click', () => selectSpot(spot.id)); choices.append(button);
        }
        const name = element('p', 'bsp-reference'); name.setAttribute('aria-live', 'polite');
        const hint = element('p', 'bsp-hint', '이 지점에서 직선 거리순 · 지도를 옮겨도 기준 유지');
        const status = element('p', 'bsp-status'); status.setAttribute('role', 'status'); status.hidden = true;
        bar.append(heading, choices, name, hint, status);
        document.querySelector('.sidebar .search-area').before(bar);
        function paint() {
            name.textContent = reference.label;
            choices.querySelectorAll('button').forEach(b => b.setAttribute('aria-pressed', String(reference.kind === 'spot' && reference.id === b.dataset.spot)));
            current.setAttribute('aria-pressed', String(reference.kind === 'current'));
            marker.setLatLng([reference.lat, reference.lon]);
            tooltip.textContent = '거리 기준 · ' + reference.label;
        }
        function setReference(point, settings = {}) {
            if (!valid(point)) throw new Error('기준 위치의 좌표를 확인해주세요.');
            const spot = point.kind === 'spot' ? find(point.id) : null;
            if (point.kind === 'spot' && !spot) throw new Error('등록되지 않은 스팟입니다.');
            reference = spot ? {...spot, kind: 'spot'}
                : {id: 'current', kind: 'current', label: '내 현재 위치', lat: point.lat, lon: point.lon, accuracy: point.accuracy};
            revision++; gpsRequest++; current.disabled = false;
            // 새로고침 시 스팟만 복원합니다. 실제 GPS 좌표는 저장하지 않습니다.
            try { if (spot) global.sessionStorage.setItem(STORAGE_KEY, spot.id);
                else global.sessionStorage.removeItem(STORAGE_KEY); } catch (_) { /* 저장 권한 없어도 선택 가능 */ }
            status.hidden = true; map.closePopup(); paint();
            options.onChange?.({source: settings.source || 'map'});
            if (settings.pan !== false) map.setView([reference.lat, reference.lon], 16);
        }
        function selectSpot(id, settings) {
            const spot = find(id); if (spot) setReference({...spot, kind: 'spot'}, settings);
        }
        function requestCurrent() {
            const mine = ++gpsRequest, before = revision;
            const failed = error => {
                if (mine !== gpsRequest || before !== revision) return;
                current.disabled = false; status.hidden = false;
                status.textContent = error.code === 1
                    ? '위치 권한이 허용되지 않았어요. 선택한 스팟을 계속 사용할 수 있어요.'
                    : '현재 위치를 확인하지 못했어요. 다시 누르거나 스팟을 선택해주세요.';
            };
            if (!navigator.geolocation || !global.isSecureContext) { failed({}); return; }
            current.disabled = true; status.hidden = false; status.textContent = '현재 위치 확인 중…';
            navigator.geolocation.getCurrentPosition(position => {
                if (mine !== gpsRequest || before !== revision) return;
                const p = {lat: position.coords.latitude, lon: position.coords.longitude,
                    accuracy: position.coords.accuracy, kind: 'current'};
                if (!valid(p)) { failed({}); return; }
                setReference(p);
            }, failed, {enableHighAccuracy: true, timeout: 12000, maximumAge: 10000});
        }
        function bindSearch(input) {
            if (!input) return;
            const results = element('div', 'bsp-results'); results.hidden = true;
            results.setAttribute('aria-label', '출발 스팟 검색 결과');
            const anchor = input.closest('.search') || input; anchor.after(results);
            function choose(spot) {
                selectSpot(spot.id);
                input.value = ''; input.dispatchEvent(new Event('input', {bubbles: true}));
                input.focus();
            }
            function draw() {
                const matches = search(input.value); results.replaceChildren();
                results.hidden = matches.length === 0;
                if (!matches.length) return;
                results.append(element('small', 'bsp-results-caption', '출발 스팟 · 선택하면 거리 기준도 바뀝니다'));
                matches.forEach(spot => {
                    const row = element('button', 'bsp-result'); row.type = 'button'; row.dataset.spot = spot.id;
                    row.append(element('strong', '', spot.label), element('span', '', spot.detail));
                    row.addEventListener('click', () => choose(spot)); results.append(row);
                });
            }
            input.addEventListener('input', draw);
            input.addEventListener('focus', draw);
            input.addEventListener('keydown', event => {
                if (event.isComposing) return;
                if (event.key === 'Escape') results.hidden = true;
                const first = results.querySelector('button');
                if (!results.hidden && first && event.key === 'ArrowDown') { event.preventDefault(); first.focus(); }
                if (!results.hidden && first && event.key === 'Enter') { event.preventDefault(); first.click(); }
            });
            results.addEventListener('keydown', event => {
                if (event.key === 'Escape') { input.focus(); results.hidden = true; }
            });
        }
        paint(); map.setView([reference.lat, reference.lon], 16);
        return Object.freeze({getReference: () => ({...reference}), getRevision: () => revision,
            selectSpot, setReference, requestCurrent, bindSearch});
    }
    global.BinGoSpots = Object.freeze({SPOTS, find, search, distance, formatDistance, create});
})(window);
