import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phaneroo_parking/requests.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  late Future userData;

  @override
  void initState() {
    super.initState();
    userData = getCurrentUserRequest();
  }

  @override
  Widget build(BuildContext context) {
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
        body: FutureBuilder(
            future: userData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: SizedBox());
              } else if (snapshot.hasError) {
                Future.delayed(Duration.zero, () {
                  Navigator.pushNamed(context, '/login');
                });
                // Return an empty container while redirecting
                return Container();
              } else if (snapshot.hasData) {
                final statusCode = snapshot.data!.statusCode;
                if (statusCode >= 400 && statusCode < 500) {
                  // Handle client errors (e.g., unauthorized)
                  Future.delayed(Duration.zero, () {
                    Navigator.pushNamed(context, '/login');
                  });
                  return Container(); // Return an empty container while redirecting
                }
                var jsonData = json.decode(snapshot.data!.body);

                SharedPreferences.getInstance().then((prefs) {
                  prefs.setInt("userID", jsonData["ID"]);
                  prefs.setInt("departmentId", jsonData["DepartmentID"]);
                });

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView(
                    children: [
                      IntroCard(userData: jsonData),
                      const SizedBox(height: 20.0),
                      const CreateService(),
                      const SizedBox(height: 10.0),
                      const ServicesList(),
                    ],
                  ),
                );
              } else {
                Future.delayed(Duration.zero, () {
                  Navigator.pushNamed(context, '/login');
                });
                // Return an empty container while redirecting
                return Container();
              }
            }),
      ),
    );
  }
}

class IntroCard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const IntroCard({super.key, required this.userData});

  @override
  State<IntroCard> createState() => _IntroCardState();
}

class _IntroCardState extends State<IntroCard> {
  late Future currentServiceData;

  @override
  void initState() {
    super.initState();
    currentServiceData = getCurrentService();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(197, 203, 237, 250),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello ${widget.userData["Codename"]}',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 2.5),
                FutureBuilder(
                  future: currentServiceData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: SizedBox());
                    } else if (snapshot.hasError) {
                      return Container();
                    } else if (snapshot.hasData) {
                      final statusCode = snapshot.data!.statusCode;
                      if (statusCode >= 400 && statusCode < 500) {
                        return Container(); // Return an empty container while redirecting
                      }
                      var jsonData = json.decode(snapshot.data!.body);
                      return Text(
                        'Welcome to ${jsonData["Name"]}',
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                const SizedBox(height: 2.5),
                Text(
                  "12/12/2030",
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesList extends StatefulWidget {
  const ServicesList({
    super.key,
  });

  @override
  State<ServicesList> createState() => _ServicesListState();
}

class _ServicesListState extends State<ServicesList> {
  late Future serviceList;

  @override
  void initState() {
    super.initState();
    serviceList = listServices();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Service Records",
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
              future: serviceList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: SizedBox());
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
                        Text("No services created yet.")
                      ],
                    );
                  }

                  var services = jsonData["results"] as List;

                  List<DataRow> widgetList = services
                      .map(
                        (service) => DataRow(
                          cells: <DataCell>[
                            DataCell(
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, "/service",
                                      arguments: service);
                                },
                                child: Text(
                                  service["Name"],
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text("${service["Date"].split("T")[0]}")),
                          ],
                        ),
                      )
                      .toList();

                  return DataTable(
                    border: TableBorder.all(color: Colors.grey.shade200),
                    columns: const [
                      DataColumn(
                        label: Text(
                          "Service",
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Date",
                        ),
                      ),
                    ],
                    rows: widgetList,
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

class CreateService extends StatefulWidget {
  const CreateService({
    super.key,
  });

  @override
  State<CreateService> createState() => _CreateServiceState();
}

class _CreateServiceState extends State<CreateService> {
  bool? _isDeploymentChecked = false;
  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController serviceDateController = TextEditingController();
  final TextEditingController serviceTimeController = TextEditingController();

  void _deploymentCheckboxChanged(bool? value) {
    setState(() {
      _isDeploymentChecked = value;
    });
  }

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
              "Create New Service",
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
                        hintText: "2024-10-31",
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
                        hintText: "17:00",
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     Checkbox(
                //       value: _isDeploymentChecked,
                //       onChanged: _deploymentCheckboxChanged,
                //       activeColor: Colors.blue,
                //       checkColor: Colors.white,
                //     ),
                //     GestureDetector(
                //       onTap: () {
                //         _deploymentCheckboxChanged(
                //             _isDeploymentChecked == true ? false : true);
                //       },
                //       child: Text(
                //         "Deployment same as previous.",
                //         style: GoogleFonts.lato(
                //           textStyle: const TextStyle(
                //             fontSize: 12.0,
                //             fontWeight: FontWeight.normal,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () {
                    // save data

                    var serviceData = <String, dynamic>{
                      "name": serviceNameController.text,
                      "date":
                          "${serviceDateController.text}T${serviceTimeController.text}:00Z",
                    };

                    saveService(serviceData).then((response) {
                      var jsonData = json.decode(response.body);

                      if (response.statusCode > 399) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unable to create Service'),
                          ),
                        );
                      } else {
                        // handle deployment
                        if (_isDeploymentChecked == true) {}

                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Success'),
                            content: const Text('Saved Successfully'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, "/service",
                                    arguments: jsonData),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
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
                          "Create Service",
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
