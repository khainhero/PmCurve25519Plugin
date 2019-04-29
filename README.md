# pm_curve25519

- https://pub.dartlang.org/packages/pm_curve25519

Generate curve25519 key-pair. Sign messages with the same key-pair by translating the point curves to do ed25519 signing.

## Getting Started

```yml
dependencies:
  ...
  pm_curve25519: any
```

__Important:__ For iOS, manually update your podfile. Go into iOS folder in terminal and execute the command:

```pod install --repo-update```
    
## Usage example

```dart

import 'package:pm_curve25519/pm_curve25519.dart';
import 'dart:async';
import 'dart:typed_data';

//Generate curve25519 key-pair
PmKeyPair pair = await PmCurve25519.generateIdentityPair();

Uint8List publicKey = pair.publicKey;
Uint8List secretKey = pair.secretKey;
//on iOS, secret-key is actually an encoded object which is a key-pair. Treat it as if its a secret-key

print(publicKey);
//very lengthy on iOS(secret-key)
print(secretKey);


//Calculate signature with input Message and your secret-key
String msg = "Hello World";
//Convert msg string into uint8list type
Uint8List message = Uint8List.fromList(fakeMessage.codeUnits);
Uint8List signature = await PmCurve25519.getSignature(message, secretKey);
print(signature);

//verify signature
bool valid = await PmCurve25519.verifySignature(publicKey, message, signature);

assert(valid);
```

## Slight issues

The iOS secret-key is actually a pair itself. The pair is archived on the iOS platform native side and thus the byte array is actually very long compared to a normal 32 byte secret-key. 
Currently its about on average 355 bytes in output.

This shouldnt be an issue, just treat it as if its an secret-key.
Might be an issue storing this key-pair(secretKey) somewhere secure. 

## Source of the code

I have only just created an API because I couldnt find a package that would fully allow signing a message with your original curve25519 key-pair.

I have these as my sources:

For iOS:
- https://github.com/signalapp/Curve25519Kit

For android:
- https://github.com/signalapp/curve25519-java
