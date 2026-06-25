/// On-device acoustic classification labels (Module C).
enum NoiseClass {
  piling,
  generator,
  crusher,
  ambient,
}

extension NoiseClassLabel on NoiseClass {
  String get displayName {
    switch (this) {
      case NoiseClass.piling:
        return 'Piling hammers';
      case NoiseClass.generator:
        return 'Diesel generator';
      case NoiseClass.crusher:
        return 'Stone/brick crusher';
      case NoiseClass.ambient:
        return 'Ambient city noise';
    }
  }
}
