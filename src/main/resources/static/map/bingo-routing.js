/* BinGo 지도 안 길찾기. Leaflet 로드 후, map.html의 기존 <script> 전에 연결하세요. */
(function (global) {
    'use strict';
    const MODES = {walk: '도보', bike: '자전거', car: '자동차'};
    const TEST_START = {lat: 34.6687, lon: 135.5031};
    const MAX_DISTANCE = 50000;
    const distanceText = m => m < 1000 ? `${Math.round(m)}m` : `${(m / 1000).toFixed(1)}km`;
    const timeText = s => {
        const min = Math.max(1, Math.ceil(s / 60));
        return min < 60 ? `${min}분` : `${Math.floor(min / 60)}시간 ${min % 60}분`;
    };
    const meters = (a, b) => {
        const rad = Math.PI / 180;
        const h = Math.sin((b.lat - a.lat) * rad / 2) ** 2
            + Math.cos(a.lat * rad) * Math.cos(b.lat * rad) * Math.sin((b.lon - a.lon) * rad / 2) ** 2;
        return 12742000 * Math.asin(Math.sqrt(Math.min(1, Math.max(0, h))));
    };
    const turnIcon = type => ({0:'↰', 1:'↱', 2:'↰', 3:'↱', 4:'↖', 5:'↗', 6:'↑',
        7:'↻', 8:'↗', 9:'↶', 10:'●', 11:'●', 12:'↖', 13:'↗'}[type] || '↑');

    // 좌표를 가장 가까운 경로 선분에 투영합니다. 도로로 위치를 강제 보정하지 않습니다.
    function progressOnRoute(position, coordinates) {
        const sx = 111320 * Math.cos(position.lat * Math.PI / 180), sy = 111320;
        let best = {distance: Infinity, index: 0, along: 0}, total = 0;
        for (let i = 0; i < coordinates.length - 1; i++) {
            const a = coordinates[i], b = coordinates[i + 1];
            const ax = (a[0] - position.lon) * sx, ay = (a[1] - position.lat) * sy;
            const dx = (b[0] - a[0]) * sx, dy = (b[1] - a[1]) * sy;
            const length = Math.hypot(dx, dy);
            const t = length ? Math.max(0, Math.min(1, -(ax * dx + ay * dy) / (length * length))) : 0;
            const d = Math.hypot(ax + t * dx, ay + t * dy);
            if (d < best.distance) best = {distance: d, index: i, along: total + t * length};
            total += length;
        }
        return {...best, remaining: Math.max(0, total - best.along)};
    }

    function create(map, options = {}) {
        if (!global.L || !map) throw new Error('Leaflet 지도 생성 후 길찾기를 연결해주세요.');
        const container = map.getContainer().parentElement;
        const host = document.createElement('section');
        host.className = 'bingo-route-ui';
        host.setAttribute('aria-label', '길찾기');
        host.hidden = true;
        host.innerHTML = `
            <div class="br-top">
                <div class="br-heading"><strong>길찾기</strong><button type="button" data-action="close" aria-label="길찾기 닫기">✕</button></div>
                <label class="br-place"><span class="br-dot br-blue"></span><span class="br-sr">출발지</span>
                    <select data-el="origin"><option value="current">내 현재 위치</option></select></label>
                <div class="br-place"><span class="br-dot br-red"></span><span data-el="destination"></span></div>
                <div class="br-modes" role="group" aria-label="이동수단">
                    <button type="button" data-mode="walk"><span>🚶 도보</span><b data-summary="walk">—</b></button>
                    <button type="button" data-mode="bike"><span>🚲 자전거</span><b data-summary="bike">—</b></button>
                    <button type="button" data-mode="car"><span>🚗 자동차</span><b data-summary="car">—</b></button>
                </div>
                <p class="br-status" data-el="status" role="status" aria-live="polite"></p>
            </div>
            <div class="br-bottom">
                <div class="br-summary"><strong data-el="summary">경로 준비 중</strong><span data-el="eta"></span></div>
                <p class="br-note" data-el="note"></p>
                <p class="br-navigation" data-el="navigation" role="status" hidden></p>
                <ol class="br-steps" data-el="steps" aria-label="이동 순서"></ol>
                <div class="br-actions"><button type="button" class="br-secondary" data-action="reload">다시 조회</button>
                    <button type="button" class="br-primary" data-action="start" disabled>안내 시작</button></div>
                <small class="br-credit">테스트용 공개 경로: <a href="https://routing.openstreetmap.de/about.html" target="_blank" rel="noopener">OSRM / FOSSGIS</a> · © <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noopener">OpenStreetMap contributors</a> · <a href="https://www.openstreetmap.org/fixthemap" target="_blank" rel="noopener">지도 오류 제보</a></small>
            </div>`;
        container.appendChild(host);
        global.L.DomEvent.disableClickPropagation(host);
        global.L.DomEvent.disableScrollPropagation(host);
        const el = name => host.querySelector(`[data-el="${name}"]`);
        const startButton = host.querySelector('[data-action="start"]');
        if (options.allowTestOrigin === true) {
            const option = document.createElement('option');
            option.value = 'test';
            option.textContent = '도톤보리 테스트 출발점 (가상 위치)';
            el('origin').appendChild(option);
        }

        let destination = null, origin = null, active = false, mode = 'walk';
        let version = 0, controller = null, watchId = null, followVersion = 0;
        let results = {}, saved = null, previousFocus = null, userMarker = null;
        const routeLayers = global.L.layerGroup().addTo(map);
        const userLayers = global.L.layerGroup().addTo(map);
        const cache = new Map(); // 현재 탭에서만 5분 재사용. 위치를 localStorage나 DB에 저장하지 않음.

        function open(target) {
            if (!Number.isFinite(target.lat) || !Number.isFinite(target.lon)) return;
            if (!active) {
                saved = {center: map.getCenter(), zoom: map.getZoom(), bounds: map.options.maxBounds};
                previousFocus = document.activeElement;
                document.body.classList.add('bingo-routing-active');
                host.hidden = false;
                active = true;
                map.setMaxBounds(null);
                map.invalidateSize({pan: false});
            }
            destination = {lat: target.lat, lon: target.lon, name: target.name || '선택한 쓰레기통'};
            el('destination').textContent = destination.name;
            map.closePopup();
            host.querySelector('[data-action="close"]').focus();
            load();
        }

        function stopFollowing() {
            followVersion++;
            if (watchId !== null) navigator.geolocation.clearWatch(watchId);
            watchId = null;
            startButton.textContent = '안내 시작';
            el('navigation').hidden = true;
            host.querySelectorAll('.br-current').forEach(item => item.classList.remove('br-current'));
        }

        function close() {
            if (!active) return;
            version++;
            controller?.abort();
            stopFollowing();
            routeLayers.clearLayers();
            userLayers.clearLayers();
            userMarker = null;
            host.hidden = true;
            active = false;
            document.body.classList.remove('bingo-routing-active');
            map.setMaxBounds(saved.bounds || null);
            map.invalidateSize({pan: false});
            map.setView(saved.center, saved.zoom, {animate: false});
            previousFocus?.focus?.();
        }

        function locationError(error) {
            if (error.code === 1) return '현재 위치 권한이 꺼져 있습니다. 주소창의 사이트 권한에서 위치를 허용해주세요.';
            if (error.code === 3) return '현재 위치 확인 시간이 초과됐습니다. 다시 조회하거나 테스트 출발점을 선택해주세요.';
            return '현재 위치를 확인할 수 없습니다. 위치 설정을 확인하거나 테스트 출발점을 선택해주세요.';
        }

        function getPosition() {
            return new Promise((resolve, reject) => {
                if (!navigator.geolocation || !global.isSecureContext) {
                    reject(new Error('현재 위치는 localhost 또는 HTTPS 주소에서 사용할 수 있습니다.'));
                    return;
                }
                navigator.geolocation.getCurrentPosition(position => resolve({
                        lat: position.coords.latitude, lon: position.coords.longitude,
                        accuracy: position.coords.accuracy
                    }), error => reject(new Error(locationError(error))),
                    {enableHighAccuracy: true, timeout: 12000, maximumAge: 10000});
            });
        }

        // 위치 조회/경로 요청 중 출발지 또는 목적지를 바꾸면 이전 응답은 화면에 반영하지 않습니다.
        async function load() {
            const mine = ++version;
            controller?.abort();
            const abort = controller = new AbortController();
            stopFollowing();
            routeLayers.clearLayers();
            userLayers.clearLayers();
            userMarker = null;
            origin = null;
            results = {};
            paintTabs();
            el('summary').textContent = '출발지 확인 중';
            el('eta').textContent = '';
            el('steps').replaceChildren();
            el('note').textContent = '';
            startButton.disabled = true;
            el('status').textContent = '현재 위치를 확인하고 있습니다.';
            try {
                const isTest = el('origin').value === 'test';
                const position = isTest ? {...TEST_START} : await getPosition();
                if (!active || mine !== version) return;
                origin = {...position, isTest};
                if (meters(origin, destination) > MAX_DISTANCE) {
                    throw new Error('목적지와 50km 이상 떨어져 있습니다. 한국에서 테스트한다면 출발지를 ‘도톤보리 테스트 출발점’으로 바꿔주세요.');
                }
                if (meters(origin, destination) < 5) {
                    throw new Error('출발지와 목적지가 거의 같습니다. 다른 목적지를 선택해주세요.');
                }
                el('status').textContent = isTest
                    ? '가상 출발점으로 테스트 중입니다. 실제 내 위치가 아닙니다.'
                    : `현재 위치 기준 · 위치 오차 약 ${distanceText(origin.accuracy || 0)}`;
                for (const key of Object.keys(MODES)) results[key] = {state: 'loading'};
                paintTabs();
                paintRoute();
                await Promise.allSettled(Object.keys(MODES).map(async key => {
                    try {
                        const route = await fetchRoute(key, origin, destination, abort.signal);
                        if (!active || mine !== version) return;
                        results[key] = {state: 'ready', route};
                    } catch (error) {
                        if (!active || mine !== version) return;
                        results[key] = {state: 'error', message: error.message};
                    }
                    paintTabs();
                    if (mode === key) paintRoute();
                }));
            } catch (error) {
                if (!active || mine !== version) return;
                el('status').textContent = error.message;
                el('summary').textContent = '출발지를 확인해주세요';
            }
        }

        async function fetchRoute(key, start, end, parentSignal) {
            const body = {startLat: start.lat, startLon: start.lon, endLat: end.lat, endLon: end.lon, mode: key};
            const cacheKey = JSON.stringify(body);
            const hit = cache.get(cacheKey);
            if (hit && Date.now() - hit.time < 300000) return hit.route;
            const abort = new AbortController();
            const cancel = () => abort.abort();
            parentSignal.addEventListener('abort', cancel, {once: true});
            if (parentSignal.aborted) abort.abort();
            const timer = setTimeout(cancel, 30000);
            try {
                const response = await fetch('/api/routes', {
                    method: 'POST', headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(body), signal: abort.signal
                });
                const data = await response.json().catch(() => null);
                if (!response.ok) throw new Error(data?.message || `경로를 불러오지 못했습니다. (HTTP ${response.status})`);
                if (!data || data.mode !== key || !Array.isArray(data.coordinates) || data.coordinates.length < 2
                    || !Array.isArray(data.steps) || !Number.isFinite(data.distanceMeters)
                    || !Number.isFinite(data.durationSeconds)) throw new Error('경로 응답 형식을 확인해주세요.');
                if (cache.size >= 20) cache.delete(cache.keys().next().value);
                cache.set(cacheKey, {time: Date.now(), route: data});
                return data;
            } catch (error) {
                if (error.name === 'AbortError') throw new Error('경로 요청 시간이 초과되거나 취소됐습니다. 다시 조회해주세요.');
                throw error;
            } finally {
                clearTimeout(timer);
                parentSignal.removeEventListener('abort', cancel);
            }
        }

        function paintTabs() {
            host.querySelectorAll('[data-mode]').forEach(button => {
                const key = button.dataset.mode, result = results[key];
                button.setAttribute('aria-pressed', String(key === mode));
                button.classList.toggle('br-selected', key === mode);
                host.querySelector(`[data-summary="${key}"]`).textContent = !result ? '—'
                    : result.state === 'loading' ? '조회 중…'
                        : result.state === 'error' ? '조회 불가'
                            : `${timeText(result.route.durationSeconds)} · ${distanceText(result.route.distanceMeters)}`;
            });
        }

        function addPoint(position, className, label) {
            const icon = global.L.divIcon({className: 'br-point-wrap',
                html: `<span class="br-point ${className}"></span>`, iconSize: [24, 24], iconAnchor: [12, 12]});
            const marker = global.L.marker([position.lat, position.lon], {icon, zIndexOffset: 1000}).addTo(routeLayers);
            // 이름은 HTML로 해석하지 않고 텍스트로 넣습니다.
            const text = document.createElement('span'); text.textContent = label;
            marker.bindTooltip(text, {permanent: true, direction: 'top', offset: [0, -12], className: 'br-point-label'});
        }

        function paintRoute() {
            routeLayers.clearLayers();
            userLayers.clearLayers(); userMarker = null;
            startButton.disabled = true;
            el('steps').replaceChildren();
            el('eta').textContent = '';
            el('note').textContent = '';
            const result = results[mode];
            if (!result || result.state === 'loading') {
                el('summary').textContent = `${MODES[mode]} 경로 계산 중…`; return;
            }
            if (result.state === 'error') {
                el('summary').textContent = `${MODES[mode]} 경로를 표시할 수 없습니다`;
                el('note').textContent = result.message; return;
            }
            const route = result.route;
            // GeoJSON [경도, 위도] → Leaflet [위도, 경도].
            const latLngs = route.coordinates.map(point => [point[1], point[0]]);
            global.L.polyline(latLngs, {color: '#fff', weight: 9, opacity: .95, interactive: false}).addTo(routeLayers);
            global.L.polyline(latLngs, {color: '#1677ff', weight: 5,
                dashArray: mode === 'walk' ? '1 10' : null, lineCap: 'round', interactive: false}).addTo(routeLayers);
            addPoint(origin, 'br-point-start', origin.isTest ? '테스트 출발점' : '출발 위치');
            addPoint(destination, 'br-point-end', destination.name);
            el('summary').textContent = `${MODES[mode]} ${timeText(route.durationSeconds)} · ${distanceText(route.distanceMeters)}`;
            const arrival = new Date(Date.now() + route.durationSeconds * 1000);
            el('eta').textContent = `지금 출발 시 ${arrival.toLocaleTimeString('ko-KR', {hour: '2-digit', minute: '2-digit', timeZone: 'Asia/Tokyo'})} 도착 예상 (일본 시간)`;
            let note = '예상 시간은 실시간 교통·신호 대기를 반영하지 않습니다.';
            if (route.startGapMeters > 15) note += ` 출발 위치와 경로 시작점 간 직선거리 ${distanceText(route.startGapMeters)}.`;
            if (route.endGapMeters > 15) note += ` 경로 끝과 목적지 간 직선거리 ${distanceText(route.endGapMeters)}. 마지막 구간의 통행 가능 여부를 확인해주세요.`;
            el('note').textContent = note;
            route.steps.forEach((step, index) => {
                const row = document.createElement('li');
                row.dataset.index = String(index);
                const icon = document.createElement('span'); icon.className = 'br-turn'; icon.textContent = turnIcon(step.type);
                icon.setAttribute('aria-hidden', 'true');
                const desc = document.createElement('div');
                const title = document.createElement('strong'); title.textContent = step.instruction;
                const road = document.createElement('small');
                road.textContent = step.type === 10
                    ? (route.endGapMeters > 15 ? `목적지까지 직선 약 ${distanceText(route.endGapMeters)} 남음` : destination.name)
                    : (step.roadName || '이름 없는 길');
                const length = document.createElement('span'); length.className = 'br-step-distance';
                length.textContent = distanceText(step.distanceMeters);
                desc.append(title, road); row.append(icon, desc, length); el('steps').appendChild(row);
            });
            startButton.disabled = origin.isTest;
            startButton.textContent = origin.isTest ? '테스트 경로 미리보기 중' : '안내 시작';
            const size = map.getSize();
            const large = size.x >= 1000;
            const bounds = global.L.latLngBounds([...latLngs, [origin.lat, origin.lon], [destination.lat, destination.lon]]);
            map.fitBounds(bounds, {maxZoom: 18, animate: false,
                paddingTopLeft: large ? [460, 50] : [25, host.querySelector('.br-top').offsetHeight + 35],
                paddingBottomRight: large ? [50, 50] : [25, host.querySelector('.br-bottom').offsetHeight + 35]});
        }

        function followPosition() {
            if (watchId !== null) { stopFollowing(); return; }
            if (origin?.isTest || results[mode]?.state !== 'ready') return;
            if (!navigator.geolocation || !global.isSecureContext) {
                el('status').textContent = '현재 위치를 사용할 수 없습니다. 위치 권한과 HTTPS 연결을 확인해주세요.'; return;
            }
            const mine = ++followVersion;
            const route = results[mode].route;
            el('navigation').hidden = false;
            el('navigation').textContent = '현재 위치를 확인하고 있습니다…';
            startButton.textContent = '안내 중지';
            watchId = navigator.geolocation.watchPosition(position => {
                if (!active || mine !== followVersion) return;
                const current = {lat: position.coords.latitude, lon: position.coords.longitude};
                const accuracy = position.coords.accuracy;
                if (!userMarker) userMarker = global.L.circleMarker([current.lat, current.lon],
                    {radius: 8, color: '#fff', weight: 3, fillColor: '#1677ff', fillOpacity: 1}).addTo(userLayers);
                else userMarker.setLatLng([current.lat, current.lon]);
                if (accuracy > 50) {
                    el('navigation').textContent = `위치 오차가 약 ${distanceText(accuracy)}입니다. 더 정확한 위치를 기다리는 중입니다.`; return;
                }
                const progress = progressOnRoute(current, route.coordinates);
                if (progress.distance > 60) {
                    el('navigation').textContent = '현재 위치가 경로에서 벗어났습니다. ‘다시 조회’를 눌러 현재 위치에서 경로를 계산해주세요.'; return;
                }
                if (meters(current, destination) < 20 && accuracy <= 20) {
                    stopFollowing(); el('navigation').hidden = false;
                    el('navigation').textContent = '목적지 근처입니다. 주변에서 쓰레기통 위치를 확인해주세요.'; return;
                }
                let index = route.steps.findIndex(step => step.endIndex > progress.index);
                if (index < 0) index = route.steps.length - 1;
                const step = route.steps[index];
                host.querySelectorAll('.br-steps li').forEach((row, i) => row.classList.toggle('br-current', i === index));
                el('navigation').textContent = `현재 구간: ${step.instruction} · 경로 끝까지 약 ${distanceText(progress.remaining)}`;
                map.panTo([current.lat, current.lon], {animate: false});
            }, error => {
                if (!active || mine !== followVersion) return;
                stopFollowing(); el('navigation').hidden = false;
                el('navigation').textContent = locationError(error);
            }, {enableHighAccuracy: true, timeout: 12000, maximumAge: 3000});
        }

        host.addEventListener('click', event => {
            const tab = event.target.closest('[data-mode]');
            if (tab) { stopFollowing(); mode = tab.dataset.mode; paintTabs(); if (origin && results[mode]) paintRoute(); return; }
            const action = event.target.closest('[data-action]')?.dataset.action;
            if (action === 'close') close();
            if (action === 'reload') { cache.clear(); load(); }
            if (action === 'start') followPosition();
        });
        el('origin').addEventListener('change', load);
        const onKey = event => { if (event.key === 'Escape' && active) close(); };
        document.addEventListener('keydown', onKey);
        return Object.freeze({open, close, destroy() {
                close(); host.remove(); routeLayers.remove(); userLayers.remove();
                document.removeEventListener('keydown', onKey); cache.clear();
            }});
    }

    global.BinGoRouting = Object.freeze({create});
})(window);
