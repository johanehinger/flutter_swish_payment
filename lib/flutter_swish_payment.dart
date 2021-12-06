library flutter_swish_payment;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// SwishSecondaryElevatedButton
class SwishSecondaryElevatedButton extends StatelessWidget {
  final ButtonStyle? style;
  final VoidCallback? onPressed;
  const SwishSecondaryElevatedButton(
      {Key? key, required this.onPressed, this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style ??
          ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            overlayColor: MaterialStateProperty.all(Colors.grey[100]),
          ),
      child: const Image(
        image: AssetImage(
          'images/swish_logo_secondary_RGB.png',
          package: 'flutter_swish_payment',
        ),
      ),
    );
  }
}
