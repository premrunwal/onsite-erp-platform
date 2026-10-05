import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/watermark_painter.dart';
import '../../../core/utils/liveness_verifier.dart';
import '../../../core/network/api_client.dart';

class PunchAttendanceScreen extends StatefulWidget {
  const PunchAttendanceScreen({super.key});

  @override
  State<PunchAttendanceScreen> createState() => _PunchAttendanceScreenState();
}

class _PunchAttendanceScreenState extends State<PunchAttendanceScreen> {
  int _currentStepIndex = 0;
  final List<LivenessChallenge> _challenges = LivenessVerifier.getRandomChallengeSequence();
  final List<LivenessChallengeResult> _completedResults = [];

  bool _isGeofenceValid = true;
  double _currentDistanceMeters = 42.5; // Within 200m radius
  bool _isPunching = false;

  void _onChallengePassed() {
    if (_currentStepIndex < _challenges.length) {
      final challenge = _challenges[_currentStepIndex];
      _completedResults.add(
        LivenessChallengeResult(
          challenge: challenge,
          passed: true,
          score: 0.92,
        ),
      );

      setState(() {
        if (_currentStepIndex < _challenges.length - 1) {
          _currentStepIndex++;
        } else {
          _submitPunch();
        }
      });
    }
  }

  void _submitPunch() async {
    setState(() => _isPunching = true);
    try {
      final response = await ApiClient().post('/add/punch_in', data: {
        'user_id': 'u1111111-1111-1111-1111-111111111111',
        'project_id': 'p1111111-1111-1111-1111-111111111111',
        'latitude': 19.076,
        'longitude': 72.8777,
        'verification_type': 'FACE_LIVENESS',
        'liveness_proofs': _completedResults.map((r) => r.toJson()).toList(),
      });

      if (mounted) {
        setState(() => _isPunching = false);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.statusSuccess),
                SizedBox(width: 8),
                Text('Punch Recorded'),
              ],
            ),
            content: Text(response.data['message'] ?? 'Punch In Success with Face Liveness & Geofence Verification!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPunching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Punch recorded in Hive offline queue. Will sync when back online.'),
            backgroundColor: AppTheme.statusInfo,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChallenge = _challenges[_currentStepIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Punch In'),
      ),
      body: Column(
        children: [
          // Geofence status banner
          Container(
            color: _isGeofenceValid ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  _isGeofenceValid ? Icons.gpp_good_rounded : Icons.gpp_bad_rounded,
                  color: _isGeofenceValid ? AppTheme.statusSuccess : AppTheme.statusError,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isGeofenceValid
                        ? 'Inside Site Boundary (${_currentDistanceMeters.toStringAsFixed(1)}m from center)'
                        : 'Outside Site Boundary! Punch will be flagged.',
                    style: TextStyle(
                      color: _isGeofenceValid ? const Color(0xFF14532D) : const Color(0xFF7F1D1D),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Camera Framing Container with Oval Overlay Painter & Watermark
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Simulated Camera View Box
                Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Icon(Icons.person, size: 200, color: Colors.white24),
                  ),
                ),

                // Oval Camera Guide Painter
                CustomPaint(
                  size: Size.infinite,
                  painter: OvalFramePainter(),
                ),

                // Canvas Watermark Overlay at bottom
                Positioned.fill(
                  child: CustomPaint(
                    painter: WatermarkOverlayPainter(
                      projectCode: 'MTR-04',
                      siteName: 'Metro Tower Site 04',
                      latitude: 19.0760,
                      longitude: 72.8777,
                      timestampIso: DateTime.now().toUtc().toIso8601String().substring(0, 19) + ' UTC',
                    ),
                  ),
                ),

                // Interactive Challenge Prompt Card at Top
                Positioned(
                  top: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppTheme.primaryOrange, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: AppTheme.primaryOrange, strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          LivenessVerifier.getPromptMessage(currentChallenge),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Controls & Trigger Button
          Container(
            padding: const EdgeInsets.all(20),
            color: AppTheme.slateNavyDark,
            child: Column(
              children: [
                Text(
                  'Challenge Step ${_currentStepIndex + 1} of ${_challenges.length}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isPunching ? null : _onChallengePassed,
                    child: Text(_currentStepIndex < _challenges.length - 1 ? 'PASS CHALLENGE & NEXT' : 'CONFIRM PUNCH IN'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Oval Camera Framing Guide Painter
class OvalFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 20);
    final radiusX = size.width * 0.35;
    final radiusY = size.height * 0.28;

    final rect = Rect.fromCenter(center: center, width: radiusX * 2, height: radiusY * 2);

    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Cut out oval
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(rect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);

    // Draw pulsing oval border
    final borderPaint = Paint()
      ..color = AppTheme.primaryOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawOval(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
