import 'package:flutter/material.dart';
import 'package:hrms/styles.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool readOnly;
  final int maxLines;
  final Color? fillColor;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.readOnly = true,
    this.maxLines = 1,
    this.onTap,
    this.fillColor = Colors.white,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
      ), // Replace with your custom style
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: fillColor,
        hintStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
        ), // Replace with your custom hint style
        border: customBorder(
          borderColor: Styles.primaryColor,
        ),
        focusedErrorBorder: customBorder(
          borderColor: Styles.primaryColor,
        ),
        disabledBorder: customBorder(
          borderColor: Styles.primaryColor,
        ),
        enabledBorder: customBorder(
          borderColor: Styles.primaryColor,
        ),
        focusedBorder: customBorder(
          borderColor: Styles.primaryColor,
        ),
        errorBorder: customBorder(
          borderColor: Colors.red,
        ),
        contentPadding: maxLines != 1
            ? const EdgeInsets.symmetric(horizontal: 15, vertical: 6)
            : const EdgeInsets.only(left: 15, top: 6),
        suffixIcon: maxLines != 1
            ? null
            : const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.black54,
                ),
              ),
        // border: InputBorder.none,
      ),
      onTap: onTap,
    );
  }

  InputBorder customBorder({required Color borderColor, double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(color: borderColor, width: width),
    );
  }
}
