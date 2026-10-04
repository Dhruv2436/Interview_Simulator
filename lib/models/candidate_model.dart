
class ResumeData {
  String name;
  String email;
  String phone;
  String college;
  String experienceLevel;
  List<String> skills;
  List<String> projects;
  List<String> experience;
  List<String> technologies;
  List<String> certifications;
  String rawText;

  ResumeData({
    required this.name,
    required this.email,
    required this.phone,
    required this.college,
    required this.experienceLevel,
    required this.skills,
    required this.projects,
    required this.experience,
    required this.technologies,
    required this.certifications,
    this.rawText = '',
  });

  factory ResumeData.fromParsedMap(Map<String, dynamic> map, {String rawText = ''}) {
    return ResumeData(
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      college: map['education']?.toString() ?? '',
      experienceLevel: map['experienceLevel']?.toString() ?? map['experience']?.toString() ?? '',
      skills: (map['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      projects: (map['projects'] as List?)?.map((e) => e.toString()).toList() ?? [],
      experience: (map['experience'] is List)
          ? (map['experience'] as List).map((e) => e.toString()).toList()
          : [map['experience']?.toString() ?? ''],
      technologies: (map['technologies'] as List?)?.map((e) => e.toString()).toList() ?? [],
      certifications: (map['certifications'] as List?)?.map((e) => e.toString()).toList() ?? [],
      rawText: rawText,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'college': college,
      'experienceLevel': experienceLevel,
      'education': college,
      'skills': skills,
      'projects': projects,
      'experience': experience.join(', '),
      'technologies': technologies,
      'certifications': certifications,
      'profileSummary': '$name ($experienceLevel) - College: $college. Key Skills: ${skills.join(", ")}.',
    };
  }
}

class ATSAnalysisResult {
  final int score;            // Weighted final score (Education 25% + Skills 40% + Experience 35%)
  final int educationScore;   // 0-100
  final int skillsScore;      // 0-100
  final int experienceScore;  // 0-100
  final String educationReasoning;
  final String skillsReasoning;
  final String experienceReasoning;
  final String educationSuggestions;
  final String skillsSuggestions;
  final String experienceSuggestions;
  final String overallExplanation;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final List<String> missingKeywords;  // kept for backward compat
  final List<String> suggestions;      // kept for backward compat
  final String strengthSummary;

  ATSAnalysisResult({
    required this.score,
    this.educationScore = 0,
    this.skillsScore = 0,
    this.experienceScore = 0,
    this.educationReasoning = '',
    this.skillsReasoning = '',
    this.experienceReasoning = '',
    this.educationSuggestions = '',
    this.skillsSuggestions = '',
    this.experienceSuggestions = '',
    this.overallExplanation = '',
    this.matchedSkills = const [],
    this.missingSkills = const [],
    required this.missingKeywords,
    required this.suggestions,
    required this.strengthSummary,
  });

  /// Called when we have rich LLM ATS data from performATSScoring()
  factory ATSAnalysisResult.fromAtsMap(Map<String, dynamic> map, List<String> matched, List<String> missing) {
    final edu = (map['education_score'] as num? ?? 0).toInt().clamp(0, 100);
    final ski = (map['skills_score'] as num? ?? 0).toInt().clamp(0, 100);
    final exp = (map['experience_score'] as num? ?? 0).toInt().clamp(0, 100);
    // Weighted: Education 25%, Skills 40%, Experience 35%
    int weighted = (edu * 0.25 + ski * 0.40 + exp * 0.35).round().clamp(0, 100);
    // Prefer the LLM-computed final_score if provided and non-zero
    final llmFinal = (map['final_score'] as num? ?? 0).toInt();
    int finalScore = (llmFinal > 0) ? llmFinal.clamp(0, 100) : weighted;

    final sug = <String>[];
    if ((map['education_suggestions'] ?? '').toString().isNotEmpty) sug.add('Education: ${map["education_suggestions"]}');
    if ((map['skills_suggestions'] ?? '').toString().isNotEmpty) sug.add('Skills: ${map["skills_suggestions"]}');
    if ((map['experience_suggestions'] ?? '').toString().isNotEmpty) sug.add('Experience: ${map["experience_suggestions"]}');

    return ATSAnalysisResult(
      score: finalScore,
      educationScore: edu,
      skillsScore: ski,
      experienceScore: exp,
      educationReasoning: map['education_reasoning']?.toString() ?? '',
      skillsReasoning: map['skills_reasoning']?.toString() ?? '',
      experienceReasoning: map['experience_reasoning']?.toString() ?? '',
      educationSuggestions: map['education_suggestions']?.toString() ?? '',
      skillsSuggestions: map['skills_suggestions']?.toString() ?? '',
      experienceSuggestions: map['experience_suggestions']?.toString() ?? '',
      overallExplanation: map['overall_explanation']?.toString() ?? '',
      matchedSkills: matched,
      missingSkills: missing,
      missingKeywords: missing,
      suggestions: sug.isNotEmpty ? sug : ['Your resume has been evaluated against the job description.'],
      strengthSummary: finalScore >= 80 ? 'Great Score!' : finalScore >= 60 ? 'Good Match' : 'Needs Improvement',
    );
  }

  /// Offline fallback: keyword-based scoring against role requirements
  factory ATSAnalysisResult.calculate(ResumeData data, String selectedRole) {
    final Map<String, List<String>> roleKeywords = {
      'Flutter Developer': ['Riverpod', 'Firebase', 'REST API', 'Bloc', 'Clean Architecture', 'Dart'],
      'AI/ML Engineer': ['PyTorch', 'TensorFlow', 'Scikit-learn', 'NLP', 'Computer Vision', 'Python'],
      'Python Developer': ['Django', 'FastAPI', 'PostgreSQL', 'Docker', 'REST API', 'PyTest'],
      'Java Developer': ['Spring Boot', 'Hibernate', 'Microservices', 'Maven', 'JVM', 'MySQL'],
      'Web Developer': ['React', 'TypeScript', 'Tailwind CSS', 'Node.js', 'Next.js', 'GraphQL'],
      'Data Analyst': ['SQL', 'Pandas', 'Power BI', 'Tableau', 'Excel', 'Statistics'],
      'Software Engineer': ['Data Structures', 'System Design', 'Git', 'CI/CD', 'Agile', 'OOP'],
    };

    final requiredList = roleKeywords[selectedRole] ?? roleKeywords['Software Engineer']!;
    final combinedUserText = '${data.skills.join(" ")} ${data.technologies.join(" ")} ${data.projects.join(" ")} ${data.certifications.join(" ")} ${data.rawText}'.toLowerCase();

    if (combinedUserText.trim().isEmpty || (data.rawText.trim().isEmpty && data.skills.isEmpty)) {
      return ATSAnalysisResult(score: 0, missingKeywords: requiredList, suggestions: ['Upload a valid resume document containing text.'], strengthSummary: 'Empty Resume Content');
    }

    final missing = <String>[];
    int matchedCount = 0;

    for (var kw in requiredList) {
      if (combinedUserText.contains(kw.toLowerCase())) {
        matchedCount++;
      } else {
        missing.add(kw);
      }
    }

    double keywordRatio = matchedCount / requiredList.length;
    int baseScore = (keywordRatio * 70).round();

    int completenessBonus = 0;
    if (data.skills.length >= 3) completenessBonus += 10;
    if (data.projects.isNotEmpty) completenessBonus += 10;
    if (data.certifications.isNotEmpty) completenessBonus += 5;
    if (data.experience.isNotEmpty && data.experience.first.trim().isNotEmpty) completenessBonus += 5;

    int totalScore = baseScore > 0 ? (baseScore + completenessBonus).clamp(10, 98) : 0;

    final suggestions = <String>[];
    if (missing.isNotEmpty) {
      suggestions.add('Add missing keywords: ${missing.take(3).join(", ")}');
      suggestions.add('Improve Skills Section with role-specific technologies');
      suggestions.add('Add Certifications relevant to $selectedRole');
    } else {
      suggestions.add('Your resume is well aligned with $selectedRole!');
    }

    return ATSAnalysisResult(
      score: totalScore,
      skillsScore: (keywordRatio * 100).round(),
      educationScore: data.college.isNotEmpty ? 70 : 30,
      experienceScore: (data.experience.isNotEmpty && data.experience.first.trim().isNotEmpty) ? 65 : 30,
      missingKeywords: missing.isNotEmpty ? missing : [],
      missingSkills: missing.isNotEmpty ? missing : [],
      matchedSkills: requiredList.where((k) => combinedUserText.contains(k.toLowerCase())).toList(),
      suggestions: suggestions,
      strengthSummary: totalScore >= 80 ? 'Great Score!' : totalScore >= 60 ? 'Good Match' : 'Needs Improvement',
    );
  }
}
