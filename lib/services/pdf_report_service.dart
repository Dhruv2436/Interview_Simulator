import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/face_detector_service.dart';

class PdfReportGenerator {
  /// Generates and shares/prints the full interview assessment report as a PDF.
  /// Includes: extracted resume info, per-section scores, strengths, weaknesses,
  /// recommendations, and all per-question evaluations.
  static Future<void> generateAndSharePdfReport({
    required BuildContext context,
    required String candidateName,
    required String targetCompany,
    required String targetRole,
    required double overallScore,
    required RealFaceAnalytics faceAnalytics,
    required List<Map<String, dynamic>> evaluations,
    required Map<String, dynamic> candidateProfile,
    required Map<String, dynamic> report,
  }) async {
    final pdf = pw.Document();

    final String email = candidateProfile['email'] as String? ?? 'N/A';
    final String phone = candidateProfile['phone'] as String? ?? 'N/A';
    final String education = candidateProfile['education'] as String? ?? 'N/A';
    final String experience = candidateProfile['experience'] as String? ?? 'N/A';
    final List<String> skills = (candidateProfile['skills'] is List)
        ? (candidateProfile['skills'] as List).cast<String>()
        : [];
    final List<String> projects = (candidateProfile['projects'] is List)
        ? (candidateProfile['projects'] as List).cast<String>()
        : [];
    final List<String> certs = (candidateProfile['certifications'] is List)
        ? (candidateProfile['certifications'] as List).cast<String>()
        : [];

    final int mcqPercent = report['mcqScorePercent'] as int? ?? 0;
    final int voicePercent = report['voiceScorePercent'] as int? ?? 0;
    final double commRating =
        (report['communicationRating'] as num? ?? 0).toDouble();
    final double techRating =
        (report['technicalDepthRating'] as num? ?? 0).toDouble();
    final double confRating =
        (report['confidenceRating'] as num? ?? 0).toDouble();
    final String recommendation =
        report['hiringRecommendation'] as String? ?? 'Borderline';
    final String summary = report['summary'] as String? ?? '';
    final List<String> strengths =
        (report['keyStrengths'] as List<String>?) ?? [];
    final List<String> improvements =
        (report['areasForImprovement'] as List<String>?) ?? [];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "AI Interview Assessment Report",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo800,
                  ),
                ),
                pw.Text(
                  "Score: ${overallScore.toStringAsFixed(0)}%",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: overallScore >= 70
                        ? PdfColors.green700
                        : PdfColors.orange700,
                  ),
                ),
              ],
            ),
            pw.Divider(color: PdfColors.indigo200),
            pw.SizedBox(height: 4),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Enterprise AI Interview Simulator | Generated: ${DateTime.now().toLocal().toString().substring(0, 16)}",
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  "Page ${context.pageNumber} of ${context.pagesCount}",
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
        build: (context) => [
          // ── Section 1: Candidate Profile ──
          _sectionHeader("1. Candidate Profile"),
          _infoTable([
            ["Full Name", candidateName],
            ["Email", email],
            ["Phone", phone],
            ["Education", education],
            ["Experience", experience],
            ["Target Company", targetCompany],
            ["Target Role", targetRole],
          ]),
          pw.SizedBox(height: 6),
          if (skills.isNotEmpty)
            _labeledParagraph("Skills", skills.join(' • ')),
          if (projects.isNotEmpty)
            _labeledParagraph("Projects", projects.join(' | ')),
          if (certs.isNotEmpty)
            _labeledParagraph("Certifications", certs.join(' | ')),

          pw.SizedBox(height: 16),

          // ── Section 2: MCQ Assessment ──
          _sectionHeader("2. MCQ Assessment Performance"),
          _infoTable([
            ["Overall MCQ Score", "$mcqPercent%"],
          ]),

          pw.SizedBox(height: 16),

          // ── Section 3: Per-Question Evaluations ──
          _sectionHeader("3. AI Interview — Per-Question Evaluations"),
          ...evaluations.asMap().entries.map((entry) {
            final i = entry.key;
            final ev = entry.value;
            final score = ev['score'] as int? ?? 0;
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Question ${i + 1}",
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.indigo700,
                              fontSize: 11)),
                      pw.Text("Score: $score / 10",
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: score >= 8
                                  ? PdfColors.green700
                                  : score >= 6
                                      ? PdfColors.orange700
                                      : PdfColors.red700,
                              fontSize: 11)),
                    ],
                  ),
                  if (ev['question'] != null) ...[
                    pw.SizedBox(height: 4),
                    pw.Text("Q: ${ev['question']}",
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey700)),
                  ],
                  if (ev['answer'] != null) ...[
                    pw.SizedBox(height: 3),
                    pw.Text("A: ${ev['answer']}",
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey600)),
                  ],
                  pw.SizedBox(height: 5),
                  pw.Bullet(
                    text: "Strength: ${ev['strengths'] ?? 'N/A'}",
                    bulletColor: PdfColors.green700,
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.green800),
                  ),
                  pw.Bullet(
                    text: "Improve: ${ev['improvements'] ?? 'N/A'}",
                    bulletColor: PdfColors.orange700,
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.orange800),
                  ),
                  if (ev['feedback'] != null)
                    pw.Bullet(
                      text: "Feedback: ${ev['feedback']}",
                      bulletColor: PdfColors.blue700,
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.blue800),
                    ),
                ],
              ),
            );
          }),

          pw.SizedBox(height: 10),

          // ── Section 4: Overall Ratings ──
          _sectionHeader("4. Overall Skill Ratings"),
          _infoTable([
            ["Communication", "${commRating.toStringAsFixed(1)} / 10"],
            ["Technical Depth", "${techRating.toStringAsFixed(1)} / 10"],
            ["Confidence", "${confRating.toStringAsFixed(1)} / 10"],
            ["MCQ Score", "$mcqPercent%"],
            ["Interview Score", "$voicePercent%"],
            ["Overall Score", "${overallScore.toStringAsFixed(0)}%"],
          ]),

          pw.SizedBox(height: 16),

          // ── Section 5: Biometric Proctoring ──
          _sectionHeader("5. Biometric Proctoring Summary"),
          _infoTable([
            ["Candidate Presence", faceAnalytics.presenceStatus],
            ["Head Pose", faceAnalytics.headPoseStatus],
            ["Eye Contact",
                "${faceAnalytics.eyeContactPercentage.toStringAsFixed(1)}%"],
            ["Emotion", faceAnalytics.estimatedEmotion],
            ["Attention Score",
                "${faceAnalytics.attentionScore.toStringAsFixed(1)}%"],
            [
              "Proctoring Status",
              faceAnalytics.faceCount <= 1 ? "PASSED" : "VIOLATION"
            ],
          ]),

          pw.SizedBox(height: 16),

          // ── Section 6: Strengths ──
          _sectionHeader("6. Key Strengths"),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: strengths
                .map((s) => pw.Bullet(
                      text: s,
                      bulletColor: PdfColors.green700,
                      style: const pw.TextStyle(
                          fontSize: 11, color: PdfColors.green900),
                    ))
                .toList(),
          ),

          pw.SizedBox(height: 10),

          // ── Section 7: Areas for Improvement ──
          _sectionHeader("7. Areas for Improvement"),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: improvements
                .map((s) => pw.Bullet(
                      text: s,
                      bulletColor: PdfColors.orange700,
                      style: const pw.TextStyle(
                          fontSize: 11, color: PdfColors.orange900),
                    ))
                .toList(),
          ),

          pw.SizedBox(height: 16),

          // ── Hiring Recommendation ──
          _sectionHeader("8. Hiring Recommendation"),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: recommendation.contains("Strong Hire") ||
                      recommendation == "Hire"
                  ? PdfColors.green50
                  : recommendation == "No Hire"
                      ? PdfColors.red50
                      : PdfColors.orange50,
              border: pw.Border.all(
                color: recommendation.contains("Strong Hire") ||
                        recommendation == "Hire"
                    ? PdfColors.green700
                    : recommendation == "No Hire"
                        ? PdfColors.red700
                        : PdfColors.orange700,
                width: 2,
              ),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  recommendation.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: recommendation.contains("Strong Hire") ||
                            recommendation == "Hire"
                        ? PdfColors.green800
                        : recommendation == "No Hire"
                            ? PdfColors.red800
                            : PdfColors.orange800,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  summary,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                      fontSize: 11, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'AI_Interview_Report_${candidateName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────

  static pw.Widget _sectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: PdfColors.indigo50,
        border: const pw.Border(
          left: pw.BorderSide(color: PdfColors.indigo700, width: 4),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.indigo800,
        ),
      ),
    );
  }

  static pw.Widget _infoTable(List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
      },
      children: rows
          .map((row) => pw.TableRow(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 5),
                  child: pw.Text(row[0],
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 5),
                  child: pw.Text(row[1],
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey900)),
                ),
              ]))
          .toList(),
    );
  }

  static pw.Widget _labeledParagraph(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: "$label: ",
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800),
            ),
            pw.TextSpan(
              text: value,
              style: const pw.TextStyle(
                  fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    );
  }
}
