import 'package:fyqen/features/streak/application/app_clock.dart';

final class FakeAppClock implements AppClock {
  FakeAppClock(this.value);

  DateTime value;

  @override
  DateTime now() => value;
}
