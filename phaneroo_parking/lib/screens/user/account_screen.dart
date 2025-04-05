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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 1,
          title: const Row(
            children: [
              Icon(
                Icons.local_parking,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 5),
              Text(
                "ParkMaster",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            // Clickable User Avatar
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/account");
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: const Icon(
                  Icons.person, // Use any icon you prefer
                  size: 18.0,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Clickable Role Text
            // GestureDetector(
            //   onTap: () {
            //     Navigator.pushNamed(context, "/");
            //   },
            //   child: const Text(
            //     "Admin",
            //     style: TextStyle(
            //       color: Colors.black,
            //       fontSize: 14.0,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 15),

            // Clickable Logout Icon
            IconButton(
              onPressed: () {
                logoutRequest().then((response) {
                  if (response.statusCode >= 400) {
                    // not successful
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Operation now successful'),
                      ),
                    );
                    return;
                  }
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.remove("access_token");
                    prefs.remove("refresh_token");
                  });

                  Navigator.popAndPushNamed(context, "/login");
                }).catchError(
                  (err) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No Internet connection'),
                      ),
                    );
                  },
                );
              },
              icon: Icon(Icons.logout, color: Colors.white),
            ),
            const SizedBox(width: 10),
          ],
        ),

        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: FutureBuilder(
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

                return ListView(
                  children: [
                    Card(
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
                                      fontSize: 18.0,
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
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      children: [
                        jsonData["IsTeamLeader"]["Bool"] == true ||
                                jsonData["IsAdmin"]["Bool"] == true
                            ? Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, "/leaderboard");
                                  },
                                  child: ListTile(
                                    tileColor: Colors.amberAccent,
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: Colors.white,
                                      ),
                                      child: const Icon(
                                        Icons.settings,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    title: Text(
                                      "Leader Board",
                                      style: GoogleFonts.lato(
                                        textStyle: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        Expanded(
                          child: ListTile(
                            tileColor: Colors.blue.shade200,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.blue.shade100.withOpacity(0.1),
                              ),
                              child: const Icon(
                                Icons.logout,
                                color: Colors.black45,
                              ),
                            ),
                            title: Text(
                              "Logout",
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            onTap: () {
                              logoutRequest().then((response) {
                                if (response.statusCode >= 400) {
                                  // not successful
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Operation now successful'),
                                    ),
                                  );
                                  return;
                                }
                                SharedPreferences.getInstance().then((prefs) {
                                  prefs.remove("access_token");
                                  prefs.remove("refresh_token");
                                });

                                Navigator.popAndPushNamed(context, "/login");
                              }).catchError(
                                (err) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No Internet connection'),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                Future.delayed(Duration.zero, () {
                  Navigator.pushNamed(context, '/login');
                });
                // Return an empty container while redirecting
                return Container();
              }
            },
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {},
        //   child: const Icon(
        //     Icons.record_voice_over,
        //   ),
        // ),
      ),
    );
  }
}
