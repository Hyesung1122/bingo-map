(function (global) {
    'use strict';

    const spots = global.BinGoSpots;

    async function getJson(url) {
        const controller = new AbortController();
        const timeout = global.setTimeout(() => controller.abort(), 12000);
        try {
            const response = await fetch(url, {
                headers: { Accept: 'application/json' },
                credentials: 'same-origin',
                cache: 'no-store',
                signal: controller.signal
            });
            if (!response.ok) throw new Error('요청 실패: ' + response.status);
            return await response.json();
        } finally {
            global.clearTimeout(timeout);
        }
    }

    async function restaurants() {
        const result = await getJson('/api/map/restaurants');
        if (!result || !Array.isArray(result.places)) {
            throw new Error(result?.message || '식당 목록 응답 형식이 올바르지 않습니다.');
        }
        return result.places;
    }

    async function summaries() {
        const result = await getJson('/api/reviews/restaurants');
        if (!Array.isArray(result)) throw new Error('리뷰 요약 응답 형식이 올바르지 않습니다.');
        return new Map(result.map(item => [String(item.restaurantId), item]));
    }

    function escape(value) {
        return String(value ?? '').replace(/[&<>"']/g, character => ({
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#39;'
        })[character]);
    }

    function distance(origin, place) {
        if (!spots || !origin || !place) return null;
        const meters = spots.distance(origin, { lat: place.lat, lon: place.lon });
        return Number.isFinite(meters) ? meters : null;
    }

    function photo(value) {
        if (!value) return '';
        const url = String(value).trim();
        if (/^(https?:\/\/|\/)/i.test(url) && !/^\/\//.test(url)) return url;
        return '';
    }

    function stars(value) {
        const rating = Math.max(0, Math.min(5, Number(value) || 0));
        const full = Math.floor(rating + 0.25);
        return '★'.repeat(full) + '☆'.repeat(5 - full);
    }

    function stats(summary, ready) {
        if (!ready) return '리뷰 집계 확인 불가';
        const count = Number(summary?.reviewCount) || 0;
        if (!count) return '아직 리뷰가 없습니다.';
        return `${(Number(summary.avgRating) || 0).toFixed(1)}점 · 리뷰 ${count}개`;
    }

    function watch(callback) {
        let lastRun = 0;
        const refresh = () => {
            const now = Date.now();
            if (document.visibilityState === 'visible' && now - lastRun > 5000) {
                lastRun = now;
                callback();
            }
        };
        global.addEventListener('focus', refresh);
        document.addEventListener('visibilitychange', refresh);
    }

    global.BinGoReviews = Object.freeze({
        restaurants,
        summaries,
        escape,
        distance,
        photo,
        stars,
        stats,
        watch
    });
})(window);
