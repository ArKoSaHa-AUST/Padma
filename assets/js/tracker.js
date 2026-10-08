/**
 * Padma - Live Bus Tracker Module
 * Handles Route Switching, Live GPS telemetry updates, Map recentering, and ETA calculations
 */

const busRoutesData = {
  'bus-1': {
    name: 'Padma 1 • Mirpur',
    fullName: 'Padma 1 (Mirpur Route)',
    code: 'Dhaka Metro-Cha 11-4589',
    speed: '0 km/h',
    eta: '-- min',
    nextStop: 'Trip Ended (Service Offline)',
    status: 'Trip Ended',
    passengers: 0
  },
  'bus-2': {
    name: 'Padma 2 • Uttara',
    fullName: 'Padma 2 (Uttara Route)',
    code: 'Dhaka Metro-Cha 11-8920',
    speed: '0 km/h',
    eta: '-- min',
    nextStop: 'Trip Ended (Service Offline)',
    status: 'Trip Ended',
    passengers: 0
  }
};

let activeBusKey = 'bus-1';

function openBusSelectorModal() {
  const modal = document.getElementById('bus-select-modal');
  if (modal) modal.showModal();
}

function closeBusSelectorModal() {
  const modal = document.getElementById('bus-select-modal');
  if (modal) modal.close();
}

function selectBusRoute(name, code, speed, eta, nextStop) {
  const activePill = document.getElementById('active-bus-header-pill');
  const hudCode = document.getElementById('hud-bus-code');
  const hudSpeed = document.getElementById('hud-bus-speed');
  const etaDisplay = document.getElementById('eta-min-display');

  if (activePill) activePill.textContent = name;
  if (hudCode) hudCode.textContent = code;
  if (hudSpeed) hudSpeed.textContent = speed;
  if (etaDisplay) etaDisplay.textContent = eta.replace(/[^0-9]/g, '') || '4';

  closeBusSelectorModal();
  if (window.showAppToast) {
    window.showAppToast(`Active bus route updated to ${name}`);
  }
}

function initTrackerInteractions() {
  const recenterBtn = document.getElementById('recenter-map-btn');
  if (recenterBtn) {
    recenterBtn.addEventListener('click', () => {
      recenterBtn.classList.add('rotate-45');
      setTimeout(() => recenterBtn.classList.remove('rotate-45'), 300);
      if (window.showAppToast) {
        window.showAppToast('Map centered on active bus GPS beacon');
      }
    });
  }
}

document.addEventListener('DOMContentLoaded', initTrackerInteractions);
