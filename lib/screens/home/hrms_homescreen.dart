import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:hrms/Notifications_screen.dart';
import 'package:hrms/common_widgets/common_styles.dart';
import 'package:hrms/common_widgets/custom_btn.dart';

class HrmsHomeSreen extends StatefulWidget {
  const HrmsHomeSreen({super.key});

  @override
  State<HrmsHomeSreen> createState() => _HrmsHomeSreenState();
}

class _HrmsHomeSreenState extends State<HrmsHomeSreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf2f2f2),
      appBar: appBar(context),
      body: Column(
        children: [
          header(),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        shiftTimingAndStatus(),
                        const SizedBox(height: 12),
                        checkInNOut(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  hrmsSection(),
                  const SizedBox(height: 12),
                  /*  sgtSection(),
                  const SizedBox(height: 12), */
                  bannersCarosuel(context),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          const Center(
            child: Text('Hrms Home Screen'),
          ),
        ],
      ),
    );
  }

  Row hrmsSection() {
    return Row(
      children: [
        customLeaveTypeBox(
          leaveType: 'PL\'s',
          data: '4/12',
          icon: Icons.edit_calendar_outlined,
          themeColor: const Color(0xffDC2626),
          // themeColor: Color(0xffFBBF24),
        ),
        const SizedBox(width: 12),
        customLeaveTypeBox(
          leaveType: 'CL\'s',
          data: '5/12',
          icon: Icons.calendar_month,
          themeColor: const Color(0xff2563EB),
          // themeColor: CommonStyles.greenColor,
        ),
        const SizedBox(width: 12),
        customLeaveTypeBox(
          leaveType: 'Comp Off',
          data: '1/0',
          icon: Icons.calendar_today_rounded,
          themeColor: const Color(0xff9333EA),
          // themeColor: CommonStyles.blueColor,background: #9333EA;
        ),
      ],
    );
  }

  Row sgtSection() {
    return Row(
      children: [
        customLeaveTypeBox(
          leaveType: 'Travelled',
          data: '12.5',
          icon: Icons.mode_of_travel_outlined,
          themeColor: const Color(0xffFBBF24),
          // themeColor: Color(0xffFBBF24),
        ),
        const SizedBox(width: 12),
        customLeaveTypeBox(
          leaveType: 'Today Visits',
          data: '3',
          icon: Icons.calendar_month,
          themeColor: const Color(0xff16A34A),
          // themeColor: CommonStyles.greenColor,background: #16A34A;background: #;
        ),
        const SizedBox(width: 12),
        customLeaveTypeBox(
          leaveType: 'Total Visits',
          data: '5',
          icon: Icons.calendar_today_rounded,
          themeColor: const Color(0xff4F46E5),
          // themeColor: CommonStyles.blueColor,background: #9333EA;
        ),
      ],
    );
  }

  Widget customLeaveTypeBox({
    required String leaveType,
    required String data,
    required Color themeColor,
    IconData? icon,
    void Function()? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.check_circle_outline,
                  color: themeColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                leaveType,
              ),
              const SizedBox(height: 5),
              Text(
                data,
                style: const TextStyle(
                    color: CommonStyles.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }

  Row checkInNOut() {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '10:30 PM',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        CustomBtn(
          btnText: 'Check In',
        ),
        /* Column(
                            children: [
                              CustomBtn(
                                btnText: 'Check In',
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomBtn(
                                icon: Icons.logout_outlined,
                                btnText: 'Check Out',
                                backgroundColor: CommonStyles.whiteColor,
                                btnTextColor: CommonStyles.primaryColor,
                              ),
                            ],
                          ), */
      ],
    );
  }

  Row shiftTimingAndStatus() {
    return Row(
      children: [
        const Icon(
          Icons.calendar_month_outlined,
          color: CommonStyles.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 5),
        const Text(
          '31 dec | 2025',
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: CommonStyles.primaryColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Shift Morning',
            style: TextStyle(
              color: CommonStyles.primaryColor,
            ),
          ),
        )
      ],
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFf15f22),
      title: const Text(
        'HRMS',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      actions: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Notifications()),
            );
          },
          child:
              /* Image.asset(
            'assets/notification_icon.png',
            height: 30,
            width: 30,
          ), */
              const Icon(
            Icons.notifications,
            //  size: 15.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          width: 15.0,
        )
      ],
    );
  }

  Container header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: CommonStyles.primaryColor),
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jessy TheGrey',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Python Developer',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          /*  const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ), */
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _items = [
    {
      'img':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
    },
    {
      'img':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
    },
    {
      'img':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
    },
  ];
/* 
  Widget bannersCarosuel(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FlutterCarousel(
          options: FlutterCarouselOptions(
            floatingIndicator: true,
            height: 180,
            viewportFraction: 1.0,
            enlargeCenterPage: true,
            autoPlay: _items.length > 1,
            enableInfiniteScroll: _items.length > 1,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            //  enableInfiniteScroll: true,
            slideIndicator: CircularSlideIndicator(
              slideIndicatorOptions: const SlideIndicatorOptions(
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
                itemSpacing: 12,
                indicatorRadius: 4,
              ),
            ),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
          ),
          items: _items.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item['img'],
                        height: 200,
                        fit: BoxFit.fill,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
 */
  Widget bannersCarosuel(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: FlutterCarousel(
        options: FlutterCarouselOptions(
          floatingIndicator: true,
          height: 180,
          viewportFraction: 1.0,
          enlargeCenterPage: true,
          autoPlay: _items.length > 1,
          enableInfiniteScroll: _items.length > 1,
          aspectRatio: 16 / 9,
          autoPlayCurve: Curves.fastOutSlowIn,
          slideIndicator: CircularSlideIndicator(
            slideIndicatorOptions: const SlideIndicatorOptions(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
              itemSpacing: 12,
              indicatorRadius: 4,
            ),
          ),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
        ),
        items: _items.map((item) {
          return Builder(
            builder: (BuildContext context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    item['img'],
                    height: 200,
                    fit: BoxFit
                        .cover, // Use cover instead of fill for better aspect ratio handling
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    },
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
