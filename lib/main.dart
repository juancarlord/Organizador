import 'package:flutter/material.dart';
import 'app.dart';
import 'utils/logger.dart';
import 'utils/version_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize();
  AppLogger.info('Application starting...');

  runApp(const DocumentOrganizerApp());

  // Check for updates
  final isUpdateAvailable = await VersionManager.isUpdateAvailable();
  if (isUpdateAvailable) {
    // We'll show the update dialog when the app is fully loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VersionManager.showUpdateDialog(
          DocumentOrganizerApp.navigatorKey.currentContext!);
    });
  }
}
