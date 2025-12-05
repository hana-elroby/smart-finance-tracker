import 'package:flutter/material.dart';
import 'features/database_test/database_test_page.dart';
import 'core/services/sync_service.dart';

void main() async {
  // ضروري نستدعي ده الأول قبل أي حاجة
  WidgetsFlutterBinding.ensureInitialized();
  
  // ابدأ الـ Sync Service
  try {
    final syncService = SyncService();
    syncService.startListening();
    print('✅ Sync service started!');
    
    // فحص النت وعمل sync أولي
    bool hasNet = await syncService.hasInternet();
    if (hasNet) {
      print('📶 Internet available - Starting initial sync...');
      syncService.syncExpenses();
    } else {
      print('📵 No internet - Will sync when available');
    }
  } catch (e) {
    print('⚠️ Sync service error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      home: const DatabaseTestPage(),
    );
  }
}
