import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../dashboard/presentation/home_dashboard_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '9876543210');
  final TextEditingController _otpController = TextEditingController(text: '123456');

  String _selectedPrefix = '+91';
  String _selectedCountry = 'India (₹)';
  bool _isOtpSent = false;
  bool _isLoading = false;

  final Map<String, String> _countryPrefixes = {
    'India (₹)': '+91',
    'United Arab Emirates (AED)': '+971',
    'Saudi Arabia (SAR)': '+966',
    'Nepal (NRs)': '+977',
  };

  void _sendOtp() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().post('/auth/send-otp', data: {
        'phone_number': '$_selectedPrefix${_phoneController.text}',
        'country_code': _selectedPrefix,
      });

      if (mounted) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'OTP Sent! Use 123456 for testing.'),
            backgroundColor: AppTheme.statusSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Fallback for offline demo
        setState(() => _isOtpSent = true);
      }
    }
  }

  void _verifyOtp() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().post('/auth/verify-otp', data: {
        'phone_number': '$_selectedPrefix${_phoneController.text}',
        'otp': _otpController.text,
      });

      if (response.data['success'] == true) {
        final token = response.data['access_token'];
        final userData = response.data['user'];

        await LocalStorageService().saveAuthSession(token, userData);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Fallback to launch app demo
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.slateNavyDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Header
              const Icon(Icons.apartment_rounded, size: 72, color: AppTheme.primaryOrange),
              const SizedBox(height: 12),
              const Text(
                'ONSITE CLONE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const Text(
                'Construction ERP & Workforce Management',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 40),

              // Country Dropdown Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.slateNavyLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountry,
                    dropdownColor: AppTheme.slateNavyLight,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: _countryPrefixes.keys.map((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCountry = val;
                          _selectedPrefix = _countryPrefixes[val]!;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Number Input Box
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.slateNavyLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Text(
                      _selectedPrefix,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Mobile Number',
                        hintStyle: const TextStyle(color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: AppTheme.slateNavyLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF334155)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isOtpSent) ...[
                // OTP Field
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, letterSpacing: 4, fontSize: 18),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit OTP',
                    hintStyle: const TextStyle(color: Color(0xFF64748B), letterSpacing: 0, fontSize: 14),
                    filled: true,
                    fillColor: AppTheme.slateNavyLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action Button
              ElevatedButton(
                onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _sendOtp),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_isOtpSent ? 'VERIFY & SIGN IN' : 'GET SMS OTP'),
              ),
              const SizedBox(height: 24),

              // Web QR Login Trigger
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Desktop QR Camera Scanner Launching...')),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryOrange),
                label: const Text('SCAN DESKTOP WEB QR CODE', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryOrange),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
