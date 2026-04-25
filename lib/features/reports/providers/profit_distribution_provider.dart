import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../dashboard/providers/dashboard_provider.dart';

final profitDistributionProvider = Provider((ref) => ProfitDistributionService(ref));

class ProfitDistributionService {
  final ProviderRef ref;
  ProfitDistributionService(this.ref);

  /// Fetches all members with their total approved savings balance
  Future<List<Map<String, dynamic>>> getMemberSavingsBalances() async {
    // 1. Get all members
    final membersResponse = await supabase
        .from('members')
        .select('id, name')
        .eq('status', 'active');
    
    // 2. Get all approved savings/withdrawals
    final savingsResponse = await supabase
        .from('savings')
        .select('member_id, deposit_amount')
        .eq('status', 'approved');

    // 3. Calculate balance per member
    Map<String, double> memberBalances = {};
    for (var saving in savingsResponse) {
      final memberId = saving['member_id'] as String;
      final amount = (saving['deposit_amount'] as num).toDouble();
      memberBalances[memberId] = (memberBalances[memberId] ?? 0.0) + amount;
    }

    // 4. Map back to member list
    List<Map<String, dynamic>> result = [];
    for (var member in membersResponse) {
      final id = member['id'] as String;
      final balance = memberBalances[id] ?? 0.0;
      if (balance > 0) {
        result.add({
          'id': id,
          'name': member['name'],
          'balance': balance,
        });
      }
    }

    return result;
  }

  /// Distributes profit to all eligible members
  Future<void> distributeProfit({
    required String periodName,
    required double totalProfit,
    String? notes,
  }) async {
    final membersWithBalances = await getMemberSavingsBalances();
    
    double totalSystemSavings = membersWithBalances.fold(0.0, (sum, m) => sum + m['balance']);
    
    if (totalSystemSavings <= 0) throw Exception("No savings found in system to distribute profit.");

    // 1. Create the distribution record
    final distributionResponse = await supabase.from('profit_distributions').insert({
      'period_name': periodName,
      'total_profit_amount': totalProfit,
      'total_eligible_savings': totalSystemSavings,
      'notes': notes,
      'created_by': supabase.auth.currentUser?.id,
    }).select().single();

    final distributionId = distributionResponse['id'];

    // 2. Create individual share records
    List<Map<String, dynamic>> shares = [];
    for (var member in membersWithBalances) {
      double memberBalance = member['balance'];
      // Share = (Member Balance / Total Balance) * Total Profit
      double shareAmount = (memberBalance / totalSystemSavings) * totalProfit;

      shares.add({
        'distribution_id': distributionId,
        'member_id': member['id'],
        'share_amount': double.parse(shareAmount.toStringAsFixed(2)),
        'member_savings_at_time': memberBalance,
      });
    }

    if (shares.isNotEmpty) {
      await supabase.from('member_profit_shares').insert(shares);
    }

    // 3. Add the profit as a 'savings' entry (optional but recommended for ledger visibility)
    // Actually, maybe it's better to just show it in ledger from the profit_shares table.
    // For now, let's just invalidate the dashboard to refresh stats if needed.
    ref.invalidate(dashboardStatsProvider);
  }
}
