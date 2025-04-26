import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'logger.dart';

class VersionManager {
  static const String githubRepo =
      'yourusername/organizdor'; // Replace with your GitHub repo
  static const String githubApiUrl =
      'https://api.github.com/repos/$githubRepo/releases/latest';

  static Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<String?> getLatestVersion() async {
    try {
      final response = await http.get(Uri.parse(githubApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['tag_name']?.toString().replaceAll('v', '');
      }
      return null;
    } catch (e) {
      AppLogger.error('Error checking for updates', e);
      return null;
    }
  }

  static Future<bool> isUpdateAvailable() async {
    final currentVersion = await getCurrentVersion();
    final latestVersion = await getLatestVersion();

    if (latestVersion == null) return false;

    final currentParts = currentVersion.split('.');
    final latestParts = latestVersion.split('.');

    for (int i = 0; i < 3; i++) {
      final current = int.tryParse(currentParts[i]) ?? 0;
      final latest = int.tryParse(latestParts[i]) ?? 0;

      if (latest > current) return true;
      if (latest < current) return false;
    }
    return false;
  }

  static Future<void> showUpdateDialog(BuildContext context) async {
    final latestVersion = await getLatestVersion();
    if (latestVersion == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Actualización disponible'),
        content: Text(
            'Hay una nueva versión ($latestVersion) disponible. ¿Desea actualizar ahora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Más tarde'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = 'https://github.com/$githubRepo/releases/latest';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}
