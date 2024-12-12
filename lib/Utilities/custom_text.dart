import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? clr;
  final double? fs;
  final double? ls;
  final FontWeight? fw;
  final String? fontFamily;
  const CustomText({super.key, required this.text, this.clr, this.fs, this.ls, this.fw, this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: clr,
        fontFamily: fontFamily,
        fontSize: fs,
        fontWeight: fw,
        letterSpacing: ls,
      ),
    );
  }
}
