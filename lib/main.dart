// ignore_for_file: use_super_parameters

import 'dart:developer';
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
  late List<Uint8List?> images;
  late final String pdfName;

  bool open = false;

  PdfImageRendererPdf? pdf;
  int? count;
  PdfImageRendererPageSize? size;

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
                          log(count.toString());
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
                            images.add(imagePdf);
                          }
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => PdfView(images: images),));
                          //await renderPage();
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
                // if (open == true) ...[
                //   Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: <Widget>[
                //       TextButton.icon(
                //         onPressed: pageIndex > 0
                //             ? () async {
                //                 pageIndex = 1;
                //                 await renderPage();
                //               }
                //             : null,
                //         icon: const Icon(Icons.chevron_left),
                //         label: const Text('Previous'),
                //       ),
                //       TextButton.icon(
                //         onPressed: pageIndex < (count! - 1)
                //             ? () async {
                //                 pageIndex = 1;
                //                 await renderPage();
                //               }
                //             : null,
                //         icon: const Icon(Icons.chevron_right),
                //         label: const Text('Next'),
                //       ),
                //     ],
                //   ),
                // ]
              ],
            ),
          ),
        ),
      );
  }
}




// // ignore_for_file: no_leading_underscores_for_local_identifiers

// import 'dart:math';

// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Teste PDF Manipulation'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//     double _top = 0;
//     double _left = 0;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Stack(
//         children: [
//           Positioned(
//             top: _top,
//             left: _left,
//             child: GestureDetector(
//               onPanUpdate: (details) {
//                 _top = max(0, _top + details.delta.dy);
//                 _left = max(0, _left + details.delta.dx);
//                 setState(() {});
//               },
//               child: Image.network(
//                 'https://www.techupdates.net/wp-content/uploads/2021/02/Flutter.png',
//                 scale: 4
//               ),
//             )
//           ),
//         ],
//       )
//     );
//   }
// }
