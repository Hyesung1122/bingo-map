/* 주변 맛집: 지도와 같은 공개 식당 목록 + 공통 스팟 좌표를 사용합니다. */
(function () {
    'use strict';

    const PAGE_SIZE = 10;
    const API_URL = '/api/map/restaurants';
    const SPOT_STORAGE_KEY = 'bingo.origin.spot.v1';

    const CATEGORIES = {
        '타코야끼': ['타코야끼', '타코야키', 'takoyaki'],
        '야끼소바': ['야끼소바', '야키소바', 'yakisoba'],
        '오코노미야끼': ['오코노미야끼', '오코노미야키', 'okonomiyaki'],
        '붕어빵': ['붕어빵', '타이야키', '타이야끼', 'taiyaki'],
        '야키니쿠': ['야키니쿠', '야끼니꾸', '야끼니쿠', 'yakiniku']
    };

    const $ = id => document.getElementById(id);

    let allItems = [];
    let filteredItems = [];
    let currentPage = 0;

    let state = 'loading';
    let failureMessage = '';
    let requestNumber = 0;

    function escapeHtml(value) {
        return String(value ?? '').replace(
            /[&<>"']/g,
            c => ({
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#39;'
            }[c])
        );
    }

    function realNumber(value) {
        return typeof value === 'number' && Number.isFinite(value)
            ? value
            : null;
    }

    function ratingOf(item) {
        const n = realNumber(item.rating);

        return n !== null && n >= 0 && n <= 5
            ? n
            : null;
    }

    function countOf(item) {
        const n = realNumber(item.reviewCount);

        return n !== null && n >= 0
            ? n
            : null;
    }

    function currentSpot() {
        return window.BinGoSpots.find(
            $('regionSelect').value
        ) || window.BinGoSpots.find('dotonbori');
    }

    function categoryMatches(selected, category) {

        if (selected === '전체') {
            return true;
        }

        const terms = String(category || '')
            .toLowerCase()
            .split(/[,;/|]/)
            .map(s => s.trim());

        const matches = name =>
            CATEGORIES[name].some(alias =>
                terms.includes(alias)
            );

        return selected === '기타'
            ? !Object.keys(CATEGORIES).some(matches)
            : matches(selected);
    }

    function safeImage(value) {

        if (
            typeof value !== 'string' ||
            !value.trim()
        ) {
            return null;
        }

        try {

            // 공백/한글 파일명도 브라우저가 URL로 인코딩하도록 허용합니다.
            const url = new URL(
                value.trim(),
                window.location.origin
            );

            return ['http:', 'https:'].includes(
                url.protocol
            )
                ? url.href
                : null;

        } catch (_) {

            return null;
        }
    }

    function cardHtml(item) {

        const rating = ratingOf(item);
        const count = countOf(item);
        const image = safeImage(
            item.mainImageUrl
        );

        const distance =
            window.BinGoSpots.formatDistance(
                item._distance
            );

        const detailUrl =
            '/restaurants/detail?id=' +
            encodeURIComponent(item._id);

        return `
            <a
                class="restaurant-list-card"
                href="${detailUrl}"
                data-restaurant-id="${escapeHtml(item._id)}"
            >

                <div class="card-photo">

                    <span class="photo-placeholder">
                        <span aria-hidden="true">▧</span>
                        사진 준비 중
                    </span>

                    ${
            image
                ? `
                                <img
                                    src="${escapeHtml(image)}"
                                    alt="${escapeHtml(
                    item.name || '식당'
                )} 사진"
                                    class="card-thumbnail"
                                    loading="lazy"
                                >
                              `
                : ''
        }

                </div>

                <div class="card-content">

                    <div class="card-title-row">

                        <div>

                            <span class="tag-pill">
                                ${escapeHtml(
            item.category || '분류 없음'
        )}
                            </span>

                            <h3 class="restaurant-name">
                                ${escapeHtml(
            item.name || '이름 정보 없음'
        )}
                            </h3>

                        </div>

                        <span class="restaurant-distance">
                            직선 ${distance}
                        </span>

                    </div>

                    <p class="restaurant-address">
                        ${escapeHtml(
            item.address || '주소 정보 없음'
        )}
                    </p>

                    ${
            item.description
                ? `
                                <p class="restaurant-description">
                                    ${escapeHtml(
                    item.description
                )}
                                </p>
                              `
                : ''
        }

                    <div class="card-meta">

                        <span class="card-rating">

                            <span aria-hidden="true">
                                ★
                            </span>

                            ${
            rating === null
                ? '평점 없음'
                : rating.toFixed(1)
        }

                            <span class="review-count">
                                ${
            count === null
                ? '리뷰 수 미등록'
                : '리뷰 ' +
                count.toLocaleString('ko-KR') +
                '개'
        }
                            </span>

                        </span>

                        <span class="opening-hours">
                            ${escapeHtml(
            item.openingHours ||
            '영업시간 정보 없음'
        )}
                        </span>

                    </div>

                </div>

            </a>
        `;
    }

    function renderPagination() {

        const count =
            Math.ceil(
                filteredItems.length /
                PAGE_SIZE
            );

        const list =
            $('paginationList');

        $('paginationNav').hidden =
            count <= 1;

        list.replaceChildren();

        if (count <= 1) {
            return;
        }

        // 전체 데이터가 늘어도 현재 페이지 주변만 표시합니다.
        const pages = new Set([
            0,
            count - 1
        ]);

        for (
            let p = Math.max(
                0,
                currentPage - 2
            );

            p <= Math.min(
                count - 1,
                currentPage + 2
            );

            p++
        ) {
            pages.add(p);
        }

        function button(
            label,
            page,
            disabled,
            selected = false
        ) {

            const li =
                document.createElement('li');

            li.className =
                'page-item' +
                (
                    selected
                        ? ' active'
                        : ''
                );

            const b =
                document.createElement('button');

            b.type = 'button';
            b.className = 'page-link';
            b.textContent = label;
            b.disabled = disabled;
            b.dataset.page = page;

            b.setAttribute(
                'aria-label',
                label === '이전' ||
                label === '다음'
                    ? label + ' 페이지'
                    : label + '페이지'
            );

            if (selected) {
                b.setAttribute(
                    'aria-current',
                    'page'
                );
            }

            li.append(b);
            list.append(li);
        }

        button(
            '이전',
            currentPage - 1,
            currentPage === 0
        );

        let previous = -1;

        [...pages]
            .sort((a, b) => a - b)
            .forEach(p => {

                if (p > previous + 1) {

                    const li =
                        document.createElement('li');

                    li.className =
                        'page-item disabled';

                    li.innerHTML =
                        '<span class="page-link">…</span>';

                    list.append(li);
                }

                button(
                    String(p + 1),
                    p,
                    false,
                    p === currentPage
                );

                previous = p;
            });

        button(
            '다음',
            currentPage + 1,
            currentPage === count - 1
        );
    }

    function renderPage() {

        const container =
            $('restaurantListContainer');

        const ready =
            state === 'ready';

        $('resultsCount').hidden =
            !ready;

        $('listState').hidden =
            ready && filteredItems.length > 0;

        $('listState').classList.toggle(
            'is-error',
            state === 'error'
        );

        $('listState').setAttribute(
            'role',
            state === 'error'
                ? 'alert'
                : 'status'
        );

        $('retryButton').hidden =
            state !== 'error';

        $('clearEmptyFilters').hidden =
            !(
                ready &&
                allItems.length > 0 &&
                filteredItems.length === 0
            );

        container.setAttribute(
            'aria-busy',
            String(state === 'loading')
        );

        container.replaceChildren();

        if (!ready) {

            $('listStateTitle').textContent =
                state === 'loading'
                    ? '공개 식당을 불러오는 중이에요'
                    : '식당 목록을 불러오지 못했어요';

            $('listStateMessage').textContent =
                state === 'loading'
                    ? '지도와 같은 식당 목록을 확인하고 있어요.'
                    : failureMessage;

            $('paginationNav').hidden = true;

            return;
        }

        $('sourceCount').textContent =
            allItems.length;

        $('totalCount').textContent =
            filteredItems.length;

        currentPage =
            Math.max(
                0,
                Math.min(
                    currentPage,
                    Math.max(
                        0,
                        Math.ceil(
                            filteredItems.length /
                            PAGE_SIZE
                        ) - 1
                    )
                )
            );

        if (!filteredItems.length) {

            $('listStateTitle').textContent =
                allItems.length
                    ? '선택한 조건에 맞는 식당이 없어요'
                    : '공개된 식당이 아직 없어요';

            $('listStateMessage').textContent =
                allItems.length
                    ? '반경을 넓히거나 평점·카테고리 조건을 바꿔보세요.'
                    : '지도에서 공개 식당이 조회되는지 확인해주세요.';

        } else {

            const start =
                currentPage * PAGE_SIZE;

            const end =
                (currentPage + 1) * PAGE_SIZE;

            container.innerHTML =
                filteredItems
                    .slice(start, end)
                    .map(cardHtml)
                    .join('');

            container
                .querySelectorAll('img')
                .forEach(img => {

                    const failed =
                        () => img.remove();

                    img.addEventListener(
                        'error',
                        failed,
                        { once: true }
                    );

                    if (
                        img.complete &&
                        img.naturalWidth === 0
                    ) {
                        failed();
                    }
                });
        }

        renderPagination();
    }

    function applyFilters() {

        if (!window.BinGoSpots) {
            return;
        }

        const spot =
            currentSpot();

        const category =
            document.querySelector(
                '#categoryFilterContainer .active'
            )?.dataset.category
            || '전체';

        const radius =
            $('allRadius').checked
                ? Infinity
                : Number(
                    $('radiusRange').value
                );

        const minRating =
            Number(
                document.querySelector(
                    'input[name="ratingFilter"]:checked'
                ).value
            );

        const sort =
            $('sortSelect').value;

        $('radiusText').textContent =
            Number.isFinite(radius)
                ? window.BinGoSpots.formatDistance(
                    radius
                )
                : '전체';

        $('radiusRange').setAttribute(
            'aria-valuetext',
            window.BinGoSpots.formatDistance(
                Number(
                    $('radiusRange').value
                )
            )
        );

        $('distanceBasis').textContent =
            spot.label +
            ' 기준 · 직선 거리';

        $('radiusHint').textContent =
            Number.isFinite(radius)

                ? '선택한 스팟에서 반경 ' +
                window.BinGoSpots.formatDistance(
                    radius
                ) +
                ' 이내'

                : '반경 제한 없이 전체 공개 식당을 표시해요.';

        filteredItems =
            allItems
                .map(item => ({
                    ...item,
                    _distance:
                        window.BinGoSpots.distance(
                            spot,
                            item
                        )
                }))
                .filter(item => {

                    return (
                        Number.isFinite(
                            item._distance
                        )

                        && item._distance <= radius

                        && categoryMatches(
                            category,
                            item.category
                        )

                        && (
                            minRating === 0

                            ||

                            (
                                ratingOf(item) !== null
                                &&
                                ratingOf(item) >= minRating
                            )
                        )
                    );
                });

        filteredItems.sort((a, b) => {

            let difference = 0;

            if (sort === 'rating') {

                difference =
                    (
                        ratingOf(b) ?? -1
                    )
                    -
                    (
                        ratingOf(a) ?? -1
                    );
            }

            if (sort === 'review') {

                difference =
                    (
                        countOf(b) ?? -1
                    )
                    -
                    (
                        countOf(a) ?? -1
                    );
            }

            return (
                difference
                ||
                a._distance - b._distance
                ||
                a._id.localeCompare(
                    b._id,
                    'en',
                    {
                        numeric: true
                    }
                )
            );
        });

        currentPage = 0;

        renderPage();
    }

    function resetFilter() {

        document
            .querySelectorAll(
                '#categoryFilterContainer button'
            )
            .forEach(button => {

                const active =
                    button.dataset.category === '전체';

                button.classList.toggle(
                    'active',
                    active
                );

                button.setAttribute(
                    'aria-pressed',
                    String(active)
                );
            });

        $('sortSelect').value =
            'distance';

        $('allRadius').checked =
            true;

        $('radiusRange').value =
            '2500';

        document
            .querySelector(
                'input[name="ratingFilter"][value="0"]'
            )
            .checked = true;

        applyFilters();
    }

    function rememberSpot() {

        const spot =
            currentSpot();

        const id =
            spot.id;

        try {

            sessionStorage.setItem(
                SPOT_STORAGE_KEY,
                id
            );

        } catch (_) {
            // 저장 차단 시에도 필터는 동작
        }

        const url =
            new URL(
                location.href
            );

        url.searchParams.set(
            'region',
            id
        );

        history.replaceState(
            null,
            '',
            url.pathname +
            url.search +
            url.hash
        );
    }

    async function load() {

        const mine =
            ++requestNumber;

        state = 'loading';
        failureMessage = '';

        $('sourceNote').hidden =
            true;

        renderPage();

        const controller =
            new AbortController();

        const timeout =
            setTimeout(
                () => controller.abort(),
                20000
            );

        try {

            const response =
                await fetch(
                    API_URL,
                    {
                        headers: {
                            Accept:
                                'application/json'
                        },
                        credentials:
                            'same-origin',
                        cache:
                            'no-store',
                        signal:
                        controller.signal
                    }
                );

            if (!response.ok) {

                throw new Error(
                    'HTTP ' +
                    response.status
                );
            }

            const data =
                await response.json();

            if (
                !data ||
                !Array.isArray(
                    data.places
                )
            ) {

                throw new Error(
                    '식당 응답 형식 오류'
                );
            }

            if (
                mine !== requestNumber
            ) {
                return;
            }

            const valid =
                item =>
                    item &&
                    realNumber(item.lat) !== null &&
                    realNumber(item.lon) !== null &&
                    Math.abs(item.lat) <= 90 &&
                    Math.abs(item.lon) <= 180 &&
                    /^\d+$/.test(
                        String(
                            item.restaurantId ??
                            item.id ??
                            ''
                        )
                    );

            allItems =
                data.places
                    .filter(valid)
                    .map(item => ({
                        ...item,
                        _id: String(
                            item.restaurantId ??
                            item.id
                        )
                    }));

            const invalid =
                (
                    Number.isInteger(
                        data.invalidCoordinateCount
                    )
                        ? data.invalidCoordinateCount
                        : 0
                )
                +
                (
                    data.places.length -
                    allItems.length
                );

            $('sourceNote').hidden =
                invalid === 0;

            $('sourceNote').textContent =
                '좌표 또는 식당 번호를 확인할 수 없는 ' +
                invalid +
                '곳은 목록에서 제외했어요.';

            state = 'ready';

            applyFilters();

        } catch (error) {

            if (
                mine !== requestNumber
            ) {
                return;
            }

            state = 'error';

            allItems = [];
            filteredItems = [];

            failureMessage =
                error.name === 'AbortError'

                    ? '응답 시간이 길어지고 있어요. 잠시 후 다시 시도해주세요.'

                    : '다시 시도해주세요. 계속 실패하면 지도 식당 조회와 서버 로그를 확인해주세요.';

            renderPage();

        } finally {

            clearTimeout(timeout);
        }
    }

    document.addEventListener(
        'DOMContentLoaded',
        () => {

            if (!window.BinGoSpots) {

                state = 'error';

                failureMessage =
                    '거리 기준 정보를 불러오지 못했어요. /map/bingo-spots.js 파일을 확인해주세요.';

                renderPage();

                $('retryButton').onclick =
                    () => location.reload();

                return;
            }

            let saved = null;

            try {

                saved =
                    sessionStorage.getItem(
                        SPOT_STORAGE_KEY
                    );

            } catch (_) {
                // 기본 스팟
            }

            const requested =
                new URLSearchParams(
                    location.search
                ).get('region');

            // 이전 URL도 새 스팟 선택으로 연결합니다.
            const aliases = {
                umeda: 'usj',
                shinsaibashi: 'castle'
            };

            const initial =
                window.BinGoSpots.find(
                    aliases[requested] ||
                    requested
                )
                ||
                window.BinGoSpots.find(
                    saved
                )
                ||
                window.BinGoSpots.find(
                    'dotonbori'
                );

            $('regionSelect').value =
                initial.id;

            rememberSpot();

            $('regionSelect')
                .addEventListener(
                    'change',
                    () => {
                        rememberSpot();
                        applyFilters();
                    }
                );

            $('sortSelect')
                .addEventListener(
                    'change',
                    applyFilters
                );

            $('radiusRange')
                .addEventListener(
                    'input',
                    () => {

                        $('allRadius').checked =
                            false;

                        applyFilters();
                    }
                );

            $('allRadius')
                .addEventListener(
                    'change',
                    applyFilters
                );

            document
                .querySelectorAll(
                    'input[name="ratingFilter"]'
                )
                .forEach(
                    input =>
                        input.addEventListener(
                            'change',
                            applyFilters
                        )
                );

            document
                .querySelectorAll(
                    '#categoryFilterContainer button'
                )
                .forEach(
                    button =>
                        button.addEventListener(
                            'click',
                            () => {

                                document
                                    .querySelectorAll(
                                        '#categoryFilterContainer button'
                                    )
                                    .forEach(
                                        other => {

                                            const active =
                                                other ===
                                                button;

                                            other.classList.toggle(
                                                'active',
                                                active
                                            );

                                            other.setAttribute(
                                                'aria-pressed',
                                                String(
                                                    active
                                                )
                                            );
                                        }
                                    );

                                applyFilters();
                            }
                        )
                );

            $('resetFilters')
                .addEventListener(
                    'click',
                    resetFilter
                );

            $('clearEmptyFilters')
                .addEventListener(
                    'click',
                    resetFilter
                );

            $('retryButton')
                .addEventListener(
                    'click',
                    load
                );

            $('refreshList')
                .addEventListener(
                    'click',
                    load
                );

            $('mapLink')
                .addEventListener(
                    'click',
                    rememberSpot
                );

            $('paginationList')
                .addEventListener(
                    'click',
                    event => {

                        const button =
                            event.target.closest(
                                'button[data-page]'
                            );

                        if (
                            !button ||
                            button.disabled
                        ) {
                            return;
                        }

                        currentPage =
                            Number(
                                button.dataset.page
                            );

                        renderPage();

                        $('resultsTop')
                            .scrollIntoView({
                                behavior:
                                    'smooth',
                                block:
                                    'start'
                            });
                    }
                );

            applyFilters();
            load();
        }
    );

})();