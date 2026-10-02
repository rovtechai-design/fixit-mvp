import 'package:flutter/material.dart';

enum ServiceCategory {
  plumbing,
  electrical,
  acService,
  homeCleaning,
  terraceOutdoorCleaning,
  gardening,
  tailoringAlterations,
  notSure,
}

extension ServiceCategoryX on ServiceCategory {
  String get label {
    switch (this) {
      case ServiceCategory.plumbing:
        return 'Plumbing';
      case ServiceCategory.electrical:
        return 'Electrical';
      case ServiceCategory.acService:
        return 'AC Service';
      case ServiceCategory.homeCleaning:
        return 'Home Cleaning';
      case ServiceCategory.terraceOutdoorCleaning:
        return 'Terrace / Outdoor Cleaning';
      case ServiceCategory.gardening:
        return 'Gardening';
      case ServiceCategory.tailoringAlterations:
        return 'Tailoring / Alterations';
      case ServiceCategory.notSure:
        return 'Not sure';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceCategory.plumbing:
        return Icons.plumbing;
      case ServiceCategory.electrical:
        return Icons.electrical_services;
      case ServiceCategory.acService:
        return Icons.ac_unit;
      case ServiceCategory.homeCleaning:
        return Icons.cleaning_services;
      case ServiceCategory.terraceOutdoorCleaning:
        return Icons.yard;
      case ServiceCategory.gardening:
        return Icons.grass;
      case ServiceCategory.tailoringAlterations:
        return Icons.content_cut;
      case ServiceCategory.notSure:
        return Icons.help_outline;
    }
  }

  static ServiceCategory fromName(String name) =>
      ServiceCategory.values.firstWhere((c) => c.name == name);
}
