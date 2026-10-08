/**
 * Padma - Community, Telemetry, Rules, Announcements & Private Admin Chat Engine
 * Real-time Supabase Database Wiring, @mentions, Admin-only channels, reactions, and 1-on-1 Contact Admin
 */

const CHAT_DB_KEY = 'padma_chat_messages_db';

// Initial Channel Message Seeds for offline cache
function initializeChatDatabase() {
  const existing = localStorage.getItem(CHAT_DB_KEY);
  if (!existing) {
    const initialMessages = [
      {
        id: 'msg_rules_1',
        channel: 'rules-and-regulation',
        senderId: 'a0000000-0000-0000-0000-000000000002',
        senderName: 'Engr. Rafiqul Islam',
        senderTag: 'Engr.Rafiqul_Transport_Faculty_Campus',
        isAdmin: true,
        text: 'AUST Campus Transit Policy 2026: Students must produce digital/physical AUST ID card upon boarding Padma 1 or Padma 2. Queue discipline at all pickup points is strictly enforced.',
        timestamp: Date.now() - 3600000 * 5,
        reactions: { '👍': 42, '🚌': 18, '✅': 25 }
      },
      {
        id: 'msg_rules_2',
        channel: 'rules-and-regulation',
        senderId: 'a0000000-0000-0000-0000-000000000003',
        senderName: 'Dr. Shahed Rahman',
        senderTag: 'Dr.Shahed_StudentAffairs_Faculty_Campus',
        isAdmin: true,
        text: 'Seat Reservation & Emergency Courtesy: Front 6 rows on double-decker buses are reserved for female students and differently-abled peers. Please offer assistance promptly.',
        timestamp: Date.now() - 3600000 * 3,
        reactions: { '❤️': 36, '👏': 19 }
      },
      {
        id: 'msg_ann_1',
        channel: 'announcements',
        senderId: 'a0000000-0000-0000-0000-000000000002',
        senderName: 'Engr. Rafiqul Islam',
        senderTag: 'Engr.Rafiqul_Transport_Faculty_Campus',
        isAdmin: true,
        text: 'Midterm Examination Schedule: Both Padma 1 (Mirpur) and Padma 2 (Uttara) will run supplementary return trips from AUST Gate 2 at 1:45 PM and 5:15 PM.',
        timestamp: Date.now() - 3600000 * 2,
        reactions: { '🙌': 54, '🚌': 31 }
      },
      {
        id: 'msg_p1_1',
        channel: 'padma-1',
        senderId: 'a0000000-0000-0000-0000-000000000002',
        senderName: 'Engr. Rafiqul Islam',
        senderTag: 'Engr.Rafiqul_Transport_Faculty_Campus',
        isAdmin: true,
        text: 'Padma 1 (Mirpur 12 -> AUST) departed on schedule at 7:15 AM. Double decker BRTC-2401 is running on time.',
        timestamp: Date.now() - 3600000 * 1.5,
        reactions: { '🚌': 14 }
      },
      {
        id: 'msg_p1_2',
        channel: 'padma-1',
        senderId: 'a0000000-0000-0000-0000-000000000001',
        senderName: 'Padma Student',
        senderTag: 'Padma_CSE_4-1_Mirpur10',
        isAdmin: false,
        text: 'Boarded at Mirpur 10! Upper deck has plenty of empty seats right now. @Tanvir_CSE_3-2_Farmgate are you getting on at Farmgate?',
        timestamp: Date.now() - 1800000,
        reactions: { '👍': 8 }
      },
      {
        id: 'msg_p2_1',
        channel: 'padma-2',
        senderId: 'a0000000-0000-0000-0000-000000000002',
        senderName: 'Engr. Rafiqul Islam',
        senderTag: 'Engr.Rafiqul_Transport_Faculty_Campus',
        isAdmin: true,
        text: 'Padma 2 (Uttara House Building -> AUST) is currently crossing Airport roundabout with normal traffic flow.',
        timestamp: Date.now() - 2400000,
        reactions: { '🚍': 11 }
      }
    ];
    localStorage.setItem(CHAT_DB_KEY, JSON.stringify(initialMessages));
  }
}

initializeChatDatabase();

function getAllChatMessages() {
  return JSON.parse(localStorage.getItem(CHAT_DB_KEY) || '[]');
}

function saveChatMessages(messages) {
  localStorage.setItem(CHAT_DB_KEY, JSON.stringify(messages));
}

