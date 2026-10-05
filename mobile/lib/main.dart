import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/local_storage_service.dart';
import 'features/auth/presentation/phone_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive Storage Boxes
  try {
    await LocalStorageService().init();
  } catch (e) {
    print('Storage init skipped in non-flutter driver environment');
  }

  runApp(const OnsiteErpApp());
}

class OnsiteErpApp extends StatelessWidget {
  const OnsiteErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onsite ERP Construction & Workforce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const PhoneLoginScreen(),
    );
  }
}
