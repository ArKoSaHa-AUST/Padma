-- ==============================================================================
-- PADMA: Supabase Initial Seed Data
-- ==============================================================================

-- 1. BUS ROUTES
INSERT INTO public.routes (id, name, name_bn, origin, destination, color, is_active) VALUES
('route_mirpur', 'Mirpur Route (Bus-1)', 'মিরপুর রুট (বাস-১)', 'Mirpur 14', 'AUST Campus (Tejgaon)', '#2563EB', true),
('route_uttara', 'Uttara Route (Bus-2)', 'উত্তরা রুট (বাস-২)', 'Uttara Sector 10', 'AUST Campus (Tejgaon)', '#10B981', true),
('route_dhanmondi', 'Dhanmondi Route (Bus-3)', 'ধানমন্ডি রুট (বাস-৩)', 'Dhanmondi 27', 'AUST Campus (Tejgaon)', '#F59E0B', true)
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    name_bn = EXCLUDED.name_bn,
    origin = EXCLUDED.origin,
    destination = EXCLUDED.destination;

-- 2. ROUTE STOPS (Mirpur Route)
INSERT INTO public.route_stops (id, route_id, name, name_bn, lat, lng, stop_order, estimated_time) VALUES
('stop_m1', 'route_mirpur', 'Mirpur 14 (Origin)', 'মিরপুর ১৪ (প্রারম্ভ)', 23.7997, 90.3842, 1, '06:45 AM'),
('stop_m2', 'route_mirpur', 'Mirpur 10 Circle', 'মিরপুর ১০ গোলচত্বর', 23.8069, 90.3687, 2, '06:55 AM'),
('stop_m3', 'route_mirpur', 'Kazipara Bus Stand', 'কাজীপুর বাস স্ট্যান্ড', 23.7956, 90.3732, 3, '07:05 AM'),
('stop_m4', 'route_mirpur', 'Shewrapara', 'শেওড়াপাড়া', 23.7877, 90.3753, 4, '07:15 AM'),
('stop_m5', 'route_mirpur', 'Agargaon Crossing', 'আগারগাঁও ক্রসিং', 23.7785, 90.3792, 5, '07:25 AM'),
('stop_m6', 'route_mirpur', 'Bijoy Sarani', 'বিজয় সরণী', 23.7656, 90.3879, 6, '07:35 AM'),
('stop_m7', 'route_mirpur', 'Jahangir Gate (Mohakhali)', 'জাহাঙ্গীর গেট', 23.7749, 90.3927, 7, '07:42 AM'),
('stop_m8', 'route_mirpur', 'AUST Campus Main Gate', 'আহছানউল্লা ক্যাম্পাস', 23.7639, 90.4070, 8, '07:50 AM')
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    name_bn = EXCLUDED.name_bn,
    lat = EXCLUDED.lat,
    lng = EXCLUDED.lng;

-- ROUTE STOPS (Uttara Route)
INSERT INTO public.route_stops (id, route_id, name, name_bn, lat, lng, stop_order, estimated_time) VALUES
('stop_u1', 'route_uttara', 'Uttara Sector 10 (Origin)', 'উত্তরা সেক্টর ১০', 23.8759, 90.3795, 1, '06:30 AM'),
('stop_u2', 'route_uttara', 'House Building', 'হাউজ বিল্ডিং', 23.8682, 90.3976, 2, '06:40 AM'),
('stop_u3', 'route_uttara', 'Azampur', 'আজমপুর', 23.8583, 90.4005, 3, '06:48 AM'),
('stop_u4', 'route_uttara', 'Airport Station', 'বিমানবন্দর', 23.8519, 90.4081, 4, '07:00 AM'),
('stop_u5', 'route_uttara', 'Khilkhet', 'খিলক্ষেত', 23.8293, 90.4215, 5, '07:12 AM'),
('stop_u6', 'route_uttara', 'Kuril Flyover', 'কুড়িল ফ্লাইওভার', 23.8152, 90.4201, 6, '07:22 AM'),
('stop_u7', 'route_uttara', 'Banani Chairman Bari', 'বনানী চেয়ারম্যান বাড়ি', 23.7915, 90.4038, 7, '07:35 AM'),
('stop_u8', 'route_uttara', 'AUST Campus Main Gate', 'আহছানউল্লা ক্যাম্পাস', 23.7639, 90.4070, 8, '07:50 AM')
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    name_bn = EXCLUDED.name_bn,
    lat = EXCLUDED.lat,
    lng = EXCLUDED.lng;

