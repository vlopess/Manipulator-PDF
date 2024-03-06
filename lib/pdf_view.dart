import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_start_app_teste/image_interaction.dart';

class PdfView extends StatefulWidget {
  final String pdfName;
  final List<Uint8List?> images;
  const PdfView({super.key, required this.images, required this.pdfName});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  bool showSignature = false;
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
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: MaterialButton(
                  onPressed: () {                  
                  },
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),     
                  color: const Color.fromRGBO(0, 255, 0, 1),
                  child: const Text('Save', style: TextStyle(color: Colors.white),),
                ),
             ),
          ],
          centerTitle: true,
        ),
        body: Stack(
          children: [            
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(image: MemoryImage(images[index]!)),
                    );                        
                  },
              ),
            ),    
            Visibility(
              visible: showSignature,
              child: const ImageInteraction(imagePath: 'https://th.bing.com/th/id/OIP.uxEh9iC2xrs8Cf_iXCcPsAHaDF?rs=1&pid=ImgDetMain')
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
}