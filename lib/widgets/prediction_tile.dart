import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cab_rider/models/address.dart';
import 'package:cab_rider/shared/api_keys.dart';
import 'package:cab_rider/models/prediction.dart';
import 'package:cab_rider/providers/app_data.dart';
import 'package:cab_rider/screens/brand_colors.dart';
import 'package:cab_rider/helpers/request_helper.dart';
import 'package:cab_rider/widgets/progress_dialog.dart';
import 'package:cab_rider/shared/global_variables.dart';

class PredictionTile extends StatelessWidget {
  const PredictionTile({
    this.prediction,
    Key key,
  }) : super(key: key);

  final Prediction prediction;

  void getPlaceDetails(String placeId, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(status: 'Please wait...'),
    );

    String url = '$placeDetailsEndpoint?place_id=$placeId&key=$googleMapsKey';

    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if (response == 'failed') {
      return;
    }

    if (response['status'] == 'OK') {
      Address thisPlace = Address(
        placeId: placeId,
        placeName: response['result']['name'],
        latitude: response['result']['geometry']['location']['lat'],
        longitude: response['result']['geometry']['location']['lng'],
      );

      Provider.of<AppData>(context, listen: false)
          .updateDestinationAddress(thisPlace);
      print(thisPlace.placeName);

      Navigator.pop(context, 'getDirection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: () => getPlaceDetails(prediction.placeId, context),
      child: Container(
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
            ),
          ],
        ),
      ),
    );
  }
}
