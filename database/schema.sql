-- =============================================================================
-- ONSITE CLONE: CONSTRUCTION MANAGEMENT ERP & WORKFORCE PLATFORM
-- PostgreSQL Database Schema (v3.0 Production)
-- =============================================================================

-- Enable PostGIS extension for spatial queries (geofencing, site bounds)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Clean up existing schema if needed
DROP TABLE IF EXISTS mom_action_items CASCADE;
DROP TABLE IF EXISTS mom_records CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS chat_channels CASCADE;
DROP TABLE IF EXISTS compliance_vault CASCADE;
DROP TABLE IF EXISTS fuel_issue_logs CASCADE;
DROP TABLE IF EXISTS equipment_trips CASCADE;
DROP TABLE IF EXISTS equipment_registry CASCADE;
DROP TABLE IF EXISTS payment_approval_logs CASCADE;
DROP TABLE IF EXISTS payment_requests CASCADE;
DROP TABLE IF EXISTS material_transfers CASCADE;
DROP TABLE IF EXISTS grn_records CASCADE;
DROP TABLE IF EXISTS purchase_orders CASCADE;
DROP TABLE IF EXISTS material_transactions CASCADE;
DROP TABLE IF EXISTS material_stocks CASCADE;
DROP TABLE IF EXISTS materials CASCADE;
DROP TABLE IF EXISTS dpr_materials CASCADE;
DROP TABLE IF EXISTS dpr_manpower CASCADE;
DROP TABLE IF EXISTS dpr_reports CASCADE;
DROP TABLE IF EXISTS attendance_liveness_logs CASCADE;
DROP TABLE IF EXISTS attendance CASCADE;
DROP TABLE IF EXISTS user_face_embeddings CASCADE;
DROP TABLE IF EXISTS project_members CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS companies CASCADE;

-- 1. COMPANIES (Multi-Tenant Hierarchy)
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    country_code VARCHAR(10) NOT NULL DEFAULT 'IN',
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    currency_symbol VARCHAR(5) NOT NULL DEFAULT '₹',
    timezone VARCHAR(50) NOT NULL DEFAULT 'Asia/Kolkata',
    logo_url TEXT,
    tax_id VARCHAR(50), -- GSTIN / VAT Number
    subscription_tier VARCHAR(50) DEFAULT 'ENTERPRISE',
    is_locked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. USERS & ROLES
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(255),
    password_hash TEXT,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('SUPER_ADMIN', 'PROJECT_MANAGER', 'SITE_ENGINEER', 'FOREMAN', 'ACCOUNTANT', 'WORKER')),
    trade_type VARCHAR(100), -- MASON, CARPENTER, ELECTRICIAN, HELPER, PLUMBER, OPERATOR
    daily_wage DECIMAL(10, 2) DEFAULT 0.00,
    monthly_fixed_salary DECIMAL(12, 2) DEFAULT 0.00,
    hourly_rate DECIMAL(8, 2) DEFAULT 0.00,
    salary_model VARCHAR(50) DEFAULT 'DAILY_WAGE' CHECK (salary_model IN ('DAILY_WAGE', 'MONTHLY_FIXED', 'HOURLY', 'PIECE_RATE')),
    bank_account_no VARCHAR(50),
    bank_ifsc VARCHAR(20),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. USER FACE EMBEDDINGS (AI Biometrics)
CREATE TABLE user_face_embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    embedding_vector JSONB NOT NULL, -- 128 or 512 dimension floating array
    quality_score DECIMAL(5, 4) DEFAULT 0.95,
    sample_photo_url TEXT,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    enrolled_by UUID REFERENCES users(id)
);

