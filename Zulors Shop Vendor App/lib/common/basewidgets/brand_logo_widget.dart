import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/utill/images.dart';

class BrandLogoWidget extends StatelessWidget {
  const BrandLogoWidget({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final logoUrl = Provider.of<SplashController>(
      context,
    ).configModel?.companyLogoImage?.path;
    if (logoUrl == null || logoUrl.isEmpty) {
      return Image.asset(
        Images.logoWithAppName,
        width: width,
        height: height,
        fit: fit,
      );
    }
    return CachedNetworkImage(
      imageUrl: logoUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => Image.asset(
        Images.logoWithAppName,
        width: width,
        height: height,
        fit: fit,
      ),
      errorWidget: (_, __, ___) => Image.asset(
        Images.logoWithAppName,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}
