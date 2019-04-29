#import "PmCurve25519Plugin.h"
#import "Curve25519.h"
#import "Ed25519.h"

@implementation PmCurve25519Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"PmCurve25519"
            binaryMessenger:[registrar messenger]];
  PmCurve25519Plugin* instance = [[PmCurve25519Plugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
        __weak typeof(self) weakSelf = self;
        if([@"getKeyPair" isEqualToString:call.method]){
            NSDictionary *keyPair = [weakSelf getKeyPair];
            if(keyPair == nil){
                result([FlutterError errorWithCode:@"UNAVAILABLE" message:@"NULL" details:nil]);
            } else {
                result(keyPair);
                keyPair = nil;
            }
        } else if([@"getSecret" isEqualToString:call.method]){
            FlutterStandardTypedData *pubKey = call.arguments[@"publicKey"];
            FlutterStandardTypedData *keyPair = call.arguments[@"keyPair"];
            FlutterStandardTypedData *secret = [weakSelf getSecret:pubKey.data pair:keyPair.data];
            
            if(secret == nil){
                result([FlutterError errorWithCode:@"UNAVAILABLE" message:@"NULL" details:nil]);
            } else {
                result(secret);
            }
        } else if([@"getSignature" isEqualToString:call.method]){
            FlutterStandardTypedData *message = call.arguments[@"message"];
            FlutterStandardTypedData *keyPair = call.arguments[@"keyPair"];
            FlutterStandardTypedData *signature = [weakSelf getSignature:message.data pair:keyPair.data];
            if(signature == nil){
                result([FlutterError errorWithCode:@"UNAVAILABLE" message:@"NULL" details:nil]);
            } else {
                result(signature);
            }
        } else if([@"verifySignature" isEqualToString:call.method]){
            FlutterStandardTypedData *signature = call.arguments[@"signature"];
            FlutterStandardTypedData *publicKey = call.arguments[@"publicKey"];
            FlutterStandardTypedData *message = call.arguments[@"message"];
            NSNumber *valid = [weakSelf validSignature:signature.data pubKey:publicKey.data msg:message.data];
            if(valid == nil){
                result([FlutterError errorWithCode:@"UNAVALIBLE" message:@"NULL" details:nil]);
            }else {
                result(valid);
            }
                
        }
        
        else {
            result(FlutterMethodNotImplemented);
        }
}
- (NSDictionary*)getKeyPair {
    ECKeyPair *key2 = [Curve25519 generateKeyPair];

    //FlutterStandardTypedData *hello =[FlutterStandardTypedData typedDataWithBytes:key2.publicKey];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:key2];
 
    id objects[] = {(FlutterStandardTypedData*)key2.publicKey, (FlutterStandardTypedData*)data};
    id keys[] = {(NSString*)@"publicKey", (NSString*)@"secretKey"};
    NSUInteger count = sizeof(objects) /sizeof(id);
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys count:count];
    
    return dictionary;
}

- (FlutterStandardTypedData*)getSecret:(NSData*)pubKey pair:(NSData*)keyPair {
    ECKeyPair *pair = [NSKeyedUnarchiver unarchiveObjectWithData:keyPair];
    NSData *sharedSecret = [Curve25519 generateSharedSecretFromPublicKey:pubKey andKeyPair:pair];
    FlutterStandardTypedData *secret = [FlutterStandardTypedData typedDataWithBytes:sharedSecret];
    
    return secret;
}
- (FlutterStandardTypedData*)getSignature:(NSData*)message pair:(NSData*)keyPair{
    ECKeyPair *pair = [NSKeyedUnarchiver unarchiveObjectWithData:keyPair];
    NSData *sign = [Ed25519 sign:message withKeyPair:pair];
    FlutterStandardTypedData *signature =[FlutterStandardTypedData typedDataWithBytes:sign];
    return signature;
}
- (NSNumber*)validSignature:(NSData*)signature pubKey:(NSData*)publicKey msg:(NSData*)message{
    BOOL valid = [Ed25519 verifySignature:signature publicKey:publicKey data:message];
    NSNumber *isValid = [NSNumber numberWithBool:valid];
    return isValid;
}
@end
