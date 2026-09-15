/* 팀 Oracle RESTAURANT 테이블을 기존 Leaflet 지도에 표시합니다. Overpass를 호출하지 않습니다. */
(function (global) {
    'use strict';
    const FOOD_ICON = '<svg viewBox="0 0 24 24" width="21" height="21" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 3v6a3 3 0 0 0 6 0V3M8 3v18M19 21V3c-4 3-4 9 0 9"/></svg>';
    function el(tag, cls, text) {
        const node = document.createElement(tag);
        if (cls) node.className = cls;
        if (text !== undefined && text !== null) node.textContent = String(text);
        return node;
    }
    function button(cls, text, action) {
        const node = el('button', cls, text);
        node.type = 'button'; node.addEventListener('click', action); return node;
    }
    function distance(a, b) {
        const rad = Math.PI / 180, dLat = (b.lat - a.lat) * rad, dLon = (b.lon - a.lon) * rad;
        const h = Math.sin(dLat / 2) ** 2 + Math.cos(a.lat * rad) * Math.cos(b.lat * rad) * Math.sin(dLon / 2) ** 2;
        return 6371000 * 2 * Math.asin(Math.sqrt(Math.min(1, h)));
    }
    function meters(value) { return value < 1000 ? Math.round(value) + 'm' : (value / 1000).toFixed(1) + 'km'; }
    function coordinates(p) {
        return p && Number.isFinite(p.lat) && Math.abs(p.lat) <= 90
            && Number.isFinite(p.lon) && Math.abs(p.lon) <= 180;
    }
    function photo(place) {
        const frame = el('div', 'brm-photo');
        const fallback = el('span', 'brm-photo-fallback'); fallback.innerHTML = FOOD_ICON;
        frame.append(fallback);
        // 기존 프로젝트의 /images/ 파일만 사용합니다. 누락 시 기본 아이콘을 유지합니다.
        const url = place.mainImageUrl;
        if (typeof url === 'string' && /^\/images\/[a-zA-Z0-9_/-]+\.(png|jpe?g|webp)$/i.test(url)) {
            const img = el('img'); img.alt = place.name; img.loading = 'lazy';
            img.addEventListener('error', function () { img.remove(); });
            img.src = url; frame.append(img);
        }
        return frame;
    }
    function link(label, value) {
        try {
            const url = new URL(value);
            if (!['http:', 'https:'].includes(url.protocol)) return null;
            const a = el('a', 'brm-source', label);
            a.href = url.href; a.target = '_blank'; a.rel = 'noopener noreferrer'; return a;
        } catch (error) { return null; }
    }

    function create(map, options) {
        options = options || {};
        const sidebar = document.querySelector('.sidebar');
        if (!sidebar) throw new Error('지도 HTML에 .sidebar가 없습니다.');
        if (sidebar.querySelector('.brm-tabs, .bt-tabs'))
            throw new Error('음식점 지도는 한 번만 초기화하세요. 기존 BinGoTakeaway.create 호출을 제거해주세요.');

        let active = false, loaded = false, loading = false, destroyed = false;
        let places = [], selected = null, failure = '', result = null, controller = null;
        const layer = L.layerGroup(), markers = new Map();
        const tabs = el('div', 'brm-tabs');
        tabs.setAttribute('aria-label', '지도에 표시할 장소');
        const binTab = button('brm-tab', '쓰레기통', function () { setActive(false); });
        const foodTab = button('brm-tab', '식당', function () { setActive(true); });
        binTab.setAttribute('aria-pressed', 'true'); foodTab.setAttribute('aria-pressed', 'false');
        tabs.append(binTab, foodTab); sidebar.prepend(tabs);

        const panel = el('section', 'brm-panel'); panel.hidden = true;
        const controls = el('div', 'brm-controls');
        const search = el('input', 'brm-search'); search.type = 'search';
        search.placeholder = '식당 이름, 음식 종류, 주소 검색'; search.setAttribute('aria-label', '식당 검색');
        const bothLabel = el('label', 'brm-check'), both = el('input'); both.type = 'checkbox';
        bothLabel.append(both, document.createTextNode('쓰레기통도 함께 보기'));
        controls.append(search, bothLabel);
        const heading = el('div', 'brm-heading'), count = el('strong', '', '식당 정보');
        const refresh = button('brm-refresh', '다시 조회', function () { load(); }); heading.append(count, refresh);
        const reference = el('p', 'brm-reference');
        const sample = el('p', 'brm-sample', '연동 테스트용 샘플입니다. 가격·영업정보·평점은 실제 정보로 검증되지 않았습니다.');
        sample.hidden = true;
        const status = el('p', 'brm-status'); status.setAttribute('role', 'status');
        const list = el('div', 'brm-list');
        const note = el('p', 'brm-note', '팀에서 등록한 식당입니다. 메뉴별 포장 가능 여부는 매장에 확인해주세요.');
        panel.append(controls, heading, reference, sample, status, list, note); sidebar.append(panel);
        const badge = el('div', 'brm-map-badge', '등록 식당'); badge.hidden = true;
        map.getContainer().parentElement.append(badge);

        function getReference() {
            const p = typeof options.getReference === 'function' ? options.getReference() : null;
            return coordinates(p) ? p : {lat:34.6687, lon:135.5031, label:'도톤보리 중심'};
        }
        function filtered() {
            const term = search.value.trim().toLocaleLowerCase(), origin = getReference();
            return places.filter(function (p) {
                return [p.name, p.category, p.tags, p.address].join(' ').toLocaleLowerCase().includes(term);
            }).map(function (p) { return {place:p, distance:distance(origin, p)}; })
                .sort(function (a, b) { return a.distance - b.distance; });
        }
        function fitPlaces() {
            if (active && places.length) map.fitBounds(places.map(function (p) { return [p.lat, p.lon]; }),
                {padding:[36, 36], maxZoom:17});
        }
        function choose(id) {
            selected = id;
            list.querySelectorAll('.brm-card').forEach(function (card) {
                const match = card.dataset.id === id;
                card.classList.toggle('is-selected', match); card.setAttribute('aria-pressed', String(match));
            });
        }
        function popup(p) {
            const box = el('div', 'brm-popup'), origin = getReference();
            box.append(el('span', 'brm-kicker', result.sampleData ? '샘플 식당 정보' : '등록 식당'), el('h3', '', p.name));
            box.append(photo(p));
            if (p.category) box.append(el('span', 'brm-tag', p.category));
            box.append(el('p', 'brm-popup-distance', (origin.label || '기준 위치') + '에서 직선 ' + meters(distance(origin, p))));
            function detail(label, value) { if (value) box.append(el('p', 'brm-detail', label + value)); }
            detail('', p.description); detail('주소: ', p.address); detail('영업시간: ', p.openingHours);
            detail('전화: ', p.phone); detail('예산: ', p.priceRange); detail('좌석: ', p.seatInfo);
            detail('예약: ', p.reservationInfo); detail('결제: ', p.paymentMethods); detail('언어: ', p.languages);
            if (Number.isFinite(p.rating)) {
                let rating = (result.sampleData ? '예시 평점: ' : '등록 평점: ') + p.rating.toFixed(1);
                if (Number.isFinite(p.reviewCount)) rating += ' · 리뷰 ' + p.reviewCount.toLocaleString('ko-KR') + '개';
                detail('', rating);
            }
            box.append(el('h4', 'brm-menu-title', '대표 메뉴'));
            if (p.menuName) {
                box.append(el('strong', 'brm-menu-name', p.menuName)); detail('', p.menuDescription);
                box.append(el('p', 'brm-menu-price', p.menuPrice || '가격 정보 없음'));
            } else detail('', '등록된 대표 메뉴가 없습니다.');
            if (result.sampleData) detail('', '위 가격·평점 등은 연동 테스트용 샘플 값입니다.');
            const website = link('등록된 웹사이트', p.websiteUrl); if (website) box.append(website);
            const route = button('brm-route', '길찾기 ›', function () {
                if (typeof options.onRoute !== 'function') { route.textContent = '길찾기 연결 설정을 확인해주세요'; return; }
                try { map.closePopup(); options.onRoute(p); }
                catch (error) { route.textContent = '길찾기 모듈 연결을 확인해주세요'; }
            });
            box.append(route); return box;
        }
        function drawMarkers(rows) {
            layer.clearLayers(); markers.clear();
            rows.forEach(function (row) {
                const p = row.place;
                const icon = L.divIcon({className:'brm-marker-wrap', html:'<div class="brm-marker">' + FOOD_ICON + '</div>',
                    iconSize:[34,42], iconAnchor:[17,42], popupAnchor:[0,-43]});
                const marker = L.marker([p.lat, p.lon], {icon:icon, title:p.name})
                    .bindPopup(function () { return popup(p); }, {className:'brm-leaflet-popup', maxWidth:310, minWidth:240, maxHeight:370});
                // 마커는 Leaflet의 기본 팝업 열기를 사용합니다. 여기서 openPopup()을 중복 호출하지 않습니다.
                marker.on('click', function () { choose(p.id); }); marker.addTo(layer); markers.set(p.id, marker);
            });
        }
        function drawList(rows) {
            list.replaceChildren();
            rows.forEach(function (row) {
                const p = row.place;
                const card = button('brm-card', undefined, function () {
                    choose(p.id); map.panTo([p.lat, p.lon]);
                    const marker = markers.get(p.id); if (marker) marker.openPopup();
                });
                card.dataset.id = p.id;
                const top = el('div', 'brm-card-top');
                top.append(el('strong', 'brm-name', p.name), el('span', 'brm-distance', meters(row.distance)));
                card.append(top, el('span', 'brm-tag', p.category || '음식점'));
                if (p.menuName) card.append(el('span', 'brm-address', p.menuName + ' · ' + (p.menuPrice || '가격 정보 없음')));
                card.append(el('span', 'brm-address', p.address || '주소 정보 없음')); list.append(card);
            });
            choose(selected);
        }
        function render(rebuild) {
            const rows = filtered(), origin = getReference();
            count.textContent = loaded ? '식당 ' + rows.length + '곳 / 지도 등록 ' + places.length + '곳' : '식당 정보';
            badge.textContent = loaded ? '등록 식당 ' + rows.length + '곳' : '식당 정보';
            reference.textContent = (origin.label || '기준 위치') + '에서의 직선 거리순';
            sample.hidden = !loaded || !result.sampleData; refresh.disabled = loading;
            let message = loading ? '식당 정보를 불러오는 중입니다.' : failure;
            if (loading && !loaded) badge.textContent = '식당 조회 중';
            if (!loading && !failure && loaded) {
                message = result.message || '';
                if (!rows.length) message += (message ? ' ' : '') + (places.length
                    ? '검색 조건에 맞는 식당이 없습니다.' : (result.totalCount
                        ? '지도에 표시할 수 있는 좌표가 없습니다.' : '등록된 식당이 없습니다.'));
            }
            if (failure && !loaded) badge.textContent = '식당 조회 실패';
            if (failure && loaded) badge.textContent += ' · 이전 결과';
            status.textContent = message; status.hidden = !message; status.classList.toggle('is-error', Boolean(failure));
            drawList(rows); if (rebuild) drawMarkers(rows);
        }
        async function load() {
            if (loading || destroyed) return;
            loading = true; failure = ''; render(false); controller = new AbortController();
            const timer = setTimeout(function () { controller.abort(); }, 15000);
            try {
                const response = await fetch('/api/map/restaurants', {signal:controller.signal, headers:{Accept:'application/json'}});
                let data;
                try { data = await response.json(); }
                catch (error) { throw new Error('식당 API에서 JSON이 아닌 응답을 받았습니다. API 주소와 로그인 접근 설정을 확인해주세요.'); }
                if (!response.ok) throw new Error(data.message || '식당 조회 실패 (HTTP ' + response.status + ')');
                if (!Array.isArray(data.places)) throw new Error('응답에 places 배열이 없습니다.');
                const ids = new Set();
                for (const p of data.places) {
                    if (!coordinates(p) || typeof p.id !== 'string' || !p.id || typeof p.name !== 'string' || ids.has(p.id))
                        throw new Error('식당 좌표나 고유 번호가 올바르지 않습니다.');
                    ids.add(p.id);
                }
                if (destroyed) return;
                places = data.places; result = data; loaded = true; fitPlaces();
            } catch (error) {
                if (!destroyed) {
                    failure = error.name === 'AbortError' ? '식당 조회 시간이 초과됐습니다. DB 연결을 확인해주세요.' : error.message;
                    if (loaded) failure += ' 이전에 받은 목록을 유지합니다.';
                }
            } finally {
                clearTimeout(timer); loading = false; if (!destroyed) render(true);
            }
        }
        function setActive(value) {
            if (destroyed) return;
            active = value;
            document.body.classList.toggle('bingo-restaurant-mode', active);
            document.body.classList.toggle('bingo-restaurant-with-bins', active && both.checked);
            panel.hidden = !active; badge.hidden = !active;
            binTab.setAttribute('aria-pressed', String(!active)); foodTab.setAttribute('aria-pressed', String(active));
            map.closePopup();
            if (active) { layer.addTo(map); if (!loaded) load(); else { render(true); fitPlaces(); } }
            else map.removeLayer(layer);
        }
        search.addEventListener('input', function () { render(true); });
        both.addEventListener('change', function () {
            map.closePopup(); document.body.classList.toggle('bingo-restaurant-with-bins', active && both.checked);
        });
        render(false);
        return {
            refreshDistances:function () { if (!destroyed) render(false); },
            refresh:function () { load(); },
            destroy:function () {
                destroyed = true; if (controller) controller.abort(); map.removeLayer(layer); layer.clearLayers(); markers.clear();
                tabs.remove(); panel.remove(); badge.remove();
                document.body.classList.remove('bingo-restaurant-mode', 'bingo-restaurant-with-bins');
            }
        };
    }
    global.BinGoRestaurants = Object.freeze({create:create});
})(window);
