import 'package:chatapp/common/custom_form_button.dart';
import 'package:chatapp/screens/loginscreen.dart';
import 'package:chatapp/screens/phoneotp.dart';
import 'package:flutter/material.dart';

class Startupscreen extends StatefulWidget {
  const Startupscreen({super.key});

  @override
  State<Startupscreen> createState() => _StartupscreenState();
}

class _StartupscreenState extends State<Startupscreen> {
  @override
  Widget build(BuildContext context) {
    final sizeWid = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/startup.png',height: 300,width: sizeWid,),
            SizedBox(
              height: 30,
            ),
            CustomFormButton(
              innerText: 'LogIn',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
            SizedBox(height: 20,),
            CustomFormButton(
              innerText: 'Phone Login',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyPhone()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
