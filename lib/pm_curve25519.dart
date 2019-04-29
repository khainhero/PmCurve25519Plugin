import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/services.dart';
///secret-key and public-key in Uint8List type. On iOS, secret-key is the pair itself.
class PmKeyPair {
  final Uint8List publicKey, secretKey;

  const PmKeyPair(this.publicKey, this.secretKey);

  PmKeyPair.fromMap(Map<String, Uint8List> map) : this(map['publicKey'], map['secretKey']);

}
///Generate key-pair from curve25519. Sign messages and/or other keys utilizing ed25519. Verify signature with public-key.
class PmCurve25519 {
  static const MethodChannel _platform = const MethodChannel('PmCurve25519');
  
  ///Returns key-pair with public-key and secret-key. On iOS the secret-key is the pair itself which you can use for signing or computing a secret as if its a secret-key.
  //
  ///The iOS key-pair is encoded using NSKeyedArchiver on its respective platform. So thus it is a very long byte sequence so please take note of its length.
  static Future<PmKeyPair> generateIdentityPair() async {
    try {
      final Map result = await _platform.invokeMethod('getKeyPair');
      return PmKeyPair.fromMap(result.cast<String, Uint8List>());
    } on PlatformException catch (e){
      print(e.message);
      return null;
    }
  }
  ///Compute a shared-secret between 2 users. Requires the other users public-key and your private-key or key-pair if on iOS.
  static Future<Uint8List> getSharedSecret(Uint8List otherPublicKey, Uint8List mySecret) async {
    if(null == otherPublicKey || null == mySecret){
      return null;
    }
    try {
      final Uint8List result = await _platform.invokeMethod('getSecret', <String, dynamic>{
        'publicKey': otherPublicKey,
        'keyPair': mySecret,
      });
      return result;
    } on PlatformException catch (e) {
      print(e.message);
      return null;
    }
  }
  ///Calculate a signature with your secret-key or key-pair if you are on iOS. Sign a message of type Uint8List.
  static Future<Uint8List> getSignature(Uint8List message, Uint8List mySecret) async {
    if(null == message || null == mySecret){
      return null;
    }
    try {
      final Uint8List result = await _platform.invokeMethod('getSignature', <String, dynamic>{
        'message': message,
        'keyPair': mySecret
      });
      return result;
    } on PlatformException catch(e) {
      print(e.message);
      return null;
    }
  }
  ///Verify a signature. Requires your public-key, the message and the signature which was computed with the public-key's secret.
  static Future<bool> verifySignature(Uint8List publicKey, Uint8List message, Uint8List signature) async {
    if(null == publicKey || null == message || null == signature){
      return null;
    }
    try {
      final bool result = await _platform.invokeMethod('verifySignature', <String, dynamic>{
        'publicKey': publicKey,
        'message': message,
        'signature': signature,
      });
      return result;
    } on PlatformException catch(e){
      print(e.message);
      return null;
    }
  }
}