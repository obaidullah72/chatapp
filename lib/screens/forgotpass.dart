import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../common/custom_form_button.dart';
import '../common/custom_input_field.dart';
import '../common/page_header.dart';
import '../common/page_heading.dart';
import 'loginscreen.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _forgetPasswordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleForgetPassword() async {
    if (_forgetPasswordFormKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Column(
          children: [
            SizedBox(height: 30,),
            const PageHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _forgetPasswordFormKey,
                    child: Column(
                      children: [
                        const PageHeading(
                          title: 'Forgot password',
                        ),
                        CustomInputField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Your email id',
                          isDense: true,
                          validator: (textValue) {
                            if (textValue == null || textValue.isEmpty) {
                              return 'Email is required!';
                            }
                            if (!EmailValidator.validate(textValue)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomFormButton(
                          innerText: 'Submit',
                          onPressed: (){},
                        ),
                        const SizedBox(height: 20),
                        Container(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const LoginScreen()))
                            },
                            child: const Text(
                              'Back to login',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xff939393),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
}
