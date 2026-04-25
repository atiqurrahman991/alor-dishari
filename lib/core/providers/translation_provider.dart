import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'language_provider.dart';

enum Tr {
  // Auth
  appName, login, logout, email, password, forgotPassword, loginButton, welcomeBack,
  signUp, signUpButton, dontHaveAccount, alreadyHaveAccount,
  // Navigation
  dashboard, members, savings, loans, installments, reports, settings,
  investments, returns, // Adding missing enum members
  // Dashboard
  totalMembers, totalSavings, totalInvestment, totalOutstanding, activeInvestments, monthlyCollection,
  totalLoan, activeLoans, // Restoring for compatibility
  // Members
  addMember, editMember, deleteMember, memberName, mobileNumber, nidNumber,
  category, address, nomineeName, memberDetails, memberList,
  // Savings
  addSavings, depositAmount, depositDate, savingsHistory, totalDeposits,
  // Loans
  addInvestment, totalInvestmentAmount, outstandingAmount, returnAmount, investmentStatus, active, closed,
  addLoan, loanIssuedSuccess, investmentIssuedSuccess, // Adding missing and restoring
  // Installments
  addReturn, paidAmount, lateFine, paymentDate, returnHistory,
  addInstallment, // Restoring
  // Common
  save, cancel, delete, edit, search, filter, refresh, loading, noData,
  success, error, confirm, yes, no, date, amount, name, submit, back, next, close, notes,
  // Settings
  language, theme, darkMode, lightMode, switchLanguage, switchTheme, appVersion, privacyPolicy,
  // New UI Elements
  hello, administrator, quickActions, pendingApprovals, noPending, approve, 
  joined, viewLedger, issuingLoanFor, noMembersFound, depositRequested, 
  errorLoading,
  // Profit Distribution
  distributeProfit, profitShare, totalProfitAmount, periodName, eligibleSavings,
}

