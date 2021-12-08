library flutter_swish_payment;

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:math';

enum ButtonTypes {
  textButton,
  elevatedButton,
}

enum LogoTypes {
  primary,
  secondary,
}

Random random = Random();

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

/// # Swish Payment Data
///
/// A class for representing all data used in a Swish payment request.
/// [payeeAlias], [amount], [currency], and [callbackUrl] are all
/// required and mustn’t be null
///
/// [payerAlias], [payeePaymentReference], [payerSSN], and [ageLimit]
/// are all optional. **Use only if you know what you are doing!**
///
/// [message] is also optional but is recommended.
class SwishPaymentData {
  const SwishPaymentData({
    required this.payeeAlias,
    required this.amount,
    required this.currency,
    required this.callbackUrl,
    this.payeePaymentReference,
    this.payerAlias,
    this.payerSSN,
    this.ageLimit,
    this.message,
  });

  /// The Swish number of the payee. It needs to match with Merchant
  /// Swish number.
  final String payeeAlias;

  /// The amount of money to pay. The amount cannot be less than
  /// 0.01 SEK and not more than 999999999999.99 SEK. Valid value
  /// has to be all digits or with 2 digit decimal separated with a period.
  final String amount;

  /// The currency to use. Currently the only supported value is `'SEK'`.
  final String currency;

  /// URL that Swish will use to notify caller about the result of the
  /// payment request. The URL has to use HTTPS.
  final String callbackUrl;

  /// Payment reference supplied by theMerchant. This is not used
  /// by Swish but is included in responses back to the client.
  /// This reference could for example be an order id or similar.
  /// If set the value must not exceed 35 characters and only
  /// the following characters are allowed: [a-ö, A-Ö, 0-9, -]
  final String? payeePaymentReference;

  /// The registered Cell phone number of the person that makes the
  /// payment. It can only contain numbers and has to be at least 8
  /// and at most 15 digits. It also needs to match the following
  /// format in order to be found in Swish: `country code + cell
  /// phone number (without leading zero)`. E.g.: 46712345678 If
  /// set, request is handled as E-Commerce payment. If not set,
  /// request is handled as M- Commerce payment
  final String? payerAlias;

  /// The social security number of the individual making the
  /// payment, should match the registered value for payerAlias
  /// or the payment will not be accepted. The value should
  /// be a proper Swedish social security number (personnummer
  /// or sammordningsnummer). Note: Since MSS is a stand-alone
  /// test system it can not verify if payerSSN match registered
  /// value for payerAlias.
  final String? payerSSN;

  /// Minimum age (in years) that the individual connected to
  /// the payerAlias has to be in order for the payment to be
  /// accepted. Value has to be in the range of 1 to 99. Note:
  /// Since MSS is a stand-alone test system it can not verify
  /// the payerAlias age against the ageLimit value.
  final String? ageLimit;

  /// Merchant supplied message about the payment/order. Max
  /// 50 characters. Allowed characters are the letters a-ö,
  /// A-Ö, the numbers 0-9 and any of the special characters
  /// :;.,?!()-”.
  final String? message;

  /// Convert [SwishPaymentData] into a JSON object.
  Map<String, dynamic> toJson() => {
        'payeeAlias': payeeAlias,
        'amount': amount,
        'currency': currency,
        'callbackUrl': callbackUrl,
        'payeePaymentReference': payeePaymentReference,
        'payerAlias': payerAlias,
        'payerSSN': payerSSN,
        'ageLimit': ageLimit,
        'message': message,
      };
}

/// # Swish Agent
///
/// Handles Public key infrastructure (PKI). Must be initialized
/// with the organization’s Swish certificate, key, and certificate
/// authority.
///
/// It is important that it is ensured that everything has been
/// loaded before calling [SwishAgent.initializeAgent]. This is
/// preferably done using:
/// ```dart
/// WidgetsFlutterBinding.ensureInitialized();
/// ```
/// This sample demonstrates how to initialize a SwishAgent using **test** PKI
/// files.
/// ```dart
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   ByteData cert =
///     await rootBundle.load('assets/swish_merchant_test_certificate.pem');
///   ByteData key =
///     await rootBundle.load('assets/swish_merchant_test_certificate.key');
///   ByteData ca = await rootBundle.load('assets/swish_TLS_root_CA.pem');
///   String credential = "swish";
///
///   SwishAgent swishAgent = SwishAgent.initializeAgent(
///     cert: cert,
///     key: key,
///     ca: ca,
///     credential: credential,
///   );
///
///   SwishClient swishClient = SwishClient(
///     swishAgent: swishAgent,
///   );
///   runApp(
///     FlutterSwishPaymentDemo(
///       swishClient: swishClient,
///     ),
///   );
///}
/// ```
// ignore: todo
/// TODO: Initialize PKI members using more than project assets.
///
/// For more info about PKI:
/// > - https://developer.swish.nu/documentation/getting-started/swish-commerce-api
/// > - https://en.wikipedia.org/wiki/Public_key_infrastructure
class SwishAgent {
  /// Create an instance of `SwishAgent`, all parameters mustn’t be null.
  const SwishAgent.initializeAgent({
    required ByteData key,
    required ByteData ca,
    required ByteData cert,
    required String credential,
  })  : _cert = cert,
        _key = key,
        _ca = ca,
        _credential = credential;

  /// Certificate **(.pem file)**
  /// This file should be well protected in your project!
  final ByteData _cert;

  /// Key for reading the Certificate [_cert] **(.key file)**
  /// This file should be well protected in your project!
  final ByteData _key;

  /// Certificate authority **(.pem file)**
  /// This file should be well protected in your project!
  final ByteData _ca;

  /// The credentials for reading certificate files.
  final String _credential;

