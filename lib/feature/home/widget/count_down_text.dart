import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rescu/extension/string.dart';
import 'package:rescu/service/countdown_service.dart';

class CountdownText extends StatelessWidget {
  const CountdownText({
    super.key,
    required this.endsAt,
  });

  final DateTime? endsAt;

  @override
  Widget build(BuildContext context) {
    final end = endsAt;
    if (end == null) return const SizedBox.shrink();

    final now = Get.find<CountdownService>().now;

    return ValueListenableBuilder<DateTime>(
      valueListenable: now,
      builder: (context, currentTime, child) {
        final remaining = end.toUtc().difference(currentTime);

        return Text(
          formatCountdown(
            remaining.isNegative ? Duration.zero : remaining,
          ),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
        );
      },
    );
  }
}
