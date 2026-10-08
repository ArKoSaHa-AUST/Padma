/**
 * Padma - Student Assistance Module
 * 1. Blood Request Desk (Connected to Supabase blood_requests table)
 * 2. Lost & Found Noticeboard (Connected to Supabase lost_found_items table)
 * 3. Submit Complain / Grievance Document (Connected to Supabase feedback table)
 */

const BLOOD_DB_KEY = 'padma_blood_requests_db';
const LOST_FOUND_DB_KEY = 'padma_lost_found_db';
const COMPLAINTS_DB_KEY = 'padma_complaints_db';

// Initial Seed Data for offline resilience
function initializeRequestsDatabase() {
  if (!localStorage.getItem(BLOOD_DB_KEY)) {
    const initialBlood = [
      {
        id: 'br_1',
        title: 'Urgent O+ Blood Needed for Surgery',
        bloodGroup: 'O+',
        hospitalName: 'Dhaka Medical College Hospital (DMCH)',
        patientDetails: 'Post-operative cardiac patient in ICU Bed 14',
        messageBody: 'Patient scheduled for bypass surgery tomorrow morning at 8:00 AM. Requires 2 bags of fresh whole blood.',
        requiredDate: 'Tomorrow, 8:00 AM',
        contactNumber: '01711-889900',
        emailAddress: 'siam.chowdhury@aust.edu',
        extraInformation: 'Cross-matching blood sample ready at DMCH blood bank counter #3',
        authorTag: 'Siam_CSE_3-1_Mirpur10',
        authorName: 'Siam Chowdhury',
        timestamp: Date.now() - 3600000 * 2
      }
    ];
    localStorage.setItem(BLOOD_DB_KEY, JSON.stringify(initialBlood));
  }

  if (!localStorage.getItem(LOST_FOUND_DB_KEY)) {
    const initialLostFound = [
      {
        id: 'lf_1',
        itemType: 'LOST',
        title: 'Scientific Calculator FX-991EX',
        description: 'Left in Classroom 4A03 after Math exam. Has red sticker on back.',
        imageUrl: '',
        location: 'Room 4A03, Academic Building',
        contact: '01700-112233',
        authorTag: 'Sadia_CSE_2-2_Campus',
        authorName: 'Sadia Afrin',
        timestamp: Date.now() - 3600000 * 4
      }
    ];
    localStorage.setItem(LOST_FOUND_DB_KEY, JSON.stringify(initialLostFound));
  }

  if (!localStorage.getItem(COMPLAINTS_DB_KEY)) {
    const initialComplaints = [
      {
        id: 'cmp_1',
        title: 'Severe Overcrowding at Mirpur 10 Morning Pickup',
        body: 'Due to ongoing semester finals, more than 80 students queued at Mirpur 10 at 7:35 AM while Padma 1 was already at 90% seating capacity from Mirpur 12. Kindly deploy an auxiliary feeder shuttle for examination weeks.',
        imageUrl: '',
        studentName: 'Padma Student',
        studentId: '2023202420252026',
        studentEmail: 'padmaStudent@aust.edu',
        department: 'CSE',
        semester: '4-1',
        pickupDestination: 'Mirpur 10',
        authorTag: 'Padma_CSE_4-1_Mirpur10',
        status: 'Under Review',
        timestamp: Date.now() - 3600000 * 6
      }
    ];
    localStorage.setItem(COMPLAINTS_DB_KEY, JSON.stringify(initialComplaints));
  }
}

initializeRequestsDatabase();

// -------------------------------------------------------------
// 1. Blood Requests Module (Supabase Connected)
// -------------------------------------------------------------
function getBloodRequests() {
  return JSON.parse(localStorage.getItem(BLOOD_DB_KEY) || '[]');
}

