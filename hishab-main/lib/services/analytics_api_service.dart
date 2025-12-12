import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';

/// Analytics API Service
///
/// Provides methods to:
/// - Fetch rule-based analytics
/// - Fetch AI-powered analytics
/// - Download PDF analytics reports
class AnalyticsApiService {
  /// Fetch rule-based analytics
  ///
  /// Returns analytics data including monthly breakdown,
  /// category analysis, budget recommendations, and savings analysis
  ///
  /// [token] - JWT authentication token
  /// [savingsPercent] - Desired savings percentage (0-100), default: 20
  ///
  /// Returns analytics data map or null on error
  static Future<Map<String, dynamic>?> getRuleBasedAnalytics({
    required String token,
    int savingsPercent = 20,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl(
          '${ApiConfig.ruleBasedAnalyticsEndpoint}?savingsPercent=$savingsPercent',
        ),
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Premium subscription required for analytics.');
      }

      return null;
    } catch (e) {
      print('Error fetching rule-based analytics: $e');
      rethrow;
    }
  }

  /// Fetch AI-powered analytics
  ///
  /// Returns AI-generated insights and recommendations
  /// from Google Gemini based on user's spending data
  ///
  /// [token] - JWT authentication token
  /// [savingsPercent] - Desired savings percentage (0-100), default: 20
  ///
  /// Returns analytics data map or null on error
  static Future<Map<String, dynamic>?> getAIPoweredAnalytics({
    required String token,
    int savingsPercent = 20,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl(
          '${ApiConfig.aiPoweredAnalyticsEndpoint}?savingsPercent=$savingsPercent',
        ),
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Premium subscription required for AI analytics.');
      }

      return null;
    } catch (e) {
      print('Error fetching AI-powered analytics: $e');
      rethrow;
    }
  }

  /// Download PDF analytics report
  ///
  /// Downloads a comprehensive PDF report containing both
  /// rule-based and AI-powered analytics with charts
  ///
  /// [token] - JWT authentication token
  /// [savingsPercent] - Desired savings percentage (0-100), default: 20
  /// [onProgress] - Optional callback for download progress (0.0 to 1.0)
  ///
  /// Returns file path of downloaded PDF or null on error
  static Future<String?> downloadPdfReport({
    required String token,
    int savingsPercent = 20,
    Function(double)? onProgress,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl(ApiConfig.analyticsPdfEndpoint),
      );

      // Create request
      final request = http.Request('POST', url);
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.body = jsonEncode({
        'savingsPercent': savingsPercent,
      });

      // Send request
      print('Requesting PDF report from ${url.toString()}');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120), // 2 minutes timeout for PDF generation
      );

      // Check status code
      if (streamedResponse.statusCode != 200) {
        final responseBody = await streamedResponse.stream.bytesToString();
        print('PDF download failed with status ${streamedResponse.statusCode}');
        print('Response: $responseBody');

        if (streamedResponse.statusCode == 401) {
          throw Exception('Authentication failed. Please login again.');
        } else if (streamedResponse.statusCode == 403) {
          throw Exception(
              'Premium subscription required for PDF reports. Upgrade to premium to access this feature.');
        } else if (streamedResponse.statusCode == 404) {
          throw Exception(
              'No expense data found. Start tracking expenses to generate reports.');
        } else {
          final errorData = jsonDecode(responseBody);
          throw Exception(
              errorData['message'] ?? 'Failed to generate PDF report');
        }
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final filename =
          'hishab-analytics-${DateTime.now().toIso8601String().split('T')[0]}.pdf';
      final filePath = '${tempDir.path}/$filename';

      // Delete old file if exists
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Download with progress tracking
      final contentLength = streamedResponse.contentLength ?? 0;
      final bytes = <int>[];
      int receivedBytes = 0;

      await for (var chunk in streamedResponse.stream) {
        bytes.addAll(chunk);
        receivedBytes += chunk.length;

        if (contentLength > 0 && onProgress != null) {
          final progress = receivedBytes / contentLength;
          onProgress(progress);
        }
      }

      // Write to file
      await file.writeAsBytes(bytes);

      print('PDF report downloaded successfully to $filePath');
      print('File size: ${bytes.length} bytes');

      // Final progress callback
      if (onProgress != null) {
        onProgress(1.0);
      }

      return filePath;
    } catch (e) {
      print('Error downloading PDF report: $e');
      rethrow;
    }
  }

  /// Check PDF report service health
  ///
  /// Returns true if the PDF generation service is operational
  static Future<bool> checkPdfServiceHealth() async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl(ApiConfig.pdfReportHealthEndpoint),
      );

      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      print('PDF service health check failed: $e');
      return false;
    }
  }

  /// Clean up old PDF files
  ///
  /// Deletes PDF files older than [daysToKeep] days
  /// from the temporary directory
  static Future<void> cleanupOldPdfs({int daysToKeep = 7}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();

      final files = tempDir.listSync();
      for (var file in files) {
        if (file.path.endsWith('.pdf') && file.path.contains('hishab-analytics')) {
          final fileStat = await file.stat();
          final fileAge = now.difference(fileStat.modified);

          if (fileAge.inDays > daysToKeep) {
            await file.delete();
            print('Deleted old PDF: ${file.path}');
          }
        }
      }
    } catch (e) {
      print('Error cleaning up old PDFs: $e');
    }
  }
}
