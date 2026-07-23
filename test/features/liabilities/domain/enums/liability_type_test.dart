import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';

void main() {
  test('LiabilityType values remain in the required order', () {
    expect(LiabilityType.values, <LiabilityType>[
      LiabilityType.creditCard,
      LiabilityType.personalLoan,
      LiabilityType.vehicleLoan,
      LiabilityType.mortgage,
      LiabilityType.studentLoan,
      LiabilityType.businessLoan,
      LiabilityType.buyNowPayLater,
      LiabilityType.familyLoan,
      LiabilityType.taxDebt,
      LiabilityType.other,
    ]);
  });
}
