import 'dart:developer';
import 'dart:io';

import 'package:chatapp/screens/loginscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../common/custom_form_button.dart';
import '../common/custom_input_field.dart';
import '../common/page_header.dart';
import '../common/page_heading.dart';
import '../model/usermodel.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  File? _profileImage;
  bool isLoading = false;
  final _signupFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedGender;

  FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  Future<void> _pickProfileImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _profileImage = File(image.path));
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: isLoading
            ? Center(
                child: Container(
                  height: size.height / 20,
                  width: size.height / 20,
                  child: CircularProgressIndicator(),
                ),
              )
            : SingleChildScrollView(
                child: Form(
                  key: _signupFormKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      const PageHeader(),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            const PageHeading(
                              title: 'Sign-up',
                            ),
                            SizedBox(
                              width: 130,
                              height: 130,
                              child: CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      bottom: 5,
                                      right: 5,
                                      child: GestureDetector(
                                        onTap: _pickProfileImage,
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade400,
                                            border: Border.all(
                                                color: Colors.white, width: 3),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_sharp,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            CustomInputField(
                              labelText: 'Name',
                              hintText: 'Your name',
                              isDense: true,
                              controller: _nameController,
                              validator: (textValue) {
                                if (textValue == null || textValue.isEmpty) {
                                  return 'Name field is required!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            CustomInputField(
                                labelText: 'Email',
                                hintText: 'Your email id',
                                isDense: true,
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
                                labelText: 'Contact no.',
                                hintText: 'Your contact number',
                                isDense: true,
                                controller: _phoneController,
                                validator: (textValue) {
                                  if (textValue == null || textValue.isEmpty) {
                                    return 'Contact number is required!';
                                  }
                                  return null;
                                }),
                            const SizedBox(
                              height: 16,
                            ),
                            CustomInputField(
                              labelText: 'Password',
                              hintText: 'Your password',
                              isDense: true,
                              controller: _passwordController,
                              obscureText: true,
                              validator: (textValue) {
                                if (textValue == null || textValue.isEmpty) {
                                  return 'Password is required!';
                                }
                                return null;
                              },
                              suffixIcon: true,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              width: size.width * 0.9,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedGender,
                                  items: _genderOptions.map((String gender) {
                                    return DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(gender),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedGender = newValue;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Gender',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select your gender';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 22,
                            ),
                            CustomFormButton(
                              innerText: 'Signup',
                              onPressed: _handleSignupUser,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account ? ',
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
                                                  const LoginScreen()))
                                    },
                                    child: const Text(
                                      'Log-in',
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
                              height: 15,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _handleSignupUser() async {
    if (_signupFormKey.currentState!.validate()) {
      try {
        // Create user with email and password
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await userCredential.user!.sendEmailVerification();

        // Get image URL after uploading
        String imageUrl = '';
        if (_profileImage != null) {
          thumbnailUpload(_profileImage!.path, context).then((netimage) async {
            imageUrl = netimage ?? '';
            // Create UserModel instance
            UserModel userModel = UserModel(
              uid: userCredential.user!.uid,
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              imageUrl: imageUrl,
              gender: _selectedGender!,
            );

            // Save user info in Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set(userModel.toMap());

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Sign-up successful! Please verify your email.')),
            );

            // Navigate to login screen
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
          });
        } else {
          // If there's no profile image, save user info without it
          UserModel userModel = UserModel(
            uid: userCredential.user!.uid,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            imageUrl: 'no image',
            gender: _selectedGender!,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userModel.toMap());

          await FirebaseFirestore.instance
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .set({
            "name": _nameController,
            "email": _emailController,
            // "status": _status,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Sign-up successful! Please verify your email.')),
          );

          // Navigate to login screen
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      } on FirebaseAuthException catch (e) {
        // Handle Firebase auth errors
        String message;
        if (e.code == 'email-already-in-use') {
          message = 'This email is already in use.';
        } else if (e.code == 'weak-password') {
          message = 'The password is too weak.';
        } else {
          message = 'FirebaseAuthException: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } on FirebaseException catch (e) {
        // Handle Firebase Firestore and Storage errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('FirebaseException: ${e.message}')),
        );
        print(e.message);
      } catch (e) {
        // Handle any other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('General Exception: ${e.toString()}')),
        );
      }
    }
  }

  Future<String?> thumbnailUpload(String post, BuildContext context) async {
    try {
      final path = 'thumbnails/${post.split('/').last.split(".").first}';
      log(path);
      final ref = FirebaseStorage.instance.ref().child(path);
      log(ref.toString());
      UploadTask putFile = ref.putFile(File(post));
      putFile.asStream().listen((event) {
        log(event.totalBytes.toString());
        log(event.bytesTransferred.toString());
      });
      final snapshot = await putFile.whenComplete(() {});
      final url = snapshot.ref.getDownloadURL();
      log(url.toString());
      return url;
    } catch (e) {
      throw e;
    }
  }
}
