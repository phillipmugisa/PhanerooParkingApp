import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:phaneroo_parking/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanCarScreen extends StatefulWidget {
  const ScanCarScreen({super.key});

  @override
  State<ScanCarScreen> createState() => _ScanCarScreenState();
}

class _ScanCarScreenState extends State<ScanCarScreen>
    with TickerProviderStateMixin {
  final RegExp pattern = RegExp(r'^[A-Z]{3}\s\d{3}[A-Z]$');
  int licenseNoLength = 8;
  int currentScreenIndex = 2;

  int? currentServiceId;
  int? parkingId;
  int? vehicleId;
  String licenseNo = "";
  bool isCheckedout = true;
  bool is_Search = false;
  int? userID;

  String? parkingValue;
  late Future parkingList;
  late Future servicesData;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  TextEditingController licenseNoController = TextEditingController();
  final TextEditingController servicesController = TextEditingController();
  final TextEditingController parkingController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController telNumberController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController carOccupantsController = TextEditingController();

  String _selectedVehicleType = "CAR";

  @override
  void initState() {
    super.initState();
    parkingList = listParkings();
    servicesData = listServices();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _initializeUserData();
    _getCurrentService();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userID = prefs.getInt("userID");
        parkingId = prefs.getInt("parkingId");
      });
    } catch (e) {
      debugPrint('Error initializing user data: $e');
    }
  }

  Future<void> _getCurrentService() async {
    try {
      final response = await getCurrentService();
      final jsonData = json.decode(response.body);
      setState(() {
        currentServiceId = jsonData["ID"];
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('Connection Difficulty', Colors.red);
      }
    }
  }

  Future<int?> _ensureParkingId() async {
    if (parkingId != null && parkingId != 0) {
      return parkingId;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedParkingId = prefs.getInt("parkingId");

      if (storedParkingId != null && storedParkingId != 0) {
        setState(() {
          parkingId = storedParkingId;
        });
        return storedParkingId;
      }
    } catch (e) {
      debugPrint('Error getting parkingId from SharedPreferences: $e');
    }

    if (userID != null && currentServiceId != null) {
      try {
        final response =
            await getTeamMemberServiceAllocation(userID!, currentServiceId);

        if (response.statusCode <= 399) {
          final jsonData = json.decode(response.body);
          final fetchedParkingId = jsonData["ParkingID"];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt("parkingId", fetchedParkingId);

          setState(() {
            parkingId = fetchedParkingId;
          });

          return fetchedParkingId;
        }
      } catch (e) {
        debugPrint('Error fetching parking allocation: $e');
      }
    }

    return null;
  }

  void populateFields(String value) {
    final Future response = searchVehicles(value);

    setState(() {
      is_Search = true;
    });

    response.then((data) {
      var jsonData = json.decode(data!.body);

      setState(() {
        is_Search = false;
      });

      if (jsonData["count"] < 1) return;

      var record = jsonData["results"][0];
      setState(() {
        licenseNoController.text = record["LicenseNumber"].toString();
        driverNameController.text = record["Fullname"].toString();
        telNumberController.text = record["PhoneNumber"].toString();

        if (record["IsCheckedOut"]["Bool"] != true) {
          isCheckedout = false;
          vehicleId = record["ID"];
        }
      });
    }).catchError(() {});
  }

  void checkoutVehicle() {
    if (vehicleId == null) {
      _showErrorDialog('Incomplete operation. Rescan/reenter vehicle');
      return;
    }

    if (userID == null) {
      Navigator.popAndPushNamed(context, "/");
      return;
    }

    checkoutVehicleRequest(vehicleId!, userID!).then((response) {
      if (response.statusCode > 399) {
        _showErrorDialog('Unable to checkout vehicle');
      } else {
        _showSuccessDialog('Updated Successfully', () {
          Navigator.popAndPushNamed(context, "/scan");
        });
      }
    }).catchError((err) {
      _showSnackBar('Connection Difficulty', Colors.red);
    });
  }

  Future<void> registerVehicle() async {
    if (currentServiceId == null) {
      _showErrorDialog('Provide required details');
      return;
    }

    if (userID == null) {
      Navigator.popAndPushNamed(context, "/");
      return;
    }

    final resolvedParkingId = await _ensureParkingId();

    if (resolvedParkingId == null || resolvedParkingId == 0) {
      _showErrorDialog('Unable to determine parking location');
      return;
    }

    final data = <String, dynamic>{
      'licenseNo': licenseNoController.text,
      'driverName': driverNameController.text,
      'driverTelNo': telNumberController.text,
      'cardNumber': cardNumberController.text.toString(),
      'occupants': carOccupantsController.text.toString(),
      'vehicleType': _selectedVehicleType,
      'ServiceId': currentServiceId,
      'ParkingId': resolvedParkingId,
      'checkedinby': userID
    };

    try {
      final response = await saveVehicle(data);

      if (response.statusCode > 399) {
        _showErrorDialog('Unable to register vehicle');
      } else {
        _showSuccessDialog('Registered Successfully', () {
          Navigator.popAndPushNamed(context, "/scan");
        });
      }
    } catch (err) {
      _showSnackBar('Connection Difficulty', Colors.red);
    }
  }

  void _showErrorDialog(String message) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.error_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message, VoidCallback? onPressed) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.check_circle_outline, color: Colors.green),
            ),
            const SizedBox(width: 12),
            const Text('Success'),
          ],
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: onPressed ?? () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green.withOpacity(0.1),
              foregroundColor: Colors.green,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        validator: validator,
        style: GoogleFonts.inter(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          ),
          labelStyle: GoogleFonts.inter(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          hintStyle: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 100,
                floating: false,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Vehicle Registration',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 16.0,
                    ),
                  ),
                  centerTitle: true,
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle Type Selection
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Vehicle Type',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildVehicleTypeCard(
                                    type: "CAR",
                                    icon: Icons.directions_car,
                                    color: Colors.blue,
                                    isSelected: _selectedVehicleType == "CAR",
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildVehicleTypeCard(
                                    type: "BIKE",
                                    icon: Icons.pedal_bike,
                                    color: Colors.green,
                                    isSelected: _selectedVehicleType == "BIKE",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Vehicle Details Form
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vehicle Information',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),

                            _buildModernTextField(
                              controller: licenseNoController,
                              label: 'License Number',
                              hint: 'e.g. USH 234A',
                              icon: Icons.confirmation_number,
                              onChanged: (value) {
                                if (value.length >= 8) {
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

                            if (is_Search) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.teal),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Checking for existing records...',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.teal,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            _buildModernTextField(
                              controller: driverNameController,
                              label: 'Driver Name',
                              icon: Icons.person,
                            ),

                            const SizedBox(height: 20),

                            _buildModernTextField(
                              controller: telNumberController,
                              label: 'Phone Number',
                              icon: Icons.phone,
                            ),

                            const SizedBox(height: 20),

                            _buildModernTextField(
                              controller: cardNumberController,
                              label: 'Card Number',
                              icon: Icons.credit_card,
                              onChanged: (value) {
                                if (licenseNoController.text == "") {
                                  populateFields(value);
                                }
                              },
                            ),

                            const SizedBox(height: 20),

                            _buildModernTextField(
                              controller: carOccupantsController,
                              label: 'Number of Occupants',
                              icon: Icons.groups,
                            ),

                            const SizedBox(height: 32),

                            // Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (isCheckedout) {
                                    licenseNo = licenseNoController.text;
                                    if (licenseNo.length < 5) {
                                      _showErrorDialog(
                                          'Invalid license number (e.g. UAA 001A)');
                                    } else {
                                      registerVehicle();
                                    }
                                  } else {
                                    checkoutVehicle();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isCheckedout
                                      ? Colors.black87
                                      : const Color(0xFF00CE6C),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isCheckedout ? Icons.login : Icons.logout,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isCheckedout
                                          ? 'Check In Vehicle'
                                          : 'Check Out Vehicle',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          indicatorColor: Colors.blue.withOpacity(0.1),
          selectedIndex: currentScreenIndex,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: "Records",
            ),
            NavigationDestination(
              icon: Icon(Icons.app_registration_outlined),
              selectedIcon: Icon(Icons.app_registration),
              label: "Register",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleTypeCard({
    required String type,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicleType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              type,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
