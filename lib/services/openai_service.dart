import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class OpenAIService {
  static const String _openRouterApiKey = Secrets.openRouterApiKey;
  static const String _openRouterUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'google/gemini-2.5-flash';

  final Random _random = Random();

  // ---------------------------------------------------------------------------
  // OpenRouter helper
  // ---------------------------------------------------------------------------
  Future<String?> _chatCompletion({
    required String prompt,
    double temperature = 0.7,
    int maxTokens = 4096,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_openRouterUrl),
        headers: {
          'Authorization': 'Bearer $_openRouterApiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://interview-simulator.app',
          'X-Title': 'Interview Simulator',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': temperature,
          'max_tokens': maxTokens,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(
          'OpenRouter error ${response.statusCode}: ${response.body}',
        );
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['choices']?[0]?['message']?['content'];
      return content?.toString().trim();
    } catch (e, st) {
      debugPrint('OpenRouter exception: $e\n$st');
      return null;
    }
  }

  String _cleanJson(String content) {
    return content
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();
  }

  String? _extractJsonBlock(String content, {bool array = false}) {
    final cleaned = _cleanJson(content);
    final startChar = array ? '[' : '{';
    final endChar = array ? ']' : '}';
    final start = cleaned.indexOf(startChar);
    final end = cleaned.lastIndexOf(endChar);
    if (start == -1 || end == -1 || end <= start) return null;
    return cleaned.substring(start, end + 1);
  }

  // ---------------------------------------------------------------------------
  // Regex Text Extraction Helper (Instant offline fallback for high reliability)
  // ---------------------------------------------------------------------------
  Map<String, dynamic> parseResumeWithRegex(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String name = '';
    for (var line in lines.take(5)) {
      if (line.toLowerCase().contains('name:')) {
        name = line
            .replaceAll(RegExp(r'name:', caseSensitive: false), '')
            .trim();
        break;
      } else if (!line.contains('@') &&
          !line.contains('http') &&
          line.split(' ').length >= 2 &&
          line.split(' ').length <= 4) {
        name = line;
        break;
      }
    }

    final emailMatch = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    ).firstMatch(text);
    final email = emailMatch?.group(0) ?? '';

    final phoneMatch = RegExp(
      r'(\+?\d{1,3}[\s-]?)?\(?\d{3}\)?[\s-]?\d{3}[\s-]?\d{4}',
    ).firstMatch(text);
    final phone = phoneMatch?.group(0) ?? '';

    String college = '';
    final eduMatch = RegExp(
      r'(B\.?Tech|B\.?E|B\.?S|Bachelor|Master|University|College|Institute)[^\n,]*',
      caseSensitive: false,
    ).firstMatch(text);
    if (eduMatch != null) college = eduMatch.group(0)!.trim();

    final skillKeywords = [
      'Flutter',
      'Dart',
      'Firebase',
      'REST API',
      'Riverpod',
      'Bloc',
      'React',
      'Python',
      'Java',
      'SQL',
      'Git',
      'Docker',
      'C++',
      'JavaScript',
    ];
    final skills = <String>[];
    for (var kw in skillKeywords) {
      if (text.toLowerCase().contains(kw.toLowerCase())) skills.add(kw);
    }

    List<String> projects = [];
    final projMatch = RegExp(
      r'(Project|Projects)[s\:\-]*([^\n]+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (projMatch != null) {
      projects = projMatch
          .group(2)!
          .split(RegExp(r'[,|;]'))
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
    }

    String experience = '';
    final expMatch = RegExp(
      r'(\d+(\.\d+)?\s*(years|yrs|year|yr))',
      caseSensitive: false,
    ).firstMatch(text);
    if (expMatch != null) experience = expMatch.group(0)!;

    return {
      'name': name,
      'email': email,
      'phone': phone,
      'education': college,
      'skills': skills,
      'projects': projects,
      'experience': experience,
      'technologies': skills,
      'certifications': <String>[],
      'strengths': <String>[],
      'profileSummary': name.isNotEmpty
          ? '$name with ${experience.isNotEmpty ? experience : "some"} experience skilled in ${skills.join(", ")}.'
          : '',
    };
  }

  // ---------------------------------------------------------------------------
  // 0. ATS Scoring
  // ---------------------------------------------------------------------------
  static const List<String> _skillsWhitelist = [
    'python',
    'r',
    'java',
    'c++',
    'c#',
    'sql',
    'nosql',
    'mongodb',
    'mysql',
    'postgresql',
    'oracle',
    'excel',
    'tableau',
    'power bi',
    'sas',
    'matlab',
    'html',
    'css',
    'javascript',
    'typescript',
    'react',
    'angular',
    'node.js',
    'flutter',
    'dart',
    'firebase',
    'riverpod',
    'bloc',
    'provider',
    'flask',
    'django',
    'spring',
    'aws',
    'azure',
    'gcp',
    'docker',
    'kubernetes',
    'git',
    'linux',
    'rest api',
    'graphql',
    'machine learning',
    'deep learning',
    'nlp',
    'data science',
    'data analysis',
    'statistics',
    'regression',
    'classification',
    'clustering',
    'etl',
    'hadoop',
    'spark',
    'ci/cd',
    'devops',
    'agile',
    'scrum',
    'project management',
    'scikit-learn',
    'pytorch',
    'tensorflow',
    'fastapi',
    'microservices',
    'kafka',
    'redis',
    'elasticsearch',
    'communication',
    'leadership',
    'teamwork',
    'problem solving',
    'critical thinking',
  ];

  List<String> _extractSkillsFromText(String text) {
    final lower = text.toLowerCase();
    return _skillsWhitelist.where((skill) {
      final s = skill.toLowerCase();
      // Multi-word skills, or skills with special chars (+, #, .) don't work
      // with \b word boundaries — use plain contains instead.
      if (s.contains(' ') || s.contains('+') || s.contains('#') || s.contains('.')) {
        return lower.contains(s);
      }
      // Single alpha-only word — use word boundary for precision
      final pattern = RegExp(r'\b' + RegExp.escape(s) + r'\b');
      return pattern.hasMatch(lower);
    }).toList();
  }

  Future<Map<String, dynamic>> performATSScoring({
    required String resumeText,
    required String jobDescription,
  }) async {
    final jdSkills = _extractSkillsFromText(jobDescription);
    final resumeSkills = _extractSkillsFromText(resumeText);
    final matched = jdSkills.where((s) => resumeSkills.contains(s)).toList();
    final missing = jdSkills.where((s) => !resumeSkills.contains(s)).toList();

    final prompt =
        '''Given the following resume and job description, evaluate the candidate in these areas:
- Education (score 0-100)
- Skills (score 0-100)
- Experience (score 0-100)

For each section, provide:
- Score
- Reasoning
- Suggestions to improve

At the end, provide a weighted final score (Education 25%, Skills 40%, Experience 35%).

IMPORTANT: ONLY output the following fields, in exactly this format, with NO extra commentary or text. Do not add explanations before or after. Do not use markdown or bullet points. Use numbers only for scores.

Job Description:
$jobDescription

Resume:
$resumeText

Respond with:
Education Score: <number>
Education Reasoning: <text>
Education Suggestions: <text>
Skills Score: <number>
Skills Reasoning: <text>
Skills Suggestions: <text>
Experience Score: <number>
Experience Reasoning: <text>
Experience Suggestions: <text>
Final Score: <number>
Overall Explanation: <text>''';

    final result = <String, dynamic>{
      'education_score': 0,
      'education_reasoning': '',
      'education_suggestions': '',
      'skills_score': 0,
      'skills_reasoning': '',
      'skills_suggestions': '',
      'experience_score': 0,
      'experience_reasoning': '',
      'experience_suggestions': '',
      'final_score': 0,
      'overall_explanation': '',
      'matched_skills': matched,
      'missing_skills': missing,
    };

    final content = await _chatCompletion(prompt: prompt, temperature: 0.1);
    if (content == null) {
      debugPrint('ATS Scoring: OpenRouter returned null — API may be rate-limited or key expired');
      return result;
    }

    debugPrint('ATS raw response:\n$content');

    // Robust multi-line parser:
    // Tracks which key was last matched so continuation lines are appended.
    String? lastKey;

    // Normalise a label line: lowercase + remove all spaces to handle
    // Gemini variations like 'Skills Score :' or 'skillsscore:'
    String norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) { lastKey = null; continue; }

      // Check if this line starts a known label
      final colonIdx = line.indexOf(':');
      if (colonIdx > 0) {
        final labelPart = norm(line.substring(0, colonIdx));
        final valuePart = line.substring(colonIdx + 1).trim();

        if (labelPart == norm('Education Score')) {
          final nums = RegExp(r'\d+').allMatches(valuePart);
          if (nums.isNotEmpty) result['education_score'] = int.parse(nums.first.group(0)!).clamp(0, 100);
          lastKey = null;
          continue;
        } else if (labelPart == norm('Education Reasoning')) {
          result['education_reasoning'] = valuePart;
          lastKey = 'education_reasoning';
          continue;
        } else if (labelPart == norm('Education Suggestions')) {
          result['education_suggestions'] = valuePart;
          lastKey = 'education_suggestions';
          continue;
        } else if (labelPart == norm('Skills Score')) {
          final nums = RegExp(r'\d+').allMatches(valuePart);
          if (nums.isNotEmpty) result['skills_score'] = int.parse(nums.first.group(0)!).clamp(0, 100);
          lastKey = null;
          continue;
        } else if (labelPart == norm('Skills Reasoning')) {
          result['skills_reasoning'] = valuePart;
          lastKey = 'skills_reasoning';
          continue;
        } else if (labelPart == norm('Skills Suggestions')) {
          result['skills_suggestions'] = valuePart;
          lastKey = 'skills_suggestions';
          continue;
        } else if (labelPart == norm('Experience Score')) {
          final nums = RegExp(r'\d+').allMatches(valuePart);
          if (nums.isNotEmpty) result['experience_score'] = int.parse(nums.first.group(0)!).clamp(0, 100);
          lastKey = null;
          continue;
        } else if (labelPart == norm('Experience Reasoning')) {
          result['experience_reasoning'] = valuePart;
          lastKey = 'experience_reasoning';
          continue;
        } else if (labelPart == norm('Experience Suggestions')) {
          result['experience_suggestions'] = valuePart;
          lastKey = 'experience_suggestions';
          continue;
        } else if (labelPart == norm('Final Score')) {
          final nums = RegExp(r'\d+').allMatches(valuePart);
          if (nums.isNotEmpty) result['final_score'] = int.parse(nums.first.group(0)!).clamp(0, 100);
          lastKey = null;
          continue;
        } else if (labelPart == norm('Overall Explanation')) {
          result['overall_explanation'] = valuePart;
          lastKey = 'overall_explanation';
          continue;
        }
      }

      // Continuation line — append to last key's value
      if (lastKey != null && result.containsKey(lastKey)) {
        final existing = result[lastKey].toString();
        result[lastKey] = existing.isNotEmpty ? '$existing $line' : line;
      }
    }

    debugPrint(
      'ATS parsed — edu:${result["education_score"]} '
      'ski:${result["skills_score"]} '
      'exp:${result["experience_score"]} '
      'final:${result["final_score"]}',
    );

    return result;
  }

  // ---------------------------------------------------------------------------
  // 1. Resume Analysis
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> analyzeResumeDetailed(String resumeText) async {
    final trimmed = resumeText.trim();
    final regexResult = parseResumeWithRegex(trimmed);

    if (trimmed.length < 30) return regexResult;

    final prompt =
        '''
You are an expert recruitment parser. Extract candidate details from this resume text:
"""
$trimmed
"""

IMPORTANT: If the text does NOT resemble a resume or has no meaningful data, return empty strings for all fields and an empty array for skills and projects. DO NOT hallucinate or guess data.

Return ONLY a JSON object:
{
  "name": "Full Name",
  "email": "Email address",
  "phone": "Phone number",
  "education": "College / University name and degree",
  "skills": ["Skill 1", "Skill 2"],
  "projects": ["Project 1", "Project 2"],
  "experience": "Years of experience e.g. 1.5 Years",
  "certifications": ["Cert 1"]
}
''';

    try {
      final content = await _chatCompletion(prompt: prompt, temperature: 0.1);
      if (content == null) return regexResult;

      final jsonBlock = _extractJsonBlock(content) ?? _cleanJson(content);
      final parsed = jsonDecode(jsonBlock) as Map<String, dynamic>;
      return {
        'name':
            (parsed['name'] != null &&
                parsed['name'].toString().isNotEmpty &&
                parsed['name'].toString() != 'Candidate')
            ? parsed['name']
            : regexResult['name'],
        'email':
            (parsed['email'] != null && parsed['email'].toString().isNotEmpty)
            ? parsed['email']
            : regexResult['email'],
        'phone':
            (parsed['phone'] != null && parsed['phone'].toString().isNotEmpty)
            ? parsed['phone']
            : regexResult['phone'],
        'education':
            (parsed['education'] != null &&
                parsed['education'].toString().isNotEmpty)
            ? parsed['education']
            : regexResult['education'],
        'skills':
            (parsed['skills'] is List && (parsed['skills'] as List).isNotEmpty)
            ? (parsed['skills'] as List).map((e) => e.toString()).toList()
            : regexResult['skills'],
        'projects':
            (parsed['projects'] is List &&
                (parsed['projects'] as List).isNotEmpty)
            ? (parsed['projects'] as List).map((e) => e.toString()).toList()
            : regexResult['projects'],
        'experience':
            (parsed['experience'] != null &&
                parsed['experience'].toString().isNotEmpty)
            ? parsed['experience']
            : regexResult['experience'],
        'certifications': (parsed['certifications'] is List)
            ? (parsed['certifications'] as List)
                  .map((e) => e.toString())
                  .toList()
            : regexResult['certifications'],
        'strengths': regexResult['strengths'],
        'profileSummary': regexResult['profileSummary'],
      };
    } catch (e) {
      debugPrint('Resume analysis failed: $e');
      return regexResult;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. MCQ Test Generation — unique aptitude + technical every session
  // ---------------------------------------------------------------------------
  static const List<String> _aptitudeTopics = [
    'Arithmetic', 'Percentage', 'Average', 'Ratio', 'Profit & Loss',
    'Probability', 'Permutation & Combination', 'Time & Work',
    'Time Speed Distance', 'Mixture', 'Age Problems', 'Blood Relation',
    'Direction Sense', 'Coding Decoding', 'Logical Reasoning', 'Puzzles',
    'Seating Arrangement', 'Calendar', 'Clock Problems', 'Grammar',
    'Vocabulary', 'Synonyms', 'Antonyms', 'Sentence Correction',
    'Reading Comprehension', 'Verbal Ability', 'Analogy'
  ];

  Future<List<Map<String, dynamic>>> generateMCQs({
    required Map<String, dynamic> candidateProfile,
    required String technicalDomain,
    required int numAptitude,
    required int numTechnical,
  }) async {
    final sessionSeed =
        DateTime.now().millisecondsSinceEpoch + _random.nextInt(999999);
    final skills = (candidateProfile['skills'] is List)
        ? (candidateProfile['skills'] as List).join(', ')
        : 'None extracted';
        
    final projects = (candidateProfile['projects'] is List)
        ? (candidateProfile['projects'] as List).join(', ')
        : 'None extracted';

    for (var attempt = 1; attempt <= 3; attempt++) {
      final attemptSeed = sessionSeed + attempt * 7919;
      
      final selectedAptitudeTypes = List.of(_aptitudeTopics)..shuffle(_random);
      final targetedAptitude = selectedAptitudeTypes.take(numAptitude).toList();
      
      final prompt =
          '''
You are a strict, enterprise-grade AI Assessment Platform generating a highly dynamic MCQ test.
Session Unique Hash: $attemptSeed (Use this seed to mathematically guarantee no repetition from standard boilerplate).

CANDIDATE INFO:
Selected Role: $technicalDomain
Extracted Skills: $skills
Resume Projects: $projects

Generate EXACTLY $numAptitude Aptitude MCQs and EXACTLY $numTechnical Technical MCQs.

CRITICAL REQUIREMENT 1: NEVER REPEAT QUESTIONS
- You MUST NEVER repeat previous questions, rephrase questions, or just change numerical values.
- No two semantic patterns should be similar across the entire test.
- Every single question MUST be unique, wildly different, and randomly generated from scratch.

APTITUDE RULES:
- Here are $numAptitude strictly randomized, mixed categories: ${targetedAptitude.join(", ")}.
- You MUST generate exactly ONE highly distinct MCQ for each category listed above.
- NEVER generate basic formats like "A completes task in 6 hours". Create complex, dynamic narratives.
- DO NOT list them in predictable order; randomize the category distribution inside the output array.

TECHNICAL RULES (STRICT PRIORITY):
- FIRST PRIORITY: Selected Role ($technicalDomain)
- SECOND PRIORITY: Uploaded Resume / Projects ($projects)
- THIRD PRIORITY: Extracted Skills ($skills)
- You MUST generate $numTechnical Technical MCQs heavily targeting the intersection of these three domains.
- Example: If the role is AI Engineer and skills include Python and Docker, generate specific, advanced questions combining deployment of AI in Docker, or Python optimization for LLMs.
- NEVER ask "What is X?" or "Which of the following defines SQL?". Create difficult, scenario-based architecture or debugging problems.

- DO NOT truncate. Write FULL, COMPLETE, multi-sentence scenarios for both the statement and all 4 options. NO ELLIPSES (...).

Return ONLY a valid JSON array of exactly ${numAptitude + numTechnical} objects:
[
  {
    "category": "Aptitude",
    "topic": "Ratio",
    "statement": "Full, complete text of the wild scenario detailing all requirements...",
    "options": ["A. Full distinct option", "B. Full distinct option", "C. Full distinct option", "D. Full distinct option"],
    "correctIndex": 0
  },
  {
    "category": "Technical",
    "topic": "Docker/Python",
    "statement": "Full, complete scenario based technical question with total context...",
    "options": ["A. Detailed valid option", "B. Detailed invalid option", "C. Detailed invalid option", "D. Detailed invalid option"],
    "correctIndex": 2
  }
]
correctIndex is 0-based. Return raw JSON without markdown backticks.
''';

      try {
        final content = await _chatCompletion(
          prompt: prompt,
          temperature: 0.85 + (attempt * 0.05),
          maxTokens: 8192,
        );
        if (content == null) continue;

        final jsonBlock = _extractJsonBlock(content, array: true);
        if (jsonBlock == null) {
          debugPrint('MCQ attempt $attempt: no JSON array found');
          continue;
        }

        final list = (jsonDecode(jsonBlock) as List<dynamic>)
            .cast<Map<String, dynamic>>();
        final normalized = _normalizeMcqs(list);
        final unique = _deduplicateMcqs(normalized);

        if (unique.length >= numAptitude + numTechnical) {
          unique.shuffle(_random);
          return unique.take(numAptitude + numTechnical).toList();
        }

        debugPrint(
          'MCQ attempt $attempt: got ${unique.length}/${numAptitude + numTechnical} unique questions',
        );
      } catch (e) {
        debugPrint('MCQ generation attempt $attempt failed: $e');
      }
    }

    debugPrint('All MCQ API attempts failed — using randomized fallback');
    return _fallbackMCQs(technicalDomain, numAptitude, numTechnical);
  }

  List<Map<String, dynamic>> _normalizeMcqs(List<Map<String, dynamic>> raw) {
    return raw.map((q) {
      final options = (q['options'] is List)
          ? (q['options'] as List).map((e) => e.toString()).toList()
          : <String>[];
      var correctIndex = q['correctIndex'];
      if (correctIndex is String) {
        correctIndex = int.tryParse(correctIndex) ?? 0;
      } else if (correctIndex is! int) {
        correctIndex = 0;
      }
      return {
        'category': q['category']?.toString() ?? 'General',
        'topic': q['topic']?.toString() ?? 'General',
        'statement': q['statement']?.toString() ?? '',
        'options': options.length >= 4
            ? options.take(4).toList()
            : [
                'A. Option 1',
                'B. Option 2',
                'C. Option 3',
                'D. Option 4',
              ],
        'correctIndex': (correctIndex as int).clamp(0, 3),
      };
    }).where((q) => (q['statement'] as String).length > 10).toList();
  }

  List<Map<String, dynamic>> _deduplicateMcqs(
    List<Map<String, dynamic>> mcqs,
  ) {
    final seen = <String>{};
    final unique = <Map<String, dynamic>>[];
    for (final q in mcqs) {
      final key = (q['statement'] as String).toLowerCase().trim();
      if (key.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      unique.add(q);
    }
    return unique;
  }

  List<Map<String, dynamic>> _fallbackMCQs(String domain, int apt, int tech) {
    final mcqs = <Map<String, dynamic>>[];

    // ── Complete Aptitude Question Bank ──
    final aptQuestions = <Map<String, dynamic>>[
      {
        'topic': 'Time & Work',
        'statement': 'A can complete a project in 12 days and B can complete the same project in 18 days. If they work together, in how many days will they finish the project?',
        'options': ['A. 6.0 days', 'B. 7.2 days', 'C. 8.0 days', 'D. 9.5 days'],
        'correctIndex': 1,
      },
      {
        'topic': 'Percentage',
        'statement': 'A shopkeeper marks an item 40% above its cost price and then gives a 20% discount on the marked price. What is the shopkeeper\'s profit or loss percentage?',
        'options': ['A. 12% Profit', 'B. 8% Loss', 'C. 10% Profit', 'D. No profit, no loss'],
        'correctIndex': 0,
      },
      {
        'topic': 'Probability',
        'statement': 'A bag contains 5 red balls, 3 blue balls, and 2 green balls. If one ball is drawn at random, what is the probability that it is NOT red?',
        'options': ['A. 1/2', 'B. 3/10', 'C. 2/5', 'D. 1/5'],
        'correctIndex': 0,
      },
      {
        'topic': 'Ratio & Proportion',
        'statement': 'The ratio of the ages of Ravi and Sonia is 3:5. After 6 years, the ratio of their ages will be 2:3. What is Sonia\'s current age?',
        'options': ['A. 20 years', 'B. 25 years', 'C. 30 years', 'D. 15 years'],
        'correctIndex': 2,
      },
      {
        'topic': 'Logical Reasoning',
        'statement': 'In a row of 20 students, Aakash is ranked 8th from the left and Priya is ranked 5th from the right. How many students are sitting between Aakash and Priya?',
        'options': ['A. 5 students', 'B. 6 students', 'C. 7 students', 'D. 8 students'],
        'correctIndex': 2,
      },
      {
        'topic': 'Number Series',
        'statement': 'Find the next number in the series: 2, 6, 12, 20, 30, 42, ___',
        'options': ['A. 52', 'B. 54', 'C. 56', 'D. 58'],
        'correctIndex': 2,
      },
      {
        'topic': 'Profit & Loss',
        'statement': 'A trader bought 80 pens at Rs. 12 each and sold them all at Rs. 10.50 each. What is the total loss incurred by the trader?',
        'options': ['A. Rs. 100', 'B. Rs. 110', 'C. Rs. 120', 'D. Rs. 130'],
        'correctIndex': 2,
      },
      {
        'topic': 'Speed, Distance & Time',
        'statement': 'A train 200 metres long is travelling at 54 km/h. How long will it take to completely pass a stationary pole standing beside the track?',
        'options': ['A. 10 seconds', 'B. 13.3 seconds', 'C. 15 seconds', 'D. 8 seconds'],
        'correctIndex': 1,
      },
      {
        'topic': 'Coding Decoding',
        'statement': 'In a certain code language, "MANGO" is written as "OCPIQ". Using the same coding pattern, how would "APPLE" be written in the same code?',
        'options': ['A. CRRNG', 'B. BQQMF', 'C. CQQNG', 'D. CRRMG'],
        'correctIndex': 0,
      },
      {
        'topic': 'Age Problems',
        'statement': 'The sum of the present ages of a father and his son is 55 years. Five years ago, the father\'s age was four times the son\'s age. What is the son\'s present age?',
        'options': ['A. 10 years', 'B. 12 years', 'C. 15 years', 'D. 18 years'],
        'correctIndex': 2,
      },
      {
        'topic': 'Mixture & Alligation',
        'statement': 'A vessel contains 40 litres of milk. 8 litres of milk is removed and replaced with 8 litres of water. This process is repeated once more. What percentage of the final mixture is milk?',
        'options': ['A. 60%', 'B. 64%', 'C. 70%', 'D. 72%'],
        'correctIndex': 1,
      },
      {
        'topic': 'Direction Sense',
        'statement': 'Starting from his house, Rahul walked 5 km North, then turned East and walked 3 km, then turned South and walked 5 km. How far and in which direction is Rahul from his starting point?',
        'options': ['A. 3 km West', 'B. 3 km East', 'C. 5 km South', 'D. 8 km East'],
        'correctIndex': 1,
      },
      {
        'topic': 'Data Interpretation',
        'statement': 'In a company, the number of employees in 2020 was 1200. By 2022, the count rose to 1500. What is the percentage increase in the number of employees from 2020 to 2022?',
        'options': ['A. 20%', 'B. 22%', 'C. 25%', 'D. 30%'],
        'correctIndex': 2,
      },
      {
        'topic': 'Permutation & Combination',
        'statement': 'In how many different ways can the letters of the word "LEADER" be arranged such that the two E\'s always appear together as a single unit?',
        'options': ['A. 60', 'B. 120', 'C. 240', 'D. 360'],
        'correctIndex': 1,
      },
      {
        'topic': 'Arithmetic',
        'statement': 'The average of 5 consecutive even numbers is 42. What is the largest of these five numbers?',
        'options': ['A. 44', 'B. 46', 'C. 48', 'D. 50'],
        'correctIndex': 1,
      },
    ];

    // ── Complete Technical Question Bank ──
    final techQuestions = <Map<String, dynamic>>[
      {
        'statement': 'In a $domain application, which design pattern is most suitable for managing application-wide state while keeping the UI layer completely decoupled from the business logic?',
        'options': [
          'A. BLoC / MVVM pattern — separates state, business logic, and UI into distinct, testable layers',
          'B. Singleton pattern — uses a single global object that is accessible from anywhere in the app',
          'C. Observer pattern — allows objects to subscribe to changes without separation of concerns',
          'D. Factory pattern — creates objects dynamically but does not address application state management',
        ],
        'correctIndex': 0,
      },
      {
        'statement': 'When building a $domain system that must handle 10,000 concurrent users, which architectural approach provides the best horizontal scalability without creating a single point of failure?',
        'options': [
          'A. A single monolithic server with a very large RAM configuration and high-speed processors',
          'B. Microservices architecture combined with a load balancer and stateless service instances',
          'C. A two-tier client-server model with only database connection pooling applied',
          'D. Vertical scaling by upgrading server hardware each time the load increases',
        ],
        'correctIndex': 1,
      },
      {
        'statement': 'In $domain development, what is the primary purpose of implementing a Repository Pattern between the data source layer and the business logic layer?',
        'options': [
          'A. To speed up network requests by permanently caching all API responses directly on disk',
          'B. To abstract and centralise data access logic, making it easy to swap data sources without affecting business logic',
          'C. To prevent multiple simultaneous API calls by queuing all requests in a single-threaded queue',
          'D. To automatically generate UI components directly from raw database schemas',
        ],
        'correctIndex': 1,
      },
      {
        'statement': 'A $domain application is experiencing extremely slow load times after a recent deployment. What is the MOST effective first step in diagnosing the root cause of this performance degradation?',
        'options': [
          'A. Immediately roll back the deployment to the previous version to restore normal performance',
          'B. Increase the server RAM and CPU allocation to absorb the increased processing load',
          'C. Use profiling and monitoring tools to identify which function calls or queries consume the most execution time',
          'D. Rewrite the entire codebase using a different programming language known for better runtime speed',
        ],
        'correctIndex': 2,
      },
      {
        'statement': 'What is the key difference between optimistic locking and pessimistic locking when handling concurrent data updates in a $domain database system?',
        'options': [
          'A. Optimistic locking locks the record immediately upon reading; pessimistic locking only checks for conflicts upon writing',
          'B. Optimistic locking assumes no conflict and validates only at write time; pessimistic locking locks the record for the entire transaction duration',
          'C. Optimistic locking is used exclusively with NoSQL databases; pessimistic locking applies only to relational SQL databases',
          'D. There is no practical difference between the two strategies; both produce identical results in all concurrency scenarios',
        ],
        'correctIndex': 1,
      },
      {
        'statement': 'In a $domain RESTful API, which HTTP status code should be returned when a client sends a well-formed request but the server cannot locate the requested resource?',
        'options': [
          'A. 400 Bad Request — the request syntax is malformed or is missing required parameters',
          'B. 401 Unauthorised — the client has not provided valid authentication credentials',
          'C. 404 Not Found — the server cannot locate the requested resource at the given URI',
          'D. 500 Internal Server Error — an unexpected condition occurred on the server side',
        ],
        'correctIndex': 2,
      },
      {
        'statement': 'You are designing a caching strategy for a high-traffic $domain service. Which cache eviction policy should you use to automatically remove the least recently accessed items when the cache reaches its storage capacity?',
        'options': [
          'A. FIFO (First In, First Out) — evicts the oldest cached entry regardless of how frequently it has been accessed',
          'B. LRU (Least Recently Used) — evicts the item that has not been accessed for the longest period of time',
          'C. MRU (Most Recently Used) — evicts the item that was most recently accessed from the cache',
          'D. Random Replacement — evicts a randomly selected item each time space needs to be freed',
        ],
        'correctIndex': 1,
      },
      {
        'statement': 'When implementing a CI/CD pipeline for a $domain project, what is the main benefit of running automated unit and integration tests at every code commit pushed to the repository?',
        'options': [
          'A. It completely eliminates the need for manual code reviews by senior developers on the team',
          'B. It guarantees that the final production build will never have any runtime errors or logic bugs',
          'C. It catches regressions and integration failures early, significantly reducing the cost of fixing bugs found in production',
          'D. It automatically generates up-to-date documentation for every function and class in the codebase',
        ],
        'correctIndex': 2,
      },
      {
        'statement': 'In $domain, what does the SOLID principle of "Dependency Inversion" specifically state about how software modules should depend on each other?',
        'options': [
          'A. High-level modules should directly depend on low-level modules to maximise runtime efficiency',
          'B. Both high-level and low-level modules should depend on abstractions (interfaces), not on concrete implementations',
          'C. Every class in the system should have only one single responsibility and one reason to change',
          'D. Software entities should be open for extension through inheritance but closed for modification of existing code',
        ],
        'correctIndex': 1,
      },
      {
        'statement': 'A $domain app is exhibiting an N+1 query problem where loading a list of 50 users triggers 51 separate database queries. What is the most efficient solution to fix this performance issue?',
        'options': [
          'A. Increase the database connection pool size to allow more simultaneous queries to execute in parallel',
          'B. Cache the results of every individual query in memory so the database is not hit repeatedly',
          'C. Use eager loading or SQL JOIN queries to fetch all required related data in a single optimised database query',
          'D. Reduce the page size to display fewer users per page, limiting the total number of queries triggered',
        ],
        'correctIndex': 2,
      },
      {
        'statement': 'In $domain software development, what is the fundamental difference between unit testing and integration testing as two separate testing strategies?',
        'options': [
          'A. Unit tests validate the entire application workflow end-to-end; integration tests focus on single functions in isolation',
          'B. Unit tests validate individual functions or classes in complete isolation; integration tests validate how multiple components interact and work together',
          'C. Unit tests can only be written in dynamically typed languages; integration tests require statically typed languages',
          'D. Unit tests are always run manually by developers; integration tests are exclusively run inside CI/CD pipelines',
        ],
        'correctIndex': 1,
      },
      {
        'statement': 'When building a secure $domain API, which authentication method is the recommended industry standard for stateless session management without storing session data on the server?',
        'options': [
          'A. Session cookies stored server-side and linked to an in-memory session table for each active user',
          'B. HTTP Basic Authentication that transmits the username and password as Base64 on every single request',
          'C. JWT (JSON Web Tokens) signed with a secret key and cryptographically validated on each request without any server-side session storage',
          'D. API keys embedded directly inside the client application\'s compiled source code for convenience',
        ],
        'correctIndex': 2,
      },
    ];

    final shuffledApt = List.of(aptQuestions)..shuffle(_random);
    for (var i = 0; i < apt; i++) {
      final q = shuffledApt[i % shuffledApt.length];
      mcqs.add({
        'category': 'Aptitude',
        'topic': q['topic'],
        'statement': q['statement'],
        'options': q['options'],
        'correctIndex': q['correctIndex'],
      });
    }

    final shuffledTech = List.of(techQuestions)..shuffle(_random);
    for (var i = 0; i < tech; i++) {
      final q = shuffledTech[i % shuffledTech.length];
      mcqs.add({
        'category': 'Technical',
        'topic': domain,
        'statement': q['statement'],
        'options': q['options'],
        'correctIndex': q['correctIndex'],
      });
    }

    mcqs.shuffle(_random);
    return mcqs;
  }

  // ---------------------------------------------------------------------------
  // 3. Final Report Synthesis
  // ---------------------------------------------------------------------------
  Map<String, dynamic> generateFinalReport({
    required Map<String, dynamic> candidateProfile,
    required int aptitudeScore,
    required int numAptitude,
    required int technicalScore,
    required int numTechnical,
    required List<Map<String, dynamic>> interviewEvaluations,
  }) {
    final totalMcq = numAptitude + numTechnical;
    final earnedMcq = aptitudeScore + technicalScore;
    final mcqPercent = totalMcq > 0 ? (earnedMcq / totalMcq) * 100 : 0.0;

    double voicePercent = 0;
    double totalRawScore = 0;
    var answeredCount = 0;
    final strengths = <String>[];
    final improvements = <String>[];

    for (var ev in interviewEvaluations) {
      final rawScore = ev['score'];
      var s = 0;
      if (rawScore is int) {
        s = rawScore;
      } else if (rawScore is double) {
        s = rawScore.round();
      } else if (rawScore is String) {
        s = int.tryParse(rawScore) ?? 0;
      }

      if (s > 0) {
        totalRawScore += s;
        answeredCount++;
      }
      final str = ev['strengths']?.toString() ?? '';
      final imp = ev['improvements']?.toString() ?? '';
      if (str.isNotEmpty && str != 'N/A') strengths.add(str);
      if (imp.isNotEmpty && imp != 'N/A') improvements.add(imp);
    }

    voicePercent = answeredCount > 0
        ? (totalRawScore / (answeredCount * 10)) * 100
        : 0;

    final overallDouble = (mcqPercent * 0.4) + (voicePercent * 0.6);
    final overallScore = overallDouble.round().clamp(0, 100);

    double commRating = 0;
    double techRating = 0;
    double confRating = 0;
    if (answeredCount > 0) {
      commRating = (totalRawScore / answeredCount).clamp(0, 10);
      final techAnswers = interviewEvaluations.where((e) {
        final s = e['score'];
        return (s is int ? s : int.tryParse(s.toString()) ?? 0) >= 5;
      });
      techRating = techAnswers.isNotEmpty
          ? techAnswers
                    .map((e) {
                      final s = e['score'];
                      return (s is int ? s : int.tryParse(s.toString()) ?? 0)
                          .toDouble();
                    })
                    .reduce((a, b) => a + b) /
                techAnswers.length
          : commRating * 0.8;
      final goodAnswers = interviewEvaluations.where((e) {
        final s = e['score'];
        return (s is int ? s : int.tryParse(s.toString()) ?? 0) >= 6;
      }).length;
      confRating = ((goodAnswers / interviewEvaluations.length) * 10).clamp(
        0,
        10,
      );
    }

    final candidateName = candidateProfile['name'] as String? ?? 'Candidate';
    final candidateSkills = (candidateProfile['skills'] is List)
        ? (candidateProfile['skills'] as List).cast<String>()
        : <String>[];
    final atsScore = candidateProfile['score'] as int? ?? 0;

    if (strengths.isEmpty && candidateSkills.isNotEmpty) {
      strengths.add(
        'Strong skill profile: ${candidateSkills.take(5).join(', ')}',
      );
    }
    if (strengths.length < 2 && atsScore > 60) {
      strengths.add('Well-matched resume with ATS score of $atsScore%');
    }
    if (improvements.isEmpty) {
      improvements.add('Provide concrete project impact metrics in responses');
      improvements.add('Elaborate on real-world edge cases and error handling');
    }

    String recommendation;
    if (overallScore >= 80) {
      recommendation = 'Strong Hire';
    } else if (overallScore >= 65) {
      recommendation = 'Hire';
    } else if (overallScore >= 50) {
      recommendation = 'Borderline';
    } else {
      recommendation = 'No Hire';
    }

    final String summary;
    if (voicePercent == 0 && mcqPercent == 0) {
      summary = '$candidateName did not complete the interview assessment.';
    } else {
      summary =
          '$candidateName achieved MCQ: ${mcqPercent.round()}%, Interview: ${voicePercent.round()}%, '
          'overall: $overallScore%. Skills: ${candidateSkills.take(3).join(", ")}. '
          'Recommendation: $recommendation.';
    }

    return {
      'candidateName': candidateName,
      'overallScore': overallScore,
      'mcqScorePercent': mcqPercent.round(),
      'voiceScorePercent': voicePercent.round(),
      'communicationRating': double.parse(commRating.toStringAsFixed(1)),
      'technicalDepthRating': double.parse(techRating.toStringAsFixed(1)),
      'confidenceRating': double.parse(confRating.toStringAsFixed(1)),
      'hiringRecommendation': recommendation,
      'keyStrengths': strengths.take(5).toList(),
      'areasForImprovement': improvements.take(4).toList(),
      'summary': summary,
    };
  }

  // ---------------------------------------------------------------------------
  // 4. Voice Interview — evaluation & dynamic questions
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> evaluateAnswerStructured({
    required String question,
    required String answer,
  }) async {
    int heuristicScore(String ans) {
      if (ans.trim().length < 20) return 2;
      if (ans.trim().length < 60) return 4;
      if (ans.trim().length < 150) return 6;
      return 7;
    }

    final prompt =
        '''
You are a strict senior technical interviewer. Evaluate this interview answer honestly.
Do NOT give full marks unless the answer is truly excellent.

Question: "$question"
Answer: "$answer"

Scoring guide:
- 1-3: Very poor/irrelevant/empty answer
- 4-5: Partial, missing key points
- 6-7: Adequate but lacks depth
- 8-9: Good with clear explanation
- 10: Perfect, complete and insightful

Return ONLY valid JSON (no markdown, no extra text):
{"score": <integer 1-10>, "strengths": "<what was done well>", "improvements": "<what was missing or could be better>", "feedback": "<1 sentence summary>"}
''';

    try {
      final content = await _chatCompletion(
        prompt: prompt,
        temperature: 0.1,
        maxTokens: 300,
      );
      if (content == null) throw Exception('No response');

      final jsonBlock = _extractJsonBlock(content) ?? _cleanJson(content);
      final parsed = jsonDecode(jsonBlock) as Map<String, dynamic>;
      final rawScore = parsed['score'];
      final intScore = rawScore is int
          ? rawScore
          : int.tryParse(rawScore.toString()) ?? heuristicScore(answer);

      return {
        'score': intScore.clamp(1, 10),
        'strengths':
            parsed['strengths']?.toString() ??
            'Addressed the question topic',
        'improvements':
            parsed['improvements']?.toString() ??
            'Elaborate with specific examples',
        'feedback': parsed['feedback']?.toString() ?? 'Response received.',
      };
    } catch (e) {
      debugPrint('Answer evaluation failed: $e');
      final hs = heuristicScore(answer);
      return {
        'score': hs,
        'strengths': hs >= 6
            ? 'Provided a structured response to the question'
            : 'Attempted to answer the question',
        'improvements': hs >= 6
            ? 'Add concrete examples and metrics from real projects'
            : 'Provide a more detailed and specific answer',
        'feedback': hs >= 6
            ? 'Decent response, could use more depth.'
            : 'Answer needs more detail and technical elaboration.',
      };
    }
  }

  Future<String> generateInterviewQuestionDynamic({
    required Map<String, dynamic> candidateProfile,
    required String technicalDomain,
    required double scorePercentage,
    required List<Map<String, String>> conversationHistory,
    bool isFirstQuestion = false,
  }) async {
    final sessionSeed = DateTime.now().millisecondsSinceEpoch;
    final skills = (candidateProfile['skills'] is List)
        ? (candidateProfile['skills'] as List).join(', ')
        : 'Tech';
    final projects = (candidateProfile['projects'] is List)
        ? (candidateProfile['projects'] as List).join(', ')
        : 'N/A';

    final historyText = conversationHistory.isEmpty
        ? 'No prior conversation.'
        : conversationHistory
              .map((m) => '${m['role']?.toUpperCase()}: ${m['content']}')
              .join('\n');

    final alreadyAsked = conversationHistory
        .where((m) => m['role'] == 'assistant')
        .map((m) => m['content'] ?? '')
        .where((q) => q.isNotEmpty)
        .join('\n- ');

    final prompt =
        '''
You are an expert AI Interviewer conducting a live technical interview for a highly competitive enterprise role.
Domain: $technicalDomain
Candidate: ${candidateProfile['name'] ?? 'Candidate'}
Skills: $skills
Projects: $projects
MCQ Performance: ${scorePercentage.round()}%

CRITICAL RULES FOR UNIQUENESS - YOU MUST OBEY THESE:
- Session Hash: $sessionSeed <- Use this mathematical seed to generate completely random, obscure, and unpredictable questions.
- NEVER repeat or rephrase standard interview questions.
- NEVER ask definition questions (e.g., "What is X?").
- IF YOU ARE GIVEN A PROJECT OR SKILL, drill deep into an obscure edge case or a chaotic real-world scenario involving it.
- Your questions must feel totally different from any previous attempts.

${isFirstQuestion ? 'This is the OPENING question. Greet them very briefly in a bizarre or highly creative professional manner based on the seed $sessionSeed. Then, instantly ask them to solve a complex architectural or logical problem specifically tying one of their Projects to one of their Skills. DO NOT use standard opening phrases like "Tell me about yourself".' : 'Generate the NEXT follow-up question based on the conversation below. Pivot to a completely different sub-topic within their skills, or invent a high-stakes scenario. DO NOT follow a predictable logical pattern from the last question.'}

Conversation so far:
$historyText

Questions already asked (BANNED TOPICS - DO NOT REPHRASE OR TOUCH THESE):
${alreadyAsked.isEmpty ? 'None yet' : '- $alreadyAsked'}

Rules:
- Ask exactly ONE question (1-3 sentences, professional but challenging tone).
- Return ONLY the question text, no labels, no quotes, no numbering.
''';

    final content = await _chatCompletion(
      prompt: prompt,
      temperature: 0.95,
      maxTokens: 200,
    );

    if (content != null && content.isNotEmpty) {
      return content.replaceAll(RegExp(r'''^["']|["']$'''), '').trim();
    }

    if (isFirstQuestion) {
      return 'Welcome! Please introduce yourself and describe the technical project you are most proud of in $technicalDomain.';
    }

    final fallbacks = [
      'Can you walk me through how you handled a challenging bug in a $technicalDomain project?',
      'How do you approach system design decisions when building $technicalDomain applications?',
      'Describe a time you had to optimize performance in a $technicalDomain codebase.',
      'What trade-offs did you consider when choosing your tech stack for a recent project?',
      'How do you ensure code quality and test coverage in $technicalDomain development?',
    ]..shuffle(_random);
    return fallbacks.first;
  }
}
