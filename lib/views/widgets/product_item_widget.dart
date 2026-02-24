import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_colors.dart';

class ProductItemWidget extends StatefulWidget {
  final ProductItemModel product;
  const ProductItemWidget({super.key, required this.product});

  @override
  State<ProductItemWidget> createState() => _ProductItemWidgetState();
}

class _ProductItemWidgetState extends State<ProductItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: SizedBox(
        height: 120,
        child: Card(
          color: AppColors.white,
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.all(15),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.greyShade2,
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.product.description,
                      style: TextStyle(fontSize: 13, color: AppColors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    widget.product.isFavorite = !widget.product.isFavorite;
                  });
                },
                icon: Icon(
                  widget.product.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: AppColors.darkGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
