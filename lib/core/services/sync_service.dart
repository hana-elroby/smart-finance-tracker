import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/database_helper.dart';
import '../models/expense_model.dart';
import 'firestore_service.dart';

class SyncService {
  static final SyncService instance = SyncService._internal();
  SyncService._internal();
  factory SyncService() => instance;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirestoreService _firestoreService = FirestoreService();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  // Sync status stream controller
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  // Start listening for connectivity changes - بدء مراقبة الاتصال بالإنترنت
  void startListening() {
    try {
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          if (results.contains(ConnectivityResult.mobile) ||
              results.contains(ConnectivityResult.wifi)) {
            print('📶 Internet connected! Starting sync...');
            syncExpenses();
          } else {
            print('📵 No internet connection');
            _syncStatusController.add(SyncStatus.offline);
          }
        },
      );
    } catch (e) {
      print('⚠️ Cannot start connectivity listener: $e');
    }
  }

  // Stop listening - إيقاف المراقبة
  void stopListening() {
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }

  // Sync expenses - مزامنة المصاريف
  Future<SyncResult> syncExpenses() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress...');
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);
    print('🔄 Starting sync...');

    int syncedCount = 0;
    int failedCount = 0;

    try {
      // Get unsynced expenses - جلب المصاريف غير المتزامنة
      List<Map<String, dynamic>> unsyncedExpensesMap =
          await _dbHelper.getUnsyncedExpenses();

      if (unsyncedExpensesMap.isEmpty) {
        print('✅ No expenses to sync');
        _syncStatusController.add(SyncStatus.synced);
        _isSyncing = false;
        return SyncResult(success: true, message: 'All expenses are synced');
      }

      List<Expense> unsyncedExpenses =
          unsyncedExpensesMap.map((e) => Expense.fromMap(e)).toList();

      print('📤 Found ${unsyncedExpenses.length} expenses to sync');

      // Sync each expense - إرسال كل مصروف للسيرفر
      for (var expense in unsyncedExpenses) {
        final firestoreId = await _firestoreService.addExpense(expense);

        if (firestoreId != null) {
          await _dbHelper.markExpenseAsSynced(
            expense.id!,
            firestoreId: firestoreId,
          );
          syncedCount++;
          print('✅ Synced: ${expense.title}');
        } else {
          failedCount++;
          print('❌ Failed to sync: ${expense.title}');
        }
      }

      _syncStatusController.add(SyncStatus.synced);
      print('🎉 Sync completed! Synced: $syncedCount, Failed: $failedCount');

      return SyncResult(
        success: failedCount == 0,
        syncedCount: syncedCount,
        failedCount: failedCount,
        message: 'Synced $syncedCount expenses',
      );
    } catch (e) {
      print('❌ Sync error: $e');
      _syncStatusController.add(SyncStatus.error);
      return SyncResult(success: false, message: 'Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Check internet connection - فحص حالة الاتصال بالإنترنت
  Future<bool> hasInternet() async {
    try {
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

  // Manual sync - مزامنة يدوية
  Future<SyncResult> manualSync() async {
    bool hasNet = await hasInternet();

    if (!hasNet) {
      print('❌ No internet connection');
      return SyncResult(
        success: false,
        message: 'No internet connection',
      );
    }

    return await syncExpenses();
  }

  // Get sync status
  Future<SyncStatus> getSyncStatus() async {
    final hasNet = await hasInternet();
    if (!hasNet) return SyncStatus.offline;

    final unsynced = await _dbHelper.getUnsyncedExpenses();
    if (unsynced.isEmpty) return SyncStatus.synced;

    return SyncStatus.pending;
  }

  // Get unsynced count
  Future<int> getUnsyncedCount() async {
    final unsynced = await _dbHelper.getUnsyncedExpenses();
    return unsynced.length;
  }
}

// Sync status enum
enum SyncStatus {
  synced,
  syncing,
  pending,
  offline,
  error,
}

// Sync result class
class SyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final String message;

  SyncResult({
    required this.success,
    this.syncedCount = 0,
    this.failedCount = 0,
    required this.message,
  });
}
