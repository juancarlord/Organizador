import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/constants.dart';
import '../widgets/directory_selector.dart';
import 'processing_screen_2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedDirectory = '';
  String outputDirectory = '';
  bool createZipArchives = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 40,
            ),
            const SizedBox(width: 12),
            const Text(
              AppStrings.appTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.configuration,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.directorySelection,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DirectorySelector(
                      labelText: AppStrings.sourceDirectory,
                      hintText: AppStrings.selectSourceDirectory,
                      selectedDirectory: selectedDirectory,
                      onDirectorySelected: (directory) {
                        setState(() {
                          selectedDirectory = directory;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DirectorySelector(
                      labelText: AppStrings.outputDirectory,
                      hintText: AppStrings.selectDestinationDirectory,
                      selectedDirectory: outputDirectory,
                      onDirectorySelected: (directory) {
                        setState(() {
                          outputDirectory = directory;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.processingOptions,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text(AppStrings.createZip),
                      subtitle: const Text(AppStrings.zipDescription),
                      value: createZipArchives,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          createZipArchives = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed:
                    selectedDirectory.isNotEmpty && outputDirectory.isNotEmpty
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProcessingScreen(
                                  sourceDirectory: selectedDirectory,
                                  outputDirectory: outputDirectory,
                                  createZipArchives: createZipArchives,
                                ),
                              ),
                            );
                          }
                        : null,
                icon: const Icon(Icons.play_arrow),
                label: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    AppStrings.startOrganization,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
