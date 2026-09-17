/* BinGo Map: 주요 지명과 역 이름을 남기는 벡터 배경 지도.
 * 불러오는 순서: Leaflet → MapLibre GL JS → Leaflet 어댑터 → 이 파일.
 * Java의 /api/bins와 쓰레기통 마커 생성 코드는 그대로 사용합니다.
 */
(function () {
    'use strict';

    const STYLE_URL = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json';
    const ATTRIBUTION = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap contributors</a>' +
        ' &copy; <a href="https://carto.com/attributions">CARTO</a>';

    // 데이터에 한국어 이름이 있으면 사용하고, 없으면 현지 이름으로 표시합니다.
    const NAME = ['coalesce', ['get', 'name:ko'], ['get', 'name'], ['get', 'name_en'], ''];

    function createStyle(original) {
        if (!original || original.version !== 8 || !Array.isArray(original.layers) || !original.sources?.carto) {
            throw new Error('지원하는 CARTO 지도 스타일 형식이 아닙니다.');
        }
        const style = JSON.parse(JSON.stringify(original));
        style.name = 'BinGo Map — Simple';

        for (const layer of style.layers) {
            const sourceLayer = layer['source-layer'];
            layer.layout = layer.layout || {};
            layer.paint = layer.paint || {};

            // 변경 1: 배경에 그려진 상점·관광시설·공원 이름·번지·작은 도로 이름을 숨깁니다.
            // 주요 지명, 큰 도로 이름, 강 이름만 남깁니다.
            if (layer.type === 'symbol') {
                const keepPlace = sourceLayer === 'place' && layer.id !== 'place_hamlet';
                const keepRoad = ['roadname_pri', 'roadname_sec', 'roadname_major'].includes(layer.id);
                const keepWater = ['water_name', 'waterway'].includes(sourceLayer);
                layer.layout.visibility = keepPlace || keepRoad || keepWater ? 'visible' : 'none';

                if (keepPlace || keepRoad || keepWater) {
                    layer.layout['text-field'] = NAME;
                    layer.layout['text-allow-overlap'] = false;
                    layer.layout['text-ignore-placement'] = false;
                    layer.paint['text-halo-color'] = '#ffffff';
                    layer.paint['text-halo-width'] = 1.5;
                    if (keepPlace) {
                        delete layer.layout['icon-image'];
                        layer.paint['text-color'] = '#586574';
                        // 동네 이름이 확대 직후 사라지지 않도록 유지합니다.
                        if (layer.id === 'place_suburbs') layer.maxzoom = 24;
                    }
                    if (keepRoad) {
                        layer.minzoom = Math.max(layer.minzoom || 0, 14);
                        layer.layout['symbol-spacing'] = 400;
                        layer.paint['text-color'] = '#7c8791';
                    }
                    if (keepWater) layer.paint['text-color'] = '#428ab1';
                }
            }

            // 변경 2: 참고 이미지와 비슷한 옅은 건물과 파란 강을 만듭니다.
            if (layer.type === 'background') layer.paint['background-color'] = '#f8f7f3';
            if (layer.id === 'water') layer.paint['fill-color'] = '#b8e2f2';
            if (layer.id === 'waterway') layer.paint['line-color'] = '#a8d9ee';
            if (sourceLayer === 'building' && layer.type === 'fill') {
                layer.paint['fill-color'] = '#eeeae2';
                layer.paint['fill-outline-color'] = '#e5e0d7';
                layer.paint['fill-translate'] = [0, 0];
            }
        }

        // 변경 3: 시설 라벨을 숨겨도 철도·지하철역은 별도 레이어로 표시합니다.
        // 역 출입구나 정류장 전체가 아니라 station/subway/halt로 분류된 점을 찾습니다.
        const stationFilter = ['all',
            ['==', '$type', 'Point'],
            ['==', 'class', 'railway'],
            ['in', 'subclass', 'station', 'subway', 'halt']
        ];
        const font = original.layers.find(layer => layer.id === 'place_suburbs')
            ?.layout?.['text-font'] || ['Noto Sans Regular'];

        // 도톤보리 테스트 지역에서 방향을 잡는 데 필요한 동네 이름만 선택합니다.
        // 실제 지도 데이터의 이름을 기준으로 거르며 좌표를 임의로 만들지 않습니다.
        style.layers.push({
            id: 'bingo-district-name', type: 'symbol', source: 'carto', 'source-layer': 'place',
            minzoom: 13,
            filter: ['in', 'name', '道頓堀一丁目', '道頓堀二丁目', '難波一丁目', '心斎橋筋一丁目', '日本橋一丁目'],
            layout: { 'text-field': NAME, 'text-font': font, 'text-size': 12,
                'text-padding': 20, 'text-allow-overlap': false, 'text-ignore-placement': false },
            paint: { 'text-color': '#687581', 'text-halo-color': '#ffffff', 'text-halo-width': 2 }
        });

        style.layers.push({
            id: 'bingo-station-dot', type: 'circle', source: 'carto', 'source-layer': 'poi',
            minzoom: 12, filter: stationFilter,
            paint: { 'circle-radius': 3.5, 'circle-color': '#4685c7',
                'circle-stroke-color': '#ffffff', 'circle-stroke-width': 1.5 }
        });
        style.layers.push({
            id: 'bingo-station-name', type: 'symbol', source: 'carto', 'source-layer': 'poi',
            minzoom: 12, filter: stationFilter,
            layout: { 'text-field': NAME, 'text-font': font,
                'text-size': ['interpolate', ['linear'], ['zoom'], 12, 11, 16, 13],
                'text-anchor': 'top', 'text-offset': [0, 0.65], 'text-padding': 8,
                'text-allow-overlap': false, 'text-ignore-placement': false },
            paint: { 'text-color': '#376899', 'text-halo-color': '#ffffff', 'text-halo-width': 2 }
        });
        return style;
    }

    async function addTo(map, options = {}) {
        const container = map.getContainer();
        // 이전 CSS의 회색 필터가 새 배경의 파란 강까지 흐리게 만들지 않게 합니다.
        container.classList.add('bingo-vector-map');
        if (!map.attributionControl) L.control.attribution().addTo(map);
        map.attributionControl.addAttribution(ATTRIBUTION);

        const status = L.DomUtil.create('div', 'bingo-basemap-status', container);
        status.setAttribute('role', 'status');
        status.textContent = '배경 지도를 불러오는 중…';
        const abortController = new AbortController();
        const timeout = setTimeout(() => abortController.abort(), 20000);

        // CARTO 키를 발급받았다면 addTo(map, { apiKey: '발급받은 키' })로 설정할 수 있습니다.
        // 키는 CARTO 도메인 요청에만 전달합니다.
        function withKey(url) {
            const parsed = new URL(url);
            if (options.apiKey && (parsed.hostname === 'basemaps.cartocdn.com' ||
                parsed.hostname.endsWith('.basemaps.cartocdn.com'))) {
                parsed.searchParams.set('key', options.apiKey);
            }
            return parsed.href;
        }

        try {
            if (!window.maplibregl || typeof L.maplibreGL !== 'function') {
                throw new Error('MapLibre 또는 Leaflet 어댑터를 불러오지 못했습니다. script 순서를 확인하세요.');
            }
            const response = await fetch(withKey(STYLE_URL), { signal: abortController.signal });
            if (!response.ok) throw new Error('지도 스타일 HTTP ' + response.status);
            const style = createStyle(await response.json());

            const layer = L.maplibreGL({
                style: style,
                interactive: false,
                attribution: ATTRIBUTION,
                transformRequest: url => ({ url: withKey(url) })
            }).addTo(map);
            const glMap = layer.getMaplibreMap();
            glMap.once('load', () => { status.remove(); });
            glMap.on('error', event => {
                console.error('배경 지도 로딩 오류:', event.error);
                if (status.isConnected) status.textContent = '배경 지도를 불러오지 못했어요. 잠시 후 새로고침해 주세요.';
            });
            return layer;
        } catch (error) {
            console.error('배경 지도 초기화 실패:', error);
            status.textContent = '배경 지도를 불러오지 못했어요. 잠시 후 새로고침해 주세요.';
            // 배경 요청의 실패가 쓰레기통 조회 코드까지 멈추게 하지 않습니다.
            return null;
        } finally {
            clearTimeout(timeout);
        }
    }

    window.BinGoBasemap = Object.freeze({ addTo: addTo, createStyle: createStyle });
})();
