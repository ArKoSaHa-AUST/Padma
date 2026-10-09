/**
 * Padma - Student Assistance & Responses Module
 * 1. Blood Request Desk (Connected to Supabase blood_requests table)
 * 2. Lost & Found Noticeboard (Connected to Supabase lost_found_items table)
 * 3. Post Responses Channel (Connected to Supabase post_responses table for Blood & Lost/Found)
 * 4. Submit Complain / Grievance Document (Connected to Supabase feedback table)
 * Full CRUD (Create, Edit, Delete) and Real-Time Instant Live Updates
 */

const BLOOD_DB_KEY = 'padma_blood_requests_db';
const LOST_FOUND_DB_KEY = 'padma_lost_found_db';
const COMMENTS_DB_KEY = 'padma_post_comments_db';
const RESPONSES_DB_KEY = 'padma_post_responses_db';
const COMPLAINTS_DB_KEY = 'padma_complaints_db';

let activeResponsesFilter = 'all';
let activePostIdFilter = null;

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
        authorId: 'a0000000-0000-0000-0000-000000000004',
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
        authorId: 'a0000000-0000-0000-0000-000000000005',
        authorTag: 'Sadia_CSE_2-2_Campus',
        authorName: 'Sadia Afrin',
        timestamp: Date.now() - 3600000 * 4
      }
    ];
    localStorage.setItem(LOST_FOUND_DB_KEY, JSON.stringify(initialLostFound));
  }

  if (!localStorage.getItem(COMMENTS_DB_KEY)) {
    const initialComments = [
      {
        id: 'comm_1',
        postId: 'lf_1',
        userId: 'a0000000-0000-0000-0000-000000000001',
        userName: 'Padma Student',
        userTag: 'Padma_CSE_4-1_Mirpur10',
        content: 'I saw someone turn in a Casio FX-991EX at Room 4A03 lab desk. Check with Mr. Harun.',
        timestamp: Date.now() - 3600000 * 2,
        updatedAt: null
      }
    ];
    localStorage.setItem(COMMENTS_DB_KEY, JSON.stringify(initialComments));
  }

  if (!localStorage.getItem(RESPONSES_DB_KEY)) {
    const initialResponses = [
      {
        id: 'resp_br_1',
        postId: 'br_1',
        postType: 'blood',
        postTitle: 'Urgent O+ Blood Needed for Surgery',
        postSummary: 'O+ at Dhaka Medical College Hospital (DMCH)',
        requesterId: 'a0000000-0000-0000-0000-000000000004',
        requesterTag: 'Siam_CSE_3-1_Mirpur10',
        requesterName: 'Siam Chowdhury',
        responderId: 'a0000000-0000-0000-0000-000000000001',
        responderName: 'Padma Student',
        responderTag: 'Padma_CSE_4-1_Mirpur10',
        department: 'CSE',
        semester: '4-1',
        contactNumber: '01711-223344',
        fbLink: 'https://facebook.com/padmastudent',
        availability: 'Can donate today after 1:30 PM (after class)',
        notes: 'Eligible donor, verified O+ blood group, last donated 5 months ago.',
        status: 'pending',
        timestamp: Date.now() - 3600000
      },
      {
        id: 'resp_lf_1',
        postId: 'lf_1',
        postType: 'lost_found',
        postTitle: 'Scientific Calculator FX-991EX',
        postSummary: 'Room 4A03, Academic Building',
        requesterId: 'a0000000-0000-0000-0000-000000000005',
        requesterTag: 'Sadia_CSE_2-2_Campus',
        requesterName: 'Sadia Afrin',
        responderId: 'a0000000-0000-0000-0000-000000000001',
        responderName: 'Padma Student',
        responderTag: 'Padma_CSE_4-1_Mirpur10',
        department: 'CSE',
        semester: '4-1',
        contactNumber: '01711-223344',
        fbLink: 'https://facebook.com/padmastudent',
        availability: 'Available at AUST Library 3rd Floor',
        notes: 'I saw this calculator on Table 4 and handed it to Room 4A03 Lab Attendant Mr. Harun.',
        status: 'contacted',
        timestamp: Date.now() - 7200000
      }
    ];
    localStorage.setItem(RESPONSES_DB_KEY, JSON.stringify(initialResponses));
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
// 1. Blood Requests Module (Supabase Connected + Full CRUD)
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
          title: b.title || `Urgent ${b.blood_group} Blood for Patient at ${b.hospital}`,
          bloodGroup: b.blood_group,
          hospitalName: `${b.hospital} (${b.location || 'Dhaka'})`,
          patientDetails: b.patient_details || b.notes || 'Emergency requirement',
          messageBody: b.message_body || b.notes || '',
          requiredDate: b.needed_by ? new Date(b.needed_by).toLocaleDateString() : (b.required_date || 'Immediate'),
          contactNumber: b.requester_phone || b.contact_number,
          emailAddress: b.email_address || 'attendant@aust.edu',
          extraInformation: b.extra_info || `Units needed: ${b.units || 1}. Status: ${b.status || 'Active'}`,
          authorId: b.requester_id || b.author_id,
          authorTag: b.author_tag || `${(b.requester_name || 'Student').split(' ')[0]}_AUST_DonorDesk`,
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
    authorId: user.id,
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
      SupabaseDb.broadcastChange('blood_request_created', newRequest);
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

// Edit Blood Request
let editingBloodRequestId = null;

function openEditBloodRequestModal(reqId) {
  const requests = getBloodRequests();
  const req = requests.find(r => r.id === reqId);
  if (!req) return;

  editingBloodRequestId = reqId;

  const modal = document.getElementById('edit-blood-request-modal');
  if (!modal) return;

  document.getElementById('edit-blood-req-title').value = req.title || '';
  document.getElementById('edit-blood-req-group').value = req.bloodGroup || 'O+';
  document.getElementById('edit-blood-req-hospital').value = req.hospitalName || '';
  document.getElementById('edit-blood-req-patient').value = req.patientDetails || '';
  document.getElementById('edit-blood-req-date').value = req.requiredDate || '';
  document.getElementById('edit-blood-req-contact').value = req.contactNumber || '';
  document.getElementById('edit-blood-req-email').value = req.emailAddress || '';
  document.getElementById('edit-blood-req-body').value = req.messageBody || '';
  document.getElementById('edit-blood-req-extra').value = req.extraInformation || '';

  modal.showModal();
}

function closeEditBloodRequestModal() {
  const modal = document.getElementById('edit-blood-request-modal');
  if (modal) modal.close();
  editingBloodRequestId = null;
}

async function saveEditedBloodRequest() {
  if (!editingBloodRequestId) return;

  const title = document.getElementById('edit-blood-req-title')?.value.trim();
  const bloodGroup = document.getElementById('edit-blood-req-group')?.value || 'O+';
  const hospitalName = document.getElementById('edit-blood-req-hospital')?.value.trim();
  const patientDetails = document.getElementById('edit-blood-req-patient')?.value.trim() || '';
  const messageBody = document.getElementById('edit-blood-req-body')?.value.trim() || '';
  const requiredDate = document.getElementById('edit-blood-req-date')?.value.trim() || 'Immediate';
  const contactNumber = document.getElementById('edit-blood-req-contact')?.value.trim();
  const emailAddress = document.getElementById('edit-blood-req-email')?.value.trim();
  const extraInformation = document.getElementById('edit-blood-req-extra')?.value.trim() || '';

  if (!title || !hospitalName || !contactNumber) {
    if (window.showAppToast) window.showAppToast('Title, Hospital and Contact are required!', true);
    return;
  }

  const list = getBloodRequests();
  const idx = list.findIndex(r => r.id === editingBloodRequestId);
  if (idx !== -1) {
    list[idx] = {
      ...list[idx],
      title,
      bloodGroup,
      hospitalName,
      patientDetails,
      messageBody,
      requiredDate,
      contactNumber,
      emailAddress,
      extraInformation
    };
    localStorage.setItem(BLOOD_DB_KEY, JSON.stringify(list));

    if (typeof SupabaseDb !== 'undefined') {
      try {
        await SupabaseDb.updateBloodRequest(editingBloodRequestId, {
          blood_group: bloodGroup,
          hospital: hospitalName,
          requester_phone: contactNumber,
          notes: `${title}. ${messageBody} ${patientDetails}`
        });
        SupabaseDb.broadcastChange('blood_request_updated', list[idx]);
      } catch (e) {
        console.warn('Supabase update blood request warning:', e);
      }
    }

    closeEditBloodRequestModal();
    renderBloodRequestsFeed();

    if (window.showAppToast) {
      window.showAppToast('Blood request updated successfully in real-time!');
    }
  }
}

// Delete Blood Request
async function deleteBloodRequest(reqId) {
  if (!confirm('Are you sure you want to delete this blood request?')) return;

  let list = getBloodRequests();
  list = list.filter(r => r.id !== reqId);
  localStorage.setItem(BLOOD_DB_KEY, JSON.stringify(list));

  // Also remove associated responses
  let responses = getPostResponses();
  responses = responses.filter(resp => resp.postId !== reqId);
  savePostResponses(responses);

  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.deleteBloodRequest(reqId);
      SupabaseDb.broadcastChange('blood_request_deleted', { id: reqId });
    } catch (e) {
      console.warn('Supabase delete blood request warning:', e);
    }
  }

  renderBloodRequestsFeed();
  renderPostResponsesFeed();

  if (window.showAppToast) {
    window.showAppToast('Blood request deleted');
  }
}

