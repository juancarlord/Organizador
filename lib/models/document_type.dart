class DocumentType {
  final String name;
  final String folderName;

  const DocumentType({
    required this.name,
    required this.folderName,
  });

  static const Map<String, DocumentType> types = {
    'ORDEN MEDICA': DocumentType(
      name: 'ORDEN MEDICA',
      folderName: 'ORDEN MEDICA',
    ),
    'REPORTE': DocumentType(
      name: 'REPORTE',
      folderName: 'REPORTE',
    ),
    'FACTURA': DocumentType(
      name: 'FACTURA',
      folderName: 'FACTURA',
    ),
    'DETALLE DE CARGOS': DocumentType(
      name: 'DETALLE DE CARGOS',
      folderName: 'DETALLE DE CARGOS',
    ),
    'JSON': DocumentType(
      name: 'JSON',
      folderName: 'JSON',
    ),
    'CUV': DocumentType(
      name: 'CUV',
      folderName: 'CUV',
    ),
    'XML': DocumentType(
      name: 'XML',
      folderName: 'XML',
    ),
    'OTRO': DocumentType(
      name: 'OTRO',
      folderName: 'OTROS',
    ),
  };
}
