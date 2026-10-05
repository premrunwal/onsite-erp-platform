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
app.use(express.json({ limit: '10mb' }));

// Request Logging Middleware
app.use((req, res, next) => {
  console.log(`[HTTP API] ${req.method} ${req.url}`);
  next();
});

// Health Check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', system: 'Onsite ERP Backend API', timestamp: new Date().toISOString() });
});

// Auth & Setup Routes
app.post('/apis/v3/auth/send-otp', AuthController.sendOtp);
app.post('/apis/v3/auth/verify-otp', AuthController.verifyOtp);
app.post('/apis/v3/scan/login/qr', AuthController.qrLoginScan);
app.get('/apis/v3/country-configuration', AuthController.getCountryConfig);

// Attendance & Face AI Routes
app.post('/apis/v3/add/punch_in', AttendanceController.punchIn);
app.post('/apis/v3/add/punch_out', AttendanceController.punchOut);
app.post('/apis/v3/bulk/punch_in_out', AttendanceController.bulkPunch);
app.post('/apis/v3/add/companyuserfaceinfo', AttendanceController.enrollFaceEmbedding);
app.get('/apis/v3/list/attendance/payroll', AttendanceController.getPayrollReport);

// Project & DPR Routes
app.get('/apis/v3/list/all/project', ProjectController.listProjects);
app.post('/apis/v3/add/daily-progress-report', ProjectController.addDPR);
app.get('/apis/v3/get/dpr-pdf/:id', ProjectController.getDPRPdf);

// Materials & Inventory Routes
app.get('/apis/v3/list/material/stock', MaterialController.listStock);
app.post('/apis/v3/add/materialpurchase', MaterialController.addPurchase);
app.post('/apis/v3/bulk/add/material/grn', MaterialController.addGRN);
app.post('/apis/v3/add/material-transfer/out', MaterialController.transferOut);
app.post('/apis/v3/add/material-transfer/in', MaterialController.transferIn);
app.post('/apis/v3/bulk/add/material-used', MaterialController.logConsumption);

// Financials & Approvals Pipeline Routes
app.post('/apis/v3/add/payment-request', FinancialController.createPaymentRequest);
app.post('/apis/v3/approval/action', FinancialController.handleApprovalAction);
app.get('/apis/v3/list/approval/feature/projectlevel', FinancialController.getApprovalsQueue);

// Initialize Realtime Socket.IO Gateway
setupSocketIO(io);

// Start Server if run directly
if (require.main === module) {
  server.listen(CONFIG.PORT, () => {
    console.log(`=======================================================`);
    console.log(`  ONSITE CLONE ERP BACKEND API RUNNING ON PORT ${CONFIG.PORT}`);
    console.log(`  REST API Gateway: http://localhost:${CONFIG.PORT}/apis/v3/`);
    console.log(`  WebSocket Server: ws://localhost:${CONFIG.PORT}`);
    console.log(`=======================================================`);
  });
}

export { app, server };
