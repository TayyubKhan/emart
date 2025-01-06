import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class CustomTextFormField extends StatefulWidget {
  final int maxLength;
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final TextEditingController controller;
  final Widget icon;
  List<TextInputFormatter> inputFormater;
  final FormFieldSetter<String> onChanged;
  CustomTextFormField({
    super.key,
    this.inputFormater=const [],
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    this.validator,
    this.onSaved,
    required this.onChanged,
    this.maxLength = 50,
    required this.controller,
    required this.showError,
    required this.icon,
  });
  bool showError = false;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
        ),
        const Gap(5),
        SizedBox(
          height: 50,
          child: TextFormField(
            inputFormatters: widget.inputFormater,
            onChanged: widget.onChanged,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 15),
            controller: widget.controller,
            maxLength: widget.maxLength,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              suffixIcon: widget.icon,
              counterText: '',
              label: Text(
                widget.hintText,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 15),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Colors.grey)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Colors.black)),
              hintText: widget.hintText,
            ),
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onSaved: widget.onSaved,
          ),
        ),
      ],
    );
  }
}
