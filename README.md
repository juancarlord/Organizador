# Documento Organizador

A Flutter application designed to organize medical documents based on document numbers and MR numbers, with special handling for CAPRESOCA files.

## Features

- Organizes medical documents into structured folders
- Handles multiple document types:
  - Medical Orders (ORDEN MEDICA)
  - Authorizations (AUTORIZACION Y ORDEN)
  - Reports (REPORTE)
  - Invoices (FACTURA)
  - XML files
  - JSON and CUV files
  - Validations (VALIDACIONES)
  - Charges (CARGOS)
- Special file naming conventions:
  - Report files are appended with "\_RPT"
  - Validation files are appended with "\_VLD"
- Creates ZIP archives of organized folders
- Supports both document number and MR number based organization
- Progress tracking during organization
- Detailed logging of operations

## Requirements

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Windows/Linux/macOS operating system

## Installation

1. Clone the repository:

```bash
git clone [repository-url]
```

2. Navigate to the project directory:

```bash
cd documento_organizador
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

## Usage

1. Launch the application
2. Select the source directory containing your medical documents
3. Select the output directory where organized files will be placed
4. Choose whether to create ZIP archives
5. Click "Start Organization"

### Folder Structure

The application expects the following folder structure in the source directory:

- ORDEN MEDICA
- AUTORIZACION Y ORDEN
- REPORTE
- FACTURA
- XML
- JSON Y CUV
- VALIDACIONES
- CARGOS

Note: The application will work with any number of these folders. Missing folders will be skipped.

### File Naming Conventions

- Report files: `[original_name]_RPT.[extension]`
- Validation files: `[original_name]_VLD.[extension]`
- Other files maintain their original names

## Building

### Windows

```bash
flutter build windows
```

### Linux

```bash
flutter build linux
```

### macOS

```bash
flutter build macos
```

## Dependencies

- path_provider: ^2.1.0
- file_picker: ^5.3.3
- archive: ^3.3.7
- path: ^1.8.3
- provider: ^6.0.5
- intl: ^0.18.1
- url_launcher: ^6.2.5
- logging: ^1.2.0
- package_info_plus: ^5.0.1
- http: ^1.1.0
- msix: ^3.16.7

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue in the repository or contact the development team.

## Acknowledgments

- Flutter team for the amazing framework
- All contributors who have helped with the project