-- 3. BUSES
INSERT INTO public.buses (id, title, bus_number, route_id, driver_name, driver_phone, capacity, current_status, is_active) VALUES
('bus_1', 'Padma 1 (Mirpur Special)', 'Dhaka Metro Cha 11-4201', 'route_mirpur', 'Md. Rafiqul Islam', '+880 1712-345678', 52, 'onTime', true),
('bus_2', 'Padma 2 (Uttara Express)', 'Dhaka Metro Cha 11-8890', 'route_uttara', 'Md. Kamal Hossain', '+880 1819-876543', 52, 'delayed', true),
('bus_3', 'Padma 3 (Dhanmondi Shuttle)', 'Dhaka Metro Cha 11-3312', 'route_dhanmondi', 'Md. Shah Alam', '+880 1914-554433', 52, 'waiting', true)
ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    driver_name = EXCLUDED.driver_name,
    driver_phone = EXCLUDED.driver_phone;

-- 4. LIVE BUS LOCATIONS
INSERT INTO public.live_bus_locations (
    bus_id, route_id, latitude, longitude, speed_kmh, heading, eta_minutes, 
    next_stop_name, next_stop_name_bn, current_stop_name, current_stop_index, 
    distance_progress, is_broadcasting, passenger_count, status, updated_at
) VALUES
('bus_1', 'route_mirpur', 23.7877, 90.3753, 34.5, 145.0, 8, 'Shewrapara', 'শেওড়াপাড়া', 'Kazipara Bus Stand', 3, 0.45, true, 42, 'onTime', NOW()),
('bus_2', 'route_uttara', 23.8293, 90.4215, 22.0, 180.0, 15, 'Khilkhet', 'খিলক্ষেত', 'Airport Station', 4, 0.60, true, 48, 'delayed', NOW()),
('bus_3', 'route_dhanmondi', 23.7639, 90.4070, 0.0, 0.0, 0, 'AUST Campus', 'আহছানউল্লা ক্যাম্পাস', 'AUST Campus', 0, 0.0, false, 0, 'waiting', NOW())
ON CONFLICT (bus_id) DO UPDATE SET 
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    speed_kmh = EXCLUDED.speed_kmh,
    eta_minutes = EXCLUDED.eta_minutes,
    next_stop_name = EXCLUDED.next_stop_name,
    is_broadcasting = EXCLUDED.is_broadcasting,
    updated_at = NOW();

-- 5. CHANNELS
INSERT INTO public.channels (id, name, name_bn, type, description, icon, is_official, is_active) VALUES
('announcements', 'official-announcements', 'অফিসিয়াল বিজ্ঞপ্তি', 'announcements', 'Official notifications from AUST Transport Office', 'campaign', true, true),
('general', 'general-community', 'সাধারণ আলোচনা', 'general', 'Open student hub for queries, schedules & discussions', 'forum', false, true),
('bus-1-mirpur', 'bus-1-mirpur-telemetry', 'বাস-১ মিরপুর লাইভ', 'telemetry', 'Live passenger & conductor chat for Mirpur Route', 'directions_bus', false, true),
('bus-2-uttara', 'bus-2-uttara-telemetry', 'বাস-২ উত্তরা লাইভ', 'telemetry', 'Live passenger & conductor chat for Uttara Route', 'directions_bus', false, true),
('emergency-blood', 'emergency-blood-bank', 'জরুরি রক্তদান', 'emergency', 'AUST Blood Donors Network & Urgent Requests', 'bloodtype', true, true),
('ride-share', 'aust-ride-share', 'রাইড শেয়ারিং', 'rideshare', 'Campus carpooling and ride coordination', 'commute', false, true)
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    description = EXCLUDED.description;

