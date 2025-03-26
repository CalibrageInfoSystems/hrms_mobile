
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonUtils{


  static void showCustomToastMessageLong(String message,
      BuildContext context,
      int backgroundColorType,
      int length,
      {double toastPosition = 16.0}) {
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final double textWidth = screenWidth / 1.5; // Adjust multiplier as needed

    final double toastWidth = textWidth + 32.0; // Adjust padding as needed
    final double toastOffset = (screenWidth - toastWidth) / 2;

    IconData iconData;
    Color iconColor;

    if (backgroundColorType == 0) {
      // Success
      iconData = Icons.check_circle;
      iconColor = Colors.green;
    } else {
      // Error
      iconData = Icons.error;
      iconColor = Colors.red;
    }

    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) =>
          Positioned(
            bottom: toastPosition, // Change to toastPosition
            left: toastOffset,
            child: Material(
              color: Colors.transparent, // Changed to transparent to cover entire screen
              child: Center(
                child: Container(
                  width: toastWidth,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: backgroundColorType == 0 ? Colors.green : Colors.red,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white
                   // color: backgroundColorType == 0 ? Color(0x6F4CAF50) : Color(0xBBD97E72),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(iconData, color: iconColor), // Icon
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(fontSize: 16.0, color: Colors.black, fontFamily: 'Outfit'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(Duration(seconds: length)).then((value) {
      overlayEntry.remove();
    });
  }



  static const blackColor = Colors.black;
  static const blackColorShade = Color(0xFF5f5f5f);
  static const primaryColor = Color(0xFFf7ebff);
  static const primaryTextColor = Color(0xFF11528f);
  static const formFieldErrorBorderColor = Color(0xFFff0000);
  static const blueColor = Color(0xFF0f75bc);
  static const primarylightColor = Color(0xffe2f0fd);
  static const TextStyle header_Styles = TextStyle(
    fontSize: 20,
    fontFamily: "Outfit",
    fontWeight: FontWeight.w600,
    color: Color(0xFF11528f),
  );
  static const TextStyle Sub_header_Styles = TextStyle(
    fontSize: 20,
    fontFamily: "Outfit",
    fontWeight: FontWeight.w500,
    color: blackColor
  );
  static const TextStyle Mediumtext_o_14 = TextStyle(
    fontSize: 20,
    fontFamily: "Outfit",
    fontWeight: FontWeight.w500,
    color: Color(0xFF11528f),
  );

  static const TextStyle Mediumtext14 = TextStyle(
    fontSize: 14,
    fontFamily: "Outfit",
    fontWeight: FontWeight.w500,
    color: Color(0xFF11528f),
  );
  static const TextStyle Mediumtext_14 = TextStyle(
    fontSize: 20,
    fontFamily: "Outfit",
    fontWeight: FontWeight.w500,
    color:Colors.black,
  );
  static  TextStyle Mediumtext16 = TextStyle(
    fontSize: 16,
    fontFamily: "Outfit",
    fontWeight: FontWeight.w500,
    color: Color(0xFF5f5f5f),
  );
  static const txSty_14w_fb = TextStyle(
    fontSize: 14,
    fontFamily: 'Outfit',
    fontWeight: FontWeight.bold,
    color: Color(0xFFFFFFFF),
  );
  static const txSty_12b_fb = TextStyle(
    fontSize: 12.0,
    color: blackColor,
    fontWeight: FontWeight.w600,
    fontFamily: "Outfit",
  );
  static const txSty_12bs_fb = TextStyle(
    fontSize: 12.0,
    letterSpacing: 1,
    fontWeight: FontWeight.w600,
    fontFamily: "Outfit",
  );
  static const txSty_12p_fb = TextStyle(
    fontSize: 12.0,
    color: primaryTextColor,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
    fontFamily: "Outfit",
  );
  static const txSty_18b_fb = TextStyle(
    fontSize: 18,
    fontFamily: 'Outfit',
    fontWeight: FontWeight.w700,
    color: Color(0xFF11528f),
  );
  static const txSty_18p_f7 = TextStyle(
    fontSize: 16,
    fontFamily: 'Outfit',
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
    color:Color(0xFF11528f),
  );
  static Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // Connected to the internet
    } else {
      return false; // Not connected to the internet
    }
  }
    static void myCommonMethod() {
      // Your common method logic here
      print('This is a common method');
    }

}