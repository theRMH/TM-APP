// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../Api/config.dart';
import '../Api/data_store.dart';

class TheatreController extends GetxController {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> productions = [];

  @override
  void onInit() {
    super.onInit();
    fetchProductions();
  }

  String get _userId =>
      (getData.read("UserLogin") != null ? getData.read("UserLogin")["id"] : "0")
          .toString();

  Future<void> fetchProductions() async {
    isLoading = true;
    errorMessage = null;
    update();
    final uri = Uri.parse(Config.baseurl + Config.homeDataApi);
    final payload = {"uid": _userId};

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      if (response.statusCode != 200) {
        errorMessage = "Server error (${response.statusCode})";
        productions = [];
      } else {
        final decoded = jsonDecode(response.body);
        final responseCode = decoded["ResponseCode"]?.toString();
        if (responseCode == "200" && decoded["HomeData"] != null) {
          final homeData = decoded["HomeData"];
        final Map<String, Map<String, dynamic>> unique = {};
        final List<String> keys = ["latest_event", "upcoming_event", "nearby_event"];
        for (final key in keys) {
          final value = homeData[key];
          if (value is Iterable) {
            for (final item in value) {
              Map<String, dynamic> entry;
              if (item is Map<String, dynamic>) {
                entry = item;
              } else if (item is Map) {
                entry = Map<String, dynamic>.from(item);
              } else {
                continue;
              }
              final id = entry["event_id"]?.toString() ??
                  entry["id"]?.toString() ??
                  entry["eventId"]?.toString();
              if (id == null) continue;
              if (!unique.containsKey(id)) {
                unique[id] = entry;
              }
            }
          }
        }
        productions = unique.values.toList();
          if (productions.isEmpty) {
            errorMessage = "No productions are available right now.";
          }
        } else {
          errorMessage =
              decoded["ResponseMsg"]?.toString() ?? "Unable to load productions.";
          productions = [];
        }
      }
    } catch (e) {
      errorMessage = e.toString();
      productions = [];
    } finally {
      isLoading = false;
      update();
    }
  }
}
