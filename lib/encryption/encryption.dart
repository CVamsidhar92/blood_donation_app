import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class MyEncryptionDecryption {
  // Use a static key for encryption and decryption
  static final String _staticKey = 'chvamsidhar12345'; // Replace with your key

  // Encrypt function
  static String encrypt(String data) {
    // Convert the data to bytes
    Uint8List plainText = utf8.encode(data);

    // Convert the key to bytes
    Uint8List keyBytes = utf8.encode(_staticKey);

    // Create an AES key
    final cryptoKey = Key.fromUtf8(base64Url.encode(keyBytes));

    // Create an AES block cipher
    final encrypter = Encrypter(AES(cryptoKey));

    // Encrypt the data
    final encryptedData = encrypter.encryptBytes(plainText);

    // Return the base64-encoded encrypted data
    return base64Url.encode(encryptedData.bytes);
  }

  // Decrypt function
  static String decrypt(String encryptedData) {
    // Convert the encrypted data to bytes
    Uint8List encryptedBytes = base64Url.decode(encryptedData);

    // Convert the key to bytes
    Uint8List keyBytes = utf8.encode(_staticKey);

    // Create an AES key
    final cryptoKey = Key.fromUtf8(base64Url.encode(keyBytes));

    // Create an AES block cipher
    final encrypter = Encrypter(AES(cryptoKey));

    // Decrypt the data
    final decryptedBytes = encrypter.decryptBytes(Encrypted(encryptedBytes));

    // Convert the decrypted bytes to string
    return utf8.decode(decryptedBytes);
  }
}
