import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../services/analytics_api_service.dart';
import '../../services/auth_service.dart';

/// Analytics Screen
///
/// Displays comprehensive financial analytics including:
/// - Rule-based analytics (data-driven insights)
/// - AI-powered insights (personalized recommendations from Gemini)
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingRuleBased = false;
  bool _isLoadingAI = false;
  Map<String, dynamic>? _ruleBasedData;
  Map<String, dynamic>? _aiData;
  String? _errorMessage;
  int _savingsPercent = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load both analytics types
  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoadingRuleBased = true;
      _isLoadingAI = true;
      _errorMessage = null;
    });

    try {
      // Get token from AuthService (more reliable)
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login to view analytics');
      }

      // Load both in parallel
      final results = await Future.wait([
        AnalyticsApiService.getRuleBasedAnalytics(
          token: token,
          savingsPercent: _savingsPercent,
        ),
        AnalyticsApiService.getAIPoweredAnalytics(
          token: token,
          savingsPercent: _savingsPercent,
        ),
      ]);

      if (mounted) {
        setState(() {
          _ruleBasedData = results[0];
          _aiData = results[1];
          _isLoadingRuleBased = false;
          _isLoadingAI = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoadingRuleBased = false;
          _isLoadingAI = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066CC),
        elevation: 0,
        title: const Text(
          'Advanced Analytics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Rule-Based', icon: Icon(Icons.bar_chart, size: 20)),
            Tab(text: 'AI-Powered', icon: Icon(Icons.auto_awesome, size: 20)),
          ],
        ),
      ),
      body: _errorMessage != null
          ? _buildErrorState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRuleBasedTab(),
                _buildAIPoweredTab(),
              ],
            ),
    );
  }

  /// Error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAnalytics,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066CC),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Rule-Based Analytics Tab
  Widget _buildRuleBasedTab() {
    if (_isLoadingRuleBased) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_ruleBasedData == null) {
      return _buildNoDataState('Rule-Based Analytics');
    }

    final hasEnoughData = _ruleBasedData!['hasEnoughData'] ?? false;

    if (!hasEnoughData) {
      return _buildInsufficientDataState(_ruleBasedData!['message']);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview
          _buildOverviewCard(_ruleBasedData!['overview']),
          const SizedBox(height: 16),

          // Monthly Breakdown
          _buildSectionTitle('Monthly Breakdown'),
          ..._buildMonthlyBreakdown(
              _ruleBasedData!['monthlyBreakdown'] ?? []),
          const SizedBox(height: 16),

          // Category Analytics
          _buildSectionTitle('Category Analysis'),
          ..._buildCategoryAnalytics(
              _ruleBasedData!['categoryAnalytics'] ?? []),
          const SizedBox(height: 16),

          // Budget Recommendations
          _buildSectionTitle('Budget Recommendations'),
          _buildBudgetRecommendations(
              _ruleBasedData!['budgetRecommendations']),
          const SizedBox(height: 16),

          // Savings Analysis
          _buildSavingsAnalysis(_ruleBasedData!['savingsAnalysis']),
        ],
      ),
    );
  }

  /// AI-Powered Analytics Tab
  Widget _buildAIPoweredTab() {
    if (_isLoadingAI) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI is analyzing your data...'),
          ],
        ),
      );
    }

    if (_aiData == null) {
      return _buildNoDataState('AI-Powered Analytics');
    }

    final disclaimer = _aiData!['disclaimer'];
    final aiInsights = _aiData!['aiInsights'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disclaimer if not enough data
          if (disclaimer != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      disclaimer,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // AI Insights
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF16725).withOpacity(0.1),
                  const Color(0xFFF16725).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF16725).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome, color: Color(0xFFF16725)),
                    SizedBox(width: 8),
                    Text(
                      'AI Insights',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF16725),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  aiInsights ?? 'No insights available',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// No data state
  Widget _buildNoDataState(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No $title Available',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start tracking your expenses to see detailed analytics',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Insufficient data state
  Widget _buildInsufficientDataState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timeline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Keep Tracking!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message ?? 'Need more data for detailed analytics',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Overview card
  Widget _buildOverviewCard(Map<String, dynamic> overview) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0066CC).withOpacity(0.1),
            const Color(0xFF0066CC).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem(
                'Months',
                overview['totalMonthsTracked'].toString(),
                Icons.calendar_today,
              ),
              _buildOverviewItem(
                'Total Spent',
                '৳${overview['totalSpentAllTime']}',
                Icons.account_balance_wallet,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem(
                'Avg Monthly',
                '৳${overview['averageMonthlySpending']}',
                Icons.trending_up,
              ),
              _buildOverviewItem(
                'Expenses',
                overview['totalExpenses'].toString(),
                Icons.receipt_long,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0066CC), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  /// Section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0066CC),
        ),
      ),
    );
  }

  /// Monthly breakdown cards
  List<Widget> _buildMonthlyBreakdown(List<dynamic> monthlyBreakdown) {
    return monthlyBreakdown.take(3).map<Widget>((month) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  month['month'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '৳${month['total']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066CC),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${month['count']} expenses',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }).toList();
  }

  /// Category analytics cards
  List<Widget> _buildCategoryAnalytics(List<dynamic> categories) {
    return categories.take(5).map<Widget>((cat) {
      final trend = cat['trend'];
      Color trendColor = Colors.grey;
      IconData trendIcon = Icons.trending_flat;

      if (trend == 'increasing') {
        trendColor = Colors.red;
        trendIcon = Icons.trending_up;
      } else if (trend == 'decreasing') {
        trendColor = Colors.green;
        trendIcon = Icons.trending_down;
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat['category'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Avg: ৳${cat['averageMonthly']} • Total: ৳${cat['totalAllTime']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(trendIcon, color: trendColor, size: 24),
          ],
        ),
      );
    }).toList();
  }

  /// Budget recommendations card
  Widget _buildBudgetRecommendations(Map<String, dynamic> budget) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF47B881).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF47B881).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended Budget',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '৳${budget['totalBudget']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF47B881),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Savings Goal: ৳${budget['savingsGoal']} (${budget['savingsPercent']}%)',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  /// Savings analysis card
  Widget _buildSavingsAnalysis(Map<String, dynamic> savings) {
    final canAchieve = savings['canAchieveSavings'] ?? false;
    final color = canAchieve ? const Color(0xFF47B881) : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            canAchieve ? Icons.check_circle : Icons.warning,
            color: color,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              savings['message'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
