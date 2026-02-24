import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/models/home_carousel_Item_model.dart';

class HomeCarouselWidget extends StatelessWidget {
  const HomeCarouselWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterCarousel.builder(
      itemCount: dummyCarsouleItems.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                imageUrl: dummyCarsouleItems[itemIndex].imgUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.fill,
                width: double.infinity,
              ),
            ),
          ),
      options: FlutterCarouselOptions(
        height: 200.0,
        autoPlay: true,
        showIndicator: true,
        slideIndicator: CircularSlideIndicator(),
      ),
    );
  }
}
