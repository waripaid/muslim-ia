import 'dart:async';

import 'package:flutter/services.dart';

class DeepLinkService {
  DeepLinkService._();

  static const MethodChannel _channel = MethodChannel('muslimia/deeplinks');
  static final StreamController<String> _controller =
      StreamController<String>.broadcast();

  static Stream<String> get onLink => _controller.stream;

  static void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNewIntentLink') {
        final link = call.arguments;
        if (link is String && link.isNotEmpty) {
          _controller.add(link);
        }
      }
    });
  }

  static Future<String?> getInitialLink() async {
    try {
      return await _channel.invokeMethod<String>('getInitialLink');
    } catch (_) {
      return null;
    }
  }
}
