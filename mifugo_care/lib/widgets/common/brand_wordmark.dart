import 'package:flutter/material.dart';

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 22, this.fontWeight = FontWeight.w800});

  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      'MifugoCare',
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: 0.2,
      ),
    );
  }
}


