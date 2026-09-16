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

    const validPoint = p => p && typeof p.lat === 'number' && Number.isFinite(p.lat) && Math.abs(p.lat) <= 90
        && typeof p.lon === 'number' && Number.isFinite(p.lon) && Math.abs(p.lon) <= 180;
    const BIN_SVG = '<svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 6h18M9 6V3h6v3M5 6l1 15h12l1-15M10 10v7M14 10v7"/></svg>';

    // 추가: 현재 위치가 아닌 식당 좌표를 기준으로 일반 쓰레기통 1개만 선택합니다.
    // 직선거리 기준의 추천이며, 실제 최단 도보 경로를 비교한 결과는 아닙니다.
    function nearestGeneralBin(restaurant, bins, radius = 1500) {
        if (!validPoint(restaurant) || !Array.isArray(bins)) throw new Error('식당 또는 쓰레기통 정보를 확인해주세요.');
        let best = null;
        bins.forEach(bin => {
            if (!validPoint(bin) || bin.id == null || bin.category !== 'general') return;
            const distance = meters(restaurant, bin);
            if (distance > radius) return;
            if (!best || distance < best.distance
                    || (distance === best.distance && String(bin.id) < String(best.id))) {
                best = {...bin, name: bin.name || '일반 쓰레기통', distance};
            }
        });
        return best;
    }

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
                <div class="br-journey" data-el="journey" hidden>
                    <div class="br-stages" role="group" aria-label="길찾기 구간">
                        <button type="button" data-stage="restaurant">1. 식당까지</button>
                        <button type="button" data-stage="bin" disabled>2. 식사 후 쓰레기통</button>
                    </div>
                    <p data-el="bin-status" role="status" aria-live="polite"></p>
                    <button type="button" class="br-bin-retry" data-action="retry-bins" hidden>쓰레기통 다시 연결</button>
                </div>
                <div class="br-modes" data-el="modes" role="group" aria-label="식당까지 이동수단">
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
        // 연결 상태 문구가 길어져도 위·아래 패널이 겹치지 않도록 실제 높이를 사용합니다.
        function measureTop() {
            const height = host.querySelector('.br-top').offsetHeight;
            if (height > 0) host.style.setProperty('--br-top-height', height + 'px');
        }
        const sizeObserver = global.ResizeObserver ? new global.ResizeObserver(measureTop) : null;
        sizeObserver?.observe(host.querySelector('.br-top'));
        const restaurantOrigin = document.createElement('option');
        restaurantOrigin.value = 'restaurant';
        restaurantOrigin.textContent = '선택한 식당 (출발 미리보기)';
        restaurantOrigin.hidden = restaurantOrigin.disabled = true;
        el('origin').appendChild(restaurantOrigin);
        if (options.allowTestOrigin === true) {
            const option = document.createElement('option');
            option.value = 'test';
            option.textContent = '도톤보리 테스트 출발점 (가상 위치)';
            el('origin').appendChild(option);
        }

        let destination = null, origin = null, active = false, mode = 'walk', originFailure = '';
        let version = 0, controller = null, watchId = null, followVersion = 0;
        let results = {}, saved = null, previousFocus = null, userMarker = null;
        // 추가: 두 구간을 분리해 식당 도착이 곧 쓰레기통 도착으로 처리되지 않게 합니다.
        let journey = null, stage = 'restaurant', firstOriginChoice = 'current', firstMode = 'walk';
        // 추가: 같은 식당 안에서 구간별 출발지·이동수단·조회 결과를 기억합니다.
        // 구간별 화면 저장은 메모리에서만 관리하며, 닫거나 식당을 바꾸면 비웁니다.
        let stageViews = {restaurant: null, bin: null};
        let journeyController = null;
        const binRadius = Number.isFinite(options.nearestBinRadius) && options.nearestBinRadius > 0
            ? options.nearestBinRadius : 1500;
        const routeLayers = global.L.layerGroup().addTo(map);
        const userLayers = global.L.layerGroup().addTo(map);
        const cache = new Map(); // 현재 탭에서만 5분 재사용. 위치를 localStorage나 DB에 저장하지 않음.

        function activate(target) {
            if (!validPoint(target)) throw new Error('목적지 좌표가 올바르지 않습니다.');
            if (!active) {
                saved = {center: map.getCenter(), zoom: map.getZoom(), bounds: map.options.maxBounds};
                previousFocus = document.activeElement;
                document.body.classList.add('bingo-routing-active');
                host.hidden = false;
                active = true;
                map.setMaxBounds(null);
                map.invalidateSize({pan: false});
            }
            destination = {lat: target.lat, lon: target.lon, name: target.name || '선택한 쓰레기통', kind: target.kind || 'bin'};
            el('destination').textContent = destination.name;
            map.closePopup();
            host.querySelector('[data-action="close"]').focus();
            paintJourney();
        }

        function open(target) {
            if (!validPoint(target)) throw new Error('목적지 좌표가 올바르지 않습니다.');
            journeyController?.abort(); journey = null; stage = 'restaurant';
            stageViews = {restaurant: null, bin: null};
            if (el('origin').value === 'restaurant') el('origin').value = firstOriginChoice;
            activate(target);
            return load();
        }

        function openRestaurant(target, settings = {}) {
            if (!validPoint(target)) throw new Error('식당 좌표가 올바르지 않습니다.');
            journeyController?.abort();
            rememberRestaurantChoice();
            el('origin').value = firstOriginChoice;
            stage = 'restaurant'; mode = firstMode;
            stageViews = {restaurant: null, bin: null};
            journey = {restaurant: {...target, kind: 'restaurant'}, city: settings.city || 'osaka',
                bin: null, state: 'idle', leg: null};
            activate(journey.restaurant);
            // 변경: 식당까지의 경로만 조회합니다. 쓰레기통은 2번 구간을 선택할 때 찾습니다.
            return load();
        }

        function paintJourney() {
            el('journey').hidden = !journey;
            host.classList.toggle('br-has-journey', Boolean(journey));
            el('modes').hidden = Boolean(journey && stage === 'bin');
            restaurantOrigin.hidden = restaurantOrigin.disabled = !journey || stage !== 'bin';
            host.querySelectorAll('[data-stage]').forEach(button => {
                button.setAttribute('aria-pressed', String(button.dataset.stage === stage));
                // 변경: 결과가 없거나 조회가 실패해도 2번 구간에서 상태를 확인할 수 있습니다.
                if (button.dataset.stage === 'bin') button.disabled = !journey;
            });
            const showBinDetails = Boolean(journey && stage === 'bin');
            el('bin-status').hidden = !showBinDetails;
            const retry = host.querySelector('[data-action="retry-bins"]');
            retry.hidden = !showBinDetails || (!['error', 'empty'].includes(journey.state) && journey.leg?.state !== 'error');
            if (!showBinDetails) {
                el('bin-status').textContent = '';
                measureTop();
                return;
            }
            let message = '식당에서 가까운 일반 쓰레기통을 확인하고 있습니다…';
            if (journey.state === 'empty') message = `식당 반경 ${distanceText(binRadius)} 안에 등록된 일반 쓰레기통이 없습니다. 식당 길찾기는 이용할 수 있습니다.`;
            if (journey.state === 'error') message = journey.message + ' 식당 길찾기는 이용할 수 있습니다.';
            if (journey.bin) {
                message = `${journey.bin.name} · 식당에서 직선 ${distanceText(journey.bin.distance)} · 일반 쓰레기통`;
                if (journey.leg?.state === 'ready') message += `\n식당 → 쓰레기통: 도보 ${timeText(journey.leg.route.durationSeconds)} · ${distanceText(journey.leg.route.distanceMeters)}`;
                else if (journey.leg?.state === 'error') message += '\n위치는 연결됐지만 도보 경로를 불러오지 못했습니다.';
                else if (journey.leg?.state === 'nearby') message += '\n식당 바로 근처입니다. 주변에서 위치를 확인해주세요.';
                else message += '\n식당에서 쓰레기통까지 도보 경로 확인 중…';
            }
            el('bin-status').textContent = message;
            measureTop();
        }

        async function loadNearby(mine) {
            journeyController?.abort();
            // 쓰레기통을 다시 선택하면 이전 쓰레기통 구간의 화면을 재사용하지 않습니다.
            stageViews.bin = null;
            const abort = journeyController = new AbortController();
            const lookup = mine.lookup = Symbol('bin-lookup');
            const isCurrent = () => active && journey === mine && mine.lookup === lookup;
            mine.state = 'loading'; mine.bin = null; mine.leg = null;
            paintJourney();
            if (stage === 'bin') {
                destination = null;
                el('destination').textContent = '식사 후 쓰레기통';
                load();
            }
            const timer = setTimeout(() => abort.abort(), 15000);
            try {
                // 변경된 프로젝트의 Oracle 조회 API를 그대로 사용합니다. Overpass 호출 없음.
                const response = await fetch('/api/bins?city=' + encodeURIComponent(mine.city),
                    {signal: abort.signal, cache: 'no-store', headers: {Accept: 'application/json'}});
                if (!response.ok) throw new Error(`쓰레기통 DB 조회 실패 (HTTP ${response.status}).`);
                const bins = await response.json();
                if (!isCurrent()) return;
                if (!Array.isArray(bins)) throw new Error('쓰레기통 API의 배열 응답을 확인해주세요.');
                mine.bin = nearestGeneralBin(mine.restaurant, bins, binRadius);
                mine.state = mine.bin ? 'ready' : 'empty';
            } catch (error) {
                if (!isCurrent()) return;
                mine.state = 'error';
                mine.message = error.name === 'AbortError' ? '쓰레기통 DB 조회 시간이 초과됐습니다.' : error.message;
            } finally {
                clearTimeout(timer);
            }
            if (!isCurrent()) return;
            paintJourney();
            // 변경: 조회 중 식당 구간으로 돌아갔다면 지도·경로를 건드리지 않습니다.
            if (stage === 'bin') {
                destination = mine.bin ? {...mine.bin, kind: 'bin'} : null;
                el('destination').textContent = destination?.name || '식사 후 쓰레기통';
                load();
            }
        }

        function rememberRestaurantChoice() {
            // 쓰레기통 구간에서 출발지를 바꿔도 식당까지의 설정은 유지합니다.
            if ((!journey || stage === 'restaurant') && ['current', 'test'].includes(el('origin').value)) {
                firstOriginChoice = el('origin').value;
                firstMode = mode;
            }
        }

        function rememberStage() {
            rememberRestaurantChoice();
            if (!journey) return;
            stageViews[stage] = {
                choice: el('origin').value,
                mode,
                origin: origin ? {...origin} : null,
                originFailure,
                results: {...results}
            };
        }

        function chooseStage(next) {
            if (!journey || !['restaurant', 'bin'].includes(next) || next === stage) return;
            rememberStage();
            const restored = stageViews[next];
            if (next === 'bin') {
                stage = 'bin'; mode = 'walk';
                restaurantOrigin.hidden = restaurantOrigin.disabled = false;
                el('origin').value = restored?.choice || 'restaurant';
                destination = journey.bin ? {...journey.bin, kind: 'bin'} : null;
            } else {
                stage = 'restaurant'; mode = restored?.mode || firstMode;
                el('origin').value = restored?.choice || firstOriginChoice;
                destination = journey.restaurant;
            }
            el('destination').textContent = destination?.name || '식사 후 쓰레기통';
            paintJourney();
            // 변경: 돌아온 구간은 저장된 위치와 결과로 복원합니다.
            if (next === 'bin' && journey.state === 'idle') loadNearby(journey);
            else load(false, restored);
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
            journeyController?.abort(); journey = null;
            stageViews = {restaurant: null, bin: null};
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
            if (error.code === 1) return '현재 위치 요청이 거부됐습니다. 사이트·기기의 위치 권한을 확인해주세요.';
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
        async function load(startAfterLoad = false, restored = null) {
            const mine = ++version;
            controller?.abort();
            const abort = controller = new AbortController();
            stopFollowing();
            routeLayers.clearLayers();
            userLayers.clearLayers();
            userMarker = null;
            origin = null;
            originFailure = '';
            results = restored ? {...restored.results} : {};
            paintTabs();
            el('summary').textContent = '출발지 확인 중';
            el('eta').textContent = '';
            el('steps').replaceChildren();
            el('note').textContent = '';
            startButton.disabled = true;
            el('status').textContent = '현재 위치를 확인하고 있습니다.';
            // 쓰레기통 미조회·조회 중·실패·0건 상태에서는 출발지와 경로를 요청하지 않습니다.
            if (journey && stage === 'bin' && !journey.bin) {
                paintRoute();
                return;
            }
            try {
                // 실패한 출발지도 빈 화면으로 지우지 않고 설명을 그대로 보여줍니다.
                // 사용자가 출발지를 변경하거나 '다시 조회'를 누르면 새로 확인합니다.
                if (restored?.originFailure) {
                    originFailure = restored.originFailure;
                    el('status').textContent = originFailure;
                    paintRoute();
                    return;
                }
                const isTest = el('origin').value === 'test';
                const isPreview = Boolean(journey && stage === 'bin' && el('origin').value === 'restaurant');
                const position = restored?.origin ? {...restored.origin}
                    : isPreview ? {...journey.restaurant} : isTest ? {...TEST_START} : await getPosition();
                if (!active || mine !== version) return;
                if (!validPoint(position)) throw new Error('현재 위치의 좌표를 확인해주세요.');
                // 복원한 실제 위치는 '미리보기'로 표시하고 실제 안내 시작 시 새로 확인합니다.
                origin = {...position, isTest, isPreview, isSnapshot: Boolean(restored?.origin && !isTest && !isPreview)};
                if (meters(origin, destination) > MAX_DISTANCE) {
                    throw new Error('목적지와 50km 이상 떨어져 있습니다. 한국에서 테스트한다면 출발지를 ‘도톤보리 테스트 출발점’으로 바꿔주세요.');
                }
                el('status').textContent = isPreview
                    ? '식당 출발 도보 경로 미리보기입니다. 안내 버튼을 누르면 내 현재 위치에서 다시 계산합니다.'
                    : isTest
                    ? '가상 출발점으로 테스트 중입니다. 실제 내 위치가 아닙니다.'
                    : origin.isSnapshot
                    ? '이전에 확인한 내 위치 기준입니다. 실제 안내를 시작하면 현재 위치를 다시 확인합니다.'
                    : `현재 위치 기준 · 위치 오차 약 ${distanceText(origin.accuracy || 0)}`;
                const keys = journey && stage === 'bin' ? ['walk'] : Object.keys(MODES);
                if (meters(origin, destination) < 5) {
                    for (const key of keys) results[key] = {state: 'nearby'};
                    if (isPreview) { journey.leg = {state: 'nearby'}; paintJourney(); }
                    paintTabs(); paintRoute(); return;
                }
                // 완료된 결과는 바로 표시하고, 구간 전환 때문에 중단된 요청만 다시 이어갑니다.
                const pendingKeys = keys.filter(key => !results[key] || results[key].state === 'loading');
                for (const key of pendingKeys) results[key] = {state: 'loading'};
                if (isPreview && pendingKeys.length) { journey.leg = {state: 'loading'}; paintJourney(); }
                paintTabs();
                paintRoute();
                await Promise.allSettled(pendingKeys.map(async key => {
                    try {
                        const route = await fetchRoute(key, origin, destination, abort.signal);
                        if (!active || mine !== version) return;
                        results[key] = {state: 'ready', route};
                        if (isPreview && journey) {
                            journey.leg = {state: 'ready', route};
                            paintJourney();
                        }
                    } catch (error) {
                        if (!active || mine !== version) return;
                        results[key] = {state: 'error', message: error.message};
                        if (isPreview && journey) {
                            journey.leg = {state: 'error', message: error.message};
                            paintJourney();
                        }
                    }
                    paintTabs();
                    if (mode === key) paintRoute();
                }));
                if (startAfterLoad === true && active && mine === version && results[mode]?.state === 'ready') followPosition();
            } catch (error) {
                if (!active || mine !== version) return;
                originFailure = error.message;
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
                if (data.distanceMeters < 0 || data.durationSeconds < 0 || data.steps.length === 0
                    || !Number.isFinite(data.startGapMeters) || data.startGapMeters < 0
                    || !Number.isFinite(data.endGapMeters) || data.endGapMeters < 0
                    || data.coordinates.some(p => !Array.isArray(p) || !validPoint({lat:p[1], lon:p[0]}))
                    || data.steps.some(s => !s || typeof s.instruction !== 'string'
                        || !Number.isFinite(s.distanceMeters) || s.distanceMeters < 0
                        || !Number.isInteger(s.startIndex) || !Number.isInteger(s.endIndex)
                        || s.startIndex < 0 || s.endIndex < s.startIndex || s.endIndex >= data.coordinates.length)) {
                    throw new Error('경로 좌표 또는 이동 순서가 올바르지 않습니다.');
                }
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
                            : result.state === 'nearby' ? '바로 근처'
                            : `${timeText(result.route.durationSeconds)} · ${distanceText(result.route.distanceMeters)}`;
            });
        }

        function addPoint(position, className, label) {
            const icon = global.L.divIcon({className: 'br-point-wrap',
                html: `<span class="br-point ${className}">${className === 'br-point-bin' ? BIN_SVG : ''}</span>`, iconSize: [24, 24], iconAnchor: [12, 12]});
            const marker = global.L.marker([position.lat, position.lon], {icon, zIndexOffset: 1000}).addTo(routeLayers);
            // 이름은 HTML로 해석하지 않고 텍스트로 넣습니다.
            const text = document.createElement('span'); text.textContent = label;
            marker.bindTooltip(text, {permanent: true, direction: 'top', offset: [0, -12], className: 'br-point-label'});
        }

        function paintRoute() {
            measureTop();
            routeLayers.clearLayers();
            userLayers.clearLayers(); userMarker = null;
            startButton.disabled = true;
            el('steps').replaceChildren();
            el('eta').textContent = '';
            el('note').textContent = '';
            if (!destination) {
                if (journey && stage === 'bin') {
                    const waiting = ['idle', 'loading'].includes(journey.state);
                    el('summary').textContent = waiting ? '쓰레기통 위치 확인 중'
                        : journey.state === 'empty' ? '주변에 등록된 일반 쓰레기통이 없습니다'
                        : '쓰레기통 정보를 불러오지 못했습니다';
                    el('status').textContent = waiting ? '식당에서 가까운 쓰레기통을 찾고 있습니다.'
                        : '다시 연결하거나 식당 구간으로 돌아갈 수 있습니다.';
                }
                return;
            }
            // 변경: 현재 선택한 구간의 목적지만 표시합니다.
            addPoint(destination, destination.kind === 'restaurant' ? 'br-point-restaurant' : 'br-point-bin', destination.name);
            const result = results[mode];
            if (originFailure) {
                el('summary').textContent = '출발지를 확인해주세요';
                el('note').textContent = originFailure;
                return;
            }
            if (!result || result.state === 'loading') {
                el('summary').textContent = `${MODES[mode]} 경로 계산 중…`; return;
            }
            if (result.state === 'error') {
                el('summary').textContent = `${MODES[mode]} 경로를 표시할 수 없습니다`;
                el('note').textContent = result.message; return;
            }
            if (result.state === 'nearby') {
                el('summary').textContent = '목적지 바로 근처입니다';
                el('note').textContent = destination.kind === 'restaurant'
                    ? '식당 위치를 확인하고, 식사 후 2번 쓰레기통 구간을 선택해주세요.'
                    : '주변에서 쓰레기통의 실제 위치와 분리배출 표시를 확인해주세요.';
                startButton.disabled = !(origin?.isPreview || origin?.isSnapshot);
                startButton.textContent = origin?.isPreview || origin?.isSnapshot ? '내 현재 위치에서 안내' : '목적지 근처';
                map.fitBounds(global.L.latLngBounds([[destination.lat, destination.lon]]), {maxZoom: 18, padding: [60, 60]});
                return;
            }
            const route = result.route;
            // GeoJSON [경도, 위도] → Leaflet [위도, 경도].
            const latLngs = route.coordinates.map(point => [point[1], point[0]]);
            global.L.polyline(latLngs, {color: '#fff', weight: 9, opacity: .95, interactive: false}).addTo(routeLayers);
            global.L.polyline(latLngs, {color: journey && stage === 'bin' ? '#1a9d52' : '#1677ff', weight: 5,
                dashArray: mode === 'walk' ? '1 10' : null, lineCap: 'round', interactive: false}).addTo(routeLayers);
            addPoint(origin, origin.isPreview ? 'br-point-restaurant' : 'br-point-start',
                origin.isPreview ? journey.restaurant.name : origin.isTest ? '테스트 출발점' : '출발 위치');
            const stageLabel = journey ? (stage === 'bin' ? '쓰레기통까지 ' : '식당까지 ') : '';
            el('summary').textContent = `${stageLabel}${MODES[mode]} ${timeText(route.durationSeconds)} · ${distanceText(route.distanceMeters)}`;
            const arrival = new Date(Date.now() + route.durationSeconds * 1000);
            el('eta').textContent = origin.isPreview ? '식당에서 출발하는 구간만 계산 · 식사 시간 제외'
                : origin.isSnapshot ? '이전에 조회한 경로 미리보기'
                : `지금 출발 시 ${arrival.toLocaleTimeString('ko-KR', {hour: '2-digit', minute: '2-digit', timeZone: 'Asia/Tokyo'})} 도착 예상 (일본 시간)`;
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
            startButton.textContent = watchId !== null ? '안내 중지' : origin.isPreview || origin.isSnapshot ? '내 현재 위치에서 안내'
                : origin.isTest ? '테스트 경로 미리보기 중' : '안내 시작';
            const size = map.getSize();
            const large = size.x >= 1000;
            // 변경: 화면 범위도 현재 구간의 출발지·목적지·경로에만 맞춥니다.
            const bounds = global.L.latLngBounds([...latLngs, [origin.lat, origin.lon], [destination.lat, destination.lon]]);
            if (watchId === null) map.fitBounds(bounds, {maxZoom: 18, animate: false,
                paddingTopLeft: large ? [460, 50] : [25, host.querySelector('.br-top').offsetHeight + 35],
                paddingBottomRight: large ? [50, 50] : [25, host.querySelector('.br-bottom').offsetHeight + 35]});
        }

        function followPosition() {
            if (watchId !== null) { stopFollowing(); return; }
            if (origin?.isPreview || origin?.isSnapshot) {
                el('origin').value = 'current';
                load(true); return;
            }
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
                    el('navigation').textContent = destination.kind === 'restaurant'
                        ? '식당 근처입니다. 식사 후 ‘2. 식사 후 쓰레기통’을 선택해주세요.'
                        : '목적지 근처입니다. 주변에서 쓰레기통 위치와 분리배출 표시를 확인해주세요.'; return;
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
            const stageButton = event.target.closest('[data-stage]');
            if (stageButton && !stageButton.disabled) { chooseStage(stageButton.dataset.stage); return; }
            const tab = event.target.closest('[data-mode]');
            if (tab) {
                stopFollowing(); mode = tab.dataset.mode; rememberRestaurantChoice();
                paintTabs(); if (origin && results[mode]) paintRoute(); return;
            }
            const action = event.target.closest('[data-action]')?.dataset.action;
            if (action === 'close') close();
            if (action === 'reload') {
                cache.clear();
                if (journey && stage === 'bin' && !journey.bin) {
                    if (journey.state !== 'loading') loadNearby(journey);
                    return;
                }
                load();
            }
            if (action === 'retry-bins' && journey && journey.state !== 'loading') {
                loadNearby(journey);
            }
            if (action === 'start') followPosition();
        });
        el('origin').addEventListener('change', () => {
            rememberRestaurantChoice();
            load();
        });
        const onKey = event => { if (event.key === 'Escape' && active) close(); };
        document.addEventListener('keydown', onKey);
        return Object.freeze({open, openRestaurant, close, destroy() {
                close(); host.remove(); routeLayers.remove(); userLayers.remove();
                sizeObserver?.disconnect();
                document.removeEventListener('keydown', onKey); cache.clear();
            }});
    }

    global.BinGoRouting = Object.freeze({create, nearestGeneralBin});
})(window);
