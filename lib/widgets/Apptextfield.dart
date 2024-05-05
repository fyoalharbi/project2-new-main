import 'package:flutter/material.dart';

class Apptextfield extends StatelessWidget {
  final String hintText;
  final IconData? icon;
  final Color iconColor;
  final double width;
  final double height;
  final Color? borderColor;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final VoidCallback? onIconPressed;

  const Apptextfield({
    super.key,
    required this.hintText,
    this.icon,
    this.iconColor = const Color(0xFF2D2689),
    this.width = 400.0,
    this.height = 50.5,
    this.borderColor,
    required this.controller, this.validator,
    this.onIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        validator: validator,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.8)),
          prefixIcon: icon != null
              ? IconButton(

            icon: Icon(icon),
            color: iconColor,
            onPressed: onIconPressed,
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.all(12.0),
        ),
      ),
    );
  }
}
