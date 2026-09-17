document.addEventListener("DOMContentLoaded", function () {
    let verifiedEmail = null;
    let verifiedAnswer = null;

    const stepEmail = document.getElementById("step-email");
    const stepVerify = document.getElementById("step-verify");
    const stepReset = document.getElementById("step-reset");
    const stepDone = document.getElementById("step-done");
    const emailError = document.getElementById("email-error");
    const verifyError = document.getElementById("verify-error");
    const resetError = document.getElementById("reset-error");

    // 1단계: 이메일 -> 본인확인 질문 불러오기
    document.getElementById("find-question-btn").addEventListener("click", function () {
        const email = document.getElementById("reset-email").value.trim();
        emailError.textContent = "";

        if (!email) {
            emailError.textContent = "이메일을 입력해주세요.";
            return;
        }

        fetch("/api/password-reset/question", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email }),
        })
            .then(async (res) => {
                const data = await res.json();
                if (!res.ok) {
                    emailError.textContent = data.message || "계정을 찾을 수 없습니다.";
                    return;
                }
                verifiedEmail = email;
                document.getElementById("question-text").textContent = data.question;
                stepEmail.hidden = true;
                stepVerify.hidden = false;
            })
            .catch(() => {
                emailError.textContent = "확인 중 오류가 발생했습니다. 다시 시도해주세요.";
            });
    });

    // 2단계: 답변 확인
    document.getElementById("verify-btn").addEventListener("click", function () {
        const answer = document.getElementById("reset-answer").value.trim();
        verifyError.textContent = "";

        if (!answer) {
            verifyError.textContent = "답변을 입력해주세요.";
            return;
        }

        fetch("/api/password-reset/verify", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email: verifiedEmail, answer }),
        })
            .then(async (res) => {
                const data = await res.json();
                if (!res.ok) {
                    verifyError.textContent = data.message || "답변이 일치하지 않습니다.";
                    return;
                }
                verifiedAnswer = answer;
                stepVerify.hidden = true;
                stepReset.hidden = false;
            })
            .catch(() => {
                verifyError.textContent = "확인 중 오류가 발생했습니다. 다시 시도해주세요.";
            });
    });

    // 3단계: 새 비밀번호로 변경
    document.getElementById("reset-btn").addEventListener("click", function () {
        const newPassword = document.getElementById("new-password").value;
        const newPasswordConfirm = document.getElementById("new-password-confirm").value;
        resetError.textContent = "";

        fetch("/api/password-reset/reset", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                email: verifiedEmail,
                answer: verifiedAnswer,
                newPassword,
                newPasswordConfirm,
            }),
        })
            .then(async (res) => {
                const data = await res.json();
                if (!res.ok) {
                    resetError.textContent = data.message || "비밀번호 변경에 실패했습니다.";
                    return;
                }
                stepReset.hidden = true;
                stepDone.hidden = false;
            })
            .catch(() => {
                resetError.textContent = "변경 중 오류가 발생했습니다. 다시 시도해주세요.";
            });
    });
});