async function renderBloodRequestsFeed() {
  const container = document.getElementById('blood-requests-feed');
  if (!container) return;

  await syncBloodRequestsFromSupabase();

  const user = getCurrentUser();
  const requests = getBloodRequests();
  const allResponses = getPostResponses();

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
    const isOwner = user && (user.id === req.authorId || user.chatTag === req.authorTag || user.role === 'admin');
    const responsesCount = allResponses.filter(r => r.postId === req.id).length;

    return `
      <article class="req-card blood-req relative flex flex-col rounded-2xl bg-surface-elevated p-4 shadow-md border-l-4 border-urgent animate-fade-in" id="card-${req.id}">
        <div class="flex items-center justify-between gap-2 flex-wrap">
          <div class="flex items-center gap-2 flex-wrap">
            <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-urgent text-white text-xs font-bold shadow-sm">
              <span class="material-symbols-outlined text-[14px]">water_drop</span>
              ${escapeHtml(req.bloodGroup)}
            </span>
            <span class="text-xs text-urgent font-bold uppercase tracking-wider">Required: ${escapeHtml(req.requiredDate)}</span>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-[11px] text-text-muted">@${escapeHtml(req.authorTag)}</span>
            ${isOwner ? `
              <div class="flex items-center gap-1 ml-1 bg-surface-highest/80 rounded-lg p-0.5 border border-border-line/40">
                <button onclick="openEditBloodRequestModal('${req.id}')" class="p-1 text-text-secondary hover:text-primary transition-colors" title="Edit Post">
                  <span class="material-symbols-outlined text-[16px]">edit</span>
                </button>
                <button onclick="deleteBloodRequest('${req.id}')" class="p-1 text-text-secondary hover:text-urgent transition-colors" title="Delete Post">
                  <span class="material-symbols-outlined text-[16px]">delete</span>
                </button>
              </div>
            ` : ''}
          </div>
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

        <!-- Action Row -->
        <div class="grid grid-cols-2 gap-2 mt-3">
          <a class="h-10 flex items-center justify-center gap-1.5 rounded-xl bg-primary-container text-on-primary text-xs font-bold transition-all shadow-sm" href="tel:${escapeHtml(req.contactNumber)}">
            <span class="material-symbols-outlined text-[18px]">call</span>
            <span>Call Attendant</span>
          </a>
          <button onclick="openDonorResponseModal('${req.id}')" class="h-10 flex items-center justify-center gap-1.5 rounded-xl bg-urgent text-white hover:bg-urgent/90 text-xs font-bold transition-all shadow active:scale-95">
            <span class="material-symbols-outlined text-[18px]">volunteer_activism</span>
            <span>I Can Donate</span>
          </button>
        </div>

        <!-- Responses Counter / Quick Jump Button -->
        <div class="mt-2.5 pt-2 border-t border-border-line/30 flex items-center justify-between">
          <button onclick="viewPostResponses('${req.id}', 'blood')" class="text-xs font-semibold text-primary hover:underline flex items-center gap-1.5">
            <span class="material-symbols-outlined text-[16px]">mark_chat_read</span>
            <span>${responsesCount} Donor Response${responsesCount !== 1 ? 's' : ''}</span>
          </button>
          <span class="text-[10px] text-text-muted">Real-time Donor Desk</span>
        </div>
      </article>
    `;
  }).join('');
}

// -------------------------------------------------------------
// 2. Lost and Found Module (Supabase Connected + Full CRUD)
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
          authorId: item.author_id,
          authorTag: item.author_tag || `${(item.author_name || 'Student').split(' ')[0]}_AUST_Transit`,
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
    authorId: user.id,
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
      SupabaseDb.broadcastChange('lost_found_created', newItem);
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

// Edit Lost and Found
let editingLostFoundId = null;

function openEditLostFoundModal(itemId) {
  const items = getLostFoundItems();
  const item = items.find(i => i.id === itemId);
  if (!item) return;

  editingLostFoundId = itemId;

  const modal = document.getElementById('edit-lost-found-modal');
  if (!modal) return;

  document.getElementById('edit-lf-type').value = item.itemType || 'LOST';
  document.getElementById('edit-lf-title').value = item.title || '';
  document.getElementById('edit-lf-desc').value = item.description || '';
  document.getElementById('edit-lf-location').value = item.location || '';
  document.getElementById('edit-lf-contact').value = item.contact || '';
  document.getElementById('edit-lf-img').value = item.imageUrl || '';

  modal.showModal();
}

function closeEditLostFoundModal() {
  const modal = document.getElementById('edit-lost-found-modal');
  if (modal) modal.close();
  editingLostFoundId = null;
}

