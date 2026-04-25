import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('গোপনীয়তা নীতি (Privacy Policy)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              theme,
              '১. তথ্য সংগ্রহ',
              'আমরা সদস্যদের নাম, মোবাইল নম্বর, জাতীয় পরিচয়পত্র নম্বর (NID) এবং মনোনীত ব্যক্তির (Nominee) তথ্য সংগ্রহ করি শুধুমাত্র সমিতির হিসাব রক্ষণাবেক্ষণের জন্য।',
            ),
            _buildSection(
              theme,
              '২. তথ্যের ব্যবহার',
              'সংগৃহীত তথ্যগুলো শুধুমাত্র আপনার সঞ্চয়, বিনিয়োগ এবং লভ্যাংশ ট্র্যাকিং করার জন্য ব্যবহার করা হয়। আপনার অনুমতি ছাড়া এই তথ্য অন্য কোনো কাজে ব্যবহার করা হবে না।',
            ),
            _buildSection(
              theme,
              '৩. নিরাপত্তা',
              'আপনার সকল তথ্য Supabase ক্লাউড ডাটাবেসে এনক্রিপ্টেড অবস্থায় সংরক্ষিত থাকে। আমরা সর্বোচ্চ গুরুত্ব দিয়ে তথ্যের নিরাপত্তা নিশ্চিত করি।',
            ),
            _buildSection(
              theme,
              '৪. তথ্য শেয়ারিং',
              'সমিতির কোনো সদস্যের ব্যক্তিগত তথ্য বাইরের কোনো ব্যক্তি বা প্রতিষ্ঠানের কাছে বিক্রি বা শেয়ার করা হয় না।',
            ),
            _buildSection(
              theme,
              '৫. যোগাযোগ',
              'প্রাইভেসি পলিসি সংক্রান্ত যেকোনো প্রশ্ন বা অভিযোগের জন্য সমিতির অ্যাডমিনের সাথে যোগাযোগ করুন।',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'সর্বশেষ আপডেট: এপ্রিল ২০২৬',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
