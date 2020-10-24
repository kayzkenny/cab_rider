import 'package:flutter/material.dart';
import 'package:cab_rider/widgets/taxi_button.dart';
import 'package:cab_rider/screens/brand_colors.dart';
import 'package:cab_rider/widgets/brand_divider.dart';

class CollectPaymentDialog extends StatelessWidget {
  final int fares;
  final String paymentMethod;

  const CollectPaymentDialog({
    this.paymentMethod,
    this.fares,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.transparent,
      child: Container(
        height: 360,
        padding: EdgeInsets.symmetric(vertical: 16),
        margin: EdgeInsets.all(4.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('${paymentMethod.toUpperCase()} PAYMENT'),
            BrandDivider(),
            Text(
              '\$$fares',
              style: TextStyle(
                fontFamily: 'Brand-Bold',
                fontSize: 50,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Amount above is the total fares to be charged to the rider',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 230,
              child: TaxiButton(
                title: paymentMethod == 'cash' ? 'PAY CASH' : 'CONFRIM',
                color: BrandColors.colorGreen,
                onPressed: () async {
                  Navigator.pop(context, 'close');
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