async function saveEditedLostFound() {
  if (!editingLostFoundId) return;

  const itemType = document.getElementById('edit-lf-type')?.value || 'LOST';
  const title = document.getElementById('edit-lf-title')?.value.trim();
  const description = document.getElementById('edit-lf-desc')?.value.trim();
  const location = document.getElementById('edit-lf-location')?.value.trim() || 'AUST Campus';
  const contact = document.getElementById('edit-lf-contact')?.value.trim();
  const imageUrl = document.getElementById('edit-lf-img')?.value.trim() || '';

  if (!title || !description) {
    if (window.showAppToast) window.showAppToast('Title and Description are required!', true);
    return;
  }

  const list = getLostFoundItems();
  const idx = list.findIndex(i => i.id === editingLostFoundId);
  if (idx !== -1) {
    list[idx] = {
      ...list[idx],
      itemType,
      title,
      description,
      location,
      contact,
      imageUrl
    };
    localStorage.setItem(LOST_FOUND_DB_KEY, JSON.stringify(list));

    if (typeof SupabaseDb !== 'undefined') {
      try {
        await SupabaseDb.updateLostFoundItem(editingLostFoundId, {
          title,
          description,
          type: itemType.toLowerCase(),
          location,
          contact,
          image_url: imageUrl || null
        });
        SupabaseDb.broadcastChange('lost_found_updated', list[idx]);
      } catch (e) {
        console.warn('Supabase update lost found warning:', e);
      }
    }

    closeEditLostFoundModal();
    renderLostFoundFeed();

    if (window.showAppToast) {
      window.showAppToast('Notice updated in real-time!');
    }
  }
}

// Delete Lost and Found Item
async function deleteLostFoundItem(itemId) {
  if (!confirm('Are you sure you want to delete this notice?')) return;

  let list = getLostFoundItems();
  list = list.filter(i => i.id !== itemId);
  localStorage.setItem(LOST_FOUND_DB_KEY, JSON.stringify(list));

  // Also remove associated responses
  let responses = getPostResponses();
  responses = responses.filter(resp => resp.postId !== itemId);
  savePostResponses(responses);

  // Also remove associated comments
  let comments = getPostComments();
  comments = comments.filter(c => c.postId !== itemId);
  savePostComments(comments);

  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.deleteLostFoundItem(itemId);
      SupabaseDb.broadcastChange('lost_found_deleted', { id: itemId });
    } catch (e) {
      console.warn('Supabase delete lost found warning:', e);
    }
  }

  renderLostFoundFeed();
  renderPostResponsesFeed();

  if (window.showAppToast) {
    window.showAppToast('Notice removed');
  }
}

// -------------------------------------------------------------
// 2.1 Lost & Found Post Comments (Real-Time Discussions)
// -------------------------------------------------------------
const openCommentPostIds = new Set();

function getPostComments(postId = null) {
  const all = JSON.parse(localStorage.getItem(COMMENTS_DB_KEY) || '[]');
  if (postId) {
    return all.filter(c => c.postId === postId).sort((a, b) => (a.timestamp || 0) - (b.timestamp || 0));
  }
  return all.sort((a, b) => (a.timestamp || 0) - (b.timestamp || 0));
}

function savePostComments(comments) {
  localStorage.setItem(COMMENTS_DB_KEY, JSON.stringify(comments));
}

async function syncPostCommentsFromSupabase(postId = null) {
  if (typeof SupabaseDb !== 'undefined') {
    try {
      const data = await SupabaseDb.fetchPostComments(postId);
      if (data && Array.isArray(data)) {
        const existing = JSON.parse(localStorage.getItem(COMMENTS_DB_KEY) || '[]');
        const remoteMapped = data.map(c => ({
          id: c.id,
          postId: c.post_id,
          userId: c.user_id,
          userName: c.user_name || 'Student',
          userTag: c.user_tag || 'AUST_Student',
          content: c.content,
          timestamp: new Date(c.created_at).getTime(),
          updatedAt: c.updated_at ? new Date(c.updated_at).getTime() : null
        }));

        if (postId) {
          const others = existing.filter(c => c.postId !== postId);
          localStorage.setItem(COMMENTS_DB_KEY, JSON.stringify([...others, ...remoteMapped]));
        } else if (remoteMapped.length > 0) {
          localStorage.setItem(COMMENTS_DB_KEY, JSON.stringify(remoteMapped));
        }
      }
    } catch (e) {
      console.warn('Sync post comments warning:', e);
    }
  }
}

function togglePostComments(postId) {
  const section = document.getElementById(`lf-comments-section-${postId}`);
  if (!section) return;

  if (section.classList.contains('hidden')) {
    section.classList.remove('hidden');
    openCommentPostIds.add(postId);
    renderCommentsForPost(postId);
    if (window.attachMentionsToAllInputs) {
      window.attachMentionsToAllInputs();
    }
  } else {
    section.classList.add('hidden');
    openCommentPostIds.delete(postId);
  }
}

function renderCommentsForPost(postId) {
  const container = document.getElementById(`lf-comments-list-${postId}`);
  if (!container) return;

  const user = getCurrentUser();
  const comments = getPostComments(postId);
  const countBadge = document.getElementById(`lf-comments-count-${postId}`);
  if (countBadge) {
    countBadge.textContent = `${comments.length} comment${comments.length !== 1 ? 's' : ''}`;
  }
  const mainBtn = document.getElementById(`lf-comment-btn-${postId}`);
  if (mainBtn) {
    mainBtn.innerHTML = `
      <span class="material-symbols-outlined text-[15px] shrink-0">chat_bubble</span>
      <span class="truncate">Comments (${comments.length})</span>
    `;
  }

  if (comments.length === 0) {
    container.innerHTML = `
      <div class="py-3 px-2 text-center text-text-muted text-xs italic bg-surface-highest/40 rounded-xl border border-border-line/20">
        No comments yet. Have details or found this item? Leave a comment below!
      </div>
    `;
    return;
  }

  container.innerHTML = comments.map(comm => {
    const isOwner = user && (user.id === comm.userId || user.chatTag === comm.userTag || user.role === 'admin');
    const timeAgo = formatTimeAgo(comm.timestamp);

    return `
      <div class="p-2.5 rounded-xl bg-surface-highest/70 border border-border-line/30 text-xs animate-fade-in" id="comment-node-${comm.id}">
        <div class="flex items-start justify-between gap-2">
          <div class="flex items-center gap-2">
            <div class="w-6 h-6 rounded-full bg-primary/20 text-primary font-bold flex items-center justify-center text-[10px] shrink-0">
              ${escapeHtml((comm.userName || 'S').charAt(0).toUpperCase())}
            </div>
            <div>
              <div class="flex items-center gap-1.5 flex-wrap">
                <span class="font-bold text-text-primary text-[11px]">${escapeHtml(comm.userName || 'Student')}</span>
                <span class="text-[10px] text-text-muted">@${escapeHtml(comm.userTag || '')}</span>
              </div>
              <span class="text-[9px] text-text-muted">${timeAgo} ${comm.updatedAt ? '(edited)' : ''}</span>
            </div>
          </div>
          ${isOwner ? `
            <div class="flex items-center gap-1 shrink-0 bg-surface-sidebar/60 rounded-lg p-0.5 border border-border-line/30">
              <button onclick="editPostCommentInline('${comm.id}', '${postId}')" class="p-1 text-text-muted hover:text-primary transition-colors" title="Edit comment">
                <span class="material-symbols-outlined text-[13px]">edit</span>
              </button>
              <button onclick="deletePostComment('${comm.id}', '${postId}')" class="p-1 text-text-muted hover:text-urgent transition-colors" title="Delete comment">
                <span class="material-symbols-outlined text-[13px]">delete</span>
              </button>
            </div>
          ` : ''}
        </div>
        <div class="mt-1.5 text-text-secondary text-xs leading-relaxed break-words pl-8" id="comment-body-${comm.id}">
          ${escapeHtml(comm.content)}
        </div>
      </div>
    `;
  }).join('');
}