// Fetch dynamic messages from Supabase
async function syncChannelMessagesFromSupabase(channelId) {
  if (typeof SupabaseDb !== 'undefined') {
    try {
      const dbMsgs = await SupabaseDb.fetchMessages(channelId);
      if (dbMsgs && Array.isArray(dbMsgs)) {
        const local = getAllChatMessages();
        const otherChannels = local.filter(m => m.channel !== channelId);
        
        const mapped = dbMsgs.map(m => ({
          id: m.id,
          channel: m.channel_id,
          senderId: m.sender_id,
          senderName: m.sender_name,
          senderTag: m.reply_to_sender_name ? m.sender_name : (m.sender_name ? formatSenderTagFromName(m.sender_name, m.sender_role) : 'User'),
          isAdmin: m.sender_role === 'admin',
          text: m.text,
          timestamp: new Date(m.created_at).getTime(),
          reactions: m.reactions || {}
        }));

        saveChatMessages([...otherChannels, ...mapped]);
      }
    } catch (e) {
      console.warn('Sync channel messages warning:', e);
    }
  }
}

function formatSenderTagFromName(name, role) {
  if (!name) return 'AUST_User';
  const first = name.split(' ')[0].replace(/[^a-zA-Z0-9]/g, '');
  if (role === 'admin') return `${first}_Transport_Faculty_Campus`;
  return `${first}_CSE_4-1_Mirpur10`;
}

// Format mention text and highlight @tags
function renderMessageText(text) {
  const safeText = escapeHtml(text);
  // Match @firstname_dept_sem_dest or @username
  return safeText.replace(/@([a-zA-Z0-9_\-\.]+)/g, (match, p1) => {
    return `<span class="bg-primary/20 text-primary-fixed-dim px-1.5 py-0.5 rounded font-bold">@${p1}</span>`;
  });
}

// Send Message in Active Channel (Dynamically written to Supabase)
async function sendChatMessage(channelId, inputElementId) {
  const user = getCurrentUser();
  if (!user) {
    if (window.showAppToast) window.showAppToast('Please sign in to send messages', true);
    if (window.switchScreen) window.switchScreen('signin');
    return;
  }

  const isAdmin = user.role === 'admin';

  // Restriction check: Rules & Regulation and Announcements are ADMIN ONLY for posting
  if ((channelId === 'rules-and-regulation' || channelId === 'announcements') && !isAdmin) {
    if (window.showAppToast) {
      window.showAppToast('Only transport administrators can post in this channel. You can react below.', true);
    }
    return;
  }

  const input = document.getElementById(inputElementId);
  if (!input) return;
  const text = input.value.trim();
  if (!text) return;

  const senderTag = formatChatTag(user);
  const msgId = 'msg_' + Date.now() + '_' + Math.floor(Math.random() * 1000);

  const newMessage = {
    id: msgId,
    channel: channelId,
    senderId: user.id,
    senderName: user.name,
    senderTag: senderTag,
    isAdmin: isAdmin,
    text: text,
    timestamp: Date.now(),
    reactions: {}
  };

  const messages = getAllChatMessages();
  messages.push(newMessage);
  saveChatMessages(messages);

  input.value = '';

  // Write directly to Supabase messages table
  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.postMessage({
        id: msgId,
        channel_id: channelId,
        sender_id: user.id,
        sender_name: user.name,
        sender_role: user.role || 'student',
        text: text,
        is_urgent: channelId === 'rules-and-regulation',
        reactions: {}
      });
    } catch (e) {
      console.warn('Supabase post message warning:', e);
    }
  }

  // Trigger Mention Alert if mentions are present
  const mentionMatches = text.match(/@([a-zA-Z0-9_\-\.]+)/g);
  if (mentionMatches && window.dispatchMentionNotification) {
    mentionMatches.forEach(m => {
      window.dispatchMentionNotification(m.replace('@', ''), channelId, text, senderTag);
    });
  }

  // Refresh Channel Feed
  renderChannelFeed(channelId);

  // If announcement or rule, dispatch global notification
  if (channelId === 'announcements' && window.dispatchGlobalAnnouncementNotification) {
    window.dispatchGlobalAnnouncementNotification(text, user.name);
  } else if (channelId === 'rules-and-regulation' && window.dispatchRuleNotification) {
    window.dispatchRuleNotification(text, user.name);
  }
}

