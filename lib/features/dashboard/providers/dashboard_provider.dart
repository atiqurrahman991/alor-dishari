import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../main.dart'; // accessing global supabase

// 1. Get current logged in member's profile
final currentUserProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) return null;
  
  // Retry logic for race condition during signup
  for (int i = 0; i < 5; i++) {
    try {
      final data = await supabase
          .from('members')
          .select()
          .eq('auth_id', user.id)
          .single();
      return data;
    } catch (e) {
      if (i == 4) return null; // After 5 attempts give up
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
  return null;
});

// 2. Dashboard Stats Provider
final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final profile = await ref.watch(currentUserProfileProvider.future);
  if (profile == null) throw Exception('Profile not found');

  final isRoleAdmin = profile['role'] == 'admin';

  if (isRoleAdmin) {
    // ADMIN STATS
    // Members count
    final membersData = await supabase.from('members').select('id');
    final membersCount = membersData.length;

    // Total Savings
    final savingsData = await supabase.from('savings').select('deposit_amount').eq('status', 'approved');
    double totalSavings = savingsData.fold(0.0, (sum, item) => sum + ((item['deposit_amount'] as num).toDouble()));

    // Total Profit Distributed
    final profitData = await supabase.from('member_profit_shares').select('share_amount');
    double totalProfit = profitData.fold(0.0, (sum, item) => sum + ((item['share_amount'] as num).toDouble()));

    // Active Loans & Outstanding
    final loansData = await supabase.from('loans').select('outstanding_amount').eq('status', 'active');
    double totalOutstanding = loansData.fold(0.0, (sum, item) => sum + ((item['outstanding_amount'] as num).toDouble()));
    int activeLoansCount = loansData.length;

    // Target Progress (Samity Overall)
    const double monthlyTarget = 500.0;
    const int totalMonths = 60; // 5 years
    final double overallTarget = monthlyTarget * totalMonths * membersCount;
    
    final startDate = DateTime(2022, 1, 1);
    final now = DateTime.now();
    final monthsPassed = (now.year - startDate.year) * 12 + now.month - startDate.month + 1;
    final timeProgress = (monthsPassed / totalMonths).clamp(0.0, 1.0);

    return {
      'isAdmin': true,
      'total_members': membersCount,
      'total_savings': totalSavings + totalProfit,
      'total_pure_savings': totalSavings,
      'total_profit_distributed': totalProfit,
      'total_outstanding': totalOutstanding,
      'active_loans': activeLoansCount,
      'target_progress': (totalSavings / overallTarget).clamp(0.0, 1.0),
      'time_progress': timeProgress,
      'total_target': overallTarget,
    };
  } else {
    // MEMBER STATS
    final memberId = profile['id'];

    // Own Savings
    final savingsData = await supabase.from('savings').select('deposit_amount').eq('status', 'approved').eq('member_id', memberId);
    double totalSavings = savingsData.fold(0.0, (sum, item) => sum + ((item['deposit_amount'] as num).toDouble()));

    // Own Profit
    final profitData = await supabase.from('member_profit_shares').select('share_amount').eq('member_id', memberId);
    double ownProfit = profitData.fold(0.0, (sum, item) => sum + ((item['share_amount'] as num).toDouble()));

    // Own Outstanding Loans
    final loansData = await supabase.from('loans').select('outstanding_amount').eq('status', 'active').eq('member_id', memberId);
    double totalOutstanding = loansData.fold(0.0, (sum, item) => sum + ((item['outstanding_amount'] as num).toDouble()));
    int activeLoansCount = loansData.length;

    // Target Progress (Individual)
    const double monthlyTarget = 500.0;
    const int totalMonths = 60;
    const double individualTarget = monthlyTarget * totalMonths; // 30,000 BDT

    final startDate = DateTime(2022, 1, 1);
    final now = DateTime.now();
    final monthsPassed = (now.year - startDate.year) * 12 + now.month - startDate.month + 1;
    final timeProgress = (monthsPassed / totalMonths).clamp(0.0, 1.0);

    return {
      'isAdmin': false,
      'isPending': profile['status'] == 'pending',
      'name': profile['name'],
      'total_savings': totalSavings + ownProfit,
      'pure_savings': totalSavings,
      'total_profit': ownProfit,
      'total_outstanding': totalOutstanding,
      'active_loans': activeLoansCount,
      'target_progress': (totalSavings / individualTarget).clamp(0.0, 1.0),
      'time_progress': timeProgress,
      'individual_target': individualTarget,
    };
  }
});

// 3. Pending Savings Provider (Admin Only)
final pendingSavingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final profile = await ref.watch(currentUserProfileProvider.future);
  if (profile == null || profile['role'] != 'admin') return [];

  final data = await supabase
      .from('savings')
      .select('id, deposit_amount, date, members(name)')
      .eq('status', 'pending')
      .order('created_at', ascending: false);
      
  return List<Map<String, dynamic>>.from(data);
});

