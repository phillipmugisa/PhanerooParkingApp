import 'package:flutter/material.dart';
import 'package:phaneroo_parking/requests.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? currentServiceID;
  Map<String, dynamic>? currentServiceData;
  late Future userData;

  @override
  void initState() {
    super.initState();
    userData = getCurrentUserRequest();
    getCurrentService().then((response) {
      var jsonData = json.decode(response.body);
      currentServiceID = jsonData["ID"];
      currentServiceData = jsonData;
    }).catchError((val) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection Difficulty'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    int currentScreenIndex = 0;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder(
            future: userData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
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
                return ListView(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                  children: [
                    // TopPageActions(),
                    // SizedBox(height: 10.0),
                    // current user information
                    PersonnalDetails(
                        userData: jsonData,
                        currentServiceData: currentServiceData),
                    const SizedBox(height: 10.0),
                    ParkingStats(
                      currentServiceID: currentServiceID,
                    ),
                    const SizedBox(height: 10.0),
                    TeamList(userData: jsonData, serviceID: currentServiceID),
                    const SizedBox(height: 80.0),
                  ],
                );
              } else {
                Future.delayed(Duration.zero, () {
                  Navigator.pushNamed(context, '/login');
                });
                // Return an empty container while redirecting
                return Container();
              }
            }),
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

class TeamList extends StatefulWidget {
  final Map<String, dynamic> userData;
  final int? serviceID;
  const TeamList({super.key, required this.userData, required this.serviceID});

  @override
  State<TeamList> createState() => _TeamListState();
}

class _TeamListState extends State<TeamList> {
  late Future departmentList;

  @override
  void initState() {
    super.initState();
    departmentList = listDepartmentTeamRequest(widget.userData["DepartmentID"]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: 2.0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Team Members",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                  ),
                ),
                // TextButton(
                //   onPressed: () {},
                //   child: const Text(
                //     "View All",
                //     style: TextStyle(
                //       fontWeight: FontWeight.w500,
                //       fontSize: 12.0,
                //       color: Colors.black87,
                //     ),
                //   ),
                // )
              ],
            ),
          ),
          const SizedBox(height: 5.0),
          FutureBuilder(
              future: departmentList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  Future.delayed(Duration.zero, () {
                    Navigator.pushNamed(context, '/login');
                  });
                  // Return an empty container while redirecting
                  return Container();
                } else if (snapshot.hasData) {
                  var jsonData = json.decode(snapshot.data!.body);
                  var groups = jsonData["results"] as List;

                  List<DataRow> team = groups
                      .map((g) => DataRow(cells: [
                            DataCell(Text(g["Codename"])),
                            DataCell(
                              FutureBuilder(
                                future: getTeamMemberServiceAllocation(
                                    g["ID"], widget.serviceID),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Container();
                                  } else if (snapshot.hasData) {
                                    final statusCode =
                                        snapshot.data!.statusCode;
                                    if (statusCode >= 400 && statusCode < 500) {
                                      return Container(); // Return an empty container while redirecting
                                    }
                                    var jsonData =
                                        json.decode(snapshot.data!.body);
                                    if (jsonData["Name"] == null) {
                                      return Text(
                                        "Not Deployed",
                                        style: GoogleFonts.lato(
                                          textStyle: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      );
                                    }

                                    return Text(
                                      jsonData["Name"],
                                      style: GoogleFonts.lato(
                                        textStyle: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ),
                            // get allocation
                            DataCell(Text(g["PhoneNumber"])),
                          ]))
                      .toList();

                  return DataTable(
                    border: TableBorder.all(color: Colors.grey.shade200),
                    columns: const [
                      DataColumn(label: Text("Code Name")),
                      DataColumn(label: Text("Allocation")),
                      DataColumn(label: Text("Tel No.")),
                    ],
                    rows: team,
                  );
                } else {
                  Future.delayed(Duration.zero, () {
                    Navigator.pushNamed(context, '/login');
                  });
                  // Return an empty container while redirecting
                  return Container();
                }
              }),
        ],
      ),
    );
  }
}

class ParkingStats extends StatefulWidget {
  final int? currentServiceID;
  const ParkingStats({super.key, required this.currentServiceID});

  @override
  State<ParkingStats> createState() => _ParkingStatsState();
}

class _ParkingStatsState extends State<ParkingStats> {
  late Future currentServiceParkingStats;

  @override
  void initState() {
    super.initState();
    currentServiceParkingStats =
        currentServiceParkingStatsRequest(widget.currentServiceID!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: 2.0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Parking Statistics",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                  ),
                ),
                // TextButton(
                //   onPressed: () {},
                //   child: const Text(
                //     "View All",
                //     style: TextStyle(
                //       fontWeight: FontWeight.w500,
                //       fontSize: 12.0,
                //       color: Colors.black87,
                //     ),
                //   ),
                // )
              ],
            ),
          ),
          const SizedBox(height: 5.0),
          FutureBuilder(
            future: currentServiceParkingStats,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                Future.delayed(Duration.zero, () {
                  Navigator.pushNamed(context, '/login');
                });
                // Return an empty container while redirecting
                return Container();
              } else if (snapshot.hasData) {
                var jsonData = json.decode(snapshot.data!.body);
                if (jsonData["results"] == null ||
                    jsonData["results"] == Null) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text("No Vehicles registered yet for current Service.")
                    ],
                  );
                }
                var groups = jsonData["results"] as List;

                List<DataRow> groupings = groups
                    .map((g) => DataRow(cells: [
                          DataCell(Text(g["Codename"])),
                          DataCell(Text(g["Name"])),
                          DataCell(Text(g["Count"].toString())),
                        ]))
                    .toList();

                return DataTable(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columns: const [
                    DataColumn(label: Text("Parking")),
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Count")),
                  ],
                  rows: groupings,
                );
              } else {
                Future.delayed(Duration.zero, () {
                  Navigator.pushNamed(context, '/login');
                });
                // Return an empty container while redirecting
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}

class PersonnalDetails extends StatefulWidget {
  final Map<String, dynamic>? currentServiceData;
  final Map<String, dynamic> userData;

  const PersonnalDetails(
      {super.key, required this.userData, required this.currentServiceData});

  @override
  State<PersonnalDetails> createState() => _PersonnalDetailsState();
}

class _PersonnalDetailsState extends State<PersonnalDetails> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: const Color.fromARGB(197, 203, 237, 250),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Column(
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
                Text(
                  'Welcome to ${widget.currentServiceData!["Name"]}',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 2.5),
                Row(
                  children: [
                    Text(
                      "Deployed at ",
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    FutureBuilder(
                      future: getTeamMemberServiceAllocation(
                          widget.userData["ID"],
                          widget.currentServiceData!["ID"]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Container();
                        } else if (snapshot.hasData) {
                          final statusCode = snapshot.data!.statusCode;
                          if (statusCode >= 400 && statusCode < 500) {
                            return Container(); // Return an empty container while redirecting
                          }
                          var jsonData = json.decode(snapshot.data!.body);
                          if (jsonData["Name"] == null) {
                            return Text(
                              "Not Deployed",
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }

                          return Text(
                            jsonData["Name"],
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TopPageActions extends StatelessWidget {
  const TopPageActions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.mic),
          color: Colors.white,
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.black54)),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.record_voice_over),
          color: Colors.white,
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.black)),
          constraints: const BoxConstraints(
            minHeight: 100.0,
            minWidth: 100.0,
            maxHeight: 200.0,
            maxWidth: 200.0,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.volume_up_sharp),
          color: Colors.white,
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.black54)),
        ),
      ],
    );
  }
}