// Toggle Emoji Reaction on a Message (Dynamic update in Supabase)
async function toggleChatReaction(msgId, emoji) {
  const user = getCurrentUser();
  if (!user) {
    if (window.showAppToast) window.showAppToast('Please sign in to react', true);
    return;
  }

  const messages = getAllChatMessages();
  const msg = messages.find(m => m.id === msgId);
  if (!msg) return;

  if (!msg.reactions) msg.reactions = {};
  msg.reactions[emoji] = (msg.reactions[emoji] || 0) + 1;

  saveChatMessages(messages);
  renderChannelFeed(msg.channel);

  // Update in Supabase
  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.updateReactions(msgId, msg.reactions);
    } catch (e) {
      console.warn('Supabase update reactions warning:', e);
    }
  }
}

// Render Messages for a Channel (Syncs live from database)
async function renderChannelFeed(channelId) {
  const container = document.getElementById(`feed-${channelId}`);
  if (!container) return;

  // Sync latest from Supabase
  await syncChannelMessagesFromSupabase(channelId);

  const currentUser = getCurrentUser();
  const messages = getAllChatMessages().filter(m => m.channel === channelId);

  if (messages.length === 0) {
    container.innerHTML = `
      <div class="py-12 flex flex-col items-center justify-center text-center text-text-muted">
        <span class="material-symbols-outlined text-4xl mb-2 text-primary/40">forum</span>
        <p class="text-sm font-semibold">No messages yet in #${channelId}</p>
        <p class="text-xs text-text-muted mt-1">Be the first to start the conversation!</p>
      </div>
    `;
    return;
  }

  container.innerHTML = messages.map(msg => {
    const isMe = currentUser && (currentUser.id === msg.senderId || currentUser.studentId === msg.senderId);
    const timeStr = formatMessageTime(msg.timestamp);
    const reactionsHtml = Object.entries(msg.reactions || {}).map(([emoji, count]) => `
      <button onclick="toggleChatReaction('${msg.id}', '${emoji}')" class="reaction-pill inline-flex items-center gap-1 bg-surface-container-high hover:bg-surface-elevated text-text-secondary px-2.5 py-0.5 rounded-full text-xs font-semibold active:scale-95 transition-all">
        <span>${emoji}</span>
        <span class="text-[11px] font-bold">${count}</span>
      </button>
    `).join('');

    return `
      <article class="flex items-start gap-3 group animate-fade-in ${msg.isAdmin ? 'p-3 rounded-2xl bg-surface-elevated/90 border-l-4 border-tertiary-container' : ''}">
        <div class="w-10 h-10 rounded-full ${msg.isAdmin ? 'bg-purple-900 text-tertiary-fixed' : 'bg-primary/20 text-primary'} flex items-center justify-center font-bold text-xs shrink-0 shadow-sm">
          ${getInitials(msg.senderName)}
        </div>
        <div class="flex flex-col min-w-0 flex-1">
          <div class="flex items-center gap-1.5 flex-wrap">
            <span class="font-bold text-xs text-primary-fixed truncate">@${escapeHtml(msg.senderTag || msg.senderName)}</span>
            ${msg.isAdmin ? '<span class="px-1.5 py-0.2 rounded bg-tertiary-container text-on-tertiary font-bold text-[9px] uppercase tracking-wider">ADMIN</span>' : ''}
            <span class="font-caption-timestamp text-[10px] text-text-muted ml-auto">${timeStr}</span>
          </div>
          <div class="text-text-primary mt-1 text-sm leading-relaxed break-words font-body-message">
            ${renderMessageText(msg.text)}
          </div>
          <div class="flex items-center gap-1.5 mt-2 flex-wrap">
            ${reactionsHtml}
            <button onclick="promptAddReaction('${msg.id}')" class="w-6 h-6 rounded-full bg-surface-highest/60 hover:bg-surface-highest text-text-muted hover:text-text-primary flex items-center justify-center text-xs transition-colors" title="Add reaction">
              <span class="material-symbols-outlined text-[14px]">add_reaction</span>
            </button>
          </div>
        </div>
      </article>
    `;
  }).join('');

  const scrollParent = container.closest('.overflow-y-auto') || container;
  scrollParent.scrollTop = scrollParent.scrollHeight;
}

function promptAddReaction(msgId) {
  toggleChatReaction(msgId, '👍');
}

// -------------------------------------------------------------
// Contact Admin 1-on-1 Private Messaging (Supabase Connected)
// -------------------------------------------------------------
const CONTACT_ADMINS = [
  {
    id: 'ADM-01',
    uuid: 'a0000000-0000-0000-0000-000000000002',
    name: 'Engr. Rafiqul Islam',
    role: 'Chief Transport Coordinator',
    email: 'admin.rafiq@aust.edu',
    status: 'Online'
  },
  {
    id: 'ADM-02',
    uuid: 'a0000000-0000-0000-0000-000000000003',
    name: 'Dr. Shahed Rahman',
    role: 'Dean of Student Affairs',
    email: 'admin.shahed@aust.edu',
    status: 'Available'
  }
];

