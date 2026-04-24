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

    // Active Loans & Outstanding
    final loansData = await supabase.from('loans').select('outstanding_amount').eq('status', 'active');
    double totalOutstanding = loansData.fold(0.0, (sum, item) => sum + ((item['outstanding_amount'] as num).toDouble()));
    int activeLoansCount = loansData.length;

    return {
      'isAdmin': true,
      'total_members': membersCount,
      'total_savings': totalSavings,
      'total_outstanding': totalOutstanding,
      'active_loans': activeLoansCount,
    };
  } else {
    // MEMBER STATS
    final memberId = profile['id'];

    // Own Savings
    final savingsData = await supabase.from('savings').select('deposit_amount').eq('status', 'approved').eq('member_id', memberId);
    double totalSavings = savingsData.fold(0.0, (sum, item) => sum + ((item['deposit_amount'] as num).toDouble()));

    // Own Outstanding Loans
    final loansData = await supabase.from('loans').select('outstanding_amount').eq('status', 'active').eq('member_id', memberId);
    double totalOutstanding = loansData.fold(0.0, (sum, item) => sum + ((item['outstanding_amount'] as num).toDouble()));
    int activeLoansCount = loansData.length;

    return {
      'isAdmin': false,
      'isPending': profile['status'] == 'pending',
      'name': profile['name'],
      'total_savings': totalSavings,
      'total_outstanding': totalOutstanding,
      'active_loans': activeLoansCount,
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

  Future<void> approveSavings(String savingId) async {
    await supabase.from('savings').update({'status': 'approved'}).eq('id', savingId);
    
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(pendingSavingsProvider);
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
  }

  Future<void> approveInstallment(String instId) async {
    await supabase.from('installments').update({'status': 'approved'}).eq('id', instId);
    
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(pendingInstallmentsProvider);
  }

  Future<void> approveMember(String memberId) async {
    await supabase.from('members').update({'status': 'active'}).eq('id', memberId);
    
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(pendingMembersProvider);
    // optionally invalidate member list if we had one here
  }
}
