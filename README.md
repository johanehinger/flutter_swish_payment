<p align="center">
<a href="https://www.swish.nu/"><img src="https://github.com/johanehinger/flutter_swish_payment/blob/main/images/swish_logo_secondary_RGB.png?raw=true" height="150" alt="Swish" /></a>
</p>

# flutter_swish_payment

A widget and functions library for the Swedish payment service Swish.

## What is Swish?

Swish is a mobile payment system in Sweden. The service works through a smartphone application, through which the user's phone number is connected to their bank account, and which makes it possible to transfer money in real time.
Learn more at [Swish](https://www.swish.nu/).

## Usage

After installing and importing flutter_swish_payment, follow these steps to start using it:

1. Get the Swish certificates for your organization either from the [Swish Company Portal](https://portal.swish.nu/company/login?redirectPath=%2Fcompany%2Fcertificates) or from your internal organization. If you are developing a private project and want to test around in the Swish environment, Swish provides downloadable test certificates on their [environments page](https://developer.swish.nu/documentation/environments).
2. Initialize a `SwishAgent` with the certificates. This could be done directly in the main function. (Be careful about how you store your certificates!)

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ByteData cert = await rootBundle.load(
    'assets/swish_certificate.pem',
  );
  ByteData key = await rootBundle.load(
    'assets/swish_certificate.key',
  );

  String credential = "passwordForCertificates";

  SwishAgent swishAgent = SwishAgent.initializeAgent(
    cert: cert,
    key: key,
    credential: credential,
  );
  ...
}
```

3. Create a `SwishClient` and provide it the `SwishAgent`.

```dart
SwishClient swishClient = SwishClient(
  swishAgent: swishAgent,
);
```

4. You are now all set to start sending payment requests. Check out the documentation for `SwishClient` for guidance.

## Open Swish

Redirecting the user to the Swish app upon a payment request differs from device to device. Currently the only supported device is Android. Swish provides a `callbackUrl` and this can be used to navigate the user back to the app after a completed payment. For more details on how to navigate back to the app read this FAQ from Swish: [What is needed in order to get the user back to the original application?](https://developer.swish.nu/faq/what-is-needed-in-order-to-get-the-user-back-to-the-original-application)

### Android 11 and later

Declare intent to open Swish in `AndroidManifest.xml`. Add the following in `<queries> … </queries>` (if no queries section is present, create it inside of `manifest`).

```xml
<intent>
  <action android:name="android.intent.action.VIEW" />
  <data android:scheme="swish" />
</intent>
```

The end result should look something like this:

```xml
<manifest>
  <application>
    ...
  </application>
  <queries>
    <!-- Open Swish -->
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="swish" />
    </intent>
  </queries>
</manifest>
```

Learn more at:

> - [Package visibility in android 11](https://medium.com/androiddevelopers/package-visibility-in-android-11-cc857f221cd9)
> - [Intent](https://pub.dev/packages/intent)

## What is the future goal for flutter_swish_payment?

The goal is to have a full library covering everything from the Swish API. Everything from a Swish QR code widget, to managing refunds from your online store.

## Contributing

flutter_swish_payment is still in its early development. Help us out by reporting bugs, propose new features or even contribute with your own code on our [Github](https://github.com/johanehinger/flutter_swish_payment/). Together we can take this project to the next level and release a final version.

---

> ### Disclaimer
>
> As the project stands now, it has only been tested against the Merchant Swish Simulator (MMS). Before using this package for real transactions contact the [Swish team](https://developer.swish.nu/contact-us) for guidance.
