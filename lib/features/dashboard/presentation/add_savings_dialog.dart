import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/translation_provider.dart';
import '../providers/dashboard_provider.dart';

class AddSavingsDialog extends ConsumerStatefulWidget {
  const AddSavingsDialog({super.key});

  @override
  ConsumerState<AddSavingsDialog> createState() => _AddSavingsDialogState();
}

class _AddSavingsDialogState extends ConsumerState<AddSavingsDialog> {
  final _amountController = TextEditingController();
  final _trxIdController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedMonth = 'January 2026';
  String _selectedMethod = 'Cash';
  bool _isLoading = false;

  final _months = [
    'January 2026', 'February 2026', 'March 2026', 'April 2026',
    'May 2026', 'June 2026', 'July 2026', 'August 2026',
    'September 2026', 'October 2026', 'November 2026', 'December 2026'
  ];
  final _methods = ['Cash', 'bKash', 'Nagad', 'Bank Transfer'];

  @override
  void dispose() {
    _amountController.dispose();
    _trxIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text);
      await ref.read(actionProvider).submitSavings(
        amount: amount,
        month: _selectedMonth,
        method: _selectedMethod,
        trxId: _trxIdController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(translationProvider)[Tr.depositRequested]),
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
          Icon(Icons.monetization_on_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(tr[Tr.addSavings]),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'সঞ্চয় জমা দেওয়ার জন্য অর্থের পরিমাণ লিখুন। অ্যাডমিন কর্তৃক অনুমোদিত হলে তা আপনার অ্যাকাউন্টে যোগ হবে।',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMonth,
              decoration: InputDecoration(
                labelText: 'মাসের নাম',
                prefixIcon: const Icon(Icons.calendar_month_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _selectedMonth = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: InputDecoration(
                labelText: 'পেমেন্ট মাধ্যম',
                prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _methods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _selectedMethod = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: tr[Tr.depositAmount],
                prefixIcon: const Icon(Icons.attach_money_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                if (double.tryParse(val) == null) return 'Invalid Number';
                if (double.parse(val) <= 0) return 'Must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (_selectedMethod != 'Cash') ...[
              TextFormField(
                controller: _trxIdController,
                decoration: InputDecoration(
                  labelText: 'Transaction ID (TrxID)',
                  prefixIcon: const Icon(Icons.tag_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'নোট বা মন্তব্য (ঐচ্ছিক)',
                prefixIcon: const Icon(Icons.notes_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
