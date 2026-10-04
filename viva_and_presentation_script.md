# SmartBro AI Interview Simulator - Presenter Script & Viva Defense Guide

---

## Part 1: Presenter Script (Word-for-Word Presentation Speech)

### **Slide 1: Title & Introduction**
> *"Good morning respected faculty members and examiners. Today, we are presenting our project: **SmartBro AI Interview Simulator & Placement Preparation Platform**.*
> 
> *In today's competitive job market, candidates face three major challenges:*
> 1. *Lack of realistic, real-time mock interview practice.*
> 2. *High rejection rates from automated Applicant Tracking Systems (ATS) without clear feedback.*
> 3. *High cost and unscalability of human mock interviews.*
> 
> *Our project solves this by delivering an automated, mobile-first ecosystem built in Flutter that combines ATS resume evaluation, dynamic MCQ screening, AI voice interviews, and real-time computer vision face proctoring."*

---

### **Slide 2: Technology Used**
> *"To achieve seamless performance and cross-platform capability, we selected a modern tech stack:*
> * *On the frontend, we use **Flutter with Dart**, providing cross-platform mobile apps for Android and iOS.*
> * *For intelligence, we integrated **OpenAI’s GPT-4o API** to parse resumes, generate adaptive technical MCQs, and grade candidate verbal responses.*
> * *For computer vision and proctoring, we use **Google ML Kit Face Detection**, running on-device at 30 FPS to track head pose angles and eye contact.*
> * *For audio processing, we combine **Text-to-Speech (`flutter_tts`)** for synthesized AI interviewer questions and **Speech-to-Text (`speech_to_text`)** for candidate answers.*
> * *For document processing and reports, we use **Syncfusion PDF Parser** and Flutter's **Native Printing/PDF Service**."*

---

### **Slide 3: Proposed Work & Pipeline**
> *"Our application follows a strict 4-stage progressive pipeline:*
> 1. ***Stage 1 - ATS Resume Analysis:** The user uploads a resume PDF. The system extracts skills, experience, and projects, comparing them against the target job description to produce a match percentage.*
> 2. ***Stage 2 - Adaptive MCQ Testing:** Based on the selected role, dynamic technical MCQs are generated. Candidates must score above the passing threshold (e.g., 75%) to qualify for the next round.*
> 3. ***Stage 3 - AI Voice & Video Interview:** The candidate faces the camera. The front camera streams to ML Kit for face proctoring, while the AI interviewer speaks questions and records candidate answers.*
> 4. ***Stage 4 - Analytics & Report Generation:** The system compiles scores across technical accuracy, speech fluency, and face confidence into a downloadable PDF report."*

---

### **Slide 4: System Design & Diagrams**
> *"Here we present the architecture and sequence flow of our system.*
> * *The Architecture Diagram shows the separation between the **Flutter Presentation Layer**, **Core Processing Layer (OpenAI, ML Kit, TTS/STT)**, and **Cloud External Services**.*
> * *The Sequence Diagram details the candidate transition from MCQ evaluation to the AI Interview round. If a candidate passes the qualification threshold, the ML Kit camera engine and OpenAI voice stream initialize automatically."*

---

### **Slide 5: Implementation Screens**
> *"Let us look at the key implementation screens:*
> * ***Role Selection & Setup (`interview_setup_screen.dart`):** Allows candidates to choose their domain and configure question limits.*
> * ***ATS Resume Screening (`ats_checker_screen.dart`):** Displays parsed resume information with matched and missing skill badges.*
> * ***MCQ Result & Review Sheet (`mcq_result_screen.dart`):** Shows pass/fail status and an interactive bottom sheet for reviewing correct options and explanations.*
> * ***Live AI Interview (`interview_screen.dart`):** Shows camera preview with bounding box proctoring overlay and live speech transcription.*
> * ***Performance Dashboard (`final_dashboard_screen.dart`):** Summarizes overall performance with PDF report export."*

---

