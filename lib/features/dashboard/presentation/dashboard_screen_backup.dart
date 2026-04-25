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
import '../../members/presentation/profile_screen.dart';
import '../../profit/presentation/profit_screen.dart';

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
            icon: const Icon(Icons.account_circle_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context, tr, theme),
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
                    int crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
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
                          title: tr[Tr.totalSavings], 
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
                          title: tr[Tr.activeLoans], 
                          value: '${stats['active_loans']}', 
                          icon: Icons.credit_score_rounded,
                          color: Colors.purpleAccent,
                        ),
                      ],
                    );
                  }
                ),
                
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
                      label: Text(tr[Tr.addInstallment]),
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
                        label: const Text('সঞ্চয় উত্তোলন'),
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
                    ActionChip(
                      label: Text(tr[Tr.profitDistribution]),
                      avatar: const Icon(Icons.workspace_premium_rounded, size: 18),
                      backgroundColor: Colors.amber.withOpacity(0.1),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfitScreen()),
                        );
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

  Widget _buildDrawer(BuildContext context, TranslationService tr, ThemeData theme) {
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
            leading: const Icon(Icons.workspace_premium_rounded),
            title: Text(tr[Tr.profitDistribution]),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitScreen()));
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
