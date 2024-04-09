import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phaneroo_parking/requests.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  TextEditingController codeNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController accessCodeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future<void> registerUser() async {
    var data = <String, dynamic>{
      'fullname': fullNameController.text,
      'codename': codeNameController.text,
      'phone_number': phoneNumberController.text,
      'email': phoneNumberController.text,
      'accessCode': accessCodeController.text,
      'password': passwordController.text,
      'confirm_password': confirmPasswordController.text,
    };

    if (passwordController.text != confirmPasswordController.text) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Password mismatch'),
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

    registerUserRequest(data).then((response) {
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
        Navigator.popAndPushNamed(context, "/login");
      }
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Internet connection'),
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
        children: [
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Register Account",
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                TextFormField(
                  controller: fullNameController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: Text(
                      "Fullname",
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
                  controller: emailController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: Text(
                      "Email",
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
                  controller: phoneNumberController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: Text(
                      "Phone Number",
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
                  controller: accessCodeController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: Text(
                      "Access Code",
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
                const SizedBox(height: 15.0),
                TextFormField(
                  controller: confirmPasswordController,
                  maxLines: 1,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: Text(
                      "Confirm Password",
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                GestureDetector(
                  onTap: registerUser,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Center(
                      child: Text(
                        "Register",
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
                  onPressed: () => Navigator.popAndPushNamed(context, "/login"),
                  child: Text(
                    "Already have an account",
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
          const SizedBox(height: 50.0),
        ],
      ),
    ));
  }
}
