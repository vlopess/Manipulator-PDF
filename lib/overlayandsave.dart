import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;


Future<pw.Document> saveImageAsPdf(List<Uint8List> imagesBytes, String filename, double top, double left, Uint8List signatureBytes, int signatureIndexPage) async {
  final pdf = pw.Document();

  final signatureImage = pw.MemoryImage(signatureBytes);
  final signature = pw.Positioned(top: (top + 400), left: (left + 25), child: pw.Image(signatureImage, width: 500));


  for (var index = 0; index < imagesBytes.length; index++) {
    final imageBytes = imagesBytes[index];
    final background = pw.MemoryImage(imageBytes);
    final decodedImage = img.decodeImage(imageBytes);
    final pageWidth = decodedImage!.width.toDouble();
    final pageHeight = decodedImage.height.toDouble();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pageWidth, pageHeight),
        build: (context) {
          return pw.Stack(
            children: [
              pw.Image(background, width: pageWidth, height: pageHeight),
              if(signatureIndexPage == index) signature
            ],
          );
        },
      ),
    );
  }

  final dir = await getDownloadsDirectory();
  final file = File('${dir!.path}/$filename.pdf');
  await file.writeAsBytes(await pdf.save());
  return pdf;
}




