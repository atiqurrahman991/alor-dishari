import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../core/providers/translation_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _nidController = TextEditingController();
  final _addressController = TextEditingController();
  final _nomineeController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _nidController.dispose();
    _addressController.dispose();
    _nomineeController.dispose();
    super.dispose();
  }

  void _populateFields(Map<String, dynamic> profile) {
    _nameController.text = profile['name'] ?? '';
    _mobileController.text = profile['mobile'] ?? '';
    _nidController.text = profile['nid'] ?? '';
    _addressController.text = profile['address'] ?? '';
    _nomineeController.text = profile['nominee_name'] ?? '';
  }

  Future<void> _saveProfile(String memberId) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await supabase.from('members').update({
        'name': _nameController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'nid': _nidController.text.trim(),
        'address': _addressController.text.trim(),
        'nominee_name': _nomineeController.text.trim(),
      }).eq('id', memberId);

      ref.invalidate(currentUserProfileProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('প্রোফাইল সফলভাবে আপডেট হয়েছে!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isEditing = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = ref.watch(translationProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('আমার প্রোফাইল'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Edit Profile',
              onPressed: () => setState(() => _isEditing = true),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not found.'));
          }

          // Populate fields only when first loaded or after save
          if (!_isEditing && _nameController.text.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _populateFields(profile));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Avatar Section
                CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    (profile['name'] ?? 'U')[0].toUpperCase(),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile['name'] ?? '',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  profile['role'] == 'admin' ? 'অ্যাডমিন' : 'সদস্য',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(
                        controller: _nameController,
                        label: tr[Tr.memberName],
                        icon: Icons.person_rounded,
                        enabled: _isEditing,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _mobileController,
                        label: tr[Tr.mobileNumber],
                        icon: Icons.phone_rounded,
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _nidController,
                        label: tr[Tr.nidNumber],
                        icon: Icons.badge_rounded,
                        enabled: _isEditing,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _addressController,
                        label: tr[Tr.address],
                        icon: Icons.location_on_rounded,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _nomineeController,
                        label: tr[Tr.nomineeName],
                        icon: Icons.people_alt_rounded,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 32),
                      if (_isEditing)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : () {
                                  _populateFields(profile);
                                  setState(() => _isEditing = false);
                                },
                                child: Text(tr[Tr.cancel]),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : () => _saveProfile(profile['id']),
                                icon: _isLoading
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.save_rounded),
                                label: Text(tr[Tr.save]),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
      ),
    );
  }
}
