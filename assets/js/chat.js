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

// -------------------------------------------------------------
// Messenger-Style @Mention Autocomplete Engine
// -------------------------------------------------------------
const DEFAULT_COMMUNITY_MEMBERS = [
  { name: 'Padma Student', handle: 'Padma_CSE_4-1_Mirpur10', dept: 'CSE 4-1', role: 'student', stop: 'Mirpur 10' },
  { name: 'Tanvir Ahmed', handle: 'Tanvir_CSE_4-1_Mirpur10', dept: 'CSE 4-1', role: 'student', stop: 'Mirpur 10' },
  { name: 'Sadia Afrin', handle: 'Sadia_CSE_2-2_Campus', dept: 'CSE 2-2', role: 'student', stop: 'Campus' },
  { name: 'Siam Chowdhury', handle: 'Siam_CSE_3-1_Mirpur10', dept: 'CSE 3-1', role: 'student', stop: 'Mirpur 10' },
  { name: 'Nafis Iqbal', handle: 'Nafis_EEE_3-2_Uttara', dept: 'EEE 3-2', role: 'student', stop: 'Uttara' },
  { name: 'Anika Tabassum', handle: 'Anika_Arch_4-2_Dhanmondi', dept: 'Arch 4-2', role: 'student', stop: 'Dhanmondi' },
  { name: 'Farhan Kabir', handle: 'Farhan_CE_2-1_Mohakhali', dept: 'CE 2-1', role: 'student', stop: 'Mohakhali' },
  { name: 'Engr. Rafiqul Islam', handle: 'Rafiqul_Transport_Faculty_Campus', dept: 'Transport Dept', role: 'admin', stop: 'Campus' },
  { name: 'Dr. Shahed Rahman', handle: 'Dr.Shahed_StudentAffairs_Faculty_Campus', dept: 'Student Affairs', role: 'admin', stop: 'Campus' }
];

function getMentionCandidates() {
  const map = new Map();

  // 1. Seed community members
  DEFAULT_COMMUNITY_MEMBERS.forEach(m => {
    map.set(m.handle.toLowerCase(), m);
  });

  // 2. Local registered users
  try {
    const users = JSON.parse(localStorage.getItem('padma_users_database') || '[]');
    users.forEach(u => {
      const tag = formatChatTag(u);
      if (!map.has(tag.toLowerCase())) {
        map.set(tag.toLowerCase(), {
          name: u.name,
          handle: tag,
          dept: `${u.department || 'AUST'} ${u.semester || ''}`,
          role: u.role || 'student',
          stop: u.pickupDestination || 'Campus'
        });
      }
    });
  } catch (e) {}

  // 3. Historical message senders
  try {
    const msgs = getAllChatMessages();
    msgs.forEach(m => {
      if (m.senderTag && !map.has(m.senderTag.toLowerCase())) {
        map.set(m.senderTag.toLowerCase(), {
          name: m.senderName || m.senderTag,
          handle: m.senderTag,
          dept: m.isAdmin ? 'Transport Admin' : 'AUST Student',
          role: m.isAdmin ? 'admin' : 'student',
          stop: 'Transit'
        });
      }
    });
  } catch (e) {}

  return Array.from(map.values());
}

let activeMentionPopup = null;
let activeMentionInput = null;
let mentionSelectedIndex = 0;
let filteredMentionCandidates = [];

function getOrCreateMentionPopup() {
  let popup = document.getElementById('messenger-mention-popup');
  if (!popup) {
    popup = document.createElement('div');
    popup.id = 'messenger-mention-popup';
    popup.className = 'fixed z-50 hidden w-[320px] max-w-[92vw] bg-[#1e2024]/95 backdrop-blur-xl rounded-2xl shadow-2xl border border-border-line/60 overflow-hidden text-text-primary animate-fade-in';
    document.body.appendChild(popup);
  }
  return popup;
}

function hideMentionPopup() {
  const popup = document.getElementById('messenger-mention-popup');
  if (popup) {
    popup.classList.add('hidden');
  }
  activeMentionInput = null;
  filteredMentionCandidates = [];
  mentionSelectedIndex = 0;
}

