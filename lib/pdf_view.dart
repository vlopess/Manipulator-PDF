import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:my_start_app_teste/overlayandsave.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:visibility_detector/visibility_detector.dart';


class PdfView extends StatefulWidget {
  final String pdfName;
  final List<Uint8List> images;
  const PdfView({super.key, required this.images, required this.pdfName});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  bool showSignature = false;
  String imagePath = "https://th.bing.com/th/id/OIP.uxEh9iC2xrs8Cf_iXCcPsAHaDF?rs=1&pid=ImgDetMain";
  Offset assinaturaPos = const Offset(0, 0);
  int currentPageIndex = 0;
  final GlobalKey imageKey = GlobalKey();  
  bool already = false;

  @override
  Widget build(BuildContext context) {


    var images = widget.images;
    return Scaffold(
        backgroundColor: const Color(0xFFEDF3F7),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.green),
            onPressed: () => Navigator.of(context).pop(),
          ), 
          title: Text(widget.pdfName, style: const TextStyle(fontSize: 22),),
          actions: [
             Visibility(
              visible: already,
              child: MaterialButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PdfView(images: images, pdfName: 'filename'),)),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),     
                color: const Color.fromRGBO(0, 255, 0, 1),
                child: const Text('Ver', style: TextStyle(color: Colors.white),),
              )
             ),
             Visibility(
               visible: !already,
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: MaterialButton(
                    onPressed: () async {      
                      final RenderBox box = imageKey.currentContext!.findRenderObject() as RenderBox;
                      final imagePosition = box.localToGlobal(Offset.zero);
                      final imageSize = box.size;
               
                      final relativeDx = assinaturaPos.dx - imagePosition.dx;
                      final relativeDy = assinaturaPos.dy - imagePosition.dy;
               
                      final decodedImage = img.decodeImage(images[currentPageIndex]);
                      final pdfWidth = decodedImage!.width.toDouble();
                      final pdfHeight = decodedImage.height.toDouble();
               
                      final scaleX = pdfWidth / imageSize.width;
                      final scaleY = pdfHeight / imageSize.height;
               
                      final leftInPdf = relativeDx * scaleX;
                      final topInPdf = relativeDy * scaleY;
                      final signature = await fetchImageAsUint8List(imagePath);
                      
                      await saveImageAsPdf(
                        images,
                        "filename",
                        topInPdf,
                        leftInPdf,
                        signature,
                        currentPageIndex
                      ).then((pathFile) async {                      
                        setState(() {
                          already = true;
                        });
                      });                        
                    },
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),     
                    color: const Color.fromRGBO(0, 255, 0, 1),
                    child: const Text('Save', style: TextStyle(color: Colors.white),),
                  ),
               ),
             ),
          ],
          centerTitle: true,
        ),
        body: Stack(
          children: [            
            ListView.builder(
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return VisibilityDetector(
                  key: Key('image-$index'),
                  onVisibilityChanged: (info) {
                    if (info.visibleFraction > 0.5) {
                      setState(() {
                        currentPageIndex = index;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(
                      key: index == currentPageIndex ? imageKey : null,
                      image: MemoryImage(widget.images[index])
                    ),
                  ),
                );
              },
            ),
            Visibility(
              visible: showSignature,
              child: Positioned(
                top: assinaturaPos.dy,
                left: assinaturaPos.dx,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    assinaturaPos += details.delta;
                    setState(() {});
                  },
                  child: Image.network(
                    imagePath,
                    scale: 4
                  ),
                )
              )
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSignature,
        tooltip: 'Increment',
        child: const Icon(Icons.border_color),
      ),
      );
  }

  void _showSignature() => setState(() => showSignature = true);

  PdfImageRendererPdf? pdf;
  Future<void> openPdf({required String path}) async {
    if (pdf != null) {
      await pdf!.close();
    }
    pdf = PdfImageRendererPdf(path: path);
    await pdf!.open();
  }
}

Future<Uint8List> fetchImageAsUint8List(String imageUrl) async {
  // Faz a requisição HTTP para obter a imagem
  final response = await http.get(Uri.parse(imageUrl));

  // Se a requisição for bem-sucedida, converte a imagem em Uint8List
  if (response.statusCode == 200) {
    return response.bodyBytes;  // bodyBytes é do tipo Uint8List
  } else {
    throw Exception('Falha ao carregar a imagem');
  }
}