document.addEventListener("DOMContentLoaded", function () {
    const listEl = document.getElementById("notice-list");
    const emptyEl = document.getElementById("notice-empty");

    fetch("/api/notices")
        .then((res) => res.json())
        .then((list) => {
            emptyEl.hidden = list.length > 0;
            list.forEach((n) => {
                const item = document.createElement("div");
                item.className = "notice-item";
                item.innerHTML = `
                    <div class="notice-item-head">
                        <span class="notice-item-title">${escapeHtml(n.title)}</span>
                        <span class="notice-item-date">${n.createdAt}</span>
                    </div>
                    <div class="notice-item-body">${escapeHtml(n.content)}</div>
                `;
                item.querySelector(".notice-item-head").addEventListener("click", function () {
                    item.classList.toggle("open");
                });
                listEl.appendChild(item);
            });
        })
        .catch(() => {
            emptyEl.hidden = false;
            emptyEl.textContent = "공지사항을 불러오지 못했습니다.";
        });

    function escapeHtml(str) {
        const div = document.createElement("div");
        div.textContent = str ?? "";
        return div.innerHTML;
    }
});