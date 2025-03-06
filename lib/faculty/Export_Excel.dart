import 'dart:html' as html;
import 'dart:typed_data';
class export_excel{
  void export_excel_file_web(var sub,var excelBytes){
      final blob = html.Blob([Uint8List.fromList(excelBytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "$sub AttendanceSheet.xlsx")
        ..click();
      html.Url.revokeObjectUrl(url);
  }
}