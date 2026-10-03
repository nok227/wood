class Dim {
  final double mm;
  final double cm;
  final double m;

  const Dim._(this.mm, this.cm, this.m);

  factory Dim.from(double value, String unit) {
    final u = unit.toLowerCase().trim();
    switch (u) {
      case 'mm':
        return Dim._(value, value / 10, value / 1000);
      case 'cm':
        return Dim._(value * 10, value, value / 100);
      case 'm':
        return Dim._(value * 1000, value * 100, value);
      default:
        return Dim._(value, value / 10, value / 1000);
    }
  }

  String get full => '${_f(mm)}mm (${_f(cm)}cm / ${_f(m)}m)';
  String get mmS => _f(mm);
  String get cmS => _f(cm);
  String get mS => _f(m);

  static String _f(double n) {
    if (n == n.roundToDouble()) return n.toStringAsFixed(0);
    return n
        .toStringAsFixed(4)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

String dimConversions(double w, double l, double t, String unit) {
  final wD = Dim.from(w, unit);
  final lD = Dim.from(l, unit);
  final tD = Dim.from(t, unit);
  final u = unit.toLowerCase().trim();

  if (u == 'mm') {
    return '${wD.cmS}×${lD.cmS}×${tD.cmS} cm  ·  ${wD.mS}×${lD.mS}×${tD.mS} m';
  }
  if (u == 'cm') {
    return '${wD.mmS}×${lD.mmS}×${tD.mmS} mm  ·  ${wD.mS}×${lD.mS}×${tD.mS} m';
  }
  return '${wD.mmS}×${lD.mmS}×${tD.mmS} mm  ·  ${wD.cmS}×${lD.cmS}×${tD.cmS} cm';
}

String fmtNum(num v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();