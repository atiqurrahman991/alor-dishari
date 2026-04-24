import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/translation_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/members_provider.dart';
import 'issue_loan_dialog.dart';
import 'ledger_screen.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tr = ref.watch(translationProvider);
    final membersAsync = ref.watch(membersListProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr[Tr.memberList]),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: tr[Tr.refresh],
            onPressed: () => ref.invalidate(membersListProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text('Error: $e', style: TextStyle(color: theme.colorScheme.error)),
        ),
        data: (members) {
          if (members.isEmpty) {
            return Center(
              child: Text(
                tr[Tr.noMembersFound],
                style: theme.textTheme.titleMedium,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(membersListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final role = member['role'];
                final isAdmin = role == 'admin';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  shadowColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: isAdmin 
                        ? theme.colorScheme.primaryContainer 
                        : theme.colorScheme.secondaryContainer,
                      child: Icon(
                        isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                        color: isAdmin 
                          ? theme.colorScheme.onPrimaryContainer 
                          : theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    title: Text(
                      member['name'] ?? 'Unknown',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(member['mobile'] ?? 'No Mobile'),
                    ),
                    childrenPadding: const EdgeInsets.all(16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(icon: Icons.badge_rounded, label: tr[Tr.nidNumber], value: member['nid'] ?? 'N/A'),
                            const SizedBox(height: 8),
                            _InfoRow(icon: Icons.category_rounded, label: tr[Tr.category], value: member['category'] ?? 'General'),
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.date_range_rounded, 
                              label: tr[Tr.joined], 
                              value: member['created_at'] != null 
                                ? member['created_at'].toString().split('T').first 
                                : 'Unknown'
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Adding a Loan action will come here in the future
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LedgerScreen(
                                    memberId: member['id'],
                                    memberName: member['name'] ?? 'Unknown',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.analytics_rounded, size: 18),
                            label: Text(tr[Tr.viewLedger]),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => IssueLoanDialog(member: member),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            icon: const Icon(Icons.credit_score_rounded, size: 18),
                            label: Text(tr[Tr.addLoan]),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        Expanded(child: Text(value, style: TextStyle(color: color))),
      ],
    );
  }
}
