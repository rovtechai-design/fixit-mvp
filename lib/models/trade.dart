enum Trade { plumber, electrician, acTechnician, cleaner, gardener, tailor }

extension TradeLabel on Trade {
  String get label {
    switch (this) {
      case Trade.plumber:
        return 'Plumber';
      case Trade.electrician:
        return 'Electrician';
      case Trade.acTechnician:
        return 'AC Technician';
      case Trade.cleaner:
        return 'Cleaner';
      case Trade.gardener:
        return 'Gardener';
      case Trade.tailor:
        return 'Tailor';
    }
  }

  static Trade fromName(String name) =>
      Trade.values.firstWhere((t) => t.name == name);
}
