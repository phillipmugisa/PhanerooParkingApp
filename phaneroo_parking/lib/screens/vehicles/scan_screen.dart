import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanCarScreen extends StatefulWidget {
  const ScanCarScreen({super.key});

  @override
  State<ScanCarScreen> createState() => _ScanCarScreenState();
}

class _ScanCarScreenState extends State<ScanCarScreen> {
  @override
  Widget build(BuildContext context) {
    int currentScreenIndex = 2;
    int licenseNoLength = 8;
    final RegExp pattern = RegExp(r'^[A-Z]{3}\s\d{3}[A-Z]$');

    String licenseNo = "";
    TextEditingController textController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
          children: [
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
                child: Text(
                  "Start camera by clicking on camera button below.",
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: Colors.grey.shade50,
                      fontSize: 18.0,
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
                      setState(() {
                        licenseNo = textController.text;
                      });

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
                        Navigator.pushNamed(context, "/driver_details",
                            arguments: licenseNo);
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
