/**
 * Padma - Core SPA Application Router, Global UI Controller & Notification Dispatcher
 * Dynamic Supabase Integration with notifications and admin_announcements
 */

let activeScreen = 'signin';
let toastTimer = null;
const NOTIFICATIONS_DB_KEY = 'padma_notifications_db';

// Initial Notifications Seed for offline cache
function initializeNotificationsDatabase() {
  if (!localStorage.getItem(NOTIFICATIONS_DB_KEY)) {
    const initialNotifs = [
      {
        id: 'notif_1',
        type: 'destination',
        title: 'Padma 1 is almost reached to your destination',
        body: 'BRTC-2401 is 2 minutes away from Mirpur 10 roundabout. Please proceed to the boarding bay.',
        timestamp: Date.now() - 120000,
        isRead: false
      },
      {
        id: 'notif_2',
        type: 'journey',
        title: 'Padma 1 Started Journey',
        body: 'Padma 1 departed from Mirpur 12 terminal on schedule at 7:15 AM.',
        timestamp: Date.now() - 3600000,
        isRead: false
      },
      {
        id: 'notif_3',
        type: 'announcement',
        title: 'Midterm Examination Schedule Released',
        body: 'Supplementary feeder trips scheduled for both Padma 1 and Padma 2 from Gate 2.',
        timestamp: Date.now() - 7200000,
        isRead: false
      },
      {
        id: 'notif_4',
        type: 'rules',
        title: 'AUST Campus Transit Policy 2026 Updated',
        body: 'Mandatory digital ID verification and seat reservation policy announced in #rules-and-regulation.',
        timestamp: Date.now() - 10800000,
        isRead: true
      }
    ];
    localStorage.setItem(NOTIFICATIONS_DB_KEY, JSON.stringify(initialNotifs));
  }
}

initializeNotificationsDatabase();

function getNotifications() {
  return JSON.parse(localStorage.getItem(NOTIFICATIONS_DB_KEY) || '[]');
}

function saveNotifications(list) {
  localStorage.setItem(NOTIFICATIONS_DB_KEY, JSON.stringify(list));
  updateNotificationBadge();
}

// Sync notifications from Supabase
async function syncNotificationsFromSupabase() {
  if (typeof SupabaseDb !== 'undefined') {
    try {
      const data = await SupabaseDb.fetchNotifications();
      if (data && Array.isArray(data) && data.length > 0) {
        const mapped = data.map(n => ({
          id: n.id,
          type: n.type || 'transit',
          title: n.title,
          body: n.body,
          timestamp: new Date(n.created_at).getTime(),
          isRead: n.is_read || false
        }));
        localStorage.setItem(NOTIFICATIONS_DB_KEY, JSON.stringify(mapped));
        updateNotificationBadge();
      }
    } catch (e) {
      console.warn('Sync notifications warning:', e);
    }
  }
}

// Global Notification Dispatchers
window.dispatchMentionNotification = async function(targetTag, channel, messageText, senderTag) {
  const currentUser = getCurrentUser();
  const notifs = getNotifications();

  const isMatch = currentUser && (
    currentUser.chatTag.toLowerCase().includes(targetTag.toLowerCase()) ||
    targetTag.toLowerCase().includes(currentUser.name.split(' ')[0].toLowerCase())
  );

  if (isMatch) {
    const notifId = 'notif_mention_' + Date.now();
    const newNotif = {
      id: notifId,
      type: 'mention',
      title: `You were mentioned in #${channel}`,
      body: `@${senderTag}: "${messageText}"`,
      timestamp: Date.now(),
      isRead: false
    };
    notifs.unshift(newNotif);
    saveNotifications(notifs);

    if (typeof SupabaseDb !== 'undefined') {
      try {
        await SupabaseDb.postNotification({
          id: notifId,
          user_id: currentUser.id,
          title: newNotif.title,
          body: newNotif.body,
          type: 'mention',
          is_read: false
        });
      } catch (e) {
        console.warn('Post notification warning:', e);
      }
    }

    if (window.showAppToast) {
      window.showAppToast(`You were mentioned in #${channel} by @${senderTag}`);
    }
  }
};

window.dispatchGlobalAnnouncementNotification = async function(text, adminName) {
  const notifs = getNotifications();
  const notifId = 'notif_ann_' + Date.now();
  const newNotif = {
    id: notifId,
    type: 'announcement',
    title: 'New Official Announcement',
    body: `${adminName}: "${text}"`,
    timestamp: Date.now(),
    isRead: false
  };
  notifs.unshift(newNotif);
  saveNotifications(notifs);

  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.postNotification({
        id: notifId,
        title: newNotif.title,
        body: newNotif.body,
        type: 'announcement',
        is_read: false
      });
    } catch (e) {
      console.warn('Post announcement notification warning:', e);
    }
  }

  if (window.showAppToast) window.showAppToast('New official announcement posted in #announcements');
};

