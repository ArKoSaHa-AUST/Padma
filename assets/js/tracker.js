/**
 * Padma - Live Bus Tracker, Fall 25 Bus Schedule & Telemetry Module
 * Dynamic Supabase & Realtime Synchronization with Admin 1st Bus Confirmation
 */

const FALL_25_SCHEDULE = [
  {
    stopBn: 'মিরপুর ১২ (বিআরটি পাম্প)',
    stopEn: 'Mirpur 12 (BRT Pump)',
    time1Bn: '৬.৪৫',
    time1En: '06:45 AM',
    time2Bn: '৮.৩০',
    time2En: '08:30 AM',
  },
  {
    stopBn: 'মিরপুর ১১.৫ (রংধনু শপিং সেন্টার)',
    stopEn: 'Mirpur 11.5 (Rongdhonu)',
    time1Bn: '৬.৪৮',
    time1En: '06:48 AM',
    time2Bn: '৮.৩৩',
    time2En: '08:33 AM',
  },
  {
    stopBn: 'পুরবী (বনলতা)',
    stopEn: 'Purobi (Bonolota)',
    time1Bn: '৬.৫০',
    time1En: '06:50 AM',
    time2Bn: '৮.৩৬',
    time2En: '08:36 AM',
  },
  {
    stopBn: 'মিরপুর ১১ (ইস্টার্ন ব্যাংক)',
    stopEn: 'Mirpur 11 (Eastern Bank)',
    time1Bn: '৬.৫৩',
    time1En: '06:53 AM',
    time2Bn: '৮.৩৯',
    time2En: '08:39 AM',
  },
  {
    stopBn: 'মিরপুর বাংলা স্কুল',
    stopEn: 'Mirpur Bangla School',
    time1Bn: '৬.৫৫',
    time1En: '06:55 AM',
    time2Bn: '৮.৪২',
    time2En: '08:42 AM',
  },
  {
    stopBn: 'মিরপুর অরিজিনাল ১০ (পপুলারের বিপরীতে)',
    stopEn: 'Mirpur Original 10 (Opp. Popular)',
    time1Bn: '৬.৫৭',
    time1En: '06:57 AM',
    time2Bn: '৮.৪৪',
    time2En: '08:44 AM',
  },
  {
    stopBn: 'মিরপুর ১০ (ফলপট্টির বিপরীতে)',
    stopEn: 'Mirpur 10 (Opp. Folpotti)',
    time1Bn: '৭.০৫',
    time1En: '07:05 AM',
    time2Bn: '৮.৫৮',
    time2En: '08:58 AM',
  },
  {
    stopBn: 'সেনপাড়া (আল হেলাল হাসপাতালের সামনে)',
    stopEn: 'Senpara (Al Helal Hospital)',
    time1Bn: '৭.০৮',
    time1En: '07:08 AM',
    time2Bn: '৯.০১',
    time2En: '09:01 AM',
  },
  {
    stopBn: 'কাজীপাডা (স্বপ্নের সামনে)',
    stopEn: 'Kazipara (Shwapno)',
    time1Bn: '৭.১১',
    time1En: '07:11 AM',
    time2Bn: '৯.০৪',
    time2En: '09:04 AM',
  },
  {
    stopBn: 'মনিপুর স্কুল',
    stopEn: 'Monipur School',
    time1Bn: '৭.১৫',
    time1En: '07:15 AM',
    time2Bn: '৯.০৭',
    time2En: '09:07 AM',
  },
  {
    stopBn: 'শেওড়াপাড়া (ডি এস এস এর বিপরীতে)',
    stopEn: 'Shewrapara (Opp. DSS)',
    time1Bn: '৭.২৩',
    time1En: '07:23 AM',
    time2Bn: '৯.১৫',
    time2En: '09:15 AM',
  },
  {
    stopBn: 'তালতলা (ডাম্পিং স্টেশনের পাশে)',
    stopEn: 'Taltola (Dumping Station)',
    time1Bn: '৭.২৫',
    time1En: '07:25 AM',
    time2Bn: '৯.২০',
    time2En: '09:20 AM',
  },
  {
    stopBn: 'আগারগাঁও (আইডিবি ভবনের বিপরীত পাশে)',
    stopEn: 'Agargaon (Opp. IDB Bhaban)',
    time1Bn: '৭.২৮',
    time1En: '07:28 AM',
    time2Bn: '৯.২৪',
    time2En: '09:24 AM',
  },
  {
    stopBn: 'ভার্সিটি (আহছানউল্লা ক্যাম্পাস)',
    stopEn: 'Varsity (AUST Campus)',
    time1Bn: '৭.৪৫',
    time1En: '07:45 AM',
    time2Bn: '৯.৪৫',
    time2En: '09:45 AM',
  }
];

