import 'package:chatapp/model/usermodel.dart';
import 'package:chatapp/screens/forgotpass.dart';
import 'package:chatapp/screens/signupscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/custom_form_button.dart';
import '../common/custom_input_field.dart';
import '../common/page_header.dart';
import '../common/page_heading.dart';
import '../provider/userprovider.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            const PageHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        const PageHeading(
                          title: 'Log-in',
                        ),
                        CustomInputField(
                            labelText: 'Email',
                            hintText: 'Your email id',
                            controller: _emailController,
                            validator: (textValue) {
                              if (textValue == null || textValue.isEmpty) {
                                return 'Email is required!';
                              }
                              if (!EmailValidator.validate(textValue)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            }),
                        const SizedBox(
                          height: 16,
                        ),
                        CustomInputField(
                          labelText: 'Password',
                          hintText: 'Your password',
                          obscureText: true,
                          suffixIcon: true,
                          controller: _passwordController,
                          validator: (textValue) {
                            if (textValue == null || textValue.isEmpty) {
                              return 'Password is required!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          width: size.width * 0.80,
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const ForgetPasswordPage()))
                            },
                            child: const Text(
                              'Forget password?',
                              style: TextStyle(
                                color: Color(0xff939393),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomFormButton(
                            innerText: 'Login', onPressed: _handleLoginUser),
                        const SizedBox(
                          height: 18,
                        ),
                        SizedBox(
                          width: size.width * 0.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don\'t have an account ? ',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xff939393),
                                    fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const SignupPage()))
                                },
                                child: const Text(
                                  'Sign-up',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xff748288),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLoginUser() async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          if (!user.emailVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please verify your email before logging in.'),
                action: SnackBarAction(
                  label: 'Resend Email',
                  onPressed: () async {
                    await user.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Verification email resent. Please check your inbox.'),
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login successful!')),
            );
            QuerySnapshot _firedata = await FirebaseFirestore.instance
                .collection('users')
                .where('uid', isEqualTo: user.uid)
                .get();
            UserModel userm = _firedata.docs
                .map((_element) =>
                UserModel.fromMap(_element.data() as Map<String, dynamic>))
                .first;
            Provider.of<UserProvider>(context, listen: false).setUser(userm);

            // Navigate to home screen
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided.';
        } else {
          message = 'An error occurred. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