let selectedContactAdminId = 'ADM-01';

function selectContactAdmin(adminId) {
  selectedContactAdminId = adminId;
  const admin = CONTACT_ADMINS.find(a => a.id === adminId);
  const titleEl = document.getElementById('contact-admin-active-title');
  const roleEl = document.getElementById('contact-admin-active-role');
  if (titleEl && admin) titleEl.textContent = admin.name;
  if (roleEl && admin) roleEl.textContent = admin.role;

  document.querySelectorAll('.admin-select-pill').forEach(pill => {
    if (pill.dataset.adminId === adminId) {
      pill.className = 'admin-select-pill flex items-center gap-2 p-2.5 rounded-xl bg-primary-container text-on-primary font-bold text-xs shadow-md transition-all cursor-pointer';
    } else {
      pill.className = 'admin-select-pill flex items-center gap-2 p-2.5 rounded-xl bg-surface-elevated text-text-secondary hover:text-text-primary font-medium text-xs transition-all cursor-pointer';
    }
  });

  renderContactAdminFeed();
}

async function sendContactAdminMessage() {
  const user = getCurrentUser();
  if (!user) {
    if (window.showAppToast) window.showAppToast('Please sign in to contact administrators', true);
    if (window.switchScreen) window.switchScreen('signin');
    return;
  }

  const input = document.getElementById('contact-admin-input');
  if (!input) return;
  const text = input.value.trim();
  if (!text) return;

  const targetAdminId = selectedContactAdminId || 'ADM-01';
  const targetAdmin = CONTACT_ADMINS.find(a => a.id === targetAdminId) || CONTACT_ADMINS[0];

  const senderTag = formatChatTag(user);
  const msgId = 'msg_pvt_' + Date.now();

  const privateMsg = {
    id: msgId,
    studentId: user.id,
    studentName: user.name,
    studentTag: senderTag,
    adminId: targetAdminId,
    adminName: targetAdmin.name,
    senderId: user.id,
    senderName: user.name,
    senderTag: senderTag,
    text: text,
    timestamp: Date.now()
  };

  const pvtKey = 'padma_private_contact_messages';
  const pvtMessages = JSON.parse(localStorage.getItem(pvtKey) || '[]');
  pvtMessages.push(privateMsg);
  localStorage.setItem(pvtKey, JSON.stringify(pvtMessages));

  // Write directly to Supabase messages table
  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.postMessage({
        id: msgId,
        channel_id: 'contact-admin',
        sender_id: user.id,
        sender_name: user.name,
        sender_role: 'student',
        text: text,
        reply_to_sender_name: targetAdminId,
        reply_to_text: user.studentId || user.id
      });
    } catch (e) {
      console.warn('Supabase post private message warning:', e);
    }
  }

  input.value = '';
  renderContactAdminFeed();

  // Simulated auto-acknowledgement from Admin
  setTimeout(async () => {
    const replyId = 'msg_pvt_reply_' + Date.now();
    const replyMsg = {
      id: replyId,
      studentId: user.id,
      studentName: user.name,
      studentTag: senderTag,
      adminId: targetAdminId,
      adminName: targetAdmin.name,
      senderId: targetAdmin.uuid || targetAdminId,
      senderName: targetAdmin.name,
      senderTag: `${targetAdmin.name.split(' ')[0]}_Admin_Faculty_Campus`,
      text: `Hello ${user.name.split(' ')[0]}, thank you for reaching out directly. We have logged your enquiry regarding transit logistics and will review it immediately.`,
      timestamp: Date.now()
    };
    const currentList = JSON.parse(localStorage.getItem(pvtKey) || '[]');
    currentList.push(replyMsg);
    localStorage.setItem(pvtKey, JSON.stringify(currentList));

    if (typeof SupabaseDb !== 'undefined') {
      try {
        await SupabaseDb.postMessage({
          id: replyId,
          channel_id: 'contact-admin',
          sender_id: targetAdmin.uuid || 'a0000000-0000-0000-0000-000000000002',
          sender_name: targetAdmin.name,
          sender_role: 'admin',
          text: replyMsg.text,
          reply_to_sender_name: user.studentId || user.id,
          reply_to_text: targetAdminId
        });
      } catch (e) {
        console.warn('Supabase reply post warning:', e);
      }
    }

    renderContactAdminFeed();
    if (window.showAppToast) {
      window.showAppToast(`New private reply from ${targetAdmin.name}`);
    }
  }, 1200);
}

