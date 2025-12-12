import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../models/expense.dart';
import '../../localization/app_localizations.dart';
import '../../services/expense_service.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    const primaryColor = Color(0xFFF16725);
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          loc.translate('expenses'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.1),
              backgroundColor,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 100,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.translate('noExpenses'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.translate('addExpense'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          final groupedExpenses = provider.getExpensesGroupedByDate();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedExpenses.length,
            itemBuilder: (context, index) {
              final dateKey = groupedExpenses.keys.elementAt(index);
              final expenses = groupedExpenses[dateKey]!;
              final dailyTotal = expenses.fold<double>(
                0,
                (sum, expense) => sum + expense.amount,
              );

              // Translate "Today" and "Yesterday"
              String displayDateKey = dateKey;
              if (dateKey == 'Today') {
                displayDateKey = loc.translate('today');
              } else if (dateKey == 'Yesterday') {
                displayDateKey = loc.translate('yesterday');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayDateKey,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFF16725),
                                const Color(0xFFF16725).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF16725).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            '৳${NumberFormat('#,##0.00').format(dailyTotal)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...expenses.map(
                    (expense) => _buildExpenseItem(context, expense, provider),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
        ),
      ),
    );
  }

  Widget _buildExpenseItem(
    BuildContext context,
    Expense expense,
    FinanceProvider provider,
  ) {
    final loc = AppLocalizations.of(context);
    final category = provider.categories.firstWhere(
      (cat) => cat.name == expense.category,
      orElse: () => provider.categories.first,
    );

    return Dismissible(
      key: Key(expense.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(loc.translate('delete')),
            content: Text(
              loc.translate('clearDataConfirm'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(loc.translate('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(loc.translate('delete')),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        // Delete from local database
        provider.deleteExpense(expense.id!);
        
        // Sync with backend API
        try {
          if (expense.id != null) {
            final success = await ExpenseService.deleteExpense(expense.id!);
            if (success) {
              print('✅ Expense deleted from backend: ${expense.id}');
            } else {
              print('⚠️ Failed to delete expense from backend (deleted locally)');
            }
          }
        } catch (e) {
          print('⚠️ API deletion error: $e (expense deleted locally)');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('expenseDeleted')),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: category.color.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: category.color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    category.color.withOpacity(0.2),
                    category.color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: category.color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(category.icon, color: category.color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translateCategory(category.name),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: category.color,
                    ),
                  ),
                  if (expense.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      expense.note,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm a').format(expense.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '৳${NumberFormat('#,##0.00').format(expense.amount)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF16725),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(loc.translate('delete')),
                          content: Text(
                            loc.translate('clearDataConfirm'),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                              child: Text(loc.translate('cancel')),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: Text(
                                loc.translate('delete'),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (shouldDelete == true) {
                        // Delete from local database
                        provider.deleteExpense(expense.id!);
                        
                        // Sync with backend API
                        try {
                          if (expense.id != null) {
                            final success = await ExpenseService.deleteExpense(expense.id!);
                            if (success) {
                              print('✅ Expense deleted from backend: ${expense.id}');
                            } else {
                              print('⚠️ Failed to delete expense from backend (deleted locally)');
                            }
                          }
                        } catch (e) {
                          print('⚠️ API deletion error: $e (expense deleted locally)');
                        }
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context).translate('expenseDeleted')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
