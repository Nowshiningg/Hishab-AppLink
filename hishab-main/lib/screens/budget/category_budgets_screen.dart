import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../localization/app_localizations.dart';

class CategoryBudgetsScreen extends StatefulWidget {
  const CategoryBudgetsScreen({super.key});

  @override
  State<CategoryBudgetsScreen> createState() => _CategoryBudgetsScreenState();
}

class _CategoryBudgetsScreenState extends State<CategoryBudgetsScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<FinanceProvider>(context);
    const primaryColor = Color(0xFFF16725);
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF16725),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          loc.translate('Category Budgets'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
        child: FutureBuilder<Map<String, Map<String, double>>>(
        future: provider.getCategoryBudgetStatus(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final budgetStatus = snapshot.data!;
          final allCategories = provider.categories;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF16725), Color(0xFFFF8C42)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF16725).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.translate('Manage Category Budgets'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.translate('Set Budgets For Categories'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category budget cards
              ...allCategories.map((category) {
                final categoryName = category.name;
                final status = budgetStatus[categoryName];
                final hasBudget = status != null;

                return _buildCategoryBudgetCard(
                  context,
                  loc,
                  provider,
                  category.name,
                  category.icon,
                  category.color,
                  status,
                );
              }),
            ],
          );
        },
        ),
      ),
    );
  }

  Widget _buildCategoryBudgetCard(
    BuildContext context,
    AppLocalizations loc,
    FinanceProvider provider,
    String categoryName,
    IconData icon,
    Color color,
    Map<String, double>? status,
  ) {
    final hasBudget = status != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translateCategory(categoryName),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (hasBudget) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 14,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '৳${NumberFormat('#,##0').format(status['budget'])}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                            Text(
                              ' ${loc.translate('budgetLimit')}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (!hasBudget) ...[
                        const SizedBox(height: 4),
                        Text(
                          loc.translate('noBudgetSet'),
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showSetBudgetDialog(
                    context,
                    loc,
                    provider,
                    categoryName,
                    status?['budget'],
                  ),
                  icon: Icon(
                    hasBudget ? Icons.edit : Icons.add_circle,
                    color: color,
                  ),
                ),
              ],
            ),
            if (hasBudget) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                loc.translate('budgetUsed'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '৳${NumberFormat('#,##0').format(status['spent'])}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: status['remaining']! < 0
                            ? Colors.red.withOpacity(0.05)
                            : const Color(0xFF4ECDC4).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                status['remaining']! < 0 ? Icons.warning_amber : Icons.account_balance_wallet,
                                size: 14,
                                color: status['remaining']! < 0
                                    ? Colors.red.withOpacity(0.7)
                                    : const Color(0xFF4ECDC4).withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  loc.translate('budgetRemaining'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '৳${NumberFormat('#,##0').format(status['remaining'])}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: status['remaining']! < 0
                                  ? Colors.red
                                  : const Color(0xFF4ECDC4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (status['percentage']! / 100).clamp(0.0, 1.0),
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    status['percentage']! > 100
                        ? Colors.red
                        : status['percentage']! > 80
                            ? Colors.orange
                            : color,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${status['percentage']!.toStringAsFixed(1)}% ${loc.translate('used')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showDeleteBudgetDialog(
                      context,
                      loc,
                      provider,
                      categoryName,
                    ),
                    child: Text(
                      loc.translate('remove'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSetBudgetDialog(
    BuildContext context,
    AppLocalizations loc,
    FinanceProvider provider,
    String categoryName,
    double? currentBudget,
  ) {
    final controller = TextEditingController(
      text: currentBudget != null ? currentBudget.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.translate('Set Category Budget')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${loc.translate('category')}: ${loc.translateCategory(categoryName)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: loc.translate('budgetAmount'),
                prefixText: '৳',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                await provider.setCategoryBudget(categoryName, amount);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (context.mounted) {
                  setState(() {}); // Refresh the UI
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.translate('budgetSet')),
                      backgroundColor: const Color(0xFF4ECDC4),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF16725),
              foregroundColor: Colors.white,
            ),
            child: Text(loc.translate('save')),
          ),
        ],
      ),
    );
  }

  void _showDeleteBudgetDialog(
    BuildContext context,
    AppLocalizations loc,
    FinanceProvider provider,
    String categoryName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.translate('removeBudget')),
        content: Text(
          '${loc.translate('removeBudgetConfirm')} ${loc.translateCategory(categoryName)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteCategoryBudget(categoryName);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (context.mounted) {
                setState(() {}); // Refresh the UI
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.translate('budgetRemoved')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(loc.translate('remove')),
          ),
        ],
      ),
    );
  }
}
