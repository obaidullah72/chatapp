import 'package:chatapp/provider/userprovider.dart';
import 'package:chatapp/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyDBcUSBNirv-LZUFACZxIEwowJyiRC6XKY",
    appId: "1:58816611583:android:0ac4cca768782019daf8ca",
    messagingSenderId: "58816611583",
    projectId: "chatapptask-affb8",
    storageBucket: "chatapptask-affb8.appspot.com",
  ));

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatApp',
      home: const Splashscreen(),
    );
  }
}
