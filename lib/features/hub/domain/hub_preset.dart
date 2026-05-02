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
      description:
          'Annual roadworthiness test required by law for vehicles over 3 years old. Missing it means your car is illegal to drive.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'car-service',
      name: 'Car Service',
      category: HubCategory.car,
      description:
          'Regular servicing keeps your car reliable and protects resale value. Most manufacturers recommend annually or every 12,000 miles.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'car-road-tax',
      name: 'Road Tax',
      category: HubCategory.car,
      description:
          'Vehicle Excise Duty is required to legally drive on UK roads. It can be paid monthly or annually, but it is easy to miss.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'car-insurance',
      name: 'Car Insurance',
      category: HubCategory.car,
      description:
          'Legally required. Renewing without comparing quotes often costs more, so shop around 3 to 4 weeks before expiry.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'car-breakdown-cover',
      name: 'Breakdown Cover',
      category: HubCategory.car,
      description:
          'AA, RAC, Green Flag, and similar cover often creeps up on auto renewal. Call, haggle, or switch before it renews.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'car-tyre-check',
      name: 'Tyre Check / Replacement',
      category: HubCategory.car,
      description:
          'Legal minimum tread depth is 1.6mm. Check tread and pressure monthly, because the penalty can be GBP 2,500 per illegal tyre.',
      frequency: Frequency(1),
    ),
    HubPreset(
      id: 'car-washer-fluid',
      name: 'Windscreen Washer Fluid',
      category: HubCategory.car,
      description:
          'Top up regularly, especially before winter. Running out on a motorway is dangerous and can be an MOT failure point.',
      frequency: Frequency(1),
    ),
    HubPreset(
      id: 'home-boiler-service',
      name: 'Boiler Service',
      category: HubCategory.home,
      description:
          'An annual gas safety check keeps your boiler efficient and safe. It helps prevent carbon monoxide risks and costly breakdowns.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'home-insurance-renewal',
      name: 'Home Insurance Renewal',
      category: HubCategory.home,
      description:
          'Buildings insurance renewal prices can jump if you stay loyal. Compare before renewing so you keep proper cover at a fair price.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'home-contents-insurance',
      name: 'Contents Insurance Renewal',
      category: HubCategory.home,
      description:
          'Covers belongings against theft, fire, and damage. It is often bundled with home insurance, but still worth checking separately.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'home-energy-tariff-review',
      name: 'Energy Tariff Review',
      category: HubCategory.home,
      description:
          'Fixed tariffs expire and you may move to a more expensive variable rate. Check whether a better deal is available.',
      frequency: Frequency(6),
    ),
    HubPreset(
      id: 'home-gutter-cleaning',
      name: 'Gutter Cleaning',
      category: HubCategory.home,
      description:
          'Blocked gutters cause damp, leaks, and foundation damage. Clear leaves and debris at least annually, especially after autumn.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'home-smoke-alarm-test',
      name: 'Smoke Alarm / CO Detector Check',
      category: HubCategory.home,
      description:
          'Test monthly and replace batteries when needed. Smoke alarms should be replaced every 10 years, carbon monoxide detectors every 5 to 7 years.',
      frequency: Frequency(1),
    ),
    HubPreset(
      id: 'home-tv-licence',
      name: 'TV Licence',
      category: HubCategory.home,
      description:
          'Required if you watch live TV or use BBC iPlayer. The fee changes over time, so check the current cost before renewal.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'home-council-tax',
      name: 'Council Tax',
      category: HubCategory.home,
      description:
          'Runs April to March. Check your band is correct, because some homes are in the wrong band and appeals are free.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'home-chimney-sweep',
      name: 'Chimney Sweep',
      category: HubCategory.home,
      description:
          'Needed annually if you use a wood burner or open fire. It reduces chimney fire risk and carbon monoxide buildup.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'home-window-cleaning',
      name: 'Window Cleaning',
      category: HubCategory.home,
      description:
          'Regular cleaning prevents hard water stain buildup that can become permanent. Every 2 to 3 months keeps glass clear.',
      frequency: Frequency(3),
    ),
    HubPreset(
      id: 'home-bleed-radiators',
      name: 'Bleeding Radiators',
      category: HubCategory.home,
      description:
          'Air trapped in radiators makes them heat unevenly. Bleeding them takes a few minutes and helps save energy.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'home-water-meter-reading',
      name: 'Water Meter Reading',
      category: HubCategory.home,
      description:
          'Submit regular readings to avoid estimated bills. It takes minutes and can prevent surprise charges.',
      frequency: Frequency(3),
    ),
    HubPreset(
      id: 'home-fridge-freezer-clean',
      name: 'Fridge/Freezer Defrost & Clean',
      category: HubCategory.home,
      description:
          'Ice buildup makes freezers work harder and costs more to run. Cleaning coils and shelves also improves efficiency.',
      frequency: Frequency(6),
    ),
    HubPreset(
      id: 'home-washing-machine-clean',
      name: 'Washing Machine Clean',
      category: HubCategory.home,
      description:
          'Run an empty hot wash with a cleaning tablet or white vinegar monthly. It prevents mould, odours, and wear.',
      frequency: Frequency(1),
    ),
    HubPreset(
      id: 'home-stopcock-check',
      name: 'Stopcock / Water Shutoff Check',
      category: HubCategory.home,
      description:
          'Find and test the main water shutoff before an emergency. A stuck stopcock turns a small leak into a much bigger problem.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'health-dental-checkup',
      name: 'Dentist Check-up',
      category: HubCategory.health,
      description:
          'NHS guidance is usually every 6 to 24 months depending on risk. Catching problems early saves pain, time, and money.',
      frequency: Frequency(6),
    ),
    HubPreset(
      id: 'health-eye-test',
      name: 'Eye Test',
      category: HubCategory.health,
      description:
          'Recommended every 2 years, or annually if over 40 or with existing conditions. It may be free on the NHS if eligible.',
      frequency: Frequency(24),
    ),
    HubPreset(
      id: 'health-flu-jab',
      name: 'Flu Jab',
      category: HubCategory.health,
      description:
          'Free on the NHS if eligible, including over 65s, pregnant people, and certain conditions. Otherwise it is usually low-cost at pharmacies.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'health-nhs-ppc',
      name: 'NHS Prescription Prepayment Certificate',
      category: HubCategory.health,
      description:
          'If you need 4 or more prescriptions in 3 months, or 12 or more in 12 months, a PPC can save money.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'health-check-blood-test',
      name: 'Health Check / Blood Test',
      category: HubCategory.health,
      description:
          'NHS Health Checks are free for 40 to 74 year olds every 5 years. Periodic blood tests can spot issues early.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'health-medication-repeat-review',
      name: 'Medication / Repeat Prescription Review',
      category: HubCategory.health,
      description:
          'Repeat medication can run low or drift out of date. Review supplies, dosage, and renewal timing before you are nearly out.',
      frequency: Frequency(3),
    ),
    HubPreset(
      id: 'tech-phone-contract',
      name: 'Phone Contract Renewal',
      category: HubCategory.tech,
      description:
          'After the minimum term ends, you are likely overpaying. Switch to SIM-only or renegotiate for a cheaper deal.',
      frequency: Frequency(24),
    ),
    HubPreset(
      id: 'tech-broadband-contract',
      name: 'Broadband Contract End',
      category: HubCategory.tech,
      description:
          'Out-of-contract broadband prices can jump significantly. Compare and switch, or call for a retention deal.',
      frequency: Frequency(18),
    ),
    HubPreset(
      id: 'tech-software-licences',
      name: 'Software Licence Renewals',
      category: HubCategory.tech,
      description:
          'Antivirus, Office 365, Adobe, and similar renewals add up. Check whether you still need them or have a free alternative.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'tech-cloud-storage',
      name: 'Cloud Storage Subscription',
      category: HubCategory.tech,
      description:
          'iCloud, Google One, Dropbox, and similar plans can creep upward. Check usage so you are not paying for unused storage.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'tech-password-review',
      name: 'Password & Security Review',
      category: HubCategory.tech,
      description:
          'Review important passwords, 2FA settings, recovery details, and breached accounts. Start with critical accounts first.',
      frequency: Frequency(6),
    ),
    HubPreset(
      id: 'tech-device-backup',
      name: 'Computer / Phone Backup',
      category: HubCategory.tech,
      description:
          'Back up photos, documents, and important files. If your device died today, this is what protects what you cannot replace.',
      frequency: Frequency(1),
    ),
    HubPreset(
      id: 'pets-vet-checkup',
      name: 'Vet Check-up',
      category: HubCategory.pets,
      description:
          'Annual wellness exams catch health issues early, including weight, teeth, and general health changes.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'pets-vaccinations',
      name: 'Pet Vaccinations / Boosters',
      category: HubCategory.pets,
      description:
          'Core vaccinations need annual or triennial boosters depending on the vaccine. Check your pet vaccination card.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'pets-flea-treatment',
      name: 'Flea / Worm Treatment',
      category: HubCategory.pets,
      description:
          'Monthly flea treatment and regular worming help prevent infestations and health problems. Missed doses are easy to forget.',
      frequency: Frequency(1),
    ),
    HubPreset(
      id: 'pets-insurance',
      name: 'Pet Insurance Renewal',
      category: HubCategory.pets,
      description:
          'Premiums rise with age. Review cover annually, but be careful switching because pre-existing conditions may not be covered.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'pets-microchip-details',
      name: 'Microchip Details Check',
      category: HubCategory.pets,
      description:
          'If a pet goes missing, outdated microchip contact details make reunions harder. Check address and phone details annually.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'documents-passport',
      name: 'Passport Renewal',
      category: HubCategory.documents,
      description:
          'Expires every 10 years. Many countries require 6 months validity remaining, and renewal can take 3 to 10 weeks.',
      frequency: Frequency(120),
    ),
    HubPreset(
      id: 'documents-driving-licence',
      name: 'Driving Licence Photo Renewal',
      category: HubCategory.documents,
      description:
          'Photocard licences must be renewed every 10 years. The licence itself usually lasts until age 70.',
      frequency: Frequency(120),
    ),
    HubPreset(
      id: 'documents-tenancy-agreement',
      name: 'Tenancy Agreement Renewal',
      category: HubCategory.documents,
      description:
          'Know when your fixed term ends. After that you may move to a rolling contract and rent can change with notice.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'documents-life-insurance',
      name: 'Life Insurance Review',
      category: HubCategory.documents,
      description:
          'Review cover after major life events like a mortgage, baby, or pay rise. Make sure beneficiaries are current.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'documents-will-review',
      name: 'Will Review',
      category: HubCategory.documents,
      description:
          'Review after marriages, births, property purchases, or divorces. Many adults do not have a will at all.',
      frequency: Frequency(24),
    ),
    HubPreset(
      id: 'documents-credit-report',
      name: 'Credit Report Check',
      category: HubCategory.documents,
      description:
          'Check for errors, fraud, and what lenders see. Free options include ClearScore, Credit Karma, and Experian.',
      frequency: Frequency(6),
    ),
    HubPreset(
      id: 'documents-emergency-contacts',
      name: 'Emergency Contacts & Key Documents',
      category: HubCategory.documents,
      description:
          'Keep emergency contacts, document locations, and account recovery details current so family can act quickly if needed.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'seasonal-pressure-wash',
      name: 'Pressure Wash Driveway / Patio',
      category: HubCategory.seasonal,
      description:
          'Algae and moss make surfaces slippery and can damage paving. A spring clean makes a visible difference.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'seasonal-garden-prep',
      name: 'Garden Prep / Lawn Care',
      category: HubCategory.seasonal,
      description:
          'First mow is often around March, lawn feed around April, and hedge cutting should avoid nesting season where possible.',
      frequency: Frequency(3),
    ),
    HubPreset(
      id: 'seasonal-winter-car-prep',
      name: 'Winter Car Prep',
      category: HubCategory.seasonal,
      description:
          'Check antifreeze, battery, tyre tread, and keep a winter kit in the boot, including scraper, torch, and blanket.',
      frequency: Frequency(12),
    ),
    HubPreset(
      id: 'seasonal-declutter-charity',
      name: 'Declutter & Charity Shop Run',
      category: HubCategory.seasonal,
      description:
          'Review wardrobes, cupboards, and storage. Donate what you do not use so the house stays easier to manage.',
      frequency: Frequency(6),
    ),
  ];
}