window.dispatchRuleNotification = async function(text, adminName) {
  const notifs = getNotifications();
  const notifId = 'notif_rule_' + Date.now();
  const newNotif = {
    id: notifId,
    type: 'rules',
    title: 'Rules & Regulation Updated',
    body: `${adminName}: "${text}"`,
    timestamp: Date.now(),
    isRead: false
  };
  notifs.unshift(newNotif);
  saveNotifications(notifs);

  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.postNotification({
        id: notifId,
        title: newNotif.title,
        body: newNotif.body,
        type: 'rules',
        is_read: false
      });
    } catch (e) {
      console.warn('Post rule notification warning:', e);
    }
  }

  if (window.showAppToast) window.showAppToast('New rule posted in #rules-and-regulation');
};

window.dispatchBloodNotification = async function(req) {
  const notifs = getNotifications();
  const notifId = 'notif_blood_' + Date.now();
  const newNotif = {
    id: notifId,
    type: 'blood',
    title: `Emergency ${req.bloodGroup} Blood Needed`,
    body: `${req.title} at ${req.hospitalName}. Contact: ${req.contactNumber}`,
    timestamp: Date.now(),
    isRead: false
  };
  notifs.unshift(newNotif);
  saveNotifications(notifs);

  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.postNotification({
        id: notifId,
        title: newNotif.title,
        body: newNotif.body,
        type: 'blood',
        is_read: false
      });
    } catch (e) {
      console.warn('Post blood notification warning:', e);
    }
  }
};

window.dispatchLostFoundNotification = async function(item) {
  const notifs = getNotifications();
  const notifId = 'notif_lf_' + Date.now();
  const newNotif = {
    id: notifId,
    type: 'lost_found',
    title: `New ${item.itemType} Notice: ${item.title}`,
    body: `${item.description} (Location: ${item.location})`,
    timestamp: Date.now(),
    isRead: false
  };
  notifs.unshift(newNotif);
  saveNotifications(notifs);

  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.postNotification({
        id: notifId,
        title: newNotif.title,
        body: newNotif.body,
        type: 'lost_found',
        is_read: false
      });
    } catch (e) {
      console.warn('Post lost & found notification warning:', e);
    }
  }
};

function updateNotificationBadge() {
  const notifs = getNotifications();
  const unreadCount = notifs.filter(n => !n.isRead).length;
  const badge = document.getElementById('notif-badge');
  const countEl = document.getElementById('notif-unread-count');

  if (badge) {
    if (unreadCount > 0) {
      badge.classList.remove('hidden');
    } else {
      badge.classList.add('hidden');
    }
  }
  if (countEl) {
    countEl.textContent = unreadCount > 0 ? `${unreadCount} New` : '0 New';
  }
}

async function renderNotificationsFeed() {
  const container = document.getElementById('notifications-feed-list');
  if (!container) return;

  await syncNotificationsFromSupabase();

  const notifs = getNotifications();
  if (notifs.length === 0) {
    container.innerHTML = `
      <div class="py-12 flex flex-col items-center justify-center text-center text-text-muted">
        <span class="material-symbols-outlined text-4xl mb-2 text-primary/40">notifications_paused</span>
        <p class="text-sm font-bold">No notifications yet</p>
      </div>
    `;
    return;
  }

  container.innerHTML = notifs.map(n => {
    let icon = 'notifications';
    let borderClass = 'border-primary';
    let iconBg = 'bg-primary/15 text-primary';
    let targetScreen = 'home';

    if (n.type === 'destination') {
      icon = 'near_me';
      borderClass = 'border-primary';
      iconBg = 'bg-primary/20 text-primary';
      targetScreen = 'home';
    } else if (n.type === 'journey' || n.type === 'transit') {
      icon = 'directions_bus';
      borderClass = 'border-primary';
      iconBg = 'bg-primary/15 text-primary';
      targetScreen = 'home';
    } else if (n.type === 'blood') {
      icon = 'water_drop';
      borderClass = 'border-urgent';
      iconBg = 'bg-urgent/15 text-urgent';
      targetScreen = 'blood-requests';
    } else if (n.type === 'mention') {
      icon = 'alternate_email';
      borderClass = 'border-secondary';
      iconBg = 'bg-secondary/20 text-secondary';
      targetScreen = 'padma-1';
    } else if (n.type === 'announcement') {
      icon = 'campaign';
      borderClass = 'border-tertiary-container';
      iconBg = 'bg-tertiary-container/20 text-tertiary-container';
      targetScreen = 'announcements';
    } else if (n.type === 'rules') {
      icon = 'gavel';
      borderClass = 'border-tertiary';
      iconBg = 'bg-tertiary/20 text-tertiary';
      targetScreen = 'rules-and-regulation';
    }

    const timeAgo = formatTimeAgo(n.timestamp);

    return `
      <div onclick="switchScreen('${targetScreen}')" class="p-3.5 rounded-2xl bg-surface-elevated border-l-4 ${borderClass} shadow flex items-start gap-3 cursor-pointer hover:brightness-105 transition-all animate-fade-in ${n.isRead ? 'opacity-85' : 'ring-1 ring-primary/20'}">
        <div class="w-9 h-9 rounded-full ${iconBg} flex items-center justify-center shrink-0">
          <span class="material-symbols-outlined text-[20px]">${icon}</span>
        </div>
        <div class="flex-1 min-w-0">
          <div class="flex items-center justify-between">
            <span class="text-[13px] font-bold text-text-primary truncate">${escapeHtml(n.title)}</span>
            <span class="text-[11px] text-text-muted shrink-0 ml-2">${timeAgo}</span>
          </div>
          <p class="text-[13px] text-text-secondary mt-0.5 leading-snug">${escapeHtml(n.body)}</p>
        </div>
      </div>
    `;
  }).join('');
}