-- 4. PROJECTS & SITES (Geofencing Boundaries)
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    address TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    geofence_radius_meters INT DEFAULT 200,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(15, 2) DEFAULT 0.00,
    status VARCHAR(50) DEFAULT 'ACTIVE' CHECK (status IN ('PLANNING', 'ACTIVE', 'ON_HOLD', 'COMPLETED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Project Members Mapping
CREATE TABLE project_members (
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role_in_project VARCHAR(50) DEFAULT 'MEMBER',
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (project_id, user_id)
);

-- 5. ATTENDANCE & PUNCH RECORDS
CREATE TABLE attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    punch_in_time TIMESTAMP WITH TIME ZONE NOT NULL,
    punch_out_time TIMESTAMP WITH TIME ZONE,
    punch_in_lat DOUBLE PRECISION,
    punch_in_lng DOUBLE PRECISION,
    punch_out_lat DOUBLE PRECISION,
    punch_out_lng DOUBLE PRECISION,
    punch_in_photo_url TEXT,
    punch_out_photo_url TEXT,
    watermark_metadata JSONB, -- Embedded Lat, Lng, Timestamp, Project Code
    verification_type VARCHAR(50) DEFAULT 'FACE_LIVENESS' CHECK (verification_type IN ('SELFIE', 'FACE_LIVENESS', 'MANUAL', 'BULK_FOREMAN')),
    is_geofence_valid BOOLEAN DEFAULT TRUE,
    distance_from_center_meters DECIMAL(8, 2),
    status VARCHAR(50) DEFAULT 'PRESENT' CHECK (status IN ('PRESENT', 'HALF_DAY', 'OVERTIME', 'ABSENT', 'REJECTED')),
    overtime_hours DECIMAL(4, 2) DEFAULT 0.00,
    punched_by UUID REFERENCES users(id), -- For Foreman bulk punch
    remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Liveness Challenge Audit Trail
CREATE TABLE attendance_liveness_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attendance_id UUID REFERENCES attendance(id) ON DELETE CASCADE,
    challenges_passed JSONB NOT NULL, -- e.g. ["BLINK", "HEAD_LEFT", "SMILE"]
    liveness_score DECIMAL(5, 4) NOT NULL,
    is_spoof_detected BOOLEAN DEFAULT FALSE,
    captured_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. DAILY PROGRESS REPORTS (DPR)
CREATE TABLE dpr_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    report_date DATE NOT NULL,
    weather_condition VARCHAR(50) DEFAULT 'CLEAR', -- CLEAR, RAINY, CLOUDY, EXTREME_HEAT
    site_status_summary TEXT NOT NULL,
    prepared_by UUID NOT NULL REFERENCES users(id),
    site_photo_urls JSONB DEFAULT '[]'::jsonb,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (project_id, report_date)
);

CREATE TABLE dpr_manpower (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dpr_id UUID NOT NULL REFERENCES dpr_reports(id) ON DELETE CASCADE,
    trade_name VARCHAR(100) NOT NULL, -- MASON, CARPENTER, ELECTRICIAN, HELPER
    planned_count INT DEFAULT 0,
    actual_present_count INT DEFAULT 0,
    hours_worked DECIMAL(4, 2) DEFAULT 8.00
);

CREATE TABLE dpr_materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dpr_id UUID NOT NULL REFERENCES dpr_reports(id) ON DELETE CASCADE,
    material_name VARCHAR(255) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    consumed_quantity DECIMAL(12, 2) NOT NULL,
    task_activity VARCHAR(255)
);

-- 7. MATERIALS & INVENTORY MANAGEMENT
CREATE TABLE materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) DEFAULT 'GENERAL', -- CEMENT, STEEL, AGGREGATE, PLUMBING, ELECTRICAL
    unit VARCHAR(50) NOT NULL, -- BAGS, KG, TON, SQFT, CFT, METERS
    hsn_code VARCHAR(50),
    min_stock_alert_threshold DECIMAL(12, 2) DEFAULT 10.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE material_stocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    material_id UUID NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
    current_quantity DECIMAL(12, 2) DEFAULT 0.00,
    last_updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (project_id, material_id)
);

CREATE TABLE purchase_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    po_number VARCHAR(100) NOT NULL UNIQUE,
    vendor_name VARCHAR(255) NOT NULL,
    vendor_phone VARCHAR(20),
    total_amount DECIMAL(14, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'ISSUED' CHECK (status IN ('DRAFT', 'ISSUED', 'PARTIALLY_DELIVERED', 'COMPLETED', 'CANCELLED')),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE grn_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    po_id UUID REFERENCES purchase_orders(id),
    grn_number VARCHAR(100) NOT NULL UNIQUE,
    delivery_challan_no VARCHAR(100) NOT NULL,
    challan_photo_url TEXT,
    received_by UUID REFERENCES users(id),
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE material_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    material_id UUID NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
    transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN ('PURCHASE', 'GRN', 'CONSUMPTION', 'TRANSFER_IN', 'TRANSFER_OUT', 'RETURN')),
    quantity DECIMAL(12, 2) NOT NULL,
    grn_id UUID REFERENCES grn_records(id),
    notes TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE material_transfers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_project_id UUID NOT NULL REFERENCES projects(id),
    destination_project_id UUID NOT NULL REFERENCES projects(id),
    material_id UUID NOT NULL REFERENCES materials(id),
    quantity DECIMAL(12, 2) NOT NULL,
    transfer_status VARCHAR(50) DEFAULT 'PENDING' CHECK (transfer_status IN ('PENDING', 'IN_TRANSIT', 'RECEIVED', 'REJECTED')),
    vehicle_number VARCHAR(50),
    driver_phone VARCHAR(20),
    dispatch_photo_url TEXT,
    dispatched_by UUID REFERENCES users(id),
    received_by UUID REFERENCES users(id),
    dispatched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    received_at TIMESTAMP WITH TIME ZONE
);

