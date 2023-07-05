import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  ///Write an item to secure storage using key, value
  void addItem(String k, String v) async {
    await _storage.write(
        key: k,
        value: v,
        iOptions: getIOSOptions(),
        aOptions: getAndroidOptions());
  }

  ///Get item from secure storage using key
  Future<String> getItem(k) async {
    String? value = await _storage.read(
        key: k, iOptions: getIOSOptions(), aOptions: getAndroidOptions());
    if (value != null && value.isNotEmpty) {
      return value.toString();
    } else {
      return '';
    }
  }

  ///Delete an item from secure storage using key
  void deleteItem(k) async {
    await _storage.delete(
        key: k, iOptions: getIOSOptions(), aOptions: getAndroidOptions());
  }

  IOSOptions getIOSOptions() => const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      );

  AndroidOptions getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
}
