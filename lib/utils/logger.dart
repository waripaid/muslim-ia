import 'package:flutter/foundation.dart';

class AppLogger {
  static const _prefix = 'MuslimIA';

  static void info(String module, String msg) => debugPrint('$_prefix | ℹ️  $module | $msg');
  static void success(String module, String msg) => debugPrint('$_prefix | ✅ $module | $msg');
  static void warn(String module, String msg) => debugPrint('$_prefix | ⚠️  $module | $msg');
  static void error(String module, String msg, [Object? e]) => debugPrint('$_prefix | ❌ $module | $msg${e != null ? ' | $e' : ''}');
  static void api(String method, String path, int status, int duration) => debugPrint('$_prefix | 📡 $method $path → $status (${duration}ms)');
  static void stream(String module, String msg) => debugPrint('$_prefix | 📝 $module | $msg');
  static void start(String module, String msg) => debugPrint('$_prefix | 🚀 $module | $msg');
}
