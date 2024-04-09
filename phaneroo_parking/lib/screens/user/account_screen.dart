import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phaneroo_parking/requests.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late Future userData;

  @override
  void initState() {
    super.initState();
    userData = getCurrentUserRequest();
  }

  @override
  Widget build(BuildContext context) {
    int currentScreenIndex = 3;
    return FutureBuilder(
        future: userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Future.delayed(Duration.zero, () {
              Navigator.pushNamed(context, '/login');
            });
            // Return an empty container while redirecting
            return Container();
          } else if (snapshot.hasData) {
            final statusCode = snapshot.data!.statusCode;
            if (statusCode >= 400 && statusCode < 500) {
              // Handle client errors (e.g., unauthorized)
              Future.delayed(Duration.zero, () {
                Navigator.pushNamed(context, '/login');
              });
              return Container(); // Return an empty container while redirecting
            }

            var jsonData = json.decode(snapshot.data!.body);

            return SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                body: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Card(
                        surfaceTintColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: Container(
                                  height: 120.0,
                                  width: 120.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.blue.shade100,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.5),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child:
                                          Image.asset("assets/images/user.png"),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              Column(
                                children: [
                                  Text(
                                    jsonData["Codename"],
                                    style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    jsonData["Fullname"],
                                    style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    jsonData["Name"],
                                    style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),
                                  SizedBox(
                                    height: 50.0,
                                    width: 200.0,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        logoutRequest().then((response) {
                                          if (response.statusCode >= 400) {
                                            // not successful
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Operation now successful'),
                                              ),
                                            );
                                            return;
                                          }
                                          SharedPreferences.getInstance()
                                              .then((prefs) {
                                            prefs.remove("access_token");
                                            prefs.remove("refresh_token");
                                          });

                                          Navigator.popAndPushNamed(
                                              context, "/login");
                                        }).catchError(
                                          (err) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'No Internet connection'),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: const StadiumBorder(),
                                        side: BorderSide.none,
                                      ),
                                      child: Text(
                                        "Logout",
                                        style: GoogleFonts.lato(
                                          textStyle: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
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
          } else {
            Future.delayed(Duration.zero, () {
              Navigator.pushNamed(context, '/login');
            });
            // Return an empty container while redirecting
            return Container();
          }
        });
  }
}
