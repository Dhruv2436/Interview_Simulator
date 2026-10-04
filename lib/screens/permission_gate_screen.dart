import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animate_do/animate_do.dart';

/// Shown before the interview starts.
/// Requests CAMERA and MICROPHONE permissions dynamically.
/// Only navigates forward when both are granted.
class PermissionGateScreen extends StatefulWidget {
  final Widget destination;
  final String candidateName;
  final String company;
  final String role;

  const PermissionGateScreen({
    super.key,
    required this.destination,
    required this.candidateName,
    required this.company,
    required this.role,
  });

  @override
  State<PermissionGateScreen> createState() => _PermissionGateScreenState();
}

class _PermissionGateScreenState extends State<PermissionGateScreen>
    with TickerProviderStateMixin {
  PermissionStatus _cameraStatus = PermissionStatus.denied;
  PermissionStatus _micStatus = PermissionStatus.denied;
  bool _isChecking = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _checkCurrentStatus();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkCurrentStatus() async {
    final cam = await Permission.camera.status;
    final mic = await Permission.microphone.status;
    if (mounted) {
      setState(() {
        _cameraStatus = cam;
        _micStatus = mic;
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() => _isChecking = true);
    final results = await [Permission.camera, Permission.microphone].request();
    if (mounted) {
      setState(() {
        _cameraStatus = results[Permission.camera] ?? PermissionStatus.denied;
        _micStatus = results[Permission.microphone] ?? PermissionStatus.denied;
        _isChecking = false;
      });
    }
  }

  bool get _allGranted =>
      _cameraStatus.isGranted && _micStatus.isGranted;

  void _proceed() {
    if (_allGranted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => widget.destination),
      );
    } else {
      _requestPermissions();
    }
  }

  void _openAppSettings() async {
    await openAppSettings();
    await Future.delayed(const Duration(seconds: 1));
    await _checkCurrentStatus();
  }

  Color _statusColor(PermissionStatus s) {
    if (s.isGranted) return const Color(0xFF10B981);
    if (s.isPermanentlyDenied) return Colors.redAccent;
    return Colors.orange;
  }

  IconData _statusIcon(PermissionStatus s) {
    if (s.isGranted) return Icons.check_circle_rounded;
    if (s.isPermanentlyDenied) return Icons.block_rounded;
    return Icons.access_time_rounded;
  }

  String _statusText(PermissionStatus s) {
    if (s.isGranted) return 'Granted';
    if (s.isPermanentlyDenied) return 'Permanently Denied';
    if (s.isDenied) return 'Not Granted';
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Header Icon with pulse animation
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, child) => Container(
                    padding: EdgeInsets.all(20 + 4 * _pulseController.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6366F1).withValues(alpha: 0.15 + 0.05 * _pulseController.value),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.security_rounded,
                        size: 60, color: Color(0xFF6366F1)),
                  ),
                ),

                const SizedBox(height: 28),

                FadeInDown(
                  child: const Text(
                    'Permission Required',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'To conduct a fair AI interview with proctoring,\n${widget.company} requires camera and microphone access.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Interview Info Card
                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_rounded,
                                color: Color(0xFF6366F1), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(widget.candidateName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.business_rounded,
                                color: Color(0xFF10B981), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                  '${widget.company} — ${widget.role}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Permission Cards
                FadeInUp(
                  delay: const Duration(milliseconds: 220),
                  child: _permissionCard(
                    icon: Icons.videocam_rounded,
                    title: 'Camera',
                    subtitle: 'Required for live proctoring & face verification',
                    status: _cameraStatus,
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 280),
                  child: _permissionCard(
                    icon: Icons.mic_rounded,
                    title: 'Microphone',
                    subtitle: 'Required for voice responses & speech recognition',
                    status: _micStatus,
                  ),
                ),

                const SizedBox(height: 32),

                // Action Button
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: SizedBox(
                    width: double.infinity,
                    child: _isChecking
                        ? Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Checking Permissions...',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _allGranted ? _proceed : _requestPermissions,
                            icon: Icon(
                              _allGranted
                                  ? Icons.rocket_launch_rounded
                                  : Icons.security_rounded,
                              color: Colors.white,
                            ),
                            label: Text(
                              _allGranted
                                  ? 'Launch AI Interview'
                                  : 'Grant Permissions',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _allGranted
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF6366F1),
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 6,
                            ),
                          ),
                  ),
                ),

                // Open Settings fallback
                if (_cameraStatus.isPermanentlyDenied ||
                    _micStatus.isPermanentlyDenied) ...[
                  const SizedBox(height: 16),
                  FadeIn(
                    child: TextButton.icon(
                      onPressed: _openAppSettings,
                      icon: const Icon(Icons.settings_rounded,
                          color: Colors.orange, size: 18),
                      label: const Text(
                        'Open App Settings to Grant Permissions',
                        style: TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Info note
                FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: Colors.blueGrey, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your camera and microphone data are processed locally on-device for proctoring. '
                            'No video or audio is recorded or stored remotely.',
                            style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 12,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _permissionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required PermissionStatus status,
  }) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Icon(_statusIcon(status), color: color, size: 20),
              const SizedBox(height: 3),
              Text(_statusText(status),
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