function editPostCommentInline(commentId, postId) {
  const comment = getPostComments().find(c => c.id === commentId);
  if (!comment) return;

  const bodyEl = document.getElementById(`comment-body-${commentId}`);
  if (!bodyEl) return;

  bodyEl.innerHTML = `
    <div class="mt-1 space-y-2">
      <textarea 
        id="edit-comment-input-${commentId}" 
        class="w-full bg-surface-sidebar text-text-primary text-xs rounded-lg p-2 border border-primary/50 focus:outline-none resize-none leading-relaxed" 
        rows="2">${escapeHtml(comment.content)}</textarea>
      <div class="flex items-center justify-end gap-2">
        <button 
          onclick="renderCommentsForPost('${postId}')" 
          class="px-2.5 py-1 rounded-lg text-text-muted hover:text-text-primary text-[11px] font-medium transition-colors">
          Cancel
        </button>
        <button 
          onclick="saveEditedComment('${commentId}', '${postId}')" 
          class="px-3 py-1 rounded-lg bg-primary text-on-primary text-[11px] font-bold shadow-sm hover:brightness-110 transition-all">
          Save
        </button>
      </div>
    </div>
  `;
  const input = document.getElementById(`edit-comment-input-${commentId}`);
  if (input) input.focus();
}

async function saveEditedComment(commentId, postId) {
  const input = document.getElementById(`edit-comment-input-${commentId}`);
  if (!input) return;
  const newContent = input.value.trim();
  if (!newContent) {
    if (window.showAppToast) window.showAppToast('Comment content cannot be empty', true);
    return;
  }

  const all = getPostComments();
  const idx = all.findIndex(c => c.id === commentId);
  if (idx !== -1) {
    all[idx].content = newContent;
    all[idx].updatedAt = Date.now();
    savePostComments(all);

    if (typeof SupabaseDb !== 'undefined') {
      try {
        await SupabaseDb.updateComment(commentId, {
          content: newContent,
          updated_at: new Date().toISOString()
        });
        SupabaseDb.broadcastChange('comment_updated', all[idx]);
      } catch (e) {
        console.warn('Supabase update comment warning:', e);
      }
    }

    renderCommentsForPost(postId);
    if (window.showAppToast) window.showAppToast('Comment updated');
  }
}

async function deletePostComment(commentId, postId) {
  if (!confirm('Are you sure you want to delete this comment?')) return;

  let all = getPostComments();
  all = all.filter(c => c.id !== commentId);
  savePostComments(all);

  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.deleteComment(commentId);
      SupabaseDb.broadcastChange('comment_deleted', { id: commentId, postId });
    } catch (e) {
      console.warn('Supabase delete comment warning:', e);
    }
  }

  renderCommentsForPost(postId);
  if (window.showAppToast) window.showAppToast('Comment removed');
}

async function submitPostComment(postId) {
  const user = getCurrentUser();
  if (!user) {
    if (window.showAppToast) window.showAppToast('Please sign in to comment', true);
    if (window.switchScreen) window.switchScreen('signin');
    return;
  }

  const input = document.getElementById(`lf-comment-input-${postId}`);
  if (!input) return;
  const content = input.value.trim();
  if (!content) return;

  const commentId = 'comm_' + Date.now();
  const authorTag = formatChatTag(user);

  const newComment = {
    id: commentId,
    postId: postId,
    userId: user.id,
    userName: user.name,
    userTag: authorTag,
    content: content,
    timestamp: Date.now(),
    updatedAt: null
  };

  const all = getPostComments();
  all.push(newComment);
  savePostComments(all);

  input.value = '';

  // Supabase sync
  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.postComment({
        id: commentId,
        post_id: postId,
        user_id: user.id,
        user_name: user.name,
        user_tag: authorTag,
        content: content
      });
      SupabaseDb.broadcastChange('comment_created', newComment);
    } catch (e) {
      console.warn('Supabase post comment warning:', e);
    }
  }

  // Check for @mentions in comment content
  if (window.dispatchMentionNotification) {
    const mentions = content.match(/@([\w\-]+)/g) || [];
    mentions.forEach(mention => {
      const targetTag = mention.substring(1);
      window.dispatchMentionNotification(targetTag, user, `commented on Lost & Found post: "${content.substring(0, 40)}..."`);
    });
  }

  renderCommentsForPost(postId);

  if (window.showAppToast) {
    window.showAppToast('Comment added');
  }
}

async function renderLostFoundFeed() {
  const container = document.getElementById('lost-found-feed');
  if (!container) return;

  await syncLostFoundFromSupabase();
  await syncPostCommentsFromSupabase();

  const user = getCurrentUser();
  const items = getLostFoundItems();
  const allResponses = getPostResponses();
  const allComments = getPostComments();

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
    const isOwner = user && (user.id === item.authorId || user.chatTag === item.authorTag || user.role === 'admin');
    const responsesCount = allResponses.filter(r => r.postId === item.id).length;
    const commentsCount = allComments.filter(c => c.postId === item.id).length;

    return `
      <article class="relative flex flex-col rounded-2xl bg-surface-elevated p-4 shadow-md border-l-4 ${isLost ? 'border-warning' : 'border-success'} animate-fade-in" id="card-${item.id}">
        <div class="flex items-center justify-between gap-2 flex-wrap">
          <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full ${isLost ? 'bg-warning/20 text-warning' : 'bg-success/20 text-success'} text-xs font-bold">
            <span class="material-symbols-outlined text-[14px]">${isLost ? 'help' : 'check_circle'}</span>
            ${escapeHtml(item.itemType)}
          </span>
          <div class="flex items-center gap-2">
            <span class="text-[11px] text-text-muted">@${escapeHtml(item.authorTag)}</span>
            ${isOwner ? `
              <div class="flex items-center gap-1 ml-1 bg-surface-highest/80 rounded-lg p-0.5 border border-border-line/40">
                <button onclick="openEditLostFoundModal('${item.id}')" class="p-1 text-text-secondary hover:text-primary transition-colors" title="Edit Post">
                  <span class="material-symbols-outlined text-[16px]">edit</span>
                </button>
                <button onclick="deleteLostFoundItem('${item.id}')" class="p-1 text-text-secondary hover:text-urgent transition-colors" title="Delete Post">
                  <span class="material-symbols-outlined text-[16px]">delete</span>
                </button>
              </div>
            ` : ''}
          </div>
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

        <!-- Action Row -->
        <div class="grid grid-cols-3 gap-1.5 mt-3">
          <button onclick="openLostFoundResponseModal('${item.id}')" class="h-9 flex items-center justify-center gap-1 rounded-xl bg-warning text-black font-bold text-[11px] shadow active:scale-95 transition-all px-1">
            <span class="material-symbols-outlined text-[16px] shrink-0">verified</span>
            <span class="truncate">${isLost ? 'I Found This' : 'This Is Mine'}</span>
          </button>
          <button onclick="viewPostResponses('${item.id}', 'lost_found')" class="h-9 flex items-center justify-center gap-1 rounded-xl bg-surface-highest hover:bg-surface-bright text-text-primary font-bold text-[11px] border border-border-line/40 transition-all px-1">
            <span class="material-symbols-outlined text-[16px] shrink-0">mark_chat_read</span>
            <span class="truncate">Claims (${responsesCount})</span>
          </button>
          <button onclick="togglePostComments('${item.id}')" class="h-9 flex items-center justify-center gap-1 rounded-xl bg-primary/10 hover:bg-primary/20 text-primary font-bold text-[11px] border border-primary/30 transition-all px-1" id="lf-comment-btn-${item.id}">
            <span class="material-symbols-outlined text-[16px] shrink-0">chat_bubble</span>
            <span class="truncate">Comments (${commentsCount})</span>
          </button>
        </div>

        <!-- Expandable Comments Section -->
        <div id="lf-comments-section-${item.id}" class="mt-3 pt-3 border-t border-border-line/30 hidden">
          <div class="flex items-center justify-between mb-2">
            <span class="text-xs font-bold text-text-primary flex items-center gap-1.5">
              <span class="material-symbols-outlined text-[16px] text-primary">forum</span>
              <span>Discussion & Updates</span>
            </span>
            <span class="text-[10px] text-text-muted font-medium" id="lf-comments-count-${item.id}">${commentsCount} comment${commentsCount !== 1 ? 's' : ''}</span>
          </div>

          <!-- Comments List Container -->
          <div id="lf-comments-list-${item.id}" class="space-y-2 mb-3 max-h-60 overflow-y-auto pr-1">
            <!-- Rendered dynamically by renderCommentsForPost -->
          </div>

          <!-- New Comment Input Box -->
          <div class="flex items-center gap-2 pt-2 border-t border-border-line/20">
            <div class="relative flex-1">
              <input 
                type="text" 
                id="lf-comment-input-${item.id}" 
                placeholder="Write a comment or lead (use @ to mention)..." 
                class="w-full bg-surface-highest/80 text-text-primary text-xs rounded-xl px-3 py-2 border border-border-line/40 focus:outline-none focus:border-primary pr-8 transition-all"
                onkeydown="if(event.key === 'Enter') submitPostComment('${item.id}')"
              />
            </div>
            <button 
              onclick="submitPostComment('${item.id}')" 
              class="h-8 px-3 rounded-xl bg-primary text-on-primary text-xs font-bold flex items-center justify-center gap-1 hover:brightness-110 active:scale-95 transition-all shadow-sm shrink-0">
              <span class="material-symbols-outlined text-[16px]">send</span>
              <span class="hidden sm:inline">Post</span>
            </button>
          </div>
        </div>
      </article>
    `;
  }).join('');

  // Re-open and render any comments sections that were previously open
  openCommentPostIds.forEach(postId => {
    const section = document.getElementById(`lf-comments-section-${postId}`);
    if (section) {
      section.classList.remove('hidden');
      renderCommentsForPost(postId);
    }
  });
}

