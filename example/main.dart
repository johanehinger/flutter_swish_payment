import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swish_payment/flutter_swish_payment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load all PKI files. These are test files from the Merchant Swish Simulator
  // that can be downloaded from Swish. Remember to store your files securely.
  ByteData cert = await rootBundle.load(
    'assets/Swish_Merchant_TestCertificate.pem',
  );
  ByteData key = await rootBundle.load(
    'assets/Swish_Merchant_TestCertificate.key',
  );

  // The password for the certificate files. Swish uses standard "swish" for the
  // test files. Store your private password securely.
  String credential = "swish";

  SwishAgent swishAgent = SwishAgent.initializeAgent(
    key: key,
    cert: cert,
    credential: credential,
  );

  SwishClient swishClient = SwishClient(
    swishAgent: swishAgent,
  );

  runApp(
    MyApp(
      swishClient: swishClient,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SwishClient swishClient;
  const MyApp({
    Key? key,
    required this.swishClient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Swish Payment Demo',
      home: HomePage(
        swishClient: swishClient,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final SwishClient swishClient;
  const HomePage({
    Key? key,
    required this.swishClient,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Create the payment data that should be paid and sent to the end Swish user.
  final SwishPaymentData swishPaymentData = const SwishPaymentData(
    payeeAlias: '1231181189',
    amount: '100',
    currency: 'SEK',
    callbackUrl: 'https://example.com/api/swishcb/paymentrequest',
    message: 'Kingston USB FLash drive 8 GB',
  );

  bool isWaiting = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isWaiting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Please open the Swish app.'),
                  SizedBox(
                    height: 12.0,
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            )
          : Center(
              child: SizedBox(
                width: 200,
                height: 75,
                child: SwishButton.secondaryElevatedButton(
                  onPressed: () async {
                    try {
                      // Create the payment requst
                      SwishPaymentRequest swishPaymentRequest =
                          await widget.swishClient.createPaymentRequest(
                        swishPaymentData: swishPaymentData,
                      );
                      // Ensure that the payment request is valid.
                      if (swishPaymentRequest.errorCode != null) {
                        throw Exception(swishPaymentRequest.errorMessage);
                      }
                      setState(() {
                        isWaiting = true;
                      });
                      // Wait until the Swish user receives the payment request and
                      // decides to either pay it or decline it. A timeout is also
                      // possible (the user does nothing).
                      swishPaymentRequest =
                          await widget.swishClient.waitForPaymentRequest(
                        location: swishPaymentRequest.location!,
                      );
                      setState(() {
                        isWaiting = false;
                      });
                      // The payment is now done (or failed).
                      // ignore: avoid_print
                      print(
                        swishPaymentRequest.toString(),
                      );
                    } catch (error) {
                      // ignore: avoid_print
                      print(
                        error.toString(),
                      );
                    }
                  },
                ),
              ),
            ),
    );
  }
}
