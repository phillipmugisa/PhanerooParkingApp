import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:phaneroo_parking/requests.dart';

class ScanCarScreen extends StatefulWidget {
  const ScanCarScreen({super.key});

  @override
  State<ScanCarScreen> createState() => _ScanCarScreenState();
}

class _ScanCarScreenState extends State<ScanCarScreen> {
  int currentScreenIndex = 2;
  int licenseNoLength = 8;
  int? currentServiceId;
  int? parkingId;
  final RegExp pattern = RegExp(r'^[A-Z]{3}\s\d{3}[A-Z]$');

  String licenseNo = "";

  String? parkingValue;
  late Future parkingList;

  @override
  void initState() {
    super.initState();
    parkingList = listParkings();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();

    // fetch parking session id
    getCurrentService().then((response) {
      var jsonData = json.decode(response.body);
      currentServiceId = jsonData["results"][0]["ID"];
    }).catchError((err) {});

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
          children: [
            Row(
              children: [
                Text(
                  "Select Parking: ",
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                FutureBuilder(
                  future: parkingList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      var jsonData = json.decode(snapshot.data!.body);
                      var parkings = jsonData["results"] as List;

                      // serviceValue = parkings[0]["Name"].toString();
                      List<DropdownMenuItem> widgetList = parkings
                          .map(
                            (s) => DropdownMenuItem(
                              value: s["Codename"],
                              child: Text(s["Codename"]),
                            ),
                          )
                          .toList();

                      return Expanded(
                        child: DropdownButton(
                          value: parkingValue,
                          onChanged: (value) {
                            // get parking
                            var parking = parkings
                                .where((p) => p["Codename"] == value)
                                .toList();

                            parkingId = parking[0]["ID"];
                            setState(() {
                              parkingValue = parking[0]["Codename"];
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
                          items: widgetList,
                        ),
                      );
                    } else {
                      return const Text('Try Again');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Container(
              constraints: const BoxConstraints(minHeight: 300.0),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1.0,
                  color: Colors.black26,
                ),
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey.shade800,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "Start camera by clicking on camera button below.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        color: Colors.grey.shade50,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              padding: const EdgeInsets.all(2.5),
              child: TextFormField(
                controller: textController,
                maxLines: 1,
                maxLength: licenseNoLength,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  label: Text(
                    "License Number (e.g. USH 234A)",
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter license number';
                  }
                  if (value.length < licenseNoLength - 1) {
                    return 'Incomplete license number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.all(2.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.redo_rounded),
                    color: Colors.white,
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black)),
                    constraints: const BoxConstraints(
                      minHeight: 50.0,
                      minWidth: 50.0,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      licenseNo = textController.text;

                      if (licenseNo.length < licenseNoLength - 1 ||
                          !pattern.hasMatch(licenseNo)) {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'Invalid license number (e.g. UAA 001A)'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'OK'),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        Map<String, dynamic> data = {
                          'licenseNo': licenseNo,
                          "id": null,
                          "currentServiceId": currentServiceId,
                          "parkingId": parkingId,
                        };
                        Navigator.pushNamed(context, "/driver_details",
                            arguments: data);
                      }

                      return;
                    },
                    icon: const Icon(
                      Icons.done,
                      size: 50.0,
                    ),
                    color: Colors.white,
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black)),
                    constraints: const BoxConstraints(
                      minHeight: 80.0,
                      minWidth: 80.0,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_outlined),
                    color: Colors.white,
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black)),
                    constraints: const BoxConstraints(
                      minHeight: 50.0,
                      minWidth: 50.0,
                    ),
                  ),
                ],
              ),
            )
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