-- 6. MESSAGES
INSERT INTO public.messages (id, channel_id, sender_id, sender_name, sender_role, text, is_urgent, is_pinned, is_telemetry, badge_text, reactions, created_at) VALUES
('msg_ann_1', 'announcements', 'admin_1', 'Padma Transport Office', 'admin', '📢 **Campus Departure Advisory**: Afternoon trips for all routes will depart strictly from Main Gate at 01:45 PM.', false, true, true, 'OFFICIAL NOTICE', '{"👍": 32, "🚌": 18}'::JSONB, NOW() - INTERVAL '2 hours'),
('msg_ann_2', 'announcements', 'admin_1', 'Padma Dispatch Control', 'admin', '🌧️ **Weather Alert**: Pre-monsoon showers expected along Mirpur Corridor. Drivers advised to maintain 35km/h safety limit.', true, false, true, 'WEATHER ALERT', '{"☔": 14}'::JSONB, NOW() - INTERVAL '4 hours'),
('msg_gen_1', 'general', 'stu_tanvir', 'Tanvir Ahmed (CSE 4.1)', 'student', 'Has Bus 1 crossed Shewrapara yet? Road traffic seems moderate at Agargaon.', false, false, false, NULL, '{"👀": 4}'::JSONB, NOW() - INTERVAL '15 minutes'),
('msg_gen_2', 'general', 'stu_nabil', 'Nabil Hasan (EEE 4.2)', 'student', 'Yes, conductor confirmed it just passed Shewrapara flyover heading towards Agargaon.', false, false, false, NULL, '{"👍": 6, "❤️": 2}'::JSONB, NOW() - INTERVAL '12 minutes'),
('msg_bus1_1', 'bus-1-mirpur', 'driver_rafiq', 'Rafiqul Islam (Conductor)', 'driver', '🚌 **Bus 1 Live Update**: Currently at Kazipara. 6 seats available in the middle row.', false, false, true, 'CONDUCTOR', '{"👍": 15}'::JSONB, NOW() - INTERVAL '20 minutes'),
('msg_bus2_1', 'bus-2-uttara', 'driver_kamal', 'Kamal Hossain (Driver)', 'driver', 'Bus 2 approaching Khilkhet overpass. Delay approx 5 mins due to construction.', false, false, true, 'DRIVER', '{"⏱️": 8}'::JSONB, NOW() - INTERVAL '25 minutes'),
('msg_bld_1', 'emergency-blood', 'stu_siam', 'Siam Chowdhury (CSE 3.1)', 'student', '🔴 **URGENT**: Need 2 Bags of O+ Blood for emergency surgery at Dhaka Medical College Hospital. Contact: 01711-889900.', true, true, false, 'URGENT O+', '{"🩸": 19, "🙏": 8}'::JSONB, NOW() - INTERVAL '35 minutes'),
('msg_rs_1', 'ride-share', 'stu_arif', 'Ariful Islam (ME 3.2)', 'student', '🚗 Leaving Mirpur DOHS towards AUST Campus at 7:30 AM tomorrow. 2 seats available in private sedan. DM to join.', false, false, false, 'CARPOOL', '{"🚗": 6}'::JSONB, NOW() - INTERVAL '50 minutes')
ON CONFLICT (id) DO NOTHING;

-- 7. BLOOD REQUESTS
INSERT INTO public.blood_requests (id, requester_id, requester_name, requester_phone, blood_group, units, hospital, location, needed_by, urgency, status, notes, donor_user_ids, created_at) VALUES
('br_1', 'stu_siam', 'Siam Chowdhury', '01711-889900', 'O+', 2, 'Dhaka Medical College Hospital', 'Bakshibazar, Dhaka', NOW() + INTERVAL '4 hours', 'critical', 'active', 'Emergency surgery required post-accident. Immediate matching donors appreciated.', ARRAY['stu_tanvir', 'stu_nabil'], NOW() - INTERVAL '1 hour'),
('br_2', 'stu_farhana', 'Farhana Yasmin', '01812-334455', 'B+', 1, 'Square Hospital', 'Panthapath, Dhaka', NOW() + INTERVAL '12 hours', 'urgent', 'active', 'Platelet requirement for university student relative.', ARRAY[]::TEXT[], NOW() - INTERVAL '3 hours'),
('br_3', 'stu_mahmud', 'Mahmudul Hasan', '01911-223344', 'AB-', 1, 'National Heart Foundation', 'Mirpur 2, Dhaka', NOW() + INTERVAL '24 hours', 'standard', 'active', 'Planned cardiac procedure. Rare blood group volunteer needed.', ARRAY[]::TEXT[], NOW() - INTERVAL '6 hours')
ON CONFLICT (id) DO NOTHING;

