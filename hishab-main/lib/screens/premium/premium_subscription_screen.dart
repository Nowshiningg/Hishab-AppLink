import 'package:flutter/material.dart';
import '../../services/banglalink_integration_service.dart';
import '../../models/subscription.dart';

class PremiumSubscriptionScreen extends StatefulWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  State<PremiumSubscriptionScreen> createState() => _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState extends State<PremiumSubscriptionScreen> {
  final _blService = BanglalinkIntegrationService();
  bool _isLoading = true;
  bool _isSubscribed = false;
  bool _isProcessing = false;
  Subscription? _subscription;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final isSubscribed = await _blService.isPremiumSubscriber();
      
      if (isSubscribed) {
        final status = await _blService.getSubscriptionStatus();
        setState(() {
          _isSubscribed = isSubscribed;
          _subscription = status;
        });
      } else {
        setState(() => _isSubscribed = false);
      }
    } catch (e) {
      debugPrint('Error checking subscription: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _subscribe() async {
    setState(() => _isProcessing = true);
    
    try {
      final subscription = await _blService.subscribeToPremium();
      
      if (subscription != null && subscription.isActive) {
        setState(() {
          _isSubscribed = true;
          _subscription = subscription;
        });
        _showMessage('Successfully subscribed to Premium!', isError: false);
      } else {
        _showMessage('Subscription failed. Please try again.');
      }
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _unsubscribe() async {
    final confirmed = await _showConfirmDialog(
      'Cancel Subscription?',
      'Are you sure you want to cancel your premium subscription? You will lose access to all premium features.',
    );
    
    if (!confirmed) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final success = await _blService.unsubscribeFromPremium();
      
      if (success) {
        setState(() {
          _isSubscribed = false;
          _subscription = null;
        });
        _showMessage('Subscription cancelled successfully', isError: false);
      } else {
        _showMessage('Failed to cancel subscription');
      }
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSubscribed
              ? _buildSubscribedView()
              : _buildUnsubscribedView(),
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

  Widget _buildSubscribedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Success badge
          Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Title
          const Text(
            'You\'re Premium!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Status
          Text(
            'Enjoying all premium features',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),

          // Subscription info card
          if (_subscription != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Status', _subscription!.status.toUpperCase()),
                  const Divider(height: 24),
                  _buildInfoRow('Subscribed On', _formatDate(_subscription!.subscribedAt)),
                  if (_subscription!.nextBillingDate != null) ...[
                    const Divider(height: 24),
                    _buildInfoRow('Next Billing', _formatDate(_subscription!.nextBillingDate!)),
                  ],
                  const Divider(height: 24),
                  _buildInfoRow('Price', '৳2/day'),
                ],
              ),
            ),
          const SizedBox(height: 40),

          // Active features
          const Text(
            'Active Premium Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildActiveFeature(Icons.cloud_done, 'Cloud Sync'),
          _buildActiveFeature(Icons.analytics, 'Advanced Analytics'),
          _buildActiveFeature(Icons.card_giftcard, 'Rewards Redemption'),
          _buildActiveFeature(Icons.smart_toy, 'Smart Assistant'),
          _buildActiveFeature(Icons.picture_as_pdf, 'PDF Reports'),
          _buildActiveFeature(Icons.notifications_active, 'SMS Alerts'),
          
          const SizedBox(height: 40),

          // Cancel button
          OutlinedButton(
            onPressed: _isProcessing ? null : _unsubscribe,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  )
                : const Text(
                    'Cancel Subscription',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
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

  Widget _buildActiveFeature(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
