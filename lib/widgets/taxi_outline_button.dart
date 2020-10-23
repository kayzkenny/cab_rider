import 'package:flutter/material.dart';
import 'package:cab_rider/screens/brand_colors.dart';

class TaxiOutlineButton extends StatelessWidget {
  final Color color;
  final String title;
  final Function onPressed;

  TaxiOutlineButton({
    this.title,
    this.color,
    this.onPressed,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      borderSide: BorderSide(color: color),
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(25.0),
      ),
      onPressed: onPressed,
      color: color,
      textColor: color,
      child: Container(
        height: 50.0,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15.0,
              fontFamily: 'Brand-Bold',
              color: BrandColors.colorText,
            ),
          ),
        ),
      ),
    );
  }
}
