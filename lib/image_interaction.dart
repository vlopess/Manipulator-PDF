import 'dart:math';

import 'package:flutter/material.dart';

class ImageInteraction extends StatefulWidget {
  final String imagePath;
  const ImageInteraction({super.key, required this.imagePath});

  @override
  State<ImageInteraction> createState() => _ImageInteractionState();
}

class _ImageInteractionState extends State<ImageInteraction> {
  double? _top;
  double? _left;
  @override
  Widget build(BuildContext context) {
    _top ??= MediaQuery.of(context).size.height / 2;
    _left ??= MediaQuery.of(context).size.width / 2;
    return Positioned(
      top: _top,
      left: _left,
      child: GestureDetector(
        onPanUpdate: (details) {
          _top = max(0, _top! + details.delta.dy);
          _left = max(0, _left! + details.delta.dx);
          setState(() {});
        },
        child: Image.network(
          widget.imagePath,
          scale: 3
        ),
      )
    );
  }
}