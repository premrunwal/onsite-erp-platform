import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { db } from '../../database/db';
import { CONFIG } from '../../config';

export class AuthController {
  static sendOtp(req: Request, res: Response) {
    const { phone_number, country_code } = req.body;
    if (!phone_number) {
      return res.status(400).json({ success: false, message: 'Phone number is required' });
    }

    // Generate 6-digit OTP (for demo, fixed 123456 or random)
    const otp = '123456';
    db.otpStore.set(phone_number, {
      otp,
      expiresAt: Date.now() + 5 * 60 * 1000,
    });

    console.log(`[SMS GATEWAY] Sent OTP ${otp} to ${phone_number}`);
    return res.json({
      success: true,
      message: `OTP sent successfully to ${phone_number}`,
      debug_otp: otp,
    });
  }

  static verifyOtp(req: Request, res: Response) {
    const { phone_number, otp } = req.body;
    if (!phone_number || !otp) {
      return res.status(400).json({ success: false, message: 'Phone number and OTP are required' });
    }

    const storedData = db.otpStore.get(phone_number);
    // Allow default test OTP 123456 for convenience
    if (otp !== '123456' && (!storedData || storedData.otp !== otp || Date.now() > storedData.expiresAt)) {
      return res.status(401).json({ success: false, message: 'Invalid or expired OTP' });
    }

    // Find or create user
    let user = db.users.find((u) => u.phone_number === phone_number);
    if (!user) {
      user = {
        id: uuidv4(),
        company_id: db.companies[0].id,
        phone_number,
        full_name: 'Site Supervisor',
        role: 'SITE_ENGINEER',
        daily_wage: 1000,
        monthly_fixed_salary: 30000,
        is_active: true,
        created_at: new Date().toISOString(),
      };
      db.users.push(user);
    }

    const token = jwt.sign(
      { userId: user.id, companyId: user.company_id, role: user.role },
      CONFIG.JWT_SECRET,
      { expiresIn: CONFIG.JWT_EXPIRES_IN_SEC }
    );

    return res.json({
      success: true,
      message: 'Authentication successful',
      access_token: token,
      refresh_token: uuidv4(),
      user,
      company: db.companies[0],
    });
  }

  static qrLoginScan(req: Request, res: Response) {
    const { qr_session_id, user_id } = req.body;
    if (!qr_session_id) {
      return res.status(400).json({ success: false, message: 'QR session ID required' });
    }

    const user = db.users.find((u) => u.id === (user_id || db.users[0].id));
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const token = jwt.sign(
      { userId: user.id, companyId: user.company_id, role: user.role },
      CONFIG.JWT_SECRET,
      { expiresIn: CONFIG.JWT_EXPIRES_IN_SEC }
    );

    db.qrSessions.set(qr_session_id, {
      status: 'AUTHENTICATED',
      userId: user.id,
      token,
    });

    return res.json({
      success: true,
      message: 'Desktop session authorized successfully via QR scan',
    });
  }

  static getCountryConfig(req: Request, res: Response) {
    return res.json({
      success: true,
      countries: CONFIG.SUPPORTED_COUNTRIES,
    });
  }
}
