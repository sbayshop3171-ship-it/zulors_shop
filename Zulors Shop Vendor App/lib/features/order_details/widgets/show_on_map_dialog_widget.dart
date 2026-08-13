import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/order/domain/models/order_model.dart';
import 'package:zulors_shop_vendor/features/order_details/controllers/order_details_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';

class ShowOnMapDialogWidget extends StatelessWidget {
  final BillingAddressData? billingAddressData;
  const ShowOnMapDialogWidget({super.key,required this.billingAddressData});

  @override
  Widget build(BuildContext context) {
    return  Consumer<OrderDetailsController>(
        builder:  (context, resProvider, child) {
          Set<Marker> markers = resProvider.markers;
          return  Dialog(
          child: SizedBox(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(double.parse(billingAddressData?.latitude ?? ''), double.parse(billingAddressData?.longitude ?? '')),
                  zoom: 15,
                ),
                markers: markers,
                zoomControlsEnabled: false,
                compassEnabled: false,
                indoorViewEnabled: true,
                mapToolbarEnabled: false,
              ),
            )
          ),
        );
      }
    );
  }
}
