import { v4 as uuidv4 } from 'uuid';

export interface Company {
  id: string;
  name: string;
  country_code: string;
  currency: string;
  currency_symbol: string;
  logo_url?: string;
  created_at: string;
}

export interface User {
  id: string;
  company_id: string;
  phone_number: string;
  full_name: string;
  role: 'SUPER_ADMIN' | 'PROJECT_MANAGER' | 'SITE_ENGINEER' | 'FOREMAN' | 'ACCOUNTANT' | 'WORKER';
  trade_type?: string;
  daily_wage: number;
  monthly_fixed_salary: number;
  salary_model?: 'DAILY_WAGE' | 'MONTHLY_FIXED' | 'HOURLY' | 'PIECE_RATE';
  avatar_url?: string;
  is_active: boolean;
  face_embedding?: number[];
  created_at: string;
}

export interface Project {
  id: string;
  company_id: string;
  name: string;
  code: string;
  latitude: number;
  longitude: number;
  geofence_radius_meters: number;
  status: 'ACTIVE' | 'PLANNING' | 'COMPLETED';
}

export interface Attendance {
  id: string;
  user_id: string;
  project_id: string;
  punch_in_time: string;
  punch_out_time?: string;
  punch_in_lat: number;
  punch_in_lng: number;
  punch_in_photo_url: string;
  verification_type: string;
  is_geofence_valid: boolean;
  distance_from_center_meters: number;
  status: string;
  overtime_hours: number;
}

export interface Material {
  id: string;
  company_id: string;
  name: string;
  category: string;
  unit: string;
  hsn_code: string;
  min_stock_alert_threshold: number;
}

export interface MaterialStock {
  id: string;
  project_id: string;
  material_id: string;
  current_quantity: number;
  last_updated_at: string;
}

export interface PaymentRequest {
  id: string;
  project_id: string;
  requested_by: string;
  amount: number;
  category: string;
  payee_name: string;
  description: string;
  bill_attachment_url?: string;
  approval_status: 'PENDING' | 'LEVEL1_APPROVED' | 'APPROVED' | 'REJECTED' | 'PAID';
  current_approval_level: number;
  created_at: string;
}

export interface DPRReport {
  id: string;
  project_id: string;
  report_date: string;
  weather_condition: string;
  site_status_summary: string;
  prepared_by: string;
  site_photo_urls: string[];
  manpower: Array<{ trade_name: string; count: number }>;
  materials: Array<{ material_name: string; consumed_qty: number; unit: string }>;
  created_at: string;
}

export interface ChatMessage {
  id: string;
  channel_id: string;
  sender_id: string;
  sender_name: string;
  message_text?: string;
  media_url?: string;
  media_type: 'TEXT' | 'IMAGE' | 'VOICE_NOTE' | 'DOCUMENT';
  created_at: string;
}

// Memory Database Initial State
const DEFAULT_COMPANY_ID = 'c1111111-1111-1111-1111-111111111111';
const DEFAULT_PROJECT_ID = 'p1111111-1111-1111-1111-111111111111';
const DEFAULT_USER_ID = 'u1111111-1111-1111-1111-111111111111';

export class InMemoryStore {
  companies: Company[] = [
    {
      id: DEFAULT_COMPANY_ID,
      name: 'Apex Infra Construction Ltd',
      country_code: 'IN',
      currency: 'INR',
      currency_symbol: '₹',
      created_at: new Date().toISOString(),
    },
  ];

