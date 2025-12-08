import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import 'premium_thank_you_screen.dart';
import 'premium_features_screen.dart';

class PremiumSubscriptionScreen extends StatefulWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  State<PremiumSubscriptionScreen> createState() => _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState extends State<PremiumSubscriptionScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _subscribe() async {
    setState(() => _isProcessing = true);
    
    try {
      // Subscribe using provider (demo mode)
      await context.read<FinanceProvider>().subscribeToPremium();
      
      // Navigate to thank you screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PremiumThankYouScreen(),
          ),
        );
      }
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
      setState(() => _isProcessing = false);
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        // Check if we should show thank you screen
        if (provider.isPremiumSubscribed && provider.showPremiumThankYou) {
          return const PremiumThankYouScreen();
        }
        
        // Show features screen if already subscribed
        if (provider.isPremiumSubscribed) {
          return const PremiumFeaturesScreen();
        }
        
        // Otherwise show subscription offer
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            title: const Text(
              'Premium Subscription',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: _buildUnsubscribedView(),
        );
      },
    );
  }

  Widget _buildUnsubscribedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium badge
          Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF16725),
                    const Color(0xFFF16725).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF16725).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Title
          const Text(
            'Go Premium',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          Text(
            'Unlock all features and take control of your finances',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),

          // Features list
          _buildFeatureCard(
            Icons.cloud_sync,
            'Cloud Sync',
            'Automatically backup your data to the cloud',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            Icons.analytics,
            'Advanced Analytics',
            'Get detailed insights and spending patterns',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            Icons.card_giftcard,
            'Rewards Redemption',
            'Redeem points for exclusive rewards',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            Icons.smart_toy,
            'Smart Assistant',
            'AI-powered financial advice and tips',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            Icons.picture_as_pdf,
            'PDF Reports',
            'Export detailed financial reports',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            Icons.notifications_active,
            'SMS Alerts',
            'Get expense summaries and budget alerts via SMS',
          ),
          const SizedBox(height: 40),

          // Pricing
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF16725).withOpacity(0.1),
                  const Color(0xFFF16725).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF16725).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '৳',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF16725),
                      ),
                    ),
                    const Text(
                      '2',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF16725),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '/day',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Billed daily through Banglalink',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cancel anytime',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Subscribe button
          ElevatedButton(
            onPressed: _isProcessing ? null : _subscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF16725),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Subscribe Now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // Terms
          Text(
            'By subscribing, you agree to our Terms of Service. Subscription will auto-renew daily until cancelled.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF16725).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
