import 'package:flutter/material.dart';

class Appbuttons extends StatelessWidget {
  final Color? textColor;
  final Color? backgroundColor;
  final Color borderColor;
  final String text;
  final String? routeName;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  Appbuttons({
    Key? key,
    this.textColor,
    this.backgroundColor,
    this.borderColor = const Color(0xFF2D2689),
    required this.text,
    this.routeName,
    this.onPressed,
    this.width = 400,
    this.height = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onPressed != null) {
              onPressed!();
            } else if (routeName != null) {
              Navigator.pushNamed(context, routeName!);
            }
          },
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.white,
              ),
            ),
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor ?? Color(0xFF2D2689),
        border: Border.all(width: 1, color: borderColor),
      ),
    );
  }
}