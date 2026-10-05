import express from 'express';
import http from 'http';
import cors from 'cors';
import { Server as SocketIOServer } from 'socket.io';
import { CONFIG } from './config';
import { AuthController } from './modules/auth/auth.controller';
import { AttendanceController } from './modules/attendance/attendance.controller';
import { ProjectController } from './modules/projects/project.controller';
import { MaterialController } from './modules/materials/material.controller';
import { FinancialController } from './modules/financials/financial.controller';
import { setupSocketIO } from './modules/chat/chat.gateway';

const app = express();
const server = http.createServer(app);
const io = new SocketIOServer(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

app.use(cors());
app.use(express.json({ limit: '50mb' }));

// Request Logging Middleware
app.use((req, res, next) => {
  console.log(`[HTTP API Gateway] ${req.method} ${req.url}`);
  next();
});

// Health Check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    system: 'Onsite Clone Production ERP Gateway',
    database: 'Supabase PostgreSQL 16 + PostGIS',
    storage: 'Cloudinary Media Engine',
    timestamp: new Date().toISOString(),
  });
});

// Helper router to bind endpoints to both /apis/v3/ and root /
const bindRoute = (path: string, handler: express.RequestHandler, method: 'get' | 'post' = 'post') => {
  if (method === 'get') {
    app.get(path, handler);
    app.get(`/apis/v3${path}`, handler);
  } else {
    app.post(path, handler);
    app.post(`/apis/v3${path}`, handler);
  }
};

// 1. Auth & Onboarding Routes
bindRoute('/auth/send-otp', AuthController.sendOtp);
bindRoute('/auth/verify-otp', AuthController.verifyOtp);
bindRoute('/scan/login/qr', AuthController.qrLoginScan);
bindRoute('/country-configuration', AuthController.getCountryConfig, 'get');

// 2. Attendance & AI Facial Biometrics Routes
bindRoute('/add/punch_in', AttendanceController.punchIn);
bindRoute('/add/punch_out', AttendanceController.punchOut);
bindRoute('/bulk/punch_in_out', AttendanceController.bulkPunch);
bindRoute('/add/companyuserfaceinfo', AttendanceController.enrollFaceEmbedding);
bindRoute('/list/attendance/payroll', AttendanceController.getPayrollReport, 'get');

// 3. Project & DPR Routes
bindRoute('/list/all/project', ProjectController.listProjects, 'get');
bindRoute('/add/daily-progress-report', ProjectController.addDPR);
app.get('/get/dpr-pdf/:id', ProjectController.getDPRPdf);
app.get('/apis/v3/get/dpr-pdf/:id', ProjectController.getDPRPdf);

// 4. Materials & Inventory Routes
bindRoute('/list/material/stock', MaterialController.listStock, 'get');
bindRoute('/add/materialpurchase', MaterialController.addPurchase);
bindRoute('/bulk/add/material/grn', MaterialController.addGRN);
bindRoute('/add/material-transfer/out', MaterialController.transferOut);
bindRoute('/add/material-transfer/in', MaterialController.transferIn);
bindRoute('/bulk/add/material-used', MaterialController.logConsumption);

// 5. Financials & Approvals Pipeline Routes
bindRoute('/add/payment-request', FinancialController.createPaymentRequest);
bindRoute('/approval/action', FinancialController.handleApprovalAction);
bindRoute('/list/approval/feature/projectlevel', FinancialController.getApprovalsQueue, 'get');

// Initialize Realtime Socket.IO Gateway
setupSocketIO(io);

// Start Server if run directly
if (require.main === module) {
  server.listen(CONFIG.PORT, () => {
    console.log(`=======================================================`);
    console.log(`  ONSITE CLONE PRODUCTION ERP RUNNING ON PORT ${CONFIG.PORT}`);
    console.log(`  Database: Supabase PostgreSQL 16 + PostGIS`);
    console.log(`  Storage: Cloudinary Media Engine`);
    console.log(`  REST API Gateway: http://localhost:${CONFIG.PORT}/apis/v3/`);
    console.log(`  WebSocket Server: ws://localhost:${CONFIG.PORT}`);
    console.log(`=======================================================`);
  });
}

export { app, server };
