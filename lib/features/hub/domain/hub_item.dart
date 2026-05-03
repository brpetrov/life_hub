import 'package:cloud_firestore/cloud_firestore.dart';

import 'frequency.dart';
import 'hub_category.dart';
import 'hub_status.dart';

enum HubItemSource {
  preset('preset'),
  custom('custom');

  const HubItemSource(this.value);

  final String value;

  static HubItemSource fromValue(Object? value) {
    return switch (value?.toString().trim().toLowerCase()) {
      'preset' => HubItemSource.preset,
      _ => HubItemSource.custom,
    };
  }
}

class HubItem {
  const HubItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.frequency,
    required this.source,
    this.lastDoneDate,
    this.nextDueDate,
    this.presetId,
    this.notificationsMuted = false,
    this.archived = false,
    this.createdAt,
    this.updatedAt,
  });

  factory HubItem.fromFirestore(String id, Map<String, dynamic> data) {
    return HubItem(
      id: id,
      name: _stringValue(data['name']),
      category: HubCategory.fromValue(data['category']),
      description: _stringValue(data['description']),
      frequency: _frequencyFromValue(data['frequencyMonths']),
      lastDoneDate: _dateFromFirestore(data['lastDoneDate']),
      nextDueDate: _dateFromFirestore(data['nextDueDate']),
      source: HubItemSource.fromValue(data['source']),
      presetId: _nullableStringValue(data['presetId']),
      notificationsMuted: data['notificationsMuted'] == true,
      archived: data['archived'] == true,
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
    );
  }

  final String id;
  final String name;
  final HubCategory category;
  final String description;
  final Frequency frequency;
  final DateTime? lastDoneDate;
  final DateTime? nextDueDate;
  final HubItemSource source;
  final String? presetId;
  final bool notificationsMuted;
  final bool archived;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HubStatus status({DateTime? now}) {
    return HubStatus.fromDueDate(nextDueDate, now: now);
  }

  HubItem markDone(DateTime completedAt) {
    return copyWith(
      lastDoneDate: completedAt,
      nextDueDate: frequency.nextDueDateAfter(completedAt),
      clearNextDueDate: !frequency.repeats,
      updatedAt: completedAt,
    );
  }

  HubItem copyWith({
    String? id,
    String? name,
    HubCategory? category,
    String? description,
    Frequency? frequency,
    DateTime? lastDoneDate,
    DateTime? nextDueDate,
    HubItemSource? source,
    String? presetId,
    bool? notificationsMuted,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearLastDoneDate = false,
    bool clearNextDueDate = false,
    bool clearPresetId = false,
    bool clearCreatedAt = false,
    bool clearUpdatedAt = false,
  }) {
    return HubItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      lastDoneDate: clearLastDoneDate
          ? null
          : lastDoneDate ?? this.lastDoneDate,
      nextDueDate: clearNextDueDate ? null : nextDueDate ?? this.nextDueDate,
      source: source ?? this.source,
      presetId: clearPresetId ? null : presetId ?? this.presetId,
      notificationsMuted: notificationsMuted ?? this.notificationsMuted,
      archived: archived ?? this.archived,
      createdAt: clearCreatedAt ? null : createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name.trim(),
      'category': category.value,
      'description': description.trim(),
      'frequencyMonths': frequency.months,
      'lastDoneDate': _timestampFromDate(lastDoneDate),
      'nextDueDate': _timestampFromDate(nextDueDate),
      'source': source.value,
      'presetId': presetId,
      'notificationsMuted': notificationsMuted,
      'archived': archived,
      'createdAt': _timestampFromDate(createdAt),
      'updatedAt': _timestampFromDate(updatedAt),
    };
  }

  static String _stringValue(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static String? _nullableStringValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static Frequency _frequencyFromValue(Object? value) {
    final months = switch (value) {
      int() => value,
      num() => value.round(),
      String() => int.tryParse(value.trim()) ?? 0,
      _ => 0,
    };

    return Frequency(months < 0 ? 0 : months);
  }

  static DateTime? _dateFromFirestore(Object? value) {
    return switch (value) {
      Timestamp() => value.toDate(),
      DateTime() => value,
      String() => DateTime.tryParse(value),
      _ => null,
    };
  }

  static Timestamp? _timestampFromDate(DateTime? value) {
    return value == null ? null : Timestamp.fromDate(value);
  }
}
