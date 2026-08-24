/// TA/DA export — CSV and PDF export for monthly TA/DA summary.
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/tada_entry.dart';
import '../utils/pay_month.dart';

class TadaExport {
  static final _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// Export TA/DA entries as CSV and share.
  static Future<void> exportCsv({
    required String userName,
    required String employeeId,
    required PayMonth payMonth,
    required List<TadaEntry> entries,
  }) async {
    final rows = <List<dynamic>>[
      ['TA/DA Report - $userName (ID: $employeeId)'],
      ['Period: ${payMonth.displayLabel}'],
      [],
      ['Date', 'Purpose', 'Amount', 'Remarks'],
      ...entries.map((e) => [
            e.dateString,
            e.purpose,
            e.amount.toStringAsFixed(2),
            e.remarks,
          ]),
      [],
      ['Total', '', entries.fold(0.0, (s, e) => s + e.amount).toStringAsFixed(2), ''],
    ];

    final startDateStr = payMonth.startDate.toIso8601String().split('T')[0];
    final endDateStr = payMonth.endDate.toIso8601String().split('T')[0];
    final fileName = 'TADA_${userName}_${employeeId}_$startDateStr-$endDateStr.csv';

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)]);
  }

  /// Export TA/DA entries as PDF and share/print.
  static Future<void> exportPdf({
    required String userName,
    required String employeeId,
    required PayMonth payMonth,
    required List<TadaEntry> entries,
  }) async {
    final fontData = await rootBundle.load('assets/fonts/HindSiliguri-Regular.ttf');
    final fallbackTtf = pw.Font.ttf(fontData);

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(fontFallback: [fallbackTtf]),
    );
    final total = entries.fold(0.0, (s, e) => s + e.amount);

    // Group by date.
    final grouped = <String, List<TadaEntry>>{};
    for (final e in entries) {
      grouped.putIfAbsent(e.dateString, () => []).add(e);
    }
    // entries are already sorted by date from the DB query.

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('TA/DA Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text(payMonth.displayLabel, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(userName, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    pw.Text('ID: $employeeId', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total: ${total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Page ${context.pageNumber}/${context.pagesCount}', style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        build: (context) {
          return [
            // Summary table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(1.5),
                1: pw.FlexColumnWidth(3),
                2: pw.FlexColumnWidth(1.5),
                3: pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: ['Date', 'Purpose', 'Amount', 'Remarks'].map((h) => pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(h, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  )).toList(),
                ),
                ...entries.map((e) {
                  final date = DateTime.parse(e.dateString);
                  return pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('${date.day} ${_monthNames[date.month - 1].substring(0, 3)}', style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(e.purpose, style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(e.amount.toStringAsFixed(2), style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(e.remarks, style: const pw.TextStyle(fontSize: 9)),
                      ),
                    ],
                  );
                }),
                // Total row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey50),
                  children: [
                    pw.Container(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Container(padding: const pw.EdgeInsets.all(6)),
                    pw.Container(padding: const pw.EdgeInsets.all(6), child: pw.Text(total.toStringAsFixed(2), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Container(padding: const pw.EdgeInsets.all(6)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    final startDateStr = payMonth.startDate.toIso8601String().split('T')[0];
    final endDateStr = payMonth.endDate.toIso8601String().split('T')[0];
    final fileName = 'TADA_${userName}_${employeeId}_$startDateStr-$endDateStr.pdf';

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: fileName,
    );
  }
}
