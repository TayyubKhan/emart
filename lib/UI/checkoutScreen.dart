import 'package:credit_app/Model/UserModel.dart';
import 'package:credit_app/UI/paymentSelectionScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import '../components/TextFormField.dart';
import 'CardDetailScreen.dart';

class CheckoutScreen extends StatefulWidget {
  CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool showError = false;

  String text2 = '';

  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final numberController = TextEditingController();

  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your details:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                // Full Name field
                _buildInputField(
                    label: 'Full Name',
                    hint: 'e.g., Ramesh Kumar',
                    controller: nameController),
                const SizedBox(height: 20),
                // Mobile Number field
                CustomTextFormField(
                  showError: showError,
                  controller: numberController,
                  labelText: 'Mobile Number*',
                  hintText: 'Enter Your Mobile Number',
                  keyboardType: TextInputType.phone,
                  onSaved: (value) {},
                  maxLength: 10,
                  icon: showError
                      ? JustTheTooltip(
                          isModal: true,
                          shadow: const Shadow(color: Colors.grey),
                          tailBuilder:
                              JustTheInterface.defaultBezierTailBuilder,
                          content: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(text2),
                          ),
                          child: const Material(
                            color: Colors.transparent,
                            elevation: 0,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  onChanged: (String? newValue) {
                    // setState(() {
                    //   showError = false;
                    // });
                  },
                ),
                const SizedBox(height: 20),
                // Email field
                _buildInputField(
                  label: 'Email',
                  hint: 'e.g., example@mail.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                ),
                const SizedBox(height: 20),

                // Delivery Address field (Minimum 5 lines)
                _buildInputField(
                  label: 'Delivery Address',
                  hint: 'e.g., 15 MG Road, Bengaluru, Karnataka',
                  minLines: 5,
                  controller: addressController,
                ),
                const SizedBox(height: 20),

                // Submit Button
                Consumer(builder: (context, ref, _) {
                  return Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          ref.read(userProvider.notifier).state = UserModel(
                              name: nameController.text,
                              email: emailController.text,
                              mobileNumber: numberController.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PaymentSelectionScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Submit Details',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int minLines = 1,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: minLines > 1 ? null : 1,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $label.';
            }
            if (label == 'Mobile Number' &&
                !RegExp(r'^\d{10}$').hasMatch(value)) {
              return 'Please enter a valid Mobile Number.';
            }
            if (label == 'Email' &&
                !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                    .hasMatch(value)) {
              return 'Please enter a valid Email.';
            }
            return null;
          },
        ),
      ],
    );
  }
}
