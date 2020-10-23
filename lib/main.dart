import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cab_rider/screens/main_page.dart';
import 'package:cab_rider/providers/app_data.dart';
import 'package:cab_rider/screens/login_page.dart';
import 'package:cab_rider/shared/global_variables.dart';
import 'package:cab_rider/screens/registration_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // name property throws an error on hot restart, default param used instead
    // name: 'db2',
    // IOS FirebaseOptions Not Yet Configures
    options: Platform.isIOS || Platform.isMacOS
        ? FirebaseOptions(
            appId: '1:297855924061:ios:c6de2b69b03a5be8',
            apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
            projectId: 'flutter-firebase-plugins',
            messagingSenderId: '297855924061',
            databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
          )
        : FirebaseOptions(
            appId: '1:268282644915:android:7d569cdfce9b528e9ee3c6',
            apiKey: 'AIzaSyA2K6lj6tSMD62FGv5sViZn40VD2i6ZxZM',
            messagingSenderId: '268282644915',
            projectId: 'geetaxi-1e769',
            databaseURL: 'https://geetaxi-1e769.firebaseio.com',
          ),
  );
  currentFirebaseUser = auth.FirebaseAuth.instance.currentUser;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'Brand-Regular',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: currentFirebaseUser == null ? LoginPage.id : MainPage.id,
        routes: {
          MainPage.id: (context) => MainPage(),
          LoginPage.id: (context) => LoginPage(),
          RegistrationPage.id: (context) => RegistrationPage(),
        },
      ),
    );
  }
}
