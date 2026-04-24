import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart'; // global supabase

final membersListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await supabase
      .from('members')
      .select('id, name, mobile, nid, category, role, created_at')
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
});

final memberActionProvider = Provider((ref) => MemberActionService(ref));

class MemberActionService {
  final ProviderRef ref;
  MemberActionService(this.ref);

  Future<void> issueLoan({
    required String memberId,
    required double amount,
    required double installmentAmount,
  }) async {
    await supabase.from('loans').insert({
      'member_id': memberId,
      'total_loan': amount,
      'outstanding_amount': amount,
      'installment_amount': installmentAmount,
      'status': 'active'
    });
    // Invalidate dashboard stats to reflect the new loan
    // Usually requiring an import to dashboard_provider, but we can do a global refresh if needed.
  }
}
