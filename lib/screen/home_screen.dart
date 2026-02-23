// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, sized_box_for_whitespace, avoid_print, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:magicmate_user/screen/profile/notification_screen.dart';
import 'package:magicmate_user/screen/seeAll/latest_event.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../controller/eventdetails_controller.dart';
import '../controller/home_controller.dart';
import '../controller/login_controller.dart';
import '../helpar/routes_helpar.dart';
import '../model/fontfamily_model.dart';
import '../model/home_info.dart';
import '../model/catwise_event.dart';
import '../utils/Colors.dart';
import 'LoginAndSignup/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

var currency;
var wallet1;

class _HomeScreenState extends State<HomeScreen> {
  HomePageController homePageController = Get.find();
  EventDetailsController eventDetailsController = Get.find();
  LoginController loginController = Get.find();
  String? networkimage;
  String userName = "";
  String? base64Image;

  ScrollController? _scrollController;
  bool lastStatus = true;
  double height = Get.height * 0.35;
  String selectedCategoryId = 'all';
  bool isCategoryLoading = false;
  List<CatWiseInfo> selectedCategoryEvents = [];
  final Map<String, List<CatWiseInfo>> _categoryEventsCache = {};
  final Set<String> _hiddenCategoryIds = {};
  bool _categoriesValidated = false;
  bool _needsCategoryReset = false;
  int? _homeDataSignature;

