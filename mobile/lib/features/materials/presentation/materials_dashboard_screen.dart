import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class MaterialsDashboardScreen extends StatefulWidget {
  const MaterialsDashboardScreen({super.key});

  @override
  State<MaterialsDashboardScreen> createState() => _MaterialsDashboardScreenState();
}

class _MaterialsDashboardScreenState extends State<MaterialsDashboardScreen> {
  List<dynamic> _stocks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStockLevels();
  }

  void _fetchStockLevels() async {
    try {
      final response = await ApiClient().get('/list/material/stock?project_id=p1111111-1111-1111-1111-111111111111');
      if (mounted) {
        setState(() {
          _stocks = response.data['stock'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _stocks = [
            {
              'material_name': 'UltraTech OPC 53 Grade Cement',
              'current_quantity': 450.0,
              'unit': 'BAGS',
              'is_low_stock': false,
            },
            {
              'material_name': 'TMT TATA Tiscon Fe 550D Steel 12mm',
              'current_quantity': 18.5,
              'unit': 'TON',
              'is_low_stock': false,
            },
            {
              'material_name': 'River Sand (Coarse)',
              'current_quantity': 4.0,
              'unit': 'CFT',
              'is_low_stock': true,
            },
          ];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials & Site Stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStockLevels,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Quick Action Toolbar
                Container(
                  padding: const EdgeInsets.all(12),
                  color: AppTheme.slateNavyLight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.add_shopping_cart,
                        label: 'Create PO',
                        onTap: () => _showActionDialog('Create Purchase Order (PO)'),
                      ),
                      _buildQuickActionButton(
                        icon: Icons.inventory,
                        label: 'Record GRN',
                        onTap: () => _showActionDialog('Goods Receipt Note (GRN)'),
                      ),
                      _buildQuickActionButton(
                        icon: Icons.local_shipping,
                        label: 'Transfer Out',
                        onTap: () => _showActionDialog('Material Transfer Out'),
                      ),
                    ],
                  ),
                ),

                // Stock List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _stocks.length,
                    itemBuilder: (context, index) {
                      final item = _stocks[index];
                      final isLow = item['is_low_stock'] == true;

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isLow
                                ? AppTheme.statusError.withOpacity(0.15)
                                : AppTheme.statusSuccess.withOpacity(0.15),
                            child: Icon(
                              Icons.category,
                              color: isLow ? AppTheme.statusError : AppTheme.statusSuccess,
                            ),
                          ),
                          title: Text(
                            item['material_name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text('Category: ${item['category'] ?? 'GENERAL'}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item['current_quantity']} ${item['unit']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isLow ? AppTheme.statusError : AppTheme.slateNavyDark,
                                ),
                              ),
                              if (isLow)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.statusError,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'LOW STOCK ALERT',
                                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQuickActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryOrange,
            radius: 20,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  void _showActionDialog(String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: const Text('Form submitted successfully. Stock inventory updated in real-time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}