let firstBusAssignment = localStorage.getItem('padma_first_bus_id') || 'padma-1';

let busRoutesData = {
  'padma-1': {
    id: 'padma-1',
    busId: 'bus_1',
    routeId: 'route_mirpur',
    name: 'Padma 1 • Mirpur',
    fullName: 'Padma 1 (Mirpur Route)',
    code: 'Dhaka Metro Cha 11-4201',
    speed: '34 km/h',
    eta: '2 min',
    nextStop: 'Mirpur 10 Roundabout',
    status: 'On Time',
    passengers: 58,
    checkpoints: FALL_25_SCHEDULE.map(s => s.stopEn)
  },
  'padma-2': {
    id: 'padma-2',
    busId: 'bus_2',
    routeId: 'route_mirpur_2',
    name: 'Padma 2 • Mirpur',
    fullName: 'Padma 2 (Mirpur Route)',
    code: 'Dhaka Metro Cha 11-4202',
    speed: '28 km/h',
    eta: '8 min',
    nextStop: 'Mirpur 11.5',
    status: 'On Time',
    passengers: 64,
    checkpoints: FALL_25_SCHEDULE.map(s => s.stopEn)
  }
};

let activeBusKey = 'padma-1';

function applyFirstBusAssignmentState() {
  if (firstBusAssignment === 'padma-1') {
    busRoutesData['padma-1'].name = 'Padma 1 (1st Bus • 06:45 AM)';
    busRoutesData['padma-1'].fullName = 'Padma 1 (1st Bus • 06:45 AM Departure)';
    busRoutesData['padma-2'].name = 'Padma 2 (2nd Bus • 08:30 AM)';
    busRoutesData['padma-2'].fullName = 'Padma 2 (2nd Bus • 08:30 AM Departure)';
  } else {
    busRoutesData['padma-1'].name = 'Padma 1 (2nd Bus • 08:30 AM)';
    busRoutesData['padma-1'].fullName = 'Padma 1 (2nd Bus • 08:30 AM Departure)';
    busRoutesData['padma-2'].name = 'Padma 2 (1st Bus • 06:45 AM)';
    busRoutesData['padma-2'].fullName = 'Padma 2 (1st Bus • 06:45 AM Departure)';
  }
  updateTrackerUI();
  renderBusScheduleModal();
}

// Fetch live GPS telemetry from Supabase live_bus_locations
async function syncLiveBusTelemetry() {
  if (typeof SupabaseDb !== 'undefined') {
    try {
      const [locations, buses, routes] = await Promise.all([
        SupabaseDb.fetchLiveBusLocations(),
        SupabaseDb.fetchBuses(),
        SupabaseDb.fetchRoutes()
      ]);

      if (locations && Array.isArray(locations) && locations.length > 0) {
        locations.forEach(loc => {
          const key = loc.bus_id === 'bus_1' ? 'padma-1' : (loc.bus_id === 'bus_2' ? 'padma-2' : null);
          if (key && busRoutesData[key]) {
            busRoutesData[key].speed = `${Math.round(loc.speed_kmh || 30)} km/h`;
            busRoutesData[key].eta = `${loc.eta_minutes || 2} min`;
            busRoutesData[key].nextStop = loc.next_stop_name || busRoutesData[key].nextStop;
            busRoutesData[key].status = loc.status === 'onTime' ? 'On Time' : (loc.status || 'Active');
            busRoutesData[key].passengers = loc.passenger_count || busRoutesData[key].passengers;
          }
        });
        updateTrackerUI();
      }
    } catch (e) {
      console.warn('Sync live bus telemetry warning:', e);
    }
  }
}

