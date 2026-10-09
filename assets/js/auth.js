/**
 * Padma - Authentication & Session Management Module
 * Strict Auth, 2-Hour Auto-Logout, @aust.edu validation, Seeded Credentials, Supabase Database Sync
 */

const SESSION_KEY = 'padma_user_session';
const USERS_DB_KEY = 'padma_users_database';
const SESSION_DURATION_MS = 2 * 60 * 60 * 1000; // 2 Hours

// Seed default users if not present in localStorage
function initializeUsersDatabase() {
  const existing = localStorage.getItem(USERS_DB_KEY);
  if (!existing) {
    const seedUsers = [
      {
        id: 'a0000000-0000-0000-0000-000000000001',
        studentId: '2023202420252026',
        name: 'Padma Student',
        email: 'padmaStudent@aust.edu',
        password: 'Padma@123',
        department: 'CSE',
        semester: '4-1',
        bloodGroup: 'O+',
        pickupDestination: 'Mirpur 10',
        role: 'student'
      },
      {
        id: 'a0000000-0000-0000-0000-000000000002',
        studentId: 'ADM-01',
        name: 'Engr. Rafiqul Islam',
        email: 'admin.rafiq@aust.edu',
        password: 'Admin@123',
        department: 'Transport Division',
        semester: 'Faculty/Admin',
        bloodGroup: 'B+',
        pickupDestination: 'Campus',
        role: 'admin'
      },
      {
        id: 'a0000000-0000-0000-0000-000000000003',
        studentId: 'ADM-02',
        name: 'Dr. Shahed Rahman',
        email: 'admin.shahed@aust.edu',
        password: 'Admin@123',
        department: 'Student Affairs',
        semester: 'Faculty/Admin',
        bloodGroup: 'A+',
        pickupDestination: 'Campus',
        role: 'admin'
      }
    ];
    localStorage.setItem(USERS_DB_KEY, JSON.stringify(seedUsers));
  }
}

initializeUsersDatabase();

// Sync users from Supabase profiles table on start
async function syncProfilesFromSupabase() {
  if (typeof SupabaseDb !== 'undefined' && SupabaseDb.fetchProfiles) {
    try {
      const profiles = await SupabaseDb.fetchProfiles();
      if (profiles && profiles.length > 0) {
        const localUsers = JSON.parse(localStorage.getItem(USERS_DB_KEY) || '[]');
        profiles.forEach(p => {
          const idx = localUsers.findIndex(u => 
            (u.email && p.email && u.email.toLowerCase() === p.email.toLowerCase()) || 
            (u.studentId && p.student_id && u.studentId === p.student_id) ||
            u.id === p.id
          );
          const mapped = {
            id: p.id,
            studentId: p.student_id || p.id,
            name: p.name,
            email: p.email,
            department: p.department || 'CSE',
            semester: p.session || '4-1',
            bloodGroup: p.blood_group || 'O+',
            pickupDestination: p.default_stop_name || 'Mirpur 10',
            role: p.role || 'student',
            password: (idx !== -1 && localUsers[idx].password) ? localUsers[idx].password : (p.role === 'admin' ? 'Admin@123' : 'Padma@123')
          };
          if (idx !== -1) {
            localUsers[idx] = { ...localUsers[idx], ...mapped };
          } else {
            localUsers.push(mapped);
          }
        });
        localStorage.setItem(USERS_DB_KEY, JSON.stringify(localUsers));
      }
    } catch (e) {
      console.warn('Profiles sync notice:', e);
    }
  }
}

syncProfilesFromSupabase();

// Generate Chat Tag: firstname_departmentName_semester_pickupDestination
function formatChatTag(user) {
  if (!user) return 'Anonymous';
  const firstName = (user.name || 'User').split(' ')[0].replace(/[^a-zA-Z0-9]/g, '');
  const dept = (user.department || 'AUST').replace(/[^a-zA-Z0-9]/g, '');
  const sem = (user.semester || '1-1').replace(/[^a-zA-Z0-9-]/g, '');
  const dest = (user.pickupDestination || 'Campus').replace(/[^a-zA-Z0-9]/g, '');
  return `${firstName}_${dept}_${sem}_${dest}`;
}

// Session Management
function saveUserSession(user) {
  const session = {
    user: user,
    loginTimestamp: Date.now()
  };
  localStorage.setItem(SESSION_KEY, JSON.stringify(session));
}

function getCurrentSession() {
  const raw = localStorage.getItem(SESSION_KEY);
  if (!raw) return null;
  try {
    const session = JSON.parse(raw);
    const now = Date.now();
    // 2-hour auto logout check
    if (now - session.loginTimestamp >= SESSION_DURATION_MS) {
      clearUserSession();
      if (window.showAppToast) {
        window.showAppToast('Session expired after 2 hours. Please sign in again.', true);
      }
      return null;
    }
    return session;
  } catch (e) {
    clearUserSession();
    return null;
  }
}

