import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductSelectionNotifier extends StateNotifier<Set<int>> {
  ProductSelectionNotifier() : super({});

  void toggleSelection(int index) {
    if (state.contains(index)) {
      state = {...state}..remove(index); // Remove the index
    } else {
      state = {...state}..add(index); // Add the index
    }
  }
}

// Define providers for both lists
final firstHalfSelectionProvider =
    StateNotifierProvider<ProductSelectionNotifier, Set<int>>(
        (ref) => ProductSelectionNotifier());

final secondHalfSelectionProvider =
    StateNotifierProvider<ProductSelectionNotifier, Set<int>>(
        (ref) => ProductSelectionNotifier());

class CartNotifier extends StateNotifier<Map<dynamic, int>> {
  CartNotifier() : super({});

  void addToCart(dynamic product) {
    if (state.containsKey(product)) {
      state = {...state, product: state[product]! + 1};
    } else {
      state = {...state, product: 1};
    }
  }

  void removeFromCart(dynamic product) {
    if (state.containsKey(product)) {
      final currentCount = state[product]!;
      if (currentCount > 1) {
        state = {...state, product: currentCount - 1};
      } else {
        state = {...state}..remove(product);
      }
    }
  }

  int getItemCount(dynamic product) {
    return state[product] ?? 0;
  }

  int get totalItemCount => state.values.fold(0, (sum, count) => sum + count);
}

final cartProvider = StateNotifierProvider<CartNotifier, Map<dynamic, int>>(
  (ref) => CartNotifier(),
);
