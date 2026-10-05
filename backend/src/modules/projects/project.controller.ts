import { Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { db, DPRReport } from '../../database/db';

export class ProjectController {
  static listProjects(req: Request, res: Response) {
    return res.json({
      success: true,
      projects: db.projects,
    });
  }

  static addDPR(req: Request, res: Response) {
    const {
      project_id,
      weather_condition = 'CLEAR',
      site_status_summary,
      prepared_by,
      manpower,
      materials,
      site_photo_urls = [],
    } = req.body;

    if (!project_id || !site_status_summary || !prepared_by) {
      return res.status(400).json({
        success: false,
        message: 'Missing required parameters: project_id, site_status_summary, prepared_by',
      });
    }

    const dpr: DPRReport = {
      id: uuidv4(),
      project_id,
      report_date: new Date().toISOString().split('T')[0],
      weather_condition,
      site_status_summary,
      prepared_by,
      site_photo_urls,
      manpower: manpower || [
        { trade_name: 'MASON', count: 12 },
        { trade_name: 'CARPENTER', count: 6 },
        { trade_name: 'HELPER', count: 18 },
      ],
      materials: materials || [
        { material_name: 'Cement', consumed_qty: 40, unit: 'BAGS' },
        { material_name: 'Steel 12mm', consumed_qty: 1.5, unit: 'TON' },
      ],
      created_at: new Date().toISOString(),
    };

    db.dprReports.push(dpr);

    return res.json({
      success: true,
      message: 'Daily Progress Report (DPR) submitted successfully',
      dpr,
    });
  }

  static getDPRPdf(req: Request, res: Response) {
    const { id } = req.params;
    const dpr = db.dprReports.find((d) => d.id === id) || db.dprReports[0];

    const project = db.projects.find((p) => p.id === dpr?.project_id) || db.projects[0];
    const author = db.users.find((u) => u.id === dpr?.prepared_by) || db.users[0];

    return res.json({
      success: true,
      dpr_id: dpr?.id || id,
      pdf_title: `DAILY_PROGRESS_REPORT_${project.code}_${dpr?.report_date || '2026-10-05'}.pdf`,
      download_url: `https://onsite-erp.storage.s3.amazonaws.com/dpr-reports/DPR_${id}.pdf`,
      metadata: {
        company: db.companies[0].name,
        project_name: project.name,
        prepared_by: author.full_name,
        total_manpower: dpr?.manpower.reduce((acc, curr) => acc + curr.count, 0) || 36,
        weather: dpr?.weather_condition || 'CLEAR',
        generated_at: new Date().toISOString(),
      },
    });
  }
}
