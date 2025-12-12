/// Example: How to use the Hishab Backend API Integration
///
/// This file demonstrates how to integrate the backend APIs
/// into your Flutter app screens.

import 'package:flutter/material.dart';
import '../services/dev_auth_service.dart';
import '../services/expense_api_service.dart';
import '../services/chatbot_api_service.dart';
import '../services/analytics_api_service.dart';
import '../models/expense.dart';

/// Example 1: User Registration and Login
class AuthExample {
  Future<void> registerUser() async {
    // Register a new user (dev mode - bypasses OTP)
    final result = await DevAuthService.devRegister(
      phoneNumber: '01712345678',
    );

    if (result['success']) {
      print('✅ Registration successful!');
      print('User ID: ${result['user']['id']}');
      print('Phone: ${result['user']['phone']}');
      print('JWT Token: ${result['token']}');

      // Token is automatically saved to SharedPreferences
      // You can retrieve it later using:
      String? savedToken = await DevAuthService.getSavedToken();
      print('Saved token: $savedToken');
    } else {
      print('❌ Registration failed: ${result['message']}');
    }
  }

  Future<void> loginUser() async {
    // Login existing user (dev mode)
    final result = await DevAuthService.devLogin(
      phoneNumber: '01712345678',
    );

    if (result['success']) {
      print('✅ Login successful!');
      print('JWT Token: ${result['token']}');
    } else {
      print('❌ Login failed: ${result['message']}');
    }
  }

  Future<void> checkLoginStatus() async {
    bool isLoggedIn = await DevAuthService.isLoggedIn();

    if (isLoggedIn) {
      final user = await DevAuthService.getSavedUser();
      print('✅ User is logged in');
      print('User: ${user?['phone']}');
    } else {
      print('❌ User is not logged in');
    }
  }

  Future<void> logout() async {
    await DevAuthService.clearAuthData();
    print('✅ Logged out successfully');
  }
}

/// Example 2: Expense Management
class ExpenseManagementExample {
  Future<void> createExpense() async {
    // Get saved token
    final token = await DevAuthService.getSavedToken();
    if (token == null) {
      print('❌ Not logged in. Please login first.');
      return;
    }

    // Create an expense
    final expense = await ExpenseApiService.createExpense(
      token: token,
      amount: 500.0,
      categoryId: 1, // Food category
      note: 'Lunch at restaurant',
    );

    if (expense != null) {
      print('✅ Expense created successfully!');
      print('ID: ${expense.id}');
      print('Amount: ${expense.amount}');
      print('Category: ${expense.category}');
      print('Note: ${expense.note}');
    } else {
      print('❌ Failed to create expense');
    }
  }

  Future<void> getAllExpenses() async {
    final token = await DevAuthService.getSavedToken();
    if (token == null) {
      print('❌ Not logged in');
      return;
    }

    try {
      final expenses = await ExpenseApiService.getAllExpenses(token: token);
      print('✅ Found ${expenses.length} expenses');

      for (var expense in expenses) {
        print('- ${expense.amount} BDT | ${expense.category} | ${expense.note}');
      }
    } catch (e) {
      print('❌ Error fetching expenses: $e');
    }
  }

  Future<void> deleteExpense(int expenseId) async {
    final token = await DevAuthService.getSavedToken();
    if (token == null) {
      print('❌ Not logged in');
      return;
    }

    try {
      final success = await ExpenseApiService.deleteExpense(
        token: token,
        expenseId: expenseId,
      );

      if (success) {
        print('✅ Expense deleted successfully');
      } else {
        print('❌ Failed to delete expense');
      }
    } catch (e) {
      print('❌ Error deleting expense: $e');
    }
  }

  Future<void> getCategories() async {
    try {
      final categories = await ExpenseApiService.getAllCategories();
      print('✅ Found ${categories.length} categories');

      for (var category in categories) {
        print('- ID: ${category.id} | Name: ${category.name} | Color: ${category.colorCode}');
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
    }
  }
}

/// Example 3: Sync Local Data to Cloud
class SyncExample {
  Future<void> syncLocalExpensesToBackend(List<Expense> localExpenses) async {
    final token = await DevAuthService.getSavedToken();
    if (token == null) {
      print('❌ Not logged in. Cannot sync.');
      return;
    }

    try {
      print('🔄 Syncing ${localExpenses.length} expenses to cloud...');

      final syncedExpenses = await ExpenseApiService.syncExpensesToBackend(
        token: token,
        localExpenses: localExpenses,
      );

      print('✅ Synced ${syncedExpenses.length} expenses successfully');
    } catch (e) {
      print('❌ Sync failed: $e');
    }
  }
}

/// Example 4: Premium Features
class PremiumFeaturesExample {
  Future<void> activatePremium() async {
    // Activate premium subscription (dev mode)
    final result = await DevAuthService.devSubscribe(
      phoneNumber: '01712345678',
    );

    if (result['success']) {
      print('✅ Premium subscription activated!');
      print('Features: ${result['subscription']['features']}');
    } else {
      print('❌ Subscription failed: ${result['message']}');
    }
  }

