import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:phaneroo_parking/requests.dart';

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
      setState(() {
        currentServiceID = jsonData["ID"];
        currentServiceData = jsonData;
      });
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
        appBar: AppBar(
          // Changed AppBar colors to green theme
          backgroundColor: Colors.black,
          elevation: 1,
          title: const Row(
            children: [
              Icon(
                Icons.local_parking,
                color: Colors.white, // Changed to white for contrast
                size: 20,
              ),
              SizedBox(width: 5),
              Text(
                "ParkMaster",
                style: TextStyle(
                  color: Colors.white, // Changed to white for contrast
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/account");
              },
              child: CircleAvatar(
                backgroundColor: const Color.fromRGBO(
                    242, 248, 252, 1), // Changed background color
                child: Icon(
                  Icons.person,
                  size: 18.0,
                  color: Colors.orange.shade700, // Changed to orange
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                logoutRequest().then((response) {
                  if (response.statusCode >= 400) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Operation not successful'),
                      ),
                    );
                    return;
                  }
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.remove("access_token");
                    prefs.remove("refresh_token");
                  });

                  Navigator.popAndPushNamed(context, "/login");
                }).catchError((err) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No Internet connection'),
                    ),
                  );
                });
              },
              icon: const Icon(Icons.logout,
                  color: Colors.white), // Changed to white
            ),
            const SizedBox(width: 10),
          ],
        ),
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
                return Container();
              } else if (snapshot.hasData) {
                final statusCode = snapshot.data!.statusCode;
                if (statusCode >= 400 && statusCode < 500) {
                  Future.delayed(Duration.zero, () {
                    Navigator.pushNamed(context, '/login');
                  });
                  return Container();
                }
                var jsonData = json.decode(snapshot.data!.body);
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setInt("userID", jsonData["ID"]);
                  prefs.setInt("departmentId", jsonData["DepartmentID"]);
                  prefs.setInt(
                      "currentServiceID", jsonData["currentServiceID"]);
                });
                return ListView(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                  children: [
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
            }
          },
          destinations: [
            NavigationDestination(
              icon:
                  Icon(Icons.home, color: Colors.green.shade700), // Green icons
              label: "Home",
            ),
            NavigationDestination(
              icon:
                  Icon(Icons.list, color: Colors.green.shade700), // Green icons
              label: "Records",
            ),
            NavigationDestination(
              icon:
                  Icon(Icons.book, color: Colors.green.shade700), // Green icons
              label: "Register",
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
  bool isExpanded = true;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    departmentList = listDepartmentTeamRequest(widget.userData["DepartmentID"]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 12.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10.0),
                  topRight: const Radius.circular(10.0),
                  bottomLeft: Radius.circular(isExpanded ? 0 : 10.0),
                  bottomRight: Radius.circular(isExpanded ? 0 : 10.0),
                ),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Team Members",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            FutureBuilder(
                future: departmentList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                      ),
                      child: const Text("Error loading team members"),
                    );
                  } else if (snapshot.hasData) {
                    var jsonData = json.decode(snapshot.data!.body);
                    var groups = jsonData["results"] as List;

                    // Calculate the total number of pages
                    _totalPages = (groups.length / 5).ceil();

                    if (groups.isEmpty) {
                      return const Center(child: Text("No team members found"));
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),
                        ),
                        child: Column(
                          children: [
                            // PageView to enable swiping
                            SizedBox(
                              height: 300, // Adjust this height as needed
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (int page) {
                                  setState(() {
                                    _currentPage = page;
                                  });
                                },
                                itemCount: _totalPages,
                                itemBuilder: (context, pageIndex) {
                                  // Calculate start and end indices for current page
                                  int startIndex = pageIndex * 4;
                                  int endIndex = startIndex + 4 > groups.length
                                      ? groups.length
                                      : startIndex + 4;
                                  // Get subset of team members for this page
                                  var pageMembers =
                                      groups.sublist(startIndex, endIndex);

                                  return Column(
                                    children: pageMembers.map((g) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            g["Codename"],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          subtitle: Text(
                                              "Phone: ${g["PhoneNumber"]}"),
                                          trailing: FutureBuilder(
                                            future:
                                                getTeamMemberServiceAllocation(
                                                    g["ID"], widget.serviceID),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                  ),
                                                );
                                              } else if (snapshot.hasError) {
                                                return const Text(
                                                  "Error",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                );
                                              } else if (snapshot.hasData) {
                                                var jsonData = json.decode(
                                                    snapshot.data!.body);
                                                final deployment =
                                                    jsonData["Name"];
                                                return Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 4.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: deployment != null
                                                        ? Colors.green.shade100
                                                        : Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    border: Border.all(
                                                      color: deployment != null
                                                          ? Colors
                                                              .green.shade300
                                                          : Colors
                                                              .grey.shade400,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    deployment ??
                                                        "Not Deployed",
                                                    style: TextStyle(
                                                      color: deployment != null
                                                          ? Colors
                                                              .green.shade800
                                                          : Colors
                                                              .grey.shade700,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12.0,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return const Text("No Data");
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),

                            // Page indicator and navigation
                            if (_totalPages > 1)
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Previous page button
                                    IconButton(
                                      onPressed: _currentPage > 0
                                          ? () {
                                              _pageController.previousPage(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          : null,
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        color: _currentPage > 0
                                            ? Colors.green.shade700
                                            : Colors.grey.shade400,
                                      ),
                                    ),

                                    // Page indicator text
                                    Text(
                                      "Page ${_currentPage + 1} of $_totalPages",
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    // Next page button
                                    IconButton(
                                      onPressed: _currentPage < _totalPages - 1
                                          ? () {
                                              _pageController.nextPage(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          : null,
                                      icon: Icon(
                                        Icons.arrow_forward_ios,
                                        color: _currentPage < _totalPages - 1
                                            ? Colors.green.shade700
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                  } else {
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
  int totalVehicles = 0;

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
              vertical: 12.0,
              horizontal: 12.0,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              border: Border.all(color: Colors.grey.shade300),
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
              ],
            ),
          ),
          FutureBuilder(
            future: currentServiceParkingStats,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                  ),
                  child: const CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                  ),
                  child: const Text("Error loading parking statistics"),
                );
              } else if (snapshot.hasData) {
                var jsonData = json.decode(snapshot.data!.body);
                var stats = jsonData["results"] as List;

                // Calculate total vehicles
                totalVehicles =
                    stats.fold(0, (sum, item) => sum + (item["Count"] as int));

                // Create color map by category
                Map<String, Color> colorMap = {
                  "Cars": Colors.blue,
                  "Motorcycles": Colors.orange,
                  "Bicycles": Colors.green,
                  "Trucks": Colors.purple,
                  "Buses": Colors.red,
                  "Others": Colors.teal,
                };

                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Total vehicles count
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Text(
                              totalVehicles.toString(),
                              style: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            const Text(
                              "Total Vehicles",
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Progress indicators for each category
                      ...stats.map((stat) {
                        final percentage = totalVehicles > 0
                            ? (stat["Count"] as int) / totalVehicles
                            : 0.0;
                        final categoryName = stat["Name"] as String;
                        final defaultColor = Colors.grey;
                        final color = colorMap[categoryName] ?? defaultColor;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    categoryName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "${stat["Count"]} (${(percentage * 100).toStringAsFixed(1)}%)",
                                    style: TextStyle(
                                      color: color.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: LinearProgressIndicator(
                                  value: percentage,
                                  backgroundColor: color.withOpacity(0.2),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                  minHeight: 6.0,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
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
                  widget.currentServiceData != null
                      ? 'Welcome to ${widget.currentServiceData!["Name"]}'
                      : 'Welcome',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
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
                    widget.currentServiceData != null
                        ? FutureBuilder(
                            future: getTeamMemberServiceAllocation(
                                widget.userData["ID"],
                                widget.currentServiceData!["ID"]),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Container();
                              } else if (snapshot.hasData) {
                                var jsonData = json.decode(snapshot.data!.body);
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: jsonData["Name"] != null
                                        ? Colors.green.shade50
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: jsonData["Name"] != null
                                          ? Colors.green.shade300
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Text(
                                    jsonData["Name"] ?? "Not Deployed",
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: jsonData["Name"] != null
                                            ? Colors.green.shade800
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return const Text("Not Deployed");
                              }
                            },
                          )
                        : const Text(
                            "Not Available",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
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
