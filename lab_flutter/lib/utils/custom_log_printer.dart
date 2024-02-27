import 'package:logger/logger.dart';

class CustomLogPrinter extends LogPrinter {
  final PrettyPrinter _prettyPrinter = PrettyPrinter();

  @override
  List<String> log(LogEvent event) {
    if (event.level == Level.info) {
      // Custom format for info logs
      var color = PrettyPrinter.levelColors[event.level];
      var emoji = PrettyPrinter.levelEmojis[event.level];
      return [color!('$emoji ${event.message}')];
    } else {
      // Default format for other logs
      return _prettyPrinter.log(event);
    }
  }
}