async function syncBloodRequestsFromSupabase() {
  if (typeof SupabaseDb !== 'undefined') {
    try {
      const data = await SupabaseDb.fetchBloodRequests();
      if (data && Array.isArray(data) && data.length > 0) {
        const mapped = data.map(b => ({
          id: b.id,
          title: `Urgent ${b.blood_group} Blood for Patient at ${b.hospital}`,
          bloodGroup: b.blood_group,
          hospitalName: `${b.hospital} (${b.location || 'Dhaka'})`,
          patientDetails: b.notes || 'Emergency requirement',
          messageBody: b.notes || '',
          requiredDate: b.needed_by ? new Date(b.needed_by).toLocaleDateString() : 'Immediate',
          contactNumber: b.requester_phone,
          emailAddress: 'attendant@aust.edu',
          extraInformation: `Units needed: ${b.units || 1}. Status: ${b.status || 'Active'}`,
          authorTag: `${(b.requester_name || 'Student').split(' ')[0]}_AUST_DonorDesk`,
          authorName: b.requester_name || 'AUST Commuter',
          timestamp: new Date(b.created_at).getTime()
        }));
        localStorage.setItem(BLOOD_DB_KEY, JSON.stringify(mapped));
      }
    } catch (e) {
      console.warn('Sync blood requests warning:', e);
    }
  }
}

function openBloodRequestModal() {
  const modal = document.getElementById('blood-request-modal');
  if (modal) modal.showModal();
}

function closeBloodRequestModal() {
  const modal = document.getElementById('blood-request-modal');
  if (modal) modal.close();
}

async function submitBloodRequest() {
  const user = getCurrentUser();
  if (!user) {
    if (window.showAppToast) window.showAppToast('Please sign in to post blood requests', true);
    if (window.switchScreen) window.switchScreen('signin');
    return;
  }

  const title = document.getElementById('blood-req-title')?.value.trim();
  const bloodGroup = document.getElementById('blood-req-group')?.value || 'O+';
  const hospitalName = document.getElementById('blood-req-hospital')?.value.trim();
  const patientDetails = document.getElementById('blood-req-patient')?.value.trim() || '';
  const messageBody = document.getElementById('blood-req-body')?.value.trim() || '';
  const requiredDate = document.getElementById('blood-req-date')?.value.trim() || 'Immediate';
  const contactNumber = document.getElementById('blood-req-contact')?.value.trim();
  const emailAddress = document.getElementById('blood-req-email')?.value.trim() || user.email;
  const extraInformation = document.getElementById('blood-req-extra')?.value.trim() || '';

  if (!title || !hospitalName || !contactNumber) {
    if (window.showAppToast) window.showAppToast('Title, Hospital and Contact are required!', true);
    return;
  }

  const authorTag = formatChatTag(user);
  const reqId = 'br_' + Date.now();

  const newRequest = {
    id: reqId,
    title,
    bloodGroup,
    hospitalName,
    patientDetails,
    messageBody,
    requiredDate,
    contactNumber,
    emailAddress,
    extraInformation,
    authorTag,
    authorName: user.name,
    timestamp: Date.now()
  };

  const list = getBloodRequests();
  list.unshift(newRequest);
  localStorage.setItem(BLOOD_DB_KEY, JSON.stringify(list));

  // Insert into Supabase blood_requests table
  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.postBloodRequest({
        id: reqId,
        requester_id: user.id,
        requester_name: user.name,
        requester_phone: contactNumber,
        blood_group: bloodGroup,
        units: 2,
        hospital: hospitalName,
        location: user.pickupDestination || 'Dhaka',
        needed_by: new Date(Date.now() + 24 * 3600 * 1000).toISOString(),
        urgency: 'critical',
        status: 'active',
        notes: `${title}. ${messageBody} ${patientDetails}`
      });
    } catch (e) {
      console.warn('Supabase post blood request warning:', e);
    }
  }

  closeBloodRequestModal();
  renderBloodRequestsFeed();

  if (window.showAppToast) {
    window.showAppToast(`Emergency ${bloodGroup} blood request broadcasted to campus!`, true);
  }

  if (window.dispatchBloodNotification) {
    window.dispatchBloodNotification(newRequest);
  }
}

