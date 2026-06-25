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
  String get captureRecording => 'রেকর্ড হচ্ছে…';

  @override
  String get captureLaeqMeterLabel => 'LAeq স্তর মিটার';

  @override
  String get guardOk =>
      'রেকর্ডের জন্য প্রস্তুত — ফোন সোজা ~১.৫ মি উচ্চতায় ধরুন।';

  @override
  String get guardMuffled => 'ডিভাইস মাফল করা মনে হচ্ছে — মাইক্রোফোন খুলে নিন।';

  @override
  String get guardPocketed => 'ফোন পকেটে মনে হচ্ছে — বের করে সোজা ধরুন।';

  @override
  String get guardObscured => 'অতিরিক্ত নড়াচড়া সনাক্ত — স্থিরভাবে ধরুন।';

  @override
  String get voicePromptReady => 'রেকর্ডের জন্য প্রস্তুত। ফোন সোজা ধরুন।';

  @override
  String get voicePromptMuffled => 'চালিয়ে যেতে মাইক্রোফোন খুলে নিন।';

  @override
  String get voicePromptPocketed => 'ফোন পকেট থেকে বের করুন।';

  @override
  String get voicePromptObscured => 'ফোন স্থিরভাবে ধরুন।';

  @override
  String get voicePromptCaptureComplete => 'প্রমাণ সফলভাবে সংগ্রহ হয়েছে।';

  @override
  String get onboardingTitle => 'নয়েজগার্ডিয়ানে স্বাগতম';

  @override
  String get onboardingIconLabel => 'নয়েজগার্ডিয়ান লোগো';

  @override
  String get onboardingConsentIntro =>
      'শুরু করার আগে, বাংলাদেশের ব্যক্তিগত তথ্য সুরক্ষা অধ্যাদেশ (PDPO) ২০২৫ অনুযায়ী নয়েজগার্ডিয়ান কীভাবে আপনার তথ্য পরিচালনা করে তা পর্যালোচনা করুন।';

  @override
  String get onboardingPurgePolicy =>
      'অডিও পরিষ্কার: বৈশিষ্ট্য বের করার পরে কাঁচা অডিও অবিলম্বে মুছে ফেলা হয়। শুধুমাত্র স্বাক্ষরিত প্রমাণ প্যাকেট (LAeq, শ্রেণি, অস্পষ্ট অবস্থান) স্থানীয়ভাবে সংরক্ষিত হয়।';

  @override
  String get onboardingPdpoRights =>
      'আপনার অধিকার: DoE পোর্টালের মাধ্যমে আপনি জমা দেওয়া প্রমাণের অ্যাক্সেস, সংশোধন বা মুছে ফেলার অনুরোধ করতে পারেন। সেটিংসে সম্মতি প্রত্যাহার করতে পারেন।';

  @override
  String get onboardingDataUse =>
      'তথ্য ব্যবহার: প্রমাণ প্রয়োগের জন্য পরিবেশ অধিদপ্তরের সাথে সিঙ্ক হয়। GPS স্থানাঙ্ক ডিভাইস ছাড়ার আগে ~১০০ মি পর্যন্ত অস্পষ্ট করা হয়।';

  @override
  String get onboardingAgree => 'আমি সম্মত — রেকর্ড শুরু করুন';

  @override
  String get onboardingDecline => 'প্রত্যাখ্যান';

  @override
  String get historySync => 'সিঙ্ক';

  @override
  String get historyEmpty => 'এখনও কোনো প্রমাণ সারিতে নেই।';

  @override
  String get historyExportPdf => 'PDF রপ্তানি';

  @override
  String historyLaeqSubtitle(String value) {
    return 'LAeq $value dB(A)';
  }

  @override
  String get statusPending => 'অপেক্ষমাণ';

  @override
  String get statusSyncing => 'সিঙ্ক হচ্ছে';

  @override
  String get statusSynced => 'সিঙ্ক হয়েছে';

  @override
  String get statusFailed => 'ব্যর্থ';

  @override
  String get heatmapEmpty => 'হিটম্যাপের জন্য এখনও সিঙ্ক করা প্রমাণ নেই।';

  @override
  String get heatmapMapLegend =>
      'সবুজ: সীমার নিচে · হলুদ: উচ্চ · লাল: খুব উচ্চ';

  @override
  String heatmapCellCount(int count) {
    return 'n=$count';
  }

  @override
  String heatmapCellAvg(String value) {
    return 'গড় $value dB';
  }

  @override
  String heatmapCellMax(String value) {
    return 'সর্বোচ্চ $value dB';
  }

  @override
  String heatmapCellViolations(int count) {
    return 'লঙ্ঘন $count';
  }

  @override
  String get settingsLowDataMode => 'কম-ডেটা মোড (শুধু WiFi সিঙ্ক)';

  @override
  String get settingsLowDataHint =>
      'ব্যান্ডউইথ বাঁচাতে মোবাইল ডেটায় সিঙ্ক ব্লক করে।';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageBn => 'বাংলা';

  @override
  String get settingsMockDoeStatus =>
      'স্থানীয় Mock DoE ব্যবহার হচ্ছে (অফলাইন সিঙ্ক)';

  @override
  String get settingsExportLastPdf => 'সর্বশেষ সিঙ্ক PDF রপ্তানি';

  @override
  String get settingsNoSyncedEvidence => 'রপ্তানির জন্য সিঙ্ক করা প্রমাণ নেই।';

  @override
  String get settingsDebugLog => 'ডিবাগ লগ (লাইভ)';

  @override
  String get settingsCopyPath => 'পথ কপি করুন';

  @override
  String get settingsClearLog => 'লগ মুছুন';

  @override
  String get settingsRefreshLog => 'রিফ্রেশ';

  @override
  String get settingsLogPathCopied => 'লগ ফাইলের পথ কপি হয়েছে';

  @override
  String get settingsNoLogLines => 'এখনও কোনো লগ লাইন নেই';
}
