library flutter_swish_payment;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ButtonTypes {
  textButton,
  elevatedButton,
}

enum LogoTypes {
  primary,
  secondary,
}

/// # A Material Design "Swish button"
///
/// When adding Swish widgets to the UI, special care should be taken to
/// the official [Swish design guide](https://developer.swish.nu/documentation/guidelines).
/// The `SwishButton` already follows the official style guide provided
/// by Swish and should not be styled further! If necessary, the design
/// can be overridden with its [style] parameter.
///
/// ## Swish elevated button
/// Use Swish elevated buttons to add dimension to otherwise mostly flat
/// layouts, e.g.  in long busy lists of content, or in wide
/// spaces. Avoid using Swish elevated buttons on already-elevated content
/// such as dialogs or cards.
///
/// ## Swish text button
/// Use Swish text buttons on toolbars, in dialogs, or inline with other
/// content but offset from that content with padding so that the
/// button's presence is obvious. Swish text buttons do not have visible
/// borders and must therefore rely on their position relative to
/// other content for context. In dialogs and cards, they should be
/// grouped together in one of the bottom corners. Avoid using Swish text
/// buttons where they would blend in with other content, for example
/// in the middle of lists.
///
/// ## General information
///
/// If [onPressed] callback is null, then the
/// button will be disabled.
///
///
/// This sample produces a `SwishButton.secondaryElevatedButton` and a
/// `SwishButton.secondaryTextButton`.
///
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return Center(
///     child: Column(
///       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
///       children: <Widget>[
///         SwishButton.secondaryElevatedButton(
///           onPressed: () {},
///         ),
///         SwishButton.secondaryTextButton(
///           onPressed: () {},
///         ),
///       ],
///     ),
///   );
/// }
///
/// ```
///
/// See also:
/// > - https://github.com/johanehinger/flutter_swish_payment
/// > - https://developer.swish.nu/
class SwishButton extends StatelessWidget {
  /// Create an elevated button with the primary logo of Swish.
  ///
  const SwishButton.primaryElevatedButton({
    Key? key,
    required this.onPressed,
    this.style,
  })  : buttonType = ButtonTypes.elevatedButton,
        logo = LogoTypes.primary,
        super(key: key);

  /// Create an text button with the primary logo of Swish.
  ///
  const SwishButton.primaryTextButton({
    Key? key,
    required this.onPressed,
    this.style,
  })  : buttonType = ButtonTypes.textButton,
        logo = LogoTypes.primary,
        super(key: key);

  /// Create an elevated button with the secondary logo of Swish.
  ///
  /// ![Swish Secondary Logo](https://github.com/johanehinger/flutter_swish_payment/blob/main/images/swish_logo_secondary_RGB.png?raw=true|width=250,height=75)
  const SwishButton.secondaryElevatedButton({
    Key? key,
    required this.onPressed,
    this.style,
  })  : buttonType = ButtonTypes.elevatedButton,
        logo = LogoTypes.secondary,
        super(key: key);

  /// Create an text button with the secondary logo of Swish.
  ///
  /// ![Swish Secondary Logo](https://github.com/johanehinger/flutter_swish_payment/blob/main/images/swish_logo_secondary_RGB.png?raw=true|width=250,height=75)
  const SwishButton.secondaryTextButton({
    Key? key,
    required this.onPressed,
    this.style,
  })  : buttonType = ButtonTypes.textButton,
        logo = LogoTypes.secondary,
        super(key: key);

  final ButtonStyle? style;
  final VoidCallback? onPressed;
  final ButtonTypes buttonType;
  final LogoTypes logo;

  @override
  Widget build(BuildContext context) {
    Image _logo;
    switch (logo) {
      case LogoTypes.primary:
        _logo = const Image(
          image: AssetImage(
            'images/swish_logo_primary_RGB.png',
            package: 'flutter_swish_payment',
          ),
        );
        break;
      case LogoTypes.secondary:
        _logo = const Image(
          fit: BoxFit.fitWidth,
          image: AssetImage(
            'images/swish_logo_secondary_RGB.png',
            package: 'flutter_swish_payment',
          ),
        );
        break;
    }

    ButtonStyle _style = style ??
        ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Colors.white,
          ),
          overlayColor: MaterialStateProperty.all(
            Colors.grey[100],
          ),
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.all(8.0),
          ),
        );

    switch (buttonType) {
      case ButtonTypes.elevatedButton:
        return ElevatedButton(
          onPressed: onPressed,
          child: _logo,
          style: _style,
        );
      case ButtonTypes.textButton:
        return TextButton(
          onPressed: onPressed,
          child: _logo,
          style: _style,
        );
    }
  }
}
