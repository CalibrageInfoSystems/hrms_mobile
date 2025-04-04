import 'package:flutter/material.dart';
import 'package:hrms/common_widgets/common_styles.dart';

class CustomBtn extends StatelessWidget {
  final Color? backgroundColor;
  final Color? btnTextColor;
  final double? radius;
  final IconData? icon;
  final String btnText;
  final bool isLoading;
  final VoidCallback onTap;

  const CustomBtn({
    super.key,
    this.backgroundColor = CommonStyles.primaryColor,
    this.radius = 10,
    this.icon,
    required this.btnText,
    this.btnTextColor = CommonStyles.whiteColor,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isLoading ? CommonStyles.whiteColor : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius!),
          side: const BorderSide(color: CommonStyles.primaryColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: CommonStyles.primaryColor,
                strokeWidth: 2,
              ),
            )
          : Icon(
              icon ?? Icons.camera_alt_outlined,
              size: 20,
              color: btnTextColor,
            ),
      label: Text(
        isLoading ? 'Checking...' : btnText,
        style: TextStyle(
            color: isLoading ? CommonStyles.primaryColor : btnTextColor),
      ),
    );
  }
}