async function renderContactAdminFeed() {
  const container = document.getElementById('contact-admin-feed');
  if (!container) return;

  const user = getCurrentUser();
  if (!user) return;

  // Sync from Supabase contact-admin messages
  if (typeof SupabaseDb !== 'undefined') {
    try {
      const dbMsgs = await SupabaseDb.fetchMessages('contact-admin');
      if (dbMsgs && Array.isArray(dbMsgs)) {
        const pvtKey = 'padma_private_contact_messages';
        const mapped = dbMsgs.map(m => ({
          id: m.id,
          studentId: m.sender_role === 'student' ? m.sender_id : (m.reply_to_sender_name || user.id),
          studentName: m.sender_role === 'student' ? m.sender_name : user.name,
          studentTag: m.sender_role === 'student' ? formatSenderTagFromName(m.sender_name, 'student') : formatChatTag(user),
          adminId: m.sender_role === 'admin' ? (m.reply_to_text || selectedContactAdminId) : (m.reply_to_sender_name || selectedContactAdminId),
          adminName: m.sender_role === 'admin' ? m.sender_name : 'Administrator',
          senderId: m.sender_id,
          senderName: m.sender_name,
          senderTag: formatSenderTagFromName(m.sender_name, m.sender_role),
          text: m.text,
          timestamp: new Date(m.created_at).getTime()
        }));
        localStorage.setItem(pvtKey, JSON.stringify(mapped));
      }
    } catch (e) {
      console.warn('Supabase contact admin sync warning:', e);
    }
  }

  const pvtKey = 'padma_private_contact_messages';
  const allPvt = JSON.parse(localStorage.getItem(pvtKey) || '[]');

  const filtered = allPvt.filter(m => 
    (m.studentId === user.id || m.studentId === user.studentId || m.senderId === user.id) &&
    (m.adminId === selectedContactAdminId || m.senderId.includes('a0000000-0000-0000-0000-000000000002') || m.senderId.includes('a0000000-0000-0000-0000-000000000003'))
  );

  if (filtered.length === 0) {
    const admin = CONTACT_ADMINS.find(a => a.id === selectedContactAdminId);
    container.innerHTML = `
      <div class="py-12 flex flex-col items-center justify-center text-center text-text-muted">
        <div class="w-12 h-12 rounded-full bg-surface-elevated flex items-center justify-center text-primary mb-3">
          <span class="material-symbols-outlined text-2xl">lock</span>
        </div>
        <p class="text-sm font-bold text-text-primary">End-to-End Private Channel</p>
        <p class="text-xs text-text-muted mt-1 max-w-[280px]">Messages sent here are strictly confidential between you and <strong>${admin ? admin.name : 'the Administrator'}</strong>. Other students cannot see this conversation.</p>
      </div>
    `;
    return;
  }

  container.innerHTML = filtered.map(msg => {
    const isMe = msg.senderId === user.id || msg.senderId === user.studentId;
    const timeStr = formatMessageTime(msg.timestamp);

    return `
      <div class="flex flex-col ${isMe ? 'items-end' : 'items-start'} my-2 animate-fade-in">
        <div class="flex items-center gap-1.5 mb-1 px-1">
          <span class="text-[11px] font-bold ${isMe ? 'text-primary' : 'text-tertiary-fixed'}">@${escapeHtml(msg.senderTag)}</span>
          <span class="text-[10px] text-text-muted">• ${timeStr}</span>
        </div>
        <div class="max-w-[85%] p-3.5 rounded-2xl ${isMe ? 'bg-primary-container text-on-primary-container rounded-tr-sm shadow-md font-medium' : 'bg-surface-elevated text-text-primary rounded-tl-sm border border-border-line/40 shadow'} text-sm leading-relaxed">
          ${escapeHtml(msg.text)}
        </div>
      </div>
    `;
  }).join('');

  container.scrollTop = container.scrollHeight;
}

// Helpers
function getInitials(name) {
  if (!name) return 'U';
  return name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();
}

function formatMessageTime(timestamp) {
  if (!timestamp) return 'Just now';
  const date = new Date(timestamp);
  return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str).replace(/[&<>'"]/g, 
    tag => ({
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      "'": '&#39;',
      '"': '&quot;'
    }[tag] || tag)
  );
}
