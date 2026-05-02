enum HubCategory {
  car('car', 'Car'),
  home('home', 'Home'),
  health('health', 'Health'),
  tech('tech', 'Tech'),
  pets('pets', 'Pets'),
  documents('documents', 'Documents'),
  seasonal('seasonal', 'Seasonal'),
  custom('custom', 'Custom');

  const HubCategory(this.value, this.label);

  final String value;
  final String label;

  static HubCategory fromValue(Object? value) {
    final normalized = value
        ?.toString()
        .trim()
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll('_', '')
        .replaceAll(' ', '');

    return switch (normalized) {
      'car' || 'vehicle' || 'vehicles' => HubCategory.car,
      'home' || 'house' => HubCategory.home,
      'health' || 'medical' => HubCategory.health,
      'tech' || 'technology' || 'digital' => HubCategory.tech,
      'pet' || 'pets' => HubCategory.pets,
      'document' || 'documents' || 'paperwork' => HubCategory.documents,
      'seasonal' || 'season' => HubCategory.seasonal,
      'custom' || 'other' || 'misc' || 'miscellaneous' => HubCategory.custom,
      _ => HubCategory.custom,
    };
  }
}
