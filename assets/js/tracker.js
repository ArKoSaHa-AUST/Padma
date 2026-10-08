/**
 * Padma - Live Bus Tracker & Telemetry Module
 * Dynamic Supabase Integration with live_bus_locations, routes, and buses
 */

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
    checkpoints: ['Mirpur 14', 'Mirpur 10', 'Shewrapara', 'Farmgate', 'AUST Gate 2']
  },
  'padma-2': {
    id: 'padma-2',
    busId: 'bus_2',
    routeId: 'route_uttara',
    name: 'Padma 2 • Uttara',
    fullName: 'Padma 2 (Uttara Route)',
    code: 'Dhaka Metro Cha 11-4202',
    speed: '28 km/h',
    eta: '8 min',
    nextStop: 'Airport Footbridge',
    status: 'On Time',
    passengers: 64,
    checkpoints: ['House Building', 'Airport', 'Mohakhali', 'Nabisco', 'AUST Gate 1']
  }
};

let activeBusKey = 'padma-1';

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

function initTrackerInteractions() {
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

document.addEventListener('DOMContentLoaded', initTrackerInteractions);
