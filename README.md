# 🚀 FAANG-Level AI Interview Simulator (Enterprise Architecture)

Welcome to the world-class **AI Interview Simulator**—a platform engineered to replicate the rigorous hiring processes used by top-tier tech firms like Google, Microsoft, and Amazon. This project features dynamic AI generation, multi-modal capabilities (voice, text, resume analysis), and an integrated coding execution environment.

## 🌟 Core Modules

### 1. Dynamic AI Interviewer 🤖
- Context-aware questioning with stateful conversation memory.
- Adaptive difficulty: As performance scales, questions get proportionally harder.
- Never flatters, actively challenges assumptions, and points out logic flaws.

### 2. Comprehensive Interview Tracks 🏢
- HR & Behavioral (STAR Method evaluations).
- Technical & System Design.
- Competitive Coding environment with hidden unit-tests.
- Custom/Managerial & Campus Placement interviews.

### 3. Smart Intelligence Stack 🧠
- **Resume parsing (PDF/DOCX)** extracts skills and formulates fact-checking verification questions to detect falsely claimed experiences.
- **Voice Stack**: Native STT (Speech-to-Text) & TTS (Text-to-Speech) providing human-like interaction loops.
- **Real-time Code Evaluation**: Monaco Editor + Judge0 API for instant feedback on code efficiency (Time/Space complexities).

## 🏗 System Architecture

1. **Frontend (Flutter)**: Premium UI featuring dark/light modes, split-screen coding environments, glassmorphism, dynamic voice-wave animations, and highly responsive layouts.
2. **Backend (FastAPI)**: Orchestrates the heavy lifting, sessions tracking, integration webhooks.
3. **Database & Cache**: PostgreSQL for persistent profiling; Redis for low-latency session and rate-limit tracking.
4. **AI & APIs**: OpenAI Model access (GPT-4o/Gemini), Judge0 (Remote Execution), Whisper (Voice translation). 
*(See `system_architecture.md` for a comprehensive breakdown)*

## 🛠 Project Setup

### Frontend (Flutter)
1. Navigate to the root directory
2. Install dependencies: `flutter pub get`
3. Add your OpenRouter/OpenAI API Keys in `lib/services/openai_service.dart`.
4. Run locally: `flutter run`

### Backend Server (FastAPI / Python)
1. Navigate to `cd backend`
2. Install Python requirements: `pip install -r requirements.txt`
3. Launch ASGI Server: `python main.py` or `uvicorn main:app --reload`
4. Visit `localhost:8000/docs` to view the Swagger API schemas.

---
**Evaluation Criteria** 📈  
*Candidates are scored out of 100 based on Technical Skills, Confidence, Problem Solving, Grammar, Edge-case tracking, and Behavioral alignment. Results are detailed in the Dashboard Performance Analytics.*