function getCurrentUser() {
  const session = getCurrentSession();
  if (session && session.user) {
    session.user.chatTag = formatChatTag(session.user);
    return session.user;
  }
  return null;
}

function clearUserSession() {
  localStorage.removeItem(SESSION_KEY);
}

// Check session periodically for 2-hour auto logout
setInterval(() => {
  const session = getCurrentSession();
  if (!session) {
    if (typeof activeScreen !== 'undefined' && activeScreen !== 'signin') {
      if (window.switchScreen) window.switchScreen('signin');
    }
  }
}, 30000);

// Protected Pages Security Guard
function checkPageAuthGuard() {
  if (typeof window === 'undefined') return;
  const user = getCurrentUser();
  const path = window.location.pathname;

  const isProtectedSubPage = (
    path.includes('/tracker/') ||
    path.includes('/channels/') ||
    path.includes('/notifications/') ||
    path.includes('/profile/')
  );

  if (isProtectedSubPage && !user) {
    const prefix = path.includes('/pages/') ? '../auth/signin.html' : 'pages/auth/signin.html';
    window.location.replace(prefix);
  }
}

if (typeof window !== 'undefined') {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', checkPageAuthGuard);
  } else {
    checkPageAuthGuard();
  }
}

// Inline Error Helpers for Sign In / Sign Up Boxes
function showAuthInlineError(containerId, message) {
  let box = document.getElementById(containerId);
  if (!box) {
    const activeForm = document.querySelector('form');
    if (activeForm) {
      box = document.createElement('div');
      box.id = containerId;
      box.className = 'p-3 rounded-xl bg-urgent/15 border border-urgent/40 text-urgent text-xs font-semibold flex items-center gap-2 mb-2 animate-shake';
      activeForm.prepend(box);
    }
  }
  if (box) {
    box.innerHTML = `
      <span class="material-symbols-outlined text-urgent text-[18px] shrink-0">error</span>
      <span class="flex-1 text-xs font-semibold">${escapeAuthHtml(message)}</span>
    `;
    box.classList.remove('hidden');
  }
  if (window.showAppToast) {
    window.showAppToast(message, true);
  }
}

function clearAuthInlineError(containerId) {
  const box = document.getElementById(containerId);
  if (box) {
    box.classList.add('hidden');
    box.innerHTML = '';
  }
}

function escapeAuthHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

// Toggle Password Visibility
function togglePasswordVisibility(inputId, triggerBtn) {
  const pwdInput = document.getElementById(inputId);
  if (!pwdInput) return;

  if (pwdInput.type === 'password') {
    pwdInput.type = 'text';
    if (triggerBtn) {
      const icon = triggerBtn.querySelector('.material-symbols-outlined') || triggerBtn;
      if (icon) icon.textContent = 'visibility_off';
    }
  } else {
    pwdInput.type = 'password';
    if (triggerBtn) {
      const icon = triggerBtn.querySelector('.material-symbols-outlined') || triggerBtn;
      if (icon) icon.textContent = 'visibility';
    }
  }
}

// Toggle Auth Tabs
function toggleAuthForm(mode) {
  const signinBox = document.getElementById('signin-box');
  const signupBox = document.getElementById('signup-box');
  const tabIn = document.getElementById('auth-tab-signin');
  const tabUp = document.getElementById('auth-tab-signup');

  clearAuthInlineError('signin-error-box');
  clearAuthInlineError('signup-error-box');

  if (!signinBox || !signupBox) return;

  if (mode === 'signin') {
    signinBox.classList.remove('hidden');
    signupBox.classList.add('hidden');
    if (tabIn && tabUp) {
      tabIn.className = 'flex-1 py-1.5 rounded-full text-center font-label-button text-[13px] bg-surface-elevated text-primary font-semibold shadow transition-all';
      tabUp.className = 'flex-1 py-1.5 rounded-full text-center font-label-button text-[13px] text-text-muted font-medium transition-all';
    }
  } else {
    signinBox.classList.add('hidden');
    signupBox.classList.remove('hidden');
    if (tabIn && tabUp) {
      tabUp.className = 'flex-1 py-1.5 rounded-full text-center font-label-button text-[13px] bg-surface-elevated text-primary font-semibold shadow transition-all';
      tabIn.className = 'flex-1 py-1.5 rounded-full text-center font-label-button text-[13px] text-text-muted font-medium transition-all';
    }
  }
}

