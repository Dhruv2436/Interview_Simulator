class QuestionPaperInfo {
  final String universityName;
  final String department;
  final String subjectName;
  final String subjectCode;
  final String semester;
  final String examination;
  final String date;
  final String time;
  final String totalMarks;
  final String language;
  final List<String> instructions;

  QuestionPaperInfo({
    this.universityName = 'Gujarat Technological University',
    this.department = 'Computer Engineering',
    required this.subjectName,
    required this.subjectCode,
    required this.semester,
    required this.examination,
    this.date = '',
    this.time = '',
    this.totalMarks = '70',
    this.language = 'English',
    this.instructions = const [],
  });

  factory QuestionPaperInfo.fromJson(Map<String, dynamic> json) {
    return QuestionPaperInfo(
      universityName: json['universityName']?.toString() ??
          'Gujarat Technological University',
      department:
          json['department']?.toString() ?? 'Engineering & Technology',
      subjectName: json['subjectName']?.toString() ?? 'University Subject',
      subjectCode: json['subjectCode']?.toString() ?? 'CODE-101',
      semester: json['semester']?.toString() ?? '1',
      examination: json['examination']?.toString() ?? 'Examination-2026',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '02:30 Hours',
      totalMarks: json['totalMarks']?.toString() ?? '70',
      language: json['language']?.toString() ?? 'English',
      instructions: (json['instructions'] is List)
          ? (json['instructions'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'universityName': universityName,
        'department': department,
        'subjectName': subjectName,
        'subjectCode': subjectCode,
        'semester': semester,
        'examination': examination,
        'date': date,
        'time': time,
        'totalMarks': totalMarks,
        'language': language,
        'instructions': instructions,
      };
}

class QuestionItem {
  final String qNumber; // e.g. Q.1, Q.2
  final String subNumber; // e.g. (a), (b), (c), (i)
  final int marks; // e.g. 3, 4, 7
  final String questionText; // Original question text
  final bool isOr; // True if alternative OR question
  final String? orGroup; // Identifier linking OR questions
  final String answer; // Universal marks-oriented generated answer
  final String? formulaWorking; // Mathematical formulas & step-by-step calculations
  final String? codeSnippet; // Code snippet for programming subjects
  final List<String>? algorithmSteps; // Step-by-step algorithms
  final String? flowchartText; // Flowchart description / directional steps
  final List<List<String>>? comparisonTable; // Table format for differences/comparisons

  QuestionItem({
    required this.qNumber,
    required this.subNumber,
    required this.marks,
    required this.questionText,
    this.isOr = false,
    this.orGroup,
    required this.answer,
    this.formulaWorking,
    this.codeSnippet,
    this.algorithmSteps,
    this.flowchartText,
    this.comparisonTable,
  });

  factory QuestionItem.fromJson(Map<String, dynamic> json) {
    List<List<String>>? table;
    if (json['comparisonTable'] is List) {
      table = (json['comparisonTable'] as List)
          .map((row) => (row as List).map((cell) => cell.toString()).toList())
          .toList();
    }

    return QuestionItem(
      qNumber: json['qNumber']?.toString() ?? 'Q.1',
      subNumber: json['subNumber']?.toString() ?? '(a)',
      marks: (json['marks'] is num) ? (json['marks'] as num).toInt() : 3,
      questionText: json['questionText']?.toString() ?? '',
      isOr: json['isOr'] == true,
      orGroup: json['orGroup']?.toString(),
      answer: json['answer']?.toString() ?? '',
      formulaWorking: json['formulaWorking']?.toString(),
      codeSnippet: json['codeSnippet']?.toString(),
      algorithmSteps: (json['algorithmSteps'] is List)
          ? (json['algorithmSteps'] as List).map((e) => e.toString()).toList()
          : null,
      flowchartText: json['flowchartText']?.toString(),
      comparisonTable: table,
    );
  }

  Map<String, dynamic> toJson() => {
        'qNumber': qNumber,
        'subNumber': subNumber,
        'marks': marks,
        'questionText': questionText,
        'isOr': isOr,
        'orGroup': orGroup,
        'answer': answer,
        'formulaWorking': formulaWorking,
        'codeSnippet': codeSnippet,
        'algorithmSteps': algorithmSteps,
        'flowchartText': flowchartText,
        'comparisonTable': comparisonTable,
      };
}

class QuestionPaperSolution {
  final QuestionPaperInfo info;
  final List<QuestionItem> questions;

  QuestionPaperSolution({
    required this.info,
    required this.questions,
  });

  factory QuestionPaperSolution.fromJson(Map<String, dynamic> json) {
    final info = QuestionPaperInfo.fromJson(
        json['info'] as Map<String, dynamic>? ?? {});
    final questionsRaw = json['questions'] as List<dynamic>? ?? [];
    final questions = questionsRaw
        .map((q) => QuestionItem.fromJson(q as Map<String, dynamic>))
        .toList();

    return QuestionPaperSolution(
      info: info,
      questions: questions,
    );
  }

  Map<String, dynamic> toJson() => {
        'info': info.toJson(),
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}

