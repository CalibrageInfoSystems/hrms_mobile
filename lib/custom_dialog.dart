import 'package:flutter/material.dart';



class CustomDialog {
  static void showMyDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                width: 80,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFf15f22), // Set the background color
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white, // Set the text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


