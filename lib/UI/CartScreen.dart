import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ViewModel/product_view_model.dart';

class CartScreen extends ConsumerWidget {
  final Widget Button;
  const CartScreen({super.key, required this.Button});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty!'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final product = cartItems.keys.elementAt(index);
                final count = cartItems[product]!;
                return ListTile(
                  leading: Image.network(product['image'], width: 50),
                  title: Text(product['title']),
                  subtitle:
                  Text('Quantity: $count\nRs ${product['price']}000'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.red),
                        onPressed: () {
                          ref
                              .read(cartProvider.notifier)
                              .removeFromCart(product);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: Colors.green),
                        onPressed: () {
                          ref
                              .read(cartProvider.notifier)
                              .addToCart(product);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Button,
          ),
        ],
      ),
    );
  }
}

