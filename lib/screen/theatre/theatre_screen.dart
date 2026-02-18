// ignore_for_file: prefer_const_constructors, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Api/config.dart';
import '../../controller/theatre_controller.dart';
import 'package:magicmate_user/helpar/routes_helpar.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';

class TheatreScreen extends StatefulWidget {
  TheatreScreen({super.key});

  @override
  State<TheatreScreen> createState() => _TheatreScreenState();
}

class _TheatreScreenState extends State<TheatreScreen> {
  final TheatreController controller = Get.put(TheatreController());
  String activeTab = "about";

  final List<Map<String, String>> processSteps = const [
    {
      "step": "01",
      "title": "Strategy",
      "desc":
          "Question everything. Find the path, follow the clues, and keep the conversation rolling while discussing presentation and future impact.",
    },
    {
      "step": "02",
      "title": "Development",
      "desc":
          "Once the story is chosen, we transform it by questioning answers and converging on an engaging dialogue between artists and technicians.",
    },
    {
      "step": "03",
      "title": "Production",
      "desc":
          "The production leaves no stone unturned—optimised for performer comfort while elevating the script without losing its original soul.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff03091e),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Theatre Marina",
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 28,
            color: WhiteColor,
          ),
        ),
        const SizedBox(height: 20),
        _buildHeroBanner(),
              const SizedBox(height: 24),
              _buildTabBar(),
              const SizedBox(height: 16),
              activeTab == "about" ? _buildAboutTab() : _buildProductionsTab(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xff020d24), Color(0xff051333)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
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
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Theatre Marina's flagship festival dedicated to fostering talent, promoting creativity, and recognising excellence in theatre.",
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

  Widget _buildTabBar() {
    return Row(
      children: [
        _buildTabButton("about", "About"),
        const SizedBox(width: 12),
        _buildTabButton("productions", "Productions"),
      ],
    );
  }

  Widget _buildTabButton(String tabKey, String label) {
    final bool isActive = activeTab == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            activeTab = tabKey;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? gradient.defoultColor : Colors.white12,
            ),
            color: isActive ? Colors.white10 : Colors.black12,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontFamily.gilroyMedium,
                  fontSize: 13,
                  letterSpacing: 1.5,
                  color: isActive ? gradient.defoultColor : WhiteColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              if (isActive)
                Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: gradient.defoultColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVisionSection(),
        const SizedBox(height: 16),
        _buildProcessSection(),
        const SizedBox(height: 16),
        _buildLeadershipSection(),
        const SizedBox(height: 16),
        _buildQuoteSection(),
      ],
    );
  }

  Widget _buildVisionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Our Vision",
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
            color: gradient.defoultColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Theatre Marina is a one-of-a-kind troupe dedicated to theatre. With a team of artists, writers, directors, performers and technicians, we deliver powerful, presentable on-stage experiences.",
          style: TextStyle(
            fontFamily: FontFamily.gilroyMedium,
            fontSize: 14,
            color: WhiteColor.withOpacity(0.85),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff0a1230),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Our Process",
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 16,
              color: WhiteColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "How we create the magic",
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 12,
              color: WhiteColor.withOpacity(0.6),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: processSteps
                .map(
                  (step) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: gradient.defoultColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: gradient.defoultColor),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            step["step"]!,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              color: gradient.defoultColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step["title"]!,
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 14,
                                  color: WhiteColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step["desc"]!,
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyMedium,
                                  fontSize: 12,
                                  color: WhiteColor.withOpacity(0.75),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadershipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Leadership",
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
            color: WhiteColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xff0b1329),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                  image: const DecorationImage(
                    image: NetworkImage(
                        "https://theatremarina.com/wp-content/uploads/2024/07/R-Giridharan.pdf-image-023-400x400.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "R. Giridharan",
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 16,
                        color: WhiteColor,
                      ),
                    ),
                    Text(
                      "Founder & Creative Director",
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: gradient.defoultColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "A three-decade storyteller, he brings together technology and artistry to keep theatre daring yet accessible.",
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        fontSize: 12,
                        color: WhiteColor.withOpacity(0.75),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff060c1b),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            "\"Art disturbs the comfortable, comforts the disturbed. Additionally, we, also entertain.\"",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 16,
              color: WhiteColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "— Theatre Marina",
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 10,
              letterSpacing: 1.5,
              color: gradient.defoultColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionsTab() {
    return GetBuilder<TheatreController>(builder: (controller) {
      if (controller.isLoading) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: CircularProgressIndicator(
              color: gradient.defoultColor,
            ),
          ),
        );
      }

      if (controller.errorMessage != null) {
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text(
            controller.errorMessage!,
            style: TextStyle(
              color: WhiteColor.withOpacity(0.7),
              fontFamily: FontFamily.gilroyMedium,
            ),
          ),
        );
      }

      if (controller.productions.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text(
            "No productions available at the moment.",
            style: TextStyle(
              color: WhiteColor.withOpacity(0.7),
              fontFamily: FontFamily.gilroyMedium,
            ),
          ),
        );
      }

      return Column(
        children:
            controller.productions.map((item) => _buildProductionCard(item)).toList(),
      );
    });
  }

  Widget _buildProductionCard(Map<String, dynamic> production) {
    final imagePath = production["event_img"] ?? "";
    final imageUrl = imagePath.isNotEmpty ? "${Config.imageUrl}$imagePath" : null;
    final title = production["event_title"] ?? "Untitled";
    final date = production["event_sdate"] ?? "";
    final location = production["event_place_name"] ?? "";

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        final eventId =
            production["event_id"]?.toString() ?? production["eventId"]?.toString();
        if (eventId != null && eventId.isNotEmpty) {
          Get.toNamed(Routes.eventDetailsScreen, arguments: {
            "eventId": eventId,
            "bookStatus": "1",
          });
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xff091230),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: Colors.black26,
                      ),
                    )
                  : Container(
                      height: 160,
                      color: Colors.black26,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      fontSize: 16,
                      color: WhiteColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.watch_later_outlined,
                        color: WhiteColor.withOpacity(0.6),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        date,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyMedium,
                          fontSize: 12,
                          color: WhiteColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: WhiteColor.withOpacity(0.6),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyMedium,
                            fontSize: 12,
                            color: WhiteColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
