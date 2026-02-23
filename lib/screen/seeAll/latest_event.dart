// ignore_for_file: sort_child_properties_last, prefer_const_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Api/config.dart';
import '../../controller/eventdetails_controller.dart';
import '../../controller/home_controller.dart';
import '../../helpar/routes_helpar.dart';
import '../../model/fontfamily_model.dart';
import '../../model/home_info.dart';
import '../../utils/Colors.dart';

class LatestEvent extends StatefulWidget {
  String? eventStaus;
  LatestEvent({super.key, this.eventStaus});

  @override
  State<LatestEvent> createState() => _LatestEventState();
}

class _LatestEventState extends State<LatestEvent> {
  HomePageController homePageController = Get.find();
  EventDetailsController eventDetailsController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: WhiteColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: BlackColor),
        ),
        title: Text(
          widget.eventStaus == "1"
              ? "Latest Events".tr
              : widget.eventStaus == "2"
              ? "Monthly Event".tr
              : widget.eventStaus == "3"
              ? "Nearby Event".tr
              : "",
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: BlackColor,
          ),
        ),
      ),
      body: GetBuilder<HomePageController>(
        builder: (context) {
          final homeInfo = homePageController.homeInfo;
          if (!homePageController.isLoading || homeInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final homeData = homeInfo.homeData;
          final thisMonthEvents = homeData.thisMonthEvent;
          final latestEvents = homeData.latestEvent;
          final nearbyEvents = homeData.nearbyEvent;
          final nearbyAsEvents = nearbyEvents
              .map(
                (event) => Event(
                  eventId: event.eventId,
                  eventTitle: event.eventTitle,
                  eventImg: event.eventImg,
                  eventSdate: event.eventSdate,
                  eventPlaceName: event.eventPlaceName,
                ),
              )
              .toList();
          final eventsToShow = widget.eventStaus == "3"
              ? nearbyAsEvents
              : widget.eventStaus == "2"
                  ? thisMonthEvents
                  : latestEvents;
          return Column(
            children: [
              widget.eventStaus == "1"
                  ? Expanded(
                      child: eventsToShow.isNotEmpty
                          ? ListView.builder(
                              itemCount: eventsToShow.length,
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final event = eventsToShow[index];
                                return InkWell(
                                  onTap: () async {
                                    await eventDetailsController.getEventData(
                                      eventId: event.eventId,
                                    );
                                    Get.toNamed(
                                      Routes.eventDetailsScreen,
                                      arguments: {
                                        "eventId": event.eventId,
                                        "bookStatus": "1",
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 140,
                                    width: Get.size.width,
                                    margin: EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 140,
                                          width: 130,
                                          margin: EdgeInsets.all(10),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            child: FadeInImage.assetNetwork(
                                              fadeInCurve: Curves.easeInCirc,
                                              placeholder:
                                                  "assets/ezgif.com-crop.gif",
                                              height: 140,
                                              image:
                                                  "${Config.imageUrl}${event.eventImg}",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                event.eventTitle,
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontFamily.gilroyBold,
                                                  fontSize: 15,
                                                  color: BlackColor,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                event.eventSdate,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontFamily.gilroyMedium,
                                                  color: gradient.defoultColor,
                                                  fontSize: 14,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/Location.png",
                                                    color:
                                                        gradient.defoultColor,
                                                    height: 15,
                                                    width: 15,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        Get.size.width * 0.48,
                                                    child: Text(
                                                      event.eventPlaceName,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontFamily: FontFamily
                                                            .gilroyMedium,
                                                        fontSize: 14,
                                                        color: BlackColor,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                    decoration: BoxDecoration(
                                      color: WhiteColor,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 20),
                                  Container(
                                    height: 150,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          "assets/emptyOrder.png",
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "No shows are listed yet.",
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      color: BlackColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Check back soon for upcoming events.",
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      color: greyColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    )
                  : widget.eventStaus == "2"
                  ? Expanded(
                      child: thisMonthEvents.isNotEmpty
                          ? ListView.builder(
                              itemCount: thisMonthEvents.length,
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                final event = thisMonthEvents[index];
                                return InkWell(
                                  onTap: () async {
                                    await eventDetailsController.getEventData(
                                      eventId: event.eventId,
                                    );
                                    Get.toNamed(
                                      Routes.eventDetailsScreen,
                                      arguments: {
                                        "eventId": event.eventId,
                                        "bookStatus": "1",
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 140,
                                    width: Get.size.width,
                                    margin: EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 140,
                                          width: 130,
                                          margin: EdgeInsets.all(10),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            child: FadeInImage.assetNetwork(
                                              fadeInCurve: Curves.easeInCirc,
                                              placeholder:
                                                  "assets/ezgif.com-crop.gif",
                                              height: 140,
                                              image:
                                                  "${Config.imageUrl}${event.eventImg}",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                event.eventTitle,
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontFamily.gilroyBold,
                                                  fontSize: 15,
                                                  color: BlackColor,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                event.eventSdate,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontFamily.gilroyMedium,
                                                  color: gradient.defoultColor,
                                                  fontSize: 14,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/Location.png",
                                                    color:
                                                        gradient.defoultColor,
                                                    height: 15,
                                                    width: 15,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        Get.size.width * 0.48,
                                                    child: Text(
                                                      event.eventPlaceName,
                                                      style: TextStyle(
                                                        fontFamily: FontFamily
                                                            .gilroyMedium,
                                                        fontSize: 14,
                                                        color: BlackColor,
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
                                    decoration: BoxDecoration(
                                      color: WhiteColor,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 20),
                                  Container(
                                    height: 150,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          "assets/emptyOrder.png",
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "No Monthly Event placed!",
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      color: BlackColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Currently you don’t have any Monthly Event.",
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      color: greyColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    )
                  : widget.eventStaus == "3"
                  ? Expanded(
                      child: nearbyEvents.isNotEmpty
                          ? ListView.builder(
                              itemCount: nearbyEvents.length,
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                final event = nearbyEvents[index];
                                return InkWell(
                                  onTap: () async {
                                    await eventDetailsController.getEventData(
                                      eventId: event.eventId,
                                    );
                                    Get.toNamed(
                                      Routes.eventDetailsScreen,
                                      arguments: {
                                        "eventId": event.eventId,
                                        "bookStatus": "1",
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 140,
                                    width: Get.size.width,
                                    margin: EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 140,
                                          width: 130,
                                          margin: EdgeInsets.all(10),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            child: FadeInImage.assetNetwork(
                                              fadeInCurve: Curves.easeInCirc,
                                              placeholder:
                                                  "assets/ezgif.com-crop.gif",
                                              height: 140,
                                              image:
                                                  "\${Config.imageUrl}\${event.eventImg}",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                event.eventTitle,
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontFamily.gilroyBold,
                                                  fontSize: 15,
                                                  color: BlackColor,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                event.eventSdate,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontFamily.gilroyMedium,
                                                  fontSize: 12,
                                                  color: greytext,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/Location.png",
                                                    color:
                                                        gradient.defoultColor,
                                                    height: 15,
                                                    width: 15,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        Get.size.width * 0.45,
                                                    child: Text(
                                                      event.eventPlaceName,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontFamily: FontFamily
                                                            .gilroyMedium,
                                                        fontSize: 14,
                                                        color: BlackColor,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                    decoration: BoxDecoration(
                                      color: WhiteColor,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),
                                  Container(
                                    height: 150,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          "assets/emptyOrder.png",
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "No Event placed!".tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      fontSize: 16,
                                      color: BlackColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "You haven't placed any orders yet.".tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 14,
                                      color: greytext,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    )
                  : SizedBox(),
            ],
          );
        },
      ),
    );
  }
}
