import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/translation_provider.dart';
import '../providers/members_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class IssueLoanDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> member;

  const IssueLoanDialog({super.key, required this.member});

  @override
  ConsumerState<IssueLoanDialog> createState() => _IssueLoanDialogState();
}

class _IssueLoanDialogState extends ConsumerState<IssueLoanDialog> {
  final _amountController = TextEditingController();
  final _installmentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _installmentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text);
      final installment = double.parse(_installmentController.text);

      await ref.read(memberActionProvider).issueLoan(
        memberId: widget.member['id'],
        amount: amount,
        installmentAmount: installment,
      );

      // Invalidate dashboard to reflect the new active loan
      ref.invalidate(dashboardStatsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ref.read(translationProvider)[Tr.loanIssuedSuccess]} ${widget.member['name']}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ref.read(translationProvider)[Tr.error]}: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = ref.watch(translationProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.credit_score_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(tr[Tr.addLoan]),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tr[Tr.issuingLoanFor]} ${widget.member['name']}',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: tr[Tr.totalLoanAmount],
                prefixIcon: const Icon(Icons.account_balance_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                if (double.tryParse(val) == null) return 'Invalid Number';
                if (double.parse(val) <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _installmentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: tr[Tr.installmentAmount],
                prefixIcon: const Icon(Icons.receipt_long_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                if (double.tryParse(val) == null) return 'Invalid Number';
                if (double.parse(val) <= 0) return 'Must be > 0';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(tr[Tr.cancel]),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(tr[Tr.submit]),
        ),
      ],
    );
  }
}
