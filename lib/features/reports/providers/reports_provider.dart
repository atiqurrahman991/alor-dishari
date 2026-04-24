import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import 'package:intl/intl.dart';

// Provider to fetch daily and monthly reports for the admin
final reportsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
  final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

  // 1. Today's Savings
  final todaySavingsData = await supabase
      .from('savings')
      .select('deposit_amount')
      .eq('status', 'approved')
      .gte('created_at', startOfDay);
  final todaySavings = todaySavingsData.fold<double>(0, (sum, item) => sum + (item['deposit_amount'] as num));

  // 2. This Month's Savings
  final monthSavingsData = await supabase
      .from('savings')
      .select('deposit_amount')
      .eq('status', 'approved')
      .gte('created_at', startOfMonth);
  final monthSavings = monthSavingsData.fold<double>(0, (sum, item) => sum + (item['deposit_amount'] as num));

  // 3. Today's Installments
  final todayInstallmentData = await supabase
      .from('installments')
      .select('paid_amount')
      .eq('status', 'approved')
      .gte('created_at', startOfDay);
  final todayInstallment = todayInstallmentData.fold<double>(0, (sum, item) => sum + (item['paid_amount'] as num));

  // 4. This Month's Installments
  final monthInstallmentData = await supabase
      .from('installments')
      .select('paid_amount')
      .eq('status', 'approved')
      .gte('created_at', startOfMonth);
  final monthInstallment = monthInstallmentData.fold<double>(0, (sum, item) => sum + (item['paid_amount'] as num));

  return {
    'today_savings': todaySavings,
    'month_savings': monthSavings,
    'today_installment': todayInstallment,
    'month_installment': monthInstallment,
    'today_total': todaySavings + todayInstallment,
    'month_total': monthSavings + monthInstallment,
    'month_name': DateFormat('MMMM yyyy').format(now),
  };
});
