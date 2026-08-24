import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  final fontData = File('assets/fonts/HindSiliguri-Regular.ttf').readAsBytesSync();
  final fallbackTtf = pw.Font.ttf(fontData.buffer.asByteData());
  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(fontFallback: [fallbackTtf]),
  );
  pdf.addPage(pw.Page(build: (pw.Context context) => pw.Text("Hello বাংলা")));
  try {
    pdf.save();
    print("Success");
  } catch(e) {
    print("Error: $e");
  }
}
