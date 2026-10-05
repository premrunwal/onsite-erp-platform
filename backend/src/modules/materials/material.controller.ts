import { Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { db } from '../../database/db';

export class MaterialController {
  static listStock(req: Request, res: Response) {
    const { project_id } = req.query;
    const projectStocks = db.stocks.filter(
      (s) => !project_id || s.project_id === project_id
    );

    const stockDetails = projectStocks.map((stock) => {
      const material = db.materials.find((m) => m.id === stock.material_id);
      const isLowStock = stock.current_quantity <= (material?.min_stock_alert_threshold || 10);
      return {
        stock_id: stock.id,
        project_id: stock.project_id,
        material_id: stock.material_id,
        material_name: material?.name || 'Unknown Material',
        category: material?.category || 'GENERAL',
        unit: material?.unit || 'UNITS',
        current_quantity: stock.current_quantity,
        is_low_stock: isLowStock,
        min_threshold: material?.min_stock_alert_threshold || 10,
        last_updated_at: stock.last_updated_at,
      };
    });

    return res.json({
      success: true,
      stock: stockDetails,
      low_stock_alerts_count: stockDetails.filter((s) => s.is_low_stock).length,
    });
  }

  static addPurchase(req: Request, res: Response) {
    const { project_id, vendor_name, total_amount, items } = req.body;
    if (!project_id || !vendor_name || !total_amount) {
      return res.status(400).json({ success: false, message: 'project_id, vendor_name, total_amount required' });
    }

    const poNumber = `PO-${Math.floor(100000 + Math.random() * 900000)}`;
    return res.json({
      success: true,
      message: `Purchase Order ${poNumber} generated successfully`,
      po_number: poNumber,
      total_amount,
      vendor_name,
      status: 'ISSUED',
    });
  }

  static addGRN(req: Request, res: Response) {
    const { project_id, delivery_challan_no, challan_photo_url, items } = req.body;
    if (!project_id || !delivery_challan_no || !items || !Array.isArray(items)) {
      return res.status(400).json({ success: false, message: 'project_id, delivery_challan_no, items array required' });
    }

    // Increment stocks
    for (const item of items) {
      let stock = db.stocks.find(
        (s) => s.project_id === project_id && s.material_id === item.material_id
      );
      if (!stock) {
        stock = {
          id: uuidv4(),
          project_id,
          material_id: item.material_id,
          current_quantity: 0,
          last_updated_at: new Date().toISOString(),
        };
        db.stocks.push(stock);
      }
      stock.current_quantity += Number(item.quantity);
      stock.last_updated_at = new Date().toISOString();
    }

    const grnNo = `GRN-${Math.floor(100000 + Math.random() * 900000)}`;
    return res.json({
      success: true,
      message: `GRN ${grnNo} processed. Materials stock updated.`,
      grn_number: grnNo,
      updated_items_count: items.length,
    });
  }

  static transferOut(req: Request, res: Response) {
    const { source_project_id, destination_project_id, material_id, quantity, vehicle_number } = req.body;
    if (!source_project_id || !destination_project_id || !material_id || !quantity) {
      return res.status(400).json({ success: false, message: 'source_project_id, destination_project_id, material_id, quantity required' });
    }

    // Deduct stock from source
    const sourceStock = db.stocks.find(
      (s) => s.project_id === source_project_id && s.material_id === material_id
    );
    if (!sourceStock || sourceStock.current_quantity < quantity) {
      return res.status(422).json({ success: false, message: 'Insufficient stock at source site for transfer out' });
    }

    sourceStock.current_quantity -= Number(quantity);
    const transferId = uuidv4();

    return res.json({
      success: true,
      message: 'Material Transfer Out initiated. Stock deducted from source site.',
      transfer_id: transferId,
      status: 'IN_TRANSIT',
    });
  }

  static transferIn(req: Request, res: Response) {
    const { transfer_id, destination_project_id, material_id, quantity } = req.body;
    if (!destination_project_id || !material_id || !quantity) {
      return res.status(400).json({ success: false, message: 'destination_project_id, material_id, quantity required' });
    }

    let destStock = db.stocks.find(
      (s) => s.project_id === destination_project_id && s.material_id === material_id
    );
    if (!destStock) {
      destStock = {
        id: uuidv4(),
        project_id: destination_project_id,
        material_id,
        current_quantity: 0,
        last_updated_at: new Date().toISOString(),
      };
      db.stocks.push(destStock);
    }

    destStock.current_quantity += Number(quantity);

    return res.json({
      success: true,
      message: 'Material Transfer In acknowledged. Stock added to destination site.',
      transfer_id,
      status: 'RECEIVED',
    });
  }

  static logConsumption(req: Request, res: Response) {
    const { project_id, items } = req.body;
    if (!project_id || !items || !Array.isArray(items)) {
      return res.status(400).json({ success: false, message: 'project_id and items array required' });
    }

    for (const item of items) {
      const stock = db.stocks.find(
        (s) => s.project_id === project_id && s.material_id === item.material_id
      );
      if (stock) {
        stock.current_quantity = Math.max(0, stock.current_quantity - Number(item.quantity));
        stock.last_updated_at = new Date().toISOString();
      }
    }

    return res.json({
      success: true,
      message: `Daily material consumption logged for ${items.length} materials.`,
    });
  }
}
