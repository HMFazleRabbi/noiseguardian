import 'dart:convert';

/// Deterministic JSON encoder with lexicographically sorted keys at every level.
String canonicalJsonEncode(Map<String, dynamic> value) {
  return jsonEncode(_sortMap(value));
}

dynamic _sortValue(dynamic value) {
  if (value is Map) {
    return _sortMap(Map<String, dynamic>.from(value));
  }
  if (value is List) {
    return value.map(_sortValue).toList();
  }
  return value;
}

Map<String, dynamic> _sortMap(Map<String, dynamic> map) {
  final sortedKeys = map.keys.toList()..sort();
  final result = <String, dynamic>{};
  for (final key in sortedKeys) {
    result[key] = _sortValue(map[key]);
  }
  return result;
}
