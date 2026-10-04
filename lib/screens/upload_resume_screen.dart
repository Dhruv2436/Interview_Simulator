import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'ats_checker_screen.dart';
import '../services/openai_service.dart';
import '../models/candidate_model.dart';

class UploadResumeScreen extends StatefulWidget {
  final String role;
  final String experienceLevel;
  final String difficultyLevel;

  const UploadResumeScreen({
    super.key,
    required this.role,
    required this.experienceLevel,
    required this.difficultyLevel,
  });

  @override
  State<UploadResumeScreen> createState() => _UploadResumeScreenState();
}

class _UploadResumeScreenState extends State<UploadResumeScreen> {
  String? _fileName;
  String? _fileSize;
  Uint8List? _fileBytes;
  bool _isAnalyzing = false;
  final TextEditingController _jdController = TextEditingController();
  bool _jdExpanded = false;

  @override
  void dispose() {
    _jdController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );

    if (result != null) {
      final file = result.files.single;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null && !kIsWeb) {
        try {
          bytes = await File(file.path!).readAsBytes();
        } catch (e) {
          debugPrint('Error reading file from path on mobile: $e');
        }
      }

      setState(() {
        _fileBytes = bytes;
        _fileName = file.name;
        final kb = file.size / 1024;
        _fileSize = '${kb.toStringAsFixed(0)} KB';
      });
    }
  }

  Future<void> _processResume() async {
    setState(() => _isAnalyzing = true);
    try {
      // 1. Extract resume text
      String resumeText = '';
      if (_fileBytes != null) {
        try {
          final document = PdfDocument(inputBytes: _fileBytes!);
          resumeText = PdfTextExtractor(document).extractText();
          document.dispose();
        } catch (e) {
          debugPrint('PDF parsing failed: $e');
        }
      }

      if (resumeText.trim().isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not extract text from PDF. Try a text-based PDF (not a scanned image).'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }

      final service = OpenAIService();
      final jobDescription = _jdController.text.trim();

      // 2. Parse resume details (name, email, skills, etc.)
      final parsedResume = await service.analyzeResumeDetailed(resumeText);
      final resumeData = ResumeData.fromParsedMap(parsedResume, rawText: resumeText);

      ATSAnalysisResult analysis;

      if (jobDescription.isNotEmpty && resumeText.isNotEmpty) {
        // 3a. AI ATS scoring (JD vs Resume via Gemini/OpenRouter)
        final atsMap = await service.performATSScoring(
          resumeText: resumeText,
          jobDescription: jobDescription,
        );
        final matched = (atsMap['matched_skills'] as List?)?.cast<String>() ?? [];
        final missing = (atsMap['missing_skills'] as List?)?.cast<String>() ?? [];

        // If ALL scores are 0 the API failed silently — fall back to keyword scoring
        final eduScore = (atsMap['education_score'] as int?) ?? 0;
        final skiScore = (atsMap['skills_score'] as int?) ?? 0;
        final expScore = (atsMap['experience_score'] as int?) ?? 0;

        if (eduScore == 0 && skiScore == 0 && expScore == 0) {
          debugPrint('ATS: AI returned all zeros — falling back to keyword scoring');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('AI scoring unavailable. Using keyword-based ATS scoring.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          analysis = ATSAnalysisResult.calculate(resumeData, widget.role);
        } else {
          analysis = ATSAnalysisResult.fromAtsMap(atsMap, matched, missing);
        }
      } else {
        // 3b. Fallback: keyword-based scoring against selected role
        analysis = ATSAnalysisResult.calculate(resumeData, widget.role);
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ATSCheckerScreen(
              role: widget.role,
              analysis: analysis,
              resumeData: resumeData,
              jobDescription: jobDescription,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('_processResume error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: ${e.toString().split('\n').first}'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: const Text(
                  'Upload Your Resume',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: const Text(
                  'Upload your resume and optionally paste a job\ndescription for a precise ATS score.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Upload Area
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF5B42FA).withAlpha(128),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_upload_outlined, size: 48, color: Color(0xFF5B42FA)),
                        const SizedBox(height: 16),
                        const Text(
                          'Drag & Drop your resume\nhere',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('or', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B42FA),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'Choose File',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 250),
                child: const Center(
                  child: Text(
                    'Supported formats: PDF, DOC, DOCX  (Max size: 10MB)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                  ),
                ),
              ),

              if (_fileName != null) ...[
                const SizedBox(height: 16),
                FadeIn(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Colors.grey, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _fileName!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _fileSize ?? '',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => setState(() {
                            _fileName = null;
                            _fileSize = null;
                            _fileBytes = null;
                          }),
                        )
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Job Description Collapsible Section
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: () => setState(() => _jdExpanded = !_jdExpanded),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B42FA).withAlpha(13),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF5B42FA).withAlpha(77)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined, color: Color(0xFF5B42FA), size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paste Job Description',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5B42FA),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'For precise ATS scoring (optional)',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _jdExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: const Color(0xFF5B42FA),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_jdExpanded) ...[
                const SizedBox(height: 12),
                FadeIn(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _jdController,
                      maxLines: 8,
                      style: const TextStyle(fontSize: 13, height: 1.6),
                      decoration: const InputDecoration(
                        hintText: 'Paste the job description here...\n\nExample:\n• 3+ years of Flutter experience\n• Strong knowledge of REST APIs\n• Experience with Firebase...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              FadeInUp(
                delay: const Duration(milliseconds: 350),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_fileName == null || _isAnalyzing) ? null : _processResume,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B42FA),
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isAnalyzing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Analyzing with AI...',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          )
                        : Text(
                            'Analyze Resume',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _fileName == null ? Colors.grey.shade500 : Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
