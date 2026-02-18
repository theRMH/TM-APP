// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, sized_box_for_whitespace, prefer_typing_uninitialized_variables, unnecessary_brace_in_string_interps, must_be_immutable, prefer_interpolation_to_compose_strings, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/eventdetails_controller.dart';
import '../helpar/routes_helpar.dart';
import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';
import '../utils/Custom_widget.dart';
import 'home_screen.dart' as home_screen;

double _parseTicketPrice(String? value) {
  if (value == null || value.isEmpty) return 0.0;
  final sanitized = value.replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(sanitized) ?? 0.0;
}

String _formatAmount(double amount, String currencySymbol) {
  return '$currencySymbol${amount.toStringAsFixed(2)}';
}

String _formatAmountFromString(String? value, String currencySymbol) {
  return _formatAmount(_parseTicketPrice(value), currencySymbol);
}

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({super.key});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  EventDetailsController eventDetailsController = Get.find();
  @override
  void initState() {
    super.initState();
    eventDetailsController.mTotal = 0.0;
    eventDetailsController.totalTicket = 0;
  }

  int _selectedIndex = -1;

  String get _currencySymbol => home_screen.currency ?? "₹";

  void _updateCount(int index, int delta) {
    final ticket = eventDetailsController.ticketInfo?.eventTypePrice[index];
    if (ticket == null) return;

    final bool switchingType = _selectedIndex != index;
    final currentCount =
        switchingType ? 0 : eventDetailsController.totalTicket;
    final newCount = (currentCount + delta).clamp(0, ticket.remainTicket);
    if (newCount == currentCount) return;

    setState(() {
      if (newCount > 0) {
        _selectedIndex = index;
      } else if (_selectedIndex == index) {
        _selectedIndex = -1;
      }
      eventDetailsController.totalTicket = newCount;
    });

    final pricePer = _parseTicketPrice(ticket.ticketPrice);
    final total = pricePer * newCount;
    if (newCount > 0) {
      eventDetailsController.getTotal(total: total);
      eventDetailsController.getEventTicketData(
        ticketId1: ticket.typeid,
        ticketType1: ticket.ticketType,
        ticketPrice1: ticket.ticketPrice,
        totalTicket1: newCount.toString(),
      );
      eventDetailsController.totalTicke = ticket.totalTicket.toString();
    } else {
      eventDetailsController.totalTicket = 0;
      eventDetailsController.getTotal(total: 0);
      eventDetailsController.clearEventTicketData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: WhiteColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Ticket Details".tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
            color: BlackColor,
          ),
        ),
        leading: BackButton(
          onPressed: () {
            Get.back();
          },
          color: BlackColor,
        ),
      ),
      bottomNavigationBar: GetBuilder<EventDetailsController>(
        builder: (context) {
          return GestButton(
            height: 50,
            Width: Get.size.width,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            buttoncolor: gradient.defoultColor,
            buttontext:
                "${"PURCHASE".tr} - ${_currencySymbol}${eventDetailsController.mTotal.toStringAsFixed(2)}",
            style: TextStyle(
              color: WhiteColor,
              fontFamily: FontFamily.gilroyBold,
              fontSize: 15,
            ),
            onclick: () {
              if (eventDetailsController.totalTicket != 0) {
                Get.toNamed(
                  Routes.orderDetailsScreen,
                  arguments: {
                    "total": eventDetailsController.mTotal,
                  },
                );
              } else {
                showToastMessage("Please Select Your Favorite Ticket!".tr);
              }
            },
          );
        },
      ),
      body: GetBuilder<EventDetailsController>(builder: (context) {
        return eventDetailsController.isLoading
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "WHAT TICKETS WOULD YOU LIKE?".tr,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 16,
                        color: BlackColor,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: eventDetailsController
                            .ticketInfo?.eventTypePrice.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final count = _selectedIndex == index
                              ? eventDetailsController.totalTicket
                              : 0;
                          return ListOfCounter(
                            index: index,
                            count: count,
                            isSelected: _selectedIndex == index && count > 0,
                            currencySymbol: _currencySymbol,
                            onIncrement: () => _updateCount(index, 1),
                            onDecrement: () => _updateCount(index, -1),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                  color: gradient.defoultColor,
                ),
              );
      }),
    );
  }
}

class ListOfCounter extends StatelessWidget {
  final int index;
  final int count;
  final bool isSelected;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final String currencySymbol;

  const ListOfCounter({
    Key? key,
    required this.index,
    required this.count,
    required this.isSelected,
    required this.onIncrement,
    required this.onDecrement,
    required this.currencySymbol,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eventDetailsController = Get.find<EventDetailsController>();
    final ticket =
        eventDetailsController.ticketInfo?.eventTypePrice[index];
    if (ticket == null) return const SizedBox();

    final pricePer = _parseTicketPrice(ticket.ticketPrice);
    final total = pricePer * count;

    return Container(
      height: 120,
      width: Get.size.width,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipPath(
            clipper: OvalRightBorderClipper(),
            child: Container(
              height: 120,
              width: 80,
              alignment: Alignment.center,
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontFamily: FontFamily.gilroyBold,
                  fontSize: 25,
                  color: isSelected ? WhiteColor : BlackColor,
                ),
              ),
              decoration: BoxDecoration(
                color: isSelected ? gradient.defoultColor : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.ticketType,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    fontSize: 17,
                    color: BlackColor,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  ticket.description,
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyMedium,
                    fontSize: 14,
                    color: BlackColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "${ticket.remainTicket} ${"spots left".tr}",
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    fontSize: 14,
                    color: Color(0xFFFF5E4E),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "x ${_formatAmountFromString(ticket.ticketPrice, currencySymbol)} = ${_formatAmount(total, currencySymbol)}",
                  style: TextStyle(
                    color: gradient.defoultColor,
                    fontFamily: FontFamily.gilroyBold,
                    fontSize: 14,
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 120,
            width: 50,
            child: Column(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onIncrement,
                    child: Container(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.add,
                        color: gradient.defoultColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: onDecrement,
                    child: Container(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.remove,
                        color: gradient.defoultColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: WhiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(
              0.5,
              0.5,
            ),
            blurRadius: 0.5,
            spreadRadius: 0.5,
          ), //BoxShadow
          BoxShadow(
            color: Colors.white,
            offset: const Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.0,
          ), //BoxShadow
        ],
      ),
    );
  }
}

class OvalRightBorderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - 25, 0);
    path.quadraticBezierTo(
        size.width, size.height / 2, size.width - 25, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
