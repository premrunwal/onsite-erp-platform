import { Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { db, PaymentRequest } from '../../database/db';

export class FinancialController {
  static createPaymentRequest(req: Request, res: Response) {
    const {
      project_id,
      requested_by,
      amount,
      category,
      payee_name,
      description,
      bill_attachment_url,
    } = req.body;

    if (!project_id || !requested_by || !amount || !category || !payee_name) {
      return res.status(400).json({
        success: false,
        message: 'project_id, requested_by, amount, category, payee_name are required',
      });
    }

    const pr: PaymentRequest = {
      id: uuidv4(),
      project_id,
      requested_by,
      amount: Number(amount),
      category,
      payee_name,
      description: description || '',
      bill_attachment_url: bill_attachment_url || '',
      approval_status: 'PENDING',
      current_approval_level: 1,
      created_at: new Date().toISOString(),
    };

    db.paymentRequests.push(pr);

    return res.json({
      success: true,
      message: 'Payment request created and submitted into Level 1 approval queue',
      payment_request: pr,
    });
  }

  static handleApprovalAction(req: Request, res: Response) {
    const { payment_request_id, action, comments } = req.body; // action: 'APPROVED' | 'REJECTED'
    if (!payment_request_id || !action) {
      return res.status(400).json({ success: false, message: 'payment_request_id and action required' });
    }

    const pr = db.paymentRequests.find((p) => p.id === payment_request_id);
    if (!pr) {
      return res.status(404).json({ success: false, message: 'Payment request not found' });
    }

    if (action === 'REJECTED') {
      pr.approval_status = 'REJECTED';
    } else if (action === 'APPROVED') {
      if (pr.current_approval_level === 1) {
        pr.current_approval_level = 2;
        pr.approval_status = 'LEVEL1_APPROVED';
      } else {
        pr.approval_status = 'APPROVED';
      }
    }

    return res.json({
      success: true,
      message: `Payment request marked as ${pr.approval_status}`,
      payment_request: pr,
    });
  }

  static getApprovalsQueue(req: Request, res: Response) {
    const { project_id } = req.query;
    const queue = db.paymentRequests.filter(
      (p) => !project_id || p.project_id === project_id
    );

    return res.json({
      success: true,
      pending_requests: queue.filter((p) => p.approval_status === 'PENDING' || p.approval_status === 'LEVEL1_APPROVED'),
      all_requests: queue,
    });
  }
}
