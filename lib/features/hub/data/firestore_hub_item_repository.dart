import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../domain/hub_item.dart';
import '../domain/hub_item_sort.dart';
import 'hub_item_repository.dart';

class FirestoreHubItemRepository implements HubItemRepository {
  factory FirestoreHubItemRepository({
    required String userId,
    FirebaseFirestore? firestore,
    DateTime Function()? now,
  }) {
    final trimmedUserId = userId.trim();

    if (trimmedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'Must not be empty.');
    }

    return FirestoreHubItemRepository._(
      firestore: firestore ?? FirebaseFirestore.instance,
      userId: trimmedUserId,
      now: now ?? DateTime.now,
    );
  }

  FirestoreHubItemRepository._({
    required FirebaseFirestore firestore,
    required String userId,
    required DateTime Function() now,
  }) : _firestore = firestore,
       _userId = userId,
       _now = now;

  static const _usersCollection = 'users';
  static const _hubItemsCollection = 'hubItems';
  static const _batchLimit = 500;
  static const _pollInterval = Duration(seconds: 5);

  final FirebaseFirestore _firestore;
  final String _userId;
  final DateTime Function() _now;

  CollectionReference<Map<String, dynamic>> get _itemsCollection {
    return _firestore
        .collection(_usersCollection)
        .doc(_userId)
        .collection(_hubItemsCollection);
  }

  @override
  Stream<List<HubItem>> watchItems() {
    if (_usePollingStreams) {
      return _watchItemsByPolling();
    }

    return _itemsCollection.where('archived', isEqualTo: false).snapshots().map(
      (snapshot) {
        return _sortedItemsFromDocuments(snapshot.docs);
      },
    );
  }

  Stream<List<HubItem>> _watchItemsByPolling() async* {
    while (true) {
      yield await fetchItems();
      await Future<void>.delayed(_pollInterval);
    }
  }

  @override
  Future<List<HubItem>> fetchItems() async {
    final snapshot = await _itemsCollection
        .where('archived', isEqualTo: false)
        .get();

    return _sortedItemsFromDocuments(snapshot.docs);
  }

  @override
  Future<void> createItem(HubItem item) async {
    final document = _documentForCreate(item);

    await document.set(_createData(item));
  }

  @override
  Future<void> createItems(List<HubItem> items) async {
    if (items.isEmpty) {
      return;
    }

    for (var start = 0; start < items.length; start += _batchLimit) {
      final batch = _firestore.batch();
      final end = (start + _batchLimit).clamp(0, items.length);

      for (final item in items.sublist(start, end)) {
        batch.set(_documentForCreate(item), _createData(item));
      }

      await batch.commit();
    }
  }

  @override
  Future<void> updateItem(HubItem item) async {
    final data = item.toFirestore()
      ..remove('createdAt')
      ..['updatedAt'] = FieldValue.serverTimestamp();

    await _documentForId(item.id).update(data);
  }

  @override
  Future<void> markDone(HubItem item) async {
    final completedAt = _now();
    final updated = item.markDone(completedAt);

    await _documentForId(item.id).update({
      'lastDoneDate': Timestamp.fromDate(completedAt),
      'nextDueDate': _timestampFromDate(updated.nextDueDate),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteItem(String id) async {
    await _documentForId(
      id,
    ).update({'archived': true, 'updatedAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> deleteAllItems() async {
    while (true) {
      final snapshot = await _itemsCollection.limit(_batchLimit).get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = _firestore.batch();

      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }

      await batch.commit();
    }
  }

  Map<String, dynamic> _createData(HubItem item) {
    return item.toFirestore()
      ..['archived'] = false
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp();
  }

  DocumentReference<Map<String, dynamic>> _documentForCreate(HubItem item) {
    final itemId = item.id.trim();

    return itemId.isEmpty
        ? _itemsCollection.doc()
        : _itemsCollection.doc(itemId);
  }

  DocumentReference<Map<String, dynamic>> _documentForId(String id) {
    final trimmedId = id.trim();

    if (trimmedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty.');
    }

    return _itemsCollection.doc(trimmedId);
  }

  Timestamp? _timestampFromDate(DateTime? value) {
    return value == null ? null : Timestamp.fromDate(value);
  }

  List<HubItem> _sortedItemsFromDocuments(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    final items = documents.map((document) {
      return HubItem.fromFirestore(document.id, document.data());
    });

    return HubItemSort.sortedByDashboardPriority(items, now: _now());
  }

  bool get _usePollingStreams {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  }
}