  /// Get the security context based on the provided certificates.
  SecurityContext get securityContext {
    SecurityContext context = SecurityContext.defaultContext;
    context.useCertificateChainBytes(
      _cert.buffer.asUint8List(),
      password: _credential,
    );
    context.usePrivateKeyBytes(
      _key.buffer.asUint8List(),
      password: _credential,
    );
    return context;
  }

  /// Get a random 32 hexadecimal UUID (Universally unique identifier).
  /// While it is random, a collision is extremely unlikely. The number
  /// of random UUIDs which need to be generated in order to have a
  /// 50% probability of at least one collision is 2.71 quintillion…
  String get instructionUUID {
    int length = 32;
    const String chars = '0123456789ABCDEF';
    String hex = '';
    while (length-- > 0) {
      hex += chars[(random.nextInt(16)) | 0];
    }
    return hex;
  }
}

class SwishPaymentRequest {
  const SwishPaymentRequest({
    this.paymentRequestToken,
    required this.location,
    required this.statusCode,
    this.validationErrorCode,
  });

  /// When creating a m-commerce payment request Swish will return a
  /// `paymentRequestToken`. This is then used to open the Swish app.
  /// An e-commerce payment request will not contain a `paymentRequestToken`.
  final String? paymentRequestToken;

  /// An URL for retrieving the status of the payment request.
  final String? location;

  /// HTTP response status codes responsible for indicating whether the
  /// Swish request has been successfully completed or not. Possible status
  /// codes are:
  /// - **201 Created** Payment request was successfully created.
  /// [SwishPaymentRequest] will contain a [location] and if it is Swish
  /// m-commerce case, it will also have a [paymentRequestToken].
  /// - **400 Bad Request** The Create Payment Request operation was malformed.
  /// [location] and [paymentRequestToken] will be null.
  /// - **401 Unauthorized** There are authentication problems with the
  /// certificate. Or the Swish number in the certificate is not enrolled.
  /// [location] and [paymentRequestToken] will be null.
  /// - **403 Forbidden** The payeeAlias in the payment request object is
  /// not the same as merchant’s Swishnumber. [location] and
  /// [paymentRequestToken] will be null.
  /// - **415 Unsupported Media Type** The Content-Type header is not
  /// "application/json". [location] and [paymentRequestToken] will be null.
  /// - **422 Unprocessable Entity** There are validation errors. Will
  /// return an array of Error objects. [location] and [paymentRequestToken]
  /// will be null.
  /// - **500 Internal Server Error** There was some unknown/unforeseen error
  /// that occurred on the server, this should normally not happen.
  /// [location] and [paymentRequestToken] will be null.
  final int statusCode;

  final String? validationErrorCode;
}

/// # Swish Client
///
/// Handles communication to the Swish API. Must be created with
/// a [SwishAgent] which provides the [SwishClient] with necessary
/// security context.
class SwishClient {
  /// Create a [SwishClient] instance.
  SwishClient({
    required this.swishAgent,
  }) : _httpClient = HttpClient(context: swishAgent.securityContext);

  final SwishAgent swishAgent;
  final HttpClient _httpClient;

  /// A payment request is a transaction sent from a merchant to the
  /// Swish system to initiate an e-commerce or m-commerce payment.
  Future<SwishPaymentRequest> createPaymentRequest({
    required SwishPaymentData swishPaymentData,
  }) async {
    HttpClientRequest request = await _httpClient.putUrl(
      Uri.parse(
        'https://mss.cpc.getswish.net/swish-cpcapi/api/v2/paymentrequests/' +
            swishAgent.instructionUUID,
      ),
    );
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    // Write the data to the request
    request.write(
      json.encode(
        swishPaymentData.toJson(),
      ),
    );
    HttpClientResponse response = await request.close();
    String? paymentRequestToken = response.headers.value('paymentrequesttoken');
    String? location = response.headers.value('location');

    return SwishPaymentRequest(
      location: location,
      statusCode: response.statusCode,
      paymentRequestToken: paymentRequestToken,
    );
  }

  /// # Open Swish
  ///
  /// Open Swish on mobile with the payment information in [SwishPaymentRequest]
  /// ready for the user to be paid.
  /// ---
  /// ## Running on Android 11 and later
  /// When on Android 11 and later [openSwish] needs to declare intent to open
  /// Swish in `AndroidManifest.xml`. Add the following in `<queries> … </queries>`
  /// (if no queries section is present, create it inside of `manifest`).
  /// ```xml
  /// <intent>
  ///   <action android:name="android.intent.action.VIEW" />
  ///   <data android:scheme="swish" />
  /// </intent>
  /// ```
  ///
  /// The end result should look something like this:
  ///
  /// ```xml
  /// <manifest>
  ///   <application>
  ///     ...
  ///   </application>
  ///   <queries>
  ///     <!-- Open swish -->
  ///     <intent>
  ///       <action android:name="android.intent.action.VIEW" />
  ///       <data android:scheme="swish" />
  ///     </intent>
  ///   </queries>
  /// </manifest>
  /// ```
  /// Learn more at:
  /// > - https://medium.com/androiddevelopers/package-visibility-in-android-11-cc857f221cd9
  /// > - https://pub.dev/packages/url_launcher
  Future<void> openSwish({
    required SwishPaymentRequest swishPaymentRequest,
  }) async {
    String callbackURL = 'merchant_flutter_callbackUrl_example';
    String openSwishUrl = 'swish://paymentrequest?token=' +
        swishPaymentRequest.paymentRequestToken.toString() +
        '&callbackurl=' +
        callbackURL;
    if (await canLaunch(openSwishUrl)) {
      await launch(openSwishUrl);
    } else {
      throw 'Could not launch Swish';
    }
  }
}
