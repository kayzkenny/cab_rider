import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cab_rider/screens/brand_colors.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Set Destination',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Brand-Bold',
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData().copyWith(
          color: Colors.black,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Image.asset(
                    'images/pickicon.png',
                    height: 16,
                    width: 16,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: BrandColors.colorLightGrayFair,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Pickup Location',
                            contentPadding: EdgeInsets.all(8),
                            fillColor: BrandColors.colorLightGrayFair,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Image.asset(
                    'images/desticon.png',
                    height: 16,
                    width: 16,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: BrandColors.colorLightGrayFair,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Where to?',
                            contentPadding: EdgeInsets.all(8),
                            fillColor: BrandColors.colorLightGrayFair,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
