import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/constants.dart';

class DirectorySelector extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String selectedDirectory;
  final Function(String) onDirectorySelected;

  const DirectorySelector({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.selectedDirectory,
    required this.onDirectorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: hintText,
              filled: true,
              fillColor: Colors.grey[100],
            ),
            controller: TextEditingController(text: selectedDirectory),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () async {
            final pickedDirectory =
                await FilePicker.platform.getDirectoryPath();
            if (pickedDirectory != null) {
              onDirectorySelected(pickedDirectory);
            }
          },
          icon: const Icon(Icons.folder_open),
          label: const Text(AppStrings.browse),
        ),
      ],
    );
  }
}
