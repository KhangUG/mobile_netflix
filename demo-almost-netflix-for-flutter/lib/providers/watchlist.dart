import 'dart:async';
import 'dart:typed_data';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:appwrite/models.dart';
import 'package:netflix_clone/api/client.dart';
import 'package:netflix_clone/data/entry.dart';
import 'package:flutter/material.dart';

class WatchListProvider extends ChangeNotifier {
  static final String _databaseId = "default2";
  final String _collectionId = "watchlists";
  static final String _bucketId = "default1";

  List<Entry> _entries = [];
  List<Entry> get entries => _entries;

  Future<User> get user async {
    return await ApiClient.account.get();
  }

  Future<List<Entry>> list() async {
    final user = await this.user;

    final watchlist = await ApiClient.database.listDocuments(
      databaseId: _databaseId,
      collectionId: _collectionId,
    );

    final movieIds = watchlist.documents
        .map((document) => document.data["movieId"])
        .toList();
    final entries = (await ApiClient.database.listDocuments(
            databaseId: _databaseId,
            collectionId: appwrite.ID.custom('movies')))
        .documents
        .map((document) => Entry.fromJson(document.data))
        .toList();
    final filtered =
        entries.where((entry) => movieIds.contains(entry.id)).toList();

    _entries = filtered;

    notifyListeners();

    return _entries;
  }

  Future<void> add(Entry entry) async {
    final user = await this.user;

    var result = await ApiClient.database.createDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: appwrite.ID.unique(),
        data: {
          "userId": user.$id,
          "movieId": entry.id,
        });

    list(); // Cập nhật danh sách sau khi thêm mục mới
  }

  Future<void> remove(Entry entry) async {
    final user = await this.user;

    final result = await ApiClient.database.listDocuments(
        databaseId: _databaseId,
        collectionId: _collectionId,
        queries: [
          appwrite.Query.equal("userId", user.$id),
          appwrite.Query.equal("movieId", entry.id)
        ]);

    final id = result.documents.first.$id;

    await ApiClient.database.deleteDocument(
        databaseId: _databaseId, collectionId: _collectionId, documentId: id);

    list(); // Cập nhật danh sách sau khi xóa mục
  }

  Future<Uint8List> imageFor(Entry entry) async {
    return await ApiClient.storage.getFileView(
      bucketId: _bucketId,
      fileId: entry.thumbnailImageId,
    );
  }

  bool isOnList(Entry entry) => _entries.any((e) => e.id == entry.id);
}