async function renderBloodRequestsFeed() {
  const container = document.getElementById('blood-requests-feed');
  if (!container) return;

  await syncBloodRequestsFromSupabase();

  const requests = getBloodRequests();
  if (requests.length === 0) {
    container.innerHTML = `
      <div class="py-12 flex flex-col items-center justify-center text-center text-text-muted">
        <span class="material-symbols-outlined text-4xl mb-2 text-urgent/40">water_drop</span>
        <p class="text-sm font-bold">No active blood donation requests</p>
        <p class="text-xs text-text-muted mt-1">Campus donors are on standby.</p>
      </div>
    `;
    return;
  }

  container.innerHTML = requests.map(req => {
    return `
      <article class="req-card blood-req relative flex flex-col rounded-2xl bg-surface-elevated p-4 shadow-md border-l-4 border-urgent animate-fade-in">
        <div class="flex items-center justify-between gap-2 flex-wrap">
          <div class="flex items-center gap-2 flex-wrap">
            <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-urgent text-white text-xs font-bold shadow-sm">
              <span class="material-symbols-outlined text-[14px]">water_drop</span>
              ${escapeHtml(req.bloodGroup)}
            </span>
            <span class="text-xs text-urgent font-bold uppercase tracking-wider">Required: ${escapeHtml(req.requiredDate)}</span>
          </div>
          <span class="text-[11px] text-text-muted">@${escapeHtml(req.authorTag)}</span>
        </div>

        <h3 class="text-base font-bold text-text-primary mt-2.5 leading-snug">${escapeHtml(req.title)}</h3>
        
        ${req.messageBody ? `<p class="text-xs text-text-secondary mt-1 leading-relaxed">${escapeHtml(req.messageBody)}</p>` : ''}
        
        <div class="mt-3 p-3 rounded-xl bg-surface-highest/60 space-y-1.5 text-xs">
          <div class="flex items-center gap-2 text-text-secondary">
            <span class="material-symbols-outlined text-urgent text-[16px] shrink-0">local_hospital</span>
            <span class="text-text-primary font-medium truncate">${escapeHtml(req.hospitalName)}</span>
          </div>
          ${req.patientDetails ? `
          <div class="flex items-center gap-2 text-text-secondary">
            <span class="material-symbols-outlined text-text-muted text-[16px] shrink-0">info</span>
            <span class="truncate">${escapeHtml(req.patientDetails)}</span>
          </div>` : ''}
          ${req.extraInformation ? `
          <div class="flex items-center gap-2 text-text-secondary">
            <span class="material-symbols-outlined text-text-muted text-[16px] shrink-0">medical_services</span>
            <span class="truncate">${escapeHtml(req.extraInformation)}</span>
          </div>` : ''}
        </div>

        <div class="grid grid-cols-2 gap-2 mt-3">
          <a class="h-10 flex items-center justify-center gap-1.5 rounded-xl bg-primary-container text-on-primary text-xs font-bold transition-all shadow-sm" href="tel:${escapeHtml(req.contactNumber)}">
            <span class="material-symbols-outlined text-[18px]">call</span>
            <span>Call Attendant</span>
          </a>
          <a class="h-10 flex items-center justify-center gap-1.5 rounded-xl bg-urgent/15 hover:bg-urgent/25 text-urgent text-xs font-bold transition-all" href="mailto:${escapeHtml(req.emailAddress)}?subject=Padma Blood Donation Volunteer for ${encodeURIComponent(req.bloodGroup)}">
            <span class="material-symbols-outlined text-[18px]">volunteer_activism</span>
            <span>I Can Donate</span>
          </a>
        </div>
      </article>
    `;
  }).join('');
}

// -------------------------------------------------------------
// 2. Lost and Found Module (Supabase Connected)
// -------------------------------------------------------------
function getLostFoundItems() {
  return JSON.parse(localStorage.getItem(LOST_FOUND_DB_KEY) || '[]');
}

