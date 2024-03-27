import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phaneroo_parking/requests.dart';
import 'dart:convert';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String? serviceValue;
  String? parkingValue;
  int currentScreenIndex = 1;
  dynamic parkings;

  late Future servicesData;
  late Future vehiclesData;
  late Future parkingList;

  TextEditingController searchController = TextEditingController();
  final TextEditingController servicesController = TextEditingController();
  final TextEditingController parkingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    servicesData = getCurrentService();
    vehiclesData = getVehiclesList();
    parkingList = listParkings();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0),
          children: [
            Card(
              surfaceTintColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextFormField(
                  controller: searchController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    label: Text(
                      "Search for Vehicle or Driver Details",
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ),
                  onChanged: (String? keyword) {
                    if (keyword!.length > 2) {
                      setState(() {
                        vehiclesData = searchVehicles(keyword);
                      });
                    } else {
                      setState(() {
                        vehiclesData = getVehiclesList();
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder(
                  future: servicesData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      var jsonData = json.decode(snapshot.data!.body);
                      var services = jsonData["results"] as List;

                      return DropdownMenu(
                        initialSelection: services[0]["Name"],
                        controller: servicesController,
                        requestFocusOnTap: true,
                        label: const Text('Service'),
                        onSelected: (value) {
                          setState(() {
                            var service = services
                                .where((p) => p["Name"] == value)
                                .toList();

                            setState(() {
                              // serviceValue = name.toString();
                              vehiclesData =
                                  getServiceVehicles(service[0]["ID"]);
                            });
                          });
                        },
                        dropdownMenuEntries: services
                            .map((v) => DropdownMenuEntry(
                                  value: v["Name"],
                                  label: v["Name"],
                                ))
                            .toList(),
                      );
                    } else {
                      return const Text('Try Again');
                    }
                  },
                ),
                const SizedBox(width: 10),
                FutureBuilder(
                  future: parkingList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      var jsonData = json.decode(snapshot.data!.body);
                      var parkings = jsonData["results"] as List;

                      return DropdownMenu(
                        initialSelection: parkings[0]["Codename"],
                        controller: parkingController,
                        requestFocusOnTap: true,
                        label: const Text('Parking'),
                        onSelected: (value) {
                          setState(() {
                            var parking = parkings
                                .where((p) => p["Codename"] == value)
                                .toList();

                            setState(() {
                              // serviceValue = name.toString();
                              vehiclesData =
                                  getParkingVehicles(parking[0]["ID"]);
                            });
                          });
                        },
                        dropdownMenuEntries: parkings
                            .map((v) => DropdownMenuEntry(
                                  value: v["Codename"],
                                  label: v["Codename"],
                                ))
                            .toList(),
                      );
                    } else {
                      return const Text('Try Again');
                    }
                  },
                )
              ],
            ),
            VehicleList(vehiclesData: vehiclesData),
          ],
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {},
        //   child: const Icon(
        //     Icons.record_voice_over,
        //   ),
        // ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white,
          indicatorColor: Colors.grey.shade300,
          shadowColor: Colors.black87,
          selectedIndex: currentScreenIndex,
          onDestinationSelected: (int index) {
            currentScreenIndex = index;
            switch (index) {
              case 0:
                Navigator.pushNamed(context, "/");
                return;
              case 1:
                Navigator.pushNamed(context, "/records");
                return;
              case 2:
                Navigator.pushNamed(context, "/scan");
                return;
              // case 3:
              //   Navigator.pushNamed(context, "/interactions");
              //   return;
              case 3:
                Navigator.pushNamed(context, "/account");
                return;
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.list),
              label: "Records",
            ),
            NavigationDestination(
              icon: Icon(Icons.book),
              label: "Register",
            ),
            // NavigationDestination(
            //   icon: Icon(Icons.chat),
            //   label: "Interactions",
            // ),
            NavigationDestination(
              icon: Icon(Icons.account_circle),
              label: "Account",
            ),
          ],
        ),
      ),
    );
  }
}

class VehicleList extends StatelessWidget {
  const VehicleList({
    super.key,
    required this.vehiclesData,
  });

  final Future vehiclesData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: vehiclesData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            var jsonData = json.decode(snapshot.data!.body);
            if (jsonData["results"] == null || jsonData["results"] == Null) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text("No vehicles registered yet.")
                ],
              );
            }

            var vehicles = jsonData["results"] as List;
            int vehicleCount = vehicles.length;

            List<DataRow> widgetList = vehicles
                .map(
                  (vehicle) => DataRow(
                    cells: [
                      DataCell(
                        Text(vehicle["LicenseNumber"]),
                      ),
                      DataCell(
                        Text(vehicle["Fullname"]),
                      ),
                      vehicle["IsCheckedOut"]["Bool"] == true
                          ? const DataCell(
                              Text(
                                "OUT",
                                style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          : const DataCell(
                              Text(
                                "IN",
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                    ],
                    onSelectChanged: (isSelected) {
                      if (isSelected != null && isSelected) {
                        Map<String, dynamic> data = {
                          'licenseNo': vehicle["LicenseNumber"],
                          "id": vehicle["ID"]
                        };
                        Navigator.pushNamed(context, "/driver_details",
                            arguments: data);
                      }
                    },
                  ),
                )
                .toList();

            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        "Vehicle Count",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Text(
                        "$vehicleCount",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  DataTable(
                    border: TableBorder.all(color: Colors.grey.shade200),
                    columns: [
                      DataColumn(
                          label: Text(
                        "License",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                      DataColumn(
                          label: Text(
                        "Driver",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                      DataColumn(
                          label: Text(
                        "Status",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                    ],
                    rows: widgetList,
                  ),
                ],
              ),
            );
          } else {
            return Text(
              'Try Again',
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
        });
  }
}