  Future<void> chatWithAI() async {
    final token = await DevAuthService.getSavedToken();
    if (token == null) {
      print('❌ Not logged in');
      return;
    }

    try {
      final response = await ChatbotApiService.chat(
        token: token,
        message: 'How much did I spend on food this month?',
      );

      if (response != null) {
        print('🤖 AI Response: $response');
      }
    } catch (e) {
      print('❌ Chatbot error: $e');
    }
  }

  Future<void> getAnalytics() async {
    final token = await DevAuthService.getSavedToken();
    if (token == null) {
      print('❌ Not logged in');
      return;
    }

    try {
      // Get rule-based analytics
      final analytics = await AnalyticsApiService.getRuleBasedAnalytics(
        token: token,
        savingsPercent: 20,
      );

      if (analytics != null) {
        print('✅ Analytics generated successfully');
        print('Monthly Breakdown: ${analytics['monthlyBreakdown']}');
        print('Recommendations: ${analytics['recommendations']}');
      }
    } catch (e) {
      print('❌ Analytics error: $e');
    }
  }

  Future<void> downloadPDFReport() async {
    final token = await DevAuthService.getSavedToken();
    if (token == null) {
      print('❌ Not logged in');
      return;
    }

    try {
      print('📄 Generating PDF report...');

      final filePath = await AnalyticsApiService.downloadPdfReport(
        token: token,
        savingsPercent: 20,
        onProgress: (progress) {
          print('Download progress: ${(progress * 100).toStringAsFixed(0)}%');
        },
      );

      if (filePath != null) {
        print('✅ PDF report saved to: $filePath');
      }
    } catch (e) {
      print('❌ PDF generation error: $e');
    }
  }
}

/// Example 5: Complete Widget Integration
class ExpenseScreenExample extends StatefulWidget {
  const ExpenseScreenExample({Key? key}) : super(key: key);

  @override
  State<ExpenseScreenExample> createState() => _ExpenseScreenExampleState();
}

class _ExpenseScreenExampleState extends State<ExpenseScreenExample> {
  List<Expense> expenses = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await DevAuthService.getSavedToken();
      if (token != null) {
        final fetchedExpenses = await ExpenseApiService.getAllExpenses(
          token: token,
        );
        setState(() {
          expenses = fetchedExpenses;
          isLoading = false;
        });
      } else {
        // User not logged in, load from local DB instead
        // final localExpenses = await DatabaseHelper.instance.getAllExpenses();
        setState(() {
          // expenses = localExpenses;
          isLoading = false;
          errorMessage = 'Not logged in. Showing local data only.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading expenses: $e';
      });
    }
  }

  Future<void> _addExpense(double amount, int categoryId, String note) async {
    setState(() => isLoading = true);

    try {
      final token = await DevAuthService.getSavedToken();
      if (token != null) {
        // Create expense on backend
        final expense = await ExpenseApiService.createExpense(
          token: token,
          amount: amount,
          categoryId: categoryId,
          note: note,
        );

        if (expense != null) {
          // Reload expenses
          await _loadExpenses();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Expense added successfully')),
          );
        }
      } else {
        // Save to local DB only
        // await DatabaseHelper.instance.insertExpense(expense);
        await _loadExpenses();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error adding expense: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  Future<void> _deleteExpense(int expenseId) async {
    try {
      final token = await DevAuthService.getSavedToken();
      if (token != null) {
        await ExpenseApiService.deleteExpense(
          token: token,
          expenseId: expenseId,
        );
        await _loadExpenses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Expense deleted')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExpenses,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.orange[100],
                    child: Text(errorMessage!),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return ListTile(
                        title: Text('${expense.amount} BDT'),
                        subtitle: Text('${expense.category} - ${expense.note}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteExpense(expense.id!),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add expense dialog
          _addExpense(500.0, 1, 'Example expense');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// How to use these examples:
///
/// 1. Authentication:
///    await AuthExample().registerUser();
///    await AuthExample().loginUser();
///
/// 2. Expense Management:
///    await ExpenseManagementExample().createExpense();
///    await ExpenseManagementExample().getAllExpenses();
///
/// 3. Premium Features:
///    await PremiumFeaturesExample().activatePremium();
///    await PremiumFeaturesExample().chatWithAI();
///    await PremiumFeaturesExample().getAnalytics();
///
/// 4. Use the ExpenseScreenExample widget in your app