async function syncLostFoundFromSupabase() {
  if (typeof SupabaseDb !== 'undefined') {
    try {
      const data = await SupabaseDb.fetchLostFoundItems();
      if (data && Array.isArray(data) && data.length > 0) {
        const mapped = data.map(item => ({
          id: item.id,
          itemType: (item.type || 'LOST').toUpperCase(),
          title: item.title,
          description: item.description,
          imageUrl: item.image_url || '',
          location: item.location || 'AUST Campus',
          contact: item.contact || '+880 1...',
          authorTag: `${(item.author_name || 'Student').split(' ')[0]}_AUST_Transit`,
          authorName: item.author_name || 'AUST Student',
          timestamp: new Date(item.created_at).getTime()
        }));
        localStorage.setItem(LOST_FOUND_DB_KEY, JSON.stringify(mapped));
      }
    } catch (e) {
      console.warn('Sync lost & found warning:', e);
    }
  }
}

function openLostFoundModal() {
  const modal = document.getElementById('lost-found-modal');
  if (modal) modal.showModal();
}

function closeLostFoundModal() {
  const modal = document.getElementById('lost-found-modal');
  if (modal) modal.close();
}

async function submitLostFoundItem() {
  const user = getCurrentUser();
  if (!user) {
    if (window.showAppToast) window.showAppToast('Please sign in to post in Lost & Found', true);
    if (window.switchScreen) window.switchScreen('signin');
    return;
  }

  const itemType = document.getElementById('lf-type')?.value || 'LOST';
  const title = document.getElementById('lf-title')?.value.trim();
  const description = document.getElementById('lf-desc')?.value.trim();
  const imageUrl = document.getElementById('lf-img')?.value.trim() || '';
  const location = document.getElementById('lf-location')?.value.trim() || 'AUST Campus';
  const contact = document.getElementById('lf-contact')?.value.trim() || user.email;

  if (!title || !description) {
    if (window.showAppToast) window.showAppToast('Please provide a title and description', true);
    return;
  }

  const authorTag = formatChatTag(user);
  const itemId = 'lf_' + Date.now();

  const newItem = {
    id: itemId,
    itemType,
    title,
    description,
    imageUrl,
    location,
    contact,
    authorTag,
    authorName: user.name,
    timestamp: Date.now()
  };

  const list = getLostFoundItems();
  list.unshift(newItem);
  localStorage.setItem(LOST_FOUND_DB_KEY, JSON.stringify(list));

  // Insert into Supabase lost_found_items table
  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.postLostFoundItem({
        id: itemId,
        title: title,
        description: description,
        type: itemType.toLowerCase(),
        location: location,
        contact: contact,
        image_url: imageUrl || null,
        author_name: `${user.name} (${user.department} ${user.semester})`,
        author_id: user.id,
        status: 'active'
      });
    } catch (e) {
      console.warn('Supabase post lost found warning:', e);
    }
  }

  closeLostFoundModal();
  renderLostFoundFeed();

  if (window.showAppToast) {
    window.showAppToast(`Posted ${itemType.toLowerCase()} notice successfully`);
  }

  if (window.dispatchLostFoundNotification) {
    window.dispatchLostFoundNotification(newItem);
  }
}