function renderMentionPopup(inputEl, query, candidates) {
  const popup = getOrCreateMentionPopup();
  activeMentionInput = inputEl;
  filteredMentionCandidates = candidates;

  if (candidates.length === 0) {
    hideMentionPopup();
    return;
  }

  // Adjust selected index
  if (mentionSelectedIndex >= candidates.length) {
    mentionSelectedIndex = 0;
  }

  // Compute positioning directly above the input container
  const rect = inputEl.getBoundingClientRect();
  const popupHeight = Math.min(260, 48 + candidates.length * 52);
  let top = rect.top - popupHeight - 10;
  let left = rect.left;

  // Window bounds safety check
  if (left + 320 > window.innerWidth - 12) {
    left = window.innerWidth - 320 - 12;
  }
  if (left < 12) left = 12;
  if (top < 10) {
    top = rect.bottom + 8; // flip below if not enough room above
  }

  popup.style.top = `${top}px`;
  popup.style.left = `${left}px`;

  popup.innerHTML = `
    <div class="px-3.5 py-2 bg-surface-sidebar border-b border-border-line/40 flex items-center justify-between text-[11px] font-bold text-text-muted uppercase tracking-wider">
      <div class="flex items-center gap-1.5">
        <span class="text-primary font-mono text-xs">@</span>
        <span>Mention Student / Admin</span>
      </div>
      <span class="text-[10px] text-text-muted lowercase">${candidates.length} match${candidates.length > 1 ? 'es' : ''}</span>
    </div>
    <div class="max-h-[210px] overflow-y-auto no-scrollbar divide-y divide-border-line/20">
      ${candidates.map((c, idx) => {
        const isSelected = idx === mentionSelectedIndex;
        const initials = (c.name || 'U').split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();
        return `
          <div class="mention-item flex items-center gap-2.5 px-3 py-2 cursor-pointer transition-colors ${isSelected ? 'bg-primary/20 text-primary-fixed border-l-4 border-primary' : 'hover:bg-surface-elevated text-text-secondary hover:text-text-primary'}" data-index="${idx}">
            <div class="relative w-8 h-8 rounded-full ${c.role === 'admin' ? 'bg-purple-900 text-purple-200' : 'bg-primary/20 text-primary'} flex items-center justify-center font-bold text-xs shrink-0 shadow-sm">
              ${initials}
              <div class="absolute -bottom-0.5 -right-0.5 w-2.5 h-2.5 rounded-full ${c.role === 'admin' ? 'bg-purple-400' : 'bg-success'} border border-surface-container-lowest"></div>
            </div>
            <div class="flex flex-col min-w-0 flex-1">
              <div class="flex items-center gap-1.5 truncate">
                <span class="font-semibold text-xs text-text-primary truncate">${escapeHtml(c.name)}</span>
                ${c.role === 'admin' ? '<span class="px-1.5 py-0.2 rounded bg-purple-500/20 text-purple-300 font-bold text-[8.5px] uppercase">Admin</span>' : ''}
              </div>
              <div class="flex items-center justify-between gap-1 text-[10.5px]">
                <span class="font-mono text-primary truncate">@${escapeHtml(c.handle)}</span>
                <span class="text-text-muted truncate shrink-0">${escapeHtml(c.dept)}</span>
              </div>
            </div>
          </div>
        `;
      }).join('')}
    </div>
  `;

  popup.classList.remove('hidden');

  // Attach click listeners to items
  popup.querySelectorAll('.mention-item').forEach(el => {
    el.addEventListener('mousedown', (e) => {
      e.preventDefault(); // Prevent input blur
      const index = parseInt(el.getAttribute('data-index'), 10);
      selectMentionCandidate(index);
    });
  });
}

