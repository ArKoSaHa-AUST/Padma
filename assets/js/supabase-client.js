/**
 * Padma - Supabase Client Bridge & Database Connector
 * Direct live integration with Supabase Postgres REST & Realtime APIs
 */

const SUPABASE_CONFIG = {
  url: 'https://usherhmmpcfayggmkito.supabase.co',
  key: 'sb_publishable_AbsEe-WhHHl0w3wfAyVpdQ_elmxoArC'
};

// Initialize Official Supabase JS SDK client if available
let supabaseClient = null;
if (typeof window !== 'undefined' && window.supabase && window.supabase.createClient) {
  try {
    supabaseClient = window.supabase.createClient(SUPABASE_CONFIG.url, SUPABASE_CONFIG.key);
  } catch (e) {
    console.warn('Supabase SDK initialization notice:', e);
  }
}

// Resilient REST API Client for Supabase
const SupabaseDb = {
  getHeaders() {
    return {
      'apikey': SUPABASE_CONFIG.key,
      'Authorization': 'Bearer ' + SUPABASE_CONFIG.key,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    };
  },

  async query(table, params = '') {
    try {
      const res = await fetch(`${SUPABASE_CONFIG.url}/rest/v1/${table}${params ? '?' + params : ''}`, {
        method: 'GET',
        headers: this.getHeaders()
      });
      if (!res.ok) {
        throw new Error(`Supabase query failed on ${table}: ${res.status} ${res.statusText}`);
      }
      return await res.json();
    } catch (err) {
      console.error(`[SupabaseDb.query error on ${table}]:`, err);
      return null;
    }
  },

  async insert(table, payload) {
    try {
      const res = await fetch(`${SUPABASE_CONFIG.url}/rest/v1/${table}`, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify(payload)
      });
      if (!res.ok) {
        const errText = await res.text();
        console.error(`[SupabaseDb.insert failed on ${table}]:`, errText);
        throw new Error(errText);
      }
      return await res.json();
    } catch (err) {
      console.error(`[SupabaseDb.insert error on ${table}]:`, err);
      return null;
    }
  },

  async upsert(table, payload) {
    try {
      const res = await fetch(`${SUPABASE_CONFIG.url}/rest/v1/${table}`, {
        method: 'POST',
        headers: {
          ...this.getHeaders(),
          'Prefer': 'resolution=merge-duplicates,return=representation'
        },
        body: JSON.stringify(payload)
      });
      if (!res.ok) {
        const errText = await res.text();
        console.error(`[SupabaseDb.upsert failed on ${table}]:`, errText);
        throw new Error(errText);
      }
      return await res.json();
    } catch (err) {
      console.error(`[SupabaseDb.upsert error on ${table}]:`, err);
      return null;
    }
  },

  async update(table, filterQuery, payload) {
    try {
      const res = await fetch(`${SUPABASE_CONFIG.url}/rest/v1/${table}?${filterQuery}`, {
        method: 'PATCH',
        headers: this.getHeaders(),
        body: JSON.stringify(payload)
      });
      if (!res.ok) {
        const errText = await res.text();
        console.error(`[SupabaseDb.update failed on ${table}]:`, errText);
        throw new Error(errText);
      }
      return await res.json();
    } catch (err) {
      console.error(`[SupabaseDb.update error on ${table}]:`, err);
      return null;
    }
  },

  async delete(table, filterQuery) {
    try {
      const res = await fetch(`${SUPABASE_CONFIG.url}/rest/v1/${table}?${filterQuery}`, {
        method: 'DELETE',
        headers: this.getHeaders()
      });
      if (!res.ok) {
        const errText = await res.text();
        console.error(`[SupabaseDb.delete failed on ${table}]:`, errText);
        throw new Error(errText);
      }
      return true;
    } catch (err) {
      console.error(`[SupabaseDb.delete error on ${table}]:`, err);
      return false;
    }
  },

  // -----------------------------------------------------------------
  // 1. Authentication & Profiles
  // -----------------------------------------------------------------
  async fetchProfiles() {
    return await this.query('profiles', 'select=*');
  },

  async fetchProfileByEmailOrId(emailOrId) {
    const isEmail = emailOrId.includes('@');
    const queryStr = isEmail 
      ? `email=eq.${encodeURIComponent(emailOrId)}`
      : `student_id=eq.${encodeURIComponent(emailOrId)}`;
    const results = await this.query('profiles', `${queryStr}&select=*`);
    return (results && results.length > 0) ? results[0] : null;
  },

  async saveProfile(profile) {
    return await this.upsert('profiles', profile);
  },

  async updateProfile(idOrStudentId, updateData) {
    const isUuid = idOrStudentId.length === 36 && idOrStudentId.includes('-');
    const filter = isUuid ? `id=eq.${idOrStudentId}` : `student_id=eq.${idOrStudentId}`;
    return await this.update('profiles', filter, updateData);
  },

  // -----------------------------------------------------------------
  // 2. Chat & Telemetry Channels
  // -----------------------------------------------------------------
  async fetchChannels() {
    return await this.query('channels', 'is_active=eq.true&order=created_at.asc');
  },

  async fetchMessages(channelId) {
    return await this.query('messages', `channel_id=eq.${encodeURIComponent(channelId)}&order=created_at.asc`);
  },

  async postMessage(message) {
    return await this.insert('messages', message);
  },

  async updateReactions(messageId, reactions) {
    return await this.update('messages', `id=eq.${encodeURIComponent(messageId)}`, { reactions });
  },

  // -----------------------------------------------------------------
  // 3. Student Assistance - Blood Requests
  // -----------------------------------------------------------------
  async fetchBloodRequests() {
    return await this.query('blood_requests', 'order=created_at.desc');
  },

  async postBloodRequest(req) {
    return await this.insert('blood_requests', req);
  },

  async updateBloodRequest(id, updateData) {
    return await this.update('blood_requests', `id=eq.${encodeURIComponent(id)}`, updateData);
  },

  async deleteBloodRequest(id) {
    return await this.delete('blood_requests', `id=eq.${encodeURIComponent(id)}`);
  },

  // -----------------------------------------------------------------
  // 4. Student Assistance - Lost and Found
  // -----------------------------------------------------------------
  async fetchLostFoundItems() {
    return await this.query('lost_found_items', 'order=created_at.desc');
  },

  async postLostFoundItem(item) {
    return await this.insert('lost_found_items', item);
  },

  async updateLostFoundItem(id, updateData) {
    return await this.update('lost_found_items', `id=eq.${encodeURIComponent(id)}`, updateData);
  },

  async deleteLostFoundItem(id) {
    return await this.delete('lost_found_items', `id=eq.${encodeURIComponent(id)}`);
  },

  // -----------------------------------------------------------------
  // 5. Post Responses (Blood Donors & Lost/Found Claims)
  // -----------------------------------------------------------------
  async fetchPostResponses(postId = null) {
    const params = postId 
      ? `post_id=eq.${encodeURIComponent(postId)}&order=created_at.desc`
      : 'order=created_at.desc';
    return await this.query('post_responses', params);
  },

  async postPostResponse(response) {
    return await this.insert('post_responses', response);
  },

  async updatePostResponse(id, updateData) {
    return await this.update('post_responses', `id=eq.${encodeURIComponent(id)}`, updateData);
  },

  async deletePostResponse(id) {
    return await this.delete('post_responses', `id=eq.${encodeURIComponent(id)}`);
  },

  // -----------------------------------------------------------------
  // 5.1 Post Comments (Lost & Found Comments)
  // -----------------------------------------------------------------
  async fetchPostComments(postId = null) {
    const params = postId 
      ? `post_id=eq.${encodeURIComponent(postId)}&order=created_at.asc`
      : 'order=created_at.asc';
    return await this.query('post_comments', params);
  },

  async postComment(comment) {
    return await this.insert('post_comments', comment);
  },

  async updateComment(id, updateData) {
    return await this.update('post_comments', `id=eq.${encodeURIComponent(id)}`, updateData);
  },

  async deleteComment(id) {
    return await this.delete('post_comments', `id=eq.${encodeURIComponent(id)}`);
  },

  // -----------------------------------------------------------------
  // 6. Submit Grievance / Feedback Document
  // -----------------------------------------------------------------
  async fetchComplaints() {
    return await this.query('feedback', 'order=created_at.desc');
  },

  async postComplaint(complaint) {
    return await this.insert('feedback', complaint);
  },

  // -----------------------------------------------------------------
  // 7. Notifications & Proximity Alerts
  // -----------------------------------------------------------------
  async fetchNotifications() {
    return await this.query('notifications', 'order=created_at.desc');
  },

  async markAllNotificationsRead() {
    return await this.update('notifications', 'is_read=eq.false', { is_read: true });
  },

  async postNotification(notif) {
    return await this.insert('notifications', notif);
  },

  // -----------------------------------------------------------------
  // 8. Live Bus Telemetry, Routes & Stops
  // -----------------------------------------------------------------
  async fetchLiveBusLocations() {
    return await this.query('live_bus_locations', 'select=*');
  },

  async fetchBuses() {
    return await this.query('buses', 'select=*');
  },

  async fetchRoutes() {
    return await this.query('routes', 'select=*');
  },

  async fetchRouteStops() {
    return await this.query('route_stops', 'order=stop_order.asc');
  },

  // -----------------------------------------------------------------
  // 9. Real-time Channel Setup & Local Broadcast Bus
  // -----------------------------------------------------------------
  initRealtimeListeners(onChangeCallback) {
    // 1. Cross-tab BroadcastChannel
    if (typeof window !== 'undefined' && window.BroadcastChannel) {
      try {
        const bc = new BroadcastChannel('padma_realtime_broadcast');
        bc.onmessage = (event) => {
          if (onChangeCallback) onChangeCallback(event.data);
        };
        window.padmaBroadcastChannel = bc;
      } catch (e) {
        console.warn('BroadcastChannel error:', e);
      }
    }

    // 2. Supabase Realtime WebSocket client (if active)
    if (supabaseClient && supabaseClient.channel) {
      try {
        supabaseClient.channel('padma_realtime_postgres')
          .on('postgres_changes', { event: '*', schema: 'public' }, (payload) => {
            if (onChangeCallback) onChangeCallback(payload);
          })
          .subscribe();
      } catch (e) {
        console.warn('Supabase realtime subscription notice:', e);
      }
    }
  },

  broadcastChange(type, data = {}) {
    // Broadcast across windows / tabs
    if (window.padmaBroadcastChannel) {
      try {
        window.padmaBroadcastChannel.postMessage({ type, data, timestamp: Date.now() });
      } catch (e) {}
    }
    // Dispatch in current window
    window.dispatchEvent(new CustomEvent('padma:realtime-update', { detail: { type, data } }));
  }
};

window.SupabaseDb = SupabaseDb;

