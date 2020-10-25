import 'package:flutter/material.dart';
import 'package:cab_rider/models/user.dart';
import 'package:cab_rider/widgets/taxi_button.dart';
import 'package:cab_rider/screens/brand_colors.dart';
import 'package:cab_rider/shared/global_variables.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  // form values
  String _currentPhoneNumber = currentUserInfo.phone;
  String _currentFullName = currentUserInfo.fullName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    initialValue: currentUserInfo.fullName,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      labelText: 'FirstName',
                    ),
                    validator: (value) => value.isEmpty ? 'First Name' : null,
                    onChanged: (value) =>
                        setState(() => _currentFullName = value),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    initialValue: currentUserInfo.phone,
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      labelText: 'Phone Number',
                    ),
                    validator: (value) => value.isEmpty ? 'Phone Number' : null,
                    onChanged: (value) =>
                        setState(() => _currentPhoneNumber = value),
                  ),
                  SizedBox(height: 40.0),
                  TaxiButton(
                    color: BrandColors.colorAccentPurple,
                    title: 'UPDATE',
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        final dbRef = FirebaseDatabase.instance.reference();
                        final fullNameRef = dbRef
                            .child('users/${currentFirebaseUser.uid}/fullname');
                        final phoneRef = dbRef
                            .child('users/${currentFirebaseUser.uid}/phone');

                        await fullNameRef.set(_currentFullName);
                        await phoneRef.set(_currentPhoneNumber);

                        final userRef =
                            dbRef.child('users/${currentFirebaseUser.uid}');

                        DataSnapshot snapshot = await userRef.once();

                        if (snapshot.value != null) {
                          currentUserInfo = User.fromSnapshot(snapshot);
                        }
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
