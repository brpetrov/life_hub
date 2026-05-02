import 'frequency.dart';
import 'hub_category.dart';
import 'hub_item.dart';

class HubPreset {
  const HubPreset({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.frequency,
  });

  final String id;
  final String name;
  final HubCategory category;
  final String description;
  final Frequency frequency;

  HubItem toHubItem({
    String itemId = '',
    DateTime? nextDueDate,
    DateTime? createdAt,
  }) {
    return HubItem(
      id: itemId,
      name: name,
      category: category,
      description: description,
      frequency: frequency,
      nextDueDate: nextDueDate,
      source: HubItemSource.preset,
      presetId: id,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  static Map<HubCategory, List<HubPreset>> groupedByCategory([
    Iterable<HubPreset>? presets,
  ]) {
    final grouped = {
      for (final category in HubCategory.values) category: <HubPreset>[],
    };

    for (final preset in presets ?? all) {
      grouped[preset.category]!.add(preset);
    }

    return grouped;
  }

  static const all = <HubPreset>[
    HubPreset(
      id: 'car-mot',
      name: 'MOT',
      category: HubCategory.car,
      description: 'Book the annual MOT before it expires.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'car-service',
      name: 'Car service',
      category: HubCategory.car,
      description: 'Schedule routine servicing and maintenance.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'car-insurance',
      name: 'Car insurance',
      category: HubCategory.car,
      description: 'Review renewal quotes before the policy renews.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'home-boiler-service',
      name: 'Boiler service',
      category: HubCategory.home,
      description: 'Arrange an annual boiler safety and service check.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'home-smoke-alarm-test',
      name: 'Smoke alarm test',
      category: HubCategory.home,
      description: 'Test smoke alarms and replace batteries if needed.',
      frequency: Frequency(1),
    ),
    HubPreset(
      id: 'home-gutter-clean',
      name: 'Gutter clean',
      category: HubCategory.home,
      description: 'Clear gutters and check for blocked downpipes.',
      frequency: Frequency(6),
    ),
    HubPreset(
      id: 'health-dental-checkup',
      name: 'Dental checkup',
      category: HubCategory.health,
      description: 'Book a routine dental checkup.',
      frequency: Frequency(6),
    ),
    HubPreset(
      id: 'health-eye-test',
      name: 'Eye test',
      category: HubCategory.health,
      description: 'Book a routine eye test.',
      frequency: Frequency(24),
    ),
    HubPreset(
      id: 'health-medication-review',
      name: 'Medication review',
      category: HubCategory.health,
      description: 'Review repeat prescriptions or medication needs.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'tech-device-backup',
      name: 'Device backup',
      category: HubCategory.tech,
      description: 'Check important devices and files are backed up.',
      frequency: Frequency(1),
    ),
    HubPreset(
      id: 'tech-password-review',
      name: 'Password review',
      category: HubCategory.tech,
      description: 'Review important account passwords and recovery options.',
      frequency: Frequency(6),
    ),
    HubPreset(
      id: 'tech-subscription-review',
      name: 'Subscription review',
      category: HubCategory.tech,
      description: 'Cancel unused subscriptions and check renewal prices.',
      frequency: Frequency(6),
    ),
    HubPreset(
      id: 'pets-vaccinations',
      name: 'Pet vaccinations',
      category: HubCategory.pets,
      description: 'Check booster vaccinations are up to date.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'pets-flea-treatment',
      name: 'Flea treatment',
      category: HubCategory.pets,
      description: 'Apply or schedule regular flea treatment.',
      frequency: Frequency(1),
    ),
    HubPreset(
      id: 'pets-insurance',
      name: 'Pet insurance',
      category: HubCategory.pets,
      description: 'Review renewal options before the policy renews.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'documents-passport',
      name: 'Passport renewal',
      category: HubCategory.documents,
      description: 'Check passport expiry and renewal timing.',
      frequency: Frequency(120),
    ),
    HubPreset(
      id: 'documents-driving-licence',
      name: 'Driving licence',
      category: HubCategory.documents,
      description: 'Check licence expiry and address details.',
      frequency: Frequency(120),
    ),
    HubPreset(
      id: 'documents-home-insurance',
      name: 'Home insurance',
      category: HubCategory.documents,
      description: 'Review renewal quotes before the policy renews.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'seasonal-winter-prep',
      name: 'Winter prep',
      category: HubCategory.seasonal,
      description: 'Check heating, insulation, outdoor taps, and supplies.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'seasonal-spring-clean',
      name: 'Spring clean',
      category: HubCategory.seasonal,
      description: 'Plan a deeper clean and reset key household areas.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'seasonal-garden-maintenance',
      name: 'Garden maintenance',
      category: HubCategory.seasonal,
      description: 'Review outdoor maintenance and garden jobs.',
      frequency: Frequency(3),
    ),
  ];
}
