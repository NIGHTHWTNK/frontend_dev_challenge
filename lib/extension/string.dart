String formatCountdown(Duration remainingDuration) {
  final int hours = remainingDuration.inHours;
  final int minutes = remainingDuration.inMinutes.remainder(60);
  final int seconds = remainingDuration.inSeconds.remainder(60);

  final String hoursText = _padTwoDigits(hours);
  final String minutesText = _padTwoDigits(minutes);
  final String secondsText = _padTwoDigits(seconds);

  if (hours > 0) {
    return '$hoursText:$minutesText:$secondsText';
  }
  return '$minutesText:$secondsText';
}

String _padTwoDigits(int number) {
  return number.toString().padLeft(2, '0');
}
