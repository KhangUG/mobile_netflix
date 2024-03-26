import 'dart:convert';

import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:netflix_clone/api/client.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:netflix_clone/data/store.dart';
import 'package:appwrite/appwrite.dart';
import 'package:netflix_clone/screens/home.dart';

class AccountProvider extends ChangeNotifier {
  User? _current;
  User? get current => _current;

  Session? _session;
  Session? get session => _session;

  Future<Session?> get _cachedSession async {
    final cached = await Store.get("session");

    if (cached == null) {
      return null;
    }

    return Session.fromMap(json.decode(cached));
  }

  Future<bool> isValid() async {
    if (session == null) {
      final cached = await _cachedSession;

      if (cached == null) {
        return false;
      }

      _session = cached;
    }

    return _session != null;
  }

  Future<void> register(String email, String password, String? name) async {
    try {
      final result = await ApiClient.account.create(
          userId: appwrite.ID.unique(),
          email: email,
          password: password,
          name: name);

      _current = result;

      notifyListeners();
    } catch (e) {
      print(
          "Error during registration: $e"); // In ra lỗi để xác định nguyên nhân
      throw Exception(
          "Failed to register: $e"); // Ném ra ngoại lệ cùng với thông tin lỗi
    }
  }

  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      final result = await ApiClient.account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      _session = result;

      Store.set("session", json.encode(result.toMap()));

      notifyListeners();
    } catch (e) {
      _session = null;
    }
  }
}