-- 8. EMERGENCY REQUESTS
INSERT INTO public.emergency_requests (id, type, title, description, location, contact, requester_name, status, urgency, created_at) VALUES
('emg_1', 'medical', 'Urgent O+ Blood Needed at DMCH', 'Post-operative transfusion for AUST CSE student family member.', 'Dhaka Medical College Hospital', '01711-889900', 'Siam Chowdhury', 'active', 'critical', NOW() - INTERVAL '30 minutes'),
('emg_2', 'security', 'Lost Student ID & Bag near Gate 2', 'Black backpack containing ID card 210104050 and calculator left at tea stall.', 'AUST Gate 2', '01988-776655', 'Tahmid Rahman', 'pending', 'standard', NOW() - INTERVAL '2 hours')
ON CONFLICT (id) DO NOTHING;

-- 9. LOST & FOUND ITEMS
INSERT INTO public.lost_found_items (id, title, description, type, location, contact, author_name, status, created_at) VALUES
('lf_1', 'Scientific Calculator FX-991EX', 'Left in Classroom 4A03 after Math exam. Has red sticker on back.', 'lost', 'Room 4A03, Academic Building', '01700-112233', 'Sadia Afrin (CSE 2.2)', 'active', NOW() - INTERVAL '3 hours'),
('lf_2', 'AUST Student ID Card (EEE 2021)', 'Found near Main Gate Security Post. ID belongs to Zubair Ahmed.', 'found', 'Campus Security Post', '01822-445566', 'Security Desk', 'active', NOW() - INTERVAL '5 hours'),
('lf_3', 'Titan Men Wristwatch (Silver)', 'Lost near Library 3rd Floor study section on Monday afternoon.', 'lost', 'Central Library 3rd Floor', '01933-778899', 'Rafiul Karim', 'active', NOW() - INTERVAL '1 day')
ON CONFLICT (id) DO NOTHING;

-- 10. ADMIN ANNOUNCEMENTS
INSERT INTO public.admin_announcements (id, title, body, priority, target_route, is_pinned, created_at) VALUES
('ann_adm_1', 'Semester Final Schedule Transport Hours', 'Special late evening departures at 06:30 PM will be active during exam week across all standard routes.', 'High', 'All Routes', true, NOW() - INTERVAL '1 day'),
('ann_adm_2', 'Mirpur Route Road Maintenance Notice', 'Due to road carpeting near Kazipara station, expect 5-10 minute minor delays during morning peak hours.', 'Standard', 'Mirpur Route (Bus-1)', false, NOW() - INTERVAL '2 days')
ON CONFLICT (id) DO NOTHING;

-- 11. NOTIFICATIONS
INSERT INTO public.notifications (id, user_id, title, title_bn, body, body_bn, type, is_read, data, created_at) VALUES
('notif_1', NULL, 'Bus 1 Approaching Your Stop', 'বাস-১ আপনার স্টপেজের কাছাকাছি', 'Padma 1 is 800m away from Shewrapara. Expected arrival in 4 minutes.', 'পদ্মা ১ শেওড়াপাড়া থেকে ৮০০ মিটার দূরে। ৪ মিনিটের মধ্যে পৌঁছাবে।', 'transit', false, '{"bus_id": "bus_1", "route_id": "route_mirpur"}'::JSONB, NOW() - INTERVAL '5 minutes'),
('notif_2', NULL, 'Urgent Blood Need - O+ at DMCH', 'জরুরি রক্তের প্রয়োজন - ও+ ডিএমসিএইচ', 'Siam Chowdhury needs 2 units of O+ blood for surgery.', 'সিয়াম চৌধুরীর জরুরি অপারেশনের জন্য ২ ব্যাগ ও+ রক্ত প্রয়োজন।', 'blood', false, '{"request_id": "br_1"}'::JSONB, NOW() - INTERVAL '40 minutes')
ON CONFLICT (id) DO NOTHING;
