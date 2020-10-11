import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  static const id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
        centerTitle: true,
      ),
      body: Center(
        child: MaterialButton(
          onPressed: () {
            DatabaseReference dbRef =
                FirebaseDatabase.instance.reference().child('Test');
            dbRef.set('IsConnected');
          },
          height: 50,
          minWidth: 300,
          color: Colors.green,
          child: Text('Test Connection'),
        ),
      ),
    );
  }
}
