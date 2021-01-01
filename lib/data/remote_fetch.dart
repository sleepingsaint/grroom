import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grroom/models/influencer.dart';
import 'package:grroom/models/stylist.dart';
import 'package:grroom/utils/all_provider.dart';
import 'package:http/http.dart' as http;

abstract class RemoteFetch {
  static Future<List<Influencer>> getAllInfluencers(
      {int pageNumber, int limit}) async {
    String headerToken = await FlutterSecureStorage().read(key: "token");

    String _endpoint =
        "http://134.209.158.65/api/v1/influencer?page=$pageNumber&limit=$limit&sort=-createdAt";
    var resp = await http.get(_endpoint, headers: {
      HttpHeaders.authorizationHeader: "Bearer $headerToken",
      HttpHeaders.connectionHeader: "keep-alive"
    });
    var data = jsonDecode(resp.body)["data"];

    if (resp.statusCode == 500 || data == null) {
      return <Influencer>[];
    } else {
      List<Influencer> influencers = [];

      data.forEach((inf) {
        influencers.add(Influencer.fromResp(inf));
      });
      return influencers.toList();
    }
  }

  static Future<int> getInfluencersCount() async {
    String headerToken = await FlutterSecureStorage().read(key: "token");

    String _endpoint = "http://134.209.158.65/api/v1/influencer";
    var resp = await http.get(_endpoint, headers: {
      HttpHeaders.authorizationHeader: "Bearer $headerToken",
      HttpHeaders.connectionHeader: "keep-alive"
    });
    var data = jsonDecode(resp.body)["total"];

    return data as int;
  }

  static Future<int> getStylistCount() async {
    String headerToken = await FlutterSecureStorage().read(key: "token");

    String _endpoint = "http://134.209.158.65/api/v1/meta";
    var resp = await http.get(_endpoint,
        headers: {HttpHeaders.authorizationHeader: "Bearer $headerToken"});
    var data = jsonDecode(resp.body)["total"];

    return data as int;
  }

  static Future<List<Stylist>> getParticularMeta(
      {String id, int pageNumber, int limit}) async {
    List<Stylist> stylists = [];

    String headerToken = await FlutterSecureStorage().read(key: "token");
    String role = await FlutterSecureStorage().read(key: "role");

    String _endpoint =
        "http://134.209.158.65/api/v1/user/records/$id?page=$pageNumber&limit=$limit&sort=-createdAt";
    var resp = await http.get(_endpoint, headers: {
      HttpHeaders.authorizationHeader: "Bearer $headerToken",
      HttpHeaders.connectionHeader: "keep-alive"
    });

    var data = jsonDecode(resp.body)['data'] ?? [];
    int count = 0;

    if (data == []) {
      return [];
    } else {
      data.forEach((e) {
        var json = e["file"];
        if (json == null) {
          count++;
          print(count);
        } else {
          stylists.add(
            Stylist(
              style: Style.fromJson(json["style"]),
              location: json['location'].toString(),
              events: List<String>.from(json["events"].map((x) => x)),
              season: List<String>.from(json["season"].map((x) => x)),
              createdAt: DateTime.parse(json["createdAt"]),
              id: json["_id"],
              influencerId: json["influencerID"],
              type: json["type"],
              place: json["place"],
              image: json["image"],
            ),
          );
        }
      });

      return stylists.toList();
    }
  }

  static Future<int> getCountParticularMeta(
      {String id, int pageNumber, int limit}) async {
    String headerToken = await FlutterSecureStorage().read(key: "token");

    String _endpoint = "http://134.209.158.65/api/v1/user/records/$id";
    var resp = await http.get(_endpoint, headers: {
      HttpHeaders.authorizationHeader: "Bearer $headerToken",
      HttpHeaders.connectionHeader: "keep-alive"
    });

    var data = jsonDecode(resp.body)["total"];

    return data as int;
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
    String _endpoint = "http://134.209.158.65/api/v1/constant";
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

  static Future<List<Stylist>> getAllStylists(
      {int pageNumber, int limit}) async {
    List<Stylist> stylists = [];

    String headerToken = await FlutterSecureStorage().read(key: "token");
    String role = await FlutterSecureStorage().read(key: "role");

    Dio dio = Dio();
    dio.options.headers = {
      HttpHeaders.authorizationHeader: "Bearer $headerToken",
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.connectionHeader: "keep-alive"
    };

    String _endpoint =
        "http://134.209.158.65/api/v1/meta/?page=$pageNumber&limit=$limit&sort=-createdAt";

    try {
      var resp = await dio.get(_endpoint);
      final data = resp.data["data"];
      if (resp.statusCode == 404 || data == null) {
        return [];
      } else {
        final data = resp.data["data"] ?? [];

        if (role == 'user') {
          data.forEach((e) {
            var json = e["file"];
            if (json == null) {
            } else {
              stylists.add(Stylist(
                style: Style.fromJson(json["style"]),
                location: json['location'].toString(),
                events: List<String>.from(json["events"].map((x) => x)),
                season: List<String>.from(json["season"].map((x) => x)),
                createdAt: DateTime.parse(json["createdAt"]),
                id: json["_id"],
                influencerId: json["influencerID"],
                type: json["type"],
                place: json["place"],
                image: json["image"],
              ));
            }
          });
        } else {
          data.forEach((e) {
            stylists.add(Stylist.fromJson(e));
          });
        }
        return stylists.toList();
      }
    } catch (e) {
      return [];
    }
  }
}
