import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phaneroo_parking/requests.dart';
import 'dart:convert';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int currentScreenIndex = 2;
  int? currentServiceId;
  int? parkingId; // this is based on the allocation
  int? vehicleId;
  bool? isCheckedOut = false;

  // text fields
  TextEditingController licenseNoController = TextEditingController();

  TextEditingController carModelController = TextEditingController();
  TextEditingController checkInTimeController = TextEditingController();
  TextEditingController checkOutTimeController = TextEditingController();

  TextEditingController driverNameController = TextEditingController();
  TextEditingController driverTelNoController = TextEditingController();
  TextEditingController driverEmailController = TextEditingController();

  TextEditingController securityNotesController = TextEditingController();

  void registerVehicle({int? id}) {
    var data = <String, dynamic>{
      'licenseNo': licenseNoController.text,
      'carModel': carModelController.text,
      'driverName': driverNameController.text,
      'driverTelNo': driverTelNoController.text,
      'driverEmail': driverEmailController.text,
      'securityNote': securityNotesController.text,
      'ServiceId': currentServiceId,
      'ParkingId': parkingId
    };
    if (id != null) {
      // update vehicle
      updateVehicle(id, data).then((response) {
        if (response.statusCode > 399) {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Unable to update vehicle detail'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Updated Successfully'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }).catchError((err) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No Internet connection'),
          ),
        );
      });
    } else {
      saveVehicle(data).then((response) {
        // var jsonData = json.decode(response.body);

        if (response.statusCode > 399) {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Unable to register vehicle'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Registered Successfully'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.popAndPushNamed(context, "/scan"),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }).catchError((err) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No Internet connection'),
          ),
        );
      });
    }
  }

  void checkoutVehicle(int id) {
    checkoutVehicleRequest(id).then((response) {
      if (response.statusCode > 399) {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Unable to update vehicle details'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Updated Successfully'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.popAndPushNamed(context, "/records"),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Internet connection'),
        ),
      );
    });
  }

  void contactDriver() {}

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (data != null) {
      if (data["licenseNo"] != null) {
        licenseNoController.text = data["licenseNo"];
      }

      if (data["id"] != null) {
        // fetch vehicle date
        getVehicleData(data["id"]).then((response) {
          var jsonData = json.decode(response.body);
          // fill the fields
          licenseNoController.text = jsonData["LicenseNumber"];
          carModelController.text = jsonData["Model"]["String"];

          checkInTimeController.text = jsonData["CheckInTime"]["Time"];
          if (jsonData["CheckOutTime"]["Valid"]) {
            checkOutTimeController.text = jsonData["CheckOutTime"]["Time"];
          }
          securityNotesController.text = jsonData["SecurityNotes"]["String"];

          driverNameController.text = jsonData["Fullname"];
          driverTelNoController.text = jsonData["PhoneNumber"];
          driverEmailController.text = jsonData["Email"];
        }).catchError((err) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No Internet connection'),
            ),
          );
        });
      }

      if (data["currentServiceId"] != null) {
        currentServiceId = data["currentServiceId"];
      }
      if (data["parkingId"] != null) {
        parkingId = data["parkingId"];
      }
    }

    return SafeArea(
      child: Scaffold(
        body: data == null
            ? const Center(
                child: Text("Invalid Access"),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
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
                            enabled: false,
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
                            enabled: false,
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
                                constraints:
                                    const BoxConstraints(minHeight: 50.0),
                                child: ElevatedButton(
                                  onPressed: () => contactDriver(),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
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
                              data["id"] != null
                                  ? ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(minHeight: 50.0),
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            checkoutVehicle(data["id"]),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.black54),
                                        ),
                                        child: const Text(
                                          "Checkout",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(width: 0.0),
                              const SizedBox(width: 10.0),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minHeight: 50.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (data['id'].runtimeType == int) {
                                      registerVehicle(id: data['id']);
                                    } else {
                                      registerVehicle();
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
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
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {},
        //   child: const Icon(
        //     Icons.record_voice_over,
        //   ),
        // ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.black,
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
