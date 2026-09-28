# JAGO — National Tribal Scholarship Platform Task Matrix
**Ministry of Tribal Affairs (MoTA), Government of India**  
**National Unified ST Scholarship Verification & Discrepancy Resolution Engine**  
**Core Mantras:**  
1. *"One Student. One Verified Profile. One Dashboard. Five Scholarship Schemes."*  
2. *"Reuse what is verified. Revalidate what changes. Route what needs review."*

---

## 📌 Implementation Status Overview

| Component | Stack | Status | Target / Port |
|---|---|:---:|---|
| **Student Mobile App** | Flutter (Dart) + Hardware Phone Chassis | ✅ **COMPLETED & ENHANCED** | [http://localhost:3000](http://localhost:3000) |
| **Backend & Verification Engine** | FastAPI (Python) + SQLite / PostgreSQL | ✅ **COMPLETED & ENHANCED** | [http://127.0.0.1:8000](http://127.0.0.1:8000) |
| **MoTA Officer Admin Dashboard** | React 18 + Vite + Tailwind CSS | ✅ **COMPLETED & ENHANCED** | [http://localhost:5173](http://localhost:5173) |
| **Containerization & Deployment** | Dockerfile + docker-compose.yml | ✅ **COMPLETED** | `docker compose up` |
| **Automated Test Suite** | Flutter Widget Tests + API Health Checks | ✅ **PASSED** | Exit Code 0 |

---

## 🎨 UI/UX & Polish Improvements Completed

1. **Complete Removal of Hackathon / SIH Branding**:
   - Replaced all SIH, hackathon, and prototype tags with official **Ministry of Tribal Affairs, Government of India** identity across the entire codebase (Flutter, React, FastAPI, schemas, seeders).
   - National Portal branding: *"National Unified ST Scholarship Verification & Sanction Portal"*.

2. **Ultra-Realistic 6.7" Flagship Smartphone Frame**:
   - Realistic metallic volume rocker and power buttons on the phone chassis.
   - Dynamic Island camera cutout with integrated speaker slit.
   - Live system status bar (`09:41`, 5G, Wi-Fi, battery indicator).
   - Smooth curved titanium bezel with ambient back-glow.
   - Interactive segmented mode toggle: **📱 View in Phone Frame** vs. **🖥️ Expand Fullscreen**.

3. **Presentation Quick-Switcher Dock**:
   - Integrated a horizontal carousel of quick-navigation chips in the web shell for instant 1-click access to all 13 core screens during reviews:
     - `🏠 Landing`
     - `🔑 Login`
     - `📊 Dashboard`
     - `👤 Profile`
     - `📁 Vault`
     - `🎓 Schemes`
     - `💳 DBT Pay`
     - `🤖 JAGO AI`
     - `🔔 Alerts`

4. **National Tricolor Aesthetic**:
   - Saffron (`#FF671F`), White, and Forest Green (`#046A38`) decorative header accent bars.
   - High-contrast official typography and verification badge styling (`UIDAI Verified`, `DigiLocker`, `AISHE`).

---

## 📱 Module 1: Student Mobile Application (Flutter)
All 13 screens implemented with zero stubs, real state binding, and native 6.7" smartphone mockup framing.

- [x] **Shell & Mockup Frame (`lib/widgets/device_frame_wrapper.dart`)**
  - [x] 6.7" curved matte titanium smartphone chassis with side hardware buttons.
  - [x] Dynamic Island / camera punch-hole cutout with integrated speaker slit.
  - [x] Live system status bar (`09:41`, 5G, Wi-Fi, battery indicator).
  - [x] Responsive mode switcher (📱 Mobile Frame vs. 🖥️ Full Screen).
  - [x] Quick navigation carousel dock for instant testing.

- [x] **Screen 1: Landing Screen (`lib/screens/landing_screen.dart`)**
  - [x] Official MoTA branding with National Emblem insignia.
  - [x] English / Hindi (EN/HI) instant bilingual language toggle.
  - [x] 3 Value Proposition feature cards with high-contrast typography.
  - [x] Primary CTA buttons: "Student Login" & "Explore Demo".

- [x] **Screen 2: Student Login (`lib/screens/student_login_screen.dart`)**
  - [x] Mobile number & OTP verification flow (Demo OTP: `123456`).
  - [x] One-tap "⚡ Demo Login as Rahul Kumar" shortcut.
  - [x] Aadhaar-linked phone authentication simulation.

- [x] **Screen 3: Unified Student Dashboard (`lib/screens/dashboard_screen.dart`)**
  - [x] Prominent 92% profile completion progress indicator.
  - [x] 4 Key Metric summary tiles: Active Schemes, Sanctioned Amount, Disbursed, Verified Status.
  - [x] Real-time Action Required card for expired income certificates.
  - [x] Profile readiness checklist with direct navigation deep links.
  - [x] Persistent bottom navigation bar (Home, Profile, Schemes, Vault, AI Chat).

- [x] **Screen 4: Unified Student Profile (`lib/screens/profile_screen.dart`)**
  - [x] 6 Structured data sections: Personal, Caste/Tribe, Academic, Bank/DBT, Family, Documents.
  - [x] Data provenance badges for every field (`UIDAI Verified`, `DigiLocker`, `AISHE`).
  - [x] MoTA Data Reuse Policy banner explaining zero redundant re-entry.

- [x] **Screen 5: DigiLocker & Document Vault (`lib/screens/documents_screen.dart`)**
  - [x] 8 Verified document slots: Caste (ST), Income, Domicile, 10th/12th Marksheet, College ID, Bonafide, Ration Card.
  - [x] Live status badges (`Verified`, `Expiring Soon`, `Missing`).
  - [x] Interactive DigiLocker sync simulation.
  - [x] In-app document preview dialog with metadata inspection.

- [x] **Screen 6: Scheme Discovery & Eligibility Engine (`lib/screens/scholarships_screen.dart`)**
  - [x] 5 MoTA National Scholarship Schemes:
    1. Pre-Matric Scholarship for ST Students
    2. Post-Matric Scholarship for ST Students
    3. National Fellowship for Higher Education of ST Students
    4. National Overseas Scholarship for ST Students
    5. Top Class Education Scheme for ST Students
  - [x] Real-time eligibility evaluation matrix against current student profile.
  - [x] "One-Scheme" policy enforcement alert warning against dual financial benefits.

- [x] **Screen 7: Application Prep & Data Reuse (`lib/screens/application_prep_screen.dart`)**
  - [x] Instant auto-population of 22 verified profile attributes.
  - [x] Automatic isolation of expired income certificate.
  - [x] Single-tap OCR revalidation and simulated re-upload flow.

- [x] **Screen 8: Final Application Submission (`lib/screens/application_form_screen.dart`)**
  - [x] Tamper-proof, locked pre-filled data fields.
  - [x] DBT-enabled Aadhaar-seeded bank account selection.
  - [x] Statutory digital declaration and consent checkbox.
  - [x] Pre-submission review summary modal with confirmation alert.

- [x] **Screen 9: Verification Orchestrator (`lib/screens/verification_screen.dart`)**
  - [x] Live animated 8-step verification pipeline:
    1. Aadhaar Demographic & Biometric Match (UIDAI)
    2. ST Caste Certificate Validity (State e-District)
    3. Income Threshold Compliance (Revenue Dept)
    4. Institutional AISHE Code Validation
    5. Academic Enrollment & APAAR Match
    6. Bank Account DBT Aadhaar-Seeding (NPCI)
    7. No-Duplicate Benefit Check (MoTA Registry)
    8. Cross-Verification Synthesis
  - [x] Mismatch Tolerance: Flags minor institution naming differences without auto-rejection.
  - [x] Intelligent Routing: Auto-routes flagged cases to Officer Review Queue.

- [x] **Screen 10: Application Tracking & Timeline (`lib/screens/application_tracking_screen.dart`)**
  - [x] Interactive 5-stage timeline: Submitted → Institute Verification → State Nodal Review → MoTA Approval → DBT Sanction.
  - [x] Real-time status indicators and tracking ID reference.
  - [x] Deficiency explanation card with direct resolution actions.

- [x] **Screen 11: Payments & DBT Tracking (`lib/screens/payments_screen.dart`)**
  - [x] Direct Benefit Transfer summary cards: Total Sanctioned vs. Disbursed.
  - [x] Transaction history list with PFMS UTR numbers and credit timestamps.
  - [x] NPCI Aadhaar-linking confirmation badge.

- [x] **Screen 12: JAGO AI Assistant (`lib/screens/jago_chat_screen.dart`)**
  - [x] Bilingual conversational assistant (English & Hindi).
  - [x] Strict grounding in MoTA scholarship rules (anti-hallucination guardrails).
  - [x] Quick-prompt recommendation chips for instant queries.

- [x] **Screen 13: Notifications & Alerts (`lib/screens/notifications_screen.dart`)**
  - [x] Categorized alert feed (Verification, Scheme Deadlines, DBT Payments).
  - [x] Unread badge counter and "Mark all as read" capability.

---

## ⚙️ Module 2: Backend API & Verification Engine (FastAPI)
Located at `backend/` running on `http://127.0.0.1:8000`.

- [x] **Database Schema & ORM (`app/models.py`, `app/database.py`)**
  - [x] Models for `User`, `StudentProfile`, `Document`, `Scheme`, `Application`, `VerificationRecord`, `ReviewCase`, `Payment`, `Notification`, `UnreachedStudent`.
  - [x] Automatic database migration and SQLite/PostgreSQL connection pool.
- [x] **Database Seeder (`app/seed.py`)**
  - [x] Realistic demo profile for Rahul Kumar (Post-Matric ST Scholar).
  - [x] 5 MoTA National Scholarship Schemes with eligibility rule trees.
  - [x] Seeded review cases including institution naming discrepancies.
  - [x] 300 Unreached Student records for saturation analysis.
- [x] **Auth Endpoints (`app/routes/auth.py`)**
  - [x] Student OTP verification and 1-tap demo token generation.
  - [x] Officer credential authentication (`officer@mota.gov.in`).
- [x] **Student Endpoints (`app/routes/student.py`)**
  - [x] CRUD for Profile, Document Vault, Schemes, Applications, and Payments.
  - [x] Document OCR upload and certificate validity re-evaluation.
  - [x] Application submission trigger for Verification Orchestrator.
- [x] **Verification Orchestrator (`app/services/verification_orchestrator.py`)**
  - [x] Multi-registry validation pipeline simulating UIDAI, DigiLocker, AISHE, APAAR, UDISE+, State e-District, UGC-NTA.
  - [x] Fuzzy string matching tolerance (*ABC Institute of Technology* vs *ABC Institute of Engineering*) routing to review rather than rejection.
- [x] **OCR Service (`app/services/ocr_service.py`)**
  - [x] Simulated structured extraction from uploaded certificate images and PDFs.
- [x] **JAGO AI Knowledge Base (`app/services/jago_ai.py`)**
  - [x] RAG-grounded MoTA FAQ and guideline repository.
  - [x] State-aware contextual answering in Hindi and English.
- [x] **Admin Endpoints (`app/routes/admin.py`)**
  - [x] 8 Real-time KPI statistics calculations.
  - [x] Officer Review Queue with filters (Urgency, Discrepancy Type, Date).
  - [x] Action handler (Approve, Request Correction, Reject).
  - [x] Geographic saturation and unreached student cluster querying.

---

## 👨‍💼 Module 3: MoTA Officer Admin Dashboard (React + Vite)
Located at `admin_dashboard/` running on `http://localhost:5173`.

- [x] **Screen 1: Officer Login (`src/pages/AdminLogin.jsx`)**
  - [x] Secure government portal authentication with demo credentials pre-filled.
- [x] **Screen 2: Officer Dashboard (`src/pages/Dashboard.jsx`)**
  - [x] 8 Live KPI stat cards (Total Registered, Verified ST, Applications, Manual Review Queue, Sanctioned, DBT Crores, Unreached).
  - [x] Common Deficiencies breakdown chart.
- [x] **Screen 3: Review Queue (`src/pages/ReviewQueue.jsx`)**
  - [x] Filterable data grid of flagged applications.
  - [x] Severity and mismatch type badges.
- [x] **Screen 4: Review Case Details (`src/pages/ReviewCase.jsx`)**
  - [x] Side-by-side comparison: Student Submitted Data vs. Official Government Registry Record.
  - [x] Visual highlight of flagged discrepancies (e.g. Institution name variance).
  - [x] Action toolbar: "Approve Verification", "Request Student Correction", "Reject".
- [x] **Screen 5: Unreached Students Explorer (`src/pages/UnreachedStudents.jsx`)**
  - [x] Saturation analysis table for 300 tribal students without active scholarship claims.
  - [x] Filter by State, District, and Saturation Priority.
  - [x] Bulk SMS & CSC (Common Service Centre) outreach dispatch trigger.
- [x] **Screen 6: Verification Layer Monitor (`src/pages/VerificationLayer.jsx`)**
  - [x] Real-time health and latency monitor for all 7 simulated government registries.
