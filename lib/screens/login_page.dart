import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cab_rider/screens/main_page.dart';
import 'package:cab_rider/widgets/taxi_button.dart';
import 'package:cab_rider/screens/brand_colors.dart';
import 'package:cab_rider/screens/registration_page.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ConnectivityResult _connectionStatus;

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final _auth = FirebaseAuth.instance;

  final Connectivity _connectivity = Connectivity();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final formKey = GlobalKey<FormState>();

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

  Future<void> login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // check if user registration was successful
      if (userCredential != null) {
        // route the user to the main page
        Navigator.pushNamedAndRemoveUntil(
          context,
          MainPage.id,
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackbar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnackbar('Wrong password provided for that user.');
      }
    } catch (e) {
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
                    result == ConnectivityResult.wifi
                ? 'You are Online'
                : 'You are Offline',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          backgroundColor: result == ConnectivityResult.wifi ||
                  result == ConnectivityResult.wifi
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
                'Sign In as a Rider',
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
                title: 'LOGIN',
                color: BrandColors.colorGreen,
                onPressed: () async {
                  if (formKey.currentState.validate()) {
                    if (_connectionStatus != ConnectivityResult.mobile &&
                        _connectionStatus != ConnectivityResult.wifi) {
                      showSnackbar('No Internet Connection');
                      return;
                    }
                    await login();
                  }
                },
              ),
              SizedBox(height: 32),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RegistrationPage.id,
                    (route) => false,
                  );
                },
                child: Text('Don\'t have an account, sign up here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
