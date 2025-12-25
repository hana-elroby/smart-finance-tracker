// Analytics API Service - خدمة التحليلات
// Handles all analytics-related API calls

import 'api_service.dart';

class AnalyticsApiService {
  static final AnalyticsApiService instance = AnalyticsApiService._internal();
  AnalyticsApiService._internal();
  factory AnalyticsApiService() => instance;

  final ApiService _api = ApiService();

  // Get Summary
  Future<AnalyticsSummaryResult> getSummary() async {
    final response = await _api.get('/analytics/summary');

    if (response.isSuccess) {
      return AnalyticsSummaryResult.success(
        totalSpent: (response.getData<num>('totalSpent') ?? 0).toDouble(),
        totalTransactions: response.getData<int>('totalTransactions') ?? 0,
        averageTransaction: (response.getData<num>('averageTransaction') ?? 0).toDouble(),
        thisMonthSpent: (response.getData<num>('thisMonthSpent') ?? 0).toDouble(),
        lastMonthSpent: (response.getData<num>('lastMonthSpent') ?? 0).toDouble(),
      );
    }

    return AnalyticsSummaryResult.failure(message: response.message ?? 'Failed to load summary');
  }

  // Get Analytics by Category
  Future<CategoryAnalyticsResult> getByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String().split('T')[0];

    final query = queryParams.isNotEmpty 
        ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';

    final response = await _api.get('/analytics/by-category$query');

    if (response.isSuccess) {
      final data = response.getData<List>('categories') ?? response.data ?? [];
      final categories = data.map((item) {
        final map = item as Map<String, dynamic>;
        return CategoryAnalytics(
          categoryId: map['_id'] ?? map['categoryId'] ?? '',
          categoryName: map['name'] ?? map['categoryName'] ?? 'Other',
          total: (map['total'] as num?)?.toDouble() ?? 0,
          count: map['count'] ?? 0,
          percentage: (map['percentage'] as num?)?.toDouble() ?? 0,
        );
      }).toList();

      return CategoryAnalyticsResult.success(categories: categories);
    }

    return CategoryAnalyticsResult.failure(message: response.message ?? 'Failed to load category analytics');
  }

  // Get Analytics by Date
  Future<DateAnalyticsResult> getByDate({
    String period = 'daily', // daily, weekly, monthly
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{'period': period};
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String().split('T')[0];

    final query = '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    final response = await _api.get('/analytics/by-date$query');

    if (response.isSuccess) {
      final data = response.getData<List>('data') ?? response.data ?? [];
      final dateData = data.map((item) {
        final map = item as Map<String, dynamic>;
        return DateAnalytics(
          date: map['date'] ?? map['_id'] ?? '',
          total: (map['total'] as num?)?.toDouble() ?? 0,
          count: map['count'] ?? 0,
        );
      }).toList();

      return DateAnalyticsResult.success(data: dateData);
    }

    return DateAnalyticsResult.failure(message: response.message ?? 'Failed to load date analytics');
  }

  // Get Top Categories
  Future<CategoryAnalyticsResult> getTopCategories({int limit = 5}) async {
    final response = await _api.get('/analytics/top-categories?limit=$limit');

    if (response.isSuccess) {
      final data = response.getData<List>('categories') ?? response.data ?? [];
      final categories = data.map((item) {
        final map = item as Map<String, dynamic>;
        return CategoryAnalytics(
          categoryId: map['_id'] ?? map['categoryId'] ?? '',
          categoryName: map['name'] ?? map['categoryName'] ?? 'Other',
          total: (map['total'] as num?)?.toDouble() ?? 0,
          count: map['count'] ?? 0,
          percentage: (map['percentage'] as num?)?.toDouble() ?? 0,
        );
      }).toList();

      return CategoryAnalyticsResult.success(categories: categories);
    }

    return CategoryAnalyticsResult.failure(message: response.message ?? 'Failed to load top categories');
  }

  // Get Trends
  Future<TrendsResult> getTrends() async {
    final response = await _api.get('/analytics/trends');

    if (response.isSuccess) {
      return TrendsResult.success(
        weeklyChange: (response.getData<num>('weeklyChange') ?? 0).toDouble(),
        monthlyChange: (response.getData<num>('monthlyChange') ?? 0).toDouble(),
        topCategory: response.getData<String>('topCategory'),
        averageDaily: (response.getData<num>('averageDaily') ?? 0).toDouble(),
      );
    }

    return TrendsResult.failure(message: response.message ?? 'Failed to load trends');
  }
}

