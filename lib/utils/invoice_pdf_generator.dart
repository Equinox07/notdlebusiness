import 'dart:typed_data';
import 'package:notdle/models/invoice.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(24.0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('INVOICE', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Invoice ID: ${invoice.id}'),
              pw.Text('Customer ID: ${invoice.customerId}'),
              pw.Text('Order ID: ${invoice.orderId}'),
              pw.Text('Status: ${invoice.status}'),
              pw.Text('Total Amount: \$${invoice.total?.toStringAsFixed(2)}'),
              pw.Text('Date: ${invoice.date!.toIso8601String()}'),
              pw.SizedBox(height: 16),
              pw.Text('Created: ${invoice.createdDate}'),
              pw.Text('Updated: ${invoice.updatedDate}'),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}


// import 'package:printing/printing.dart';
// import '../utils/invoice_pdf_generator.dart';
//
// void previewPdf(BuildContext context, Invoice invoice) async {
//   final pdfData = await generateInvoicePdf(invoice);
//
//   await Printing.layoutPdf(
//     onLayout: (format) async => pdfData,
//     name: 'invoice_${invoice.id}.pdf',
//   );
// }
