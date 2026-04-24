import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/translation_provider.dart';
import '../providers/dashboard_provider.dart';

class WithdrawSavingsDialog extends ConsumerStatefulWidget {
  const WithdrawSavingsDialog({super.key});

  @override
  ConsumerState<WithdrawSavingsDialog> createState() => _WithdrawSavingsDialogState();
}

class _WithdrawSavingsDialogState extends ConsumerState<WithdrawSavingsDialog> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _trxIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedMethod = 'Cash';
  bool _isLoading = false;

  final List<String> _methods = ['Cash', 'bKash', 'Nagad', 'Bank Transfer'];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _trxIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text);
      
      await ref.read(actionProvider).requestWithdrawal(
        amount: amount,
        method: _selectedMethod,
        trxId: _trxIdController.text,
        notes: _notesController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('উত্তোলনের রিকোয়েস্ট সফলভাবে পাঠানো হয়েছে!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
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
          Icon(Icons.money_off_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          const Text('সঞ্চয় উত্তোলন'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: tr[Tr.amount],
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null) return 'Invalid Number';
                  if (double.parse(val) <= 0) return 'Must be > 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                items: _methods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) => setState(() => _selectedMethod = val!),
                decoration: const InputDecoration(
                  labelText: 'পেমেন্ট মাধ্যম',
                  prefixIcon: Icon(Icons.payment_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _trxIdController,
                decoration: const InputDecoration(
                  labelText: 'Transaction ID (Optional)',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: tr[Tr.notes],
                  prefixIcon: const Icon(Icons.note_rounded),
                ),
                maxLines: 2,
              ),
            ],
          ),
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
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('উত্তোলন করুন'),
        ),
      ],
    );
  }
}
