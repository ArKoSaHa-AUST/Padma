-- ==============================================================================
-- PADMA: AUST Campus Transit Tracker & Community Hub
-- Supabase PostgreSQL Schema & Realtime Setup
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES TABLE (Linked to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    student_id TEXT,
    name TEXT NOT NULL,
    department TEXT DEFAULT 'CSE',
    session TEXT DEFAULT 'Fall 2021',
    blood_group TEXT DEFAULT 'A+',
    role TEXT DEFAULT 'student' CHECK (role IN ('student', 'admin', 'moderator', 'driver')),
    is_verified BOOLEAN DEFAULT true,
    is_donor BOOLEAN DEFAULT true,
    is_donor_available BOOLEAN DEFAULT true,
    default_route_id TEXT DEFAULT 'route_mirpur',
    default_stop_name TEXT DEFAULT 'Mirpur 10',
    avatar_url TEXT,
    trips_taken INTEGER DEFAULT 0,
    contributions INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. BUS ROUTES TABLE
CREATE TABLE IF NOT EXISTS public.routes (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    name_bn TEXT NOT NULL,
    origin TEXT NOT NULL,
    destination TEXT NOT NULL,
    color TEXT DEFAULT '#2563EB',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. ROUTE STOPS TABLE
CREATE TABLE IF NOT EXISTS public.route_stops (
    id TEXT PRIMARY KEY,
    route_id TEXT NOT NULL REFERENCES public.routes(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    name_bn TEXT NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    stop_order INTEGER NOT NULL,
    estimated_time TEXT,
    is_favorite BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. BUSES TABLE
CREATE TABLE IF NOT EXISTS public.buses (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    bus_number TEXT NOT NULL,
    route_id TEXT NOT NULL REFERENCES public.routes(id) ON DELETE CASCADE,
    driver_name TEXT NOT NULL,
    driver_phone TEXT NOT NULL,
    capacity INTEGER DEFAULT 52,
    current_status TEXT DEFAULT 'onTime' CHECK (current_status IN ('onTime', 'delayed', 'waiting', 'breakdown', 'tripEnded')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. LIVE BUS LOCATIONS (Real-time Telemetry)
CREATE TABLE IF NOT EXISTS public.live_bus_locations (
    bus_id TEXT PRIMARY KEY REFERENCES public.buses(id) ON DELETE CASCADE,
    route_id TEXT NOT NULL REFERENCES public.routes(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    speed_kmh DOUBLE PRECISION DEFAULT 0.0,
    heading DOUBLE PRECISION DEFAULT 0.0,
    eta_minutes INTEGER DEFAULT 0,
    next_stop_name TEXT,
    next_stop_name_bn TEXT,
    current_stop_name TEXT,
    current_stop_index INTEGER DEFAULT 0,
    distance_progress DOUBLE PRECISION DEFAULT 0.0,
    is_broadcasting BOOLEAN DEFAULT false,
    passenger_count INTEGER DEFAULT 0,
    status TEXT DEFAULT 'onTime',
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. LOCATION SHARING SESSIONS
CREATE TABLE IF NOT EXISTS public.location_sharing_sessions (
    id TEXT PRIMARY KEY,
    bus_id TEXT NOT NULL REFERENCES public.buses(id) ON DELETE CASCADE,
    driver_id TEXT,
    status TEXT DEFAULT 'idle' CHECK (status IN ('idle', 'connecting', 'active', 'reconnecting', 'ended')),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. CHANNELS TABLE
CREATE TABLE IF NOT EXISTS public.channels (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    name_bn TEXT,
    type TEXT DEFAULT 'general' CHECK (type IN ('announcements', 'general', 'telemetry', 'emergency', 'rideshare')),
    description TEXT,
    icon TEXT DEFAULT 'chat',
    route_id TEXT,
    is_official BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. MESSAGES TABLE
CREATE TABLE IF NOT EXISTS public.messages (
    id TEXT PRIMARY KEY,
    channel_id TEXT NOT NULL REFERENCES public.channels(id) ON DELETE CASCADE,
    sender_id TEXT NOT NULL,
    sender_name TEXT NOT NULL,
    sender_role TEXT DEFAULT 'student',
    sender_avatar TEXT,
    text TEXT NOT NULL,
    image_url TEXT,
    is_urgent BOOLEAN DEFAULT false,
    is_pinned BOOLEAN DEFAULT false,
    is_telemetry BOOLEAN DEFAULT false,
    badge_text TEXT,
    reply_to_sender_name TEXT,
    reply_to_text TEXT,
    reactions JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. BLOOD REQUESTS TABLE
CREATE TABLE IF NOT EXISTS public.blood_requests (
    id TEXT PRIMARY KEY,
    requester_id TEXT NOT NULL,
    requester_name TEXT NOT NULL,
    requester_phone TEXT NOT NULL,
    blood_group TEXT NOT NULL,
    units INTEGER DEFAULT 1,
    hospital TEXT NOT NULL,
    location TEXT NOT NULL,
    needed_by TIMESTAMPTZ NOT NULL,
    urgency TEXT DEFAULT 'standard' CHECK (urgency IN ('standard', 'urgent', 'critical')),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'fulfilled', 'cancelled')),
    notes TEXT,
    donor_user_ids TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. EMERGENCY REQUESTS TABLE
CREATE TABLE IF NOT EXISTS public.emergency_requests (
    id TEXT PRIMARY KEY,
    type TEXT DEFAULT 'medical',
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    location TEXT NOT NULL,
    contact TEXT NOT NULL,
    requester_name TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    urgency TEXT DEFAULT 'high',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. LOST & FOUND ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.lost_found_items (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    type TEXT DEFAULT 'lost' CHECK (type IN ('lost', 'found')),
    location TEXT NOT NULL,
    contact TEXT NOT NULL,
    image_url TEXT,
    author_name TEXT NOT NULL,
    author_id TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'resolved')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. ADMIN ANNOUNCEMENTS TABLE
CREATE TABLE IF NOT EXISTS public.admin_announcements (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    priority TEXT DEFAULT 'Standard' CHECK (priority IN ('Standard', 'High', 'Urgent')),
    target_route TEXT DEFAULT 'All Routes',
    is_pinned BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. ADMIN STOPPAGE WAIT NOTICES TABLE
CREATE TABLE IF NOT EXISTS public.admin_stoppage_wait_notices (
    id TEXT PRIMARY KEY,
    bus_id TEXT NOT NULL REFERENCES public.buses(id) ON DELETE CASCADE,
    stoppage_name TEXT NOT NULL,
    until_time TEXT NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. REPORTED MESSAGES TABLE
CREATE TABLE IF NOT EXISTS public.reported_messages (
    id TEXT PRIMARY KEY,
    message_id TEXT,
    student_name TEXT NOT NULL,
    student_id TEXT NOT NULL,
    message_content TEXT NOT NULL,
    channel_name TEXT NOT NULL,
    reason TEXT NOT NULL,
    is_resolved BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 15. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS public.notifications (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    title TEXT NOT NULL,
    title_bn TEXT,
    body TEXT NOT NULL,
    body_bn TEXT,
    type TEXT DEFAULT 'transit',
    is_read BOOLEAN DEFAULT false,
    data JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 16. FEEDBACK TABLE
CREATE TABLE IF NOT EXISTS public.feedback (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    user_name TEXT NOT NULL,
    category TEXT DEFAULT 'general',
    message TEXT NOT NULL,
    attachment_url TEXT,
    status TEXT DEFAULT 'open',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.route_stops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.buses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_bus_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_sharing_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blood_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emergency_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lost_found_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_stoppage_wait_notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reported_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

-- Allow public read and write policies for development and demo
DO $$ 
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS "Public access policy on %I" ON public.%I', t, t);
        EXECUTE format('CREATE POLICY "Public access policy on %I" ON public.%I FOR ALL TO anon, authenticated USING (true) WITH CHECK (true)', t, t);
    END LOOP;
END $$;

-- Enable Realtime for live tables
DO $$
BEGIN
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.live_bus_locations;
    EXCEPTION WHEN duplicate_object THEN END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.location_sharing_sessions;
    EXCEPTION WHEN duplicate_object THEN END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
    EXCEPTION WHEN duplicate_object THEN END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.blood_requests;
    EXCEPTION WHEN duplicate_object THEN END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.emergency_requests;
    EXCEPTION WHEN duplicate_object THEN END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.lost_found_items;
    EXCEPTION WHEN duplicate_object THEN END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.admin_announcements;
    EXCEPTION WHEN duplicate_object THEN END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.admin_stoppage_wait_notices;
    EXCEPTION WHEN duplicate_object THEN END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
    EXCEPTION WHEN duplicate_object THEN END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.buses;
    EXCEPTION WHEN duplicate_object THEN END;
END $$;
