import 'package:flutter/material.dart';
import 'package:phaneroo_parking/screens/auth/register.dart';
import 'package:phaneroo_parking/screens/home_screen.dart';
import 'package:phaneroo_parking/screens/vehicles/details_screen.dart';
import 'package:phaneroo_parking/screens/vehicles/scan_screen.dart';
import 'package:phaneroo_parking/screens/vehicles/records_screen.dart';
import 'package:phaneroo_parking/screens/user/account_screen.dart';
import 'package:phaneroo_parking/screens/auth/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Parking Assistant",
      initialRoute: "/",
      routes: {
        "/": (context) => const HomeScreen(),
        "/scan": (context) => const ScanCarScreen(),
        "/records": (context) => const RecordsScreen(),
        "/driver_details": (context) => const DetailsScreen(),
        "/account": (context) => const AccountScreen(),
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
