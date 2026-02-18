// ignore_for_file: prefer_const_constructors, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';
import 'tenally_screen.dart';

enum SubmissionType { script, artist }

class SubmissionSuccessScreen extends StatelessWidget {
  final SubmissionType submissionType;
  final String? message;
  final String? fileName;

  const SubmissionSuccessScreen({
    super.key,
    required this.submissionType,
    this.message,
    this.fileName,
  });

  String get _title {
    if (submissionType == SubmissionType.script) {
      return "Script Submitted!";
    }
    return "Artist Registration Submitted!";
  }

  String get _subtitle {
    return message ?? "Your submission has been received. We'll reach out soon.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WhiteColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Success",
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            color: BlackColor,
          ),
        ),
      ),
      backgroundColor: bgcolor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 96,
                  color: gradient.defoultColor,
                ),
                const SizedBox(height: 20),
                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    fontSize: 22,
                    color: BlackColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyMedium,
                    fontSize: 14,
                    color: Greycolor,
                  ),
                ),
                if (fileName != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: WhiteColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: gradient.defoultColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insert_drive_file,
                          color: gradient.defoultColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            fileName!,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: 14,
                              color: BlackColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offAll(() => TenallyScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gradient.defoultColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Back to Tenally",
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 16,
                        color: WhiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
