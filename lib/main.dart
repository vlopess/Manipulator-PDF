// ignore_for_file: use_super_parameters

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_start_app_teste/pdf_view.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';

void main() => runApp(
  const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: '',
    home: MyApp(),
  )
);

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int pageIndex = 1;
  Uint8List? image;
  late List<Uint8List> images;
  late final String pdfName;

  bool open = false;

  PdfImageRendererPdf? pdf;
  int? count;
  PdfImageRendererPageSize? size  ;

  bool cropped = false;

  int asyncTasks = 0;
  
  var _isSelected = true;

  @override
  void initState() {
    super.initState();
    images = List.empty(growable: true);
  }

  Future<void> renderPage() async {
    size = await pdf!.getPageSize(pageIndex: pageIndex);
    final i = await pdf!.renderPage(
      pageIndex: pageIndex,
      x: cropped ? 100 : 0,
      y: cropped ? 100 : 0,
      width: cropped ? 100 : size!.width,
      height: cropped ? 100 : size!.height,
      scale: 3,
      background: Colors.white,
    );

    setState(() {
      image = i;
    });
  }

  Future<void> renderPageMultipleTimes() async {
    const count = 50;

    await pdf!.openPage(pageIndex: pageIndex);

    size = await pdf!.getPageSize(pageIndex: pageIndex);

    asyncTasks = count;

    final renderFutures = <Future<Uint8List?>>[];
    for (var i = 0; i < count; i++) {
      final future = pdf!.renderPage(
        pageIndex: pageIndex,
        x: (size!.width / count * i).round(),
        y: (size!.height / count * i).round(),
        width: (size!.width / count).round(),
        height: (size!.height / count).round(),
        scale: 3,
        background: Colors.white,
      );

      renderFutures.add(future);

      future.then((value) {
        setState(() {
          asyncTasks--;
        });
      });
    }

    await Future.wait(renderFutures);

    await pdf!.closePage(pageIndex: pageIndex);
  }

  Future<void> openPdf({required String path}) async {
    if (pdf != null) {
      await pdf!.close();
    }
    pdf = PdfImageRendererPdf(path: path);
    await pdf!.open();
    setState(() {
      open = true;
    });
  }

  Future<void> closePdf() async {
    if (pdf != null) {
      await pdf!.close();
      setState(() {
        pdf = null;
        open = false;
      });
    }
  }

  Future<void> openPdfPage({required int pageIndex}) async {
    await pdf!.openPage(pageIndex: pageIndex);
  }

  Future<void> closePdfPage({required int pageIndex}) async {
    await pdf!.closePage(pageIndex: pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Visibility(
                  visible: _isSelected,
                  child: ElevatedButton(
                    child: const Text('Select PDF'),
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles();                       
                        if (result != null) {
                          setState(() {
                            _isSelected = !_isSelected;
                            pdfName = result.names[0]!;
                          });
                          await openPdf(path: result.paths[0]!);
                          count = await pdf!.getPageCount();
                          for (var i = 0; i < count!; i++) {
                            size = await pdf!.getPageSize(pageIndex: i);
                            final imagePdf = await pdf!.renderPage(
                              pageIndex: i,
                              x: cropped ? 100 : 0,
                              y: cropped ? 100 : 0,
                              width: cropped ? 100 : size!.width,
                              height: cropped ? 100 : size!.height,
                              scale: 3,
                              background: Colors.white,
                            );
                            images.add(imagePdf!);
                          }
                        }
                      },
                  )
                ),     
                Visibility(
                  visible: !_isSelected,
                  child: ElevatedButton(
                    child: const Text('See PDF'),
                      onPressed: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PdfView(images: images, pdfName: pdfName,),));
                      },
                  )
                ),   
              ],
            ),
          ),
        ),
      );
  }
}