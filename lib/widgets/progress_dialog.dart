import 'package:cab_rider/screens/brand_colors.dart';
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  const ProgressDialog({
    this.status,
    Key key,
  }) : super(key: key);

  final String status;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(16.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(width: 5.0),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  BrandColors.colorAccent,
                ),
              ),
              SizedBox(width: 25.0),
              Text(
                status,
                style: TextStyle(fontSize: 15.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
