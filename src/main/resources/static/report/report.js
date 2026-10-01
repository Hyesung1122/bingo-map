document.addEventListener("DOMContentLoaded", function () {

    const latInput = document.getElementById("report-lat");
    const lonInput = document.getElementById("report-lon");
    const categorySelect = document.getElementById("report-category");
    const nameInput = document.getElementById("report-name");
    const addressInput = document.getElementById("report-address");
    const descriptionInput = document.getElementById("report-description");
    const errorEl = document.getElementById("report-form-error");
    const successEl = document.getElementById("report-form-success");
    const locationHint = document.getElementById("report-location-hint");

    // 현재 위치 사용
    document.getElementById("report-use-location").addEventListener("click", function () {
        if (!navigator.geolocation) {
            locationHint.textContent = "이 브라우저는 위치 정보 기능을 지원하지 않습니다.";
            return;
        }
        locationHint.textContent = "위치 확인 중...";
        navigator.geolocation.getCurrentPosition(
            function (pos) {
                latInput.value = pos.coords.latitude.toFixed(7);
                lonInput.value = pos.coords.longitude.toFixed(7);
                locationHint.textContent = "현재 위치를 불러왔습니다.";
            },
            function () {
                locationHint.textContent = "위치 권한이 거부되었거나 확인할 수 없습니다. 직접 입력해주세요.";
            }
        );
    });

    // 제보 제출
    document.getElementById("report-submit-btn").addEventListener("click", function () {
        errorEl.textContent = "";
        successEl.textContent = "";

        const lat = parseFloat(latInput.value);
        const lon = parseFloat(lonInput.value);
        if (isNaN(lat) || isNaN(lon)) {
            errorEl.textContent = "위도/경도를 입력하거나 현재 위치 사용 버튼을 눌러주세요.";
            return;
        }

        const payload = {
            latitude: lat,
            longitude: lon,
            category: categorySelect.value,
            name: nameInput.value.trim() || null,
            address: addressInput.value.trim() || null,
            description: descriptionInput.value.trim() || null,
        };

        fetch("/api/reports", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
        })
            .then(async (res) => {
                const data = await res.json();
                if (!res.ok) {
                    errorEl.textContent = data.message || "제보 접수에 실패했습니다.";
                    return;
                }
                successEl.textContent = data.status === "APPROVED"
                    ? "제보가 지도에 바로 반영되었습니다. (관리자 제보)"
                    : "제보가 접수되었습니다. 관리자 검수 후 반영됩니다.";
                nameInput.value = "";
                addressInput.value = "";
                descriptionInput.value = "";
                loadMyReports();
            })
            .catch(() => {
                errorEl.textContent = "제보 접수 중 오류가 발생했습니다.";
            });
    });

    // 내가 제출한 제보 목록
    const statusLabel = { PENDING: "보류중", APPROVED: "승인됨", REJECTED: "반려됨" };
    const statusClass = { PENDING: "pending", APPROVED: "approved", REJECTED: "rejected" };
    const categoryLabel = { general: "일반", recycle: "재활용", can: "캔/병" };

    function reportCardHtml(r) {
        const rejectHtml = r.status === "REJECTED" && r.rejectReason
            ? '<p class="report-reject-reason">반려 사유: ' + r.rejectReason + "</p>"
            : "";
        return (
            '<div class="report-card">' +
            '<div class="report-card-body">' +
            "<b>" + (r.name || (categoryLabel[r.category] || r.category) + " 쓰레기통") + "</b>" +
            '<p>' + (r.address || (r.latitude.toFixed(5) + ", " + r.longitude.toFixed(5))) + "</p>" +
            '<span class="report-card-meta">' + r.createdAt + "</span>" +
            rejectHtml +
            "</div>" +
            '<span class="report-status-badge ' + statusClass[r.status] + '">' + statusLabel[r.status] + "</span>" +
            "</div>"
        );
    }

    function loadMyReports() {
        fetch("/api/reports/mine")
            .then((res) => (res.ok ? res.json() : []))
            .then((list) => {
                const el = document.getElementById("report-list");
                if (!list.length) {
                    el.innerHTML = '<p class="mypage-empty">아직 제출한 제보가 없습니다.</p>';
                    return;
                }
                el.innerHTML = list.map(reportCardHtml).join("");
            })
            .catch(() => {});
    }

    loadMyReports();
});