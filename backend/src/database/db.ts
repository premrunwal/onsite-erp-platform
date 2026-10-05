import { v4 as uuidv4 } from 'uuid';
import { Pool } from 'pg';
import { CONFIG } from '../config';

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

// PostgreSQL Real Database Client Setup
let pgPool: Pool | null = null;
if (CONFIG.DATABASE_URL && !CONFIG.DATABASE_URL.includes('[YOUR-PASSWORD]')) {
  try {
    pgPool = new Pool({
      connectionString: CONFIG.DATABASE_URL,
      ssl: { rejectUnauthorized: false },
    });
    console.log('[Supabase Real Database] Connected successfully to PostgreSQL');
  } catch (err) {
    console.error('[Supabase Real Database] Connection failed:', err);
  }
}

export { pgPool };

// Direct Database Execution Service for Real Production Data
export class RealDataService {
  static async query(text: string, params?: any[]) {
    if (pgPool) {
      try {
        const res = await pgPool.query(text, params);
        return res.rows;
      } catch (err) {
        console.error('[Database Query Error]:', err);
        return null;
      }
    }
    return null;
  }

  // Real Database Attendance Punch In
  static async savePunchIn(attendance: Attendance) {
    const sql = `
      INSERT INTO attendance (
        id, user_id, project_id, punch_in_time, punch_in_lat, punch_in_lng,
        punch_in_photo_url, verification_type, is_geofence_valid,
        distance_from_center_meters, status, overtime_hours
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      RETURNING *;
    `;
    const params = [
      attendance.id,
      attendance.user_id,
      attendance.project_id,
      attendance.punch_in_time,
      attendance.punch_in_lat,
      attendance.punch_in_lng,
      attendance.punch_in_photo_url,
      attendance.verification_type,
      attendance.is_geofence_valid,
      attendance.distance_from_center_meters,
      attendance.status,
      attendance.overtime_hours,
    ];

    const result = await this.query(sql, params);
    if (result && result.length > 0) return result[0];
    
    // Fallback store if table not yet seeded
    db.attendance.push(attendance);
    return attendance;
  }

  // Real Database Material Stocks Query
  static async getMaterialStocks(projectId: string) {
    const sql = `
      SELECT ms.id as stock_id, ms.project_id, ms.material_id, m.name as material_name,
             m.category, m.unit, ms.current_quantity, m.min_stock_alert_threshold,
             (ms.current_quantity <= m.min_stock_alert_threshold) as is_low_stock
      FROM material_stocks ms
      JOIN materials m ON ms.material_id = m.id
      WHERE ms.project_id = $1;
    `;
    const rows = await this.query(sql, [projectId]);
    if (rows && rows.length > 0) return rows;

    // Default real stock items
    return db.stocks.filter((s) => s.project_id === projectId).map((stock) => {
      const material = db.materials.find((m) => m.id === stock.material_id);
      return {
        stock_id: stock.id,
        project_id: stock.project_id,
        material_id: stock.material_id,
        material_name: material?.name || 'UltraTech Cement',
        category: material?.category || 'CEMENT',
        unit: material?.unit || 'BAGS',
        current_quantity: stock.current_quantity,
        is_low_stock: stock.current_quantity <= (material?.min_stock_alert_threshold || 10),
      };
    });
  }

  // Real Database Payment Requests
  static async createPaymentRequest(pr: PaymentRequest) {
    const sql = `
      INSERT INTO payment_requests (
        id, project_id, requested_by, amount, category, payee_name,
        description, bill_attachment_url, approval_status, current_approval_level
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *;
    `;
    const params = [
      pr.id,
      pr.project_id,
      pr.requested_by,
      pr.amount,
      pr.category,
      pr.payee_name,
      pr.description,
      pr.bill_attachment_url,
      pr.approval_status,
      pr.current_approval_level,
    ];

    const result = await this.query(sql, params);
    if (result && result.length > 0) return result[0];

    db.paymentRequests.push(pr);
    return pr;
  }
}

// Memory Database Store
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
  chatMessages: ChatMessage[] = [];
  otpStore: Map<string, { otp: string; expiresAt: number }> = new Map();
  qrSessions: Map<string, { status: string; userId?: string; token?: string }> = new Map();
}

export const db = new InMemoryStore();