-- 8. FINANCIALS & MULTI-TIER APPROVALS PIPELINE
CREATE TABLE payment_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    requested_by UUID NOT NULL REFERENCES users(id),
    amount DECIMAL(14, 2) NOT NULL,
    category VARCHAR(100) NOT NULL CHECK (category IN ('MATERIAL', 'LABOUR', 'EQUIPMENT', 'PETTY_CASH', 'SUBCONTRACTOR')),
    payee_name VARCHAR(255) NOT NULL,
    payee_bank_details JSONB,
    description TEXT,
    bill_attachment_url TEXT,
    approval_status VARCHAR(50) DEFAULT 'PENDING' CHECK (approval_status IN ('PENDING', 'LEVEL1_APPROVED', 'APPROVED', 'REJECTED', 'PAID')),
    current_approval_level INT DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE payment_approval_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_request_id UUID NOT NULL REFERENCES payment_requests(id) ON DELETE CASCADE,
    action_by UUID NOT NULL REFERENCES users(id),
    action VARCHAR(50) NOT NULL CHECK (action IN ('APPROVED', 'REJECTED')),
    approval_level INT NOT NULL,
    comments TEXT,
    acted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. EQUIPMENT, FLEET & COMPLIANCE VAULT
CREATE TABLE equipment_registry (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id),
    name VARCHAR(255) NOT NULL, -- e.g. JCB 3DX Excavator
    registration_number VARCHAR(100) NOT NULL UNIQUE,
    equipment_type VARCHAR(100) DEFAULT 'HEAVY_MACHINERY',
    ownership_type VARCHAR(50) DEFAULT 'OWNED' CHECK (ownership_type IN ('OWNED', 'RENTED', 'LEASED')),
    hourly_rate DECIMAL(10, 2) DEFAULT 0.00,
    status VARCHAR(50) DEFAULT 'OPERATIONAL' CHECK (status IN ('OPERATIONAL', 'UNDER_MAINTENANCE', 'IDLE', 'DECOMMISSIONED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE equipment_trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    equipment_id UUID NOT NULL REFERENCES equipment_registry(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id),
    operator_id UUID REFERENCES users(id),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    start_meter_reading DECIMAL(10, 2) NOT NULL,
    end_meter_reading DECIMAL(10, 2),
    total_hours DECIMAL(6, 2) DEFAULT 0.00,
    work_description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE fuel_issue_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    equipment_id UUID NOT NULL REFERENCES equipment_registry(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id),
    quantity_liters DECIMAL(8, 2) NOT NULL,
    meter_reading DECIMAL(10, 2) NOT NULL,
    dispenser_name VARCHAR(100),
    receipt_photo_url TEXT,
    issued_by UUID REFERENCES users(id),
    issued_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE compliance_vault (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    equipment_id UUID NOT NULL REFERENCES equipment_registry(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('FITNESS_CERTIFICATE', 'PUCC', 'INSURANCE', 'ROAD_PERMIT', 'TAX_RECEIPT')),
    document_number VARCHAR(100),
    expiry_date DATE NOT NULL,
    document_file_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. REAL-TIME CHAT & COLLABORATION
CREATE TABLE chat_channels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    channel_type VARCHAR(50) DEFAULT 'PROJECT_SITE' CHECK (channel_type IN ('PROJECT_SITE', 'VENDOR', 'MANAGEMENT', 'DIRECT')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    channel_id UUID NOT NULL REFERENCES chat_channels(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message_text TEXT,
    media_url TEXT,
    media_type VARCHAR(50) DEFAULT 'TEXT' CHECK (media_type IN ('TEXT', 'IMAGE', 'VOICE_NOTE', 'DOCUMENT')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- INDEXES FOR HIGH-THROUGHPUT PERFORMANCE
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_company ON users(company_id);
CREATE INDEX idx_attendance_user_date ON attendance(user_id, punch_in_time);
CREATE INDEX idx_attendance_project ON attendance(project_id);
CREATE INDEX idx_materials_stock_project ON material_stocks(project_id);
CREATE INDEX idx_payment_requests_project_status ON payment_requests(project_id, approval_status);
CREATE INDEX idx_chat_messages_channel ON chat_messages(channel_id, created_at DESC);
