import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

// Define custom exception for encryption errors
class EncryptionError implements Exception {
  final String message;
  EncryptionError(this.message);
}

class SymmetricKey {
  final Uint8List _bytes;

  SymmetricKey(this._bytes);

  Uint8List get bytes => _bytes;
}

extension StringScramble on String {
  String scrambleUUID() {
    return String.fromCharCodes(
      this.runes.map((int charCode) {
        int rotatedCharCode;
        if (charCode >= 65 && charCode <= 90) {
          // Uppercase letters (A-Z)
          rotatedCharCode = (charCode - 65 + 13) % 26 + 65;
        } else if (charCode >= 97 && charCode <= 122) {
          // Lowercase letters (a-z)
          rotatedCharCode = (charCode - 97 + 13) % 26 + 97;
        } else {
          rotatedCharCode = charCode;
        }
        return rotatedCharCode;
      }),
    );
  }

  String unscrambleUUID() {
    // Since ROT13 is its own inverse, unscrambling is the same as scrambling
    return scrambleUUID();
  }
}

extension StringEncryption on String {
  Uint8List generateEncryptionKey() {
    // Convert the string to UTF-8 encoded bytes
    final utf8Bytes = utf8.encode(this);

    // Hash the UTF-8 encoded bytes using SHA-256
    final hashBytes = sha256.convert(utf8Bytes).bytes;

    // Return the hashed bytes as Uint8List (equivalent to SymmetricKey in Swift)
    return Uint8List.fromList(hashBytes);
  }

   String encryptString(Uint8List key) {
   try {
    // Convert the key bytes into an encryption key
    final encryptionKey = Key(key);

    // Generate a random IV (Initialization Vector)
    final iv = IV.fromLength(16); // 16 bytes IV for AES-GCM

    // Associated data (AAD) for authentication
    final macValue = utf8.encode("");

    // Create an AES-GCM encrypter with the key
    final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.gcm));

    // Encrypt the plaintext using AES-GCM
    final encrypted = encrypter.encrypt(
      this,
      iv: iv,
      associatedData: macValue,
    );

    // Concatenate IV, ciphertext, and tag, then encode to base64
    final concatenatedBytes = Uint8List.fromList([...iv.bytes, ...encrypted.bytes, ...macValue]);
    final base64Encoded = base64.encode(concatenatedBytes);
    
    return base64Encoded;
  } catch (e) {
    print('Error while encrypting: $e');
    return '';
  }
  }
}
