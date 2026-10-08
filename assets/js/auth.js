/**
 * Padma - Authentication Module
 * Handles Login, Registration, Password Visibility, Blood Group Selection & Session
 */

function toggleAuthForm(mode) {
  const signinBox = document.getElementById('signin-box');
  const signupBox = document.getElementById('signup-box');
  const tabIn = document.getElementById('auth-tab-signin');
  const tabUp = document.getElementById('auth-tab-signup');

  if (!signinBox || !signupBox) return;

  if (mode === 'signin') {
    signinBox.classList.remove('hidden');
    signupBox.classList.add('hidden');
    if (tabIn && tabUp) {
      tabIn.className = 'flex-1 py-1.5 rounded-full text-center font-label-button text-[13px] bg-surface-elevated text-primary font-semibold shadow transition-all';
      tabUp.className = 'flex-1 py-1.5 rounded-full text-center font-label-button text-[13px] text-text-muted font-medium transition-all';
    }
  } else {
    signinBox.classList.add('hidden');
    signupBox.classList.remove('hidden');
    if (tabIn && tabUp) {
      tabUp.className = 'flex-1 py-1.5 rounded-full text-center font-label-button text-[13px] bg-surface-elevated text-primary font-semibold shadow transition-all';
      tabIn.className = 'flex-1 py-1.5 rounded-full text-center font-label-button text-[13px] text-text-muted font-medium transition-all';
    }
  }
}

function togglePasswordVisibility(inputId, triggerBtn) {
  const pwdInput = document.getElementById(inputId);
  if (!pwdInput) return;
  
  if (pwdInput.type === 'password') {
    pwdInput.type = 'text';
    if (triggerBtn) {
      const icon = triggerBtn.querySelector('.material-symbols-outlined');
      if (icon) icon.textContent = 'visibility_off';
    }
  } else {
    pwdInput.type = 'password';
    if (triggerBtn) {
      const icon = triggerBtn.querySelector('.material-symbols-outlined');
      if (icon) icon.textContent = 'visibility';
    }
  }
}

function selectSignUpBlood(btn, group) {
  const container = document.getElementById('signup-blood-chips');
  if (container) {
    container.querySelectorAll('button').forEach(b => {
      b.className = 'py-1 bg-surface-highest rounded-lg text-xs font-semibold text-text-secondary';
    });
  }
  btn.className = 'py-1 bg-primary-container text-on-primary-container rounded-lg text-xs font-semibold shadow';
}

function handleAuthLogin() {
  if (window.showAppToast) {
    window.showAppToast('Welcome back to Padma Transit!');
  }
  setTimeout(() => {
    if (window.switchScreen) window.switchScreen('home');
  }, 400);
}

function handleAuthRegister() {
  if (window.showAppToast) {
    window.showAppToast('Account registered successfully! AUST badge issued.');
  }
  setTimeout(() => {
    if (window.switchScreen) window.switchScreen('home');
  }, 400);
}

function continueAsGuest() {
  if (window.showAppToast) {
    window.showAppToast('Switched to Guest Telemetry Mode');
  }
  if (window.switchScreen) window.switchScreen('home');
}
