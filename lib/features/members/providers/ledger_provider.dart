import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';

// 1. Ledger Data Provider
// Fetches both savings and installments for a specific member and merges them into a timeline
final ledgerProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, memberId) async {
  // Fetch approved savings
  final savingsResponse = await supabase
      .from('savings')
      .select('id, deposit_amount, month, payment_method, trx_id, created_at, notes')
      .eq('member_id', memberId)
      .eq('status', 'approved')
      .order('created_at', ascending: false);

  // Fetch active/paid installments
  final installmentsResponse = await supabase
      .from('installments')
      .select('id, paid_amount, month, payment_method, trx_id, created_at, notes, loans(id)')
      .eq('member_id', memberId)
      .eq('status', 'approved')
      .order('created_at', ascending: false);

  // Fetch profit shares
  final profitResponse = await supabase
      .from('member_profit_shares')
      .select('id, share_amount, created_at, profit_distributions(period_name)')
      .eq('member_id', memberId)
      .order('created_at', ascending: false);

  // Merge and sort
  List<Map<String, dynamic>> combined = [];
  
  for (var s in savingsResponse) {
    combined.add({
      'type': 'savings',
      'amount': s['deposit_amount'],
      'month': s['month'],
      'method': s['payment_method'],
      'trx_id': s['trx_id'],
      'date': s['created_at'],
      'notes': s['notes']
    });
  }

  for (var i in installmentsResponse) {
    combined.add({
      'type': 'installment',
      'amount': i['paid_amount'],
      'month': i['month'],
      'method': i['payment_method'],
      'trx_id': i['trx_id'],
      'date': i['created_at'],
      'notes': i['notes']
    });
  }

  for (var p in profitResponse) {
    combined.add({
      'type': 'profit',
      'amount': p['share_amount'],
      'month': p['profit_distributions']?['period_name'] ?? 'N/A',
      'method': 'System',
      'trx_id': 'PROF-${p['id'].toString().substring(0, 8)}',
      'date': p['created_at'],
      'notes': 'Islamic Profit Sharing (Mudaraba)'
    });
  }

  // Sort by date descending
  combined.sort((a, b) => b['date'].compareTo(a['date']));

  return combined;
});