// 3.5. Pending Installments Provider (Admin Only)
final pendingInstallmentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final profile = await ref.watch(currentUserProfileProvider.future);
  if (profile == null || profile['role'] != 'admin') return [];

  final data = await supabase
      .from('installments')
      .select('id, paid_amount, date, loans(members(name))')
      .eq('status', 'pending')
      .order('created_at', ascending: false);
      
  return List<Map<String, dynamic>>.from(data);
});

// 3.8. Pending Members Provider (Admin Only)
final pendingMembersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final profile = await ref.watch(currentUserProfileProvider.future);
  if (profile == null || profile['role'] != 'admin') return [];

  final data = await supabase
      .from('members')
      .select('id, name, mobile, category')
      .eq('status', 'pending')
      .order('created_at', ascending: false);
      
  return List<Map<String, dynamic>>.from(data);
});

// 3.9. Pending Counts Provider (Admin Only)
final pendingCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final profile = await ref.watch(currentUserProfileProvider.future);
  if (profile == null || profile['role'] != 'admin') return {'members': 0, 'savings': 0, 'installments': 0, 'total': 0};

  final members = await supabase.from('members').select('id').eq('status', 'pending');
  final savings = await supabase.from('savings').select('id').eq('status', 'pending');
  final installments = await supabase.from('installments').select('id').eq('status', 'pending');

  int mCount = members.length;
  int sCount = savings.length;
  int iCount = installments.length;

  return {
    'members': mCount,
    'savings': sCount,
    'installments': iCount,
    'total': mCount + sCount + iCount,
  };
});

// 4. Action Notifier (Submit & Approve)
final actionProvider = Provider((ref) => ActionService(ref));

class ActionService {
  final ProviderRef ref;
  ActionService(this.ref);

  Future<void> submitSavings({
    required double amount, 
    required String month, 
    required String method,
    String? trxId,
    String? notes,
  }) async {
    final profile = await ref.read(currentUserProfileProvider.future);
    if (profile == null) throw Exception("User profile not found");

    await supabase.from('savings').insert({
      'member_id': profile['id'],
      'deposit_amount': amount,
      'month': month,
      'payment_method': method,
      'trx_id': trxId,
      'notes': notes,
      'status': 'pending', 
    });

    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(pendingSavingsProvider);
  }

  Future<void> requestWithdrawal({
    required double amount,
    String? method,
    String? trxId,
    String? notes,
  }) async {
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile == null) throw Exception('Profile not found');

    await supabase.from('savings').insert({
      'member_id': profile['id'],
      'deposit_amount': -amount, // Negative amount for withdrawal
      'payment_method': method,
      'trx_id': trxId,
      'notes': 'Withdrawal: ${notes ?? ""}',
      'status': 'pending', 
    });

    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(pendingSavingsProvider);
  }

  Future<void> approveSavings(String savingId) async {
    await supabase.from('savings').update({'status': 'approved'}).eq('id', savingId);
    
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(pendingSavingsProvider);
    ref.invalidate(pendingCountsProvider);
  }

  Future<void> rejectSavings(String savingId) async {
    await supabase.from('savings').update({'status': 'rejected'}).eq('id', savingId);
    
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(pendingSavingsProvider);
    ref.invalidate(pendingCountsProvider);
  }

  Future<void> submitInstallment({
    required double amount, 
    required String month, 
    required String method,
    String? trxId,
    String? notes,
  }) async {
    final profile = await ref.read(currentUserProfileProvider.future);
    if (profile == null) throw Exception("User profile not found");

    // Get active loan
    final loanData = await supabase.from('loans').select('id').eq('member_id', profile['id']).eq('status', 'active').maybeSingle();
    
    if (loanData == null) throw Exception("You do not have any active loans");

    await supabase.from('installments').insert({
      'loan_id': loanData['id'],
      'paid_amount': amount,
      'month': month,
      'payment_method': method,
      'trx_id': trxId,
      'notes': notes,
      'status': 'pending',
    });

    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(pendingInstallmentsProvider);
    ref.invalidate(pendingCountsProvider);
  }

  Future<void> approveInstallment(String instId) async {
    await supabase.from('installments').update({'status': 'approved'}).eq('id', instId);
    
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(pendingInstallmentsProvider);
    ref.invalidate(pendingCountsProvider);
  }

  Future<void> rejectInstallment(String instId) async {
    await supabase.from('installments').update({'status': 'rejected'}).eq('id', instId);
    
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(pendingInstallmentsProvider);
    ref.invalidate(pendingCountsProvider);
  }

  Future<void> approveMember(String memberId) async {
    await supabase.from('members').update({'status': 'active'}).eq('id', memberId);
    
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(pendingMembersProvider);
    ref.invalidate(pendingCountsProvider);
    // optionally invalidate member list if we had one here
  }
}
