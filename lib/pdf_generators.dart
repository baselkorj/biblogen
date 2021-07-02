import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

final pdf = pw.Document();

Future savePDF() async {
  File file = File('/storage/emulated/0/Download/example.pdf');
  file.writeAsBytesSync(await pdf.save());
}

Future generatePDF() async {
  pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return <pw.Widget>[
          pw.Center(
              child: pw.Header(
                  level: 0,
                  child: pw.Text('Analog Oxygen Monitor Biblography'))),
          pw.Paragraph(text: "Hello World!")
        ];
      }));
  print('PDF Generated.');
  await savePDF();
  print('PDF Saved.');
  OpenFile.open('/storage/emulated/0/Download/example.pdf');
}
