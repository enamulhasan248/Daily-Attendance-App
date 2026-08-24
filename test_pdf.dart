import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  final fallbackTtf = pw.Font.helvetica(); // dummy
  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(fontFallback: [fallbackTtf]),
  );
  pdf.addPage(pw.Page(build: (pw.Context context) => pw.Text("Hello")));
  try {
    pdf.save();
    print("Success");
  } catch(e) {
    print("Error: $e");
  }
}
