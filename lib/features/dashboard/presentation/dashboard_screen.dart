import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/translation_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import 'add_savings_dialog.dart';
import 'add_installment_dialog.dart';
import 'withdraw_savings_dialog.dart';
import '../../members/presentation/members_screen.dart';
import '../../members/presentation/ledger_screen.dart';
import '../../reports/presentation/reports_screen.dart';
import '../../reports/presentation/distribute_profit_dialog.dart';
import '../../members/presentation/profile_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationProvider);
    final theme = Theme.of(context);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    
    // Watch real data
    final statsAsyncValue = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr[Tr.dashboard]),
        actions: [
          IconButton(
            tooltip: tr[Tr.switchLanguage],
            icon: const Icon(Icons.language_rounded),
            onPressed: ref.read(languageProvider.notifier).toggle,
          ),
          IconButton(
            tooltip: isDark ? tr[Tr.lightMode] : tr[Tr.darkMode],
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: ref.read(themeModeProvider.notifier).toggle,
          ),
          IconButton(
            tooltip: tr[Tr.logout],
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
          IconButton(
            tooltip: 'আমার প্রোফাইল',
            icon: ref.watch(pendingCountsProvider).when(
              data: (counts) => counts['total']! > 0 
                ? Badge(
                    label: Text('${counts['total']}'),
                    child: const Icon(Icons.account_circle_rounded),
                  )
                : const Icon(Icons.account_circle_rounded),
              loading: () => const Icon(Icons.account_circle_rounded),
              error: (_, __) => const Icon(Icons.account_circle_rounded),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context, tr, theme, ref),
      body: statsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(
          child: Text('Error loading dashboard: $e', style: TextStyle(color: theme.colorScheme.error)),
        ),
        data: (stats) {
          final isAdmin = stats['isAdmin'] == true;
          final isPending = stats['isPending'] == true;
          
          if (isPending) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_empty_rounded, size: 80, color: theme.colorScheme.primary),
                    const SizedBox(height: 24),
                    Text(
                      'অ্যাকাউন্ট অনুমোদনের অপেক্ষায়',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'আপনার অ্যাকাউন্টটি সফলভাবে তৈরি হয়েছে। অ্যাডমিন কর্তৃক অনুমোদিত হওয়ার পর আপনি হোমপেজ দেখতে পাবেন। দয়া করে কিছুক্ষণ অপেক্ষা করুন।',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAdmin ? tr[Tr.welcomeBack] : '${tr[Tr.hello]}, ${stats['name']}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tr[Tr.administrator],
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 24),
                
                // Grid of Stats
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 800 ? (isAdmin ? 5 : 4) : (constraints.maxWidth > 500 ? 2 : 1);
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                      children: [
                        if (isAdmin)
                          _DashboardCard(
                            title: tr[Tr.totalMembers], 
                            value: '${stats['total_members']}', 
                            icon: Icons.groups_rounded,
                            color: Colors.blueAccent,
                          ),
                        _DashboardCard(
                          title: 'মোট সঞ্চয় + লভ্যাংশ', 
                          value: '৳ ${stats['total_savings']}', 
                          icon: Icons.savings_rounded,
                          color: Colors.teal,
                        ),
                        _DashboardCard(
                          title: tr[Tr.totalOutstanding], 
                          value: '৳ ${stats['total_outstanding']}', 
                          icon: Icons.account_balance_wallet_rounded,
                          color: Colors.orangeAccent,
                        ),
                        _DashboardCard(
                          title: tr[Tr.activeInvestments], 
                          value: '${stats['active_loans']}', 
                          icon: Icons.credit_score_rounded,
                          color: Colors.purpleAccent,
                        ),
                        if (isAdmin)
                          _DashboardCard(
                            title: 'বাহ্যিক বিনিয়োগ', 
                            value: '৳ ${stats['total_external_investments']}', 
                            icon: Icons.business_center_rounded,
                            color: Colors.brown,
                          ),
                      ],
                    );
                  }
                ),

                const SizedBox(height: 24),
                _TargetProgressCard(stats: stats),
                
                const SizedBox(height: 40),
                Text(
                  tr[Tr.quickActions],
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    if (isAdmin)
                      ActionChip(
                        label: Text(tr[Tr.addMember]),
                        avatar: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                        onPressed: () {},
                      ),
                    if (isAdmin)
                      ActionChip(
                        label: Text(tr[Tr.distributeProfit]),
                        avatar: const Icon(Icons.account_balance_rounded, size: 18),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const DistributeProfitDialog(),
                          );
                        },
                      ),
                    ActionChip(
                      label: Text(tr[Tr.addSavings]),
                      avatar: const Icon(Icons.monetization_on_rounded, size: 18),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const AddSavingsDialog(),
                        );
                      },
                    ),
                    ActionChip(
                      label: Text(tr[Tr.addReturn]),
                      avatar: const Icon(Icons.receipt_long_rounded, size: 18),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const AddInstallmentDialog(),
                        );
                      },
                    ),
                    if (!isAdmin)
                      ActionChip(
                        label: const Text('সঞ্চয় উত্তোলন'),
                        avatar: const Icon(Icons.money_off_rounded, size: 18),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const WithdrawSavingsDialog(),
                          );
                        },
                      ),
                    if (!isAdmin)
                      ActionChip(
                        label: Text(tr[Tr.viewLedger]),
                        avatar: const Icon(Icons.analytics_rounded, size: 18),
                        onPressed: () {
                          final profile = ref.read(currentUserProfileProvider).value;
                          if (profile != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LedgerScreen(
                                  memberId: profile['id'],
                                  memberName: stats['name'],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 40),
                  const _PendingApprovalsSection(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, TranslationService tr, ThemeData theme, WidgetRef ref) {
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.dashboard_customize_rounded, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  tr[Tr.appName],
                  style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: Text(tr[Tr.dashboard]),
            selected: true,
            selectedColor: theme.colorScheme.primary,
            onTap: () => Navigator.pop(context),
          ),
          // Typically hidden or restricted for normal members, 
          // For now left visible
          ListTile(
            leading: const Icon(Icons.people_alt_rounded),
            title: Text(tr[Tr.members]),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MembersScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_rounded),
            title: const Text('হিসাব-নিকাশ (Reports)'),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_rounded),
            title: const Text('আমার প্রোফাইল'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: Text(tr[Tr.logout]),
            onTap: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingApprovalsSection extends ConsumerWidget {
  const _PendingApprovalsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tr = ref.watch(translationProvider);
    final pendingAsync = ref.watch(pendingSavingsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pending_actions_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text(
                tr[Tr.pendingApprovals],
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // MEMBER APPROVALS (New section)
          Text('নতুন মেম্বার রিকোয়েস্ট', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
          ref.watch(pendingMembersProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('${tr[Tr.errorLoading]}: $e', style: TextStyle(color: theme.colorScheme.error)),
            data: (items) {
              if (items.isEmpty) {
                return Text(tr[Tr.noPending], style: theme.textTheme.bodyMedium);
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.tertiary.withOpacity(0.1),
                      child: Icon(Icons.person_add, color: theme.colorScheme.tertiary),
                    ),
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Mobile: ${item['mobile']} (${item['category']})'),
                    trailing: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await ref.read(actionProvider).approveMember(item['id']);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Member Approved!'), backgroundColor: Colors.green),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error approving member'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: Text(ref.watch(translationProvider)[Tr.approve]),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          
          const SizedBox(height: 24),
          // SAVINGS
          Text('পুঁজি জমার রিকোয়েস্ট', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
          pendingAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('${tr[Tr.errorLoading]}: $e', style: TextStyle(color: theme.colorScheme.error)),
            data: (items) {
              if (items.isEmpty) {
                return Text(
                  tr[Tr.noPending],
                  style: theme.textTheme.bodyMedium,
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final memberName = item['members']?['name'] ?? 'Unknown Member';
                  final amount = item['deposit_amount'];
                  final id = item['id'];

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: const Icon(Icons.person),
                    ),
                    title: Text(memberName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(amount < 0 
                      ? '৳ ${amount.abs()} উত্তোলনের আবেদন' 
                      : '৳ $amount পুঁজি জমার আবেদন'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                          onPressed: () => ref.read(actionProvider).rejectSavings(id),
                          tooltip: 'Reject',
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await ref.read(actionProvider).approveSavings(id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Approved!'), backgroundColor: Colors.green),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error approving'), backgroundColor: Colors.red),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                          label: Text(ref.watch(translationProvider)[Tr.approve]),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          
          const SizedBox(height: 24),
          // INSTALLMENTS
          Text('বিনিয়োগ ফেরতের আবেদন', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
          ref.watch(pendingInstallmentsProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('${tr[Tr.errorLoading]}: $e', style: TextStyle(color: theme.colorScheme.error)),
            data: (items) {
              if (items.isEmpty) {
                return Text(
                  tr[Tr.noPending],
                  style: theme.textTheme.bodyMedium,
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final memberName = item['loans']?['members']?['name'] ?? 'Unknown Member';
                  final amount = item['paid_amount'];
                  final id = item['id'];

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: const Icon(Icons.person),
                    ),
                    title: Text(memberName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('৳ $amount বিনিয়োগ ফেরত (কিস্তি)'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                          onPressed: () => ref.read(actionProvider).rejectInstallment(id),
                          tooltip: 'Reject',
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await ref.read(actionProvider).approveInstallment(id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Approved!'), backgroundColor: Colors.green),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error approving'), backgroundColor: Colors.red),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                          label: Text(ref.watch(translationProvider)[Tr.approve]),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TargetProgressCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _TargetProgressCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = stats['isAdmin'] == true;
    final targetProgress = stats['target_progress'] as double;
    final timeProgress = stats['time_progress'] as double;
    final targetAmount = isAdmin ? stats['total_target'] : stats['individual_target'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.track_changes_rounded, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Text(
                  isAdmin ? '৫ বছরের লক্ষ্যমাত্রা (পুরো সমিতি)' : '৫ বছরের লক্ষ্যমাত্রা (ব্যক্তিগত)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Savings Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('পুঁজি জমার লক্ষ্যমাত্রা'),
                Text('${(targetProgress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: targetProgress,
                minHeight: 12,
                backgroundColor: Colors.green.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'লক্ষ্য: ৳ $targetAmount',
              style: theme.textTheme.bodySmall,
            ),
            
            const SizedBox(height: 20),
            
            // Time Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('সময় অতিক্রান্ত'),
                Text('${(timeProgress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: timeProgress,
                minHeight: 12,
                backgroundColor: Colors.blue.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'মেয়াদ: জানুয়ারি ২০২২ - ডিসেম্বর ২০২৬',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
