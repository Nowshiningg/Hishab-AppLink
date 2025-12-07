import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../localization/app_localizations.dart';
import 'package:intl/intl.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF16725),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          loc.translate('rewards'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF16725), Color(0xFFFF8C42)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF16725).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.stars,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.translate('totalPoints'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.totalPoints.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${provider.consecutiveDays} ${loc.translate('daysStreak')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Redemption Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                loc.translate('redeemRewards'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...provider.getAvailableRedemptions().map((redemption) {
              return _buildRedemptionCard(
                context,
                loc,
                provider,
                redemption['title'],
                redemption['pointsCost'],
                redemption['type'],
                redemption['icon'],
              );
            }),

            const SizedBox(height: 24),

            // Recent Activity
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                loc.translate('recentActivity'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...provider.rewards.take(10).map((reward) {
              return _buildRewardHistoryItem(context, loc, reward);
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRedemptionCard(
    BuildContext context,
    AppLocalizations loc,
    FinanceProvider provider,
    String title,
    int pointsCost,
    String type,
    String iconName,
  ) {
    final canAfford = provider.totalPoints >= pointsCost;

    IconData icon;
    switch (iconName) {
      case 'signal_cellular_alt':
        icon = Icons.signal_cellular_alt;
        break;
      case 'phone':
        icon = Icons.phone;
        break;
      case 'discount':
        icon = Icons.discount;
        break;
      default:
        icon = Icons.card_giftcard;
    }

    Color typeColor;
    switch (type) {
      case 'data':
        typeColor = const Color(0xFF4ECDC4);
        break;
      case 'minutes':
        typeColor = const Color(0xFF45B7D1);
        break;
      case 'discount':
        typeColor = const Color(0xFFF16725);
        break;
      default:
        typeColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canAfford
                ? typeColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: canAfford
                ? () => _showRedeemDialog(context, loc, provider, title, pointsCost)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: typeColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.stars,
                              size: 16,
                              color: canAfford
                                  ? const Color(0xFFF16725)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$pointsCost ${loc.translate('points')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: canAfford
                                    ? const Color(0xFFF16725)
                                    : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    canAfford ? Icons.arrow_forward_ios : Icons.lock,
                    color: canAfford ? typeColor : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardHistoryItem(
    BuildContext context,
    AppLocalizations loc,
    Map<String, dynamic> reward,
  ) {
    final timestamp = DateTime.parse(reward['timestamp'] as String);
    final isEarned = reward['type'] == 'earned';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEarned
                ? const Color(0xFF4ECDC4).withOpacity(0.2)
                : const Color(0xFFF16725).withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isEarned
                    ? const Color(0xFF4ECDC4).withOpacity(0.1)
                    : const Color(0xFFF16725).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEarned ? Icons.add : Icons.remove,
                color: isEarned
                    ? const Color(0xFF4ECDC4)
                    : const Color(0xFFF16725),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward['reason'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isEarned ? '+' : '-'}${reward['points']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isEarned
                    ? const Color(0xFF4ECDC4)
                    : const Color(0xFFF16725),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedeemDialog(
    BuildContext context,
    AppLocalizations loc,
    FinanceProvider provider,
    String title,
    int pointsCost,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('confirmRedemption')),
        content: Text(
          '${loc.translate('redeemConfirmMessage')} $title ${loc.translate('for')} $pointsCost ${loc.translate('points')}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.redeemReward(title, pointsCost);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.translate('redemptionSuccess')),
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
            child: Text(loc.translate('redeem')),
          ),
        ],
      ),
    );
  }
}
