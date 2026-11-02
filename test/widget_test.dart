import 'package:flutter_test/flutter_test.dart';
import 'package:chatx_app/utils/date_time_formatter.dart';

void main() {
  test('DateTimeFormatter smoke test', () {
    expect(DateTimeFormatter.formatTime(null), '');
  });
}
