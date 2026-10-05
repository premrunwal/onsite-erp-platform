import { Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { db, Attendance, RealDataService } from '../../database/db';
import { isWithinGeofence } from '../../common/geofence';
import { evaluateLivenessChallenges, LivenessChallengeProof } from '../../common/liveness';
import { generateWatermarkStampText } from '../../common/watermark';

export class AttendanceController {
  static punchIn(req: Request, res: Response) {
    const {
      user_id,
      project_id,
      latitude,
      longitude,
      photo_url,
      liveness_proofs,
      verification_type = 'FACE_LIVENESS',
    } = req.body;

    if (!user_id || !project_id || latitude === undefined || longitude === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Missing required parameters: user_id, project_id, latitude, longitude',
      });
    }

    const project = db.projects.find((p) => p.id === project_id);
    if (!project) {
      return res.status(404).json({ success: false, message: 'Project site not found' });
    }

    // 1. Geofence Validation
    const geofenceCheck = isWithinGeofence(
      latitude,
      longitude,
      project.latitude,
      project.longitude,
      project.geofence_radius_meters
    );

    if (!geofenceCheck.isValid) {
      return res.status(422).json({
        success: false,
        message: `Punch rejected: Device location is ${geofenceCheck.distanceMeters}m away from site. Maximum allowed threshold is ${project.geofence_radius_meters}m.`,
        distance_meters: geofenceCheck.distanceMeters,
      });
    }

    // 2. Interactive Anti-Spoofing Liveness Check
    if (verification_type === 'FACE_LIVENESS' && liveness_proofs) {
      const livenessResult = evaluateLivenessChallenges(liveness_proofs as LivenessChallengeProof[]);
      if (!livenessResult.passed) {
        return res.status(422).json({
          success: false,
          message: `Biometric Punch Rejected: Anti-spoofing liveness failed. ${livenessResult.details}`,
        });
      }
    }

    // 3. Generate Photo Watermark Metadata
    const watermarkText = generateWatermarkStampText({
      projectCode: project.code,
      siteName: project.name,
      latitude,
      longitude,
      timestampUtc: new Date().toISOString(),
      verificationTag: 'VERIFIED PUNCH',
    });

    const punchRecord: Attendance = {
      id: uuidv4(),
      user_id,
      project_id,
      punch_in_time: new Date().toISOString(),
      punch_in_lat: latitude,
      punch_in_lng: longitude,
      punch_in_photo_url: photo_url || 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
      verification_type,
      is_geofence_valid: true,
      distance_from_center_meters: geofenceCheck.distanceMeters,
      status: 'PRESENT',
      overtime_hours: 0,
    };

    // Persist directly to Supabase PostgreSQL
    RealDataService.savePunchIn(punchRecord);

    return res.json({
      success: true,
      message: 'Punch In Recorded Successfully',
      attendance: punchRecord,
      watermark_stamp: watermarkText,
    });
  }

  static punchOut(req: Request, res: Response) {
    const { attendance_id, overtime_hours = 0 } = req.body;

    const record = db.attendance.find((a) => a.id === attendance_id);
    if (!record) {
      return res.status(404).json({ success: false, message: 'Attendance record not found' });
    }

    record.punch_out_time = new Date().toISOString();
    record.overtime_hours = Number(overtime_hours);
    if (overtime_hours > 0) {
      record.status = 'OVERTIME';
    }

    return res.json({
      success: true,
      message: 'Punch Out Recorded Successfully',
      attendance: record,
    });
  }

  static bulkPunch(req: Request, res: Response) {
    const { project_id, foreman_id, worker_ids, status = 'PRESENT' } = req.body;
    if (!project_id || !worker_ids || !Array.isArray(worker_ids)) {
      return res.status(400).json({ success: false, message: 'project_id and array of worker_ids required' });
    }

    const createdRecords: Attendance[] = [];
    const now = new Date().toISOString();

    for (const wId of worker_ids) {
      const rec: Attendance = {
        id: uuidv4(),
        user_id: wId,
        project_id,
        punch_in_time: now,
        punch_in_lat: 19.076,
        punch_in_lng: 72.8777,
        punch_in_photo_url: '',
        verification_type: 'BULK_FOREMAN',
        is_geofence_valid: true,
        distance_from_center_meters: 10,
        status,
        overtime_hours: 0,
      };
      db.attendance.push(rec);
      createdRecords.push(rec);
    }

    return res.json({
      success: true,
      message: `Bulk punch completed for ${worker_ids.length} workers`,
      records_count: createdRecords.length,
    });
  }

  static enrollFaceEmbedding(req: Request, res: Response) {
    const { user_id, embedding_vector, sample_photo_url } = req.body;
    if (!user_id || !embedding_vector || !Array.isArray(embedding_vector)) {
      return res.status(400).json({ success: false, message: 'user_id and embedding_vector array required' });
    }

    const user = db.users.find((u) => u.id === user_id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.face_embedding = embedding_vector;
    user.avatar_url = sample_photo_url;

    return res.json({
      success: true,
      message: `Face biometrics enrolled successfully for user ${user.full_name}`,
      vector_dimension: embedding_vector.length,
    });
  }

  static getPayrollReport(req: Request, res: Response) {
    const { project_id } = req.query;

    const payrollList = db.users.map((user) => {
      const userPunches = db.attendance.filter((a) => a.user_id === user.id);
      const presentDays = userPunches.filter((a) => a.status === 'PRESENT' || a.status === 'OVERTIME').length;
      const totalOvertime = userPunches.reduce((acc, curr) => acc + curr.overtime_hours, 0);

      const baseEarned = user.salary_model === 'MONTHLY_FIXED'
        ? (user.monthly_fixed_salary / 30) * presentDays
        : user.daily_wage * presentDays;
      const overtimeEarned = totalOvertime * (user.daily_wage / 8) * 1.5;
      const grossSalary = baseEarned + overtimeEarned;

      return {
        user_id: user.id,
        full_name: user.full_name,
        role: user.role,
        trade_type: user.trade_type || 'GENERAL',
        present_days: presentDays,
        overtime_hours: totalOvertime,
        daily_rate: user.daily_wage,
        gross_salary: Math.round(grossSalary * 100) / 100,
      };
    });

    return res.json({
      success: true,
      payroll_summary: payrollList,
      total_disbursement: payrollList.reduce((acc, curr) => acc + curr.gross_salary, 0),
    });
  }
}
