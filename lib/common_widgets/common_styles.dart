import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';

class CommonStyles {
  // colors

  static const primaryTextColor = Color(0xFFeb3818);
  static const blueTextColor = Color(0xFF2e7aa6);
  static const btnRedBgColor = Color(0xFFff7964);
  static const btnBlueBgColor = Color(0xFF90c5f7);
  static const listEvenColor = Color(0xFFffe9e6);
  static const listOddColor = Color(0xFFe5f6ff);
  static const borderColor = Color(0xFF9ac2db);
  static const dataTextColor = Color(0xff818181);
  static const bottomNavBgColor = Color(0xffe8f4ff);
  static const appBarBgColor = Color(0xffe3f2f7);
  static const primaryColor = Color(0xFFf15f22);

  static const statusBlueBg = Color(0xffc3c8cc);
  static const statusBlueText = Color(0xFF11528f);
  static const statusGreenBg = Color(0xFFe5ffeb);
  static const statusGreenText = Color(0xFF287d02);
  static const statusYellowBg = Color(0xfff8e7cb);
  static const statusYellowText = Color(0xFFd48202);
  static const statusRedBg = Color(0xFFffdedf);
  static const statusRedText = Color.fromARGB(255, 236, 62, 68);
  static const startColor = Color(0xFF59ca6b);
  static const dotColor = Color(0xFFEE3618);
  // background:border: 1px solid #EE3618;;