// Analytics Summary Result
class AnalyticsSummaryResult {
  final bool isSuccess;
  final double totalSpent;
  final int totalTransactions;
  final double averageTransaction;
  final double thisMonthSpent;
  final double lastMonthSpent;
  final String? message;

  AnalyticsSummaryResult._({
    required this.isSuccess,
    this.totalSpent = 0,
    this.totalTransactions = 0,
    this.averageTransaction = 0,
    this.thisMonthSpent = 0,
    this.lastMonthSpent = 0,
    this.message,
  });

  factory AnalyticsSummaryResult.success({
    required double totalSpent,
    required int totalTransactions,
    required double averageTransaction,
    required double thisMonthSpent,
    required double lastMonthSpent,
  }) {
    return AnalyticsSummaryResult._(
      isSuccess: true,
      totalSpent: totalSpent,
      totalTransactions: totalTransactions,
      averageTransaction: averageTransaction,
      thisMonthSpent: thisMonthSpent,
      lastMonthSpent: lastMonthSpent,
    );
  }

  factory AnalyticsSummaryResult.failure({required String message}) {
    return AnalyticsSummaryResult._(isSuccess: false, message: message);
  }

  double get monthlyChangePercent {
    if (lastMonthSpent == 0) return 0;
    return ((thisMonthSpent - lastMonthSpent) / lastMonthSpent) * 100;
  }
}

// Category Analytics
class CategoryAnalytics {
  final String categoryId;
  final String categoryName;
  final double total;
  final int count;
  final double percentage;

  CategoryAnalytics({
    required this.categoryId,
    required this.categoryName,
    required this.total,
    required this.count,
    required this.percentage,
  });
}

// Category Analytics Result
class CategoryAnalyticsResult {
  final bool isSuccess;
  final List<CategoryAnalytics> categories;
  final String? message;

  CategoryAnalyticsResult._({
    required this.isSuccess,
    this.categories = const [],
    this.message,
  });

  factory CategoryAnalyticsResult.success({required List<CategoryAnalytics> categories}) {
    return CategoryAnalyticsResult._(isSuccess: true, categories: categories);
  }

  factory CategoryAnalyticsResult.failure({required String message}) {
    return CategoryAnalyticsResult._(isSuccess: false, message: message);
  }
}

// Date Analytics
class DateAnalytics {
  final String date;
  final double total;
  final int count;

  DateAnalytics({
    required this.date,
    required this.total,
    required this.count,
  });
}

// Date Analytics Result
class DateAnalyticsResult {
  final bool isSuccess;
  final List<DateAnalytics> data;
  final String? message;

  DateAnalyticsResult._({
    required this.isSuccess,
    this.data = const [],
    this.message,
  });

  factory DateAnalyticsResult.success({required List<DateAnalytics> data}) {
    return DateAnalyticsResult._(isSuccess: true, data: data);
  }

  factory DateAnalyticsResult.failure({required String message}) {
    return DateAnalyticsResult._(isSuccess: false, message: message);
  }
}

// Trends Result
class TrendsResult {
  final bool isSuccess;
  final double weeklyChange;
  final double monthlyChange;
  final String? topCategory;
  final double averageDaily;
  final String? message;

  TrendsResult._({
    required this.isSuccess,
    this.weeklyChange = 0,
    this.monthlyChange = 0,
    this.topCategory,
    this.averageDaily = 0,
    this.message,
  });

  factory TrendsResult.success({
    required double weeklyChange,
    required double monthlyChange,
    String? topCategory,
    required double averageDaily,
  }) {
    return TrendsResult._(
      isSuccess: true,
      weeklyChange: weeklyChange,
      monthlyChange: monthlyChange,
      topCategory: topCategory,
      averageDaily: averageDaily,
    );
  }

  factory TrendsResult.failure({required String message}) {
    return TrendsResult._(isSuccess: false, message: message);
  }
}