// -------------------------------------------------------------
// 3. Post Responses Channel (Blood Donation Volunteers & Lost/Found Claims)
// -------------------------------------------------------------
function getPostResponses() {
  return JSON.parse(localStorage.getItem(RESPONSES_DB_KEY) || '[]');
}

function savePostResponses(responses) {
  localStorage.setItem(RESPONSES_DB_KEY, JSON.stringify(responses));
  updateResponsesBadge();
}

async function syncPostResponsesFromSupabase() {
  if (typeof SupabaseDb !== 'undefined') {
    try {
      const data = await SupabaseDb.fetchPostResponses();
      if (data && Array.isArray(data) && data.length > 0) {
        const mapped = data.map(r => ({
          id: r.id,
          postId: r.post_id,
          postType: r.post_type || 'blood',
          postTitle: r.post_title || 'Campus Assistance Post',
          postSummary: r.post_summary || '',
          requesterId: r.requester_id,
          requesterTag: r.requester_tag || 'Author',
          requesterName: r.requester_name || 'Requester',
          responderId: r.responder_id,
          responderName: r.responder_name,
          responderTag: r.responder_tag || 'Student',
          department: r.department || 'CSE',
          semester: r.semester || '4-1',
          contactNumber: r.contact_number,
          fbLink: r.fb_link || '',
          availability: r.availability || '',
          notes: r.notes || '',
          status: r.status || 'pending',
          timestamp: new Date(r.created_at).getTime()
        }));
        localStorage.setItem(RESPONSES_DB_KEY, JSON.stringify(mapped));
        updateResponsesBadge();
      }
    } catch (e) {
      console.warn('Sync post responses warning:', e);
    }
  }
}

// Donor Response Modal
let activeRespondingBloodReqId = null;

function openDonorResponseModal(reqId) {
  const user = getCurrentUser();
  if (!user) {
    if (window.showAppToast) window.showAppToast('Please sign in to volunteer as a blood donor', true);
    if (window.switchScreen) window.switchScreen('signin');
    return;
  }

  const requests = getBloodRequests();
  const req = requests.find(r => r.id === reqId);
  if (!req) return;

  activeRespondingBloodReqId = reqId;

  const modal = document.getElementById('donor-response-modal');
  if (!modal) return;

  // Set Request Context Preview
  const infoEl = document.getElementById('donor-modal-post-info');
  if (infoEl) {
    infoEl.innerHTML = `
      <div class="p-3 rounded-xl bg-urgent/10 border border-urgent/30 flex items-start gap-2.5">
        <span class="material-symbols-outlined text-urgent text-[22px] shrink-0">water_drop</span>
        <div class="min-w-0 flex-1">
          <div class="flex items-center justify-between">
            <span class="font-bold text-xs text-urgent uppercase">${escapeHtml(req.bloodGroup)} Blood Request</span>
            <span class="text-[10px] text-text-muted">By @${escapeHtml(req.authorTag)}</span>
          </div>
          <p class="font-bold text-xs text-text-primary mt-0.5 truncate">${escapeHtml(req.title)}</p>
          <p class="text-[11px] text-text-secondary truncate mt-0.5">${escapeHtml(req.hospitalName)}</p>
        </div>
      </div>
    `;
  }

  // Pre-populate user details
  const nameInput = document.getElementById('donor-name') || document.getElementById('donor-resp-name');
  const deptInput = document.getElementById('donor-dept') || document.getElementById('donor-resp-dept');
  const semInput = document.getElementById('donor-sem') || document.getElementById('donor-resp-sem');
  const phoneInput = document.getElementById('donor-phone') || document.getElementById('donor-resp-phone');
  const fbInput = document.getElementById('donor-fblink') || document.getElementById('donor-resp-fblink');
  const availInput = document.getElementById('donor-avail') || document.getElementById('donor-resp-avail');
  const noteInput = document.getElementById('donor-notes') || document.getElementById('donor-resp-notes');

  if (nameInput) nameInput.value = user.name || '';
  if (deptInput) deptInput.value = user.department || 'CSE';
  if (semInput) semInput.value = user.semester || '4-1';
  if (phoneInput && !phoneInput.value) phoneInput.value = '';
  if (fbInput && !fbInput.value) fbInput.value = 'https://facebook.com/';
  if (availInput) availInput.value = 'Available today';
  if (noteInput) noteInput.value = `Verified ${user.bloodGroup || 'match'} donor ready to assist.`;

  modal.showModal();
}

function closeDonorResponseModal() {
  const modal = document.getElementById('donor-response-modal');
  if (modal) modal.close();
  activeRespondingBloodReqId = null;
}

