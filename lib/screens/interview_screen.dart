import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'final_dashboard_screen.dart';
import '../services/openai_service.dart';
import '../services/voice_service.dart';
import '../services/face_detector_service.dart';


class InterviewScreen extends StatefulWidget {
  final String topic;
  final String userName;
  final String company;
  final String role;
  final String difficulty;
  final Map<String, dynamic>? candidateProfile;
  final int aptitudeScore;
  final int numAptitude;
  final int technicalScore;
  final int numTechnical;
  final double overallPercentage;

  const InterviewScreen({
    super.key,
    this.topic = "Software Engineer",
    this.userName = "Candidate",
    this.company = "Tech Company",
    this.role = "Software Engineer",
    this.difficulty = "Intermediate",
    this.candidateProfile,
    this.aptitudeScore = 0,
    this.numAptitude = 10,
    this.technicalScore = 0,
    this.numTechnical = 10,
    this.overallPercentage = 80.0,
  });

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final OpenAIService _openAIService = OpenAIService();
  final VoiceService _voiceService = VoiceService();
  final FaceDetectorService _faceDetectorService = FaceDetectorService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  bool _isLoading = false;
  late String _currentQuestion;
  String _userResponse = "";
  bool _isListening = false;
  bool _isTypingMode = false;
  final List<Map<String, String>> _history = [];
  final List<Map<String, dynamic>> _evaluations = [];
  Map<String, dynamic>? _lastEvaluation;
  bool _isFinished = false;
  bool _hasStarted = false;
  int _questionNumber = 0;
  // NEW: whether the current Q has been evaluated and is waiting for "Next Q"
  bool _awaitingNextQuestion = false;

  // Face analytics
  RealFaceAnalytics _faceAnalytics = RealFaceAnalytics.empty();

  // Animation
  late AnimationController _micPulseController;
  bool _isAISpeaking = false;

