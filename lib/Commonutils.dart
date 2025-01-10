import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/styles.dart';
import 'package:intl/intl.dart';

class Commonutils {
  static Future<void> launchDatePicker(
    BuildContext context, {
    DateTime? initialDate,
    required DateTime firstDate,
    Function(DateTime? pickedDay)? onDateSelected,
    bool Function(DateTime)? selectableDayPredicate,
  }) async {
    final DateTime currentDate = DateTime.now();
    // final DateTime firstDate = DateTime(currentDate.year - 2);
    final DateTime lastDate = DateTime(DateTime.now().year + 10);
    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: initialDate,
      // initialDate: initialDate ?? currentDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      confirmText: 'OK',
      cancelText: 'CANCEL',
      selectableDayPredicate: selectableDayPredicate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Styles.primaryColor,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    onDateSelected?.call(pickedDay);
  }

  static void showCustomToastMessageLong(
    String message,
    BuildContext context,
    int backgroundColorType,
    int length,
  ) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double textWidth = screenWidth / 1.5; // Adjust multiplier as needed

    final double toastWidth = textWidth + 32.0; // Adjust padding as needed
    final double toastOffset = (screenWidth - toastWidth) / 2;

    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        bottom: 16.0,
        left: toastOffset,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            width: toastWidth,
            decoration: BoxDecoration(
              border: Border.all(
                color: backgroundColorType == 0 ? Colors.green : Colors.red,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Center(
                child: Text(
                  message,
                  style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      fontFamily: 'Calibri'),
                  textAlign: TextAlign.center,
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

  static Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // Connected to the internet
    } else {
      return false; // Not connected to the internet
    }
  }

  static String formatDisplayDate(DateTime? date) {
    if (date == null) {
      return 'Invalid';
    } else {
      return DateFormat("dd-MM-yyyy").format(date);
    }
  }

  static String? formatApiDate(DateTime? date) {
    if (date == null) return null;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }
}

class ProgressDialog {
  final BuildContext context;
  late bool _isShowing;

  ProgressDialog(this.context) {
    _isShowing = false;
    show();
  }
  Future<void> show() async {
    if (!_isShowing) {
      _isShowing = true;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white60,
              ),
              padding: const EdgeInsets.all(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const CircularProgressIndicator.adaptive(),
                  SvgPicture.asset(
                    'assets/cislogo-new.svg',
                    height: 32.0,
                    width: 32.0,
                  ),
                ],
              ),
            ),
          );
        },
      );
      _isShowing =
          false; // Set _isShowing back to false after dialog is dismissed
    }
  }

  // Future<void> show() async {
  //   if (!_isShowing) {
  //     _isShowing = true;
  //     await showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       //useRootNavigator: true,
  //       //useSafeArea: true,
  //       ///  barrierColor:  Colors.grey.shade50.withOpacity(0.35),
  //       // barrierColor:  Colors.transparent,
  //       builder: (BuildContext context) {
  //         return  Center(
  //             child: Container(
  //                 decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(10),
  //                     /// color: Colors.grey.shade50.withOpacity(0.001),
  //                     color: Colors.transparent
  //
  //                 ),
  //                 padding: const EdgeInsets.all(20),
  //                 // child: const CircularProgressIndicator.adaptive()));
  //                 child:  Container(
  //                   width: MediaQuery.of(context).size.width/1.8, // Adjust the width as needed
  //                   height: MediaQuery.of(context).size.height/4, // Adjust the height as needed
  //                   decoration: BoxDecoration(
  //                     color: Colors.transparent,
  //                     shape: BoxShape.rectangle,
  //                     // gradient: LinearGradient(
  //                     //   colors: [
  //                     //     Colors.blue,
  //                     //     Colors.green,
  //                     //   ],
  //                     //   begin: Alignment.topCenter,
  //                     //   end: Alignment.bottomCenter,
  //                     // ),
  //                   ),
  //                   child: Stack(
  //                     alignment: Alignment.center,
  //                     children: [
  //                       Container(
  //                         height: 50.0,
  //                         width: 50.0,
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //                           shape: BoxShape.circle,
  //                         ),
  //                         child: SvgPicture.asset(
  //                           'assets/cislogo-new.svg',
  //                           height: 40.0,
  //                           width: 40.0,
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         height: 50.0,
  //                         width: 50.0,
  //                         child:    CircularProgressIndicator(
  //                           strokeWidth: 3, // Adjust the stroke width of the CircularProgressIndicator
  //                           valueColor: AlwaysStoppedAnimation<Color>(
  //                             Color(0xFFf15f22),
  //                           ), // Color for the progress indicator itself
  //                         ),
  //                       )
  //
  //                     ],
  //                   ),
  //                 )));
  //         //   Center(
  //         //   child:
  //         //   Container(
  //         //     width: MediaQuery.of(context).size.width/1.8, // Adjust the width as needed
  //         //     height: MediaQuery.of(context).size.height/4, // Adjust the height as needed
  //         //     decoration: BoxDecoration(
  //         //     color: Colors.transparent,
  //         //      shape: BoxShape.rectangle,
  //         //     // gradient: LinearGradient(
  //         //     //   colors: [
  //         //     //     Colors.blue,
  //         //     //     Colors.green,
  //         //     //   ],
  //         //     //   begin: Alignment.topCenter,
  //         //     //   end: Alignment.bottomCenter,
  //         //     // ),
  //         //     ),
  //         //     child: Stack(
  //         //       alignment: Alignment.center,
  //         //       children: [
  //         //         Container(
  //         //           height: 33.0,
  //         //           width: 33.0,
  //         //           decoration: BoxDecoration(
  //         //             color: Colors.white,
  //         //             shape: BoxShape.circle,
  //         //           ),
  //         //           child: SvgPicture.asset(
  //         //             'assets/cislogo-new.svg',
  //         //             height: 30.0,
  //         //             width: 30.0,
  //         //           ),
  //         //         ),
  //         //         CircularProgressIndicator(
  //         //           strokeWidth: 3, // Adjust the stroke width of the CircularProgressIndicator
  //         //           valueColor: AlwaysStoppedAnimation<Color>(
  //         //             Color(0xFFf15f22),
  //         //           ), // Color for the progress indicator itself
  //         //         ),
  //         //       ],
  //         //     ),
  //         //   ),
  //         // );
  //       },
  //     );
  //     _isShowing = false; // Set isShowing back to false after dialog is dismissed
  //   }
  // }

  void dismiss() {
    if (_isShowing) {
      _isShowing = false;
      Navigator.of(context).pop();
    }
  }
}
