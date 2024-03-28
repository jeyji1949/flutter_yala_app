import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function()? onTap;

  const CustomButton({
    Key? key,
    required this.onTap,
    required Center child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: MaterialButton(
          elevation: 10,
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          color: const Color(0xff6369D1),
          onPressed: onTap, // Use onPressed property
        ),
      ),
    );
  }
}
