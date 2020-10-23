import 'package:flutter/material.dart';
import 'package:cab_rider/screens/brand_colors.dart';
import 'package:cab_rider/widgets/taxi_outline_button.dart';

class NoDriverDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: 250,
        padding: EdgeInsets.all(32.0),
        margin: EdgeInsets.all(0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'No driver found',
              style: TextStyle(
                fontSize: 22.0,
                fontFamily: 'Brand-Bold',
              ),
            ),
            Text(
              'No available driver close by, we suggest you try again shortly',
              textAlign: TextAlign.center,
            ),
            Container(
              width: 200,
              child: TaxiOutlineButton(
                title: 'CLOSE',
                color: BrandColors.colorLightGrayFair,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
