import 'dart:ui';

import 'package:cab_rider/widgets/brand_divider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cab_rider/shared/api_keys.dart';
import 'package:cab_rider/models/prediction.dart';
import 'package:cab_rider/providers/app_data.dart';
import 'package:cab_rider/screens/brand_colors.dart';
import 'package:cab_rider/helpers/request_helper.dart';
import 'package:cab_rider/widgets/prediction_tile.dart';
import 'package:cab_rider/shared/global_variables.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final focusDestination = FocusNode();
  final pickupController = TextEditingController();
  final destinationController = TextEditingController();

  bool focused = false;

  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  List<Prediction> destinationPredictionList = [];

  Future<void> searchPlace(String placeName) async {
    if (placeName.length > 1) {
      String url =
          '$googlePlacesEndpoint=$placeName&key=$googleMapsKey&sessiontoken=1234567890&components=country:ng';
      var response = await RequestHelper.getRequest(url);

      if (response == 'failed') {
        return;
      }

      if (response['status'] == 'OK') {
        List predicitionJson = response['predictions'];

        List<Prediction> thisList =
            predicitionJson.map((e) => Prediction.fromJson(e)).toList();

        setState(() => destinationPredictionList = thisList);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    pickupController.text =
        Provider.of<AppData>(context).pickupAddress?.placeName ?? "";

    setFocus();

    return Scaffold(
      backgroundColor: Colors.white,
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
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
                                controller: pickupController,
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
                                onChanged: (value) => searchPlace(value),
                                focusNode: focusDestination,
                                controller: destinationController,
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
              if (destinationPredictionList.length > 0)
                ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemBuilder: (context, index) => PredictionTile(
                    prediction: destinationPredictionList[index],
                  ),
                  separatorBuilder: (context, index) => BrandDivider(
                    indent: 32.0,
                  ),
                  itemCount: destinationPredictionList.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                )
            ],
          ),
        ),
      ),
    );
  }
}
