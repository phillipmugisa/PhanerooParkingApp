import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:phaneroo_parking/requests.dart';

class ScanCarScreen extends StatefulWidget {
  const ScanCarScreen({super.key});

  @override
  State<ScanCarScreen> createState() => _ScanCarScreenState();
}

class _ScanCarScreenState extends State<ScanCarScreen> {
  final RegExp pattern = RegExp(r'^[A-Z]{3}\s\d{3}[A-Z]$');
  int licenseNoLength = 8;
  int currentScreenIndex = 3;

  int? currentServiceId;
  int? parkingId;
  int? vehicleId;
  String licenseNo = "";
  bool isCheckedout = true;

  String? parkingValue;
  late Future parkingList;
  late Future servicesData;

  TextEditingController licenseNoController = TextEditingController();
  final TextEditingController servicesController = TextEditingController();
  final TextEditingController parkingController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController telNumberController = TextEditingController();

  void populateFields(String value) {
    final Future response = searchVehicles(value);

    // to cater from camera
    setState(() {
      licenseNoController.text = value;
    });

    response.then((data) {
      var jsonData = json.decode(data!.body);

      if (jsonData["count"] < 1) return;

      var record = jsonData["results"][0];
      setState(() {
        driverNameController.text = record["Fullname"].toString();
        telNumberController.text = record["PhoneNumber"].toString();

        // is the vehicle in the parking
        if (record["IsCheckedOut"]["Bool"] != true) {
          isCheckedout = false;
          vehicleId = record["ID"];
        }
      });
    }).catchError(() {});
  }

  void checkoutVehicle() {
    if (vehicleId == null) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Incomplete operation. Rescan/reenter vehicle'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    checkoutVehicleRequest(vehicleId!).then((response) {
      if (response.statusCode > 399) {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Unable to checkout vehicle'),
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
          content: Text('Connection Difficulty'),
        ),
      );
    });
  }

  void registerVehicle() {
    var data = <String, dynamic>{
      'licenseNo': licenseNoController.text,
      'driverName': driverNameController.text,
      'driverTelNo': telNumberController.text,
      'ServiceId': currentServiceId,
      'ParkingId': parkingId
    };
    if (currentServiceId == null || parkingId == null) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Provide required details'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

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
          content: Text('Connection Difficulty'),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    parkingList = listParkings();
    servicesData = listServices();

    getCurrentService().then((response) {
      var jsonData = json.decode(response.body);
      currentServiceId = jsonData["ID"];
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
          children: [
            CameraView(populateFields: populateFields),
            const SizedBox(height: 20.0),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder(
                  future: servicesData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      var jsonData = json.decode(snapshot.data!.body);
                      var services = jsonData["results"] as List;

                      return DropdownMenu(
                        initialSelection: currentServiceId,
                        controller: servicesController,
                        requestFocusOnTap: true,
                        label: const Text('Service'),
                        onSelected: (value) {
                          currentServiceId = value["ID"];
                        },
                        dropdownMenuEntries: services
                            .map((v) => DropdownMenuEntry(
                                  value: v,
                                  label: v["Name"],
                                ))
                            .toList(),
                      );
                    } else {
                      return const Text('Try Again');
                    }
                  },
                ),
                const SizedBox(width: 10),
                FutureBuilder(
                  future: parkingList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      var jsonData = json.decode(snapshot.data!.body);
                      var parkings = jsonData["results"] as List;

                      return DropdownMenu(
                        initialSelection: parkings[0]["Codename"],
                        controller: parkingController,
                        requestFocusOnTap: true,
                        label: const Text('Parking'),
                        onSelected: (value) {
                          parkingId = value["ID"];
                        },
                        dropdownMenuEntries: parkings
                            .map((v) => DropdownMenuEntry(
                                  value: v,
                                  label: v["Codename"],
                                ))
                            .toList(),
                      );
                    } else {
                      return const Text('Try Again');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            TextFormField(
              controller: licenseNoController,
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
              onChanged: (value) {
                if (value.length == licenseNoLength) {
                  // check for existing records
                  populateFields(value);
                }
              },
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
            const SizedBox(height: 5.0),
            Column(
              children: [
                TextFormField(
                  controller: driverNameController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: Text(
                      "Driver Name",
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ),
                  validator: (value) {},
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: telNumberController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: Text(
                      "Phone Number",
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ),
                  validator: (value) {},
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.all(2.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: const Icon(Icons.redo_rounded),
                  //   color: Colors.white,
                  //   style: ButtonStyle(
                  //       backgroundColor:
                  //           WidgetStateProperty.all<Color>(Colors.black)),
                  //   constraints: const BoxConstraints(
                  //     minHeight: 50.0,
                  //     minWidth: 50.0,
                  //   ),
                  // ),
                  isCheckedout
                      ? ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 50.0),
                          child: ElevatedButton(
                            onPressed: () {
                              licenseNo = licenseNoController.text;

                              if (licenseNo.length < 5) {
                                // if (licenseNo.length < licenseNoLength - 1 ||
                                //     !pattern.hasMatch(licenseNo)) {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text(
                                        'Invalid license number (e.g. UAA 001A)'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'OK'),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                // save data
                                registerVehicle();
                              }

                              return;
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  Colors.black87),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  "Check In",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 20.0),
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        )
                      : ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 50.0),
                          child: ElevatedButton(
                              onPressed: () => checkoutVehicle(),
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    const Color.fromARGB(255, 3, 206, 108)),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    "Check Out",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 20.0),
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  )
                                ],
                              )),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 40.0),
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

class CameraView extends StatefulWidget {
  final Function? populateFields;

  const CameraView({
    super.key,
    required this.populateFields,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  final RegExp pattern = RegExp(r'^[A-Z]{3}\s\d{3}[A-Z]$');
  bool _isPermissionGranted = false;

  late final Future<void> _future;
  CameraController? _cameraController;
  bool isCameraActive = true;
  bool isScanning = false;

  final textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return _isPermissionGranted
            ? Stack(
                children: [
                  FutureBuilder<List<CameraDescription>>(
                    future: availableCameras(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        _initCameraController(snapshot.data!);

                        return CameraPreview(_cameraController!);
                      } else {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: LinearProgressIndicator(),
                          ),
                        );
                      }
                    },
                  ),
                  Positioned(
                    bottom: 15,
                    left: 15,
                    child: IconButton(
                      onPressed: () {
                        if (isCameraActive) {
                          _stopCamera();
                        } else {
                          _startCamera();
                        }
                        isCameraActive = !isCameraActive;
                      },
                      icon: const Icon(Icons.camera_alt_rounded),
                      color: Colors.white,
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.blueAccent)),
                      constraints: const BoxConstraints(
                        minHeight: 50.0,
                        minWidth: 50.0,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    right: 15,
                    child: ElevatedButton(
                      onPressed: () async {
                        isScanning = true;
                        String licenceNo = await _scanImage();
                        if (licenceNo.isNotEmpty) {
                          widget.populateFields!(licenceNo.split('\n')[0]);
                        }

                        return;
                      },
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.greenAccent)),
                      child: const Row(
                        children: [
                          Text(
                            "Scan",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Icon(
                            Icons.scanner,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
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
                      'Camera permission denied',
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
              );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<String> _scanImage() async {
    if (_cameraController == null) return "";
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Scanning"),
        ),
      );
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(recognizedText.text),
        ),
      );
      return recognizedText.text;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
      return "";
    }
  }
}
