/**
 * Padma - Community & Route Chat Engine
 * Handles Real-time messaging in #general and #bus-1-mirpur, Quick Pings, and Reaction Toggles
 */

function sendGeneralMessage() {
  const input = document.getElementById('general-chat-input');
  if (!input) return;
  const text = input.value.trim();
  if (!text) return;

  const feed = document.getElementById('general-messages-feed');
  if (!feed) return;

  const msgNode = document.createElement('div');
  msgNode.className = 'flex items-start gap-3 mt-2 animate-fade-in';
  msgNode.innerHTML = `
    <div class="w-10 h-10 rounded-full bg-primary flex items-center justify-center font-bold text-[13px] text-on-primary shadow-sm shrink-0">
      RH
    </div>
    <div class="flex flex-col min-w-0 flex-1">
      <div class="flex items-center gap-2">
        <span class="font-title-channel text-[14px] font-semibold text-text-primary">Rakib Hasan</span>
        <span class="font-caption-timestamp text-[11px] px-1.5 py-0.5 rounded bg-surface-container text-text-secondary">CSE '22</span>
        <span class="font-caption-timestamp text-text-muted ml-auto">Just now</span>
      </div>
      <div class="bg-primary/15 text-text-primary rounded-2xl rounded-tl-sm px-3.5 py-2.5 mt-1 leading-snug font-body-message text-[14px] shadow-sm border border-primary/20">
        ${escapeHtml(text)}
      </div>
    </div>
  `;
  feed.appendChild(msgNode);
  input.value = '';
  window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
}

function sendBusMessage() {
  const input = document.getElementById('bus-chat-input');
  if (!input) return;
  const text = input.value.trim();
  if (!text) return;

  const feed = document.getElementById('bus-chat-stream');
  if (!feed) return;

  const msgNode = document.createElement('div');
  msgNode.className = 'flex items-start gap-3 pt-1 animate-fade-in';
  msgNode.innerHTML = `
    <div class="w-9 h-9 rounded-full bg-primary flex items-center justify-center text-on-primary font-bold text-xs shrink-0 shadow-sm">
      RH
    </div>
    <div class="flex flex-col min-w-0 flex-1">
      <div class="flex items-baseline gap-2">
        <span class="font-title-channel text-sm font-bold text-text-primary">Rakib Hasan</span>
        <span class="font-caption-timestamp text-[10px] text-text-muted">CSE '22 • Just now</span>
      </div>
      <p class="font-body-message text-[13px] text-text-primary mt-0.5 leading-snug">
        ${escapeHtml(text)}
      </p>
    </div>
  `;
  feed.appendChild(msgNode);
  input.value = '';
}

function insertQuickPing(msg) {
  const input = document.getElementById('bus-chat-input');
  if (input) {
    input.value = msg;
    sendBusMessage();
  }
}

function toggleReaction(btn) {
  const countSpan = btn.querySelector('span:last-child');
  if (!countSpan) return;
  let val = parseInt(countSpan.textContent, 10);
  if (btn.classList.contains('active')) {
    btn.classList.remove('active', 'bg-primary-container/20', 'text-primary-fixed-dim');
    btn.classList.add('bg-surface-container-high', 'text-text-secondary');
    countSpan.textContent = Math.max(0, val - 1);
  } else {
    btn.classList.add('active', 'bg-primary-container/20', 'text-primary-fixed-dim');
    btn.classList.remove('bg-surface-container-high', 'text-text-secondary');
    countSpan.textContent = val + 1;
  }
}

function escapeHtml(str) {
  return str.replace(/[&<>'"]/g, 
    tag => ({
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      "'": '&#39;',
      '"': '&quot;'
    }[tag] || tag)
  );
}
