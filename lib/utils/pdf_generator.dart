/// PDF generator — creates a color-coded attendance calendar PDF.
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/attendance_entry.dart';
import '../utils/constants.dart';
import '../utils/pay_month.dart';

class PdfGenerator {
  static Future<void> generateAttendancePdf({
    required String userName,
    required String employeeId,
    required PayMonth payMonth,
    required Map<String, dynamic> entries,
  }) async {
    final fontData = await rootBundle.load('assets/fonts/HindSiliguri-Regular.ttf');
    final fallbackTtf = pw.Font.ttf(fontData);

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(fontFallback: [fallbackTtf]),
    );

    // Color conversion helper.
    PdfColor statusPdfColor(AttendanceStatus status) {
      final c = status.color;
      return PdfColor(c.r, c.g, c.b);
    }

    final dates = payMonth.allDates;
    final startWeekday = dates.first.weekday;
    final leadingEmpty = startWeekday - 1;
    final dayHeaders = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Attendance Sheet',
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(payMonth.displayLabel, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(userName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text('ID: $employeeId', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 12),

              // Calendar Grid
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: dayHeaders.map((d) => pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(d, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    )).toList(),
                  ),
                  // Data rows
                  ..._buildCalendarRows(dates, leadingEmpty, entries, statusPdfColor),
                ],
              ),
              pw.SizedBox(height: 16),

              // Legend
              pw.Text('Legend', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Wrap(
                spacing: 16,
                runSpacing: 4,
                children: AttendanceStatus.values.map((status) {
                  return pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(
                        width: 12, height: 12,
                        decoration: pw.BoxDecoration(
                          color: statusPdfColor(status),
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                      ),
                      pw.SizedBox(width: 4),
                      pw.Text('${status.shortLabel} - ${status.label}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  );
                }).toList(),
              ),

              // Summary
              pw.SizedBox(height: 16),
              pw.Text('Summary', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Wrap(
                spacing: 20,
                runSpacing: 4,
                children: AttendanceStatus.values.map((status) {
                  final count = entries.values.where((e) => (e as AttendanceEntry).status == status).length;
                  return pw.Text('${status.label}: $count', style: const pw.TextStyle(fontSize: 10));
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final startDateStr = payMonth.startDate.toIso8601String().split('T')[0];
    final endDateStr = payMonth.endDate.toIso8601String().split('T')[0];
    final fileName = '${userName}_${employeeId}_$startDateStr-$endDateStr.pdf';

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: fileName,
    );
  }

  static List<pw.TableRow> _buildCalendarRows(
    List<DateTime> dates,
    int leadingEmpty,
    Map<String, dynamic> entries,
    PdfColor Function(AttendanceStatus) colorFn,
  ) {
    final rows = <pw.TableRow>[];
    final totalCells = leadingEmpty + dates.length;
    final rowCount = (totalCells / 7).ceil();

    for (var row = 0; row < rowCount; row++) {
      final cells = <pw.Widget>[];
      for (var col = 0; col < 7; col++) {
        final cellIndex = row * 7 + col;
        if (cellIndex < leadingEmpty || cellIndex >= leadingEmpty + dates.length) {
          cells.add(pw.Container(padding: const pw.EdgeInsets.all(6)));
        } else {
          final date = dates[cellIndex - leadingEmpty];
          final dateStr = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final entry = entries[dateStr] as AttendanceEntry?;

          cells.add(
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(4),
              decoration: pw.BoxDecoration(
                color: entry != null ? colorFn(entry.status).flatten() : null,
              ),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    '${date.day}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: entry != null ? PdfColors.white : PdfColors.black,
                    ),
                  ),
                  if (entry != null)
                    pw.Text(
                      entry.status.shortLabel,
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.white),
                    ),
                ],
              ),
            ),
          );
        }
      }
      rows.add(pw.TableRow(children: cells));
    }
    return rows;
  }
}