  static const blackColor = Colors.black;
  static const blackColorShade = Color(0xFF5f5f5f);
  // static const primaryColor = Color(0xFAF5F5F5);
  static const disabledTextColor = Color(0xFAF5F5F5);
  static const loginTextColor = Color(0xFFEE3618);
  static const buttonbg = Color(0xFF317DA6); //background: #317DA6;
  static const formFieldErrorBorderColor = Color(0xFFff0000);
  static const blueColor = Color(0xFF4695C0);
  static const blueheader = Color(0xFF317DA6);
  static const branchBg = Color(0xFFcfeaff);
  static const primarylightColor = Color(0xffe2f0fd);
  static const greenColor = Colors.greenAccent;
  static const whiteColor = Colors.white;
  static const hintTextColor = Color(0xCBBEBEBE);
  static const RedColor = Color(0xFFC93437);
  // styles
  static const txStyF20CpFF5 = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: CommonStyles.primaryTextColor);

  static const txStyF20CbFF5 = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: CommonStyles.blackColor);

  static const txStyF20CbluFF5 = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: CommonStyles.blueTextColor);

  static const txStyF14CpFF = TextStyle(
      fontSize: 14,
      fontFamily: "hind_semibold",
      fontWeight: FontWeight.w500,
      color: CommonStyles.primaryTextColor);
  static const txStyF14CbFF5 = TextStyle(
      fontSize: 14,
      fontFamily: "hind_semibold",
      fontWeight: FontWeight.w500,
      color: CommonStyles.blackColor);
  static const txStyF16CbFF5 = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: CommonStyles.blackColor);
  static const txStyF16CpFF5 = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: CommonStyles.primaryTextColor);

  static const txStyF14CwFF5 = TextStyle(
      fontSize: 14,
      fontFamily: "hind_semibold",
      fontWeight: FontWeight.w500,
      color: CommonStyles.whiteColor);

  static const TextStyle txSty_12b_f5 = TextStyle(
    fontSize: 12,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w600,
    color: blackColor,
  );
  static const TextStyle texthintstyle = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );
  static const TextStyle texterrorstyle = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: Color.fromARGB(255, 175, 15, 4),
  );
  static const TextStyle txSty_20wh_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: whiteColor,
  );
  static const TextStyle txSty_20hint_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: hintTextColor,
  );
  static const TextStyle txSty_14b_f5 = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w600,
    color: blackColor,
  );
  static const TextStyle txSty_14black = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w700,
    color: blackColor,
  );
  static const TextStyle txSty_22b_f5 = TextStyle(
    fontSize: 22,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: blackColor,
  );
  static const TextStyle txSty_14p_f5 = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
  );
  static const TextStyle txSty_12p_f5 = TextStyle(
    fontSize: 12,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
  );
  static const TextStyle txSty_14g_f5 = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w600,
    color: statusGreenText,
  );
  static const TextStyle txSty_14blu_f5 = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: Color(0xFF0f75bc),
  );
  static const TextStyle txSty_16blu_f5 = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: Color(0xFF0f75bc),
  );
  static const TextStyle txSty_16black_f5 = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: Color(0xFF5f5f5f),
  );
  static const TextStyle txSty_14black_f5 = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: Color(0xFF5f5f5f),
  );
  static const TextStyle txSty_16p_fb = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );
  static const TextStyle txSty_18b_fb = TextStyle(
    fontSize: 18,
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: 'hind_semibold',
  );
  static const TextStyle txSty_16b6_fb = TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: 'hind_semibold',
  );
  static const TextStyle txSty_16b_fb = TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w500,
    fontFamily: 'hind_semibold',
  );
  static const TextStyle txSty_14b_fb = TextStyle(
    fontSize: 14,
    color: Colors.black,
    fontWeight: FontWeight.w700,
    fontFamily: 'hind_semibold',
  );
  static const TextStyle header_Styles = TextStyle(
    fontSize: 26,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w700,
    color: Color(0xFF0f75bc),
  );
  static const TextStyle txSty_16w_fb = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.bold,
    color: whiteColor,
  );
  static const TextStyle txSty_24w = TextStyle(
      fontSize: 24,
      fontFamily: "hind_semibold",
      fontWeight: FontWeight.bold,
      color: whiteColor,
      letterSpacing: 1);
  static const TextStyle txSty_16p_f5 = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
  );
  static const TextStyle txSty_20p_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w700,
    color: primaryTextColor,
    letterSpacing: 2,
  );
  static const TextStyle txSty_20b_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.bold,
    color: blackColor,
  );

  static const TextStyle txSty_12b_fb = TextStyle(
      fontFamily: 'hind_semibold',
      fontSize: 12,
      color: Color(0xFF000000),
      fontWeight: FontWeight.w500);
  static const TextStyle txSty_12bl_fb = TextStyle(
    fontFamily: 'hind_semibold',
    fontSize: 12,
    color: Color(0xA1000000),
  );
  static const TextStyle txSty_12W_fb = TextStyle(
      fontFamily: 'hind_semibold',
      fontSize: 12,
      color: whiteColor,
      fontWeight: FontWeight.w600);
  static const TextStyle txSty_12blu_fb = TextStyle(
    fontFamily: 'hind_semibold',
    fontSize: 12,
    color: Color(0xFF8d97e2),
  );
  static const TextStyle txSty_20black_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    color: blackColor,
  );
  static const TextStyle txSty_20blu_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w700,
    color: primaryTextColor,
  );
  static const TextStyle txSty_20w_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    color: whiteColor,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle text16white = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w600,
    color: CommonStyles.whiteColor,
  );
  static const TextStyle text14white = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w600,
    color: CommonStyles.whiteColor,
  );

  static TextStyle dayTextStyle =
      const TextStyle(color: Colors.black, fontWeight: FontWeight.w700);

  static const TextStyle text18orange = TextStyle(
    fontSize: 18,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
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

  static void showCustomDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
            side: const BorderSide(
                color: Color(0x8D000000),
                width: 2.0), // Adding border to the dialog
          ),
          child: Container(
            color: blackColor,
            padding: const EdgeInsets.all(0.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Header with "X" icon and "Error" text
                Container(
                  padding: const EdgeInsets.all(10.0),
                  color: RedColor,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close, color: Colors.white),
                      Text('  Error', style: txSty_20w_fb),
                      SizedBox(
                          width: 24.0), // Spacer to align text in the center
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                // Message Text
                Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: text16white,
                ),
                const SizedBox(height: 20.0),
                // OK Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFCCCCCC), // Start color (light gray)
                          Color(0xFFFFFFFF), // Center color (white)
                          Color(0xFFCCCCCC), // End color (light gray)
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFe86100), // Orange border color
                        width: 2.0,
                      ),
                    ),
                    child: SizedBox(
                      height: 30.0, // Set the desired height
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 35.0),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text(
                          'OK',
                          style: txSty_16b_fb,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static String? formatDateString(String? date) {
    print('date: $date');
    if (date != null && date.isNotEmpty) {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    }
    return date;
  }

  static void showHorizontalDotsLoadingDialog(BuildContext context,
      {String message = "Please Wait...", int dotCount = 5}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width / 1.5,
              height: 100.0,
              color: Colors.black,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  SpinKitHorizontalDots(
                    color: const Color(0xFFe86100),

                    dotCount: dotCount, // Number of dots
                  ),
                ],
              ),
            ));
      },
    );
  }

  static void hideHorizontalDotsLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void showCustomToastMessageLong(String message, BuildContext context,
      int backgroundColorType, int length) {
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
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
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
}

class SpinKitHorizontalDots extends StatefulWidget {
  final Color color;
  final double size;
  final int dotCount;
  final double dotSpacing;

  const SpinKitHorizontalDots({
    super.key,
    required this.color,
    this.size = 30.0,
    this.dotSpacing = 8.0,
    this.dotCount = 5, // Number of dots
  });

  @override
  SpinKitHorizontalDotsState createState() => SpinKitHorizontalDotsState();
}

class SpinKitHorizontalDotsState extends State<SpinKitHorizontalDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalWidth =
        widget.size + (widget.dotSpacing * (widget.dotCount - 1));
    final dotSize = widget.size / widget.dotCount;

    return SizedBox(
      width: totalWidth,
      height: dotSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: List.generate(widget.dotCount, (index) {
              final offset = _animation.value * (totalWidth + dotSize);
              final double position =
                  (offset - index * (dotSize + widget.dotSpacing)) %
                      (totalWidth + dotSize);

              return Positioned(
                left: position - dotSize,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
