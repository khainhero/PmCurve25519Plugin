package com.example.pm_curve25519;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import org.whispersystems.curve25519.Curve25519;
import org.whispersystems.curve25519.Curve25519KeyPair;
import java.util.HashMap;

/** PmCurve25519Plugin */
public class PmCurve25519Plugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "PmCurve25519");
    channel.setMethodCallHandler(new PmCurve25519Plugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
     switch(call.method){
         case "getKeyPair":
          {
                   HashMap m = getKeyPair();
                   try {
                       result.success(m);
                   } catch (Exception e) {
                      result.error("Something went wrong...for generating key-pair...", e.getMessage(), null);
                   }
          }
          break;
         case "getSecret":
         {       byte[] publicKey = call.argument("publicKey");
                 byte[] _secret = call.argument("keyPair");
                 byte[] sharedSecret = getSharedSecret(publicKey, _secret);
                 try{
                     result.success(sharedSecret);
                 } catch (Exception e){
                     result.error("Something went wrong...for calculating shared-secret...", e.getMessage(), null);
                 }
         }
         break;
         case "getSignature":
         {
                 byte[] message = call.argument("message");
                 byte[] _secret = call.argument("keyPair");
                 byte[] signature = getSignature(message, _secret);
                 try {
                    result.success(signature);
                 } catch (Exception e){
                    result.error("Something went wrong...for calculating signature...", e.getMessage(), null);
                 }
         }
         break;
         case "verifySignature":
         {      
             byte[] publicKey = call.argument("publicKey");
             byte[] message = call.argument("message");
             byte[] signature = call.argument("signature");
             try {
                 boolean valid = verifySignature(publicKey, message, signature);
                 result.success(valid);
             } catch (Exception e){
                 result.error("Something went wrong...for verifying signature...", e.getMessage(), null);
             }
         }
         break;
         default:
             result.notImplemented();
             break;
      }
  }

  private HashMap getKeyPair(){
    Curve25519KeyPair keyPair = Curve25519.getInstance(Curve25519.BEST).generateKeyPair();
    HashMap<String, byte[]> m = new HashMap<>();
    m.put("publicKey", keyPair.getPublicKey());
    m.put("secretKey", keyPair.getPrivateKey());
    return m;
  }

  private byte[] getSharedSecret(byte[] publicKey, byte[] _secret){
    Curve25519 cipher = Curve25519.getInstance(Curve25519.BEST);
    byte[] _sharedSecret;
    _sharedSecret = cipher.calculateAgreement(publicKey, _secret);

    return _sharedSecret;
  }

  private byte[] getSignature(byte[] message, byte[] _secret){
    Curve25519 cipher = Curve25519.getInstance(Curve25519.BEST);
    byte[] signature;
    signature = cipher.calculateSignature(_secret, message);
    return signature;
  }

  private boolean verifySignature(byte[] publicKey, byte[] message, byte[] signature){
      Curve25519 cipher = Curve25519.getInstance(Curve25519.BEST);
      boolean valid;
      valid = cipher.verifySignature(publicKey, message, signature);
      return valid;
  }
}
