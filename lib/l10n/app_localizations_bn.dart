// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'নয়েজগার্ডিয়ান';

  @override
  String get navCapture => 'রেকর্ড';

  @override
  String get navHistory => 'ইতিহাস';

  @override
  String get navHeatmap => 'হিটম্যাপ';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get captureTitle => 'প্রমাণ সংগ্রহ';

  @override
  String get historyTitle => 'প্রমাণের ইতিহাস';

  @override
  String get heatmapTitle => 'শব্দ হিটম্যাপ';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get calibrationTitle => 'মাইক্রোফোন ক্যালিব্রেশন';

  @override
  String get calibrationIntro =>
      'শান্ত স্থানে রেফারেন্স পিঙ্ক নয়েজ বাজান। অ্যাপটি আপনার মাইক্রোফোনের প্রতিক্রিয়া মাপে এবং সংশোধনী (Cd) সংরক্ষণ করে।';

  @override
  String get calibrationStart => 'ক্যালিব্রেশন শুরু করুন';

  @override
  String get calibrationDone => 'সম্পন্ন';

  @override
  String get calibrationRetry => 'আবার ক্যালিব্রেট করুন';

  @override
  String get calibrationOpen => 'মাইক্রোফোন ক্যালিব্রেট করুন';

  @override
  String calibrationCurrentCd(String value) {
    return 'বর্তমান Cd: $value dB';
  }

  @override
  String calibrationSuccess(String value) {
    return 'ক্যালিব্রেশন সংরক্ষিত। Cd = $value dB';
  }

  @override
  String get captureRecord => 'প্রমাণ রেকর্ড করুন';

  @override
  String captureLaeq(String value) {
    return 'LAeq: $value dB(A)';
  }

  @override
  String captureClassLabel(String label) {
    return 'শ্রেণি: $label';
  }

  @override
  String captureConfidence(String value) {
    return 'আত্মবিশ্বাস: $value%';
  }

  @override
  String get guardOk =>
      'রেকর্ডের জন্য প্রস্তুত — ফোন সোজা ~১.৫ মি উচ্চতায় ধরুন।';

  @override
  String get guardMuffled => 'ডিভাইস মাফল করা মনে হচ্ছে — মাইক্রোফোন খুলে নিন।';

  @override
  String get guardPocketed => 'ফোন পকেটে মনে হচ্ছে — বের করে সোজা ধরুন।';

  @override
  String get guardObscured => 'অতিরিক্ত নড়াচড়া সনাক্ত — স্থিরভাবে ধরুন।';
}
