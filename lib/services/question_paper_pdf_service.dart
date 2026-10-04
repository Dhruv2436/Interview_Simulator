import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/question_paper_model.dart';

class QuestionPaperPdfService {
  /// Generates academic solution PDF and opens printer/download share preview
  static Future<void> generateAndDownloadPdf({
    required QuestionPaperSolution solution,
  }) async {
    final pdf = pw.Document();

    final info = QuestionPaperInfo(
      universityName: _cleanPdfText(solution.info.universityName),
      department: _cleanPdfText(solution.info.department),
      subjectName: _cleanPdfText(solution.info.subjectName),
      subjectCode: _cleanPdfText(solution.info.subjectCode),
      semester: _cleanPdfText(solution.info.semester),
      examination: _cleanPdfText(solution.info.examination),
      date: _cleanPdfText(solution.info.date),
      time: _cleanPdfText(solution.info.time),
      totalMarks: _cleanPdfText(solution.info.totalMarks),
      language: _cleanPdfText(solution.info.language),
      instructions: solution.info.instructions.map((e) => _cleanPdfText(e)).toList(),
    );

    final questions = solution.questions.map((q) => QuestionItem(
      qNumber: _cleanPdfText(q.qNumber),
      subNumber: _cleanPdfText(q.subNumber),
      marks: q.marks,
      questionText: _cleanPdfText(q.questionText),
      isOr: q.isOr,
      orGroup: q.orGroup != null ? _cleanPdfText(q.orGroup!) : null,
      answer: _cleanPdfText(q.answer),
      formulaWorking: q.formulaWorking != null ? _cleanPdfText(q.formulaWorking!) : null,
      codeSnippet: q.codeSnippet != null ? _cleanPdfText(q.codeSnippet!) : null,
      algorithmSteps: q.algorithmSteps?.map((e) => _cleanPdfText(e)).toList(),
      flowchartText: q.flowchartText != null ? _cleanPdfText(q.flowchartText!) : null,
      comparisonTable: q.comparisonTable?.map((row) => row.map((cell) => _cleanPdfText(cell)).toList()).toList(),
    )).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          if (context.pageNumber == 1) {
            return pw.SizedBox.shrink();
          }
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "QUESTION PAPER SOLUTION - ${info.subjectName} (${info.subjectCode})",
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo800,
                    ),
                  ),
                  pw.Text(
                    "SEM-${info.semester} | ${info.examination}",
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(color: PdfColors.indigo200, thickness: 0.8),
              pw.SizedBox(height: 6),
            ],
          );
        },
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Exam Ready Solution Paper | Question Paper Solver",
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
          // ── Academic Cover Header Card ──
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.indigo50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.indigo300, width: 1.2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  info.universityName.toUpperCase(),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo900,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  "DEPARTMENT OF ${info.department.toUpperCase()}",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo700,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  "QUESTION PAPER SOLUTION",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo900,
                    letterSpacing: 1.1,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  height: 2,
                  width: 140,
                  color: PdfColors.indigo600,
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.indigo200,
                    width: 0.5,
                  ),
                  children: [
                    _buildHeaderRow("Subject:", info.subjectName,
                        "Subject Code:", info.subjectCode),
                    _buildHeaderRow("Semester:", "Semester - ${info.semester}",
                        "Examination:", info.examination),
                    _buildHeaderRow("Total Marks:", "${info.totalMarks} Marks",
                        "Exam Time:", info.time.isNotEmpty ? info.time : "02:30 Hours"),
                  ],
                ),
              ],
            ),
          ),

          if (info.instructions.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Instructions / Note:",
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                  ...info.instructions.map((inst) => pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 2),
                        child: pw.Text(
                          "• $inst",
                          style: const pw.TextStyle(
                              fontSize: 8, color: PdfColors.grey700),
                        ),
                      )),
                ],
              ),
            ),
          ],

          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColors.indigo400, thickness: 1.5),
          pw.SizedBox(height: 16),

          // ── Questions & Answers Loop ──
          ...questions.map((q) => _buildQuestionBlock(q)),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'Solution_${info.subjectCode}_${info.subjectName.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.TableRow _buildHeaderRow(
      String label1, String val1, String label2, String val2) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.RichText(
            text: pw.TextSpan(children: [
              pw.TextSpan(
                text: "$label1 ",
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo900),
              ),
              pw.TextSpan(
                text: val1,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey900),
              ),
            ]),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.RichText(
            text: pw.TextSpan(children: [
              pw.TextSpan(
                text: "$label2 ",
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo900),
              ),
              pw.TextSpan(
                text: val2,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey900),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildQuestionBlock(QuestionItem q) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // If OR question, show clear OR divider
          if (q.isOr) ...[
            pw.Center(
              child: pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 12),
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 24, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange50,
                  border: pw.Border.all(color: PdfColors.orange400, width: 1),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(
                  "OR",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.orange900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],

          // Question Header Line: e.g. Q.1 (a) — 03 Marks
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: q.isOr ? PdfColors.orange100 : PdfColors.indigo100,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(
                color: q.isOr ? PdfColors.orange400 : PdfColors.indigo300,
                width: 1,
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "${q.qNumber} ${q.subNumber}",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: q.isOr ? PdfColors.orange900 : PdfColors.indigo900,
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: q.marks == 7
                        ? PdfColors.purple700
                        : q.marks == 4
                            ? PdfColors.blue700
                            : PdfColors.teal700,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    "${q.marks.toString().padLeft(2, '0')} Marks",
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 6),

          // Question text
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 4),
            child: pw.RichText(
              text: pw.TextSpan(children: [
                pw.TextSpan(
                  text: "Question: ",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                  ),
                ),
                pw.TextSpan(
                  text: q.questionText,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo900,
                  ),
                ),
              ]),
            ),
          ),

          pw.SizedBox(height: 8),

          // Answer Section Box
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Answer:",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  q.answer,
                  style: const pw.TextStyle(
                    fontSize: 9.5,
                    color: PdfColors.grey900,
                    lineSpacing: 2,
                  ),
                ),

                // Step-by-Step Mathematical Calculation / Working Section
                if (q.formulaWorking != null && q.formulaWorking!.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    "Mathematical Formula & Step-by-Step Working:",
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: PdfColors.blue200, width: 0.6),
                    ),
                    child: pw.Text(
                      q.formulaWorking!,
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ),
                ],

                // Algorithm Section
                if (q.algorithmSteps != null && q.algorithmSteps!.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    "Algorithm → Steps:",
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo800,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  ...q.algorithmSteps!.map((step) => pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 6, bottom: 2),
                        child: pw.Text(
                          step,
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.indigo900,
                          ),
                        ),
                      )),
                ],

                // Flowchart Diagram Section
                if (q.flowchartText != null && q.flowchartText!.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    "Flowchart → Logic Flow:",
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal800,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.teal50,
                      borderRadius: pw.BorderRadius.circular(4),
                      border:
                          pw.Border.all(color: PdfColors.teal200, width: 0.6),
                    ),
                    child: pw.Text(
                      q.flowchartText!,
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                  ),
                ],

                // Comparison Table Section
                if (q.comparisonTable != null &&
                    q.comparisonTable!.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Table(
                    border:
                        pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                    children: q.comparisonTable!.asMap().entries.map((entry) {
                      final isHeader = entry.key == 0;
                      final row = entry.value;
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: isHeader
                              ? PdfColors.indigo100
                              : (entry.key % 2 == 0
                                  ? PdfColors.grey100
                                  : PdfColors.white),
                        ),
                        children: row.map((cell) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              cell,
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                fontWeight: isHeader
                                    ? pw.FontWeight.bold
                                    : pw.FontWeight.normal,
                                color: isHeader
                                    ? PdfColors.indigo900
                                    : PdfColors.grey900,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ],

                // Code Snippet Section
                if (q.codeSnippet != null && q.codeSnippet!.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    "Program / Code Implementation:",
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo800,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey900,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      q.codeSnippet!,
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.green300,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
