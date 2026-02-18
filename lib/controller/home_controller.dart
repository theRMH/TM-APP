// ignore_for_file: avoid_print, prefer_const_constructors, prefer_interpolation_to_compose_strings, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../helpar/routes_helpar.dart';
import '../model/home_info.dart';
import '../model/map_info.dart';
import '../screen/home_screen.dart';
import 'eventdetails_controller.dart';

class HomePageController extends GetxController implements GetxService {
  EventDetailsController eventDetailsController = Get.find();
  PageController pageController = PageController();

  List<MapInfo> mapInfo = [];

  bool isLoading = false;
  String? errorMessage;
  HomeInfo? homeInfo;

  CameraPosition kGoogle = CameraPosition(
    target: LatLng(21.2381962, 72.8879607),
    zoom: 5,
  );

  List<Marker> markers = <Marker>[];
  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  HomePageController() {
    getHomeDataApi();
  }

  getHomeDataApi() async {
    try {
      errorMessage = null;
      isLoading = false;
      mapInfo.clear();
      markers.clear();
      homeInfo = null;
      update();
      Map map = {
        "uid": getData.read("UserLogin") != null ? getData.read("UserLogin")["id"] : "0",
      };
      print(map.toString());
      Uri uri = Uri.parse(Config.baseurl + Config.homeDataApi);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print(uri);

      print("::::::::::________::::::::::" + response.body.toString());
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(":::RR:::::::________::::::::::" + result.toString());
        final homeData = result["HomeData"];
        final responseCode = result["ResponseCode"]?.toString();
        if (homeData != null && responseCode == "200") {
          final nearbyEvents = homeData["nearby_event"];
          if (nearbyEvents is Iterable) {
            for (var element in nearbyEvents) {
              mapInfo.add(MapInfo.fromJson(element));
            }
          }
          homeInfo = HomeInfo.fromJson(result);
          final maplist = mapInfo.reversed.toList();
          print(":::MMM:::::::________::::::::::" + result.toString());
          for (var i = 0; i < maplist.length; i++) {
            final Uint8List markIcon = await getImages("assets/MapPin.png", 100);
            markers.add(
              Marker(
                markerId: MarkerId(i.toString()),
                position: LatLng(
                  double.tryParse(mapInfo[i].eventLatitude) ?? 0,
                  double.tryParse(mapInfo[i].eventLongtitude) ?? 0,
                ),
                icon: BitmapDescriptor.fromBytes(markIcon),
                onTap: () {
                  pageController.animateToPage(i,
                      duration: Duration(seconds: 1), curve: Curves.decelerate);
                  update();
                },
                infoWindow: InfoWindow(
                  title: mapInfo[i].eventTitle,
                  snippet: mapInfo[i].eventPlaceName,
                  onTap: () async {
                    await eventDetailsController.getEventData(
                      eventId: mapInfo[i].eventId,
                    );
                    Get.toNamed(
                      Routes.eventDetailsScreen,
                      arguments: {
                        "eventId": mapInfo[i].eventId,
                        "bookStatus": "1",
                      },
                    );
                  },
                ),
              ),
            );
            kGoogle = CameraPosition(
              target: LatLng(
                double.parse(maplist[i].eventLatitude),
                double.parse(maplist[i].eventLongtitude),
              ),
              zoom: 8,
            );
          }
          final mainData = homeData["Main_Data"];
          currency = mainData != null ? mainData["currency"] : currency;
          wallet1 = homeData["wallet"] ?? wallet1;
        } else {
          errorMessage = (result["ResponseMsg"] != null && result["ResponseMsg"].toString().isNotEmpty)
              ? result["ResponseMsg"].toString()
              : "Unable to load events.";
        }
      } else {
        errorMessage = "Server error (${response.statusCode}).";
      }
    } catch (e) {
      errorMessage = e.toString();
      print(e.toString());
    } finally {
      isLoading = true;
      print("PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP");
      if (homeInfo != null) {
        errorMessage = null;
      } else {
        errorMessage ??= "Unable to load data.";
      }
      update();
    }
  }
}
