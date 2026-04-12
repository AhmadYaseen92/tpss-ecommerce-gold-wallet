import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/data/datasources/home_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/data/models/home_carousel_Item_model.dart';

class HomeCarouselWidget extends StatelessWidget {
  HomeCarouselWidget({super.key});

  final HomeRemoteDataSource _remoteDataSource =
      HomeRemoteDataSource(InjectionContainer.dio());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _remoteDataSource.getCarouselImageUrls(),
      builder: (context, snapshot) {
        final urls = snapshot.hasData && snapshot.data!.isNotEmpty
            ? snapshot.data!
            : dummyCarsouleItems.map((item) => item.imgUrl).toList();

        return FlutterCarousel.builder(
          itemCount: urls.length,
          itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: CachedNetworkImage(
                    imageUrl: urls[itemIndex],
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                ),
              ),
          options: FlutterCarouselOptions(
            height: 220.0,
            autoPlay: true,
            showIndicator: false,
            enlargeCenterPage: true,
            slideIndicator: CircularSlideIndicator(),
          ),
        );
      },
    );
  }
}
