// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation — triggers a browser file download.
void downloadCsv(String csvContent, String fileName) {
  // BOM + CSV content as a single string for proper encoding
  final bom = '\uFEFF'; // UTF-8 BOM for Excel compatibility
  final blob = html.Blob(['$bom$csvContent'], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
