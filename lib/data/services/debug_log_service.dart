import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warn, error }

/// Persistent debug logger that flushes each line immediately for real-time tailing.
abstract class DebugLogService {
  Future<void> init();

  Future<void> dispose();

  String? get logFilePath;

  Stream<String> get lineStream;

  Future<void> debug(
    String category,
    String message, {
    Map<String, Object?>? data,
  });

  Future<void> info(
    String category,
    String message, {
    Map<String, Object?>? data,
  });

  Future<void> warn(
    String category,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  });

  Future<void> error(
    String category,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  });

  Future<List<String>> readTail({int lines = 100});

  Future<void> clear();
}

class FileDebugLogService implements DebugLogService {
  FileDebugLogService({
    this.fileName = 'noise_guardian_debug.log',
    Directory? logDirectory,
  }) : _logDirectory = logDirectory;

  final String fileName;
  final Directory? _logDirectory;
  final StreamController<String> _lineController =
      StreamController<String>.broadcast();

  IOSink? _sink;
  File? _logFile;
  bool _initialized = false;

  static const int _maxBytes = 2 * 1024 * 1024;

  @override
  String? get logFilePath => _logFile?.path;

  @override
  Stream<String> get lineStream => _lineController.stream;

  @override
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    final directory = _logDirectory ?? await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/$fileName');
    await _rotateIfNeeded();
    _sink = _logFile!.openWrite(mode: FileMode.append, encoding: utf8);
    _initialized = true;

    await _writeLine(
      LogLevel.info,
      'logger',
      'Debug log initialized',
      data: {
        'path': _logFile!.path,
        'platform': Platform.operatingSystem,
        'debugMode': kDebugMode,
      },
    );
  }

  @override
  Future<void> dispose() async {
    if (_initialized) {
      await _writeLine(LogLevel.info, 'logger', 'Debug log closing');
    }
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
    _initialized = false;
    await _lineController.close();
  }

  @override
  Future<void> debug(
    String category,
    String message, {
    Map<String, Object?>? data,
  }) =>
      _writeLine(LogLevel.debug, category, message, data: data);

  @override
  Future<void> info(
    String category,
    String message, {
    Map<String, Object?>? data,
  }) =>
      _writeLine(LogLevel.info, category, message, data: data);

  @override
  Future<void> warn(
    String category,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) =>
      _writeLine(
        LogLevel.warn,
        category,
        message,
        error: error,
        stackTrace: stackTrace,
        data: data,
      );

  @override
  Future<void> error(
    String category,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) =>
      _writeLine(
        LogLevel.error,
        category,
        message,
        error: error,
        stackTrace: stackTrace,
        data: data,
      );

  @override
  Future<List<String>> readTail({int lines = 100}) async {
    final file = _logFile;
    if (file == null || !await file.exists()) {
      return const [];
    }

    final content = await file.readAsLines();
    if (content.length <= lines) {
      return content;
    }
    return content.sublist(content.length - lines);
  }

  @override
  Future<void> clear() async {
    await _sink?.flush();
    await _sink?.close();
    _sink = null;

    final file = _logFile;
    if (file != null && await file.exists()) {
      await file.writeAsString('', encoding: utf8);
    }

    _sink = file?.openWrite(mode: FileMode.append, encoding: utf8);
    await info('logger', 'Debug log cleared');
  }

  Future<void> _rotateIfNeeded() async {
    final file = _logFile;
    if (file == null || !await file.exists()) {
      return;
    }

    final length = await file.length();
    if (length < _maxBytes) {
      return;
    }

    final backup = File('${file.path}.old');
    if (await backup.exists()) {
      await backup.delete();
    }
    await file.rename(backup.path);
  }

  Future<void> _writeLine(
    LogLevel level,
    String category,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) async {
    final timestamp = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(
      DateTime.now(),
    );
    final buffer = StringBuffer()
      ..write('$timestamp [${level.name.toUpperCase()}] [$category] $message');

    if (data != null && data.isNotEmpty) {
      buffer.write(' | data=${jsonEncode(data)}');
    }
    if (error != null) {
      buffer.write(' | error=$error');
    }
    if (stackTrace != null) {
      buffer.write(' | stack=${stackTrace.toString().replaceAll('\n', ' / ')}');
    }

    final line = buffer.toString();

    if (kDebugMode) {
      debugPrint(line);
    }

    if (_initialized && _sink != null) {
      _sink!.writeln(line);
      await _sink!.flush();
    }

    if (!_lineController.isClosed) {
      _lineController.add(line);
    }
  }
}

/// No-op logger for widget tests.
class NoopDebugLogService implements DebugLogService {
  @override
  String? get logFilePath => null;

  @override
  Stream<String> get lineStream => const Stream.empty();

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> debug(
    String category,
    String message, {
    Map<String, Object?>? data,
  }) async {}

  @override
  Future<void> info(
    String category,
    String message, {
    Map<String, Object?>? data,
  }) async {}

  @override
  Future<void> warn(
    String category,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) async {}

  @override
  Future<void> error(
    String category,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) async {}

  @override
  Future<List<String>> readTail({int lines = 100}) async => const [];

  @override
  Future<void> clear() async {}
}
