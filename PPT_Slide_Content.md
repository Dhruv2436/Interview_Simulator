# AI Interview Simulator — PPT Slide Content
# All content verified directly from source code — 100% Truth Only

---

## SLIDE 11 — Resume Analysis Module

**Title:** Resume Analysis Module

- Resume Upload: PDF, DOC, DOCX up to 10 MB using file_picker package
- PDF Text Extraction: Raw text via syncfusion_flutter_pdf (PdfTextExtractor)
- AI Parsing by Google Gemini 1.5 Flash: Extracts Name, Email, Phone, College/Degree, Skills, Projects, Experience, Certifications
- Regex Fallback: If AI fails or text < 30 chars, local Regex parser runs (zero failure)
- Job Description Field: Optional collapsible input for precise ATS matching

ATS Scoring — Two Modes:
  AI-Scored (Gemini): Triggered when JD is pasted. Gemini evaluates Education (25%), Skills (40%), Experience (35%)
  Keyword-Based: Triggered when no JD. Skills/Education/Projects matched against role keywords

ATS Report Shows:
- Circular progress indicator with ATS % score
- Section scorecards: Education / Skills / Experience — score, reasoning, improvement tips (expandable)
- Matched Skills (green chips), Missing Skills (red chips)
- AI-generated suggestions list
- GATE: ATS >= 50%  Continue to Interview | ATS < 50%  Blocked, Return Home

---

## SLIDE 12 — MCQ Assessment Module

**Title:** MCQ Assessment Module

AI Question Generation:
- Live questions from Google Gemini 1.5 Flash via OpenRouter API
- Configurable: Aptitude + Technical count (set in Interview Setup screen)
- Unique time-based seed per session (no repetition)
- 3 API retries  offline fallback question bank if all fail

Aptitude Topics Pool (27 categories):
Arithmetic, Percentage, Profit & Loss, Probability, Permutation & Combination, Time & Work, Speed/Distance/Time, Mixture, Age Problems, Blood Relation, Direction Sense, Coding-Decoding, Logical Reasoning, Puzzles, Number Series, Calendar, Clock Problems, Vocabulary, Analogy, Reading Comprehension, Synonyms, Antonyms, Sentence Correction, Verbal Ability, Seating Arrangement, Grammar, Average

Technical Questions:
- Scenario-based, role-specific (not definition-style)
- Built from: Selected Role + Resume Projects + Extracted Skills
- Topics: Design Patterns, Architecture, CI/CD, Caching, Concurrency, Debugging, APIs

MCQ Test Screen Features:
- Live countdown timer (Green  Amber  Red), auto-submit at zero
- Timer = total_questions x minutes_per_question (set during setup)
- Previous/Next buttons, pagination dots (tap to jump to any question)
- Category badge per question (e.g., Aptitude — Probability)

MCQ Result Screen:
- Score (e.g., 14/20) + circular percentage ring
- PASSING THRESHOLD: 75% (verified from code)
- Review All Answers bottom sheet: correct = green, wrong = red
- GATE: >= 75%  AI Interview | < 75%  Return Home

---

## SLIDE 13 — Coding Assessment Module (Optional)

**Title:** Coding Assessment Module (Optional)

CURRENT STATUS: NOT IMPLEMENTED

- Marked as Optional in project scope
- No coding screen exists in /lib/screens/
- Current app flow: MCQ Assessment  AI Interview (no coding screen in between)

Planned for Future Version:
- Language selection (Python, Java, C++, Dart, etc.)
- In-app code editor with syntax highlighting
- AI evaluation: correctness, time complexity, code quality
- Role-matched DSA problems

---

## SLIDE 14 — AI Interview Module

**Title:** AI Interview Module

Technologies:
- AI Model: Google Gemini 1.5 Flash (OpenRouter API)
- Voice Input: speech_to_text package — auto-listens after AI speaks
- Voice Output: flutter_tts package — AI reads every question aloud

