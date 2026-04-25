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

// Provider for detailed collection analysis (Expected vs Actual)
final collectionReportProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
  
  // 1. Get all active members
  final membersResponse = await supabase
      .from('members')
      .select('id, name, mobile')
      .eq('status', 'active');
  final members = membersResponse as List;
  
  // 2. Get all approved savings for this month
  final savingsResponse = await supabase
      .from('savings')
      .select('member_id, deposit_amount')
      .eq('status', 'approved')
      .gte('created_at', startOfMonth);
  final savings = savingsResponse as List;

  // 3. Map savings to member IDs
  Map<String, double> memberSavings = {};
  for (var s in savings) {
    final id = s['member_id'];
    final amount = (s['deposit_amount'] as num).toDouble();
    memberSavings[id] = (memberSavings[id] ?? 0.0) + amount;
  }

  // 4. Analyze who has paid and who hasn't
  List<Map<String, dynamic>> paidMembers = [];
  List<Map<String, dynamic>> dueMembers = [];
  
  const double monthlyTarget = 500.0;

  for (var m in members) {
    final id = m['id'];
    final paid = memberSavings[id] ?? 0.0;
    
    if (paid >= monthlyTarget) {
      paidMembers.add({...m, 'paid': paid});
    } else {
      dueMembers.add({...m, 'paid': paid, 'due': monthlyTarget - paid});
    }
  }

  return {
    'total_members': members.length,
    'expected_collection': members.length * monthlyTarget,
    'actual_collection': savings.fold<double>(0, (sum, item) => sum + (item['deposit_amount'] as num)),
    'paid_count': paidMembers.length,
    'due_count': dueMembers.length,
    'due_members': dueMembers,
    'paid_members': paidMembers,
  };
});