  @override
  void initState() {
    super.initState();
    _currentQuestion =
        "Welcome to your ${widget.company} AI Interview Round, ${widget.userName}. "
        "I will evaluate your technical depth, problem-solving approach, and communication skills. "
        "Let's begin: Please introduce yourself and describe your most impactful technical project.";
    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _faceAnalytics = RealFaceAnalytics.verified();
        });
        _startRealFaceStream(frontCamera);
      }
    } catch (_) {}
  }

  Timer? _webFaceTimer;

  void _startRealFaceStream(CameraDescription camera) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      _webFaceTimer?.cancel();
      _webFaceTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (!mounted || _isFinished) {
          timer.cancel();
          return;
        }
        final analytics = _faceDetectorService.getWebProctoringAnalytics();
        if (mounted) setState(() => _faceAnalytics = analytics);
      });
      return;
    }

    _cameraController!.startImageStream((CameraImage image) async {
      if (!mounted || _isFinished) return;
      final rotation =
          _rotationIntToImageRotation(camera.sensorOrientation);
      final size = Size(
        _cameraController!.value.previewSize?.width ?? 640,
        _cameraController!.value.previewSize?.height ?? 480,
      );
      final analytics = await _faceDetectorService.processCameraImage(
        image,
        rotation,
        camera.lensDirection,
        size,
      );
      if (mounted) setState(() => _faceAnalytics = analytics);
    });
  }

  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  @override
  void dispose() {
    _webFaceTimer?.cancel();
    _cameraController?.dispose();
    _faceDetectorService.dispose();
    _voiceService.stop();
    _textController.dispose();
    _chatScrollController.dispose();
    _micPulseController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────
  // INTERVIEW FLOW
  // ─────────────────────────────────────────────────────────────────────

  void _startInterview() async {
    setState(() {
      _hasStarted = true;
      _isAISpeaking = true;
    });
    await _voiceService.speak(_currentQuestion);
    setState(() => _isAISpeaking = false);
    _waitForAIAndListen();
  }

  void _waitForAIAndListen() async {
    await _voiceService.waitUntilSilent();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted && _hasStarted && !_isFinished) {
      _startListeningAutomatically();
    }
  }

  void _startListeningAutomatically() {
    if (_isListening || _isTypingMode) return;
    setState(() {
      _userResponse = "";
      _isListening = true;
    });
    _voiceService.startListening(
      onResult: (text) {
        if (mounted) setState(() => _userResponse = text);
      },
      onDone: () {
        if (mounted && _isListening && _userResponse.trim().length > 5) {
          _submitResponse();
        }
      },
    );
  }

  void _submitResponse() async {
    _voiceService.stopListening();
    final answer =
        _isTypingMode ? _textController.text.trim() : _userResponse.trim();
    if (answer.isEmpty) return;

    setState(() {
      _isListening = false;
      _isLoading = true;
      _isTypingMode = false;
      _userResponse = answer;
      _awaitingNextQuestion = false;
    });

    try {
      final eval = await _openAIService.evaluateAnswerStructured(
        question: _currentQuestion,
        answer: answer,
      );

      _evaluations.add({
        ...eval,
        'question': _currentQuestion,
        'answer': answer,
        'questionNumber': _questionNumber + 1,
      });

      _history.add({'role': 'assistant', 'content': _currentQuestion});
      _history.add({'role': 'user', 'content': answer});

      // Speak feedback
      final score = eval['score'] as int? ?? 0;
      final spokenFeedback = score >= 7
          ? "Good answer! ${eval['strengths']}. Next question coming up."
          : "Response noted. ${eval['improvements']}. Let's continue."
      ;

      setState(() {
        _isLoading = false;
        _lastEvaluation = eval;
        _awaitingNextQuestion = true; // Wait for user to tap Next
      });

      await _voiceService.speak(spokenFeedback);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Called by both auto-flow and "Next Question" button
  void _nextQuestion() async {
    setState(() => _isLoading = true);
    try {
      final profile = widget.candidateProfile ??
          {
            'name': widget.userName,
            'skills': [widget.topic],
            'projects': ['System Design'],
          };

      final nextQ = await _openAIService.generateInterviewQuestionDynamic(
        candidateProfile: profile,
        technicalDomain: widget.topic,
        scorePercentage: widget.overallPercentage,
        conversationHistory: _history,
      );

      setState(() {
        _currentQuestion = nextQ;
        _userResponse = "";
        _textController.clear();
        _lastEvaluation = null;
        _isLoading = false;
        _questionNumber++;
      });

      setState(() => _isAISpeaking = true);
      await _voiceService.speak(nextQ);
      setState(() => _isAISpeaking = false);
      _waitForAIAndListen();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleTypingMode() {
    _voiceService.stopListening();
    setState(() {
      _isListening = false;
      _isTypingMode = !_isTypingMode;
    });
  }

  void _endInterview() {
    _voiceService.stop();
    _voiceService.stopListening();
    setState(() {
      _isFinished = true;
      _isListening = false;
      _isAISpeaking = false;
    });
  }

  // ─────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_hasStarted) return _buildStartGate();
    if (_isFinished) return _buildFinalReport();
    return _buildInterviewUI();
  }

  // ─────────────────────────────────────────────────────────────────────
  // START GATE
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildStartGate() {
    final profile = widget.candidateProfile;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              FadeInDown(
                child: const Icon(Icons.face_retouching_natural,
                    size: 80, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 20),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  "Candidate: ${widget.userName}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  "${widget.company} — ${widget.role} (${widget.difficulty})",
                  style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  "Assessment Score: ${widget.overallPercentage.toStringAsFixed(1)}% (PASS)",
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
              const SizedBox(height: 32),

              // Candidate Info Card
              if (profile != null)
                FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(Icons.school_rounded, "Education",
                            profile['education'] ?? 'N/A'),
                        const SizedBox(height: 8),
                        _infoRow(Icons.work_history_rounded, "Experience",
                            profile['experience'] ?? 'N/A'),
                        const SizedBox(height: 8),
                        _infoRow(Icons.code_rounded, "Skills",
                            (profile['skills'] is List &&
                                    (profile['skills'] as List).isNotEmpty)
                                ? (profile['skills'] as List).take(6).join(', ')
                                : 'N/A'),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 350),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _startInterview,
                    icon: const Icon(Icons.verified_user, color: Colors.white),
                    label: const Text(
                      "Launch AI Technical Interview",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
              Text(value,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // MAIN INTERVIEW UI
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildInterviewUI() {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Fullscreen Camera Preview
            Positioned.fill(
              child: _isCameraInitialized
                  ? ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width:
                                _cameraController!.value.previewSize?.height ??
                                    1,
                            height:
                                _cameraController!.value.previewSize?.width ??
                                    1,
                            child: CameraPreview(_cameraController!),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF0F172A),
                      child: const Center(
                          child: Icon(Icons.videocam_off,
                              color: Colors.white24, size: 80)),
                    ),
            ),

            // Dark gradient overlay at top and bottom
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withValues(alpha: 0.92),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55],
                  ),
                ),
              ),
            ),

            // Top header
            Positioned(
              top: 10,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _topBadge(
                    Icons.badge,
                    widget.userName,
                    const Color(0xFF6366F1),
                  ),
                  // Q counter badge
                  _topBadge(
                    Icons.help_outline_rounded,
                    "Q ${_questionNumber + 1}",
                    Colors.orange,
                  ),
                  // Face status (Clickable toggle for Web/Testing)
                  // Face status badge (Always green and friendly)
                  GestureDetector(
                    onTap: () {
                      _faceDetectorService.toggleWebFacePresence();
                      setState(() {
                        _faceAnalytics =
                            _faceDetectorService.getWebProctoringAnalytics();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.face,
                            color: Color(0xFF10B981),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _faceAnalytics.isFaceDetected
                                ? _faceAnalytics.estimatedEmotion.toUpperCase()
                                : "FACE DETECTED",
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 10,
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

            // AI Question Box
            Positioned(
              top: 52,
              left: 14,
              right: 14,
              child: FadeInDown(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _micPulseController,
                              builder: (_, _) => Icon(
                                _isAISpeaking
                                    ? Icons.volume_up_rounded
                                    : Icons.smart_toy,
                                color: _isAISpeaking
                                    ? Color.lerp(
                                        const Color(0xFF6366F1),
                                        Colors.white,
                                        _micPulseController.value,
                                      )
                                    : const Color(0xFF6366F1),
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isAISpeaking
                                  ? "AI IS SPEAKING..."
                                  : "AI INTERVIEWER",
                              style: TextStyle(
                                color: _isAISpeaking
                                    ? Colors.white
                                    : const Color(0xFF6366F1),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentQuestion,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13, height: 1.4),
                        ),
                        if (_lastEvaluation != null) ...[
                          const Divider(color: Colors.white24, height: 12),
                          Row(
                            children: [
                              const Icon(Icons.thumb_up_rounded,
                                  color: Colors.greenAccent, size: 11),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                    "Strength: ${_lastEvaluation!['strengths']}",
                                    style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 10)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.trending_up_rounded,
                                  color: Colors.orangeAccent, size: 11),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                    "Improve: ${_lastEvaluation!['improvements']}",
                                    style: const TextStyle(
                                        color: Colors.orangeAccent,
                                        fontSize: 10)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Face bounding box overlay (Always green)
            if (_isCameraInitialized)
              Positioned(
                top: 268,
                left: (MediaQuery.of(context).size.width - 240) / 2,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF10B981),
                      width: 2.5,
                    ),
                  ),
                ),
              ),

            // Friendly Face Guidance Banner
            Positioned(
              top: 275,
              left: 20,
              right: 20,
              child: FadeInDown(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B).withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.center_focus_strong_rounded,
                          color: Color(0xFF34D399), size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Keep face in front of camera",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Speech preview box
            if (!_isTypingMode)
              Positioned(
                bottom: 100,
                left: 14,
                right: 14,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 100),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isListening
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF6366F1).withValues(alpha: 0.5),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isListening ? Icons.mic : Icons.chat,
                                  color: _isListening
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF6366F1),
                                  size: 12,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _isListening
                                      ? "LISTENING... (LIVE TRANSCRIPT)"
                                      : "RESPONSE PREVIEW",
                                  style: TextStyle(
                                    color: _isListening
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF6366F1),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            if (_isListening)
                              const SpinKitPulse(
                                  color: Color(0xFFEF4444), size: 12),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _userResponse.isNotEmpty
                              ? _userResponse
                              : (_isListening
                                  ? "Listening... Speak your response."
                                  : "Tap microphone to record or keyboard to type."),
                          style: TextStyle(
                            color: _userResponse.isNotEmpty
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 12,
                            fontStyle: _userResponse.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Typing input
            if (_isTypingMode)
              Positioned(
                bottom: 100,
                left: 14,
                right: 14,
                child: FadeInUp(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF6366F1)),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: TextField(
                        controller: _textController,
                        autofocus: true,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        onChanged: (val) =>
                            setState(() => _userResponse = val),
                        decoration: const InputDecoration(
                          hintText: "Type your detailed answer here...",
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ),
                ),
              ),

            // Evaluation result panel (shown after submitting, waiting for next Q)
            if (_awaitingNextQuestion && _lastEvaluation != null)
              Positioned(
                bottom: 90,
                left: 14,
                right: 14,
                child: FadeInUp(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (_lastEvaluation!['score'] as int? ?? 0) >= 7
                            ? const Color(0xFF10B981)
                            : (_lastEvaluation!['score'] as int? ?? 0) >= 5
                                ? Colors.orange
                                : Colors.redAccent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "✅ ANSWER EVALUATED",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: (_lastEvaluation!['score'] as int? ?? 0) >= 7
                                    ? const Color(0xFF10B981).withValues(alpha: 0.25)
                                    : (_lastEvaluation!['score'] as int? ?? 0) >= 5
                                        ? Colors.orange.withValues(alpha: 0.25)
                                        : Colors.redAccent.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Score: ${_lastEvaluation!['score']}/10",
                                style: TextStyle(
                                  color: (_lastEvaluation!['score'] as int? ?? 0) >= 7
                                      ? const Color(0xFF10B981)
                                      : (_lastEvaluation!['score'] as int? ?? 0) >= 5
                                          ? Colors.orange
                                          : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.thumb_up_rounded, color: Colors.greenAccent, size: 12),
                          const SizedBox(width: 5),
                          Expanded(child: Text("${_lastEvaluation!['strengths']}", style: const TextStyle(color: Colors.greenAccent, fontSize: 11, height: 1.4))),
                        ]),
                        const SizedBox(height: 4),
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.trending_up, color: Colors.orangeAccent, size: 12),
                          const SizedBox(width: 5),
                          Expanded(child: Text("${_lastEvaluation!['improvements']}", style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, height: 1.4))),
                        ]),
                        const SizedBox(height: 4),
                        if (_lastEvaluation!['feedback'] != null)
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Icon(Icons.info_outline, color: Colors.blueAccent, size: 12),
                            const SizedBox(width: 5),
                            Expanded(child: Text("${_lastEvaluation!['feedback']}", style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.4))),
                          ]),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom action bar
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // End interview
                  _roundBtn(
                    icon: Icons.stop_circle_rounded,
                    color: Colors.redAccent,
                    label: "End",
                    onTap: () => _showEndConfirmDialog(),
                  ),
                  const SizedBox(width: 8),

                  // Toggle: SUBMIT or NEXT QUESTION
                  Expanded(
                    child: _awaitingNextQuestion
                        ? ElevatedButton.icon(
                            onPressed: _isLoading ? null : () {
                              setState(() {
                                _awaitingNextQuestion = false;
                                _lastEvaluation = null;
                              });
                              _nextQuestion();
                            },
                            icon: const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 18),
                            label: const Text(
                              "NEXT QUESTION",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 0.8),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _isLoading ? null : _submitResponse,
                            icon: const Icon(Icons.send_rounded,
                                color: Colors.white, size: 18),
                            label: const Text(
                              "SUBMIT ANSWER",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 0.8),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                            ),
                          ),
                  ),

                  const SizedBox(width: 8),

                  // Voice / keyboard toggle (only when not awaiting)
                  if (!_awaitingNextQuestion)
                    _roundBtn(
                      icon: _isTypingMode ? Icons.mic : Icons.keyboard,
                      color: _isTypingMode
                          ? const Color(0xFF6366F1)
                          : Colors.blueGrey,
                      label: _isTypingMode ? "Voice" : "Text",
                      onTap: _toggleTypingMode,
                    ),
                ],
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SpinKitFadingCircle(color: Colors.white, size: 50),
                        SizedBox(height: 14),
                        Text(
                          "Evaluating response & generating next question...",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // FINAL REPORT
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildFinalReport() {
    return FinalDashboardScreen(
      mcqScore: widget.technicalScore + widget.aptitudeScore,
      totalMcq: widget.numTechnical + widget.numAptitude,
      candidateProfile: widget.candidateProfile ?? {'name': widget.userName},
      technicalDomain: widget.topic,
      evaluations: _evaluations,
      faceAnalytics: _faceAnalytics,
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // HELPER WIDGETS
  // ─────────────────────────────────────────────────────────────────────

  Widget _topBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _roundBtn({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1.0,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.5),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ),
    );
  }



  // Confirmation dialog before ending
  Future<void> _showEndConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("End Interview?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          "Are you sure you want to end the interview?\n"
          "You have answered ${_evaluations.length} question(s) so far.\n"
          "The final report will be generated immediately.",
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Continue", style: TextStyle(color: Color(0xFF6366F1))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("End & Generate Report",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) _endInterview();
  }
}
