library flutter_swish_payment;

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
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
  /// ![Swish Primary Logo](https://github.com/johanehinger/flutter_swish_payment/blob/main/images/swish_logo_primary_RGB.png?raw=true|width=200,height=250)
  const SwishButton.primaryElevatedButton({
    Key? key,
    required this.onPressed,
    this.style,
  })  : buttonType = ButtonTypes.elevatedButton,
        logo = LogoTypes.primary,
        super(key: key);

  /// Create an text button with the primary logo of Swish.
  ///
  /// ![Swish Primary Logo](https://github.com/johanehinger/flutter_swish_payment/blob/main/images/swish_logo_primary_RGB.png?raw=true|width=200,height=250)
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

/// # Swish Payment Request
///
/// A transaction sent from a merchant to the Swish system to initiate an
/// payment.
class SwishPaymentRequest {
  /// Create a [SwishPaymentRequest] instance
  const SwishPaymentRequest({
    required this.statusCode,
    this.id,
    this.location,
    this.payeePaymentReference,
    this.paymentReference,
    this.callbackUrl,
    this.payerAlias,
    this.payeeAlias,
    this.amount,
    this.currency,
    this.message,
    this.status,
    this.dateCreated,
    this.datePaid,
    this.errorCode,
    this.errorMessage,
  });

  /// The status code of the payment request. This will contain
  /// information about the status of the communication with Swish.
  /// It follows basic http status codes.
  final int statusCode;

  /// Payment request ID.
  final String? id;

  /// An URL for retrieving the payment request.
  final String? location;

  /// Payment reference of the payee, wich is the merchant that receives
  /// the payment. This reference could be order id or similar. Allowed
  /// characters are a-z A-Z 0-9 -_.+*/ and lenght must be between 1
  /// and 35 characters.
  final String? payeePaymentReference;

  /// Payment reference, from the bank, of the payment that occurred
  /// based on the Payment request. Only available if status is PAID.
  final String? paymentReference;

  /// URL that Swish will use to notify caller about the outcome of
  /// the Payment request. The URL has to use HTTPS.
  final String? callbackUrl;

  /// The registered cellphone number of the person that makes the
  /// payment. It can only contain numbers and has to be at least
  /// 8 and at most 15 numbers. It also needs to match the following
  /// format in order to be found in Swish: country code + cellphone
  /// number (without leading zero). E.g. 46712345678
  final String? payerAlias;

  /// The Swish number of the payee. It needs to match with Merchant
  /// Swish number.
  final String? payeeAlias;

  /// The amount of money to pay. The amount cannot be less than 0.01
  /// SEK and not more than 999999999999.99 SEK. Valid value has to
  /// be all digits or with 2 digit decimal separated with a period.
  final double? amount;

  /// The currency to use. Currently the only supported value is SEK.
  final String? currency;

  /// Merchant supplied message about the payment/order. Max 50
  /// characters. Allowed characters are the letters a-ö, A-Ö, the
  /// numbers 0-9 and any of the special characters :;.,?!()-”.
  final String? message;

  /// The status of the payment request.
  final String? status;

  /// The Creation date of the payment request. This will be the date
  /// and time Swish received the payment request.
  final String? dateCreated;

  /// The exact time the payment request got paid.
  final String? datePaid;

  /// The error code received by Swish.
  final String? errorCode;

  /// Additional information regarding any potential errors received
  /// from Swish while handling the payment request.
  final String? errorMessage;

  /// Create an instance of [SwishPaymentRequest] from a JSON object.
  factory SwishPaymentRequest.fromJson({
    required Map<String, dynamic> json,
    required int statusCode,
    required String? location,
  }) {
    return SwishPaymentRequest(
      statusCode: statusCode,
      id: json['id'],
      location: location,
      payeePaymentReference: json['payeePaymentReference'],
      paymentReference: json['paymentReference'],
      callbackUrl: json['callbackUrl'],
      payerAlias: json['payerAlias'],
      payeeAlias: json['payeeAlias'],
      amount: json['amount'],
      currency: json['currency'],
      message: json['message'],
      status: json['status'],
      dateCreated: json['dateCreated'],
      datePaid: json['datePaid'],
      errorCode: json['errorCode'],
      errorMessage: json['errorMessage'],
    );
  }

