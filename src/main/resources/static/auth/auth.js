/**
 * signup.html, login.html 공용.
 * URL의 ?error=... 는 제출 버튼 바로 아래에 빨간 텍스트로 보여주고,
 * ?signup=success 는 제목 아래 초록 알림 박스로 보여준다.
 * 컨트롤러가 redirect:/signup?error=... , redirect:/login?signup=success 형태로 넘겨주는 값을 읽는다.
 */
document.addEventListener("DOMContentLoaded", function () {
    const params = new URLSearchParams(window.location.search);
    const error = params.get("error");
    const signup = params.get("signup");

    const card = document.querySelector(".auth-card");
    if (!card) return;

    if (error) {
        const submitBtn = card.querySelector(".auth-submit");
        if (submitBtn) {
            const errorText = document.createElement("p");
            errorText.className = "auth-error-text";
            errorText.textContent = error; // URLSearchParams가 이미 디코딩해줌
            submitBtn.after(errorText);
        }
    } else if (signup === "success") {
        const anchor = card.querySelector(".auth-sub") || card.querySelector("h2");
        if (anchor) {
            const box = document.createElement("div");
            box.className = "auth-alert auth-alert-success";
            box.textContent = "회원가입이 완료되었습니다. 로그인해주세요.";
            anchor.after(box);
        }
    }

    // 비밀번호 필드 옆 눈 모양 아이콘 -> 누르면 비밀번호 표시/숨김 전환
    card.querySelectorAll(".auth-field .icon-right").forEach((btn) => {
        const input = btn.previousElementSibling;
        if (!input || input.tagName !== "INPUT") return;

        btn.addEventListener("click", function () {
            const isHidden = input.type === "password";
            input.type = isHidden ? "text" : "password";
            btn.textContent = isHidden ? "🙈" : "👁";
            btn.setAttribute("aria-label", isHidden ? "비밀번호 숨기기" : "비밀번호 표시");
        });
    });
});