// Select Blood Group Chip
let selectedSignUpBloodGroup = 'O+';
function selectSignUpBlood(btn, group) {
  selectedSignUpBloodGroup = group;
  const container = document.getElementById('signup-blood-chips');
  if (container) {
    container.querySelectorAll('button').forEach(b => {
      b.className = 'py-1.5 bg-surface-highest rounded-lg text-xs font-semibold text-text-secondary hover:text-white transition-colors';
    });
  }
  btn.className = 'py-1.5 bg-primary-container text-on-primary-container rounded-lg text-xs font-bold shadow';
}

// Generate standard UUID v4
function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

// Handle Sign In (Strict Validation & Supabase Verification)
async function handleAuthLogin() {
  clearAuthInlineError('signin-error-box');

  const emailOrIdInput = document.getElementById('signin-email');
  const passInput = document.getElementById('signin-pass');

  if (!emailOrIdInput || !passInput) return;

  const emailOrId = emailOrIdInput.value.trim();
  const password = passInput.value;

  if (!emailOrId || !password) {
    showAuthInlineError('signin-error-box', 'Please enter both Email/ID and Password.');
    return;
  }

  // Institutional format validation
  if (emailOrId.includes('@')) {
    if (!emailOrId.toLowerCase().endsWith('@aust.edu')) {
      showAuthInlineError('signin-error-box', 'Email must be an official AUST institutional email (@aust.edu).');
      return;
    }
  } else {
    // If not email, ensure valid Student/Admin ID
    if (emailOrId.length < 3) {
      showAuthInlineError('signin-error-box', 'Please enter a valid Student ID or official @aust.edu email.');
      return;
    }
  }

  if (password.length < 6) {
    showAuthInlineError('signin-error-box', 'Password must be at least 6 characters long.');
    return;
  }

  // Sync latest accounts from Supabase first
  await syncProfilesFromSupabase();

  const users = JSON.parse(localStorage.getItem(USERS_DB_KEY) || '[]');
  
  // Find registered user by email or student ID
  const user = users.find(u => 
    (u.email && u.email.toLowerCase() === emailOrId.toLowerCase()) || 
    (u.studentId && u.studentId.toLowerCase() === emailOrId.toLowerCase()) ||
    (u.id && u.id === emailOrId)
  );

  if (!user) {
    showAuthInlineError('signin-error-box', 'No registered account found with this Email/ID. Please Sign Up first.');
    return;
  }

  // Verify password
  if (user.password !== password) {
    showAuthInlineError('signin-error-box', 'Incorrect password. Please verify your credentials and try again.');
    return;
  }

  // Valid credentials: save session and redirect
  saveUserSession(user);
  clearAuthInlineError('signin-error-box');

  if (window.showAppToast) {
    window.showAppToast(`Welcome back, ${user.name}!`);
  }

  if (window.updateProfileUI) window.updateProfileUI();
  if (window.updateChannelPermissions) window.updateChannelPermissions();

  setTimeout(() => {
    if (window.switchScreen) {
      window.switchScreen('home');
    } else {
      window.location.href = '../tracker/home.html';
    }
  }, 300);
}