async function renderLostFoundFeed() {
  const container = document.getElementById('lost-found-feed');
  if (!container) return;

  await syncLostFoundFromSupabase();

  const items = getLostFoundItems();
  if (items.length === 0) {
    container.innerHTML = `
      <div class="py-12 flex flex-col items-center justify-center text-center text-text-muted">
        <span class="material-symbols-outlined text-4xl mb-2 text-warning/40">find_in_page</span>
        <p class="text-sm font-bold">No Lost & Found notices</p>
        <p class="text-xs text-text-muted mt-1">All items on Padma transit have been returned.</p>
      </div>
    `;
    return;
  }

  container.innerHTML = items.map(item => {
    const isLost = item.itemType === 'LOST';
    return `
      <article class="relative flex flex-col rounded-2xl bg-surface-elevated p-4 shadow-md border-l-4 ${isLost ? 'border-warning' : 'border-success'} animate-fade-in">
        <div class="flex items-center justify-between gap-2">
          <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full ${isLost ? 'bg-warning/20 text-warning' : 'bg-success/20 text-success'} text-xs font-bold">
            <span class="material-symbols-outlined text-[14px]">${isLost ? 'help' : 'check_circle'}</span>
            ${escapeHtml(item.itemType)}
          </span>
          <span class="text-[11px] text-text-muted">@${escapeHtml(item.authorTag)}</span>
        </div>

        <h3 class="text-base font-bold text-text-primary mt-2 leading-snug">${escapeHtml(item.title)}</h3>
        <p class="text-xs text-text-secondary mt-1 leading-relaxed">${escapeHtml(item.description)}</p>

        ${item.imageUrl ? `
        <div class="mt-2.5 rounded-xl overflow-hidden max-h-48 border border-border-line/40">
          <img src="${escapeHtml(item.imageUrl)}" alt="Item image" class="w-full h-full object-cover"/>
        </div>` : ''}

        <div class="mt-3 p-2.5 rounded-xl bg-surface-highest/60 flex items-center justify-between text-xs">
          <div class="flex items-center gap-1.5 text-text-secondary truncate">
            <span class="material-symbols-outlined text-primary text-[16px]">location_on</span>
            <span class="truncate">${escapeHtml(item.location)}</span>
          </div>
          <a href="tel:${escapeHtml(item.contact)}" class="text-primary font-bold hover:underline flex items-center gap-1 shrink-0 ml-2">
            <span class="material-symbols-outlined text-[15px]">call</span>
            <span>Contact</span>
          </a>
        </div>
      </article>
    `;
  }).join('');
}

// -------------------------------------------------------------
// 3. Submit Complain (Google Docs-Style Grievance with Supabase feedback Table)
// -------------------------------------------------------------
function getComplaintsList() {
  return JSON.parse(localStorage.getItem(COMPLAINTS_DB_KEY) || '[]');
}

async function syncComplaintsFromSupabase() {
  if (typeof SupabaseDb !== 'undefined') {
    try {
      const data = await SupabaseDb.fetchComplaints();
      if (data && Array.isArray(data) && data.length > 0) {
        const mapped = data.map(c => ({
          id: c.id,
          title: c.message.split('.')[0] || 'Transit Grievance',
          body: c.message,
          imageUrl: c.attachment_url || '',
          studentName: c.user_name || 'Student',
          studentId: c.user_id || '2023202420252026',
          studentEmail: 'student@aust.edu',
          department: 'AUST',
          semester: 'Active',
          pickupDestination: 'Transit Route',
          authorTag: `${(c.user_name || 'Student').split(' ')[0]}_AUST_Grievance`,
          status: c.status || 'Under Review',
          timestamp: new Date(c.created_at).getTime()
        }));
        localStorage.setItem(COMPLAINTS_DB_KEY, JSON.stringify(mapped));
      }
    } catch (e) {
      console.warn('Sync complaints warning:', e);
    }
  }
}

