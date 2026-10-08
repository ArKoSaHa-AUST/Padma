/**
 * Padma - Core SPA Application Router & Global UI Controller
 */

let activeScreen = 'home';
let toastTimer = null;

// Screen Switching Router
function switchScreen(screenId) {
  document.querySelectorAll('.screen-view').forEach(el => {
    el.classList.remove('active');
  });

  const target = document.getElementById(`screen-${screenId}`);
  if (target) {
    target.classList.add('active');
    activeScreen = screenId;
    window.scrollTo(0, 0);
  }

  // Update Header & Nav visibility for Auth screen
  const globalHeader = document.getElementById('global-header');
  const bottomNav = document.getElementById('global-bottom-nav');
  if (screenId === 'signin') {
    if (globalHeader) globalHeader.classList.add('hidden');
    if (bottomNav) bottomNav.classList.add('hidden');
  } else {
    if (globalHeader) globalHeader.classList.remove('hidden');
    if (bottomNav) bottomNav.classList.remove('hidden');
  }

  // Update active nav button
  document.querySelectorAll('.nav-item').forEach(btn => {
    btn.className = 'nav-item flex flex-col items-center justify-center gap-1 w-16 h-12 rounded-xl text-text-muted hover:text-text-primary transition-all';
  });
  const activeNav = document.getElementById(`nav-btn-${screenId}`);
  if (activeNav) {
    activeNav.className = 'nav-item flex flex-col items-center justify-center gap-1 w-16 h-12 rounded-xl transition-all bg-primary-container/20 text-primary font-semibold';
  }
}

// Discord Navigation Drawer Controls
function openDrawer() {
  const overlay = document.getElementById('drawer-overlay');
  const panel = document.getElementById('drawer-panel');
  if (overlay && panel) {
    overlay.classList.remove('pointer-events-none', 'opacity-0');
    overlay.classList.add('opacity-100');
    panel.classList.remove('-translate-x-full');
    panel.classList.add('translate-x-0');
  }
}

function closeDrawer() {
  const overlay = document.getElementById('drawer-overlay');
  const panel = document.getElementById('drawer-panel');
  if (overlay && panel) {
    overlay.classList.remove('opacity-100');
    overlay.classList.add('opacity-0', 'pointer-events-none');
    panel.classList.remove('translate-x-0');
    panel.classList.add('-translate-x-full');
  }
}

function navigateToChannel(channelKey) {
  closeDrawer();
  if (channelKey === 'general') {
    switchScreen('general-chat');
  } else if (channelKey === 'requests') {
    switchScreen('requests');
  } else if (channelKey === 'bus-1-mirpur') {
    switchScreen('bus-channel');
  } else if (channelKey === 'announcements') {
    switchScreen('home');
    showAppToast('Viewing Announcements');
  } else {
    switchScreen('home');
  }
}

// Toast Alert System
function showAppToast(message, isUrgent = false) {
  const toast = document.getElementById('app-toast');
  const toastMsg = document.getElementById('app-toast-msg');
  const toastIcon = document.getElementById('app-toast-icon');

  if (!toast || !toastMsg) return;

  if (toastTimer) clearTimeout(toastTimer);

  toastMsg.textContent = message;
  if (toastIcon) {
    toastIcon.className = 'material-symbols-outlined text-[20px] ' + (isUrgent ? 'text-urgent' : 'text-primary');
  }
  
  toast.classList.remove('translate-y-12', 'opacity-0', 'pointer-events-none');
  toast.classList.add('translate-y-0', 'opacity-100');

  toastTimer = setTimeout(() => {
    toast.classList.remove('translate-y-0', 'opacity-100');
    toast.classList.add('translate-y-12', 'opacity-0', 'pointer-events-none');
  }, 2600);
}

function markAllNotificationsRead() {
  const badge = document.getElementById('notif-badge');
  if (badge) badge.remove();
  showAppToast('All alerts marked as read');
}

// Global Event Listeners
document.addEventListener('DOMContentLoaded', () => {
  const drawerBtn = document.getElementById('open-drawer-btn');
  if (drawerBtn) {
    drawerBtn.addEventListener('click', openDrawer);
  }
});
