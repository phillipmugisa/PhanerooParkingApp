import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phaneroo_parking/requests.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController codeNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    var data = <String, dynamic>{
      'codename': codeNameController.text,
      'password': passwordController.text
    };

    if (codeNameController.text == "" || passwordController.text == "") {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Provide your codename and password'),
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

    loginRequest(data).then((response) {
      if (response.statusCode > 399) {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Please confirm your data'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        var jsonData = json.decode(response.body);
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("access_token", jsonData["access_token"]);
          prefs.setString("refresh_token", jsonData["refresh_token"]);
        });

        Navigator.popAndPushNamed(context, "/");
      }
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Internet connection'),
        ),
      );
    });
  }

  void refreshTokens() {
    refreshTokenRequest().then((response) {
      if (response.statusCode < 399) {
        // success

        var jsonData = json.decode(response.body);
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("access_token", jsonData["access_token"]);
          prefs.setString("refresh_token", jsonData["refresh_token"]);
        });

        // navigator to previous screen

        Navigator.pop(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Run your function here
    refreshTokens();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Log into your account",
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              TextFormField(
                controller: codeNameController,
                maxLines: 1,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  label: Text(
                    "Code Name",
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: passwordController,
                maxLines: 1,
                obscureText: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  label: Text(
                    "Password",
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forget Password?",
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15.0),
              GestureDetector(
                onTap: () => loginUser(),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: Text(
                      "Login",
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/register"),
                child: Text(
                  "Register account",
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
