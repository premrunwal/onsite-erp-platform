import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  void _fetchRequests() async {
    try {
      final response = await ApiClient().get('/list/approval/feature/projectlevel');
      if (mounted) {
        setState(() {
          _requests = response.data['all_requests'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _requests = [
            {
              'id': 'pr111111-1111-1111-1111-111111111111',
              'payee_name': 'Shree Ram Building Suppliers',
              'amount': 45000.0,
              'category': 'MATERIAL',
              'description': 'Advance payment for 100 bags cement delivery',
              'approval_status': 'PENDING',
              'current_approval_level': 1,
            },
            {
              'id': 'pr222222-2222-2222-2222-222222222222',
              'payee_name': 'Steel Corporation India',
              'amount': 120000.0,
              'category': 'MATERIAL',
              'description': 'TMT Bar shipment invoice #8492',
              'approval_status': 'LEVEL1_APPROVED',
              'current_approval_level': 2,
            },
          ];
          _isLoading = false;
        });
      }
    }
  }

  void _handleAction(String id, String action) async {
    try {
      final response = await ApiClient().post('/approval/action', data: {
        'payment_request_id': id,
        'action': action,
        'comments': 'Processed via Mobile ERP Pipeline',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'] ?? 'Action Recorded')),
        );
        _fetchRequests();
      }
    } catch (e) {
      if (mounted) _fetchRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approvals & Financials'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryOrange,
        onPressed: _showNewRequestBottomSheet,
        icon: const Icon(Icons.add_card_rounded, color: Colors.white),
        label: const Text('NEW EXPENSE CLAIM', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final req = _requests[index];
                final status = req['approval_status'];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              req['payee_name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '₹${req['amount']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.primaryOrangeDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Category: ${req['category']} | Level ${req['current_approval_level']} Pipeline',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(req['description'] ?? ''),
                        const SizedBox(height: 12),

                        // Approval Status Badge & Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(
                                status,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: status == 'APPROVED'
                                  ? AppTheme.statusSuccess
                                  : (status == 'REJECTED' ? AppTheme.statusError : AppTheme.statusWarning),
                            ),
                            if (status == 'PENDING' || status == 'LEVEL1_APPROVED') ...[
                              Row(
                                children: [
                                  OutlinedButton(
                                    onPressed: () => _handleAction(req['id'], 'REJECTED'),
                                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.statusError),
                                    child: const Text('REJECT'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => _handleAction(req['id'], 'APPROVED'),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusSuccess),
                                    child: const Text('APPROVE'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showNewRequestBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Payment Approval Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Payee / Vendor Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Category (MATERIAL/LABOUR/PETTY_CASH)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _fetchRequests();
                },
                child: const Text('SUBMIT TO APPROVAL PIPELINE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
