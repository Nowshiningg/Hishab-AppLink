import 'package:flutter/material.dart';
import '../services/banglalink_integration_service.dart';

/// Service to check and download app updates via Banglalink API
class UpdateCheckerService {
  static final _blService = BanglalinkIntegrationService();

  /// Check for updates and show dialog if available
  /// [currentVersion] - Current app version (e.g., "1.0.0")
  /// [context] - BuildContext for showing dialogs
  static Future<void> checkForUpdates(
    BuildContext context,
    String currentVersion,
  ) async {
    try {
      final updateAvailable = await _blService.isUpdateAvailable(
        currentVersion: currentVersion,
      );

      if (updateAvailable && context.mounted) {
        _showUpdateDialog(context);
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  /// Show update available dialog
  static void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.system_update, color: Color(0xFFF16725), size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text('Update Available'),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new version of Hishab is available!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Update now to get:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text('Latest features')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text('Performance improvements')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text('Bug fixes')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadUpdate(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF16725),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  /// Download and install update
  static Future<void> _downloadUpdate(BuildContext context) async {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Downloading Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Please wait...'),
          ],
        ),
      ),
    );

    try {
      final filePath = await _blService.downloadApk(
        onProgress: (p) {
          debugPrint('Download progress: ${(p * 100).toInt()}%');
        },
      );

      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        
        if (filePath != null) {
          _showInstallDialog(context, filePath);
        } else {
          _showErrorDialog(context, 'Download failed. Please try again.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        _showErrorDialog(context, 'Error downloading update: $e');
      }
    }
  }

  /// Show install instructions dialog
  static void _showInstallDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text('Download Complete'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The update has been downloaded successfully!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder, color: Color(0xFFF16725)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      filePath,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Open the downloaded file to install the update. You may need to allow installation from unknown sources.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF16725),
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text('Update Failed'),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF16725),
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Manual update check button widget
  static Widget buildUpdateButton(BuildContext context, String currentVersion) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF16725).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.system_update_alt,
          color: Color(0xFFF16725),
        ),
      ),
      title: const Text(
        'Check for Updates',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Current version: $currentVersion'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        // Show checking dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Checking for updates...'),
              ],
            ),
          ),
        );

        try {
          final updateAvailable = await _blService.isUpdateAvailable(
            currentVersion: currentVersion,
          );

          if (context.mounted) {
            Navigator.pop(context); // Close checking dialog

            if (updateAvailable) {
              _showUpdateDialog(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You have the latest version!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context); // Close checking dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error checking updates: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }
}
