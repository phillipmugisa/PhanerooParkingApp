import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:phaneroo_parking/constants.dart';
import 'dart:convert';

Future<http.Response> getCurrentService() async {
  var url = Uri.parse("$backendUrl/services");
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

Future<http.Response> getVehicleData(int id) async {
  var url = Uri.parse("$backendUrl/vehicles/$id");
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

Future<http.Response> saveVehicle(Map<String, dynamic> data) async {
  return await http.post(
    Uri.parse(registerVehicleRoute),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(data),
  );
}

Future<http.Response> updateVehicle(int id, Map<String, dynamic> data) async {
  return await http.patch(
    Uri.parse("$backendUrl/vehicles/$id/update"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(data),
  );
}

Future<http.Response> checkoutVehicleRequest(int id) async {
  return await http.patch(
    Uri.parse("$backendUrl/vehicles/$id/checkout"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

Future<http.Response> getVehiclesList() async {
  var url = Uri.parse(listVehiclesRoute);
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

Future<http.Response> getServiceVehicles(int id) async {
  var url = Uri.parse("$backendUrl/service/$id/vehicles");
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

Future<http.Response> getParkingVehicles(int id) async {
  var url = Uri.parse("$backendUrl/parkingstations/$id/vehicles");
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

Future<http.Response> getDriverByID(int id) async {
  var url = Uri.parse("$backendUrl/drivers/$id");
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

Future<http.Response> listParkings() async {
  var url = Uri.parse(listParkingStationsRoute);
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

Future<http.Response> searchVehicles(String keyword) async {
  var url = Uri.parse("$searchRoute$keyword");
  return await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}