Interview Flow (verified from code):
1. Start Gate shows: candidate name, company, role, difficulty, MCQ score
2. Tap "Launch AI Technical Interview"
3. AI speaks welcome + first question via TTS
4. Microphone auto-opens, live transcript shown
5. Candidate speaks  auto-submitted when done
6. Gemini evaluates: Score (1-10), Strength, Improvement feedback
7. AI speaks brief feedback aloud
8. Candidate reads feedback  taps "Next Question" (manual gate before moving on)
9. Repeat steps 3-8 for all questions
10. "End Interview" button stops session at any time

AI Question Intelligence:
- Full conversation history passed to AI to prevent topic repetition
- Difficulty adapts to candidate's ATS + MCQ combined score
- Questions built from resume skills, projects, experience

Answer Modes:
- Voice Mode (default): Auto-listen, live speech transcript
- Typing Mode: Toggle button to type instead of speaking

---

## SLIDE 15 — Face & Voice Analysis

**Title:** Face & Voice Analysis

Camera:
- Front camera (CameraLensDirection.front), Medium resolution, NV21 format
- Package: camera ^0.10.5+5
- Fullscreen camera preview with gradient overlays during interview

On-Device Face Detection:
- Library: google_mlkit_face_detection — runs entirely locally, nothing sent externally
- Processes camera image stream frame-by-frame
- Works on Android & iOS only (Web disabled via kIsWeb flag in code)

Face Analytics Tracked (RealFaceAnalytics model):
- Face detected/not detected (bool), Face count
- Head angles: X pitch, Y yaw, Z roll
- Eye contact score + eye contact percentage
- Confidence score, facial engagement score, attention score
- Estimated emotion: shown in badge (e.g., CONFIDENT, NEUTRAL)
- Position status, Head pose status, Presence status

Live Visual Feedback During Interview:
- Face bounding box: Green = detected, Red = not detected
- Top bar badge: emotion label or "NO FACE"
- Alert banners: "ALERT: No face detected! Please face the camera."
- Alert banners: "ALERT: Multiple faces detected!"

Permission Gate Screen (shown before interview):
- Requests Camera + Microphone via permission_handler
- Status: Granted (green) / Not Granted (orange) / Permanently Denied (red)
- "Open App Settings" shortcut if permanently denied
- Interview only launches when BOTH permissions are Granted
- Privacy note shown: "Processed locally. Nothing recorded or stored remotely."

---

## SLIDE 16 — User Interface Screens

**Title:** User Interface — All 15 Screens

 1  Splash Screen          — App launch branding + animation
 2  Welcome Screen         — Intro and start button
 3  Role Selection         — Job role, experience level, difficulty
 4  Upload Resume          — PDF/DOC upload + optional Job Description
 5  ATS Analysis Report    — Score donut, section breakdown, skill chips, suggestions
 6  Extracted Info         — Parsed resume: name, email, phone, education, skills, projects
 7  Instructions           — Interview rules and preparation checklist
 8  Interview Setup        — Company name, MCQ count, minutes-per-question config
 9  Permission Gate        — Camera + mic permission request with live status
10  MCQ Test               — Timed MCQ, countdown, progress bar, pagination dots
11  MCQ Result             — Score, 75% gate, full answer review bottom sheet
12  AI Interview Bridge    — Passes MCQ data to interview screen
13  AI Interview           — Live camera, voice Q&A, face detection, feedback overlay
14  Final Dashboard        — Score breakdown, recommendation, Download PDF button
15  Report Preview         — Full report view before downloading

Design System (from code):
- #5B42FA Purple: primary buttons, MCQ screens
- #6366F1 Indigo: AI interview screen, badges
- #10B981 Emerald: pass, face detected, matched skills
- #F59E0B Amber: medium score, MCQ result trophy
- #EF4444 Red: fail, no face detected, missing skills
- #0F172A Dark: interview + dashboard backgrounds
- White: form and report screens
- Animations: animate_do (FadeInDown, FadeInUp)
- Loading: flutter_spinkit SpinKitPulse

