import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/translation_provider.dart';
import '../providers/profit_distribution_provider.dart';

class DistributeProfitDialog extends ConsumerStatefulWidget {
  const DistributeProfitDialog({super.key});

  @override
  ConsumerState<DistributeProfitDialog> createState() => _DistributeProfitDialogState();
}

class _DistributeProfitDialogState extends ConsumerState<DistributeProfitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _periodController = TextEditingController();
  final _profitController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _periodController.dispose();
    _profitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final period = _periodController.text.trim();
      final profit = double.parse(_profitController.text.trim());
      final notes = _notesController.text.trim();

      await ref.read(profitDistributionProvider).distributeProfit(
        periodName: period,
        totalProfit: profit,
        notes: notes.isNotEmpty ? notes : null,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profit distributed successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationProvider);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(tr[Tr.distributeProfit]),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _periodController,
                decoration: InputDecoration(
                  labelText: tr[Tr.periodName],
                  hintText: 'e.g. April 2024',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _profitController,
                decoration: InputDecoration(
                  labelText: tr[Tr.totalProfitAmount],
                  prefixText: '৳ ',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: tr[Tr.notes],
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
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(tr[Tr.submit]),
        ),
      ],
    );
  }
}
