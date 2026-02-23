// ignore_for_file: prefer_const_constructors, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';
import 'artist_submission_screen.dart';
import 'script_submission_screen.dart';

class TenallyScreen extends StatelessWidget {
  const TenallyScreen({super.key});
  final List<Map<String, String>> highlightInfo = const [
    {
      "label": "50+ Scripts",
      "hint": "Original scripts submitted from across the globe.",
    },
    {
      "label": "12 Min Plays",
      "hint": "Mastering the art of short-form storytelling.",
    },
    {
      "label": "Housefull",
      "hint": "Season 2 saw record-breaking audience engagement.",
    },
  ];
  final List<Map<String, String>> scheduleInfo = const [
    {
      "title": "Weekend 1",
      "description": "Preliminary Rounds - Selection of Top 20",
    },
    {
      "title": "Saturday",
      "description": "Semi-Finals - The Battle of the Best",
    },
    {
      "title": "Sunday",
      "description": "Grand Finale & Awards Ceremony",
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: WhiteColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Tenally",
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            color: BlackColor,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(color: BlackColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              _buildHeroBanner(),
              const SizedBox(height: 20),
              _buildSubmissionSections(),
              const SizedBox(height: 24),
              _buildHighlights(),
              const SizedBox(height: 24),
              _buildSchedule(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Color(0xFF020D24), Color(0xFF051333)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TenAlly 2026",
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              color: WhiteColor,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Theatre Marina's flagship festival dedicated to fostering talent, promoting creativity, and recognizing excellence in theatre.",
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              color: WhiteColor.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionSections() {
    return Column(
      children: [
        _buildActionCard(
          title: "Script Submission",
          subtitle: "Submit your 12-minute masterpiece",
          icon: Icons.description,
          filled: true,
          onTap: () => Get.to(() => TenallyScriptSubmissionScreen()),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          title: "Artist Registration",
          subtitle: "Join the crew for Season 4",
          icon: Icons.people_alt,
          filled: false,
          onTap: () => Get.to(() => TenallyArtistSubmissionScreen()),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    bool filled = true,
    required VoidCallback onTap,
  }) {
    final Color bg = filled ? WhiteColor : const Color(0xff0b142b);
    final Color textColor = filled ? BlackColor : WhiteColor;
    final Color borderColor =
        filled ? Colors.transparent : gradient.defoultColor.withOpacity(0.4);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: gradient.defoultColor,
              child: Icon(
                icon,
                color: WhiteColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      fontSize: 13,
                      color: textColor.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textColor.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlights() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xff0b142b),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gradient.defoultColor.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Season 2 Highlights",
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 18,
              color: WhiteColor,
            ),
          ),
          const SizedBox(height: 12),
          ...highlightInfo.map(_buildHighlightRow).toList(),
        ],
      ),
    );
  }

  Widget _buildHighlightRow(Map<String, String> highlight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: gradient.defoultColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.star,
              color: BlackColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight["label"]!,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    color: WhiteColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  highlight["hint"]!,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyMedium,
                    color: WhiteColor.withOpacity(0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: WhiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Event Schedule",
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 18,
              color: BlackColor,
            ),
          ),
          const SizedBox(height: 12),
          ...scheduleInfo.map(_buildScheduleRow).toList(),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: gradient.defoultColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 45,
                color: gradient.defoultColor,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["title"]!,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    fontSize: 14,
                    color: BlackColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data["description"]!,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyMedium,
                    color: Greycolor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