async function submitDonorResponse() {
  const user = getCurrentUser();
  if (!user || !activeRespondingBloodReqId) return;

  const requests = getBloodRequests();
  const req = requests.find(r => r.id === activeRespondingBloodReqId);
  if (!req) return;

  const name = (document.getElementById('donor-name') || document.getElementById('donor-resp-name'))?.value.trim() || user.name;
  const department = (document.getElementById('donor-dept') || document.getElementById('donor-resp-dept'))?.value.trim() || user.department;
  const semester = (document.getElementById('donor-sem') || document.getElementById('donor-resp-sem'))?.value.trim() || user.semester;
  const contactNumber = (document.getElementById('donor-phone') || document.getElementById('donor-resp-phone'))?.value.trim();
  const fbLink = (document.getElementById('donor-fblink') || document.getElementById('donor-resp-fblink'))?.value.trim() || '';
  const availability = (document.getElementById('donor-avail') || document.getElementById('donor-resp-avail'))?.value.trim() || 'Immediate';
  const notes = (document.getElementById('donor-notes') || document.getElementById('donor-resp-notes'))?.value.trim() || '';

  if (!contactNumber) {
    if (window.showAppToast) window.showAppToast('Please enter your contact phone number', true);
    return;
  }

  const responseId = 'resp_blood_' + Date.now();
  const responderTag = formatChatTag(user);

  const newResponse = {
    id: responseId,
    postId: req.id,
    postType: 'blood',
    postTitle: req.title,
    postSummary: `${req.bloodGroup} at ${req.hospitalName}`,
    requesterId: req.authorId || req.authorTag,
    requesterTag: req.authorTag,
    requesterName: req.authorName,
    responderId: user.id,
    responderName: name,
    responderTag: responderTag,
    department: department,
    semester: semester,
    contactNumber: contactNumber,
    fbLink: fbLink,
    availability: availability,
    notes: notes,
    status: 'pending',
    timestamp: Date.now()
  };

  const responses = getPostResponses();
  responses.unshift(newResponse);
  savePostResponses(responses);

  // Insert into Supabase post_responses
  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.postPostResponse({
        id: responseId,
        post_id: req.id,
        post_type: 'blood',
        post_title: req.title,
        post_summary: `${req.bloodGroup} at ${req.hospitalName}`,
        requester_id: req.authorId || null,
        requester_tag: req.authorTag,
        requester_name: req.authorName,
        responder_id: user.id,
        responder_name: name,
        responder_tag: responderTag,
        department: department,
        semester: semester,
        contact_number: contactNumber,
        fb_link: fbLink,
        availability: availability,
        notes: notes,
        status: 'pending'
      });
      SupabaseDb.broadcastChange('post_response_created', newResponse);
    } catch (e) {
      console.warn('Supabase post donor response warning:', e);
    }
  }

  closeDonorResponseModal();

  // Send real-time notification to the requester
  if (window.dispatchDonorResponseNotification) {
    window.dispatchDonorResponseNotification(newResponse, req);
  }

  if (window.showAppToast) {
    window.showAppToast(`Thank you! Your donation response was sent directly to @${req.authorTag}`, false);
  }

  renderBloodRequestsFeed();
  renderPostResponsesFeed();
}

// Lost & Found Response Modal
let activeRespondingLostFoundId = null;

function openLostFoundResponseModal(itemId) {
  const user = getCurrentUser();
  if (!user) {
    if (window.showAppToast) window.showAppToast('Please sign in to respond to this notice', true);
    if (window.switchScreen) window.switchScreen('signin');
    return;
  }

  const items = getLostFoundItems();
  const item = items.find(i => i.id === itemId);
  if (!item) return;

  activeRespondingLostFoundId = itemId;

  const modal = document.getElementById('lost-found-response-modal');
  if (!modal) return;

  const infoEl = document.getElementById('lf-modal-post-info');
  if (infoEl) {
    infoEl.innerHTML = `
      <div class="p-3 rounded-xl bg-warning/10 border border-warning/30 flex items-start gap-2.5">
        <span class="material-symbols-outlined text-warning text-[22px] shrink-0">find_in_page</span>
        <div class="min-w-0 flex-1">
          <div class="flex items-center justify-between">
            <span class="font-bold text-xs text-warning uppercase">${escapeHtml(item.itemType)} NOTICE</span>
            <span class="text-[10px] text-text-muted">By @${escapeHtml(item.authorTag)}</span>
          </div>
          <p class="font-bold text-xs text-text-primary mt-0.5 truncate">${escapeHtml(item.title)}</p>
          <p class="text-[11px] text-text-secondary truncate mt-0.5">${escapeHtml(item.location)}</p>
        </div>
      </div>
    `;
  }

  document.getElementById('lf-resp-name').value = user.name || '';
  document.getElementById('lf-resp-dept').value = user.department || 'CSE';
  document.getElementById('lf-resp-sem').value = user.semester || '4-1';
  document.getElementById('lf-resp-phone').value = '';
  document.getElementById('lf-resp-fblink').value = 'https://facebook.com/';
  document.getElementById('lf-resp-notes').value = '';

  modal.showModal();
}

function closeLostFoundResponseModal() {
  const modal = document.getElementById('lost-found-response-modal');
  if (modal) modal.close();
  activeRespondingLostFoundId = null;
}

async function submitLostFoundResponse() {
  const user = getCurrentUser();
  if (!user || !activeRespondingLostFoundId) return;

  const items = getLostFoundItems();
  const item = items.find(i => i.id === activeRespondingLostFoundId);
  if (!item) return;

  const name = document.getElementById('lf-resp-name')?.value.trim() || user.name;
  const department = document.getElementById('lf-resp-dept')?.value.trim() || user.department;
  const semester = document.getElementById('lf-resp-sem')?.value.trim() || user.semester;
  const contactNumber = document.getElementById('lf-resp-phone')?.value.trim();
  const fbLink = document.getElementById('lf-resp-fblink')?.value.trim() || '';
  const notes = document.getElementById('lf-resp-notes')?.value.trim() || '';

  if (!contactNumber) {
    if (window.showAppToast) window.showAppToast('Please enter your contact number', true);
    return;
  }

  const responseId = 'resp_lf_' + Date.now();
  const responderTag = formatChatTag(user);

  const newResponse = {
    id: responseId,
    postId: item.id,
    postType: 'lost_found',
    postTitle: item.title,
    postSummary: item.location,
    requesterId: item.authorId || item.authorTag,
    requesterTag: item.authorTag,
    requesterName: item.authorName,
    responderId: user.id,
    responderName: name,
    responderTag: responderTag,
    department: department,
    semester: semester,
    contactNumber: contactNumber,
    fbLink: fbLink,
    availability: 'Campus Pickup',
    notes: notes,
    status: 'pending',
    timestamp: Date.now()
  };

  const responses = getPostResponses();
  responses.unshift(newResponse);
  savePostResponses(responses);

  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.postPostResponse({
        id: responseId,
        post_id: item.id,
        post_type: 'lost_found',
        post_title: item.title,
        post_summary: item.location,
        requester_id: item.authorId || null,
        requester_tag: item.authorTag,
        requester_name: item.authorName,
        responder_id: user.id,
        responder_name: name,
        responder_tag: responderTag,
        department: department,
        semester: semester,
        contact_number: contactNumber,
        fb_link: fbLink,
        availability: 'Campus Pickup',
        notes: notes,
        status: 'pending'
      });
      SupabaseDb.broadcastChange('post_response_created', newResponse);
    } catch (e) {
      console.warn('Supabase post lost/found response warning:', e);
    }
  }

  closeLostFoundResponseModal();

  if (window.dispatchLostFoundClaimNotification) {
    window.dispatchLostFoundClaimNotification(newResponse, item);
  }

  if (window.showAppToast) {
    window.showAppToast(`Response sent directly to @${item.authorTag}`);
  }

  renderLostFoundFeed();
  renderPostResponsesFeed();
}

// Edit & Delete Responses
let editingResponseId = null;