  /// Create an instance of [SwishPaymentRequest] when something went
  /// wrong. Will set everything to null except `statusCode`,
  /// `errorCode`, `errorMessage` and `status`.
  factory SwishPaymentRequest.fromError({
    required int statusCode,
    required String errorCode,
    required String errorMessage,
  }) {
    return SwishPaymentRequest(
      statusCode: statusCode,
      id: null,
      location: null,
      payeePaymentReference: null,
      paymentReference: null,
      callbackUrl: null,
      payerAlias: null,
      payeeAlias: null,
      amount: null,
      currency: null,
      message: null,
      status: 'ERROR',
      dateCreated: null,
      datePaid: null,
      errorCode: errorCode,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    return '{ statusCode: ' +
        statusCode.toString() +
        ', id: ' +
        id.toString() +
        ', location: ' +
        location.toString() +
        ', payeePaymentReference: ' +
        payeePaymentReference.toString() +
        ', paymentReference: ' +
        paymentReference.toString() +
        ', callbackUrl: ' +
        callbackUrl.toString() +
        ', payerAlias: ' +
        payerAlias.toString() +
        ', payeeAlias: ' +
        payeeAlias.toString() +
        ', amount: ' +
        amount.toString() +
        ', currency: ' +
        currency.toString() +
        ', message: ' +
        message.toString() +
        ', status: ' +
        status.toString() +
        ', dateCreated: ' +
        dateCreated.toString() +
        ', datePaid: ' +
        datePaid.toString() +
        ', errorCode: ' +
        errorCode.toString() +
        ', errorMessage: ' +
        errorMessage.toString() +
        ' }';
  }
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
  }) : _httpClient = IOClient(
          HttpClient(
            context: swishAgent.securityContext,
          ),
        );

  /// [SwishAgent] that handles internal security.
  final SwishAgent swishAgent;

  final http.Client _httpClient;

  /// A payment request is a transaction sent from a merchant to the
  /// Swish system to initiate an e-commerce or m-commerce payment.
  Future<SwishPaymentRequest> createPaymentRequest({
    required SwishPaymentData swishPaymentData,
  }) async {
    http.Response response = await _httpClient.put(
      Uri.parse(
        'https://mss.cpc.getswish.net/swish-cpcapi/api/v2/paymentrequests/' +
            swishAgent.instructionUUID,
      ),
      headers: {
        'Content-type': 'application/json',
      },
      body: json.encode(
        swishPaymentData.toJson(),
      ),
    );

    if (response.headers['location'] != null) {
      return await getPaymentRequest(location: response.headers['location']!);
    }

    List<dynamic> responseBody = jsonDecode(
      utf8.decode(
        response.bodyBytes,
      ),
    ) as List<dynamic>;

    Map<String, dynamic> errorInformation =
        responseBody[0] as Map<String, dynamic>;
    return SwishPaymentRequest.fromError(
      statusCode: response.statusCode,
      errorCode: errorInformation['errorCode'],
      errorMessage: errorInformation['errorMessage'],
    );
  }

  /// Get the payment request from Swish. Will contain information about the status
  /// of the payment request in JSON format.
  /// (**Unstable and under development**)
  Future<SwishPaymentRequest> getPaymentRequest({
    required String location,
  }) async {
    http.Response response = await _httpClient.get(
      Uri.parse(location),
    );

    SwishPaymentRequest swishPaymentRequest = SwishPaymentRequest.fromJson(
      json: jsonDecode(
        utf8.decode(
          response.bodyBytes,
        ),
      ) as Map<String, dynamic>,
      location: location,
      statusCode: response.statusCode,
    );

    return swishPaymentRequest;
  }

  /// # Open Swish
  ///
  /// (**Unstable and under development**)
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
        swishPaymentRequest.id.toString() +
        '&callbackurl=' +
        callbackURL;
    if (await canLaunch(openSwishUrl)) {
      await launch(openSwishUrl);
    } else {
      throw 'Could not launch Swish';
    }
  }
}
