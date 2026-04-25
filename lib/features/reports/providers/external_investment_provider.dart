import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';

final externalInvestmentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await supabase
      .from('external_investments')
      .select('*')
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

final externalInvestmentActionProvider = Provider((ref) => ExternalInvestmentService(ref));

class ExternalInvestmentService {
  final ProviderRef ref;
  ExternalInvestmentService(this.ref);

  Future<void> addInvestment({
    required String title,
    required double amount,
    String? notes,
  }) async {
    await supabase.from('external_investments').insert({
      'title': title,
      'amount': amount,
      'notes': notes,
      'created_by': supabase.auth.currentUser?.id,
    });
    ref.invalidate(externalInvestmentsProvider);
  }

  Future<void> closeInvestment(String id) async {
    await supabase
        .from('external_investments')
        .update({'status': 'closed'})
        .eq('id', id);
    ref.invalidate(externalInvestmentsProvider);
  }
}