function openEditResponseModal(respId) {
  const responses = getPostResponses();
  const resp = responses.find(r => r.id === respId);
  if (!resp) return;

  editingResponseId = respId;

  const modal = document.getElementById('edit-response-modal');
  if (!modal) return;

  document.getElementById('edit-resp-phone').value = resp.contactNumber || '';
  document.getElementById('edit-resp-fblink').value = resp.fbLink || '';
  document.getElementById('edit-resp-avail').value = resp.availability || '';
  document.getElementById('edit-resp-notes').value = resp.notes || '';

  modal.showModal();
}

function closeEditResponseModal() {
  const modal = document.getElementById('edit-response-modal');
  if (modal) modal.close();
  editingResponseId = null;
}

async function saveEditedResponse() {
  if (!editingResponseId) return;

  const contactNumber = document.getElementById('edit-resp-phone')?.value.trim();
  const fbLink = document.getElementById('edit-resp-fblink')?.value.trim() || '';
  const availability = document.getElementById('edit-resp-avail')?.value.trim() || '';
  const notes = document.getElementById('edit-resp-notes')?.value.trim() || '';

  if (!contactNumber) {
    if (window.showAppToast) window.showAppToast('Contact number is required', true);
    return;
  }

  const responses = getPostResponses();
  const idx = responses.findIndex(r => r.id === editingResponseId);
  if (idx !== -1) {
    responses[idx] = {
      ...responses[idx],
      contactNumber,
      fbLink,
      availability,
      notes
    };
    savePostResponses(responses);

    if (typeof SupabaseDb !== 'undefined') {
      try {
        await SupabaseDb.updatePostResponse(editingResponseId, {
          contact_number: contactNumber,
          fb_link: fbLink,
          availability: availability,
          notes: notes
        });
        SupabaseDb.broadcastChange('post_response_updated', responses[idx]);
      } catch (e) {
        console.warn('Supabase update response warning:', e);
      }
    }

    closeEditResponseModal();
    renderPostResponsesFeed();

    if (window.showAppToast) {
      window.showAppToast('Response updated in real-time!');
    }
  }
}

async function deletePostResponse(respId) {
  if (!confirm('Are you sure you want to delete this response?')) return;

  let responses = getPostResponses();
  responses = responses.filter(r => r.id !== respId);
  savePostResponses(responses);

  if (typeof SupabaseDb !== 'undefined') {
    try {
      await SupabaseDb.deletePostResponse(respId);
      SupabaseDb.broadcastChange('post_response_deleted', { id: respId });
    } catch (e) {
      console.warn('Supabase delete response warning:', e);
    }
  }

  renderPostResponsesFeed();
  renderBloodRequestsFeed();
  renderLostFoundFeed();

  if (window.showAppToast) {
    window.showAppToast('Response deleted');
  }
}

async function updateResponseStatus(respId, newStatus) {
  const responses = getPostResponses();
  const idx = responses.findIndex(r => r.id === respId);
  if (idx !== -1) {
    responses[idx].status = newStatus;
    savePostResponses(responses);

    if (typeof SupabaseDb !== 'undefined') {
      try {
        await SupabaseDb.updatePostResponse(respId, { status: newStatus });
        SupabaseDb.broadcastChange('post_response_status_updated', { id: respId, status: newStatus });
      } catch (e) {
        console.warn('Supabase update status warning:', e);
      }
    }

    renderPostResponsesFeed();
    if (window.showAppToast) {
      window.showAppToast(`Response status marked as ${newStatus}`);
    }
  }
}

function filterResponsesTab(tab, el) {
  activeResponsesFilter = tab;
  activePostIdFilter = null; // Clear single post filter

  document.querySelectorAll('.responses-tab-btn').forEach(btn => {
    btn.className = 'responses-tab-btn px-3 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap transition-all bg-surface-elevated text-text-secondary hover:text-text-primary';
  });
  if (el) {
    el.className = 'responses-tab-btn px-3 py-1.5 rounded-full text-xs font-bold whitespace-nowrap transition-all bg-primary-container text-on-primary-container shadow';
  }

  renderPostResponsesFeed();
}

function viewPostResponses(postId, postType) {
  activePostIdFilter = postId;
  if (window.switchScreen) {
    window.switchScreen('post-responses');
  }
}

function updateResponsesBadge() {
  const responses = getPostResponses();
  const badge = document.getElementById('responses-badge');
  if (badge) {
    if (responses.length > 0) {
      badge.textContent = responses.length;
      badge.classList.remove('hidden');
    } else {
      badge.classList.add('hidden');
    }
  }
}

