import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App Name
      'appName': 'Hishab',
      'appTagline': 'Track Your Expenses',

      // Greetings
      'goodMorning': 'Good Morning',
      'goodAfternoon': 'Good Afternoon',
      'goodEvening': 'Good Evening',
      'hello': 'Hello',

      // Navigation
      'home': 'Home',
      'expenses': 'Expenses',
      'categories': 'Categories',
      'settings': 'Settings',
      'profile': 'Profile',
      'analytics': 'Analytics',
      'budget': 'Budget',
      'rewards': 'Rewards',

      // Common Actions
      'add': 'Add',
      'edit': 'Edit',
      'delete': 'Delete',
      'save': 'Save',
      'cancel': 'Cancel',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'close': 'Close',
      'done': 'Done',
      'continue': 'Continue',
      'skip': 'Skip',
      'next': 'Next',
      'back': 'Back',

      // Expense Related
      'addExpense': 'Add Expense',
      'expense': 'Expense',
      'income': 'Income',
      'amount': 'Amount',
      'description': 'Description',
      'category': 'Category',
      'date': 'Date',
      'todaySpending': 'Today\'s Spending',
      'thisWeek': 'This Week',
      'thisMonth': 'This Month',
      'dailyAllowance': 'Daily Allowance',
      'monthlyIncome': 'Monthly Income',
      'totalExpenses': 'Total Expenses',
      'recentExpenses': 'Recent Expenses',
      'noExpenses': 'No expenses yet',
      'expenseAdded': 'Expense added successfully',
      'expenseDeleted': 'Expense deleted',
      'expenseUpdated': 'Expense updated',

      // Budget Related
      'budgetTracking': 'Budget Tracking',
      'dailyBudget': 'Daily Budget',
      'monthlyBudget': 'Monthly Budget',
      'daysRemaining': 'days remaining',
      'overBudget': 'Over Budget',
      'withinBudget': 'Within Budget',
      'budgetStatus': 'Budget Status',

      // Voice
      'voiceExpense': 'Voice Expense',
      'tapToSpeak': 'Tap to speak',
      'listening': 'Listening...',
      'speechNotAvailable': 'Speech recognition not available',
      'couldNotUnderstand': 'Could not understand',
      'example': 'Example',
      'manualEntry': 'Manual Entry',

      // Rewards
      'rewardPoints': 'Reward Points',
      'yourPoints': 'Your Points',
      'pointsEarned': 'Points Earned',
      'redeem': 'Redeem',
      'howToEarn': 'How to Earn Points',
      'earnByAddingExpense': 'Add Expense',
      'earnByBudgetGoal': 'Meet Budget Goal',
      'earnByConsistency': 'Weekly Consistency',
      'redeemReward': 'Redeem Reward',
      'redeemSuccess': 'Reward redeemed successfully',
      'redeemFailed': 'Redemption failed',
      'insufficientPoints': 'Insufficient points',

      // Settings
      'darkMode': 'Dark Mode',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      'language': 'Language',
      'selectLanguage': 'Select Language',
      'languageChanged': 'Language changed successfully',
      'editIncome': 'Edit Income',
      'incomeUpdated': 'Income updated successfully',
      'manageCategories': 'Manage Categories',
      'addCategory': 'Add Category',
      'categoryName': 'Category Name',
      'selectIcon': 'Select Icon',
      'selectColor': 'Select Color',
      'categoryAdded': 'Category added successfully',
      'clearAllData': 'Clear All Data',
      'clearDataWarning': 'This will delete all your expenses and income data. Categories will be reset to defaults.',
      'clearDataConfirm': 'Are you sure you want to delete all your data? This action cannot be undone.',
      'dataClearedSuccess': 'All data cleared',
      'about': 'About',
      'version': 'Version',
      'appDescription': 'A simple and elegant finance tracking app to help you manage your daily expenses.',

      // User Profile
      'name': 'Name',
      'updateName': 'Update Name',
      'yourName': 'Your Name',
      'nameUpdated': 'Name updated successfully',
      'nameCleared': 'Name cleared',
      'notSet': 'Not set',

      // Premium
      'premium': 'Premium',
      'free': 'Free',
      'upgradeToPremium': 'Upgrade to Premium',
      'premiumActive': 'Premium Active',
      'subscribeToPremium': 'Subscribe to Premium',
      'subscriptionCost': 'Only ৳2/day',
      'premiumFeatures': 'Premium Features',
      'cloudSync': 'Cloud Sync',
      'advancedAnalytics': 'Advanced Analytics',
      'rewardRedemption': 'Reward Redemption',
      'smartAssistant': 'Smart Assistant',
      'startNow': 'Start Now',
      'cancelSubscription': 'Cancel Subscription',

      // Onboarding
      'welcome': 'Welcome',
      'getStarted': 'Get Started',
      'setupIncome': 'Setup Income',
      'setupName': 'What\'s your name?',
      'enterName': 'Enter your name',
      'enterIncome': 'Enter monthly income',

      // Analytics
      'quickStats': 'Quick Stats',
      'spending': 'Spending',
      'remaining': 'Remaining',
      'spent': 'Spent',
      'topCategory': 'Top Category',
      'categoryBreakdown': 'Category Breakdown',

      // Time
      'today': 'Today',
      'yesterday': 'Yesterday',

      // Status Messages
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'networkError': 'Network error occurred',
      'generalError': 'Something went wrong',

      // Data Management
      'personal': 'Personal',
      'appearance': 'Appearance',
      'financialSettings': 'Financial Settings',
      'dataManagement': 'Data Management',

      // Categories
      'categoryFood': 'Food',
      'categoryTransport': 'Transport',
      'categoryShopping': 'Shopping',
      'categoryBills': 'Bills',
      'categoryEntertainment': 'Entertainment',
      'categoryHealth': 'Health',
      'categoryOther': 'Other',

      // Voice Expense
      'voiceExpense': 'Voice Expense',
      'listening': 'Listening...',
      'tapToSpeak': 'Tap to Speak',
      'voiceInstructions': 'Say something like "500 for groceries" or "200 books"',
      'heard': 'I heard',
      'understood': 'Understood',
      'notDetected': 'Not detected',
      'selectCategory': 'Please select a category',
      'pleaseSelectCategory': 'Please select a category',
      'microphoneNotAvailable': 'Microphone not available',
      'saveExpense': 'Save Expense',

      // Chatbot
      'chatbot': 'Finbro Assistant',
      'askMeAnything': 'Ask me about your expenses...',
      'exampleQuestions': 'Example questions',
      'biggestExpense': 'What was my biggest expense?',
      'monthlySpend': 'How much did I spend this month?',
      'canISpend': 'Can I spend 500 today?',
      'spendingTrend': 'Am I spending more than last month?',
    },
    'bn': {
      // App Name
      'appName': 'হিসাব',
      'appTagline': 'আপনার খরচ ট্র্যাক করুন',

      // Greetings
      'goodMorning': 'সুপ্রভাত',
      'goodAfternoon': 'শুভ অপরাহ্ন',
      'goodEvening': 'শুভ সন্ধ্যা',
      'hello': 'হ্যালো',

      // Navigation
      'home': 'হোম',
      'expenses': 'খরচ',
      'categories': 'ক্যাটাগরি',
      'settings': 'সেটিংস',
      'profile': 'প্রোফাইল',
      'analytics': 'বিশ্লেষণ',
      'budget': 'বাজেট',
      'rewards': 'রিওয়ার্ড',

      // Common Actions
      'add': 'যোগ করুন',
      'edit': 'সম্পাদনা করুন',
      'delete': 'মুছে ফেলুন',
      'save': 'সংরক্ষণ করুন',
      'cancel': 'বাতিল',
      'ok': 'ঠিক আছে',
      'yes': 'হ্যাঁ',
      'no': 'না',
      'close': 'বন্ধ করুন',
      'done': 'সম্পন্ন',
      'continue': 'এগিয়ে যান',
      'skip': 'এড়িয়ে যান',
      'next': 'পরবর্তী',
      'back': 'ফিরে যান',

      // Expense Related
      'addExpense': 'খরচ যোগ করুন',
      'expense': 'খরচ',
      'income': 'আয়',
      'amount': 'পরিমাণ',
      'description': 'বিবরণ',
      'category': 'ক্যাটাগরি',
      'date': 'তারিখ',
      'todaySpending': 'আজকের খরচ',
      'thisWeek': 'এই সপ্তাহ',
      'thisMonth': 'এই মাস',
      'dailyAllowance': 'দৈনিক বাজেট',
      'monthlyIncome': 'মাসিক আয়',
      'totalExpenses': 'মোট খরচ',
      'recentExpenses': 'সাম্প্রতিক খরচ',
      'noExpenses': 'কোনো খরচ নেই',
      'expenseAdded': 'খরচ যোগ করা হয়েছে',
      'expenseDeleted': 'খরচ মুছে ফেলা হয়েছে',
      'expenseUpdated': 'খরচ আপডেট হয়েছে',

      // Budget Related
      'budgetTracking': 'বাজেট ট্র্যাকিং',
      'dailyBudget': 'আজকের বাজেট',
      'monthlyBudget': 'মাসিক বাজেট',
      'daysRemaining': 'দিন বাকি',
      'overBudget': 'বাজেট অতিক্রম',
      'withinBudget': 'ভালো আছেন',
      'budgetStatus': 'বাজেট স্ট্যাটাস',

      // Voice
      'voiceExpense': 'ভয়েস খরচ',
      'tapToSpeak': 'মাইক টিপে বলুন',
      'listening': 'শুনছি...',
      'speechNotAvailable': 'স্পিচ রিকগনিশন উপলব্ধ নেই',
      'couldNotUnderstand': 'খরচ বুঝতে পারিনি',
      'example': 'উদাহরণ',
      'manualEntry': 'ম্যানুয়ালি যোগ করুন',

      // Rewards
      'rewardPoints': 'রিওয়ার্ড পয়েন্ট',
      'yourPoints': 'আপনার পয়েন্ট',
      'pointsEarned': 'পয়েন্ট অর্জিত',
      'redeem': 'রিডিম',
      'howToEarn': 'কিভাবে পয়েন্ট পাবেন',
      'earnByAddingExpense': 'খরচ যোগ করুন',
      'earnByBudgetGoal': 'বাজেট লক্ষ্য পূরণ',
      'earnByConsistency': 'সাপ্তাহিক ধারাবাহিকতা',
      'redeemReward': 'রিওয়ার্ড রিডিম করুন',
      'redeemSuccess': 'রিওয়ার্ড রিডিম করা হয়েছে',
      'redeemFailed': 'রিডিম ব্যর্থ হয়েছে',
      'insufficientPoints': 'পর্যাপ্ত পয়েন্ট নেই',

      // Settings
      'darkMode': 'ডার্ক মোড',
      'enabled': 'সক্রিয়',
      'disabled': 'নিষ্ক্রিয়',
      'language': 'ভাষা',
      'selectLanguage': 'ভাষা নির্বাচন করুন',
      'languageChanged': 'ভাষা পরিবর্তন হয়েছে',
      'editIncome': 'আয় সম্পাদনা করুন',
      'incomeUpdated': 'আয় আপডেট হয়েছে',
      'manageCategories': 'ক্যাটাগরি পরিচালনা করুন',
      'addCategory': 'ক্যাটাগরি যোগ করুন',
      'categoryName': 'ক্যাটাগরি নাম',
      'selectIcon': 'আইকন নির্বাচন করুন',
      'selectColor': 'রঙ নির্বাচন করুন',
      'categoryAdded': 'ক্যাটাগরি যোগ করা হয়েছে',
      'clearAllData': 'সব ডেটা মুছে ফেলুন',
      'clearDataWarning': 'এটি আপনার সমস্ত খরচ এবং আয়ের ডেটা মুছে ফেলবে। ক্যাটাগরি ডিফল্টে রিসেট হবে।',
      'clearDataConfirm': 'আপনি কি নিশ্চিত যে আপনি আপনার সব ডেটা মুছে ফেলতে চান? এই কাজ পূর্বাবস্থায় ফেরানো যাবে না।',
      'dataClearedSuccess': 'সব ডেটা মুছে ফেলা হয়েছে',
      'about': 'সম্পর্কে',
      'version': 'সংস্করণ',
      'appDescription': 'আপনার দৈনন্দিন খরচ পরিচালনা করতে সাহায্য করার জন্য একটি সহজ এবং মার্জিত অর্থ ট্র্যাকিং অ্যাপ।',

      // User Profile
      'name': 'নাম',
      'updateName': 'নাম আপডেট করুন',
      'yourName': 'আপনার নাম',
      'nameUpdated': 'নাম আপডেট হয়েছে',
      'nameCleared': 'নাম মুছে ফেলা হয়েছে',
      'notSet': 'সেট করা নেই',

      // Premium
      'premium': 'প্রিমিয়াম',
      'free': 'ফ্রি',
      'upgradeToPremium': 'প্রিমিয়ামে আপগ্রেড করুন',
      'premiumActive': 'প্রিমিয়াম সক্রিয়',
      'subscribeToPremium': 'প্রিমিয়ামে সাবস্ক্রাইব করুন',
      'subscriptionCost': 'শুধু ৳২/দিন',
      'premiumFeatures': 'প্রিমিয়াম ফিচার',
      'cloudSync': 'ক্লাউড সিঙ্ক',
      'advancedAnalytics': 'অ্যাডভান্সড অ্যানালিটিক্স',
      'rewardRedemption': 'রিওয়ার্ড রিডেম্পশন',
      'smartAssistant': 'স্মার্ট অ্যাসিস্ট্যান্ট',
      'startNow': 'এখনই শুরু করুন',
      'cancelSubscription': 'সাবস্ক্রিপশন বাতিল করুন',

      // Onboarding
      'welcome': 'স্বাগতম',
      'getStarted': 'শুরু করুন',
      'setupIncome': 'আয় সেটআপ করুন',
      'setupName': 'আপনার নাম কি?',
      'enterName': 'আপনার নাম লিখুন',
      'enterIncome': 'মাসিক আয় লিখুন',

      // Analytics
      'quickStats': 'দ্রুত পরিসংখ্যান',
      'spending': 'খরচ',
      'remaining': 'বাকি',
      'spent': 'খরচ হয়েছে',
      'topCategory': 'শীর্ষ ক্যাটাগরি',
      'categoryBreakdown': 'ক্যাটাগরি বিভাজন',

      // Time
      'today': 'আজ',
      'yesterday': 'গতকাল',

      // Status Messages
      'loading': 'লোড হচ্ছে...',
      'error': 'ত্রুটি',
      'success': 'সফল',
      'networkError': 'নেটওয়ার্ক সমস্যা হয়েছে',
      'generalError': 'কিছু ভুল হয়েছে',

      // Data Management
      'personal': 'ব্যক্তিগত',
      'appearance': 'চেহারা',
      'financialSettings': 'আর্থিক সেটিংস',
      'dataManagement': 'ডেটা ব্যবস্থাপনা',

      // Categories
      'categoryFood': 'খাবার',
      'categoryTransport': 'যাতায়াত',
      'categoryShopping': 'কেনাকাটা',
      'categoryBills': 'বিল',
      'categoryEntertainment': 'বিনোদন',
      'categoryHealth': 'স্বাস্থ্য',
      'categoryOther': 'অন্যান্য',

      // Voice Expense
      'voiceExpense': 'ভয়েস খরচ',
      'listening': 'শুনছি...',
      'tapToSpeak': 'বলতে ট্যাপ করুন',
      'voiceInstructions': '"৫০০ জন্য মুদি" বা "২০০ বই" এর মত কিছু বলুন',
      'heard': 'আমি শুনেছি',
      'understood': 'বুঝেছি',
      'notDetected': 'সনাক্ত করা যায়নি',
      'selectCategory': 'একটি ক্যাটাগরি নির্বাচন করুন',
      'pleaseSelectCategory': 'দয়া করে একটি ক্যাটাগরি নির্বাচন করুন',
      'microphoneNotAvailable': 'মাইক্রোফোন উপলব্ধ নেই',
      'saveExpense': 'খরচ সংরক্ষণ করুন',

      // Chatbot
      'chatbot': 'ফিনব্রো সহায়ক',
      'askMeAnything': 'আপনার খরচ সম্পর্কে জিজ্ঞাসা করুন...',
      'exampleQuestions': 'উদাহরণ প্রশ্ন',
      'biggestExpense': 'আমার সবচেয়ে বড় খরচ কি ছিল?',
      'monthlySpend': 'এই মাসে আমি কত খরচ করেছি?',
      'canISpend': 'আজ আমি ৫০০ টাকা খরচ করতে পারি?',
      'spendingTrend': 'আমি কি গত মাসের চেয়ে বেশি খরচ করছি?',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Translate category name
  String translateCategory(String categoryName) {
    final Map<String, String> categoryMapping = {
      'Food': 'categoryFood',
      'Transport': 'categoryTransport',
      'Shopping': 'categoryShopping',
      'Bills': 'categoryBills',
      'Entertainment': 'categoryEntertainment',
      'Health': 'categoryHealth',
      'Other': 'categoryOther',
    };

    final translationKey = categoryMapping[categoryName];
    if (translationKey != null) {
      return translate(translationKey);
    }
    // For custom categories, return as-is
    return categoryName;
  }

  // Convenience getters
  String get appName => translate('appName');
  String get appTagline => translate('appTagline');
  String get home => translate('home');
  String get expenses => translate('expenses');
  String get categories => translate('categories');
  String get settings => translate('settings');
  String get addExpense => translate('addExpense');
  String get todaySpending => translate('todaySpending');
  String get dailyAllowance => translate('dailyAllowance');
  String get thisWeek => translate('thisWeek');
  String get thisMonth => translate('thisMonth');
  String get monthlyIncome => translate('monthlyIncome');
  String get darkMode => translate('darkMode');
  String get enabled => translate('enabled');
  String get disabled => translate('disabled');
  String get language => translate('language');
  String get save => translate('save');
  String get cancel => translate('cancel');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'bn'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
