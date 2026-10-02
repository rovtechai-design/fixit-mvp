import '../models/service_category.dart';
import '../models/trade.dart';

/// Maps a service category to the trade that should handle it.
/// Returns null for [ServiceCategory.notSure], which is visible to every trade.
Trade? tradeForCategory(ServiceCategory category) {
  switch (category) {
    case ServiceCategory.plumbing:
      return Trade.plumber;
    case ServiceCategory.electrical:
      return Trade.electrician;
    case ServiceCategory.acService:
      return Trade.acTechnician;
    case ServiceCategory.homeCleaning:
      return Trade.cleaner;
    case ServiceCategory.terraceOutdoorCleaning:
      return Trade.cleaner;
    case ServiceCategory.gardening:
      return Trade.gardener;
    case ServiceCategory.tailoringAlterations:
      return Trade.tailor;
    case ServiceCategory.notSure:
      return null;
  }
}

bool isJobVisibleToTrade(ServiceCategory category, Trade trade) {
  final mapped = tradeForCategory(category);
  return mapped == null || mapped == trade;
}
