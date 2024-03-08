import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    int currentScreenIndex = 2;

    // text fields
    TextEditingController licenseNoController = TextEditingController();

    TextEditingController carModelController = TextEditingController();
    TextEditingController checkInTimeController = TextEditingController();
    TextEditingController checkOutTimeController = TextEditingController();

    TextEditingController driverNameController = TextEditingController();
    TextEditingController driverTelNoController = TextEditingController();
    TextEditingController driverEmailController = TextEditingController();

    TextEditingController securityNotesController = TextEditingController();

    final String? licenseNo =
        ModalRoute.of(context)?.settings.arguments as String?;

    if (licenseNo != null) {
      licenseNoController.text = licenseNo;

      // fetch Vehicle Data
    }

    // we identify cars by license numbers

    void checkoutVehicle(licenseNo) {}

    Future<http.Response> saveVehicle() async {
      return await http.post(
        Uri.parse('http://parking.mugisa.tech'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'licenseNo': licenseNoController.text,
          'carModel': carModelController.text,
          'checkInTime': checkInTimeController.text,
          'checkOutTime': checkOutTimeController.text,
          'driverName': driverNameController.text,
          'driverTelNo': driverTelNoController.text,
          'driverEmail': driverEmailController.text,
          'securityNote': securityNotesController.text,
        }),
      );
    }

    void contactDriver(licenseNo) {}

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
          child: ListView(
            children: [
              Container(
                color: Colors.grey.shade50,
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Vehicle Details",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: licenseNoController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: Text(
                          "License Number",
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: carModelController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: Text(
                          "Car Model",
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // DateInputElement(),
                    TextFormField(
                      controller: checkInTimeController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: Text(
                          "Check In Time",
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: checkOutTimeController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: Text(
                          "Check Out Time",
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                color: Colors.grey.shade50,
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Driver Details",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: driverNameController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: Text(
                          "Driver's Name",
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: driverTelNoController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: Text(
                          "Driver's Tel No",
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: driverEmailController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: Text(
                          "Driver's Email",
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                color: Colors.grey.shade50,
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Security Purposes Only",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: securityNotesController,
                      minLines: 4,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Security Notes"),
                      ),
                    ),

                    const SizedBox(height: 15.0),
                    // actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 50.0),
                          child: ElevatedButton(
                            onPressed: () => contactDriver(licenseNo),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black54),
                            ),
                            child: const Text(
                              "Contact",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 50.0),
                          child: ElevatedButton(
                            onPressed: () => checkoutVehicle(licenseNo),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black54),
                            ),
                            child: const Text(
                              "Checkout",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 50.0),
                          child: ElevatedButton(
                            onPressed: () {
                              saveVehicle()
                                  .then((response) => {
                                        if (response.statusCode > 399)
                                          {throw Error()}
                                      })
                                  .catchError((e) => {});
                              // Navigator.popAndPushNamed(context, "/scan");
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.green),
                            ),
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 80.0),
            ],
          ),
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
