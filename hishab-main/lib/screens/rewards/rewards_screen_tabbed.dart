import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../goals/goal_create_screen.dart';
import '../goals/goal_detail_screen.dart';

/// Enhanced Rewards Screen with Goals, Wishlist, and Achievements tabs
class RewardsScreenTabbed extends StatefulWidget {
  const RewardsScreenTabbed({super.key});

  @override
  State<RewardsScreenTabbed> createState() => _RewardsScreenTabbedState();
}

class _RewardsScreenTabbedState extends State<RewardsScreenTabbed>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals & Achievements'),
        backgroundColor: const Color(0xFF4ECDC4),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Goals', icon: Icon(Icons.flag)),
            Tab(text: 'Wishlist', icon: Icon(Icons.shopping_bag)),
            Tab(text: 'Achievements', icon: Icon(Icons.emoji_events)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GoalsTab(),
          _WishlistTab(),
          _AchievementsTab(),
        ],
      ),
    );
  }
}

// Goals Tab
class _GoalsTab extends StatelessWidget {
  const _GoalsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        final goals = provider.goals;

        if (goals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flag, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No Savings Goals Yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first goal to start saving!',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const GoalCreateScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Goal'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: const Color(0xFF4ECDC4),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: goals.length + 1,
          itemBuilder: (context, index) {
            if (index == goals.length) {
              return ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const GoalCreateScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Goal'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: const Color(0xFF4ECDC4),
                ),
              );
            }

            final goal = goals[index];
            final color = _parseColor(goal.colorHex) ?? const Color(0xFF4ECDC4);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => GoalDetailScreen(goalId: goal.id!),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              goal.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (goal.isCompleted)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: goal.progressPercent,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(goal.progressPercent * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '৳${NumberFormat('#,##0').format(goal.currentAmount)} / '
                            '৳${NumberFormat('#,##0').format(goal.targetAmount)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color? _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return null;
    }
  }
}

// Wishlist Tab
class _WishlistTab extends StatelessWidget {
  const _WishlistTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        final items = provider.wishlist;

        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Wishlist Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.card_giftcard, size: 40),
                title: Text(item.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: item.progressPercent,
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '৳${NumberFormat('#,##0').format(item.savedAmount)} / '
                      '৳${NumberFormat('#,##0').format(item.price)}',
                    ),
                  ],
                ),
                trailing: item.canPurchase
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

// Achievements Tab
class _AchievementsTab extends StatelessWidget {
  const _AchievementsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        final achievements = provider.achievements;
        final unlocked = provider.unlockedAchievements;
        final locked = provider.lockedAchievements;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF16725), Color(0xFFFF8C42)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('Total', achievements.length.toString()),
                  _buildStatColumn('Unlocked', unlocked.length.toString()),
                  _buildStatColumn('Locked', locked.length.toString()),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Unlocked achievements
            if (unlocked.isNotEmpty) ...[
              const Text(
                'Unlocked Achievements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...unlocked.map((achievement) => _buildAchievementCard(
                    achievement.title,
                    achievement.description,
                    true,
                    DateTime.tryParse(achievement.unlockedAt ?? ''),
                  )),
              const SizedBox(height: 24),
            ],

            // Locked achievements
            if (locked.isNotEmpty) ...[
              const Text(
                'Locked Achievements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...locked.map((achievement) => _buildAchievementCard(
                    achievement.title,
                    achievement.description,
                    false,
                    null,
                  )),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    String title,
    String description,
    bool isUnlocked,
    DateTime? unlockedAt,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          isUnlocked ? Icons.emoji_events : Icons.lock,
          size: 40,
          color: isUnlocked ? const Color(0xFFF16725) : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            if (unlockedAt != null)
              Text(
                'Unlocked: ${DateFormat.yMMMd().format(unlockedAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4ECDC4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
