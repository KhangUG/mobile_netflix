//
// provider.dart
// figures
//
// Author: Wess Cope (me@wess.io)
// Created: 06/15/2021
//
// Copywrite (c) 2021 Wess.io
//

import 'package:appwrite/appwrite.dart';

class ApiClient {
  Client get _client {
    Client client = Client();
    client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('65fdb2d7b7a4361132a9')
        .setSelfSigned(status: true);

    return client;
  }

  static Account get account => Account(_instance._client);
  static Databases get database => Databases(_instance._client);
  static Storage get storage => Storage(_instance._client);

  static final ApiClient _instance = ApiClient._internal();
  ApiClient._internal();
  factory ApiClient() => _instance;
}