// Update Tracker UI elements with active telemetry
function updateTrackerUI() {
  const data = busRoutesData[activeBusKey];
  if (!data) return;

  const activePill = document.getElementById('active-bus-header-pill');
  const hudCode = document.getElementById('hud-bus-code');
  const hudSpeed = document.getElementById('hud-bus-speed');
  const etaDisplay = document.getElementById('eta-min-display');
  const etaSubText = document.getElementById('eta-sub-text');
  const etaCheckpoint = document.getElementById('eta-checkpoint-title');

  if (activePill) activePill.textContent = data.name;
  if (hudCode) hudCode.textContent = data.code;
  if (hudSpeed) hudSpeed.textContent = data.speed;
  if (etaDisplay) etaDisplay.textContent = (data.eta || '2').replace(/[^0-9]/g, '') || '2';
  if (etaCheckpoint) etaCheckpoint.textContent = data.nextStop;
  if (etaSubText) etaSubText.textContent = `Arriving at ${data.nextStop}`;

  // Update order indicator on tracker cards
  const isFirst = (activeBusKey === firstBusAssignment);
  const busOrderBadge = document.getElementById('active-bus-order-badge');
  if (busOrderBadge) {
    busOrderBadge.innerHTML = isFirst
      ? `<span class="px-2 py-0.5 rounded-md bg-primary/20 text-primary text-[10px] font-extrabold border border-primary/40">1ST BUS • 06:45 AM DEPARTURE</span>`
      : `<span class="px-2 py-0.5 rounded-md bg-warning/20 text-warning text-[10px] font-extrabold border border-warning/40">2ND BUS • 08:30 AM DEPARTURE</span>`;
  }
}

function openBusSelectorModal() {
  const modal = document.getElementById('bus-select-modal');
  if (modal) modal.showModal();
}

function closeBusSelectorModal() {
  const modal = document.getElementById('bus-select-modal');
  if (modal) modal.close();
}

function selectBusRoute(key) {
  if (!busRoutesData[key]) return;

  activeBusKey = key;
  updateTrackerUI();
  closeBusSelectorModal();

  if (window.showAppToast) {
    window.showAppToast(`Switched active route to ${busRoutesData[key].fullName}`);
  }
}

// Open / Close Fall 25 Schedule Modal
function openBusScheduleModal() {
  renderBusScheduleModal();
  const modal = document.getElementById('bus-schedule-modal');
  if (modal) modal.showModal();
}

function closeBusScheduleModal() {
  const modal = document.getElementById('bus-schedule-modal');
  if (modal) modal.close();
}

// Admin confirmation of 1st Bus
function setFirstBusAssignment(busKey, broadcast = true) {
  firstBusAssignment = busKey;
  localStorage.setItem('padma_first_bus_id', busKey);
  applyFirstBusAssignmentState();

  const firstBusName = busKey === 'padma-1' ? 'Padma 1' : 'Padma 2';
  const secondBusName = busKey === 'padma-1' ? 'Padma 2' : 'Padma 1';

  if (broadcast && window.showAppToast) {
    window.showAppToast(`📢 Admin Confirmed: ${firstBusName} is 1st Bus (06:45 AM), ${secondBusName} is 2nd Bus (08:30 AM)!`);
  }

  // Push notification to notifications system if present
  if (typeof addAppNotification === 'function') {
    addAppNotification({
      title: '🚌 Fall 25 Bus Schedule Update',
      message: `Transport Admin confirmed ${firstBusName} will operate as 1st Bus (06:45 AM departure) and ${secondBusName} as 2nd Bus (08:30 AM departure) today.`,
      type: 'SCHEDULE',
      time: 'Just now'
    });
  }

  // Broadcast to other components via custom event
  window.dispatchEvent(new CustomEvent('padma_first_bus_updated', {
    detail: { firstBus: busKey, firstBusName, secondBusName }
  }));
}

