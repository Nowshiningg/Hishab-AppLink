import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/finance_provider.dart';
import '../../services/analytics_api_service.dart';

/// PDF Report Generation Screen
///
/// Allows premium users to generate comprehensive
/// analytics PDF reports with customizable settings
class PdfReportGenerationScreen extends StatefulWidget {
  const PdfReportGenerationScreen({super.key});

  @override
  State<PdfReportGenerationScreen> createState() =>
      _PdfReportGenerationScreenState();
}

class _PdfReportGenerationScreenState extends State<PdfReportGenerationScreen> {
  // State management
  PdfGenerationState _state = PdfGenerationState.idle;
  double _downloadProgress = 0.0;
  String? _pdfFilePath;
  String? _errorMessage;
  int _savingsPercent = 20;

  @override
  void initState() {
    super.initState();
    // Clean up old PDFs on screen load
    AnalyticsApiService.cleanupOldPdfs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: const Text(
          'Generate Analytics Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            _buildHeaderCard(),
            const SizedBox(height: 24),

            // Settings section (only show in idle state)
            if (_state == PdfGenerationState.idle) ...[
              _buildSettingsSection(),
              const SizedBox(height: 24),
            ],

            // Generate button or status
            _buildActionSection(),

            const SizedBox(height: 16),

            // Info card
            if (_state == PdfGenerationState.idle) _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  /// Header card with icon and description
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B6B),
            const Color(0xFFFF6B6B).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'PDF Analytics Report',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Comprehensive financial insights with charts and AI recommendations',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Settings section with savings percentage slider
  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Report Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Savings Goal',
                style: TextStyle(fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_savingsPercent%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFFF6B6B),
              inactiveTrackColor: const Color(0xFFFF6B6B).withOpacity(0.2),
              thumbColor: const Color(0xFFFF6B6B),
              overlayColor: const Color(0xFFFF6B6B).withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _savingsPercent.toDouble(),
              min: 0,
              max: 50,
              divisions: 10,
              label: '$_savingsPercent%',
              onChanged: (value) {
                setState(() {
                  _savingsPercent = value.round();
                });
              },
            ),
          ),
          Text(
            'Set your target savings percentage for budget recommendations',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Action section - shows button or progress
  Widget _buildActionSection() {
    switch (_state) {
      case PdfGenerationState.idle:
        return _buildGenerateButton();

      case PdfGenerationState.loading:
        return _buildLoadingState();

      case PdfGenerationState.success:
        return _buildSuccessState();

      case PdfGenerationState.error:
        return _buildErrorState();
    }
  }

  /// Generate PDF button
  Widget _buildGenerateButton() {
    return ElevatedButton(
      onPressed: _generatePdf,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.file_download, size: 22),
          SizedBox(width: 8),
          Text(
            'Generate PDF Report',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Loading state with progress indicator
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF6B6B).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
          ),
          const SizedBox(height: 16),
          Text(
            'Generating your analytics report...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _downloadProgress,
            backgroundColor: Colors.grey[300],
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_downloadProgress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Success state with action buttons
  Widget _buildSuccessState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 48,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Report Generated Successfully!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your analytics report is ready',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openPdf,
                  icon: const Icon(Icons.open_in_new, size: 20),
                  label: const Text('Open PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _sharePdf,
                  icon: const Icon(Icons.share, size: 20),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B6B),
                    side: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _reset,
            child: const Text('Generate Another Report'),
          ),
        ],
      ),
    );
  }

  /// Error state with retry button
  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Generation Failed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An error occurred while generating the report',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _generatePdf,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Info card explaining what's included
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0066CC).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0066CC).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFF0066CC), size: 20),
              SizedBox(width: 8),
              Text(
                'What\'s Included',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0066CC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('Monthly spending breakdown and trends'),
          _buildInfoItem('Category-wise analysis with insights'),
          _buildInfoItem('Budget recommendations'),
          _buildInfoItem('Visual charts and graphs'),
          _buildInfoItem('AI-powered personalized advice'),
          _buildInfoItem('Savings goal tracking'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF0066CC)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Generate PDF report
  Future<void> _generatePdf() async {
    setState(() {
      _state = PdfGenerationState.loading;
      _downloadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      // Get JWT token from provider
      final financeProvider =
          Provider.of<FinanceProvider>(context, listen: false);
      final token = financeProvider.jwtToken;

      if (token == null || token.isEmpty) {
        throw Exception(
            'Authentication required. Please login to generate reports.');
      }

      // Download PDF
      final filePath = await AnalyticsApiService.downloadPdfReport(
        token: token,
        savingsPercent: _savingsPercent,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      if (filePath != null) {
        setState(() {
          _state = PdfGenerationState.success;
          _pdfFilePath = filePath;
        });
      } else {
        throw Exception('Failed to generate PDF report');
      }
    } catch (e) {
      setState(() {
        _state = PdfGenerationState.error;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  /// Open PDF file
  Future<void> _openPdf() async {
    if (_pdfFilePath != null) {
      try {
        await OpenFile.open(_pdfFilePath!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Share PDF file
  Future<void> _sharePdf() async {
    if (_pdfFilePath != null) {
      try {
        await Share.shareXFiles(
          [XFile(_pdfFilePath!)],
          text: 'My Hishab Analytics Report',
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Reset to idle state
  void _reset() {
    setState(() {
      _state = PdfGenerationState.idle;
      _pdfFilePath = null;
      _downloadProgress = 0.0;
      _errorMessage = null;
    });
  }
}

/// PDF Generation State Enum
enum PdfGenerationState {
  idle,
  loading,
  success,
  error,
}
