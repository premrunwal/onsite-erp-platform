import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class ForemanBulkPunchScreen extends StatefulWidget {
  const ForemanBulkPunchScreen({super.key});

  @override
  State<ForemanBulkPunchScreen> createState() => _ForemanBulkPunchScreenState();
}

class _ForemanBulkPunchScreenState extends State<ForemanBulkPunchScreen> {
  final List<Map<String, dynamic>> _workers = [
    {'id': 'u3333333-3333-3333-3333-333333333333', 'name': 'Ramesh Patel', 'trade': 'MASON', 'selected': true},
    {'id': 'u4444444-4444-4444-4444-444444444444', 'name': 'Mohan Das', 'trade': 'CARPENTER', 'selected': true},
    {'id': 'u5555555-5555-5555-5555-555555555555', 'name': 'Vikram Singh', 'trade': 'ELECTRICIAN', 'selected': true},
    {'id': 'u6666666-6666-6666-6666-666666666666', 'name': 'Ganesh Ghale', 'trade': 'HELPER', 'selected': true},
    {'id': 'u7777777-7777-7777-7777-777777777777', 'name': 'Sunil Yadav', 'trade': 'HELPER', 'selected': false},
  ];

  bool _isSubmitting = false;

  void _submitBulkPunch() async {
    final selectedIds = _workers.where((w) => w['selected'] == true).map((w) => w['id'] as String).toList();
    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one worker')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await ApiClient().post('/bulk/punch_in_out', data: {
        'project_id': 'p1111111-1111-1111-1111-111111111111',
        'foreman_id': 'u2222222-2222-2222-2222-222222222222',
        'worker_ids': selectedIds,
        'status': 'PRESENT',
      });

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Bulk Punch Completed!'),
            backgroundColor: AppTheme.statusSuccess,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _workers.where((w) => w['selected'] == true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foreman Bulk Squad Punch'),
      ),
      body: Column(
        children: [
          // Header summary badge
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.slateNavyLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Squad Roster', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    Text('${_workers.length} Workers Enrolled', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.statusSuccess,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$presentCount Selected Present',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Worker list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _workers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final worker = _workers[index];
                return CheckboxListTile(
                  activeColor: AppTheme.primaryOrange,
                  value: worker['selected'],
                  title: Text(worker['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Trade: ${worker['trade']}'),
                  secondary: CircleAvatar(
                    backgroundColor: AppTheme.primaryOrange.withOpacity(0.15),
                    child: Text(worker['name'][0], style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
                  ),
                  onChanged: (val) {
                    setState(() {
                      worker['selected'] = val;
                    });
                  },
                );
              },
            ),
          ),

          // Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBulkPunch,
                child: Text('SUBMIT BULK PUNCH ($presentCount WORKERS)'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