async function submitComplaintDocument() {
  const user = getCurrentUser();
  if (!user) {
    if (window.showAppToast) window.showAppToast('Please sign in to file a complaint', true);
    if (window.switchScreen) window.switchScreen('signin');
    return;
  }

  const title = document.getElementById('complain-doc-title')?.value.trim();
  const body = document.getElementById('complain-doc-body')?.value.trim();
  const imageUrl = document.getElementById('complain-doc-img')?.value.trim() || '';

  if (!title || !body) {
    if (window.showAppToast) window.showAppToast('Please provide a subject title and complaint narrative', true);
    return;
  }

  const authorTag = formatChatTag(user);
  const cmpId = 'cmp_' + Date.now();

  const newComplaint = {
    id: cmpId,
    title,
    body,
    imageUrl,
    studentName: user.name,
    studentId: user.studentId || user.id,
    studentEmail: user.email,
    department: user.department || 'CSE',
    semester: user.semester || '4-1',
    pickupDestination: user.pickupDestination || 'Campus',
    authorTag,
    status: 'Pending Admin Review',
    timestamp: Date.now()
  };

  const list = getComplaintsList();
  list.unshift(newComplaint);
  localStorage.setItem(COMPLAINTS_DB_KEY, JSON.stringify(list));

  // Insert into Supabase feedback table
  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.postComplaint({
        id: cmpId,
        user_id: user.id,
        user_name: `${user.name} (${user.studentId || user.id})`,
        category: 'schedule',
        message: `${title}: ${body}`,
        attachment_url: imageUrl || null,
        status: 'pending'
      });
    } catch (e) {
      console.warn('Supabase post complaint warning:', e);
    }
  }

  // Clear Form
  const titleInput = document.getElementById('complain-doc-title');
  const bodyInput = document.getElementById('complain-doc-body');
  const imgInput = document.getElementById('complain-doc-img');
  if (titleInput) titleInput.value = '';
  if (bodyInput) bodyInput.value = '';
  if (imgInput) imgInput.value = '';

  const confirmBanner = document.getElementById('complain-success-banner');
  if (confirmBanner) {
    confirmBanner.classList.remove('hidden');
    setTimeout(() => confirmBanner.classList.add('hidden'), 5000);
  }

  if (window.showAppToast) {
    window.showAppToast('Complaint document securely submitted to Transport Administration!');
  }

  renderComplaintsAdminFeed();
}

async function renderComplaintsAdminFeed() {
  const container = document.getElementById('admin-complaints-feed');
  if (!container) return;

  const user = getCurrentUser();
  const isAdmin = user && user.role === 'admin';

  if (!isAdmin) {
    container.innerHTML = `
      <div class="p-5 rounded-2xl bg-surface-elevated border border-border-line/40 text-center space-y-2">
        <div class="w-10 h-10 rounded-full bg-primary/20 text-primary flex items-center justify-center mx-auto">
          <span class="material-symbols-outlined text-2xl">privacy_tip</span>
        </div>
        <h4 class="font-bold text-sm text-text-primary">Confidential Grievance Protocol</h4>
        <p class="text-xs text-text-muted max-w-[320px] mx-auto">
          Complaints submitted via this document are encrypted and dispatched directly to AUST Transport Administration. Your records remain private.
        </p>
      </div>
    `;
    return;
  }

  await syncComplaintsFromSupabase();
  const complaints = getComplaintsList();

  if (complaints.length === 0) {
    container.innerHTML = `
      <div class="py-8 text-center text-text-muted text-xs">
        No active grievances in admin queue.
      </div>
    `;
    return;
  }

  container.innerHTML = `
    <div class="mb-3 flex items-center justify-between">
      <span class="text-xs font-bold text-primary uppercase tracking-wider">Administrative Grievance Inbox (${complaints.length})</span>
    </div>
  ` + complaints.map(c => {
    return `
      <div class="p-4 rounded-2xl bg-surface-sidebar border border-border-line/40 space-y-2 shadow my-2">
        <div class="flex items-center justify-between gap-2">
          <span class="px-2 py-0.5 rounded bg-warning/20 text-warning font-bold text-[10px] uppercase">${escapeHtml(c.status)}</span>
          <span class="text-[10px] text-text-muted">${new Date(c.timestamp).toLocaleDateString()}</span>
        </div>
        <h4 class="font-bold text-sm text-text-primary">${escapeHtml(c.title)}</h4>
        <p class="text-xs text-text-secondary leading-relaxed">${escapeHtml(c.body)}</p>
        <div class="pt-2 border-t border-border-line/40 flex flex-wrap gap-x-4 gap-y-1 text-[11px] text-text-muted">
          <span>Student: <strong class="text-text-primary">${escapeHtml(c.studentName)} (${escapeHtml(c.studentId)})</strong></span>
          <span>Dept: <strong class="text-text-primary">${escapeHtml(c.department)} (${escapeHtml(c.semester)})</strong></span>
          <span>Pickup: <strong class="text-text-primary">${escapeHtml(c.pickupDestination)}</strong></span>
          <span>Email: <strong class="text-text-primary">${escapeHtml(c.studentEmail)}</strong></span>
        </div>
      </div>
    `;
  }).join('');
}
