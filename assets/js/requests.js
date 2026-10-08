/**
 * Padma - Emergency & Blood Donation Requests Module
 * Handles Category Filters, Emergency Post Submission, Attendant Calling & Donors
 */

function filterRequests(type, btn) {
  document.querySelectorAll('.req-filter-btn').forEach(b => {
    b.className = 'req-filter-btn px-3 py-1.5 rounded-full bg-surface-container hover:bg-surface-elevated text-text-primary font-label-button text-[13px] shrink-0';
  });
  if (btn) {
    btn.className = 'req-filter-btn px-3 py-1.5 rounded-full bg-primary-container text-on-primary font-label-button text-[13px] shrink-0 shadow-sm';
  }

  const cards = document.querySelectorAll('.req-card');
  cards.forEach(card => {
    if (type === 'all') {
      card.style.display = 'flex';
    } else if (type === 'blood') {
      card.style.display = card.classList.contains('blood-req') ? 'flex' : 'none';
    } else if (type === 'help') {
      card.style.display = card.classList.contains('help-req') ? 'flex' : 'none';
    }
  });
}

function openUrgentRequestModal() {
  const modal = document.getElementById('urgent-post-modal');
  if (modal) modal.showModal();
}

function submitUrgentPost() {
  const blood = document.getElementById('post-blood')?.value || 'O+';
  const loc = document.getElementById('post-loc')?.value || 'DMCH';
  const desc = document.getElementById('post-desc')?.value || '';
  const type = document.getElementById('post-type')?.value || 'blood';

  const feed = document.getElementById('requests-card-feed');
  if (feed) {
    const card = document.createElement('article');
    card.className = `req-card ${type === 'blood' ? 'blood-req border-urgent' : 'help-req border-warning'} relative flex flex-col rounded-2xl bg-surface-elevated p-4 shadow-md border-l-4 animate-fade-in`;
    card.innerHTML = `
      <div class="flex items-center justify-between gap-space-xs">
        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full ${type === 'blood' ? 'bg-urgent text-white' : 'bg-warning/20 text-warning'} font-label-button text-[12px] font-bold">
          ${type === 'blood' ? blood : 'GENERAL HELP'}
        </span>
        <span class="text-[11px] text-text-muted">Just now</span>
      </div>
      <p class="font-body-message text-body-message font-semibold text-text-primary mt-space-sm leading-snug">
        ${desc}
      </p>
      <div class="mt-space-sm p-space-sm rounded-xl bg-surface-container text-[13px] text-text-secondary flex items-center gap-2">
        <span class="material-symbols-outlined text-[17px] text-primary">location_on</span>
        <span>${loc}</span>
      </div>
    `;
    feed.prepend(card);
  }

  const modal = document.getElementById('urgent-post-modal');
  if (modal) modal.close();
  
  if (window.showAppToast) {
    window.showAppToast('Urgent alert broadcasted to campus community', true);
  }
}
