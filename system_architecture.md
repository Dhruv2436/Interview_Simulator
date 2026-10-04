# System Architecture: World-Class AI Interview Simulator

## Overview
To achieve a highly realistic, scalable, and dynamic AI interview experience inspired by FAANG companies, the simulator is being upgraded to a robust client-server architecture:

- **Frontend**: Flutter (Mobile / Web) for high-end UI, smooth voice wave animations, WebRTC interactions, and incorporating standard interview components like split-screen coding (using Monaco editor via Webview).
- **Backend Core**: FastAPI (Python) for asynchronous, high-performance orchestration.
- **Database**: PostgreSQL for persistent storage (users, interview history, performance tracking).
- **Caching & Memory**: Redis for rate limiting, maintaining real-time interview state, and providing sub-second conversational latency.
- **AI Engine**: GPT-5 / Gemini API integration (via OpenRouter or directly) to generate adaptive questions, score technical responses, and verify claims.
- **Code Execution**: Judge0 API for secure, multi-language remote code execution and testing with hidden edge-case schemas.
- **Voice Stack**: Whisper API (or local Whisper) for highly accurate speech-to-text, paired with human-like TTS (Text-to-Speech) modules.

## Features & Implementation Roadmap

### Phase 1: Database & Backend Foundation
- [ ] Set up FastAPI, SQLAlchemy, and Alembic for migrations.
- [ ] Connect to PostgreSQL and Redis.
- [ ] Define schemas for `User`, `InterviewSession`, `Question`, and `CodeSubmission`.

### Phase 2: Resume Parser & AI Question Generator
- [ ] Process uploaded PDF/DOCX resumes (PDFMiner/PyMuPDF).
- [ ] Pass the extracted resume to the AI Engine for capability mapping and exaggerated claim detection.
- [ ] Seed the Redis context with personalized starting questions (e.g. specific system design questions based on resume's listed architecture experience).

### Phase 3: The FAANG Code Interview Room
- [ ] Flutter UI upgrade: Integrated Monaco web-view or Flutter code editor for coding support.
- [ ] Backend routes pointing to the Judge0 API.
- [ ] Implement hidden evaluation schemas: checking time complexity, Big O performance, and logic edge cases.
- [ ] Send Code submissions to AI for immediate "Senior Engineer Code Review" (readability, modularity).

### Phase 4: Voice & Real-time Evaluation
- [ ] Integrate Speech-to-Text streaming with human-like pause detection so the candidate isn't interrupted unnaturally.
- [ ] Incorporate multi-metric evaluation (Skills, Confidence, Eye-contact via camera plugins, Fluency).
- [ ] Return a final composite score out of 100 with actionable feedback.

### Phase 5: Dashboard & Analytics Engine
- [ ] Generate aggregated candidate graphs.
- [ ] Integrate ATS checker capability directly into the candidate dashboard.
- [ ] Highlight weak points (e.g. Graph algorithms, Behavioral STAR method answers).