### **Slide 6: Timeline Chart**
> *"Our project development was executed in 4 distinct phases over a 3-month schedule:*
> * ***Phase 1:** Literature review, UI wireframing, and initial setup.*
> * ***Phase 2:** ATS PDF extraction and dynamic MCQ engine development.*
> * ***Phase 3:** OpenAI GPT-4o API integration, ML Kit face detection, and Speech services.*
> * ***Phase 4:** Performance dashboard creation, PDF export service, and end-to-end testing."*

---

### **Slide 7: Future Work**
> *"In future iterations, we plan to expand this platform by:*
> 1. *Adding multi-lingual voice interviews in regional languages (Hindi, Gujarati, Spanish, French).*
> 2. *Integrating audio pitch frequency analysis for stress and emotion detection.*
> 3. *Building an HR / Institutional Web Portal for recruiters to review candidate recordings and scores.*
> 4. *Introducing collaborative peer-to-peer live mock rooms."*

---

### **Slide 8: Conclusion**
> *"In conclusion, we have successfully developed an end-to-end AI Interview Simulator in Flutter. By combining generative AI with on-device computer vision and speech synthesis, we provide candidates with a scalable, low-cost, and realistic tool to master their placement interviews. Thank you!"*

---

## Part 2: Top 15 Project Viva Questions & Answers (Examiner Defense)

#### **Q1: Why did you choose Flutter instead of React Native or Native Android?**
> **Answer:** Flutter provides near-native execution speed through Dart AOT compilation, consistent cross-platform UI rendering across iOS and Android, and seamless integration with native plugins like `camera` and `google_mlkit_face_detection`.

#### **Q2: How does Google ML Kit perform face detection in real time without lag?**
> **Answer:** Google ML Kit runs on-device using quantized mobile neural networks (tflite). We pass camera image frames asynchronously via Dart streams to `FaceDetectorService`, avoiding UI thread blocking.

#### **Q3: How does the system track head pose and eye contact?**
> **Answer:** ML Kit returns face rotation angles:
> * **Euler X:** Pitch (looking up/down)
> * **Euler Y:** Yaw (turning head left/right)
> * **Euler Z:** Roll (tilting head side-to-side)
> If the Euler Y angle exceeds ±20 degrees, the proctoring engine flags the user as looking away from the screen.

#### **Q4: How does the ATS resume parser work?**
> **Answer:** We use `file_picker` to obtain the PDF file, `syncfusion_flutter_pdf` to extract raw text content, and pass the text along with target Job Description keywords to OpenAI GPT-4o. The model returns structured JSON containing matched skills, missing keywords, and the calculated match percentage.

#### **Q5: What happens if the candidate fails the MCQ round?**
> **Answer:** In `mcq_result_screen.dart`, we calculate `percentage = (score / total) * 100`. If `percentage < 75`, the system displays a "NOT QUALIFIED" card and restricts entry to the AI Interview, prompting the user to review answers and try again.

#### **Q6: How do you handle API key security in Flutter?**
> **Answer:** API keys are stored in isolated environment/secrets configuration files (`lib/secrets.dart`) and injected at build time, ensuring secrets are not exposed in client code repositories.

#### **Q7: What Speech Recognition and Synthesis engines are used?**
> **Answer:** Speech-to-Text (`speech_to_text`) uses the device's native speech recognition engine (Google Speech Services on Android / SFIOS on iOS). Text-to-Speech (`flutter_tts`) synthesizes natural voice responses for AI questions.

#### **Q8: How is the overall performance score computed in the dashboard?**
> **Answer:** The overall score is a weighted average:
> * **Technical MCQ Score:** 35%
> * **AI Voice Interview Score:** 40%
> * **Face Proctoring & Confidence Score:** 25%

#### **Q9: How are the PDF reports generated and exported?**
> **Answer:** `pdf_report_service.dart` uses the Dart `pdf` package to layout custom multi-page documents containing candidate profile metadata, score breakdown charts, and feedback, which are rendered via the native `printing` preview widget.

#### **Q10: What makes your project unique compared to existing platforms?**
> **Answer:** Most existing platforms only offer written ATS checks or text-based chatbots. Our platform combines **ATS resume checking**, **dynamic MCQs**, **voice interaction (TTS/STT)**, and **real-time video face proctoring** into a unified mobile application.