// Handle Sign Up (Dynamic with Supabase Database Insert)
async function handleAuthRegister() {
  clearAuthInlineError('signup-error-box');

  const nameInput = document.getElementById('signup-name');
  const idInput = document.getElementById('signup-id');
  const deptInput = document.getElementById('signup-dept');
  const semInput = document.getElementById('signup-sem');
  const emailInput = document.getElementById('signup-email');
  const pickupInput = document.getElementById('signup-pickup');
  const passInput = document.getElementById('signup-pass');
  const passConfirmInput = document.getElementById('signup-pass-confirm');

  if (!nameInput || !idInput || !emailInput || !passInput || !pickupInput) return;

  const name = nameInput.value.trim();
  const studentId = idInput.value.trim();
  const dept = deptInput ? deptInput.value : 'CSE';
  const semester = semInput ? semInput.value : '4-1';
  const email = emailInput.value.trim();
  const pickupDestination = pickupInput.value.trim();
  const password = passInput.value;
  const passConfirm = passConfirmInput ? passConfirmInput.value : password;

  if (!name || !studentId || !email || !pickupDestination || !password) {
    showAuthInlineError('signup-error-box', 'All required fields must be filled.');
    return;
  }

  if (name.length < 2) {
    showAuthInlineError('signup-error-box', 'Please enter your real full name.');
    return;
  }

  if (studentId.length < 4) {
    showAuthInlineError('signup-error-box', 'Student ID must be at least 4 characters.');
    return;
  }

  // Institutional Email Validation: MUST END WITH @aust.edu
  if (!email.toLowerCase().endsWith('@aust.edu')) {
    showAuthInlineError('signup-error-box', 'Institutional email must end with @aust.edu (e.g. name@aust.edu).');
    return;
  }

  if (password.length < 6) {
    showAuthInlineError('signup-error-box', 'Password must be at least 6 characters long.');
    return;
  }

  if (password !== passConfirm) {
    showAuthInlineError('signup-error-box', 'Passwords do not match! Please re-type.');
    return;
  }

  // Check if account already exists
  await syncProfilesFromSupabase();
  const users = JSON.parse(localStorage.getItem(USERS_DB_KEY) || '[]');
  const existingUser = users.find(u => 
    (u.email && u.email.toLowerCase() === email.toLowerCase()) || 
    (u.studentId && u.studentId.toLowerCase() === studentId.toLowerCase())
  );

  if (existingUser) {
    showAuthInlineError('signup-error-box', 'This institutional email or Student ID is already registered. Please Sign In.');
    return;
  }

  const userId = generateUUID();
  const newUser = {
    id: userId,
    studentId,
    name,
    email,
    password,
    department: dept,
    semester: semester,
    bloodGroup: selectedSignUpBloodGroup || 'O+',
    pickupDestination,
    role: 'student'
  };

  // Push directly to Supabase profiles table
  if (typeof SupabaseDb !== 'undefined' && SupabaseDb.saveProfile) {
    try {
      await SupabaseDb.saveProfile({
        id: userId,
        email: email,
        student_id: studentId,
        name: name,
        department: dept,
        session: semester,
        blood_group: selectedSignUpBloodGroup || 'O+',
        role: 'student',
        is_verified: true,
        is_donor: true,
        is_donor_available: true,
        default_route_id: 'route_mirpur',
        default_stop_name: pickupDestination
      });
    } catch (e) {
      console.warn('Supabase profile insertion warning:', e);
    }
  }

  users.push(newUser);
  localStorage.setItem(USERS_DB_KEY, JSON.stringify(users));

  saveUserSession(newUser);
  clearAuthInlineError('signup-error-box');

  if (window.showAppToast) {
    window.showAppToast(`Account registered successfully! Welcome to Padma, ${newUser.name}!`);
  }

  if (window.updateProfileUI) window.updateProfileUI();
  if (window.updateChannelPermissions) window.updateChannelPermissions();

  setTimeout(() => {
    if (window.switchScreen) {
      window.switchScreen('home');
    } else {
      window.location.href = '../tracker/home.html';
    }
  }, 350);
}

// Quick Fill Seed Credentials Helper for Testing
function fillSeedTestCredentials(role = 'student') {
  const emailInput = document.getElementById('signin-email');
  const passInput = document.getElementById('signin-pass');
  clearAuthInlineError('signin-error-box');

  if (emailInput && passInput) {
    if (role === 'student') {
      emailInput.value = 'padmaStudent@aust.edu';
      passInput.value = 'Padma@123';
      if (window.showAppToast) window.showAppToast('Loaded Seed Student: padmaStudent@aust.edu');
    } else {
      emailInput.value = 'admin.rafiq@aust.edu';
      passInput.value = 'Admin@123';
      if (window.showAppToast) window.showAppToast('Loaded Seed Admin: admin.rafiq@aust.edu');
    }
  }
}

// Sign Out
function handleSignOut() {
  clearUserSession();
  if (window.showAppToast) {
    window.showAppToast('Signed out successfully');
  }
  if (window.switchScreen) {
    window.switchScreen('signin');
  } else {
    window.location.href = '../auth/signin.html';
  }
}

// Update User Profile Information (Dynamic with Supabase PATCH)
async function updateUserProfile(data) {
  const currentUser = getCurrentUser();
  if (!currentUser) return false;

  const users = JSON.parse(localStorage.getItem(USERS_DB_KEY) || '[]');
  const idx = users.findIndex(u => u.id === currentUser.id || u.email === currentUser.email || u.studentId === currentUser.studentId);
  if (idx !== -1) {
    users[idx] = { ...users[idx], ...data };
    localStorage.setItem(USERS_DB_KEY, JSON.stringify(users));
    saveUserSession(users[idx]);

    // Update in Supabase profiles
    if (typeof SupabaseDb !== 'undefined' && SupabaseDb.updateProfile) {
      try {
        await SupabaseDb.updateProfile(currentUser.id, {
          name: data.name,
          department: data.department,
          session: data.semester,
          blood_group: data.bloodGroup,
          default_stop_name: data.pickupDestination
        });
      } catch (e) {
        console.warn('Supabase profile update warning:', e);
      }
    }

    if (window.updateProfileUI) window.updateProfileUI();
    if (window.showAppToast) window.showAppToast('Profile updated successfully!');
    return true;
  }
  return false;
}