async function markAllNotificationsRead() {
  const notifs = getNotifications();
  notifs.forEach(n => n.isRead = true);
  saveNotifications(notifs);
  renderNotificationsFeed();

  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.markAllNotificationsRead();
    } catch (e) {
      console.warn('Mark all notifications read warning:', e);
    }
  }

  showAppToast('All alerts marked as read');
}

// Screen Switching Router with Strict Authentication Check
function switchScreen(screenId) {
  const user = getCurrentUser();

  // Strict Auth Protection: Cannot access app screens without valid login
  if (!user && screenId !== 'signin') {
    screenId = 'signin';
  } else if (user && screenId === 'signin') {
    screenId = 'home';
  }

  document.querySelectorAll('.screen-view').forEach(el => {
    el.classList.remove('active');
  });

  const target = document.getElementById(`screen-${screenId}`);
  if (target) {
    target.classList.add('active');
    activeScreen = screenId;
    window.scrollTo(0, 0);
  }

  // Update Header & Nav visibility
  const globalHeader = document.getElementById('global-header');
  const bottomNav = document.getElementById('global-bottom-nav');
  if (screenId === 'signin') {
    if (globalHeader) globalHeader.classList.add('hidden');
    if (bottomNav) bottomNav.classList.add('hidden');
  } else {
    if (globalHeader) globalHeader.classList.remove('hidden');
    if (bottomNav) bottomNav.classList.remove('hidden');
  }

  // Trigger screen-specific dynamic rendering
  if (screenId === 'rules-and-regulation' || screenId === 'announcements' || screenId === 'padma-1' || screenId === 'padma-2') {
    renderChannelFeed(screenId);
  } else if (screenId === 'contact-admin') {
    renderContactAdminFeed();
  } else if (screenId === 'blood-requests') {
    renderBloodRequestsFeed();
  } else if (screenId === 'lost-found') {
    renderLostFoundFeed();
  } else if (screenId === 'submit-complain') {
    renderComplaintsAdminFeed();
  } else if (screenId === 'notifications') {
    renderNotificationsFeed();
  } else if (screenId === 'profile') {
    updateProfileUI();
  }

  // Update active bottom nav button
  document.querySelectorAll('.nav-item').forEach(btn => {
    btn.className = 'nav-item flex flex-col items-center justify-center gap-1 w-16 h-12 rounded-xl text-text-muted hover:text-text-primary transition-all';
  });
  const activeNav = document.getElementById(`nav-btn-${screenId}`);
  if (activeNav) {
    activeNav.className = 'nav-item flex flex-col items-center justify-center gap-1 w-16 h-12 rounded-xl transition-all bg-primary-container/20 text-primary font-semibold';
  }

  updateProfileUI();
  updateNotificationBadge();
}

// Drawer Navigation
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
  switchScreen(channelKey);
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
    toastIcon.textContent = isUrgent ? 'warning' : 'check_circle';
  }
  
  toast.classList.remove('translate-y-12', 'opacity-0', 'pointer-events-none');
  toast.classList.add('translate-y-0', 'opacity-100');

  toastTimer = setTimeout(() => {
    toast.classList.remove('translate-y-0', 'opacity-100');
    toast.classList.add('translate-y-12', 'opacity-0', 'pointer-events-none');
  }, 2800);
}

