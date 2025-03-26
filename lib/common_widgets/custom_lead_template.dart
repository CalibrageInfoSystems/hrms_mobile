import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../Database/DataAccessHandler.dart';
import '../Model Class/LeadsModel.dart';
import 'common_styles.dart';

class CustomLeadTemplate extends StatelessWidget {
  final int index;
  final LeadsModel lead;
  final void Function()? onTap;
  final double? padding;

  const CustomLeadTemplate(
      {super.key,
        required this.index,
        required this.lead,
        this.onTap,
        this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding ?? 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: index.isEven
              ? CommonStyles.listEvenColor
              : CommonStyles.listOddColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    userItem(
                        data: lead.name,
                        dataStyle:
                        const TextStyle(fontSize: 16, color: Colors.black)),
                    userItem(
                      data: lead.companyName,
                    ),
                    userItem(data: lead.email),
                    userItem(data: lead.phoneNumber, isSpaceNeeded: false),
                  ],
                ),
              ),
              Image.asset('assets/nextcircle.png'),
            ],
          ),
        ),
        /*
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (lead.name != null)
                      Text(
                        '${lead.name}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    GestureDetector(
                      onTap: onTap,
                      /* () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ViewLeadsInfo()));

                      }, */
                      child: Image.asset('assets/nextcircle.png'),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                if (lead.companyName != null)
                  listCustomText(
                    '${lead.companyName}',
                  ),
                if (lead.email != null)
                  listCustomText(
                    '${lead.email}',
                  ),
                if (lead.phoneNumber != null)
                  listCustomText('${lead.phoneNumber}', isSpace: false),
              ],
            ),
          ],
        ),
     */
      ),
    );
  }

  Column listCustomText(String text, {bool isSpace = true}) {
    return Column(
      children: [
        Text(
          text,
          style: CommonStyles.txStyF16CbFF5
              .copyWith(color: CommonStyles.dataTextColor),
        ),
        if (isSpace) const SizedBox(height: 5),
      ],
    );
  }

  Widget userItem(
      {String? data, bool isSpaceNeeded = true, TextStyle? dataStyle}) {
    if (data == null || data.isEmpty) {
      return const SizedBox();
    }
    return Container(
      padding: EdgeInsets.only(bottom: isSpaceNeeded ? 5 : 0),
      child: Text(data,
          style: dataStyle ??
              CommonStyles.txStyF16CbFF5
                  .copyWith(color: CommonStyles.dataTextColor)),

      //              Flexible(
      //   child: Text(data,
      //       style: dataStyle ??
      //           CommonStyles.txStyF16CbFF5
      //               .copyWith(color: CommonStyles.dataTextColor)),
      // ),

    );
  }
}
