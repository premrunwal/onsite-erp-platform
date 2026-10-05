import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;

  LocalStorageService._internal();

  static const String sessionBoxName = 'user_session_box';
  static const String offlinePunchBoxName = 'offline_punches_box';
  static const String stockCacheBoxName = 'stock_cache_box';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(sessionBoxName);
    await Hive.openBox(offlinePunchBoxName);
    await Hive.openBox(stockCacheBoxName);
  }

  // Auth Session Methods
  Future<void> saveAuthSession(String token, Map<String, dynamic> userData) async {
    final box = Hive.box(sessionBoxName);
    await box.put('access_token', token);
    await box.put('user_data', userData);
  }

  String? getAuthToken() {
    final box = Hive.box(sessionBoxName);
    return box.get('access_token');
  }

  Map<dynamic, dynamic>? getUserData() {
    final box = Hive.box(sessionBoxName);
    return box.get('user_data');
  }

  Future<void> clearAuthSession() async {
    final box = Hive.box(sessionBoxName);
    await box.clear();
  }

  // Offline Punch Queue Methods
  Future<void> queueOfflinePunch(Map<String, dynamic> punchData) async {
    final box = Hive.box(offlinePunchBoxName);
    await box.add(punchData);
  }

  List<Map<dynamic, dynamic>> getPendingOfflinePunches() {
    final box = Hive.box(offlinePunchBoxName);
    return box.values.cast<Map<dynamic, dynamic>>().toList();
  }

  Future<void> clearOfflinePunches() async {
    final box = Hive.box(offlinePunchBoxName);
    await box.clear();
  }
}
