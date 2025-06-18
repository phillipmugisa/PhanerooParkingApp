import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phaneroo_parking/requests.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  int currentScreenIndex = 3;
  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController serviceDateController = TextEditingController();
  final TextEditingController serviceTimeController = TextEditingController();

  Map<String, dynamic> serviceOriginalData = {};
  Future? parkingStations;

  void updateParkingList(serviceID) {
    setState(() {
      parkingStations = listServiceParkings(serviceID);
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialization logic that doesn't depend on the context can stay here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (data != null) {
      serviceNameController.text = data["Name"];
      serviceOriginalData["name"] = data["Name"];

      List<String> result = data["Date"].split('T');
      serviceDateController.text = result[0];
      serviceOriginalData["date"] = result[0];

      List<String> results = result[1].split(':00Z');
      serviceTimeController.text = results[0];
      serviceOriginalData["time"] = results[0];

      serviceOriginalData["ID"] = data["ID"];
    }
  }

  @override
  Widget build(BuildContext context) {
    parkingStations = listServiceParkings(serviceOriginalData["ID"]);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(42, 10, 74, 1),
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
            //     "Register",
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
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: [
              EditServiceCard(
                  serviceNameController: serviceNameController,
                  serviceDateController: serviceDateController,
                  serviceTimeController: serviceTimeController,
                  serviceOriginalData: serviceOriginalData),
              const SizedBox(height: 20.0),
              CreateParkingCard(
                  serviceData: serviceOriginalData,
                  updateFunc: updateParkingList),
              const SizedBox(height: 10.0),
              ParkingSpaceSelectors(
                  parkingStations: parkingStations,
                  serviceData: serviceOriginalData,
                  updateFunc: updateParkingList),
            ],
          ),
        ),
      ),
    );
  }
}

class EditServiceCard extends StatelessWidget {
  const EditServiceCard({
    super.key,
    required this.serviceNameController,
    required this.serviceDateController,
    required this.serviceTimeController,
    required this.serviceOriginalData,
  });

  final TextEditingController serviceNameController;
  final TextEditingController serviceDateController;
  final TextEditingController serviceTimeController;
  final Map<String, dynamic> serviceOriginalData;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Edit Service Details",
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.event_note),
              ),
              controller: serviceNameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Service Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      controller: serviceDateController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Service Date is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timelapse),
                      ),
                      controller: serviceTimeController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Service Time is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    // check if data was updated
                    if (serviceNameController.text ==
                            serviceOriginalData["name"] &&
                        serviceDateController.text ==
                            serviceOriginalData["date"] &&
                        serviceTimeController.text ==
                            serviceOriginalData["time"]) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No Modification detected"),
                        ),
                      );
                      return;
                    }

                    var serviceData = <String, dynamic>{
                      "name": serviceNameController.text,
                      "date":
                          "${serviceDateController.text}T${serviceTimeController.text}:00Z",
                    };

                    updateService(serviceOriginalData["ID"], serviceData)
                        .then((response) {
                      if (response.statusCode > 399) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Update Failed"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Updated Successfully"),
                          ),
                        );
                        Navigator.popAndPushNamed(context, "/service",
                            arguments: json.decode(response.body));
                      }
                    }).catchError((err) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Connection Difficulty'),
                        ),
                      );
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20.0,
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          "Save",
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ParkingSpaceSelectors extends StatefulWidget {
  final Future? parkingStations;
  final Map<String, dynamic> serviceData;
  final Function updateFunc;

  const ParkingSpaceSelectors(
      {super.key,
      required this.parkingStations,
      required this.serviceData,
      required this.updateFunc});

  @override
  State<ParkingSpaceSelectors> createState() => _ParkingSpaceSelectorsState();
}

class _ParkingSpaceSelectorsState extends State<ParkingSpaceSelectors> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Parking Spaces.",
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Expanded(
              //   child: TextFormField(
              //     decoration: const InputDecoration(
              //       labelText: 'Search',
              //       // border: ,
              //       prefixIcon: Icon(Icons.search),
              //     ),
              //     validator: (value) {
              //       if (value == null || value.trim().isEmpty) {
              //         return 'Enter valid entry.';
              //       }
              //       return null;
              //     },
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 15.0),
          FutureBuilder(
              future: widget.parkingStations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Container();
                } else if (snapshot.hasData) {
                  final statusCode = snapshot.data!.statusCode;
                  if (statusCode >= 400 && statusCode < 500) {
                    return Container(); // Return an empty container while redirecting
                  }
                  var jsonData = json.decode(snapshot.data!.body);
                  if (jsonData["results"] == null ||
                      jsonData["results"] == Null) {
                    return const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text("No records found.")
                      ],
                    );
                  }

                  var parkings = jsonData["results"] as List;
                  List<Widget> widgetList = parkings
                      .map((parking) => ParkingPill(
                            parkingId: parking["StationID"],
                            serviceId: widget.serviceData["ID"],
                            title: parking["Name"],
                            updateFunc: widget.updateFunc,
                          ))
                      .toList();

                  return Column(
                    children: widgetList,
                  );
                } else {
                  return Container();
                }
              })
        ],
      ),
    );
  }
}

class ParkingPill extends StatefulWidget {
  final int parkingId;
  final String title;
  final int serviceId;
  final Function updateFunc;

  const ParkingPill(
      {super.key,
      required this.parkingId,
      required this.title,
      required this.serviceId,
      required this.updateFunc});

