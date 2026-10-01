/* 주변맛집 상세 → 지도 연결. bingo-restaurants.js 다음, 지도 초기화 전 로드합니다. */
(function (global) {
    'use strict';
    const base = global.BinGoRestaurants;
    if (!base || typeof base.create !== 'function') {
        console.error('bingo-restaurant-entry.js를 bingo-restaurants.js 바로 다음에 넣어주세요.');
        return;
    }
    if (base.restaurantEntryInstalled) return;

    function destination() {
        const query = new URLSearchParams(global.location.search);
        if (!query.has('lat') && !query.has('lon')) return null;
        const type = (query.get('type') || '').toLowerCase();
        if (type && type !== 'restaurant') return null;
        const latText = (query.get('lat') || '').trim();
        const lonText = (query.get('lon') || '').trim();
        const lat = latText ? Number(latText) : NaN;
        const lon = lonText ? Number(lonText) : NaN;
        return {
            lat, lon, name: query.get('name') || '',
            route: query.get('route') === 'true',
            valid: Number.isFinite(lat) && Math.abs(lat) <= 90
                && Number.isFinite(lon) && Math.abs(lon) <= 180
        };
    }

    function connect(map, options, target) {
        let stopped = false, pending = true, queued = null, timeout = null;
        let tabs, panel, notice;

        function say(message) {
            if (!panel || stopped) return;
            if (!notice) {
                notice = document.createElement('p');
                notice.className = 'brm-status bingo-restaurant-entry-status';
                notice.setAttribute('role', 'status');
                panel.prepend(notice);
            }
            notice.textContent = message;
        }
        function stop() {
            if (stopped) return;
            stopped = true;
            clearTimeout(queued); clearTimeout(timeout);
            map.off('layeradd', schedule);
            map.off('dragstart', cancel);
            if (tabs) tabs.removeEventListener('click', cancel, true);
            if (panel) {
                panel.removeEventListener('input', cancel, true);
                panel.removeEventListener('click', cancelSelection, true);
            }
            if (notice) notice.remove();
        }
        function cancel() { stop(); }
        function cancelSelection(event) {
            if (event.target.closest('.brm-card, .brm-route')) stop();
        }
        function schedule() {
            if (stopped || !pending || queued !== null) return;
            // 마커와 목록 생성이 모두 끝난 뒤 식당을 선택합니다.
            queued = setTimeout(function () { queued = null; select(); }, 0);
        }
        function select() {
            if (stopped || !pending) return;
            const matches = [];
            map.eachLayer(function (layer) {
                // 쓰레기통/경로 마커는 선택하지 않습니다. 기존 식당 마커만 사용합니다.
                const iconClass = layer.options?.icon?.options?.className || '';
                if (!iconClass.split(/\s+/).includes('brm-marker-wrap')
                        || typeof layer.getLatLng !== 'function') return;
                const point = layer.getLatLng();
                if (Math.abs(point.lat - target.lat) <= 0.000001
                        && Math.abs(point.lng - target.lon) <= 0.000001) matches.push(layer);
            });
            const candidates = matches.length > 1 && target.name
                ? matches.filter(marker => marker.options.title === target.name) : matches;
            if (candidates.length > 1) {
                say('같은 위치에 여러 식당이 있습니다. 목록에서 원하는 식당을 선택해주세요.');
                return;
            }
            if (candidates.length !== 1) return;

            const marker = candidates[0];
            const point = marker.getLatLng();
            pending = false;
            stop();
            // 기존 마커의 선택 처리를 재사용하므로 목록 강조와 팝업도 함께 바뀝니다.
            marker.fire('click');
            const card = panel.querySelector('.brm-card.is-selected');
            const id = card?.dataset.id;
            map.setView([point.lat, point.lng], Math.max(map.getZoom(), 16), {animate: false});
            marker.openPopup();

            if (target.route && id && typeof options.onRoute === 'function') {
                try {
                    const result = options.onRoute({
                        id, name: marker.options.title || target.name,
                        lat: point.lat, lon: point.lng
                    });
                    if (result && typeof result.catch === 'function') {
                        result.catch(error => console.error('식당 길찾기 연결 실패:', error));
                    }
                } catch (error) {
                    console.error('식당 길찾기 연결 실패:', error);
                    marker.openPopup();
                }
            }
        }

        // 기존 지도 초기화(스팟, 검색, 쓰레기통)가 끝난 다음 한 번만 연결합니다.
        queued = setTimeout(function () {
            queued = null;
            if (stopped) return;
            tabs = document.querySelector('.brm-tabs');
            panel = document.querySelector('.brm-panel');
            const foodTab = tabs?.querySelectorAll('.brm-tab')[1];
            if (!foodTab || !panel) {
                console.error('식당 지도 탭을 찾지 못했습니다. .brm-tabs / .brm-panel을 확인해주세요.');
                stop(); return;
            }
            foodTab.click();
            if (!target.valid) {
                say('식당 좌표가 올바르지 않습니다. 주변맛집에서 식당을 다시 선택해주세요.');
                return;
            }
            // 지도 화면만 이동합니다. 거리 계산/길찾기 출발 스팟은 바꾸지 않습니다.
            map.setView([target.lat, target.lon], Math.max(map.getZoom(), 16), {animate: false});
            tabs.addEventListener('click', cancel, true);
            panel.addEventListener('input', cancel, true);
            panel.addEventListener('click', cancelSelection, true);
            map.on('dragstart', cancel);
            map.on('layeradd', schedule);
            timeout = setTimeout(function () {
                say('선택한 식당을 지도 목록에서 찾지 못했습니다. 다시 조회하거나 식당의 공개 여부와 좌표를 확인해주세요.');
            }, 16000);
            schedule();
        }, 0);
        return stop;
    }

    global.BinGoRestaurants = Object.freeze(Object.assign({}, base, {
        restaurantEntryInstalled: true,
        create: function (map, options) {
            const api = base.create.call(base, map, options);
            const target = destination();
            if (!target) return api;
            const cleanup = connect(map, options || {}, target);
            return Object.assign({}, api, {
                destroy: function () {
                    cleanup();
                    if (typeof api.destroy === 'function') return api.destroy.apply(api, arguments);
                }
            });
        }
    }));
})(window);
