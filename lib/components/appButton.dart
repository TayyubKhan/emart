import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Container(
          width: width * 0.75,
          height: height * 0.09,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.black,
          ),
          child: Center(
              child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 19, fontWeight: FontWeight.w400),
          )),
        ),
      ),
    );
  }
}

class AppButton2 extends StatelessWidget {
  const AppButton2(
      {super.key,
      required this.title,
      required this.onTap,
      required this.imagePath});
  final String title;
  final VoidCallback onTap;
  final String imagePath;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Container(
          width: width * 0.75,
          height: height * 0.09,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xff75dced).withOpacity(0.7),
          ),
          child: Center(
            child: Image(
              fit: BoxFit.fitHeight,
              image: AssetImage(imagePath),
              width: width * 0.75,
              height: height * 0.09,
            ),
          ),
        ),
      ),
    );
  }
}
