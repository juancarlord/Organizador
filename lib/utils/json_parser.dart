import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

class JsonParser {
  static Future<String?> extractDocumentNumber(String jsonFilePath) async {
    try {
      final file = File(jsonFilePath);
      final content = await file.readAsString();
      final jsonData = jsonDecode(content);

      // Check if the file ends with digits (not CUV)
      final fileName = path.basename(jsonFilePath);
      if (!RegExp(r'\d+\.json$').hasMatch(fileName)) {
        return null;
      }

      // Extract numDocumentoIdentificacion from the first user
      if (jsonData['usuarios'] != null &&
          jsonData['usuarios'] is List &&
          jsonData['usuarios'].isNotEmpty) {
        return jsonData['usuarios'][0]['numDocumentoIdentificacion'] as String?;
      }

      return null;
    } catch (e) {
      print('Error parsing JSON file $jsonFilePath: $e');
      return null;
    }
  }
}