  @override
  State<ParkingPill> createState() => _ParkingPillState();
}

class _ParkingPillState extends State<ParkingPill> {
  int? selectedTeamMemberID;
  final TextEditingController teamMemberController = TextEditingController();

  void _showFormPopup(
      BuildContext context, int departmentID, Function submitFunc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Select Team Member',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
              ),
              color: Colors.black87,
            ),
          ),
          content: FutureBuilder(
            future: listDepartmentTeamRequest(departmentID),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                var jsonData = json.decode(snapshot.data!.body);
                var teamMembers = jsonData["results"] as List;

                return DropdownMenu(
                  width: double.infinity,
                  controller: teamMemberController,
                  requestFocusOnTap: true,
                  label: const Text('Select Member'),
                  onSelected: (value) {
                    selectedTeamMemberID = value["ID"];
                  },
                  dropdownMenuEntries: teamMembers
                      .map((v) => DropdownMenuEntry(
                            value: v,
                            label: v["Codename"],
                          ))
                      .toList(),
                );
              } else {
                return const Text('Try Again');
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                submitFunc(selectedTeamMemberID);
              },
              child: const Text('Deploy'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(115, 207, 207, 207),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(5.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => {
                    SharedPreferences.getInstance().then((prefs) {
                      int? departmentId = prefs.getInt("departmentId");
                      _showFormPopup(context, departmentId!, (teamMemberId) {
                        var data = <String, dynamic>{
                          "teamMemberId": teamMemberId,
                          "parkingId": widget.parkingId,
                          "serviceId": widget.serviceId
                        };

                        saveAllocation(data).then((response) {
                          if (response.statusCode > 399) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Unable to create deployment'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Saved Successfully'),
                              ),
                            );
                            // widget.updateFunc(widget.serviceId);
                          }
                        }).catchError((err) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Connection Difficulty'),
                            ),
                          );
                        });
                      });
                    })
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 5.0),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 14, 126, 72),
                        borderRadius: BorderRadius.circular(25)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          "Deploy",
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // const Divider(
          //   thickness: 1.0,
          //   color: Color.fromARGB(115, 175, 175, 175),
          // ),
          FutureBuilder(
            future:
                getServiceParkingAllocation(widget.serviceId, widget.parkingId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Container();
              } else if (snapshot.hasData) {
                final statusCode = snapshot.data!.statusCode;
                if (statusCode >= 400 && statusCode < 500) {
                  return Container(); // Return an empty container while redirecting
                }
                var jsonData = json.decode(snapshot.data!.body);
                if (jsonData["results"] == null ||
                    jsonData["results"] == Null) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 5.0),
                        child: Text("No deployements created yet."),
                      )
                    ],
                  );
                }

                var allocations = jsonData["results"] as List;

                List<DataRow> widgetList = allocations
                    .map((allocation) => DataRow(cells: [
                          DataCell(Text("${allocation["Teammembercodename"]}")),
                          DataCell(Text("${allocation["Teammembername"]}")),
                          DataCell(
                            GestureDetector(
                              onTap: () {
                                deleteAllocation(allocation["Allocationid"])
                                    .then((response) {
                                  if (response.statusCode > 399) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Unable to delete deployment'),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Deleted Successfully'),
                                      ),
                                    );
                                    widget.updateFunc(widget.serviceId);
                                  }
                                }).catchError((err) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Connection Difficulty'),
                                    ),
                                  );
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(45, 235, 139, 139),
                                    borderRadius: BorderRadius.circular(25)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add,
                                      color: Colors.red,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      "Remove",
                                      style: GoogleFonts.lato(
                                        textStyle: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        color: Colors.red,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]))
                    .toList();

                return DataTable(
                    border: TableBorder.all(color: Colors.grey.shade200),
                    columns: const [
                      DataColumn(
                        label: Text(
                          "CodeName",
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Fullname",
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Action",
                        ),
                      ),
                    ],
                    rows: widgetList);
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}

class CreateParkingCard extends StatefulWidget {
  final Map<String, dynamic> serviceData;
  final Function updateFunc;

  const CreateParkingCard(
      {super.key, required this.serviceData, required this.updateFunc});

  @override
  State<CreateParkingCard> createState() => _CreateParkingCardState();
}

class _CreateParkingCardState extends State<CreateParkingCard> {
  final TextEditingController parkingNameController = TextEditingController();
  final TextEditingController parkingCodeNameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create Parking Space",
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      controller: parkingNameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Code Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.insert_drive_file_outlined),
                      ),
                      controller: parkingCodeNameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Code name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () {
                    var parkingData = <String, String>{
                      "name": parkingNameController.text,
                      "codename": parkingCodeNameController.text
                    };

                    saveParkingStation(parkingData).then((response) {
                      if (response.statusCode > 399) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Saving Failed"),
                          ),
                        );
                      } else {
                        var jsonData = json.decode(response.body);
                        // attach to service
                        var parkingSessionData = <String, dynamic>{
                          "stationId": jsonData["ID"],
                          "serviceId": widget.serviceData["ID"],
                        };
                        saveServiceParkingStation(parkingSessionData)
                            .then((response) {
                          if (response.statusCode > 399) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Saving Failed"),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Saved Successfully"),
                              ),
                            );
                            parkingNameController.text = "";
                            parkingCodeNameController.text = "";

                            widget.updateFunc(widget.serviceData["ID"]);
                          }
                        });
                      }
                    }).catchError((err) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Connection Difficulty'),
                        ),
                      );
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(500.0),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
