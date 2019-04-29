# pm_curve25519_example

Demonstrates how to use the pm_curve25519 plugin.

## Getting Started

```dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pm_curve25519/pm_curve25519.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pm_curve25519plugin',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.lightBlue,
        accentColorBrightness: Brightness.light
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('PmCurve25519');
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('pm_curve25519 test'),
        centerTitle: true,
      ),
      body: testCrypto(context),
    );
  }
  Uint8List publicKey;
  Uint8List _secret;
  Uint8List secretKey;
  Uint8List _signature;
  bool _valid;

  Widget testCrypto(BuildContext context){
   // print(publicKey.lengthInBytes);
   // print(secretKey.lengthInBytes);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: <Widget>[
        FlatButton(
          child: const Text('Press to generate curve25519 key-pair'),
          onPressed: _getKeyPair,
          color: Colors.blue,
        ),
        Text('Public key:\n$publicKey'),
        Text('Secret Key or Pair:\n$secretKey'),
        FlatButton(
          child: const Text('Get shared secret'),
          onPressed: _getSecret,
          color: Colors.blue,
        ),
        Text('Shared secret:\n$_secret'),
        FlatButton(
          child: const Text('Get Signature'),
          onPressed: _getSignature,
          color: Colors.blue,
        ),
        Text('signature:\n$_signature'),
        FlatButton(
          child: const Text('Verify signature'),
          onPressed: _verifySignature,
          color: Colors.blue,
        ),
        Text('Is valid signature?:\n$_valid'),    
        const Padding(
          padding: const EdgeInsets.all(30.0),
        )                 
      ],
    );
  }
  Future<void> _getSecret() async {
    Uint8List sharedSecret = await PmCurve25519.getSharedSecret(publicKey, secretKey);

    setState(() {
      _secret = sharedSecret; 
    });
  }
  Future<void> _getKeyPair() async {
    PmKeyPair getPair = await PmCurve25519.generateIdentityPair();
    setState(() {
     publicKey = getPair.publicKey;
     secretKey = getPair.secretKey;
    });
  }
  Future<void> _getSignature()async {
    String fakeMessage = "Hello world";
    Uint8List message = Uint8List.fromList(fakeMessage.codeUnits);
    Uint8List signature = await PmCurve25519.getSignature(message, secretKey);
    setState(() {
      _signature = signature;
    });
  }
  Future<void> _verifySignature()async {
    String fakeMessage = "Hello world";
    Uint8List message = Uint8List.fromList(fakeMessage.codeUnits);
    bool valid = await PmCurve25519.verifySignature(publicKey, message, _signature);
    setState(() {
      _valid = valid;
    });
  }
 }

```