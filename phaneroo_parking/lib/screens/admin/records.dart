import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phaneroo_parking/requests.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
    servicesData = listServices();
    vehiclesData = getVehiclesList();
    parkingList = listParkings();
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
              Icon(
                Icons.local_parking,
                color: Colors.white,
                size: 20,
              ),
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
            // Clickable User Avatar
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/account");
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: const Icon(
                  Icons.person, // Use any icon you prefer
                  size: 18.0,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Clickable Role Text
            // GestureDetector(
            //   onTap: () {
            //     Navigator.pushNamed(context, "/");
            //   },
            //   child: const Text(
            //     "Admin",
            //     style: TextStyle(
            //       color: Colors.black,
            //       fontSize: 14.0,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 15),

            // Clickable Logout Icon
            IconButton(
              onPressed: () {
                logoutRequest().then((response) {
                  if (response.statusCode >= 400) {
                    // not successful
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Operation now successful'),
                      ),
                    );
                    return;
                  }
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.remove("access_token");
                    prefs.remove("refresh_token");
                  });

                  Navigator.popAndPushNamed(context, "/login");
                }).catchError(
                  (err) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No Internet connection'),
                      ),
                    );
                  },
                );
              },
              icon: Icon(Icons.logout, color: Colors.white),
            ),
            const SizedBox(width: 10),
          ],
        ),

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.,
                children: [
                  FutureBuilder(
                    future: servicesData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: SizedBox(width: 0));
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        var jsonData = json.decode(snapshot.data!.body);
                        var services = jsonData["results"] as List;

                        return Expanded(
                          child: DropdownMenu(
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
                          ),
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
                        return const Center(child: SizedBox(width: 0));
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        var jsonData = json.decode(snapshot.data!.body);
                        var parkings = jsonData["results"] as List;

                        return Expanded(
                          child: DropdownMenu(
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
                          ),
                        );
                      } else {
                        return const Text('Try Again');
                      }
                    },
                  )
                ],
              ),
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
          indicatorColor: const Color.fromARGB(197, 203, 237, 250),
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
            return const Center(child: SizedBox(width: 0));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            var jsonData = json.decode(snapshot.data!.body);
            if (jsonData["results"] == null || jsonData["results"] == Null) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

            for (dynamic vehicle in vehicles) {
              vehicle["CardNumber"] = vehicle["CardNumber"]["String"];
            }

            List<DataRow> widgetList = vehicles
                .map(
                  (vehicle) => DataRow(
                    cells: [
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            Map<String, dynamic> data = {
                              'licenseNo': vehicle["LicenseNumber"],
                              "id": vehicle["ID"],
                              "is_checked_out": vehicle["IsCheckedOut"]["Bool"]
                            };
                            Navigator.pushNamed(context, "/driver_details",
                                arguments: data);
                          },
                          child: Text("${vehicle["CardNumber"]}"),
                        ),
                      ),
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            Map<String, dynamic> data = {
                              'licenseNo': vehicle["LicenseNumber"],
                              "id": vehicle["ID"],
                              "is_checked_out": vehicle["IsCheckedOut"]["Bool"]
                            };
                            Navigator.pushNamed(context, "/driver_details",
                                arguments: data);
                          },
                          child: Text(vehicle["LicenseNumber"]),
                        ),
                      ),
                      // DataCell(
                      //   GestureDetector(
                      //     onTap: () {
                      //       Map<String, dynamic> data = {
                      //         'licenseNo': vehicle["LicenseNumber"],
                      //         "id": vehicle["ID"],
                      //         "is_checked_out": vehicle["IsCheckedOut"]["Bool"]
                      //       };
                      //       Navigator.pushNamed(context, "/driver_details",
                      //           arguments: data);
                      //     },
                      //     child: Text(vehicle["Fullname"]),
                      //   ),
                      // ),
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
                    // onSelectChanged: (isSelected) {
                    //   if (isSelected != null && isSelected) {
                    //     Map<String, dynamic> data = {
                    //       'licenseNo': vehicle["LicenseNumber"],
                    //       "id": vehicle["ID"]
                    //     };
                    //     Navigator.pushNamed(context, "/driver_details",
                    //         arguments: data);
                    //   }
                    // },
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
                        "Card",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
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
                      // DataColumn(
                      //     label: Text(
                      //   "Driver",
                      //   style: GoogleFonts.lato(
                      //     textStyle: const TextStyle(
                      //       fontSize: 14.0,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // )),
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
