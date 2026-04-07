import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/data/models/home_carousel_Item_model.dart';

class CustomCarouselSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 220,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: dummyCarsouleItems.map((item) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.imgUrl,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      }).toList(),
    );
  }
}
