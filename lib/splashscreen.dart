// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:chatapp/screens/home.dart';
// import 'package:chatapp/screens/loginscreen.dart';
// import 'package:chatapp/screens/phoneotp.dart';
// import 'package:chatapp/screens/startupscreen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class Splashscreen extends StatefulWidget {
//   const Splashscreen({super.key});
//
//   @override
//   State<Splashscreen> createState() => _SplashscreenState();
// }
//
// class _SplashscreenState extends State<Splashscreen> {
//   @override
//   Widget build(BuildContext context) {
//     final sizeWidth = MediaQuery.sizeOf(context).width;
//     final sizeHeight = MediaQuery.sizeOf(context).height;
//
//     return FutureBuilder<User?>(
//       future: _checkUserAuthentication(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // Show splash screen while checking authentication
//           return AnimatedSplashScreen(
//             splash: Column(
//               children: [
//                 Image.asset('assets/logo.png', height: 150, width: sizeWidth),
//                 const Text(
//                   'Chat App',
//                   style: TextStyle(
//                       fontSize: 40,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.deepPurpleAccent,
//             splashIconSize: 250,
//             duration: 4000,
//             splashTransition: SplashTransition.fadeTransition,
//             nextScreen: Container(), // Temporary placeholder
//           );
//         } else {
//           // Navigate based on authentication state
//           if (snapshot.hasData && snapshot.data != null) {
//             return HomeScreen();
//           } else {
//             return const MyPhone();
//           }
//         }
//       },
//     );
//   }
//
//   Future<User?> _checkUserAuthentication() async {
//     return FirebaseAuth.instance.currentUser;
//   }
// }

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:chatapp/authenticate/authenticate.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  Widget build(BuildContext context) {
    final sizeWidth = MediaQuery.sizeOf(context).width;
    // final sizeHeight = MediaQuery.sizeOf(context).height;

    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Image.asset('assets/logo.png', height: 150, width: sizeWidth),
          const Text(
            'Chat App',
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      splashIconSize: 250,
      duration: 5000,
      splashTransition: SplashTransition.fadeTransition,
      nextScreen: Authenticate(), // Temporary placeholder
    );
  }
}
