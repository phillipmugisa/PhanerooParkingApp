import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String serviceValue = "phaneroo_500";
  String stationValue = "truck";
  int vehicleCount = 500;

  @override
  Widget build(BuildContext context) {
    int currentScreenIndex = 1;
    TextEditingController searchController = TextEditingController();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 0),
          children: [
            TextFormField(
              controller: searchController,
              maxLines: 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                label: Text(
                  "Search for Vehicle or Driver Details",
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            SizedBox(
              height: 100.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Select Service: ",
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          DropdownButton(
                            value: serviceValue,
                            onChanged: (String? value) {
                              // This is called when the user selects an item.
                              setState(() {
                                serviceValue = value!;
                              });
                            },
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                            elevation: 16,
                            iconEnabledColor: Colors.black,
                            dropdownColor: Colors.white,
                            underline: Container(),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: "phaneroo_500",
                                child: Text("Phaneroo 500"),
                              ),
                              DropdownMenuItem(
                                value: "phaneroo_501",
                                child: Text("Phaneroo 501"),
                              ),
                              DropdownMenuItem(
                                value: "phaneroo_502",
                                child: Text("Phaneroo 502"),
                              ),
                              DropdownMenuItem(
                                value: "phaneroo_503",
                                child: Text("Phaneroo 503"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Select Station: ",
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          DropdownButton(
                            value: stationValue,
                            onChanged: (String? value) {
                              // This is called when the user selects an item.
                              setState(() {
                                stationValue = value!;
                              });
                            },
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                            elevation: 16,
                            iconEnabledColor: Colors.black,
                            dropdownColor: Colors.white,
                            underline: Container(),
                            // isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: "truck",
                                child: Text("Truck"),
                              ),
                              DropdownMenuItem(
                                value: "heaven",
                                child: Text("Heaven"),
                              ),
                              DropdownMenuItem(
                                value: "lakeside",
                                child: Text("Lakeside"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 34.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                            const SizedBox(height: 15.0),
                            Text(
                              "$vehicleCount",
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            DataTable(
              border: TableBorder.all(color: Colors.grey.shade200),
              columns: const [
                DataColumn(label: Text("License No")),
                DataColumn(label: Text("Driver")),
                DataColumn(label: Text("Checkout")),
              ],
              rows: [
                DataRow(
                  cells: const [
                    DataCell(Text("UAX 234H")),
                    DataCell(Text("Phillip Mugisa")),
                    DataCell(Text("20:30")),
                  ],
                  onSelectChanged: (isSelected) {
                    if (isSelected != null && isSelected) {
                      Navigator.pushNamed(context, "/driver_details",
                          arguments: "UAX 234H");
                    }
                  },
                ),
                DataRow(
                  cells: const [
                    DataCell(Text("UAX 234H")),
                    DataCell(Text("Mukwano Mark")),
                    DataCell(Text("Still In")),
                  ],
                  onSelectChanged: (isSelected) {
                    if (isSelected != null && isSelected) {
                      Navigator.pushNamed(context, "/driver_details",
                          arguments: "UAX 234H");
                    }
                  },
                ),
                DataRow(
                  cells: const [
                    DataCell(Text("UAX 234H")),
                    DataCell(Text("Alex Okello")),
                    DataCell(Text("Still In")),
                  ],
                  onSelectChanged: (isSelected) {
                    if (isSelected != null && isSelected) {
                      Navigator.pushNamed(context, "/driver_details",
                          arguments: "UAX 234H");
                    }
                  },
                ),
                DataRow(
                  cells: const [
                    DataCell(Text("UBH 444K")),
                    DataCell(Text("Barbra Ayo")),
                    DataCell(Text("20:20")),
                  ],
                  onSelectChanged: (isSelected) {
                    if (isSelected != null && isSelected) {
                      Navigator.pushNamed(context, "/driver_details",
                          arguments: "UBH 444K");
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(
            Icons.record_voice_over,
          ),
        ),
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
