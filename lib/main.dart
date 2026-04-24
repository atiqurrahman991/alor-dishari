import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/translation_provider.dart';
import 'core/widgets/auth_checker.dart';

// ─────────────────────────────────────────────────────────────
//  ⚠️  আপনার Supabase credentials এখানে বসান
//  Supabase Dashboard → Project Settings → API
// ─────────────────────────────────────────────────────────────
const String _supabaseUrl     = 'https://mrkbncthlqldvpuwycvb.supabase.co';
const String _supabaseAnonKey = 'sb_publishable_TB3B_cfeBfJXQXeaYAn8JA_ytVWE6d7';

// Global shorthand  →  supabase.from('members').select()
SupabaseClient get supabase => Supabase.instance.client;

// ─────────────────────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Supabase
  await Supabase.initialize(
    url:     _supabaseUrl,
    anonKey: _supabaseAnonKey,
    debug:   true, // false করুন production এ
  );

  // Load persisted preferences
  final savedTheme    = await loadSavedTheme();
  final savedLanguage = await loadSavedLanguage();

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((_) => ThemeNotifier(savedTheme)),
        languageProvider.overrideWith((_) => LanguageNotifier(savedLanguage)),
      ],
      child: const AlorDishariApp(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  ROOT APP
// ─────────────────────────────────────────────────────────────
class AlorDishariApp extends ConsumerWidget {
  const AlorDishariApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title:                      'আলোর দিশারী',
      debugShowCheckedModeBanner: false,
      theme:     lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home:      const AuthChecker(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SETUP PREVIEW — Theme & Language toggle test screen
// ─────────────────────────────────────────────────────────────
class _SetupPreviewScreen extends ConsumerWidget {
  const _SetupPreviewScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final langNotifier  = ref.read(languageProvider.notifier);
    final isDark        = ref.watch(themeModeProvider) == ThemeMode.dark;
    final tr            = ref.watch(translationProvider);
    final cs            = Theme.of(context).colorScheme;
    final tt            = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr[Tr.appName]),
        actions: [
          IconButton(
            tooltip:  tr[Tr.switchLanguage],
            icon:     const Icon(Icons.translate_rounded),
            onPressed: langNotifier.toggle,
          ),
          IconButton(
            tooltip:  isDark ? tr[Tr.lightMode] : tr[Tr.darkMode],
            icon:     Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: themeNotifier.toggle,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status Card ──────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 56, color: cs.primary),
                    const SizedBox(height: 12),
                    Text('Setup Complete! ✅',
                        style: tt.headlineMedium,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      'Supabase • Riverpod • Theme • i18n',
                      style: tt.bodyMedium?.copyWith(color: cs.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Translation Preview ──────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Translation Preview',
                        style: tt.titleLarge?.copyWith(color: cs.primary)),
                    const Divider(height: 24),
                    _TrRow(label: tr[Tr.dashboard],        key_: Tr.dashboard),
                    _TrRow(label: tr[Tr.members],          key_: Tr.members),
                    _TrRow(label: tr[Tr.savings],          key_: Tr.savings),
                    _TrRow(label: tr[Tr.loans],            key_: Tr.loans),
                    _TrRow(label: tr[Tr.totalLoan],        key_: Tr.totalLoan),
                    _TrRow(label: tr[Tr.totalSavings],     key_: Tr.totalSavings),
                    _TrRow(label: tr[Tr.activeLoans],      key_: Tr.activeLoans),
                    _TrRow(label: tr[Tr.monthlyCollection],key_: Tr.monthlyCollection),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Button Samples ───────────────────────────────
            ElevatedButton.icon(
              onPressed: () {},
              icon:  const Icon(Icons.person_add_rounded),
              label: Text(tr[Tr.addMember]),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon:  const Icon(Icons.savings_rounded),
              label: Text(tr[Tr.addSavings]),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon:  const Icon(Icons.account_balance_rounded),
              label: Text(tr[Tr.addLoan]),
            ),
            const SizedBox(height: 32),

            // ── Info Box ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '⚠️  main.dart এ YOUR_SUPABASE_URL ও YOUR_SUPABASE_ANON_KEY '
                'বসান Supabase Dashboard → Settings → API থেকে।',
                style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HELPER WIDGET
// ─────────────────────────────────────────────────────────────
class _TrRow extends StatelessWidget {
  final String label;
  final Tr key_;
  const _TrRow({required this.label, required this.key_});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.arrow_right_rounded,
              size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
