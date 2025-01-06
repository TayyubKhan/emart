import 'package:credit_app/Model/cardDetailSendModel.dart';
import 'package:credit_app/UI/checkoutScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Model/UserModel.dart';
import 'CardDetailScreen.dart';

class PaymentSelectionScreen extends ConsumerWidget {
  const PaymentSelectionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Payment Gateway',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your payment gateway:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Razorpay Option
            _buildPaymentOption(
              label: 'Razorpay',
              icon: Icons.account_balance_wallet,
              imageIcon: Image.asset(
                'Assets/payicon.png',
                width: 50,
              ),
              isImage: true,
              onTap: () {
                ref.read(paymentGateWayProvider.notifier).state = 'Razorpay';
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CardDetailsScreen()));
              },
            ),
            const SizedBox(height: 20),
            // Stripe Option
            _buildPaymentOption(
              label: 'Credit/Debit Card',
              icon: Icons.payment,
              onTap: () {
                ref.read(paymentGateWayProvider.notifier).state =
                    'Credit/Debit Card';
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CardDetailsScreen()));
              },
            ),
            const SizedBox(height: 20),
            // Net Banking Option (Disabled for now)
            _buildPaymentOption(
              label: 'Net Banking (Coming Soon)',
              icon: Icons.account_balance,
              isDisabled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String label,
    required IconData icon,
    Widget imageIcon = const SizedBox(),
    VoidCallback? onTap,
    bool isDisabled = false,
    bool isImage = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[300] : Colors.white,
          border: Border.all(
            color: isDisabled ? Colors.grey : Colors.black,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            !isImage
                ? Icon(icon,
                    size: 32, color: isDisabled ? Colors.grey : Colors.black)
                : imageIcon,
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDisabled ? Colors.grey : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final paymentGateWayProvider = StateProvider<String>((ref) => "false");

// StateProvider to manage UserModel
final userProvider = StateProvider<UserModel>((ref) {
  return UserModel(
    name: 'Default Name',
    email: 'default@example.com',
    mobileNumber: '1234567890',
  );
});