function selectMentionCandidate(index) {
  if (!activeMentionInput || !filteredMentionCandidates[index]) return;

  const candidate = filteredMentionCandidates[index];
  const input = activeMentionInput;
  const val = input.value;
  const cursor = input.selectionStart || val.length;

  // Find the @ preceding the cursor
  const textBefore = val.slice(0, cursor);
  const atIndex = textBefore.lastIndexOf('@');
  if (atIndex !== -1) {
    const beforeAt = val.slice(0, atIndex);
    const afterCursor = val.slice(cursor);
    const replacement = `@${candidate.handle} `;
    input.value = beforeAt + replacement + afterCursor;

    const newCursor = (beforeAt + replacement).length;
    input.focus();
    input.setSelectionRange(newCursor, newCursor);
  }

  hideMentionPopup();
}

function setupMessengerMentionAutocomplete(inputEl) {
  if (!inputEl || inputEl.dataset.mentionAttached) return;
  inputEl.dataset.mentionAttached = 'true';

  inputEl.addEventListener('input', () => {
    const val = inputEl.value;
    const cursor = inputEl.selectionStart || 0;
    const textBefore = val.slice(0, cursor);

    // Look for @ preceding the cursor without spaces after it
    const lastAtIndex = textBefore.lastIndexOf('@');
    if (lastAtIndex !== -1) {
      const queryAfterAt = textBefore.slice(lastAtIndex + 1);
      // Ensure there's no space in the active mention query
      if (!/\s/.test(queryAfterAt)) {
        const queryLower = queryAfterAt.toLowerCase();
        const allCandidates = getMentionCandidates();
        const matches = allCandidates.filter(c => 
          c.name.toLowerCase().includes(queryLower) ||
          c.handle.toLowerCase().includes(queryLower) ||
          c.dept.toLowerCase().includes(queryLower) ||
          c.stop.toLowerCase().includes(queryLower)
        );
        mentionSelectedIndex = 0;
        renderMentionPopup(inputEl, queryLower, matches);
        return;
      }
    }
    hideMentionPopup();
  });

  inputEl.addEventListener('keydown', (e) => {
    const popup = document.getElementById('messenger-mention-popup');
    const isVisible = popup && !popup.classList.contains('hidden');

    if (!isVisible || filteredMentionCandidates.length === 0) return;

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      mentionSelectedIndex = (mentionSelectedIndex + 1) % filteredMentionCandidates.length;
      renderMentionPopup(inputEl, '', filteredMentionCandidates);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      mentionSelectedIndex = (mentionSelectedIndex - 1 + filteredMentionCandidates.length) % filteredMentionCandidates.length;
      renderMentionPopup(inputEl, '', filteredMentionCandidates);
    } else if (e.key === 'Enter' || e.key === 'Tab') {
      e.preventDefault();
      selectMentionCandidate(mentionSelectedIndex);
    } else if (e.key === 'Escape') {
      e.preventDefault();
      hideMentionPopup();
    }
  });

  inputEl.addEventListener('blur', () => {
    // Delay hide slightly so click inside popup registers
    setTimeout(hideMentionPopup, 200);
  });
}

function attachMentionsToAllInputs() {
  const inputIds = [
    'padma1-chat-input',
    'padma2-chat-input',
    'rules-chat-input',
    'ann-chat-input',
    'contact-admin-input'
  ];
  inputIds.forEach(id => {
    const el = document.getElementById(id);
    if (el) setupMessengerMentionAutocomplete(el);
  });

  document.querySelectorAll('input[type="text"], textarea').forEach(el => {
    if (el.placeholder && el.placeholder.toLowerCase().includes('message')) {
      setupMessengerMentionAutocomplete(el);
    }
  });
}

// Global click dismiss
document.addEventListener('click', (e) => {
  const popup = document.getElementById('messenger-mention-popup');
  if (popup && !popup.contains(e.target) && e.target !== activeMentionInput) {
    hideMentionPopup();
  }
});

// Send Message in Active Channel (Dynamically written to Supabase & Realtime Broadcasted)
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

  hideMentionPopup();

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
      SupabaseDb.broadcastChange('chat_message', newMessage);
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

// Global Exports
window.attachMentionsToAllInputs = attachMentionsToAllInputs;
window.setupMessengerMentionAutocomplete = setupMessengerMentionAutocomplete;
window.getMentionCandidates = getMentionCandidates;

document.addEventListener('DOMContentLoaded', () => {
  attachMentionsToAllInputs();
});

