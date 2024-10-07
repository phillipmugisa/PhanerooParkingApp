import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  @override
  Widget build(BuildContext context) {
    int currentScreenIndex = 3;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: const [
              IntroCard(),
              SizedBox(height: 20.0),
              CreateService(),
              SizedBox(height: 20.0),
              CreateParkingCard(),
              SizedBox(height: 10.0),
              ServicesList(),
            ],
          ),
        ),
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
                Navigator.pushNamed(context, "/leaderboard");
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
              label: "Reocrds",
            ),
            NavigationDestination(
              icon: Icon(Icons.book),
              label: "Services",
            ),
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

class CreateParkingCard extends StatelessWidget {
  const CreateParkingCard({
    super.key,
  });

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
                  onTap: () {},
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
                      weight: 100.0,
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

class IntroCard extends StatelessWidget {
  const IntroCard({
    super.key,
  });

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
                  'Hello Codename',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 2.5),
                Text(
                  'Welcome to Phaneroo 700',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

class ServicesList extends StatelessWidget {
  const ServicesList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    // border: ,
                    prefixIcon: Icon(Icons.search),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter valid entry.';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15.0),
          DataTable(
            border: TableBorder.all(color: Colors.grey.shade200),
            columns: const [
              DataColumn(
                label: Text(
                  "Service",
                ),
              ),
              DataColumn(
                label: Text(
                  "Cars",
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  "Bikes",
                ),
                numeric: true,
              ),
            ],
            rows: <DataRow>[
              DataRow(
                cells: <DataCell>[
                  DataCell(
                    GestureDetector(
                      onTap: () {
                        Map<String, dynamic> data = {"id": 1};
                        Navigator.pushNamed(context, "/service",
                            arguments: data);
                      },
                      child: Text(
                        "Phaneroo 555",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const DataCell(Text('19')),
                  const DataCell(Text('19')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(
                    GestureDetector(
                      onTap: () {
                        Map<String, dynamic> data = {"id": 1};
                        Navigator.pushNamed(context, "/service",
                            arguments: data);
                      },
                      child: Text(
                        "Phaneroo 555",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const DataCell(Text('19')),
                  const DataCell(Text('19')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(
                    GestureDetector(
                      onTap: () {
                        Map<String, dynamic> data = {"id": 1};
                        Navigator.pushNamed(context, "/service",
                            arguments: data);
                      },
                      child: Text(
                        "Phaneroo 555",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const DataCell(Text('19')),
                  const DataCell(Text('19')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(
                    GestureDetector(
                      onTap: () {
                        Map<String, dynamic> data = {"id": 1};
                        Navigator.pushNamed(context, "/service",
                            arguments: data);
                      },
                      child: Text(
                        "Phaneroo 555",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const DataCell(Text('19')),
                  const DataCell(Text('19')),
                ],
              ),
            ],
          ),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isDeploymentChecked,
                      onChanged: _deploymentCheckboxChanged,
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                    ),
                    GestureDetector(
                      onTap: () {
                        _deploymentCheckboxChanged(
                            _isDeploymentChecked == true ? false : true);
                      },
                      child: Text(
                        "Deployment same as previous.",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () {
                    Map<String, dynamic> data = {"id": 1};
                    Navigator.pushNamed(context, "/service", arguments: data);
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
                          weight: 100.0,
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