  users: User[] = [
    {
      id: DEFAULT_USER_ID,
      company_id: DEFAULT_COMPANY_ID,
      phone_number: '+919876543210',
      full_name: 'Rajesh Kumar (Site Lead)',
      role: 'PROJECT_MANAGER',
      daily_wage: 1500,
      monthly_fixed_salary: 45000,
      is_active: true,
      created_at: new Date().toISOString(),
    },
    {
      id: 'u2222222-2222-2222-2222-222222222222',
      company_id: DEFAULT_COMPANY_ID,
      phone_number: '+919876543211',
      full_name: 'Suresh Sharma (Foreman)',
      role: 'FOREMAN',
      trade_type: 'MASON',
      daily_wage: 900,
      monthly_fixed_salary: 27000,
      is_active: true,
      created_at: new Date().toISOString(),
    },
    {
      id: 'u3333333-3333-3333-3333-333333333333',
      company_id: DEFAULT_COMPANY_ID,
      phone_number: '+919876543212',
      full_name: 'Ramesh Patel (Mason)',
      role: 'WORKER',
      trade_type: 'MASON',
      daily_wage: 750,
      monthly_fixed_salary: 0,
      is_active: true,
      created_at: new Date().toISOString(),
    },
  ];

  projects: Project[] = [
    {
      id: DEFAULT_PROJECT_ID,
      company_id: DEFAULT_COMPANY_ID,
      name: 'Metro Tower Site 04',
      code: 'MTR-04',
      latitude: 19.076,
      longitude: 72.8777,
      geofence_radius_meters: 200,
      status: 'ACTIVE',
    },
    {
      id: 'p2222222-2222-2222-2222-222222222222',
      company_id: DEFAULT_COMPANY_ID,
      name: 'Skyline Highway Phase 2',
      code: 'HWY-02',
      latitude: 19.088,
      longitude: 72.89,
      geofence_radius_meters: 300,
      status: 'ACTIVE',
    },
  ];

  attendance: Attendance[] = [];
  
  materials: Material[] = [
    {
      id: 'm1111111-1111-1111-1111-111111111111',
      company_id: DEFAULT_COMPANY_ID,
      name: 'UltraTech OPC 53 Grade Cement',
      category: 'CEMENT',
      unit: 'BAGS',
      hsn_code: '2523',
      min_stock_alert_threshold: 50,
    },
    {
      id: 'm2222222-2222-2222-2222-222222222222',
      company_id: DEFAULT_COMPANY_ID,
      name: 'TMT TATA Tiscon Fe 550D Steel 12mm',
      category: 'STEEL',
      unit: 'TON',
      hsn_code: '7214',
      min_stock_alert_threshold: 5,
    },
  ];

  stocks: MaterialStock[] = [
    {
      id: uuidv4(),
      project_id: DEFAULT_PROJECT_ID,
      material_id: 'm1111111-1111-1111-1111-111111111111',
      current_quantity: 450,
      last_updated_at: new Date().toISOString(),
    },
    {
      id: uuidv4(),
      project_id: DEFAULT_PROJECT_ID,
      material_id: 'm2222222-2222-2222-2222-222222222222',
      current_quantity: 18.5,
      last_updated_at: new Date().toISOString(),
    },
  ];

  paymentRequests: PaymentRequest[] = [
    {
      id: 'pr111111-1111-1111-1111-111111111111',
      project_id: DEFAULT_PROJECT_ID,
      requested_by: DEFAULT_USER_ID,
      amount: 45000,
      category: 'MATERIAL',
      payee_name: 'Shree Ram Building Suppliers',
      description: 'Advance payment for 100 bags cement delivery',
      approval_status: 'PENDING',
      current_approval_level: 1,
      created_at: new Date().toISOString(),
    },
  ];

  dprReports: DPRReport[] = [];
  chatMessages: ChatMessage[] = [
    {
      id: uuidv4(),
      channel_id: DEFAULT_PROJECT_ID,
      sender_id: DEFAULT_USER_ID,
      sender_name: 'Rajesh Kumar',
      message_text: 'Welcome to Metro Tower Site 04 communication channel. Please post daily progress updates here.',
      media_type: 'TEXT',
      created_at: new Date().toISOString(),
    },
  ];

  // OTP Store
  otpStore: Map<string, { otp: string; expiresAt: number }> = new Map();
  // Desktop Web QR sessions
  qrSessions: Map<string, { status: string; userId?: string; token?: string }> = new Map();
}

export const db = new InMemoryStore();