---

## SLIDE 17 — Performance Dashboard

**Title:** Performance Dashboard

Score Breakdown Displayed:
  ATS Score          From ATS module result
  MCQ Score          (Correct / Total) x 100
  Technical          From AI evaluation session
  Communication      Displayed on dashboard
  Confidence         Displayed on dashboard
  OVERALL SCORE      Formula: (MCQ% x 40%) + (Technical% x 60%) [verified from code]

Hiring Recommendation:
- Overall >= 70%: "You are Interview Ready!" — positive outcome
- Overall < 70%: "Keep Practicing!" — review and retry easier level

Actions on Dashboard:
- "View Report"  Report Preview Screen
- "Download PDF"  Generates and shares professional PDF report

PDF Report Contains (from PdfReportGenerator service):
- Candidate name, company, role, overall score
- Face analytics: eye contact %, attention score, estimated emotion, presence status
- Per-answer evaluation: strengths + improvements for every question
- Module scores: MCQ%, voice%, communication rating, technical depth, confidence rating
- Hiring recommendation: "Strong Hire" (>=80%), "Hire" (>=65%), "Borderline"
- Key strengths list, areas for improvement, summary paragraph

Note: History section NOT present — removed during development

---

## SLIDE 18 — Results & Testing

**Title:** Results & Testing

Scoring Gates (code-verified):
  ATS Gate   >= 50% to proceed (ats_checker_screen.dart)
  MCQ Gate   >= 75% to proceed (mcq_result_screen.dart)
  AI Eval    Score 1-10 per answer (openai_service.dart)

API & AI Details:
  Model: google/gemini-1.5-flash via OpenRouter
  MCQ Generation: Temperature 0.85-0.95, Max Tokens 8192, 3 retries
  Resume/ATS:     Temperature 0.1 (precision mode)
  General calls:  Temperature 0.7, Max Tokens 4096

All Packages (from pubspec.yaml):
  http                       ^1.1.0       — API calls
  camera                     ^0.10.5+5    — Camera capture
  speech_to_text             ^6.6.1       — Voice recognition (STT)
  flutter_tts                ^3.8.5       — AI voice output (TTS)
  file_picker                ^10.3.2      — Resume upload
  syncfusion_flutter_pdf     ^33.2.13     — PDF text extraction
  google_mlkit_face_detection ^0.12.0     — On-device face detection
  permission_handler         ^11.0.1      — Camera/mic permissions
  pdf                        ^3.10.8      — PDF report generation
  printing                   ^5.13.1      — PDF sharing dialog
  animate_do                 ^3.1.2       — Screen animations
  flutter_spinkit            ^5.2.0       — Loading spinners
  google_fonts               ^6.1.0       — Typography
  fl_chart                   ^0.68.0      — Chart widgets
  hive + hive_flutter        ^2.2.3       — Local key-value storage
  flutter_riverpod           ^2.5.1       — State management
  intl                       ^0.20.2      — Date/time formatting
  path_provider              ^2.1.4       — File system paths

Flutter SDK: ^3.11.1  |  Language: Dart

---

## SLIDE 19 — Future Enhancements

**Title:** Future Enhancements

 1. Coding Assessment Module       — Optional, not built in this version
 2. Multiple Language Support       — English only; STT/TTS English only
 3. Company-Specific Interview Packs — Company field in setup but no company question bank
 4. Cloud Storage & User Accounts   — Local Hive only; no login or cloud sync
 5. Recruiter / Admin Dashboard     — No recruiter portal in current version
 6. Interview History Section       — Removed; needs cloud backend to restore
 7. Full Web Platform Support       — Face detection disabled on Web (kIsWeb flag)
 8. Interview Scheduling            — No calendar or scheduling integration
 9. HR Round & Group Discussion     — Only one AI interview round currently
10. Offline AI Model                — Requires internet; no on-device LLM
