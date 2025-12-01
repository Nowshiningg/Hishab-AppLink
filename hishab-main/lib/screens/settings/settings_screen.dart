import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../models/category_model.dart';
import '../../localization/app_localizations.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          loc.translate('settings'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          final income = provider.income?.monthlyIncome ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(loc.translate('personal'), [
                _buildNameCard(context, provider),
              ]),
              const SizedBox(height: 24),
              _buildSection(loc.translate('appearance'), [
                _buildThemeCard(context, provider),
                const SizedBox(height: 12),
                _buildLanguageCard(context, provider),
              ]),
              const SizedBox(height: 24),
              _buildSection(loc.translate('notifications'), [
                _buildNotificationsCard(context),
              ]),
              const SizedBox(height: 24),
              _buildSection(loc.translate('financialSettings'), [
                _buildIncomeCard(context, income),
              ]),
              const SizedBox(height: 24),
              _buildSection(loc.translate('categories'), [
                _buildCategoriesCard(context, provider),
              ]),
              const SizedBox(height: 24),
              _buildSection(loc.translate('dataManagement'), [
                _buildClearDataCard(context, provider),
              ]),
              const SizedBox(height: 24),
              _buildSection(loc.translate('about'), [_buildAboutCard(context)]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildThemeCard(BuildContext context, FinanceProvider provider) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF16725).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF16725).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF16725).withOpacity(0.2),
                  const Color(0xFFF16725).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF16725).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: const Color(0xFFF16725),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('darkMode'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.isDarkMode ? loc.translate('enabled') : loc.translate('disabled'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: provider.isDarkMode,
            onChanged: (value) => provider.toggleThemeMode(),
            activeColor: const Color(0xFFF16725),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(BuildContext context, double currentIncome) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF16725).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF16725).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF16725).withOpacity(0.2),
                      const Color(0xFFF16725).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF16725).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.payments,
                  color: Color(0xFFF16725),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  loc.translate('monthlyIncome'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '৳${NumberFormat('#,##0.00').format(currentIncome)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF16725),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showEditIncomeDialog(context, currentIncome),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFF16725)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                loc.translate('editIncome'),
                style: const TextStyle(
                  color: Color(0xFFF16725),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesCard(BuildContext context, FinanceProvider provider) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0066CC).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066CC).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0066CC).withOpacity(0.2),
                      const Color(0xFF0066CC).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0066CC).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.category,
                  color: Color(0xFF0066CC),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  loc.translate('manageCategories'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${provider.categories.length} ${loc.translate('categories').toLowerCase()}',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.categories.map((category) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: category.color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(category.icon, color: category.color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      loc.translateCategory(category.name),
                      style: TextStyle(
                        color: category.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showAddCategoryDialog(context, provider),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0066CC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                loc.translate('addCategory'),
                style: const TextStyle(
                  color: Color(0xFF0066CC),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearDataCard(BuildContext context, FinanceProvider provider) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  loc.translate('clearAllData'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            loc.translate('clearDataWarning'),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showClearDataDialog(context, provider),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                loc.translate('clearAllData'),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, FinanceProvider provider) {
    final loc = AppLocalizations.of(context);
    final currentLanguage = provider.locale.languageCode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF16725).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF16725).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF16725).withOpacity(0.2),
                      const Color(0xFFF16725).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF16725).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.language,
                  color: Color(0xFFF16725),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  loc.translate('language'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currentLanguage == 'bn' ? 'বাংলা (Bangla)' : 'English',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showLanguageDialog(context, provider),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFF16725)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                loc.translate('selectLanguage'),
                style: const TextStyle(
                  color: Color(0xFFF16725),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, FinanceProvider provider) {
    final loc = AppLocalizations.of(context);
    final currentLanguage = provider.locale.languageCode;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.translate('selectLanguage')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('বাংলা (Bangla)'),
              value: 'bn',
              groupValue: currentLanguage,
              onChanged: (value) async {
                if (value != null) {
                  await provider.changeLanguage(value);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).translate('languageChanged')),
                        backgroundColor: const Color(0xFFF16725),
                      ),
                    );
                  }
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLanguage,
              onChanged: (value) async {
                if (value != null) {
                  await provider.changeLanguage(value);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).translate('languageChanged')),
                        backgroundColor: const Color(0xFFF16725),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.translate('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final notificationService = NotificationService();

    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        notificationService.areNotificationsEnabled(),
        notificationService.getReminderTime(),
      ]).then((results) => {
        'enabled': results[0] as bool,
        'time': results[1] as String,
      }),
      builder: (context, snapshot) {
        final enabled = snapshot.data?['enabled'] as bool? ?? true;
        final time = snapshot.data?['time'] as String? ?? '20:00';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF4ECDC4).withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ECDC4).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4ECDC4), Color(0xFF45B7D1)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4ECDC4).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate('dailyReminder'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          enabled
                              ? '${loc.translate('reminderTime')}: $time'
                              : loc.translate('reminderDisabled'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: enabled,
                    activeColor: const Color(0xFF4ECDC4),
                    onChanged: (value) async {
                      if (value) {
                        await _showTimePickerDialog(context, time);
                      } else {
                        await notificationService.cancelDailyReminder();
                        // Rebuild widget
                        if (context.mounted) {
                          (context as Element).markNeedsBuild();
                        }
                      }
                    },
                  ),
                ],
              ),
              if (enabled) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => _showTimePickerDialog(context, time),
                  icon: const Icon(Icons.schedule, color: Color(0xFF4ECDC4)),
                  label: Text(
                    loc.translate('changeReminderTime'),
                    style: const TextStyle(color: Color(0xFF4ECDC4)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showTimePickerDialog(BuildContext context, String currentTime) async {
    final loc = AppLocalizations.of(context);
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4ECDC4),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && context.mounted) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await NotificationService().scheduleDailyReminder(timeString);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('reminderScheduled')),
            backgroundColor: const Color(0xFF4ECDC4),
          ),
        );
        // Force rebuild
        (context as Element).markNeedsBuild();
      }
    }
  }

  Widget _buildAboutCard(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF9C4A24).withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9C4A24).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF9C4A24).withOpacity(0.2),
                        const Color(0xFF9C4A24).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C4A24).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF9C4A24),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '${loc.translate('about')} ${loc.translate('appName')}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${loc.translate('version')} 1.0.0',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.translate('appDescription'),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditIncomeDialog(BuildContext context, double currentIncome) {
    final loc = AppLocalizations.of(context);
    final controller = TextEditingController(
      text: currentIncome > 0 ? currentIncome.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.translate('editIncome')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            prefixText: '৳ ',
            hintText: '0',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                await context.read<FinanceProvider>().setIncome(value);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).translate('incomeUpdated')),
                      backgroundColor: const Color(0xFFF16725),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF16725),
            ),
            child: Text(loc.translate('save')),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, FinanceProvider provider) {
    final loc = AppLocalizations.of(context);
    final nameController = TextEditingController();
    String selectedIcon = 'category';
    String selectedColor = '#4ECDC4';

    final availableIcons = [
      {'name': 'category', 'icon': Icons.category},
      {'name': 'home', 'icon': Icons.home},
      {'name': 'school', 'icon': Icons.school},
      {'name': 'fitness_center', 'icon': Icons.fitness_center},
      {'name': 'restaurant', 'icon': Icons.restaurant},
      {'name': 'directions_car', 'icon': Icons.directions_car},
      {'name': 'shopping_bag', 'icon': Icons.shopping_bag},
      {'name': 'receipt', 'icon': Icons.receipt},
      {'name': 'movie', 'icon': Icons.movie},
      {'name': 'local_hospital', 'icon': Icons.local_hospital},
    ];

    final availableColors = [
      '#FF6B6B',
      '#4ECDC4',
      '#45B7D1',
      '#FFA07A',
      '#98D8C8',
      '#F7DC6F',
      '#BB8FCE',
      '#85C1E2',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(loc.translate('addCategory')),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: loc.translate('categoryName'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.translate('selectIcon'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableIcons.map((iconData) {
                    final isSelected = selectedIcon == iconData['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIcon = iconData['name'] as String;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF16725).withOpacity(0.2)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFF16725)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          iconData['icon'] as IconData,
                          size: 24,
                          color: isSelected
                              ? const Color(0xFFF16725)
                              : Colors.grey.shade600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.translate('selectColor'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableColors.map((colorCode) {
                    final isSelected = selectedColor == colorCode;
                    final color = Color(
                      int.parse(colorCode.substring(1), radix: 16) + 0xFF000000,
                    );
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = colorCode;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(loc.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  final newCategory = CategoryModel(
                    name: nameController.text.trim(),
                    iconName: selectedIcon,
                    colorCode: selectedColor,
                  );
                  await provider.addCategory(newCategory);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).translate('categoryAdded')),
                        backgroundColor: const Color(0xFFF16725),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF16725),
              ),
              child: Text(loc.translate('add')),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, FinanceProvider provider) {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.translate('clearAllData')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          loc.translate('clearDataConfirm'),
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.clearAllData();
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).translate('dataClearedSuccess')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(loc.translate('clearAllData')),
          ),
        ],
      ),
    );
  }

  Widget _buildNameCard(BuildContext context, FinanceProvider provider) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF16725).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF16725).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF16725).withOpacity(0.2),
                  const Color(0xFFF16725).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF16725).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFFF16725),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('name'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.userName.isNotEmpty
                    ? provider.userName
                    : loc.translate('notSet'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showNameDialog(context, provider),
            icon: const Icon(
              Icons.edit,
              color: Color(0xFFF16725),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showNameDialog(BuildContext context, FinanceProvider provider) async {
    final loc = AppLocalizations.of(context);
    final nameController = TextEditingController(text: provider.userName);

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(loc.translate('updateName')),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: loc.translate('yourName'),
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(loc.translate('cancel')),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF16725),
              ),
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  await provider.updateName(newName);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).translate('nameUpdated')),
                        backgroundColor: const Color(0xFFF16725),
                      ),
                    );
                  }
                } else {
                  // Allow clearing the name
                  await provider.updateName('');
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).translate('nameCleared')),
                        backgroundColor: const Color(0xFFF16725),
                      ),
                    );
                  }
                }
              },
              child: Text(
                loc.translate('save'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
