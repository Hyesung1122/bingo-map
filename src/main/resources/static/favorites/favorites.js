(function () {
    'use strict';

    const list = document.getElementById('favoritesList');
    const state = document.getElementById('favoritesState');
    const count = document.getElementById('favoritesCount');
    const retry = document.getElementById('retryFavorites');
    let favorites = [];

    function escapeHtml(value) {
        return String(value ?? '').replace(/[&<>"']/g, character => ({
            '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
        }[character]));
    }

    function login() {
        window.location.replace('/login?returnUrl=%2Ffavorites');
    }

    function dateLabel(value) {
        if (!value) return '저장 날짜 정보 없음';
        const date = new Date(value);
        if (Number.isNaN(date.getTime())) return '저장 날짜 정보 없음';
        return '저장일 ' + new Intl.DateTimeFormat('ko-KR', {
            year: 'numeric', month: 'long', day: 'numeric'
        }).format(date);
    }

    function cardHtml(item) {
        const restaurant = item.targetType === 'RESTAURANT';
        const name = item.targetName || (restaurant ? '이름 없는 맛집' : '쓰레기통');
        const openUrl = restaurant
            ? '/restaurants/detail?id=' + encodeURIComponent(item.targetId)
            : '/map';

        return `
            <article class="favorite-card" data-favorite-id="${escapeHtml(item.id)}">
                <div class="favorite-card-icon" aria-hidden="true">${restaurant ? '🍽️' : '🗑️'}</div>
                <div class="favorite-card-main">
                    <span class="favorite-type">${restaurant ? '맛집' : '쓰레기통'}</span>
                    <a class="favorite-name" href="${openUrl}">${escapeHtml(name)}</a>
                    <p class="favorite-location">${escapeHtml(item.location || '위치 정보 없음')}</p>
                    <p class="favorite-date">${escapeHtml(dateLabel(item.createdAt))}</p>
                </div>
                <div class="favorite-card-actions">
                    <a class="favorite-open" href="${openUrl}">${restaurant ? '상세 보기' : '지도 보기'} →</a>
                    <button class="favorite-remove" type="button" data-remove-id="${escapeHtml(item.id)}">삭제</button>
                </div>
            </article>`;
    }

    function showMessage(html, isError) {
        state.hidden = false;
        state.classList.toggle('is-error', Boolean(isError));
        state.innerHTML = html;
        list.hidden = true;
    }

    function render() {
        count.textContent = favorites.length + '개 저장됨';
        retry.hidden = true;

        if (!favorites.length) {
            showMessage('<div><strong>아직 저장한 항목이 없어요.</strong><br>맛집 상세 화면에서 하트를 눌러 즐겨찾기에 저장해보세요.<br><a href="/restaurants">주변 맛집 둘러보기 →</a></div>', false);
            return;
        }

        state.hidden = true;
        list.hidden = false;
        list.innerHTML = favorites.map(cardHtml).join('');
    }

    async function loadFavorites() {
        count.textContent = '불러오는 중';
        retry.hidden = true;
        showMessage('즐겨찾기를 불러오는 중입니다.', false);

        try {
            const response = await fetch('/api/favorites', {
                headers: { Accept: 'application/json' },
                credentials: 'same-origin',
                cache: 'no-store'
            });

            if (response.status === 401) {
                login();
                return;
            }
            if (!response.ok) throw new Error('HTTP ' + response.status);

            favorites = await response.json();
            render();
        } catch (error) {
            count.textContent = '불러오기 실패';
            showMessage('즐겨찾기를 불러오지 못했어요. 잠시 후 다시 시도해주세요.', true);
            retry.hidden = false;
        }
    }

    list.addEventListener('click', async event => {
        const button = event.target.closest('[data-remove-id]');
        if (!button) return;

        const favoriteId = button.dataset.removeId;
        button.disabled = true;

        try {
            const response = await fetch('/api/favorites/' + encodeURIComponent(favoriteId), {
                method: 'DELETE',
                credentials: 'same-origin'
            });
            if (response.status === 401) {
                login();
                return;
            }
            if (!response.ok && response.status !== 204) {
                throw new Error('HTTP ' + response.status);
            }
            favorites = favorites.filter(item => String(item.id) !== String(favoriteId));
            render();
        } catch (error) {
            button.disabled = false;
            state.hidden = false;
            state.classList.add('is-error');
            state.textContent = '삭제하지 못했어요. 다시 시도해주세요.';
        }
    });

    retry.addEventListener('click', loadFavorites);
    loadFavorites();
})();
