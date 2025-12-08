import 'package:flutter/material.dart';
import 'banglalink_integration_service.dart';

/// Service to handle PDF export with CaaS payment integration
class PdfExportService {
  static final _blService = BanglalinkIntegrationService();

  /// Export PDF with payment confirmation
  /// Returns true if export is successful, false otherwise
  static Future<bool> exportPdf({
    required BuildContext context,
    required String reportType,
    required Future<void> Function() generatePdfCallback,
  }) async {
    // Check if user is premium subscriber (free PDF export)
    final isPremium = await _blService.isPremiumSubscriber();

    if (isPremium) {
      // Premium users get free PDF export
      try {
        await generatePdfCallback();
        _showMessage(context, 'PDF exported successfully', isError: false);
        return true;
      } catch (e) {
        _showMessage(context, 'Failed to export PDF: $e');
        return false;
      }
    }

    // Non-premium users need to pay
    final confirmed = await _showPaymentDialog(context, reportType);
    if (!confirmed) return false;

    // Show loading
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      // Charge for PDF export
      final transaction = await _blService.chargePdfExport(
        reportType: reportType,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (transaction == null || !transaction.isCompleted) {
        _showMessage(context, 'Payment failed. Please try again.');
        return false;
      }

      // Payment successful, generate PDF
      await generatePdfCallback();
      _showMessage(
        context,
        'Payment successful! PDF exported.',
        isError: false,
      );
      return true;
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
      _showMessage(context, 'Error: ${e.toString()}');
      return false;
    }
  }

  /// Show payment confirmation dialog
  static Future<bool> _showPaymentDialog(
    BuildContext context,
    String reportType,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.picture_as_pdf, color: Color(0xFFF16725)),
            SizedBox(width: 12),
            Expanded(
              child: Text('Export PDF'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This feature requires a small payment:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF16725).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF16725).withOpacity(0.3),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PDF Export',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '৳5',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF16725),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Report: ${_formatReportType(reportType)}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Premium subscribers get unlimited free exports',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF16725),
              foregroundColor: Colors.white,
            ),
            child: const Text('Pay & Export'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Format report type for display
  static String _formatReportType(String type) {
    switch (type.toLowerCase()) {
      case 'monthly':
        return 'Monthly Report';
      case 'yearly':
        return 'Yearly Report';
      case 'custom':
        return 'Custom Report';
      case 'category':
        return 'Category Report';
      default:
        return type;
    }
  }

  /// Show message to user
  static void _showMessage(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
