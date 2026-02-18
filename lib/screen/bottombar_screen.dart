// ignore_for_file: prefer_const_constructors, sort_child_properties_last, sized_box_for_whitespace, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magicmate_user/screen/profile/profile_screen.dart';
import 'package:magicmate_user/screen/theatre/theatre_screen.dart';
import 'package:magicmate_user/screen/tenally/tenally_screen.dart';
import 'package:provider/provider.dart';

import '../Api/data_store.dart';
import '../controller/login_controller.dart';
import '../firebase/chat_page.dart';
import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';
import 'LoginAndSignup/login_screen.dart';
import 'home_screen.dart';
import 'myTicket/myticket_screen.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

int selectedIndex = 0;

class _BottomBarScreenState extends State<BottomBarScreen> with WidgetsBindingObserver {
  List<Widget> myChilders = [
    HomeScreen(),
    TheatreScreen(),
    TenallyScreen(),
    ProfileScreen(),
  ];

  var isLogin;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _updateUserStatus(true);
    if (getData.read("currentIndex") == true) {
      save("currentIndex", false);
    } else {
      selectedIndex = 0;
    }
    super.initState();
    isLogin = getData.read("UserLogin");
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _updateUserStatus(true);
        break;
      case AppLifecycleState.inactive:
        _updateUserStatus(false);
        break;
      case AppLifecycleState.paused:
        _updateUserStatus(false);
        break;
      case AppLifecycleState.detached:
        _updateUserStatus(false);
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  void _updateUserStatus(bool isOnline) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = _getLoggedInUserId();
    if (userId == null) return;
    userProvider.updateUserStatus(userId, isOnline);
  }

  String? _getLoggedInUserId() {
    final user = getData.read("UserLogin");
    if (user == null) return null;
    final id = user["id"];
    if (id == null) return null;
    return id.toString();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        exit(0);
      },

      child: Scaffold(
        bottomNavigationBar: GetBuilder<LoginController>(builder: (context) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: greyColor,
            // backgroundColor: BlackColor,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
                fontFamily: 'Gilroy Bold',
                // fontWeight: FontWeight.bold,
                fontSize: 12),
            fixedColor: gradient.defoultColor,
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Gilroy Medium',
            ),
            currentIndex: selectedIndex,
            landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/home-dash.png",
                  color: selectedIndex == 0 ? gradient.defoultColor : greytext,
                  height: Get.size.height / 35,
                ),
                label: 'Home'.tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.theaters,
                  color: selectedIndex == 1 ? gradient.defoultColor : greytext,
                  size: Get.size.height / 35,
                ),
                label: 'Theatre'.tr,
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/Ticket.png",
                  color: selectedIndex == 2 ? gradient.defoultColor : greytext,
                  height: Get.size.height / 35,
                ),
                label: 'Tenally'.tr,
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/Profile.png",
                  color: selectedIndex == 3 ? gradient.defoultColor : greytext,
                  height: Get.size.height / 35,
                ),
                label: 'Profile'.tr,
              ),
            ],
            onTap: (index) {
              if (index == 3 && isLogin == null) {
                selectedIndex = 0;
                setState(() {});
                Get.to(() => LoginScreen());
                return;
              }
              setState(() {
                selectedIndex = index;
              });
            },
          );
        }),
        body: GetBuilder<LoginController>(builder: (context) {
          return myChilders[selectedIndex];
        }),
      ),
    );
  }

}