  void _scrollListener() {
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  bool get _isShrink {
    return _scrollController != null &&
        _scrollController!.hasClients &&
        _scrollController!.offset > (height - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    getData.read("UserLogin") != null
        ? setState(() {
            userName = getData.read("UserLogin")["name"] ?? "";
            networkimage = getData.read("UserLogin")["pro_pic"] ?? "";
            getData.read("UserLogin")["pro_pic"] != "null"
                ? setState(() {
                    networkimageconvert();
                  })
                : const SizedBox();
          })
        : null;
  }

  networkimageconvert() {
    (() async {
      http.Response response = await http.get(
        Uri.parse(Config.imageUrl + networkimage.toString()),
      );
      if (mounted) {
        print(response.bodyBytes);
        setState(() {
          base64Image = const Base64Encoder().convert(response.bodyBytes);
        });
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: GetBuilder<HomePageController>(
        builder: (homePageController) {
          final info = homePageController.homeInfo;
          if (!homePageController.isLoading || info == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final _FeaturedBannerData featuredBanner = _getFeaturedEvent(info);
          final homeData = info.homeData;
          final thisMonthEvents = homeData.thisMonthEvent;
          final int currentSignature = homeData.catlist.fold(
            0,
            (prev, cat) =>
                prev ^ cat.id.hashCode ^ cat.title.hashCode ^ cat.totalEvent,
          );
          if (_homeDataSignature != currentSignature) {
            _homeDataSignature = currentSignature;
            _needsCategoryReset = true;
            _categoriesValidated = false;
          }
          _prepareCategoryValidation(homeData);
          final availableCategories = homeData.catlist
              .where(
                (cat) =>
                    cat.totalEvent > 0 && !_hiddenCategoryIds.contains(cat.id),
              )
              .toList();
          final displayedEvents = _getDisplayedEvents(homeData);
          final bool isCategoryView = selectedCategoryId != 'all';
          final bool shouldShowLoading = isCategoryView && isCategoryLoading;
          final int visibleEventCount = displayedEvents.length;

          return SafeArea(
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    elevation: 0,
                    pinned: true,
                    expandedHeight: Get.size.height * 0.476,
                    titleSpacing: 0,
                    backgroundColor: _isShrink
                        ? gradient.defoultColor
                        : transparent,
                    leading: Padding(
                      padding: EdgeInsets.all(12),
                      child: Image.asset(
                        "assets/homelogo.png",
                        height: 20,
                        width: 30,
                      ),
                    ),
                    title: const SizedBox.shrink(),
                    actions: [
                      InkWell(
                        onTap: () {
                          if (getData.read("UserLogin") != null) {
                            Get.to(NotificationScreen());
                          } else {
                            Get.to(() => LoginScreen());
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          child: Image.asset(
                            "assets/Notification.png",
                            height: 20,
                            width: 20,
                            color: gradient.defoultColor,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: WhiteColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: _buildFeaturedBanner(
                          featuredBanner,
                          compact: true,
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: RefreshIndicator(
                color: gradient.defoultColor,
                onRefresh: () {
                  return Future.delayed(Duration(seconds: 2), () {
                    homePageController.getHomeDataApi();
                  });
                },
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(width: 15),
                        Text(
                          "Latest Events".tr,
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyBold,
                            color: BlackColor,
                            fontSize: 22,
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {
                            Get.to(LatestEvent(eventStaus: "2"));
                          },
                          child: Text(
                            "See All".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              color: gradient.defoultColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    thisMonthEvents.isNotEmpty
                        ? SizedBox(
                            height: 320,
                            width: Get.size.width,
                            child: ListView.builder(
                              itemCount: thisMonthEvents.length.clamp(
                                0,
                                5,
                              ),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
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
                                    height: 320,
                                    width: 240,
                                    margin: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      bottom: 10,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Stack(
                                        children: [
                                          SizedBox(
                                            height: 320,
                                            width: 240,
                                            child: FadeInImage.assetNetwork(
                                              fadeInCurve: Curves.easeInCirc,
                                              placeholder:
                                                  "assets/ezgif.com-crop.gif",
                                              height: 320,
                                              width: 240,
                                              placeholderCacheHeight: 320,
                                              placeholderCacheWidth: 240,
                                              placeholderFit: BoxFit.fill,
                                              // placeholderScale: 1.0,
                                              image:
                                                  "${Config.imageUrl}${event.eventImg}",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                stops: [0.6, 0.8, 1.5],
                                                colors: [
                                                  Colors.transparent,
                                                  const Color.fromRGBO(
                                                    0,
                                                    0,
                                                    0,
                                                    0.5,
                                                  ),
                                                  const Color.fromRGBO(
                                                    0,
                                                    0,
                                                    0,
                                                    0.5,
                                                  ),
                                                ],
                                              ),
                                              //border: Border.all(color: lightgrey),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 5,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10,
                                                bottom: 5,
                                                right: 10,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 240,
                                                    child: Text(
                                                      event.eventTitle,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontFamily: FontFamily
                                                            .gilroyBold,
                                                        fontSize: 17,
                                                        color: WhiteColor,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    event.eventSdate,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontFamily: FontFamily
                                                          .gilroyMedium,
                                                      color: WhiteColor,
                                                      fontSize: 15,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        "assets/Location.png",
                                                        color: WhiteColor,
                                                        height: 15,
                                                        width: 15,
                                                      ),
                                                      SizedBox(width: 4),
                                                      SizedBox(
                                                        width: 210,
                                                        child: Text(
                                                          event.eventPlaceName,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            fontFamily: FontFamily
                                                                .gilroyMedium,
                                                            fontSize: 15,
                                                            color: WhiteColor,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: WhiteColor,
                                    ),
                                  ),
                                );
                              },
                            ),
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
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Explore Shows",
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              color: BlackColor,
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildCategoryChip(
                                  title: "All".tr,
                                  isSelected: selectedCategoryId == 'all',
                                  onTap: () {
                                    setState(() {
                                      selectedCategoryId = 'all';
                                    });
                                  },
                                ),
                                ...availableCategories.map((category) {
                                  return _buildCategoryChip(
                                    title: category.title,
                                    imageUrl:
                                        "${Config.imageUrl}${category.catImg}",
                                    isSelected:
                                        selectedCategoryId == category.id,
                                    onTap: () {
                                      setState(() {
                                        selectedCategoryId = category.id;
                                      });
                                      _loadCategoryEvents(category.id);
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: shouldShowLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: gradient.defoultColor,
                              ),
                            )
                          : displayedEvents.isNotEmpty
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: visibleEventCount,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.65,
                                  ),
                              itemBuilder: (context, index) {
                                final event = displayedEvents[index];
                                return _buildExploreShowCard(event);
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
                    ),
                    SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Get.to(LatestEvent(eventStaus: "1"));
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: gradient.defoultColor,
                          textStyle: TextStyle(
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 15,
                          ),
                        ),
                        child: Text("View All"),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    // return GetBuilder<HomePageController>(
    //   builder: (controller) {
    //     if (!controller.isLoading) {
    //       return CircularProgressIndicator();
    //     }
    //
    //     // if (controller.homeInfo == null || controller.markers.isEmpty) {
    //     //   return Center(
    //     //     child: Column(
    //     //       mainAxisAlignment: MainAxisAlignment.center,
    //     //       children: [
    //     //         Container(
    //     //           height: 150,
    //     //           width: 200,
    //     //           decoration: BoxDecoration(
    //     //             image: DecorationImage(
    //     //                 image: AssetImage("assets/emptyOrder.png")),
    //     //           ),
    //     //         ),
    //     //         SizedBox(
    //     //           height: 10,
    //     //         ),
    //     //         Text(
    //     //           "No Event placed!",
    //     //           style: TextStyle(
    //     //               fontFamily: FontFamily.gilroyBold,
    //     //               color: BlackColor,
    //     //               fontSize: 15),
    //     //         ),
    //     //         SizedBox(height: 5),
    //     //         Text(
    //     //           "Currently you don’t have any Event.",
    //     //           style: TextStyle(
    //     //               fontFamily: FontFamily.gilroyMedium,
    //     //               color: greyColor),
    //     //         ),
    //     //       ],
    //     //     ),
    //     //   );
    //     // }
    //
    //     return Scaffold(
    //       backgroundColor: bgcolor,
    //       body: NestedScrollView(
    //         controller: _scrollController,
    //         headerSliverBuilder: (context, innerBoxIsScrolled) {
    //           return [
    //             SliverAppBar(
    //               elevation: 0,
    //               pinned: true,
    //               expandedHeight: Get.size.height * 0.36,
    //               titleSpacing: 0,
    //               backgroundColor:
    //               _isShrink ? gradient.defoultColor : transparent,
    //               leading: Padding(
    //                 padding: EdgeInsets.all(12),
    //                 child: Image.asset(
    //                   "assets/homelogo.png",
    //                   height: 20,
    //                   width: 30,
    //                 ),
    //               ),
    //               title: Text(
    //                 "MagicMate".tr,
    //                 style: TextStyle(
    //                   fontFamily: FontFamily.gilroyBold,
    //                   fontSize: 20,
    //                   color: WhiteColor,
    //                 ),
    //               ),
    //               actions: [
    //                 InkWell(
    //                   onTap: () {
    //                     if (getData.read("UserLogin") != null) {
    //                       Get.to(NotificationScreen());
    //                     } else {
    //                       Get.to(() => LoginScreen());
    //                     }
    //                   },
    //                   child: Container(
    //                     height: 40,
    //                     width: 40,
    //                     alignment: Alignment.center,
    //                     child: Image.asset(
    //                       "assets/Notification.png",
    //                       height: 20,
    //                       width: 20,
    //                       color: gradient.defoultColor,
    //                     ),
    //                     decoration: BoxDecoration(
    //                       shape: BoxShape.circle,
    //                       color: WhiteColor,
    //                     ),
    //                   ),
    //                 ),
    //                 SizedBox(
    //                   width: 5,
    //                 ),
    //               ],
    //               flexibleSpace: FlexibleSpaceBar(
    //                 background: Container(
    //                   height: Get.size.height * 0.38,
    //                   width: Get.size.width,
    //                   child: Padding(
    //                     padding:
    //                     const EdgeInsets.symmetric(horizontal: 10),
    //                     child: Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         SizedBox(
    //                           height: 45,
    //                         ),
    //                         SizedBox(
    //                           height: Get.size.height * 0.020,
    //                         ),
    //                         Text(
    //                           "Discover amazing event\nnear by you.".tr,
    //                           style: TextStyle(
    //                             fontFamily: FontFamily.gilroyBold,
    //                             fontSize: 22,
    //                             color: WhiteColor,
    //                           ),
    //                         ),
    //                         SizedBox(
    //                           height: Get.size.height * 0.040,
    //                         ),
    //                         InkWell(
    //                           onTap: () {
    //                             Get.to(SearchEventScreen());
    //                           },
    //                           child: Container(
    //                             height: 45,
    //                             width: Get.size.width,
    //                             margin: EdgeInsets.only(right: 10),
    //                             child: Row(
    //                               children: [
    //                                 SizedBox(
    //                                   width: 15,
    //                                 ),
    //                                 Image.asset(
    //                                   "assets/Search.png",
    //                                   height: 25,
    //                                   width: 25,
    //                                 ),
    //                                 SizedBox(
    //                                   width: 8,
    //                                 ),
    //                                 Text(
    //                                   "Search...".tr,
    //                                   style: TextStyle(
    //                                     fontFamily:
    //                                     FontFamily.gilroyMedium,
    //                                     color: Colors.grey.shade500,
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                             decoration: BoxDecoration(
    //                               color: WhiteColor,
    //                               borderRadius: BorderRadius.circular(40),
    //                             ),
    //                           ),
    //                         ),
    //                         SizedBox(
    //                           height: Get.size.height * 0.040,
    //                         ),
    //                         Container(
    //                           height: 35,
    //                           width: Get.size.width,
    //                           alignment: Alignment.center,
    //                           child: ListView.separated(
    //                             separatorBuilder: (context, index) =>
    //                                 SizedBox(
    //                                   width: 10,
    //                                 ),
    //                             itemCount: homePageController
    //                                 .homeInfo!.homeData.catlist.length,
    //                             scrollDirection: Axis.horizontal,
    //                             physics: BouncingScrollPhysics(),
    //                             padding: EdgeInsets.zero,
    //                             shrinkWrap: true,
    //                             itemBuilder: (context, index) {
    //                               return InkWell(
    //                                 onTap: () {
    //                                   eventDetailsController
    //                                       .getCatWiseEvent(
    //                                     catId: homePageController.homeInfo
    //                                         ?.homeData.catlist[index].id,
    //                                     title: homePageController
    //                                         .homeInfo
    //                                         ?.homeData
    //                                         .catlist[index]
    //                                         .title ??
    //                                         "",
    //                                     img: homePageController
    //                                         .homeInfo
    //                                         ?.homeData
    //                                         .catlist[index]
    //                                         .coverImg ??
    //                                         "",
    //                                   );
    //                                 },
    //                                 child: Container(
    //                                   height: 30,
    //                                   padding: EdgeInsets.symmetric(
    //                                       horizontal: 15),
    //                                   // margin: EdgeInsets.symmetric(horizontal: 8),
    //                                   alignment: Alignment.center,
    //                                   child: Row(
    //                                     children: [
    //                                       Image.network(
    //                                         "${Config.imageUrl}${homeData.catlist[index].catImg}",
    //                                         height: 20,
    //                                         width: 20,
    //                                       ),
    //                                       SizedBox(
    //                                         width: 4,
    //                                       ),
    //                                       Text(
    //                                         homePageController
    //                                             .homeInfo
    //                                             ?.homeData
    //                                             .catlist[index]
    //                                             .title ??
    //                                             "",
    //                                         style: TextStyle(
    //                                             color: BlackColor,
    //                                             fontFamily: FontFamily
    //                                                 .gilroyMedium,
    //                                             fontSize: 15),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                   decoration: BoxDecoration(
    //                                     color: WhiteColor,
    //                                     borderRadius:
    //                                     BorderRadius.circular(30),
    //                                   ),
    //                                 ),
    //                               );
    //                             },
    //                           ),
    //                         )
    //                       ],
    //                     ),
    //                   ),
    //                   decoration: BoxDecoration(
    //                     borderRadius: BorderRadius.only(
    //                       bottomLeft: Radius.circular(15),
    //                       bottomRight: Radius.circular(15),
    //                     ),
    //                     image: DecorationImage(
    //                       image: AssetImage("assets/Backgound.png"),
    //                       fit: BoxFit.cover,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ];
    //         },
    //         body: RefreshIndicator(
    //           color: gradient.defoultColor,
    //           onRefresh: () {
    //             return Future.delayed(
    //               Duration(seconds: 2),
    //                   () {
    //                 homePageController.getHomeDataApi();
    //               },
    //             );
    //           },
    //           child: ListView(
    //             shrinkWrap: true,
    //             padding: EdgeInsets.zero,
    //             physics: NeverScrollableScrollPhysics(),
    //             children: [
    //               homeData.latestEvent.isNotEmpty
    //                   ? Row(
    //                 children: [
    //                   SizedBox(
    //                     width: 15,
    //                   ),
    //                   Text(
    //                     "Latest Events".tr,
    //                     style: TextStyle(
    //                       fontFamily: FontFamily.gilroyBold,
    //                       color: BlackColor,
    //                       fontSize: 17,
    //                     ),
    //                   ),
    //                   Spacer(),
    //                   TextButton(
    //                     onPressed: () {
    //                       Get.to(LatestEvent(eventStaus: "1"));
    //                     },
    //                     child: Text(
    //                       "See All".tr,
    //                       style: TextStyle(
    //                         fontFamily: FontFamily.gilroyMedium,
    //                         color: gradient.defoultColor,
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     width: 10,
    //                   ),
    //                 ],
    //               )
    //                   : SizedBox(),
    //               homeData.latestEvent.isNotEmpty
    //                   ? SizedBox(
    //                 height: 320,
    //                 width: Get.size.width,
    //                 child: ListView.builder(
    //                   itemCount: homePageController
    //                       .homeInfo?.homeData.latestEvent.length
    //                       .clamp(0, 5),
    //                   scrollDirection: Axis.horizontal,
    //                   shrinkWrap: true,
    //                   itemBuilder: (context, index) {
    //                     return InkWell(
    //                       onTap: () async {
    //                         await eventDetailsController
    //                             .getEventData(
    //                           eventId: homePageController
    //                               .homeInfo
    //                               ?.homeData
    //                               .latestEvent[index]
    //                               .eventId,
    //                         );
    //                         Get.toNamed(
    //                           Routes.eventDetailsScreen,
    //                           arguments: {
    //                             "eventId": homePageController
    //                                 .homeInfo
    //                                 ?.homeData
    //                                 .latestEvent[index]
    //                                 .eventId,
    //                             "bookStatus": "1"
    //                           },
    //                         );
    //                       },
    //                       child: Container(
    //                         height: 320,
    //                         width: 240,
    //                         margin: EdgeInsets.only(
    //                             left: 10, right: 10, bottom: 10),
    //                         child: ClipRRect(
    //                           borderRadius:
    //                           BorderRadius.circular(30),
    //                           child: Stack(
    //                             children: [
    //                               SizedBox(
    //                                 height: 320,
    //                                 width: 240,
    //                                 child: FadeInImage.assetNetwork(
    //                                   fadeInCurve:
    //                                   Curves.easeInCirc,
    //                                   placeholder:
    //                                   "assets/ezgif.com-crop.gif",
    //                                   height: 320,
    //                                   width: 240,
    //                                   placeholderCacheHeight: 320,
    //                                   placeholderCacheWidth: 240,
    //                                   placeholderFit: BoxFit.fill,
    //                                   // placeholderScale: 1.0,
    //                                   image:
    //                                   "${Config.imageUrl}${homeData.latestEvent[index].eventImg}",
    //                                   fit: BoxFit.cover,
    //                                 ),
    //
    //                               ),
    //                               Container(
    //                                 decoration: BoxDecoration(
    //                                   gradient: LinearGradient(
    //                                     begin: Alignment.topCenter,
    //                                     end: Alignment.bottomCenter,
    //                                     stops: [0.6, 0.8, 1.5],
    //                                     colors: [
    //                                       Colors.transparent,
    //                                       Colors.black
    //                                           .withOpacity(0.5),
    //                                       Colors.black
    //                                           .withOpacity(0.5),
    //                                     ],
    //                                   ),
    //                                   //border: Border.all(color: lightgrey),
    //                                 ),
    //                               ),
    //                               Positioned(
    //                                 bottom: 5,
    //                                 child: Padding(
    //                                   padding:
    //                                   const EdgeInsets.only(
    //                                       left: 10,
    //                                       bottom: 5,
    //                                       right: 10),
    //                                   child: Column(
    //                                     crossAxisAlignment:
    //                                     CrossAxisAlignment
    //                                         .start,
    //                                     children: [
    //                                       SizedBox(
    //                                         width: 240,
    //                                         child: Text(
    //                                           homePageController
    //                                               .homeInfo
    //                                               ?.homeData
    //                                               .latestEvent[
    //                                           index]
    //                                               .eventTitle ??
    //                                               "",
    //                                           maxLines: 1,
    //                                           style: TextStyle(
    //                                             fontFamily:
    //                                             FontFamily
    //                                                 .gilroyBold,
    //                                             fontSize: 17,
    //                                             color: WhiteColor,
    //                                             overflow:
    //                                             TextOverflow
    //                                                 .ellipsis,
    //                                           ),
    //                                         ),
    //                                       ),
    //                                       SizedBox(
    //                                         height: 8,
    //                                       ),
    //                                       Text(
    //                                         homePageController
    //                                             .homeInfo
    //                                             ?.homeData
    //                                             .latestEvent[
    //                                         index]
    //                                             .eventSdate ??
    //                                             "",
    //                                         maxLines: 1,
    //                                         style: TextStyle(
    //                                           fontFamily: FontFamily
    //                                               .gilroyMedium,
    //                                           color: WhiteColor,
    //                                           fontSize: 15,
    //                                           overflow: TextOverflow
    //                                               .ellipsis,
    //                                         ),
    //                                       ),
    //                                       SizedBox(
    //                                         height: 5,
    //                                       ),
    //                                       Row(
    //                                         children: [
    //                                           Image.asset(
    //                                             "assets/Location.png",
    //                                             color: WhiteColor,
    //                                             height: 15,
    //                                             width: 15,
    //                                           ),
    //                                           SizedBox(
    //                                             width: 4,
    //                                           ),
    //                                           SizedBox(
    //                                             width: 210,
    //                                             child: Text(
    //                                               homePageController
    //                                                   .homeInfo
    //                                                   ?.homeData
    //                                                   .latestEvent[
    //                                               index]
    //                                                   .eventPlaceName ??
    //                                                   "",
    //                                               maxLines: 1,
    //                                               style: TextStyle(
    //                                                 fontFamily:
    //                                                 FontFamily
    //                                                     .gilroyMedium,
    //                                                 fontSize: 15,
    //                                                 color:
    //                                                 WhiteColor,
    //                                                 overflow:
    //                                                 TextOverflow
    //                                                     .ellipsis,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       )
    //                                     ],
    //                                   ),
    //                                 ),
    //                               )
    //                             ],
    //                           ),
    //                         ),
    //                         decoration: BoxDecoration(
    //                           borderRadius:
    //                           BorderRadius.circular(30),
    //                           color: WhiteColor,
    //                         ),
    //                       ),
    //                     );
    //                   },
    //                 ),
    //               )
    //                   : SizedBox(),
    //               homeData.nearbyEvent.isNotEmpty
    //                   ? Row(
    //                 children: [
    //                   SizedBox(
    //                     width: 15,
    //                   ),
    //                   Text(
    //                     "Nearby Event".tr,
    //                     style: TextStyle(
    //                       fontFamily: FontFamily.gilroyBold,
    //                       color: BlackColor,
    //                       fontSize: 17,
    //                     ),
    //                   ),
    //                   Spacer(),
    //                   TextButton(
    //                     onPressed: () {
    //                       Get.to(LatestEvent(eventStaus: "3"));
    //                     },
    //                     child: Text(
    //                       "See All".tr,
    //                       style: TextStyle(
    //                         fontFamily: FontFamily.gilroyMedium,
    //                         color: gradient.defoultColor,
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     width: 10,
    //                   ),
    //                 ],
    //               )
    //                   : SizedBox(),
    //               homeData.nearbyEvent.isNotEmpty
    //                   ? Container(
    //                 height: Get.height * 0.37,
    //                 width: Get.size.width,
    //                 child: ListView.builder(
    //                   shrinkWrap: true,
    //                   itemCount: homePageController
    //                       .homeInfo?.homeData.nearbyEvent.length
    //                       .clamp(0, 5),
    //                   scrollDirection: Axis.horizontal,
    //                   padding: EdgeInsets.zero,
    //                   physics: BouncingScrollPhysics(),
    //                   itemBuilder: (context, index) {
    //                     return InkWell(
    //                       onTap: () async {
    //                         await eventDetailsController
    //                             .getEventData(
    //                           eventId: homePageController
    //                               .homeInfo
    //                               ?.homeData
    //                               .nearbyEvent[index]
    //                               .eventId,
    //                         );
    //                         Get.toNamed(
    //                           Routes.eventDetailsScreen,
    //                           arguments: {
    //                             "eventId": homePageController
    //                                 .homeInfo
    //                                 ?.homeData
    //                                 .nearbyEvent[index]
    //                                 .eventId,
    //                             "bookStatus": "1",
    //                           },
    //                         );
    //                       },
    //                       child: Container(
    //                         height: Get.height * 0.37,
    //                         width: Get.width / 1.5,
    //                         margin:
    //                         EdgeInsets.symmetric(horizontal: 8),
    //                         child: Column(
    //                           children: [
    //                             Container(
    //                               height: Get.height / 4.9,
    //                               width: Get.width / 1.4,
    //                               margin: EdgeInsets.all(5),
    //                               child: ClipRRect(
    //                                 borderRadius:
    //                                 BorderRadius.circular(20),
    //                                 child: FadeInImage.assetNetwork(
    //                                   placeholder:
    //                                   "assets/ezgif.com-crop.gif",
    //                                   height: Get.height / 4.9,
    //                                   width: Get.width / 1.4,
    //                                   image:
    //                                   "${Config.imageUrl}${homeData.nearbyEvent[index].eventImg ?? ""}",
    //                                   fit: BoxFit.cover,
    //                                 ),
    //                               ),
    //                             ),
    //                             Container(
    //                               width: Get.size.width,
    //                               padding: EdgeInsets.symmetric(
    //                                   horizontal: 15),
    //                               child: Row(
    //                                 children: [
    //                                   Expanded(
    //                                     child: Column(
    //                                       mainAxisAlignment: MainAxisAlignment.center,
    //                                       crossAxisAlignment: CrossAxisAlignment.start,
    //                                       children: [
    //                                         Text(
    //                                           homeData.nearbyEvent[index].eventTitle ?? "",
    //                                           maxLines: 2,
    //                                           style: TextStyle(
    //                                             color: BlackColor,
    //                                             fontFamily:
    //                                             FontFamily
    //                                                 .gilroyBold,
    //                                             fontSize: 15,
    //                                             overflow:
    //                                             TextOverflow
    //                                                 .ellipsis,
    //                                           ),
    //                                         ),
    //                                         SizedBox(
    //                                           height: 4,
    //                                         ),
    //                                         Row(
    //                                           children: [
    //                                             Image.asset(
    //                                               "assets/Location.png",
    //                                               color: BlackColor,
    //                                               height: 15,
    //                                               width: 15,
    //                                             ),
    //                                             SizedBox(
    //                                               width: 4,
    //                                             ),
    //                                             SizedBox(
    //                                               width: Get.size.width * 0.54,
    //                                               child: Text(
    //                                                 homeData.nearbyEvent[index].eventPlaceName ??
    //                                                     "",
    //                                                 maxLines: 1,
    //                                                 style:
    //                                                 TextStyle(
    //                                                   fontFamily:
    //                                                   FontFamily
    //                                                       .gilroyMedium,
    //                                                   fontSize: 15,
    //                                                   color:
    //                                                   BlackColor,
    //                                                   overflow: TextOverflow.ellipsis,
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                           ],
    //                                         )
    //                                       ],
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                             Padding(
    //                               padding: EdgeInsets.symmetric(
    //                                   horizontal: 10),
    //                               child: Divider(
    //                                 color: Colors.grey.shade300,
    //                               ),
    //                             ),
    //                             SizedBox(
    //                               height: 6,
    //                             ),
    //                             Padding(
    //                               padding: EdgeInsets.symmetric(
    //                                   horizontal: 15),
    //                               child: Row(
    //                                 children: [
    //                                   Text(
    //                                     homePageController
    //                                         .homeInfo
    //                                         ?.homeData
    //                                         .nearbyEvent[index]
    //                                         .eventSdate ??
    //                                         "",
    //                                     style: TextStyle(
    //                                       fontFamily: FontFamily
    //                                           .gilroyMedium,
    //                                       color: greytext,
    //                                       fontSize: 14,
    //                                     ),
    //                                   )
    //                                 ],
    //                               ),
    //                             )
    //                           ],
    //                         ),
    //                         decoration: BoxDecoration(
    //                           color: WhiteColor,
    //                           borderRadius:
    //                           BorderRadius.circular(20),
    //                         ),
    //                       ),
    //                     );
    //                   },
    //                 ),
    //               )
    //                   : SizedBox(),
    //               homeData.thisMonthEvent.isNotEmpty
    //                   ? Row(
    //                 children: [
    //                   SizedBox(
    //                     width: 15,
    //                   ),
    //                   Text(
    //                     "Monthly Event".tr,
    //                     style: TextStyle(
    //                       fontFamily: FontFamily.gilroyBold,
    //                       color: BlackColor,
    //                       fontSize: 17,
    //                     ),
    //                   ),
    //                   Spacer(),
    //                   TextButton(
    //                     onPressed: () {
    //                       Get.to(LatestEvent(eventStaus: "2"));
    //                     },
    //                     child: Text(
    //                       "See All".tr,
    //                       style: TextStyle(
    //                         fontFamily: FontFamily.gilroyMedium,
    //                         color: gradient.defoultColor,
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     width: 10,
    //                   ),
    //                 ],
    //               )
    //                   : SizedBox(),
    //               homeData.thisMonthEvent.isNotEmpty
    //                   ? SizedBox(
    //                 height: Get.height * 0.37,
    //                 width: Get.size.width,
    //                 child: ListView.builder(
    //                   itemCount: homePageController
    //                       .homeInfo?.homeData.thisMonthEvent.length
    //                       .clamp(0, 5),
    //                   scrollDirection: Axis.horizontal,
    //                   physics: BouncingScrollPhysics(),
    //                   itemBuilder: (context, index) {
    //                     return InkWell(
    //                       onTap: () async {
    //                         await eventDetailsController
    //                             .getEventData(
    //                           eventId: homePageController
    //                               .homeInfo
    //                               ?.homeData
    //                               .thisMonthEvent[index]
    //                               .eventId,
    //                         );
    //                         Get.toNamed(
    //                           Routes.eventDetailsScreen,
    //                           arguments: {
    //                             "eventId": homePageController
    //                                 .homeInfo
    //                                 ?.homeData
    //                                 .thisMonthEvent[index]
    //                                 .eventId,
    //                             "bookStatus": "1",
    //                           },
    //                         );
    //                       },
    //                       child: Container(
    //                         height: Get.height * 0.37,
    //                         width: Get.width / 1.5,
    //                         margin:
    //                         EdgeInsets.symmetric(horizontal: 8),
    //                         child: Column(
    //                           children: [
    //                             Container(
    //                               height: Get.height / 4.9,
    //                               width: Get.width / 1.4,
    //                               margin: EdgeInsets.all(5),
    //                               child: ClipRRect(
    //                                 borderRadius:
    //                                 BorderRadius.circular(20),
    //                                 child: FadeInImage.assetNetwork(
    //                                   placeholder:
    //                                   "assets/ezgif.com-crop.gif",
    //                                   height: Get.height / 4.9,
    //                                   width: Get.width / 1.4,
    //                                   image:
    //                                   "${Config.imageUrl}${homeData.thisMonthEvent[index].eventImg ?? ""}",
    //                                   fit: BoxFit.cover,
    //                                 ),
    //                               ),
    //                             ),
    //                             Container(
    //                               height: 65,
    //                               width: Get.size.width,
    //                               alignment: Alignment.center,
    //                               padding: EdgeInsets.symmetric(
    //                                   horizontal: 15),
    //                               child: Row(
    //                                 children: [
    //                                   Expanded(
    //                                     child: Column(
    //                                       mainAxisAlignment:
    //                                       MainAxisAlignment
    //                                           .center,
    //                                       crossAxisAlignment:
    //                                       CrossAxisAlignment
    //                                           .start,
    //                                       children: [
    //                                         Text(
    //                                           homePageController
    //                                               .homeInfo
    //                                               ?.homeData
    //                                               .thisMonthEvent[
    //                                           index]
    //                                               .eventTitle ??
    //                                               "",
    //                                           maxLines: 2,
    //                                           style: TextStyle(
    //                                             color: BlackColor,
    //                                             fontFamily:
    //                                             FontFamily
    //                                                 .gilroyBold,
    //                                             fontSize: 15,
    //                                             overflow:
    //                                             TextOverflow
    //                                                 .ellipsis,
    //                                           ),
    //                                         ),
    //                                         SizedBox(
    //                                           height: 4,
    //                                         ),
    //                                         Row(
    //                                           children: [
    //                                             Image.asset(
    //                                               "assets/Location.png",
    //                                               color: BlackColor,
    //                                               height: 15,
    //                                               width: 15,
    //                                             ),
    //                                             SizedBox(
    //                                               width: 4,
    //                                             ),
    //                                             SizedBox(
    //                                               width: Get.size
    //                                                   .width *
    //                                                   0.54,
    //                                               child: Text(
    //                                                 homePageController
    //                                                     .homeInfo
    //                                                     ?.homeData
    //                                                     .thisMonthEvent[
    //                                                 index]
    //                                                     .eventPlaceName ??
    //                                                     "",
    //                                                 maxLines: 1,
    //                                                 style:
    //                                                 TextStyle(
    //                                                   fontFamily:
    //                                                   FontFamily
    //                                                       .gilroyMedium,
    //                                                   fontSize: 15,
    //                                                   color:
    //                                                   BlackColor,
    //                                                   overflow:
    //                                                   TextOverflow
    //                                                       .ellipsis,
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                           ],
    //                                         )
    //                                       ],
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                             Padding(
    //                               padding: EdgeInsets.symmetric(
    //                                   horizontal: 10),
    //                               child: Divider(
    //                                 color: Colors.grey.shade300,
    //                               ),
    //                             ),
    //                             SizedBox(
    //                               height: 6,
    //                             ),
    //                             Padding(
    //                               padding: EdgeInsets.symmetric(
    //                                   horizontal: 15),
    //                               child: Row(
    //                                 children: [
    //                                   Text(
    //                                     homePageController
    //                                         .homeInfo
    //                                         ?.homeData
    //                                         .thisMonthEvent[
    //                                     index]
    //                                         .eventSdate ??
    //                                         "",
    //                                     style: TextStyle(
    //                                       fontFamily: FontFamily
    //                                           .gilroyMedium,
    //                                       color: greytext,
    //                                       fontSize: 14,
    //                                     ),
    //                                   )
    //                                 ],
    //                               ),
    //                             )
    //                           ],
    //                         ),
    //                         decoration: BoxDecoration(
    //                           color: WhiteColor,
    //                           borderRadius:
    //                           BorderRadius.circular(20),
    //                         ),
    //                       ),
    //                     );
    //                   },
    //                 ),
    //               )
    //                   : SizedBox(),
    //               homeData.upcomingEvent.isNotEmpty
    //                   ? Row(
    //                 children: [
    //                   SizedBox(
    //                     width: 15,
    //                   ),
    //                   Text(
    //                     "Upcoming Event".tr,
    //                     style: TextStyle(
    //                       fontFamily: FontFamily.gilroyBold,
    //                       color: BlackColor,
    //                       fontSize: 17,
    //                     ),
    //                   ),
    //                   Spacer(),
    //                   TextButton(
    //                     onPressed: () {
    //                       Get.to(UpComingEvent());
    //                     },
    //                     child: Text(
    //                       "See All".tr,
    //                       style: TextStyle(
    //                         fontFamily: FontFamily.gilroyMedium,
    //                         color: gradient.defoultColor,
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     width: 10,
    //                   ),
    //                 ],
    //               )
    //                   : SizedBox(),
    //               homeData.upcomingEvent.isNotEmpty
    //                   ? ListView.builder(
    //                 itemCount: homePageController
    //                     .homeInfo?.homeData.upcomingEvent.length
    //                     .clamp(0, 5),
    //                 shrinkWrap: true,
    //                 physics: NeverScrollableScrollPhysics(),
    //                 padding: EdgeInsets.zero,
    //                 itemBuilder: (context, index) {
    //                   return InkWell(
    //                     onTap: () async {
    //                       await eventDetailsController.getEventData(
    //                         eventId: homePageController
    //                             .homeInfo
    //                             ?.homeData
    //                             .upcomingEvent[index]
    //                             .eventId,
    //                       );
    //                       Get.toNamed(
    //                         Routes.eventDetailsScreen,
    //                         arguments: {
    //                           "eventId": homePageController
    //                               .homeInfo
    //                               ?.homeData
    //                               .upcomingEvent[index]
    //                               .eventId,
    //                           "bookStatus": "1",
    //                         },
    //                       );
    //                     },
    //                     child: Container(
    //                       height: 120,
    //                       width: Get.size.width,
    //                       margin: EdgeInsets.only(
    //                           left: 10,
    //                           right: 10,
    //                           bottom: 10,
    //                           top: index == 0 ? 0 : 10),
    //                       child: Row(
    //                         children: [
    //                           Container(
    //                             height: 120,
    //                             width: 100,
    //                             margin: EdgeInsets.all(8),
    //                             alignment: Alignment.center,
    //                             child: ClipRRect(
    //                               borderRadius:
    //                               BorderRadius.circular(15),
    //                               child: FadeInImage.assetNetwork(
    //                                 placeholder:
    //                                 "assets/ezgif.com-crop.gif",
    //                                 height: 120,
    //                                 width: 100,
    //                                 placeholderCacheHeight: 120,
    //                                 placeholderCacheWidth: 100,
    //                                 image:
    //                                 "${Config.imageUrl}${homeData.upcomingEvent[index].eventImg}",
    //                                 fit: BoxFit.cover,
    //                               ),
    //                             ),
    //                           ),
    //                           SizedBox(
    //                             width: 5,
    //                           ),
    //                           Expanded(
    //                             child: Column(
    //                               crossAxisAlignment:
    //                               CrossAxisAlignment.start,
    //                               mainAxisAlignment:
    //                               MainAxisAlignment.center,
    //                               children: [
    //                                 Row(
    //                                   children: [
    //                                     Expanded(
    //                                       child: Text(
    //                                         homePageController
    //                                             .homeInfo
    //                                             ?.homeData
    //                                             .upcomingEvent[
    //                                         index]
    //                                             .eventTitle ??
    //                                             "",
    //                                         maxLines: 1,
    //                                         style: TextStyle(
    //                                           fontFamily: FontFamily
    //                                               .gilroyBold,
    //                                           fontSize: 15,
    //                                           color: BlackColor,
    //                                           overflow: TextOverflow
    //                                               .ellipsis,
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 SizedBox(
    //                                   height: 5,
    //                                 ),
    //                                 Row(
    //                                   children: [
    //                                     Expanded(
    //                                       child: Text(
    //                                         homePageController
    //                                             .homeInfo
    //                                             ?.homeData
    //                                             .upcomingEvent[
    //                                         index]
    //                                             .eventSdate ??
    //                                             "",
    //                                         maxLines: 1,
    //                                         style: TextStyle(
    //                                           fontFamily: FontFamily
    //                                               .gilroyMedium,
    //                                           fontSize: 14,
    //                                           color: greytext,
    //                                           overflow: TextOverflow
    //                                               .ellipsis,
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 SizedBox(
    //                                   height: 3,
    //                                 ),
    //                                 Row(
    //                                   children: [
    //                                     Image.asset(
    //                                       "assets/Location.png",
    //                                       color: BlackColor,
    //                                       height: 15,
    //                                       width: 15,
    //                                     ),
    //                                     SizedBox(
    //                                       width: 4,
    //                                     ),
    //                                     SizedBox(
    //                                       width:
    //                                       Get.size.width * 0.55,
    //                                       child: Text(
    //                                         homePageController
    //                                             .homeInfo
    //                                             ?.homeData
    //                                             .upcomingEvent[
    //                                         index]
    //                                             .eventPlaceName ??
    //                                             "",
    //                                         maxLines: 1,
    //                                         style: TextStyle(
    //                                           fontFamily: FontFamily
    //                                               .gilroyMedium,
    //                                           fontSize: 15,
    //                                           color: BlackColor,
    //                                           overflow: TextOverflow
    //                                               .ellipsis,
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 )
    //                               ],
    //                             ),
    //                           ),
    //                           SizedBox(
    //                             width: 10,
    //                           ),
    //                         ],
    //                       ),
    //                       decoration: BoxDecoration(
    //                         borderRadius: BorderRadius.circular(15),
    //                         color: WhiteColor,
    //                       ),
    //                     ),
    //                   );
    //                 },
    //               )
    //                   : SizedBox(),
    //               SizedBox(
    //                 height: 20,
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    // );
  }

  Future<void> _openEvent(String eventId) async {
    await eventDetailsController.getEventData(eventId: eventId);
    Get.toNamed(
      Routes.eventDetailsScreen,
      arguments: {"eventId": eventId, "bookStatus": "1"},
    );
  }

  void _openFeatured(_FeaturedBannerData data) {
    if (data.isPage) {
      Get.toNamed(
        Routes.loreamScreen,
        arguments: {
          "title": data.title,
          "discription": data.pageDescription.isNotEmpty
              ? data.pageDescription
              : data.subtitle,
        },
      );
      return;
    }
    if (data.eventId.isNotEmpty) {
      _openEvent(data.eventId);
    }
  }

  _FeaturedBannerData _getFeaturedEvent(HomeInfo info) {
    final featured = info.homeData.featured;
    if (featured != null && featured.isEnabled) {
      final subtitle = featured.description.isNotEmpty
          ? featured.description
          : (featured.eventPlaceName.isNotEmpty
                ? "${featured.eventPlaceName} • ${featured.eventSdate}"
                : "");
      return _FeaturedBannerData(
        type: featured.type,
        title: featured.title.isNotEmpty ? featured.title : "featured_event".tr,
        subtitle: subtitle,
        image: featured.image,
        buttonTitle: featured.buttonTitle,
        pillName: featured.pillName,
        eventId: featured.eventId,
        pageId: featured.pageId,
        pageDescription: featured.description,
      );
    }

    Event? fallbackEvent;
    if (info.homeData.nearbyEvent.isNotEmpty) {
      final nearby = info.homeData.nearbyEvent.first;
      fallbackEvent = Event(
        eventId: nearby.eventId,
        eventTitle: nearby.eventTitle,
        eventImg: nearby.eventImg,
        eventSdate: nearby.eventSdate,
        eventPlaceName: nearby.eventPlaceName,
      );
    } else if (info.homeData.latestEvent.isNotEmpty) {
      fallbackEvent = info.homeData.latestEvent.first;
    }
    if (fallbackEvent != null) {
      return _FeaturedBannerData(
        type: "event",
        title: fallbackEvent.eventTitle,
        subtitle:
            "${fallbackEvent.eventPlaceName} • ${fallbackEvent.eventSdate}",
        image: fallbackEvent.eventImg,
        buttonTitle: "",
        pillName: "",
        eventId: fallbackEvent.eventId,
        pageId: "",
        pageDescription: "",
      );
    }

    return _FeaturedBannerData(
      type: "event",
      title: "TenAlly 2026",
      subtitle: "Theatre Marina • Coming Soon",
      image: "",
      buttonTitle: "",
      pillName: "",
      eventId: "",
      pageId: "",
      pageDescription: "",
    );
  }

  Widget _buildFeaturedBanner(
    _FeaturedBannerData event, {
    bool compact = false,
  }) {
    final bannerHeight = Get.size.height * (compact ? 0.448 : 0.56);
    final bool isPlaceholder = !event.isPage && event.eventId.isEmpty;
    final pillLabel = event.pillName.isNotEmpty
        ? event.pillName
        : "featured_event".tr;
    final buttonLabel = event.buttonTitle.isNotEmpty
        ? event.buttonTitle
        : "explore_event".tr;

    return Padding(
      padding: compact
          ? const EdgeInsets.fromLTRB(16, 0, 16, 10)
          : const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: GestureDetector(
        onTap: isPlaceholder ? null : () => _openFeatured(event),
        child: Container(
          height: bannerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: event.image.isEmpty ? const Color(0xFF050B26) : null,
            image: event.image.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage("${Config.imageUrl}${event.image}"),
                    fit: BoxFit.cover,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(89, 0, 0, 0),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [
                      Colors.transparent,
                      Color.fromRGBO(0, 0, 0, 0.7),
                    ],
                    stops: [0.55, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDAA520),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        pillLabel,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyMedium,
                          fontSize: 12,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.subtitle,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: gradient.defoultColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 12,
                        ),
                      ),
                      onPressed: isPlaceholder
                          ? null
                          : () => _openFeatured(event),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            buttonLabel,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: gradient.defoultColor,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Event> _getDisplayedEvents(HomeData homeData) {
    if (selectedCategoryId == 'all') {
      return homeData.latestEvent;
    }
    return selectedCategoryEvents
        .map(
          (catEvent) => Event(
            eventId: catEvent.eventId,
            eventTitle: catEvent.eventTitle,
            eventImg: catEvent.eventImg,
            eventSdate: catEvent.eventSdate,
            eventPlaceName: catEvent.eventPlaceName,
          ),
        )
        .toList();
  }

  void _prepareCategoryValidation(HomeData homeData) {
    if (_categoriesValidated && !_needsCategoryReset) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (_needsCategoryReset) {
        setState(() {
          _hiddenCategoryIds.clear();
          _categoryEventsCache.clear();
          selectedCategoryEvents = [];
          selectedCategoryId = 'all';
          _needsCategoryReset = false;
        });
      }
      if (!_categoriesValidated) {
        _categoriesValidated = true;
        for (final category in homeData.catlist) {
          if (category.totalEvent > 0 &&
              !_hiddenCategoryIds.contains(category.id)) {
            await _prefetchCategoryData(category.id);
          }
        }
        if (mounted) setState(() {});
      }
    });
  }

  Future<void> _prefetchCategoryData(String catId) async {
    final events = await _fetchCategoryEvents(catId);
    if (events.isEmpty) {
      _markCategoryEmpty(catId);
    }
  }

  Future<List<CatWiseInfo>> _fetchCategoryEvents(String catId) async {
    if (_categoryEventsCache.containsKey(catId)) {
      return _categoryEventsCache[catId]!;
    }
    List<CatWiseInfo> fetched = [];
    try {
      final map = {
        "uid": getData.read("UserLogin") != null
            ? getData.read("UserLogin")["id"]
            : "1",
        "cat_id": catId,
      };
      final uri = Uri.parse(Config.baseurl + Config.catWiseEvent);
      final response = await http.post(uri, body: jsonEncode(map));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final data = result["CatEventData"];
        if (data is Iterable) {
          for (var element in data) {
            fetched.add(CatWiseInfo.fromJson(element));
          }
        }
      }
    } catch (_) {
      fetched = [];
    }
    _categoryEventsCache[catId] = fetched;
    return fetched;
  }

  void _markCategoryEmpty(String catId) {
    if (_hiddenCategoryIds.add(catId)) {
      if (selectedCategoryId == catId) {
        selectedCategoryId = 'all';
      }
      setState(() {});
    }
  }

  Future<void> _loadCategoryEvents(String catId) async {
    setState(() {
      isCategoryLoading = true;
      selectedCategoryEvents = [];
    });
    final events = await _fetchCategoryEvents(catId);
    if (events.isEmpty) {
      _markCategoryEmpty(catId);
    }
    setState(() {
      selectedCategoryEvents = events;
      isCategoryLoading = false;
      if (events.isEmpty) {
        selectedCategoryId = 'all';
      }
    });
  }

  Widget _buildCategoryChip({
    required String title,
    String? imageUrl,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? gradient.defoultColor : WhiteColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? gradient.defoultColor : greyColor,
            ),
          ),
          child: Row(
            children: [
              if (imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 18,
                    width: 18,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: TextStyle(
                  fontFamily: FontFamily.gilroyMedium,
                  color: isSelected ? WhiteColor : BlackColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreShowCard(Event event) {
    return InkWell(
      onTap: () async {
        await eventDetailsController.getEventData(eventId: event.eventId);
        Get.toNamed(
          Routes.eventDetailsScreen,
          arguments: {"eventId": event.eventId, "bookStatus": "1"},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: WhiteColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              child: FadeInImage.assetNetwork(
                placeholder: "assets/ezgif.com-crop.gif",
                image: "${Config.imageUrl}${event.eventImg}",
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      fontSize: 15,
                      color: BlackColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.eventSdate,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      fontSize: 13,
                      color: greytext,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Image.asset(
                        "assets/Location.png",
                        color: greyColor,
                        height: 14,
                        width: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.eventPlaceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyMedium,
                            fontSize: 13,
                            color: greyColor,
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

class _FeaturedBannerData {
  final String type;
  final String title;
  final String subtitle;
  final String image;
  final String buttonTitle;
  final String pillName;
  final String eventId;
  final String pageId;
  final String pageDescription;

  _FeaturedBannerData({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.buttonTitle,
    required this.pillName,
    required this.eventId,
    required this.pageId,
    required this.pageDescription,
  });

  bool get isPage => type.toLowerCase() == "page";
}
