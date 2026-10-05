import 'package:flutter/material.dart';

class WatermarkOverlayPainter extends CustomPainter {
  final String projectCode;
  final String siteName;
  final double latitude;
  final double longitude;
  final String timestampIso;
  final String verificationTag;

  WatermarkOverlayPainter({
    required this.projectCode,
    required this.siteName,
    required this.latitude,
    required this.longitude,
    required this.timestampIso,
    this.verificationTag = 'VERIFIED PUNCH',
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double padding = 16.0;
    const double barHeight = 60.0;

    // Background semi-transparent dark banner at bottom
    final bgPaint = Paint()
      ..color = const Color(0xCC0F172A) // 80% opacity Slate Navy
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, size.height - barHeight, size.width, barHeight);
    canvas.drawRect(rect, bgPaint);

    // Accent left stripe (Construction Orange)
    final accentPaint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, size.height - barHeight, 6, barHeight), accentPaint);

    // Build text payload
    final latStr = '${latitude.abs().toStringAsFixed(4)}° ${latitude >= 0 ? 'N' : 'S'}';
    final lngStr = '${longitude.abs().toStringAsFixed(4)}° ${longitude >= 0 ? 'E' : 'W'}';

    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: '[$projectCode] - $siteName\n',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: 'LAT: $latStr | LON: $lngStr | $timestampIso | ',
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 10,
          ),
        ),
        TextSpan(
          text: verificationTag,
          style: const TextStyle(
            color: Color(0xFF22C55E), // Green status
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 2,
    );

    textPainter.layout(maxWidth: size.width - (padding * 2));
    textPainter.paint(canvas, Offset(16, size.height - barHeight + 12));
  }

  @override
  bool shouldRepaint(covariant WatermarkOverlayPainter oldDelegate) {
    return oldDelegate.timestampIso != timestampIso ||
        oldDelegate.latitude != latitude ||
        oldDelegate.longitude != longitude;
  }
}
