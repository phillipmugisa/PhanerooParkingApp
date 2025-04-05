import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phaneroo_parking/requests.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  int currentScreenIndex = 1;
  Future? vehiclesData;

  int? currentServiceID;

  Future? userData;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    userData = getCurrentUserRequest();
    getCurrentService().then((response) {
      var jsonData = json.decode(response.body);
      currentServiceID = jsonData["ID"];
      setState(() {
        vehiclesData = currentServiceID != null
            ? getServiceVehicles(currentServiceID!)
            : Future.value(null);
      });
    }).catchError((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection Difficulty')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 1,
          title: const Row(
            children: [
              Icon(Icons.local_parking, color: Colors.white, size: 20),
              SizedBox(width: 5),
              Text(
                "ParkMaster",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/account"),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child:
                    const Icon(Icons.person, size: 18.0, color: Colors.black),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () async {
                final response = await logoutRequest();
                if (response.statusCode >= 400) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Operation not successful')),
                  );
                  return;
                }
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove("access_token");
                await prefs.remove("refresh_token");
                Navigator.popAndPushNamed(context, "/login");
              },
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
            const SizedBox(width: 10),
          ],
        ),
        backgroundColor: Colors.white,
        body: ListView(
          padding: const EdgeInsets.all(10.0),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: searchController,
                maxLines: 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  label: Text(
                    "Search by licence plate...",
                    style: GoogleFonts.lato(fontSize: 14.0),
                  ),
                ),
                onChanged: (keyword) {
                  setState(() {
                    vehiclesData = (keyword.length > 2)
                        ? searchVehicles(keyword)
                        : getServiceVehicles(currentServiceID!);
                  });
                },
              ),
            ),
            const SizedBox(height: 20.0),
            if (vehiclesData != null)
              VehicleCardList(vehiclesData: vehiclesData!),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white,
          indicatorColor: const Color.fromARGB(197, 203, 237, 250),
          selectedIndex: currentScreenIndex,
          onDestinationSelected: (index) {
            currentScreenIndex = index;
            switch (index) {
              case 0:
                Navigator.pushNamed(context, "/");
                break;
              case 1:
                Navigator.pushNamed(context, "/records");
                break;
              case 2:
                Navigator.pushNamed(context, "/scan");
                break;
            }
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(icon: Icon(Icons.list), label: "Records"),
            NavigationDestination(icon: Icon(Icons.book), label: "Register"),
          ],
        ),
      ),
    );
  }
}

class VehicleCardList extends StatelessWidget {
  const VehicleCardList({super.key, required this.vehiclesData});

  final Future vehiclesData;

  String formatTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return "--:--";
    try {
      final date = DateTime.parse(dateTimeStr);
      return DateFormat.jm().format(date);
    } catch (_) {
      return "--:--";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: vehiclesData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          var jsonData = json.decode(snapshot.data!.body);
          var vehicles = jsonData["results"] ?? [];

          if (vehicles.isEmpty) {
            return const Text("No vehicles registered yet.");
          }

          for (dynamic vehicle in vehicles) {
            vehicle["CardNumber"] = vehicle["CardNumber"]["String"];
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_parking,
                            color: Colors.indigo.shade700, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "${vehicles.length} Vehicles Parked",
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.indigo.shade200),
                      ),
                      child: Text(
                        "Parking Name",
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              vehicles.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade50,
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.car_crash,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            "No vehicles parked",
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        final isParked =
                            vehicle["IsCheckedOut"]["Bool"] != true;

                        // Determine vehicle type icon
                        IconData vehicleIcon = Icons.directions_car;
                        if (vehicle["VehicleType"] == "Motorcycle") {
                          vehicleIcon = Icons.motorcycle;
                        } else if (vehicle["VehicleType"] == "Truck") {
                          vehicleIcon = Icons.fire_truck;
                        } else if (vehicle["VehicleType"] == "Bus") {
                          vehicleIcon = Icons.directions_bus;
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/driver_details",
                              arguments: {
                                'licenseNo': vehicle["LicenseNumber"],
                                "id": vehicle["ID"],
                                "is_checked_out": vehicle["IsCheckedOut"]
                                    ["Bool"],
                              },
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isParked
                                    ? Colors.green.shade300
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // License plate header
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isParked
                                        ? Colors.green.shade50
                                        : Colors.grey.shade50,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(11),
                                      topRight: Radius.circular(11),
                                    ),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isParked
                                            ? Colors.green.shade200
                                            : Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(vehicleIcon,
                                          size: 24,
                                          color: isParked
                                              ? Colors.green.shade700
                                              : Colors.grey.shade700),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          vehicle["LicenseNumber"] ?? "Unknown",
                                          style: GoogleFonts.lato(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isParked
                                                ? Colors.green.shade800
                                                : Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isParked
                                              ? Colors.green.shade200
                                              : Colors.grey.shade300,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          vehicle["CardNumber"] ?? "--",
                                          style: GoogleFonts.lato(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isParked
                                                ? Colors.green.shade900
                                                : Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Vehicle details section
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Driver info row
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              "Driver: ${vehicle["Fullname"] ?? "Unknown"}",
                                              style: GoogleFonts.lato(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          if (vehicle["PhoneNumber"] != null &&
                                              vehicle["PhoneNumber"]
                                                  .toString()
                                                  .isNotEmpty)
                                            Row(
                                              children: [
                                                const Icon(Icons.phone,
                                                    size: 14,
                                                    color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  vehicle["PhoneNumber"] ?? "",
                                                  style: GoogleFonts.lato(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Time info row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.login,
                                                  size: 14,
                                                  color: Colors.blue.shade700),
                                              const SizedBox(width: 4),
                                              Text(
                                                "In: ${formatTime(vehicle["CheckInTime"]["Time"])}",
                                                style: GoogleFonts.lato(
                                                  fontSize: 13,
                                                  color: Colors.blue.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          isParked
                                              ? Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.green.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: Colors
                                                            .green.shade300),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.timer,
                                                          size: 12,
                                                          color: Colors.green),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        "CURRENTLY PARKED",
                                                        style: GoogleFonts.lato(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .green.shade900,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Row(
                                                  children: [
                                                    Icon(Icons.logout,
                                                        size: 14,
                                                        color: Colors
                                                            .red.shade700),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "Out: ${formatTime(vehicle["CheckOutTime"]["Time"])}",
                                                      style: GoogleFonts.lato(
                                                        fontSize: 13,
                                                        color:
                                                            Colors.red.shade700,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
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
                      },
                    ),
            ],
          );
        } else {
          return const Center(child: Text("Try Again"));
        }
      },
    );
  }
}
