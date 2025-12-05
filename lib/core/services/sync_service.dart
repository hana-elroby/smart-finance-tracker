import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/database_helper.dart';
import '../models/expense_model.dart';

class SyncService {
  static final SyncService instance = SyncService._internal();
  SyncService._internal();
  factory SyncService() => instance;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  // بدء مراقبة الاتصال بالإنترنت
  void startListening() {
    try {
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          // لو النت رجع
          if (results.contains(ConnectivityResult.mobile) ||
              results.contains(ConnectivityResult.wifi)) {
            print('📶 Internet connected! Starting sync...');
            syncExpenses();
          } else {
            print('📵 No internet connection');
          }
        },
      );
    } catch (e) {
      print('⚠️ Cannot start connectivity listener: $e');
    }
  }

  // إيقاف المراقبة
  void stopListening() {
    _connectivitySubscription?.cancel();
  }

  // مزامنة المصاريف
  Future<void> syncExpenses() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress...');
      return;
    }

    _isSyncing = true;
    print('🔄 Starting sync...');

    try {
      // 1. جلب المصاريف غير المتزامنة
      List<Map<String, dynamic>> unsyncedExpensesMap =
          await _dbHelper.getUnsyncedExpenses();

      if (unsyncedExpensesMap.isEmpty) {
        print('✅ No expenses to sync');
        _isSyncing = false;
        return;
      }

      List<Expense> unsyncedExpenses =
          unsyncedExpensesMap.map((e) => Expense.fromMap(e)).toList();

      print('📤 Found ${unsyncedExpenses.length} expenses to sync');

      // 2. إرسال كل مصروف للسيرفر
      for (var expense in unsyncedExpenses) {
        bool success = await _sendToServer(expense);

        if (success) {
          // 3. تعليم المصروف كمتزامن
          await _dbHelper.markExpenseAsSynced(expense.id!);
          print('✅ Synced: ${expense.title}');
        } else {
          print('❌ Failed to sync: ${expense.title}');
        }
      }

      print('🎉 Sync completed!');
    } catch (e) {
      print('❌ Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // إرسال مصروف للسيرفر (هنا تحطي API call بتاعك)
  Future<bool> _sendToServer(Expense expense) async {
    try {
      // TODO: استبدلي ده بـ API call حقيقي
      // مثال:
      // final response = await http.post(
      //   Uri.parse('https://your-api.com/expenses'),
      //   body: jsonEncode(expense.toMap()),
      // );
      // return response.statusCode == 200;

      // دلوقتي هنعمل fake delay عشان نحاكي API call
      await Future.delayed(const Duration(seconds: 1));

      // نفترض إن الإرسال نجح
      return true;
    } catch (e) {
      print('❌ Error sending to server: $e');
      return false;
    }
  }

  // فحص حالة الاتصال بالإنترنت (طريقة أفضل)
  Future<bool> hasInternet() async {
    try {
      // نجرب نعمل ping لـ Google
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('✅ Internet is available');
        return true;
      }
      print('❌ No internet connection');
      return false;
    } catch (e) {
      print('❌ No internet connection: $e');
      return false;
    }
  }

  // مزامنة يدوية (لو المستخدم ضغط زرار Sync)
  Future<void> manualSync() async {
    bool hasNet = await hasInternet();

    if (!hasNet) {
      print('❌ No internet connection');
      return;
    }

    await syncExpenses();
  }
}
