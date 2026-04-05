-- ============================================================
-- ArdenPia - Güzellik Salonu Randevu & Yönetim Sistemi
-- Supabase PostgreSQL Schema
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. CLIENTS TABLE (Müşteriler)
-- ============================================================
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    surname TEXT NOT NULL,
    gender TEXT CHECK (gender IN ('Kadın', 'Erkek', 'Diğer')),
    job TEXT,
    treatment_areas TEXT[] DEFAULT '{}',
    price_per_area DECIMAL(10,2) DEFAULT 0,
    dob DATE,
    phone TEXT,
    address TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 2. SERVICES TABLE (Hizmetler)
-- ============================================================
CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    default_duration_min INTEGER NOT NULL DEFAULT 30,
    default_price DECIMAL(10,2) NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 3. APPOINTMENTS TABLE (Randevular)
-- ============================================================
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES services(id) ON DELETE RESTRICT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    duration_min INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 4. CAMPAIGNS TABLE (Kampanyalar / SMS Logları)
-- ============================================================
CREATE TABLE campaigns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    recipient_count INTEGER NOT NULL DEFAULT 0,
    recipient_ids UUID[] DEFAULT '{}',
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'sent' CHECK (status IN ('draft', 'sent', 'failed')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_appointments_start_time ON appointments(start_time);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_client_id ON appointments(client_id);
CREATE INDEX idx_appointments_user_id ON appointments(user_id);
CREATE INDEX idx_clients_name ON clients(name, surname);
CREATE INDEX idx_clients_user_id ON clients(user_id);
CREATE INDEX idx_services_user_id ON services(user_id);

-- ============================================================
-- UPDATED_AT TRIGGER
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_clients_updated_at
    BEFORE UPDATE ON clients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_services_updated_at
    BEFORE UPDATE ON services
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at
    BEFORE UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;

-- Clients: only owner can CRUD
CREATE POLICY "Users can manage their own clients"
    ON clients FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Services: only owner can CRUD
CREATE POLICY "Users can manage their own services"
    ON services FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Appointments: only owner can CRUD
CREATE POLICY "Users can manage their own appointments"
    ON appointments FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Campaigns: only owner can CRUD
CREATE POLICY "Users can manage their own campaigns"
    ON campaigns FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- SEED DATA: Sample services (Hizmetler)
-- Run this AFTER creating a user and replacing 'YOUR_USER_ID'
-- ============================================================
-- INSERT INTO services (user_id, name, default_duration_min, default_price) VALUES
--     ('YOUR_USER_ID', 'Lazer Epilasyon', 45, 500),
--     ('YOUR_USER_ID', 'Kaş Lifting', 10, 150),
--     ('YOUR_USER_ID', 'Cilt Bakımı', 60, 400),
--     ('YOUR_USER_ID', 'Ağda', 30, 200),
--     ('YOUR_USER_ID', 'Manikür', 45, 250),
--     ('YOUR_USER_ID', 'Pedikür', 45, 250),
--     ('YOUR_USER_ID', 'Kirpik Lifting', 15, 200),
--     ('YOUR_USER_ID', 'Kalıcı Makyaj', 90, 1500),
--     ('YOUR_USER_ID', 'Saç Boyama', 120, 800),
--     ('YOUR_USER_ID', 'Saç Kesimi', 30, 200);

-- ============================================================
-- MIGRATION: Oda (Room) Sistemi
-- Bu satırı Supabase SQL Editor'de çalıştırın (mevcut veritabanına eklemek için)
-- ============================================================
-- ALTER TABLE appointments
-- ADD COLUMN IF NOT EXISTS room TEXT NOT NULL DEFAULT 'oda1'
-- CHECK (room IN ('oda1', 'oda2'));

