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
    return FutureBuilder<List<HomeCarsouleItemModel>>(
      future: _remoteDataSource.getCarouselProductsWithOffers(),
      builder: (context, snapshot) {
        final items = snapshot.hasData && snapshot.data!.isNotEmpty
            ? snapshot.data!
            : dummyCarsouleItems;

        return FlutterCarousel.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: items[itemIndex].imgUrl,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha(30),
                              Colors.black.withAlpha(120),
                            ],
                          ),
                        ),
                      ),
                      if ((items[itemIndex].offerLabel ?? '').isNotEmpty)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              items[itemIndex].offerLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[itemIndex].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              items[itemIndex].sellerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