async function renderPostResponsesFeed() {
  const container = document.getElementById('post-responses-feed');
  if (!container) return;

  await syncPostResponsesFromSupabase();

  const user = getCurrentUser();
  const allResponses = getPostResponses();

  // Filter based on active selection
  let filtered = allResponses;

  if (activePostIdFilter) {
    filtered = filtered.filter(r => r.postId === activePostIdFilter);
  } else if (activeResponsesFilter === 'blood') {
    filtered = filtered.filter(r => r.postType === 'blood');
  } else if (activeResponsesFilter === 'lost_found') {
    filtered = filtered.filter(r => r.postType === 'lost_found');
  } else if (activeResponsesFilter === 'received') {
    filtered = filtered.filter(r => user && (r.requesterId === user.id || r.requesterTag === formatChatTag(user)));
  } else if (activeResponsesFilter === 'sent') {
    filtered = filtered.filter(r => user && (r.responderId === user.id || r.responderTag === formatChatTag(user)));
  }

  const activePost = activePostIdFilter ? getBloodRequests().find(b => b.id === activePostIdFilter) || getLostFoundItems().find(l => l.id === activePostIdFilter) : null;

  if (filtered.length === 0) {
    container.innerHTML = `
      ${activePost ? `
        <div class="mb-4 p-3 rounded-2xl bg-surface-highest/70 border border-border-line/40 flex items-center justify-between">
          <div class="min-w-0">
            <span class="text-[10px] text-primary font-bold uppercase tracking-wider block">Filtered for Post</span>
            <h4 class="font-bold text-xs text-text-primary truncate">${escapeHtml(activePost.title)}</h4>
          </div>
          <button onclick="activePostIdFilter = null; renderPostResponsesFeed();" class="px-2.5 py-1 rounded-lg bg-surface-elevated text-xs text-text-secondary hover:text-text-primary">
            Clear Filter
          </button>
        </div>
      ` : ''}
      <div class="py-12 flex flex-col items-center justify-center text-center text-text-muted">
        <span class="material-symbols-outlined text-4xl mb-2 text-primary/40">mark_chat_read</span>
        <p class="text-sm font-bold">No responses found</p>
        <p class="text-xs text-text-muted mt-1">Donation offers and lost & found claims will appear here in real-time.</p>
      </div>
    `;
    return;
  }

  container.innerHTML = `
    ${activePost ? `
      <div class="mb-3 p-3 rounded-2xl bg-surface-highest/80 border border-primary/40 flex items-center justify-between shadow-md">
        <div class="min-w-0">
          <span class="text-[10px] text-primary font-bold uppercase tracking-wider block">Filtered Post Responses (${filtered.length})</span>
          <h4 class="font-bold text-xs text-text-primary truncate">${escapeHtml(activePost.title)}</h4>
        </div>
        <button onclick="activePostIdFilter = null; renderPostResponsesFeed();" class="px-2.5 py-1 rounded-lg bg-surface-elevated text-xs text-text-secondary hover:text-text-primary">
          View All
        </button>
      </div>
    ` : ''}
  ` + filtered.map(resp => {
    const isBlood = resp.postType === 'blood';
    const isMine = user && (user.id === resp.responderId || user.chatTag === resp.responderTag);
    const isAuthorOfPost = user && (user.id === resp.requesterId || user.chatTag === resp.requesterTag || user.role === 'admin');
    const initials = (resp.responderName || 'U').split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();

    let statusClass = 'bg-warning/15 text-warning border-warning/30';
    if (resp.status === 'contacted') statusClass = 'bg-primary/15 text-primary border-primary/30';
    if (resp.status === 'accepted' || resp.status === 'completed') statusClass = 'bg-success/15 text-success border-success/30';

    return `
      <article class="p-4 rounded-2xl bg-surface-elevated border border-border-line/40 shadow-md space-y-3 animate-fade-in relative">
        <!-- Post Reference Header -->
        <div class="flex items-center justify-between gap-2 border-b border-border-line/30 pb-2">
          <div class="flex items-center gap-1.5 min-w-0">
            <span class="material-symbols-outlined text-[16px] ${isBlood ? 'text-urgent' : 'text-warning'} shrink-0">
              ${isBlood ? 'water_drop' : 'find_in_page'}
            </span>
            <span class="text-[11px] font-bold text-text-secondary truncate">
              ${escapeHtml(resp.postTitle)}
            </span>
          </div>
          <span class="px-2 py-0.5 rounded-full border text-[10px] font-bold uppercase tracking-wider ${statusClass}">
            ${escapeHtml(resp.status || 'Pending')}
          </span>
        </div>

        <!-- Responder Profile Row -->
        <div class="flex items-start justify-between gap-2">
          <div class="flex items-center gap-2.5 min-w-0">
            <div class="w-10 h-10 rounded-full ${isBlood ? 'bg-urgent/20 text-urgent' : 'bg-warning/20 text-warning'} flex items-center justify-center font-bold text-xs shrink-0 shadow-inner">
              ${initials}
            </div>
            <div class="min-w-0 flex flex-col">
              <div class="flex items-center gap-1.5">
                <span class="font-bold text-sm text-text-primary truncate">${escapeHtml(resp.responderName)}</span>
                <span class="text-[10px] text-text-muted">(${escapeHtml(resp.department)} ${escapeHtml(resp.semester)})</span>
              </div>
              <span class="font-mono text-xs text-primary truncate">@${escapeHtml(resp.responderTag)}</span>
            </div>
          </div>

          <!-- Edit/Delete Action for Responder / Post Owner -->
          <div class="flex items-center gap-1">
            ${isMine ? `
              <button onclick="openEditResponseModal('${resp.id}')" class="p-1.5 rounded-lg bg-surface-highest hover:bg-surface-bright text-text-secondary hover:text-primary transition-colors" title="Edit Offer">
                <span class="material-symbols-outlined text-[16px]">edit</span>
              </button>
            ` : ''}
            ${(isMine || isAuthorOfPost) ? `
              <button onclick="deletePostResponse('${resp.id}')" class="p-1.5 rounded-lg bg-surface-highest hover:bg-surface-bright text-text-secondary hover:text-urgent transition-colors" title="Delete Response">
                <span class="material-symbols-outlined text-[16px]">delete</span>
              </button>
            ` : ''}
          </div>
        </div>

        <!-- Information Box -->
        <div class="p-3 rounded-xl bg-surface-highest/60 space-y-2 text-xs">
          ${resp.availability ? `
            <div class="flex items-center gap-2 text-text-secondary">
              <span class="material-symbols-outlined text-primary text-[16px] shrink-0">schedule</span>
              <span>Availability: <strong class="text-text-primary">${escapeHtml(resp.availability)}</strong></span>
            </div>
          ` : ''}
          ${resp.notes ? `
            <div class="flex items-start gap-2 text-text-secondary">
              <span class="material-symbols-outlined text-text-muted text-[16px] shrink-0 mt-0.5">chat</span>
              <span class="leading-relaxed text-text-primary font-medium">${escapeHtml(resp.notes)}</span>
            </div>
          ` : ''}
        </div>

        <!-- Direct Connect Buttons -->
        <div class="grid grid-cols-2 gap-2 pt-1">
          <a href="tel:${escapeHtml(resp.contactNumber)}" class="h-9 flex items-center justify-center gap-1.5 rounded-xl bg-primary-container text-on-primary-container font-bold text-xs shadow-sm hover:brightness-105 active:scale-95 transition-all">
            <span class="material-symbols-outlined text-[16px]">call</span>
            <span>Call (${escapeHtml(resp.contactNumber)})</span>
          </a>

          ${resp.fbLink ? `
            <a href="${escapeHtml(resp.fbLink)}" target="_blank" rel="noopener noreferrer" class="h-9 flex items-center justify-center gap-1.5 rounded-xl bg-[#1877F2]/20 text-[#1877F2] font-bold text-xs border border-[#1877F2]/40 hover:bg-[#1877F2]/30 active:scale-95 transition-all">
              <span class="material-symbols-outlined text-[16px]">open_in_new</span>
              <span>Facebook Profile</span>
            </a>
          ` : `
            <button onclick="showAppToast('No Facebook link provided by donor')" class="h-9 flex items-center justify-center gap-1.5 rounded-xl bg-surface-highest text-text-muted font-medium text-xs">
              <span>No FB Link</span>
            </button>
          `}
        </div>

        <!-- Post Owner Triage Controls -->
        ${isAuthorOfPost ? `
          <div class="pt-2 border-t border-border-line/30 flex items-center justify-between gap-2">
            <span class="text-[10px] font-bold text-text-muted uppercase">Mark Status:</span>
            <div class="flex items-center gap-1.5">
              <button onclick="updateResponseStatus('${resp.id}', 'contacted')" class="px-2.5 py-1 rounded-lg bg-surface-highest hover:bg-surface-bright text-[11px] font-semibold text-primary transition-colors">
                Contacted
              </button>
              <button onclick="updateResponseStatus('${resp.id}', 'accepted')" class="px-2.5 py-1 rounded-lg bg-success/20 hover:bg-success/30 text-[11px] font-bold text-success transition-colors">
                Accept
              </button>
              <button onclick="updateResponseStatus('${resp.id}', 'completed')" class="px-2.5 py-1 rounded-lg bg-primary-container text-on-primary-container text-[11px] font-bold shadow transition-colors">
                Completed
              </button>
            </div>
          </div>
        ` : ''}
      </article>
    `;
  }).join('');
}

// -------------------------------------------------------------
// 4. Submit Complain (Google Docs-Style Grievance with Supabase feedback Table)
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
      SupabaseDb.broadcastChange('complaint_created', newComplaint);
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
        </div>
      </div>
    `;
  }).join('');
}

// Auto-initialize feeds on DOM load for standalone and SPA pages
if (typeof document !== 'undefined') {
  document.addEventListener('DOMContentLoaded', () => {
    initializeRequestsDatabase();
    if (document.getElementById('blood-requests-feed')) {
      renderBloodRequestsFeed();
    }
    if (document.getElementById('lost-found-feed')) {
      renderLostFoundFeed();
    }
    if (document.getElementById('post-responses-feed')) {
      renderPostResponsesFeed();
    }
    if (document.getElementById('admin-complaints-feed')) {
      renderComplaintsAdminFeed();
    }
    updateResponsesBadge();
  });
}
