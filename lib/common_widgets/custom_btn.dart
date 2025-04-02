import 'package:flutter/material.dart';
import 'package:hrms/common_widgets/common_styles.dart';

class CustomBtn extends StatelessWidget {
  final Color? backgroundColor;
  final Color? btnTextColor;
  final double? radius;
  final IconData? icon;
  final String btnText;
  const CustomBtn({
    super.key,
    this.backgroundColor = CommonStyles.primaryColor,
    this.radius = 10,
    this.icon,
    required this.btnText,
    this.btnTextColor = CommonStyles.whiteColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius!),
          side: const BorderSide(color: CommonStyles.primaryColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      icon: Icon(
        icon ?? Icons.camera_alt_outlined,
        size: 20,
        color: btnTextColor,
      ),
      label: Text(
        btnText,
        style: TextStyle(color: btnTextColor),
      ),
    );
  }
}
