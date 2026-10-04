import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import '../models/question_paper_model.dart';
import '../services/question_paper_service.dart';
import '../services/question_paper_pdf_service.dart';

class QuestionPaperSolverScreen extends StatefulWidget {
  const QuestionPaperSolverScreen({super.key});

  @override
  State<QuestionPaperSolverScreen> createState() =>
      _QuestionPaperSolverScreenState();
}

class _QuestionPaperSolverScreenState
    extends State<QuestionPaperSolverScreen> {
  final TextEditingController _paperTextController = TextEditingController();

  bool _isLoading = false;
  String _loadingMessage = 'Processing Question Paper...';
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;

  QuestionPaperSolution? _solution;

  @override
  void dispose() {
    _paperTextController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'txt'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFileName = file.name;
          _selectedFileBytes = file.bytes;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loaded file: ${file.name}'),
              backgroundColor: const Color(0xFF4F46E5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('File picker error: $e');
    }
  }

  Future<void> _processQuestionPaper({String? sampleType}) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Analyzing question paper format...';
    });

    try {
      if (sampleType != null) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          setState(() {
            _loadingMessage = 'Generating marks-oriented answers...';
          });
        }
        await Future.delayed(const Duration(milliseconds: 400));

        final QuestionPaperSolution result;
        if (sampleType == 'electrical') {
          result = QuestionPaperService.getElectricalSampleSolution();
        } else if (sampleType == 'math') {
          result = QuestionPaperService.getMathSampleSolution();
        } else {
          result = QuestionPaperService.getSampleGtuSolution();
        }

        if (mounted) {
          setState(() {
            _solution = result;
            _isLoading = false;
          });
        }
        return;
      }

      final String customText = _paperTextController.text.trim();

      if (mounted) {
        setState(() {
          _loadingMessage = 'Extracting questions & marks allocation...';
        });
      }

      final result = await QuestionPaperService.solveQuestionPaper(
        rawText: customText.isNotEmpty ? customText : null,
        fileBytes: _selectedFileBytes,
        fileName: _selectedFileName,
      );

      if (mounted) {
        setState(() {
          _solution = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error solving question paper: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to solve question paper: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _generatePdf() async {
    if (_solution == null) return;
    try {
      await QuestionPaperPdfService.generateAndDownloadPdf(solution: _solution!);
    } catch (e) {
      debugPrint('PDF Generation Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 1.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Text('📄 ', style: TextStyle(fontSize: 20)),
            Text(
              'Question Paper Solver',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1B4B),
              ),
            ),
          ],
        ),
        actions: [
          if (_solution != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4F46E5)),
              tooltip: 'Reset Input',
              onPressed: () {
                setState(() {
                  _solution = null;
                  _selectedFileName = null;
                  _selectedFileBytes = null;
                  _paperTextController.clear();
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingWidget()
            : _solution == null
                ? _buildInputSection()
                : _buildSolutionPreviewSection(),
      ),
      bottomNavigationBar: (_solution != null && !_isLoading)
          ? Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _generatePdf,
                    icon: const Icon(Icons.picture_as_pdf_rounded,
                        color: Colors.white, size: 22),
                    label: const Text(
                      'Generate Solution PDF',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      elevation: 4,
                      shadowColor: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 3.5,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              _loadingMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Generating marks-based answers (3, 4, and 7 marks)...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Card ──
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.menu_book_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GTU & University Solver',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Marks-oriented academic solutions',
                              style: TextStyle(
                                color: Color(0xFFE0E7FF),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Upload your exam question paper to automatically generate a complete solution PDF with 3, 4 & 7 mark tailored answers.',
                    style: TextStyle(
                      color: Color(0xFFEEF2FF),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Quick Load Multi-Department Demo Papers ──
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 400),
            child: Card(
              elevation: 0,
              color: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.school_rounded,
                              color: Color(0xFF4F46E5), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explore Department Sample Solutions',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                'Tap any department to test instant solution model',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildDemoChip(
                          label: '💻 Computer (Python)',
                          color: const Color(0xFF059669),
                          onTap: () => _processQuestionPaper(sampleType: 'computer'),
                        ),
                        _buildDemoChip(
                          label: '⚡ Electrical (BEE)',
                          color: const Color(0xFFD97706),
                          onTap: () => _processQuestionPaper(sampleType: 'electrical'),
                        ),
                        _buildDemoChip(
                          label: '📐 Mathematics (Maths-I)',
                          color: const Color(0xFF2563EB),
                          onTap: () => _processQuestionPaper(sampleType: 'math'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Upload Card ──
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            duration: const Duration(milliseconds: 400),
            child: const Text(
              'Upload Question Paper File',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1B4B),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 400),
            child: InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedFileName != null
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFFCBD5E1),
                    width: _selectedFileName != null ? 2.0 : 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFileName != null
                          ? Icons.check_circle_rounded
                          : Icons.cloud_upload_outlined,
                      size: 40,
                      color: _selectedFileName != null
                          ? const Color(0xFF10B981)
                          : const Color(0xFF4F46E5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedFileName ?? 'Tap to select PDF / Image / Scanned Paper',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selectedFileName != null
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Supports .pdf, .jpg, .png, .txt files',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Text Input Area ──
          FadeInUp(
            delay: const Duration(milliseconds: 250),
            duration: const Duration(milliseconds: 400),
            child: const Text(
              'OR Paste Question Paper Text',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1B4B),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 400),
            child: TextField(
              controller: _paperTextController,
              maxLines: 5,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText:
                    'Paste question paper content here...\ne.g. Q.1 (a) [03 Marks] List features of Python\n(b) [04 Marks] Draw flowchart...\n(c) [07 Marks] Explain statements...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: Color(0xFF4F46E5), width: 1.8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── Submit Button ──
          FadeInUp(
            delay: const Duration(milliseconds: 350),
            duration: const Duration(milliseconds: 400),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _processQuestionPaper(),
                icon: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 20),
                label: const Text(
                  'Solve & Generate Answers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  elevation: 4,
                  shadowColor: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSolutionPreviewSection() {
    final info = _solution!.info;
    final questions = _solution!.questions;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Academic Header Summary Card ──
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEEF2FF), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          info.subjectName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Code: ${info.subjectCode}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildInfoBadge('Sem ${info.semester}'),
                      const SizedBox(width: 8),
                      _buildInfoBadge(info.examination),
                      const SizedBox(width: 8),
                      _buildInfoBadge('${info.totalMarks} Marks'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exam Questions & Answers (${questions.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1B4B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Marks Tailored',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Questions Cards List ──
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final q = questions[index];
              return _buildQuestionCard(q);
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuestionItem q) {
    final Color badgeColor = q.marks == 7
        ? const Color(0xFF7C3AED)
        : q.marks == 4
            ? const Color(0xFF2563EB)
            : const Color(0xFF0D9488);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: q.isOr ? const Color(0xFFFDE68A) : const Color(0xFFF1F5F9),
          width: q.isOr ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // OR Banner if applicable
          if (q.isOr) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: const Center(
                child: Text(
                  'OR ALTERNATIVE QUESTION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Title & Marks Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${q.qNumber} ${q.subNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${q.marks.toString().padLeft(2, '0')} Marks',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Question Text
                Text(
                  q.questionText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Answer Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              color: Color(0xFF10B981), size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Exam Answer:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        q.answer,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                          height: 1.5,
                        ),
                      ),

                      // Mathematical Formula & Step-by-Step Calculations if present
                      if (q.formulaWorking != null &&
                          q.formulaWorking!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Mathematical Formula & Working:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: SelectableText(
                            q.formulaWorking!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E40AF),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],

                      // Algorithm Steps if present
                      if (q.algorithmSteps != null &&
                          q.algorithmSteps!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Algorithm → Steps:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...q.algorithmSteps!.map((step) => Padding(
                              padding:
                                  const EdgeInsets.only(left: 4, bottom: 2),
                              child: Text(
                                step,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            )),
                      ],

                      // Flowchart representation if present
                      if (q.flowchartText != null &&
                          q.flowchartText!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Flowchart → Logic Flow:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCFBF1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            q.flowchartText!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        ),
                      ],

                      // Code Snippet container if present
                      if (q.codeSnippet != null &&
                          q.codeSnippet!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Code Implementation:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SelectableText(
                            q.codeSnippet!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11.5,
                              color: Color(0xFF86EFAC),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoChip({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
