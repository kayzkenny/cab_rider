import 'dart:async';

import 'package:cab_rider/widgets/progress_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cab_rider/screens/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cab_rider/screens/login_page.dart';
import 'package:cab_rider/widgets/taxi_button.dart';
import 'package:cab_rider/screens/brand_colors.dart';
import 'package:firebase_database/firebase_database.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  ConnectivityResult _connectionStatus;

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final _auth = FirebaseAuth.instance;

  final Connectivity _connectivity = Connectivity();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();

  final phoneController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  void showSnackbar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Future<void> registerUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        status: 'Registering you...',
      ),
    );

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // check if user registration was successful
      if (userCredential != null) {
        DatabaseReference newUserRef = FirebaseDatabase.instance
            .reference()
            .child('users/${userCredential.user.uid}');

        // prepare data to be saved on users table
        Map userMap = {
          'fullname': fullNameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
        };

        newUserRef.set(userMap);

        // route the user to the main page
        Navigator.pushNamedAndRemoveUntil(
          context,
          MainPage.id,
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'weak-password') {
        showSnackbar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnackbar('The account already exists for that email.');
      }
    } catch (e) {
      Navigator.pop(context);
      showSnackbar(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() => _connectionStatus = result);
    if (scaffoldKey.currentState != null) {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            result == ConnectivityResult.wifi ||
                    result == ConnectivityResult.mobile
                ? 'You are Online'
                : 'You are Offline',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          backgroundColor: result == ConnectivityResult.wifi ||
                  result == ConnectivityResult.mobile
              ? Colors.green[900]
              : Colors.red[700],
        ),
      );
    }
    print('connection status changed to: ${result.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(height: 64),
              Image(
                alignment: Alignment.center,
                height: 100.0,
                width: 100.0,
                image: AssetImage('images/logo.png'),
              ),
              SizedBox(height: 32),
              Text(
                'Create a Rider\'s Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  fontFamily: 'Brand-Bold',
                ),
              ),
              SizedBox(height: 32),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      validator: (value) =>
                          value.isEmpty || !value.contains('@')
                              ? 'Enter a valid email address'
                              : null,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: fullNameController,
                      validator: (value) => value.length < 8
                          ? 'Enter a full name at least 6 characters long'
                          : null,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      validator: (value) => value.length < 8
                          ? 'Enter a phone number at least 10 characters long'
                          : null,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      validator: (value) => value.length < 8
                          ? 'Enter a password at least 8 characters long'
                          : null,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 64),
              TaxiButton(
                title: 'REGISTER',
                color: BrandColors.colorGreen,
                onPressed: () async {
                  if (formKey.currentState.validate()) {
                    if (_connectionStatus != ConnectivityResult.mobile &&
                        _connectionStatus != ConnectivityResult.wifi) {
                      showSnackbar('No Internet Connection');
                      return;
                    }
                    await registerUser();
                  }
                },
              ),
              SizedBox(height: 32),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    LoginPage.id,
                    (route) => false,
                  );
                },
                child: Text('Already have a Rider\'s Account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
