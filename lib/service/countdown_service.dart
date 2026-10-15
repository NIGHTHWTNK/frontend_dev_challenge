import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class CountdownService extends GetxService {
  final ValueNotifier<DateTime> now = ValueNotifier(DateTime.now().toUtc());
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      now.value = DateTime.now().toUtc();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    now.dispose();
    super.onClose();
  }
}
