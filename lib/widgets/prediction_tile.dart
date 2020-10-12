import 'package:cab_rider/models/prediction.dart';
import 'package:flutter/material.dart';
import 'package:cab_rider/screens/brand_colors.dart';

class PredictionTile extends StatelessWidget {
  const PredictionTile({
    this.prediction,
    Key key,
  }) : super(key: key);

  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: BrandColors.colorDimText,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction.mainText,
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 2),
                Text(
                  prediction.secondaryText,
                  style: TextStyle(
                    fontSize: 12,
                    color: BrandColors.colorDimText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