// Render Fall 25 Schedule Table into #bus-schedule-modal
function renderBusScheduleModal() {
  const container = document.getElementById('bus-schedule-modal-content');
  if (!container) return;

  const isBus1First = firstBusAssignment === 'padma-1';
  const firstBusTitle = isBus1First ? 'Padma 1 (পদ্মা ১)' : 'Padma 2 (পদ্মা ২)';
  const secondBusTitle = isBus1First ? 'Padma 2 (পদ্মা ২)' : 'Padma 1 (পদ্মা ১)';

  const currentUser = JSON.parse(localStorage.getItem('padma_user') || '{}');
  const isAdmin = currentUser.role === 'admin' || (currentUser.email && currentUser.email.includes('admin'));

  let adminControlsHtml = '';
  if (isAdmin) {
    adminControlsHtml = `
      <div class="mb-3.5 p-3 rounded-xl bg-surface-highest/60 border border-border-line/40">
        <div class="flex items-center gap-2 mb-2 text-warning">
          <span class="material-symbols-outlined text-[18px]">admin_panel_settings</span>
          <span class="text-xs font-bold uppercase tracking-wider">Admin Control: Confirm 1st Bus</span>
        </div>
        <div class="grid grid-cols-2 gap-2">
          <button onclick="setFirstBusAssignment('padma-1')" class="py-2 px-3 rounded-lg text-xs font-bold transition-all ${isBus1First ? 'bg-primary text-on-primary shadow' : 'bg-surface-container hover:bg-surface-bright text-text-secondary'}">
            Padma 1 as 1st Bus
          </button>
          <button onclick="setFirstBusAssignment('padma-2')" class="py-2 px-3 rounded-lg text-xs font-bold transition-all ${!isBus1First ? 'bg-warning text-on-secondary shadow' : 'bg-surface-container hover:bg-surface-bright text-text-secondary'}">
            Padma 2 as 1st Bus
          </button>
        </div>
      </div>
    `;
  }

  let rowsHtml = '';
  FALL_25_SCHEDULE.forEach((stop, index) => {
    const isEven = index % 2 === 0;
    rowsHtml += `
      <tr class="${isEven ? 'bg-surface/50' : 'bg-surface-elevated/40'} border-b border-[#7f1d1d]/20 text-xs">
        <td class="py-2 px-2 text-center">
          <div class="font-extrabold text-primary">${stop.time1Bn}</div>
          <div class="text-[9px] text-text-muted">${stop.time1En}</div>
        </td>
        <td class="py-2 px-2 text-center">
          <div class="font-bold text-text-primary text-[11px] leading-tight">${stop.stopBn}</div>
          <div class="text-[9px] text-text-secondary">${stop.stopEn}</div>
        </td>
        <td class="py-2 px-2 text-center">
          <div class="font-extrabold text-warning">${stop.time2Bn}</div>
          <div class="text-[9px] text-text-muted">${stop.time2En}</div>
        </td>
      </tr>
    `;
  });

  container.innerHTML = `
    <!-- Header Summary Card -->
    <div class="p-3.5 mb-3 rounded-2xl bg-gradient-to-r from-primary/15 to-warning/15 border border-primary/30">
      <div class="flex items-center justify-between mb-1.5">
        <span class="px-2 py-0.5 rounded bg-primary text-on-primary text-[10px] font-black uppercase tracking-wider">ADMIN CONFIRMED</span>
        <span class="text-xs font-bold text-text-muted">FALL 2025</span>
      </div>
      <div class="text-xs space-y-1">
        <div class="flex items-center justify-between">
          <span class="text-text-secondary">১ম বাস (1st Bus):</span>
          <span class="font-extrabold text-primary">${firstBusTitle} • ০৬:৪৫ AM</span>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-text-secondary">২য় বাস (2nd Bus):</span>
          <span class="font-extrabold text-warning">${secondBusTitle} • ০৮:৩০ AM</span>
        </div>
      </div>
    </div>

    ${adminControlsHtml}

    <!-- Timetable Table -->
    <div class="rounded-xl overflow-hidden border border-[#7f1d1d]/60 mb-3 bg-surface-elevated shadow-md">
      <!-- Subheader showing bus assignment -->
      <div class="bg-[#450a0a] py-2 px-3 flex items-center justify-between text-center border-b border-[#7f1d1d]/40">
        <div class="w-1/3 text-[11px] font-extrabold text-[#fecaca] leading-tight">
          (পদ্মা ১ম বাস)<br/><span class="text-primary">${firstBusTitle.split(' ')[0]} ${firstBusTitle.split(' ')[1]}</span>
        </div>
        <div class="w-1/3 flex items-center justify-center gap-1 text-white text-xs font-black">
          <span class="material-symbols-outlined text-[16px]">directions_bus</span>
          <span>FALL 25</span>
        </div>
        <div class="w-1/3 text-[11px] font-extrabold text-[#fecaca] leading-tight">
          (পদ্মা ২য় বাস)<br/><span class="text-warning">${secondBusTitle.split(' ')[0]} ${secondBusTitle.split(' ')[1]}</span>
        </div>
      </div>

      <!-- Column headers -->
      <table class="w-full text-left border-collapse">
        <thead>
          <tr class="bg-[#991b1b] text-white text-[11px] font-black tracking-wider uppercase">
            <th class="py-2 px-2 text-center w-[28%]">TIME</th>
            <th class="py-2 px-2 text-center w-[44%]">STOPPAGE (স্টপেজ)</th>
            <th class="py-2 px-2 text-center w-[28%]">TIME</th>
          </tr>
        </thead>
        <tbody>
          ${rowsHtml}
        </tbody>
      </table>
    </div>

    <!-- Return Trips Banner -->
    <div class="p-3 mb-2.5 rounded-xl bg-[#7f1d1d]/25 border border-[#ef4444]/40 text-center">
      <div class="flex items-center justify-center gap-1.5 text-[#fecaca] text-xs font-bold mb-0.5">
        <span class="material-symbols-outlined text-[16px]">replay</span>
        <span>ফিরতি বাস (Return Trips)</span>
      </div>
      <div class="text-sm font-extrabold text-white">
        দুপুর ৩.৪৫ (03:45 PM) &amp; সন্ধ্যা ৬.১৫ (06:15 PM)
      </div>
    </div>

    <!-- 10 min early arrival advisory -->
    <div class="p-2.5 rounded-xl bg-surface-highest/50 border border-border-line/40 flex items-start gap-2 text-text-secondary text-[11px] leading-snug">
      <span class="material-symbols-outlined text-warning text-[18px] shrink-0 mt-0.5">info</span>
      <div>
        <span class="font-bold text-text-primary">বিঃদ্রঃ</span>- স্টপেজে উল্লেখিত নির্ধারিত সময়ের <span class="text-warning font-bold">১০ মিনিট পূর্বে</span> স্টপেজে দাঁড়ানোর জন্য অনুরোধ করা হলো।
      </div>
    </div>
  `;
}

function initTrackerInteractions() {
  applyFirstBusAssignmentState();

  const recenterBtn = document.getElementById('recenter-map-btn');
  if (recenterBtn) {
    recenterBtn.addEventListener('click', () => {
      recenterBtn.classList.add('rotate-45');
      setTimeout(() => recenterBtn.classList.remove('rotate-45'), 300);
      syncLiveBusTelemetry();
      if (window.showAppToast) {
        window.showAppToast('Map centered on active bus GPS beacon');
      }
    });
  }

  // Initial fetch and start periodic live telemetry sync every 10 seconds
  syncLiveBusTelemetry();
  setInterval(syncLiveBusTelemetry, 10000);
}

// Expose globally
window.openBusScheduleModal = openBusScheduleModal;
window.closeBusScheduleModal = closeBusScheduleModal;
window.setFirstBusAssignment = setFirstBusAssignment;
window.openBusSelectorModal = openBusSelectorModal;
window.closeBusSelectorModal = closeBusSelectorModal;
window.selectBusRoute = selectBusRoute;

document.addEventListener('DOMContentLoaded', initTrackerInteractions);
