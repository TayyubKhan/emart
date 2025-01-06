import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ViewModel/product_view_model.dart';

class ProductCard extends ConsumerWidget {
  final dynamic product;
  final int index;
  final bool isFirstHalf;

  const ProductCard({
    super.key,
    required this.product,
    required this.index,
    required this.isFirstHalf,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionProvider =
        isFirstHalf ? firstHalfSelectionProvider : secondHalfSelectionProvider;

    // Listen to cart count for the specific product
    final cartItemCount =
        ref.watch(cartProvider.select((cart) => cart[product] ?? 0));

    final isInCart = cartItemCount > 0;

    return GestureDetector(
      onTap: () {
        ref.read(selectionProvider.notifier).toggleSelection(index);
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: isInCart ? Colors.black : Colors.grey.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
                imageUrl: product['image'], height: 100, fit: BoxFit.cover),
            const SizedBox(height: 8),
            Text(
              product['title'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                Text(
                  '₹ ${product['price']}000',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '\t70 % Discount',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (cartItemCount > 0) // Show count only if the item is in the cart
              Text('In cart: $cartItemCount'),
            const SizedBox(height: 8),
            // Toggle Button
            ElevatedButton(
              onPressed: () {
                if (isInCart) {
                  ref.read(cartProvider.notifier).removeFromCart(product);
                } else {
                  ref.read(cartProvider.notifier).addToCart(product);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isInCart ? Colors.red : Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text(isInCart ? 'Remove from Cart' : 'Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
