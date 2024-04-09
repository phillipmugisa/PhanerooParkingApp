import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:phaneroo_parking/constants.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<http.Response> getCurrentService() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.get("access_token").toString();

  var url = Uri.parse("$backendUrl/services");
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $accessToken',
    },
  );
}

Future<http.Response> getVehicleData(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.get("access_token").toString();

  var url = Uri.parse("$backendUrl/vehicles/$id");
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $accessToken',
    },
  );
}

Future<http.Response> saveVehicle(Map<String, dynamic> data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.get("access_token").toString();

  return await http.post(
    Uri.parse(registerVehicleRoute),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $accessToken',
    },
    body: jsonEncode(data),
  );
}

Future<http.Response> updateVehicle(int id, Map<String, dynamic> data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.get("access_token").toString();

  return await http.patch(
    Uri.parse("$backendUrl/vehicles/$id/update"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $accessToken',
    },
    body: jsonEncode(data),
  );
}

Future<http.Response> checkoutVehicleRequest(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.get("access_token").toString();

  return await http.patch(
    Uri.parse("$backendUrl/vehicles/$id/checkout"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $accessToken',
    },
  );
}

Future<http.Response> getVehiclesList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.get("access_token").toString();

  var url = Uri.parse(listVehiclesRoute);
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $accessToken',
    },
  );
}

Future<http.Response> getServiceVehicles(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.get("access_token").toString();

  var url = Uri.parse("$backendUrl/service/$id/vehicles");
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $accessToken',
    },
  );
}

Future<http.Response> getParkingVehicles(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.get("access_token").toString();

  var url = Uri.parse("$backendUrl/parkingstations/$id/vehicles");
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $accessToken',
    },
  );
}

Future<http.Response> getDriverByID(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.get("access_token").toString();

  var url = Uri.parse("$backendUrl/drivers/$id");
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $accessToken',
    },
  );
}

Future<http.Response> listParkings() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.get("access_token").toString();

  var url = Uri.parse(listParkingStationsRoute);
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $accessToken',
    },
  );
}

Future<http.Response> searchVehicles(String keyword) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.get("access_token").toString();

  var url = Uri.parse("$searchRoute$keyword");
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $accessToken',
    },
  );
}

// users and auth
Future<http.Response> registerUserRequest(Map<String, dynamic> data) async {
  return await http.post(
    Uri.parse(registerUserRoute),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(data),
  );
}

Future<http.Response> loginRequest(Map<String, dynamic> data) async {
  return await http.post(
    Uri.parse(loginRoute),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(data),
  );
}

Future<http.Response> logoutRequest() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.get("access_token").toString();

  return await http.get(
    Uri.parse(logoutRoute),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $accessToken',
    },
  );
}

Future<http.Response> refreshTokenRequest() async {
  Map<String, dynamic> data = {};

  SharedPreferences prefs = await SharedPreferences.getInstance();
  data["refresh_token"] = prefs.get("refresh_token").toString();

  return await http.post(
    Uri.parse(refreshTokenRoute),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(data),
  );
}

Future<http.Response> getCurrentUserRequest() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.get("access_token").toString();

  return await http.get(
    Uri.parse(currentUserRoute),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $accessToken',
    },
  );
}
