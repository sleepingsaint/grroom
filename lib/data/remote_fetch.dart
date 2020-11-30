import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grroom/models/influencer.dart';
import 'package:grroom/models/stylist.dart';
import 'package:grroom/utils/all_provider.dart';
import 'package:http/http.dart' as http;

class RemoteFetch {
  static Future<List<Influencer>> getAllInfluencers() async {
    String headerToken = await FlutterSecureStorage().read(key: "token");

    String _endpoint = "https://groombackend.herokuapp.com/api/v1/influencer";
    var resp = await http.get(_endpoint,
        headers: {HttpHeaders.authorizationHeader: "Bearer $headerToken"});

    {
      var data = jsonDecode(resp.body)["data"];

      List<Influencer> influencers = [];

      data.forEach((inf) {
        influencers.add(Influencer.fromResp(inf));
      });
      return influencers.reversed.toList();
    }
  }

  static Future<bool> getConstants({AllProvider provider}) async {
    List<String> events = [];
    List<Map<String, dynamic>> styles = [];
    List<String> season = [];
    List<String> types = [];
    List<String> gender = [];
    List<String> bodySize = [];
    List<String> underTone = [];
    Map<String, dynamic> bodyShape = {};
    String _endpoint = "https://groombackend.herokuapp.com/api/v1/constant";
    var resp = await http.get(_endpoint);
    var json = jsonDecode(resp.body);

    json["data"]["events"].forEach((e) => events.add(e["category"]));
    json["data"]["season"].forEach((e) => season.add(e));
    json["data"]["types"].forEach((e) => types.add(e));
    json["data"]["gender"].forEach((e) => gender.add(e));
    json["data"]["bodySize"].forEach((e) => bodySize.add(e));
    json["data"]["underTone"].forEach((e) => underTone.add(e));
    json["data"]["styles"].forEach(
      (e) => styles.add(
        {
          "category": e["category"],
          "value": e["value"],
        },
      ),
    );
    bodyShape = json["data"]["bodyShape"];

    provider.updateBaseEvents(events);
    provider.updateBaseSeason(season);
    provider.updateBaseTypes(types);
    provider.updateBaseGender(gender);
    provider.updateBaseBodySize(bodySize);
    provider.updateBaseBodyshape(bodyShape);
    provider.updateBaseUndertone(underTone);
    provider.updateBaseStyles(styles);

    return true;
  }

  static Future<List<Stylist>> getAllStylists() async {
    String headerToken =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjVmYjBmODc3M2NiOTgzMDAxNzA0MDM5OCIsImlhdCI6MTYwNjczNjcxNiwiZXhwIjoxNjE0NTEyNzE2fQ.4L_YPd7ZIdF8RKsLceSoTv4MfQ99JNEUy2YrbhN8k8M";
    Dio dio = Dio();
    dio.options.headers = {
      HttpHeaders.authorizationHeader: "Bearer $headerToken",
      HttpHeaders.contentTypeHeader: 'application/json'
    };

    String _endpoint = "https://groombackend.herokuapp.com/api/v1/meta/";

    var resp = await dio.get(_endpoint);
    print(resp.data["data"]);

    final data = resp.data["data"] ?? [];

    List<Stylist> stylists = [];

    data.forEach((stylist) {
      stylists.add(Stylist.fromJson(stylist));
    });

    return stylists.reversed.toList();
  }
}
