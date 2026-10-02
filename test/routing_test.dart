import 'package:flutter_test/flutter_test.dart';
import 'package:fixit_mvp/models/service_category.dart';
import 'package:fixit_mvp/models/trade.dart';
import 'package:fixit_mvp/util/routing.dart';

void main() {
  group('tradeForCategory', () {
    test('maps every trade-specific category to its trade', () {
      expect(tradeForCategory(ServiceCategory.plumbing), Trade.plumber);
      expect(tradeForCategory(ServiceCategory.electrical), Trade.electrician);
      expect(tradeForCategory(ServiceCategory.acService), Trade.acTechnician);
      expect(tradeForCategory(ServiceCategory.homeCleaning), Trade.cleaner);
      expect(tradeForCategory(ServiceCategory.terraceOutdoorCleaning), Trade.cleaner);
      expect(tradeForCategory(ServiceCategory.gardening), Trade.gardener);
      expect(tradeForCategory(ServiceCategory.tailoringAlterations), Trade.tailor);
    });

    test('"Not sure" has no single trade', () {
      expect(tradeForCategory(ServiceCategory.notSure), isNull);
    });
  });

  group('isJobVisibleToTrade', () {
    test('a category is only visible to its own trade', () {
      expect(isJobVisibleToTrade(ServiceCategory.plumbing, Trade.plumber), isTrue);
      expect(isJobVisibleToTrade(ServiceCategory.plumbing, Trade.electrician), isFalse);
    });

    test('both cleaning categories route to Cleaner', () {
      expect(isJobVisibleToTrade(ServiceCategory.homeCleaning, Trade.cleaner), isTrue);
      expect(isJobVisibleToTrade(ServiceCategory.terraceOutdoorCleaning, Trade.cleaner), isTrue);
    });

    test('"Not sure" is visible to every trade', () {
      for (final trade in Trade.values) {
        expect(isJobVisibleToTrade(ServiceCategory.notSure, trade), isTrue);
      }
    });
  });
}