const Map<Tr, Map<String, String>> _translations = {
  Tr.appName:            {'en': 'Alor Dishari',       'bn': 'আলোর দিশারী'},
  Tr.login:              {'en': 'Login',               'bn': 'লগইন'},
  Tr.logout:             {'en': 'Logout',              'bn': 'লগআউট'},
  Tr.email:              {'en': 'Email',               'bn': 'ইমেইল'},
  Tr.password:           {'en': 'Password',            'bn': 'পাসওয়ার্ড'},
  Tr.forgotPassword:     {'en': 'Forgot Password?',    'bn': 'পাসওয়ার্ড ভুলে গেছেন?'},
  Tr.loginButton:        {'en': 'Sign In',             'bn': 'প্রবেশ করুন'},
  Tr.signUp:             {'en': 'Sign Up',             'bn': 'নিবন্ধন করুন'},
  Tr.signUpButton:       {'en': 'Create Account',      'bn': 'অ্যাকাউন্ট তৈরি করুন'},
  Tr.dontHaveAccount:    {'en': 'Don\'t have an account?', 'bn': 'অ্যাকাউন্ট নেই?'},
  Tr.alreadyHaveAccount: {'en': 'Already have an account?', 'bn': 'অ্যাকাউন্ট আছে?'},
  Tr.welcomeBack:        {'en': 'Welcome Back!',       'bn': 'স্বাগতম!'},
  Tr.dashboard:          {'en': 'Dashboard',           'bn': 'ড্যাশবোর্ড'},
  Tr.members:            {'en': 'Members',             'bn': 'সদস্য'},
  Tr.savings:            {'en': 'Savings',             'bn': 'সঞ্চয়'},
  Tr.investments:        {'en': 'Investments',         'bn': 'বিনিয়োগ'},
  Tr.returns:            {'en': 'Returns',             'bn': 'ফেরত/কিস্তি'},
  Tr.reports:            {'en': 'Reports',             'bn': 'রিপোর্ট'},
  Tr.settings:           {'en': 'Settings',            'bn': 'সেটিংস'},
  Tr.totalMembers:       {'en': 'Total Members',       'bn': 'মোট সদস্য'},
  Tr.totalSavings:       {'en': 'Total Savings',       'bn': 'মোট সঞ্চয়'},
  Tr.totalInvestment:    {'en': 'Total Investment',    'bn': 'মোট বিনিয়োগ'},
  Tr.totalOutstanding:   {'en': 'Total Outstanding',   'bn': 'মোট বকেয়া'},
  Tr.activeInvestments:  {'en': 'Active Investments',  'bn': 'সক্রিয় বিনিয়োগ'},
  Tr.monthlyCollection:  {'en': 'Monthly Collection',  'bn': 'মাসিক আদায়'},
  Tr.addMember:          {'en': 'Add Member',          'bn': 'সদস্য যোগ করুন'},
  Tr.editMember:         {'en': 'Edit Member',         'bn': 'সদস্য সম্পাদনা'},
  Tr.deleteMember:       {'en': 'Delete Member',       'bn': 'সদস্য মুছুন'},
  Tr.memberName:         {'en': 'Member Name',         'bn': 'সদস্যের নাম'},
  Tr.mobileNumber:       {'en': 'Mobile Number',       'bn': 'মোবাইল নম্বর'},
  Tr.nidNumber:          {'en': 'NID Number',          'bn': 'জাতীয় পরিচয়পত্র নম্বর'},
  Tr.category:           {'en': 'Category',            'bn': 'শ্রেণী'},
  Tr.address:            {'en': 'Address',             'bn': 'ঠিকানা'},
  Tr.nomineeName:        {'en': 'Nominee Name',        'bn': 'নমিনির নাম'},
  Tr.memberDetails:      {'en': 'Member Details',      'bn': 'সদস্যের বিবরণ'},
  Tr.memberList:         {'en': 'Member List',         'bn': 'সদস্য তালিকা'},
  Tr.addSavings:         {'en': 'Add Savings',         'bn': 'সঞ্চয় যোগ করুন'},
  Tr.depositAmount:      {'en': 'Deposit Amount',      'bn': 'জমার পরিমাণ'},
  Tr.depositDate:        {'en': 'Deposit Date',        'bn': 'জমার তারিখ'},
  Tr.savingsHistory:     {'en': 'Savings History',     'bn': 'সঞ্চয়ের ইতিহাস'},
  Tr.totalDeposits:      {'en': 'Total Deposits',      'bn': 'মোট জমা'},
  Tr.addInvestment:      {'en': 'Add Investment',      'bn': 'বিনিয়োগ করুন'},
  Tr.totalInvestmentAmount:{'en': 'Total Invested',     'bn': 'মোট বিনিয়োগের পরিমাণ'},
  Tr.outstandingAmount:  {'en': 'Outstanding Amount',  'bn': 'বকেয়া পরিমাণ'},
  Tr.returnAmount:       {'en': 'Return Amount',       'bn': 'কিস্তির পরিমাণ'},
  Tr.investmentStatus:   {'en': 'Investment Status',   'bn': 'বিনিয়োগের অবস্থা'},
  Tr.active:             {'en': 'Active',              'bn': 'সক্রিয়'},
  Tr.closed:             {'en': 'Closed',              'bn': 'বন্ধ'},
  Tr.addReturn:          {'en': 'Add Return',          'bn': 'কিস্তি জমা'},
  Tr.paidAmount:         {'en': 'Paid Amount',         'bn': 'পরিশোধিত পরিমাণ'},
  Tr.lateFine:           {'en': 'Late Fine',           'bn': 'বিলম্ব জরিমানা'},
  Tr.paymentDate:        {'en': 'Payment Date',        'bn': 'পরিশোধের তারিখ'},
  Tr.returnHistory:      {'en': 'Return History',      'bn': 'কিস্তির ইতিহাস'},
  Tr.save:               {'en': 'Save',                'bn': 'সংরক্ষণ করুন'},
  Tr.cancel:             {'en': 'Cancel',              'bn': 'বাতিল'},
  Tr.delete:             {'en': 'Delete',              'bn': 'মুছুন'},
  Tr.edit:               {'en': 'Edit',                'bn': 'সম্পাদনা'},
  Tr.search:             {'en': 'Search',              'bn': 'অনুসন্ধান'},
  Tr.filter:             {'en': 'Filter',              'bn': 'ফিল্টার'},
  Tr.refresh:            {'en': 'Refresh',             'bn': 'রিফ্রেশ'},
  Tr.loading:            {'en': 'Loading...',          'bn': 'লোড হচ্ছে...'},
  Tr.noData:             {'en': 'No data found',       'bn': 'কোনো তথ্য পাওয়া যায়নি'},
  Tr.success:            {'en': 'Success',             'bn': 'সফল হয়েছে'},
  Tr.error:              {'en': 'Error',               'bn': 'ত্রুটি'},
  Tr.confirm:            {'en': 'Confirm',             'bn': 'নিশ্চিত করুন'},
  Tr.yes:                {'en': 'Yes',                 'bn': 'হ্যাঁ'},
  Tr.no:                 {'en': 'No',                  'bn': 'না'},
  Tr.date:               {'en': 'Date',                'bn': 'তারিখ'},
  Tr.amount:             {'en': 'Amount',              'bn': 'পরিমাণ'},
  Tr.name:               {'en': 'Name',                'bn': 'নাম'},
  Tr.submit:             {'en': 'Submit',              'bn': 'জমা দিন'},
  Tr.back:               {'en': 'Back',                'bn': 'পিছনে'},
  Tr.next:               {'en': 'Next',                'bn': 'পরবর্তী'},
  Tr.close:              {'en': 'Close',               'bn': 'বন্ধ করুন'},
  Tr.notes:              {'en': 'Notes',               'bn': 'নোট'},
  Tr.language:           {'en': 'Language',            'bn': 'ভাষা'},
  Tr.theme:              {'en': 'Theme',               'bn': 'থিম'},
  Tr.darkMode:           {'en': 'Dark Mode',           'bn': 'ডার্ক মোড'},
  Tr.lightMode:          {'en': 'Light Mode',          'bn': 'লাইট মোড'},
  Tr.switchLanguage:     {'en': 'Switch to বাংলা',    'bn': 'Switch to English'},
  Tr.switchTheme:        {'en': 'Switch Theme',        'bn': 'থিম পরিবর্তন করুন'},
  Tr.appVersion:         {'en': 'App Version',         'bn': 'অ্যাপ ভার্সন'},
  Tr.privacyPolicy:       {'en': 'Privacy Policy',      'bn': 'গোপনীয়তা নীতি'},
  Tr.hello:              {'en': 'Hello',               'bn': 'হ্যালো'},
  Tr.administrator:      {'en': 'ADMINISTRATOR',       'bn': 'অ্যাডমিনিস্ট্রেটর'},
  Tr.quickActions:       {'en': 'Quick Actions',       'bn': 'কুইক অ্যাকশন'},
  Tr.pendingApprovals:   {'en': 'Pending Approvals',   'bn': 'অপেক্ষমাণ অনুমোদন'},
  Tr.noPending:          {'en': 'Great! No pending requests.', 'bn': 'চমৎকার! কোনো রিকোয়েস্ট অপেক্ষমাণ নেই।'},
  Tr.approve:            {'en': 'Approve',             'bn': 'অনুমোদন দিন'},
  Tr.joined:             {'en': 'Joined',              'bn': 'যোগদান'},
  Tr.viewLedger:         {'en': 'View Ledger',         'bn': 'হিসাব দেখুন'},
  Tr.issuingLoanFor:     {'en': 'Issuing investment for', 'bn': 'বিনিয়োগ প্রদান করা হচ্ছে:'},
  Tr.noMembersFound:     {'en': 'No members found.',   'bn': 'কোনো সদস্য পাওয়া যায়নি।'},
  Tr.depositRequested:   {'en': 'Deposit requested! Waiting for admin.', 'bn': 'জমার রিকোয়েস্ট পাঠানো হয়েছে! অ্যাডমিনের অনুমোদনের অপেক্ষায়।'},
  Tr.investmentIssuedSuccess: {'en': 'Successfully issued investment', 'bn': 'সফলভাবে বিনিয়োগ প্রদান করা হয়েছে'},
  Tr.loanIssuedSuccess:  {'en': 'Successfully issued investment', 'bn': 'সফলভাবে বিনিয়োগ প্রদান করা হয়েছে'},
  Tr.totalLoan:          {'en': 'Total Investment',    'bn': 'মোট বিনিয়োগ'},
  Tr.activeLoans:        {'en': 'Active Investments',  'bn': 'সক্রিয় বিনিয়োগ'},
  Tr.addLoan:            {'en': 'Add Investment',      'bn': 'বিনিয়োগ করুন'},
  Tr.addInstallment:     {'en': 'Add Return',          'bn': 'কিস্তি জমা'},
  Tr.errorLoading:       {'en': 'Error loading',       'bn': 'লোড করতে ত্রুটি হচ্ছে'},
  Tr.distributeProfit:   {'en': 'Distribute Profit',   'bn': 'লভ্যাংশ বিতরণ'},
  Tr.profitShare:        {'en': 'Profit Share',        'bn': 'লভ্যাংশ'},
  Tr.totalProfitAmount:  {'en': 'Total Profit Amount', 'bn': 'মোট লভ্যাংশের পরিমাণ'},
  Tr.periodName:         {'en': 'Period Name',         'bn': 'সময়ের নাম (মাস/বছর)'},
  Tr.eligibleSavings:    {'en': 'Eligible Savings',    'bn': 'যোগ্য সঞ্চয়'},
};

class TranslationService {
  final AppLanguage language;
  const TranslationService(this.language);

  String t(Tr key) {
    final map = _translations[key];
    if (map == null) return key.name;
    return map[language.code] ?? map['en'] ?? key.name;
  }

  String operator [](Tr key) => t(key);
}

final translationProvider = Provider<TranslationService>((ref) {
  final lang = ref.watch(languageProvider);
  return TranslationService(lang);
});
