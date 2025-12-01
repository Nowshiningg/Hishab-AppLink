import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';

/// Download API Service
/// Handles APK download functionality

class DownloadApiService {
  /// Get APK information
  /// 
  /// Returns: Map with APK version, size, and download URL
  static Future<Map<String, dynamic>?> getApkInfo() async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(ApiConfig.apkInfoEndpoint));
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'] as Map<String, dynamic>;
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('APK info error: $e');
    }
  }

  /// Download APK file
  /// 
  /// [onProgress]: Optional callback for download progress (0.0 to 1.0)
  /// 
  /// Returns: File path of downloaded APK
  static Future<String?> downloadApk({
    Function(double)? onProgress,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(ApiConfig.apkDownloadEndpoint));
      
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/hishab_latest.apk';
      
      // Check if file already exists and delete it
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Start download
      final request = http.Request('GET', url);
      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        final contentLength = streamedResponse.contentLength ?? 0;
        var downloadedBytes = 0;

        // Create file and write chunks
        final sink = file.openWrite();
        
        await for (var chunk in streamedResponse.stream) {
          sink.add(chunk);
          downloadedBytes += chunk.length;
          
          if (contentLength > 0 && onProgress != null) {
            final progress = downloadedBytes / contentLength;
            onProgress(progress);
          }
        }
        
        await sink.close();
        
        if (onProgress != null) {
          onProgress(1.0);
        }
        
        return filePath;
      }
      
      return null;
    } catch (e) {
      throw Exception('APK download error: $e');
    }
  }

  /// Get download URL for APK
  /// 
  /// Returns: Direct download URL
  static String getApkDownloadUrl() {
    return ApiConfig.getFullUrl(ApiConfig.apkDownloadEndpoint);
  }

  /// Check if newer version is available
  /// 
  /// [currentVersion]: Current app version
  /// 
  /// Returns: true if update is available
  static Future<bool> isUpdateAvailable({
    required String currentVersion,
  }) async {
    try {
      final info = await getApkInfo();
      if (info != null && info['version'] != null) {
        final latestVersion = info['version'] as String;
        return _compareVersions(currentVersion, latestVersion) < 0;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Compare two version strings
  /// Returns: -1 if v1 < v2, 0 if equal, 1 if v1 > v2
  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    
    for (var i = 0; i < parts1.length && i < parts2.length; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }
    
    if (parts1.length < parts2.length) return -1;
    if (parts1.length > parts2.length) return 1;
    
    return 0;
  }
}
