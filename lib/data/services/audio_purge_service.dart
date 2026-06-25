import 'dart:io';

import 'package:noise_guardian/core/logging/app_log.dart';

/// Securely deletes temporary audio after feature extraction (Module C).
class AudioPurgeService {
  const AudioPurgeService();

  /// Deletes [filePath] unless [consentToRetain] is true.
  ///
  /// Returns true if the file no longer exists after the call.
  Future<bool> purge({
    required String filePath,
    bool consentToRetain = false,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return true;
    }

    if (consentToRetain) {
      await appLogInfo(
        'purge',
        'Audio retained per user consent',
        data: {'path': filePath},
      );
      return false;
    }

    await file.delete();
    await appLogInfo(
      'purge',
      'Temp audio securely deleted',
      data: {'path': filePath},
    );
    return !(await file.exists());
  }
}