// Profile UI Updater
function updateProfileUI() {
  const user = getCurrentUser();
  if (!user) return;

  const initials = getInitials(user.name);

  // Top header and drawer avatars
  document.querySelectorAll('.user-avatar-initials').forEach(el => el.textContent = initials);
  document.querySelectorAll('.user-display-name').forEach(el => el.textContent = user.name);
  document.querySelectorAll('.user-display-id').forEach(el => el.textContent = user.studentId || user.id);
  document.querySelectorAll('.user-display-dept').forEach(el => el.textContent = user.department || 'CSE');
  document.querySelectorAll('.user-display-semester').forEach(el => el.textContent = user.semester || '4-1');
  document.querySelectorAll('.user-display-blood').forEach(el => el.textContent = user.bloodGroup || 'O+');
  document.querySelectorAll('.user-display-pickup').forEach(el => el.textContent = user.pickupDestination || 'Mirpur 10');
  document.querySelectorAll('.user-display-email').forEach(el => el.textContent = user.email);
  document.querySelectorAll('.user-display-chattag').forEach(el => el.textContent = '@' + formatChatTag(user));

  // Role badges
  const roleBadge = document.getElementById('profile-role-badge');
  if (roleBadge) {
    roleBadge.textContent = user.role === 'admin' ? 'Transport Administrator' : 'Verified Student';
  }
}

// Profile Edit Modal Controls
function openEditProfileModal() {
  const user = getCurrentUser();
  if (!user) return;

  const modal = document.getElementById('edit-profile-modal');
  const nameInput = document.getElementById('edit-profile-name');
  const deptInput = document.getElementById('edit-profile-dept');
  const semInput = document.getElementById('edit-profile-sem');
  const bloodInput = document.getElementById('edit-profile-blood');
  const pickupInput = document.getElementById('edit-profile-pickup');

  if (nameInput) nameInput.value = user.name || '';
  if (deptInput) deptInput.value = user.department || 'CSE';
  if (semInput) semInput.value = user.semester || '4-1';
  if (bloodInput) bloodInput.value = user.bloodGroup || 'O+';
  if (pickupInput) pickupInput.value = user.pickupDestination || 'Mirpur 10';

  if (modal) modal.showModal();
}

function closeEditProfileModal() {
  const modal = document.getElementById('edit-profile-modal');
  if (modal) modal.close();
}

function saveEditedProfile() {
  const name = document.getElementById('edit-profile-name')?.value.trim();
  const department = document.getElementById('edit-profile-dept')?.value;
  const semester = document.getElementById('edit-profile-sem')?.value;
  const bloodGroup = document.getElementById('edit-profile-blood')?.value;
  const pickupDestination = document.getElementById('edit-profile-pickup')?.value.trim();

  if (!name || !pickupDestination) {
    showAppToast('Name and Pickup Destination cannot be empty', true);
    return;
  }

  updateUserProfile({
    name,
    department,
    semester,
    bloodGroup,
    pickupDestination
  });

  closeEditProfileModal();
}

// Channel Permissions Handler
function updateChannelPermissions() {
  const user = getCurrentUser();
  const isAdmin = user && user.role === 'admin';

  const rulesInput = document.getElementById('rules-chat-input');
  const annInput = document.getElementById('ann-chat-input');

  if (rulesInput) {
    rulesInput.placeholder = isAdmin ? 'Post official rule (Admin)...' : 'Official rules feed (Admin post only)';
    rulesInput.disabled = !isAdmin;
  }

  if (annInput) {
    annInput.placeholder = isAdmin ? 'Broadcast announcement (Admin)...' : 'Official transport advisories (Admin broadcast only)';
    annInput.disabled = !isAdmin;
  }
}

// Helpers
function formatTimeAgo(timestamp) {
  if (!timestamp) return 'Just now';
  const diffSec = Math.floor((Date.now() - timestamp) / 1000);
  if (diffSec < 60) return 'Just now';
  const diffMin = Math.floor(diffSec / 60);
  if (diffMin < 60) return `${diffMin}m ago`;
  const diffHours = Math.floor(diffMin / 60);
  if (diffHours < 24) return `${diffHours}h ago`;
  return `${Math.floor(diffHours / 24)}d ago`;
}

// Global App Initialization
document.addEventListener('DOMContentLoaded', () => {
  const drawerBtn = document.getElementById('open-drawer-btn');
  if (drawerBtn) {
    drawerBtn.addEventListener('click', openDrawer);
  }

  // Check existing session
  const session = getCurrentSession();
  if (session && session.user) {
    switchScreen('home');
  } else {
    switchScreen('signin');
  }

  updateChannelPermissions();
  syncNotificationsFromSupabase();
});
