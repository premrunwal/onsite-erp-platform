import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class DPREntryScreen extends StatefulWidget {
  const DPREntryScreen({super.key});

  @override
  State<DPREntryScreen> createState() => _DPREntryScreenState();
}

class _DPREntryScreenState extends State<DPREntryScreen> {
  String _selectedWeather = 'CLEAR';
  final TextEditingController _summaryController = TextEditingController(
    text: 'Completed 5th floor slab casting. Electrician conduits placed. 36 workers active on site.',
  );

  bool _isSubmitting = false;

  void _submitDPR() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await ApiClient().post('/add/daily-progress-report', data: {
        'project_id': 'p1111111-1111-1111-1111-111111111111',
        'weather_condition': _selectedWeather,
        'site_status_summary': _summaryController.text,
        'prepared_by': 'u1111111-1111-1111-1111-111111111111',
        'manpower': [
          {'trade_name': 'MASON', 'count': 12},
          {'trade_name': 'CARPENTER', 'count': 6},
          {'trade_name': 'HELPER', 'count': 18},
        ],
        'materials': [
          {'material_name': 'Cement', 'consumed_qty': 40, 'unit': 'BAGS'},
          {'material_name': 'Steel 12mm', 'consumed_qty': 1.5, 'unit': 'TON'},
        ],
      });

      if (mounted) {
        setState(() => _isSubmitting = false);
        final dprId = response.data['dpr']['id'];
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('DPR Submitted Successfully'),
            content: Text('Report registered with ID: $dprId.\nBranded PDF ready for export.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('DONE'),
              ),
            ],
          ),
        );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Progress Report (DPR)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather Picker Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Site Weather Condition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedWeather,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'CLEAR', child: Text('☀️ Clear / Sunny')),
                        DropdownMenuItem(value: 'RAINY', child: Text('🌧️ Heavy Rain (Work Suspended)')),
                        DropdownMenuItem(value: 'CLOUDY', child: Text('☁️ Overcast / Cloudy')),
                        DropdownMenuItem(value: 'EXTREME_HEAT', child: Text('🔥 Extreme Heat Alert')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedWeather = val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Site Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Work Execution Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _summaryController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Describe tasks achieved today, delay causes, site photos...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Manpower Breakdown Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Trade Manpower Present Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildTradeRow('Mason Squad', '12 Present'),
                    _buildTradeRow('Carpenter Squad', '6 Present'),
                    _buildTradeRow('Electrician Squad', '2 Present'),
                    _buildTradeRow('General Labor / Helpers', '18 Present'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitDPR,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('GENERATE & SUBMIT DPR PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeRow(String trade, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(trade, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrangeDark)),
        ],
      ),
    );
  }
}
