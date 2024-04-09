import 'package:flutter/material.dart';
import 'package:phaneroo_parking/requests.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future userData;

  @override
  void initState() {
    super.initState();
    userData = getCurrentUserRequest();
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
                return ListView(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                  children: [
                    // TopPageActions(),
                    // SizedBox(height: 10.0),
                    // current user information
                    PersonnalDetails(userData: jsonData),
                    const SizedBox(height: 10.0),
                    const ParkingStats(),
                    const SizedBox(height: 10.0),
                    const TeamList(),
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

class TeamList extends StatelessWidget {
  const TeamList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 2.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: 2.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "On-site team",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.0,
                      color: Colors.black87,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 5.0),
          DataTable(
            border: TableBorder.all(color: Colors.grey.shade200),
            columns: const [
              DataColumn(label: Text("Code Name")),
              DataColumn(label: Text("Allocation")),
              DataColumn(label: Text("chat")),
            ],
            rows: [
              DataRow(cells: [
                const DataCell(Text("BMW")),
                const DataCell(Text("Truck")),
                DataCell(TextButton(
                  onPressed: () {},
                  child: const Icon(Icons.message),
                )),
              ]),
              DataRow(cells: [
                const DataCell(Text("Kia")),
                const DataCell(Text("Truck")),
                DataCell(TextButton(
                  onPressed: () {},
                  child: const Icon(Icons.message),
                )),
              ]),
              DataRow(cells: [
                const DataCell(Text("Genesis")),
                const DataCell(Text("Truck")),
                DataCell(TextButton(
                  onPressed: () {},
                  child: const Icon(Icons.message),
                )),
              ]),
              DataRow(cells: [
                const DataCell(Text("Vision")),
                const DataCell(Text("Lakeside")),
                DataCell(TextButton(
                  onPressed: () {},
                  child: const Icon(Icons.message),
                )),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

class ParkingStats extends StatelessWidget {
  const ParkingStats({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 2.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: 2.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Parking Statistics",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.0,
                      color: Colors.black87,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 5.0),
          DataTable(
              border: TableBorder.all(color: Colors.grey.shade300),
              columns: const [
                DataColumn(label: Text("Parking")),
                DataColumn(label: Text("Count")),
                DataColumn(label: Text("Date")),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text("Truck")),
                  DataCell(Text("200")),
                  DataCell(Text("01/03/2024")),
                ]),
                DataRow(cells: [
                  DataCell(Text("Lakeside")),
                  DataCell(Text("300")),
                  DataCell(Text("01/03/2024")),
                ]),
                DataRow(cells: [
                  DataCell(Text("Heaven")),
                  DataCell(Text("500")),
                  DataCell(Text("01/03/2024")),
                ]),
              ])
        ],
      ),
    );
  }
}

class PersonnalDetails extends StatelessWidget {
  final Map<String, dynamic> userData;

  const PersonnalDetails({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.9),
      child: Wrap(
        direction: Axis.horizontal,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: 2.0,
            ),
            child: const Text(
              "Personal Information",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15.0,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Column(
            children: [
              Row(
                children: [
                  const Text(
                    "Code Name: ",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    userData["Codename"],
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 8, 8, 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
              Row(
                children: [
                  const Text(
                    "Department: ",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    userData["Name"],
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 8, 8, 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
              Row(
                children: [
                  const Text(
                    "Allocation: ",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2.5),
                  Text(
                    userData["Name"],
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 8, 8, 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.black54)),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.record_voice_over),
          color: Colors.white,
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black)),
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
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.black54)),
        ),
      ],
    );
  }
}
