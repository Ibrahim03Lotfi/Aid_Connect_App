# Athar (أَثَــر) — Smart Humanitarian Relief & Development Platform (`SM1_readme`)

Welcome to **Athar (أَثَــر)** (also known in the repository as **Aid Connect**), a comprehensive, next-generation humanitarian relief, field operations, and smart aid distribution platform tailored for the Syrian context.

This document is designed for **two audiences**:
1. **Non-Technical Readers, Strangers, & Stakeholders**: Explains *what* the project is, *why* it matters, and *how* it works in plain, everyday language without confusing jargon.
2. **Technical Developers, Engineers, & Evaluators**: Details the full system architecture, database schema, AI algorithms, NFC anti-fraud mechanisms, GIS mapping implementation, API contracts, and automated test suites.

---

## Part 1: For Everyone (Non-Technical Overview)

### 1.1 What Problem Are We Solving?
In humanitarian crises and charity work, organizations and donors face four major challenges:
1. **Chaos & Slow Paperwork**: Families in need wait weeks for paper applications and medical bills to be reviewed manually.
2. **Double-Dipping & Aid Duplication**: Without a unified digital system, the same person might collect multiple aid packages from different distribution points while other families receive nothing.
3. **Fake Documents & Reused Photos**: Scammers sometimes reuse old photos from the internet or alter medical invoices to collect donations fraudulently.
4. **Lack of Donor Trust**: Donors want to know where their money goes, whether a family's need was verified on the ground, and when the aid was actually delivered.

### 1.2 What Did We Build?
We built **Athar**, an all-in-one digital ecosystem consisting of two main parts that work together in real time:
1. **A Mobile App (Flutter)** used by **Citizens/Donors**, **Field Volunteers**, and **Charity Organizations**.
2. **A Web Command Operations Center (Laravel Dashboard)** used by **Administrators, Dispatchers, and Auditors** to monitor the entire country on a live map, audit cases with AI, manage warehouse stock, and track every aid package delivered.

### 1.3 How Does the Platform Work? (Step-by-Step Story)

#### Step 1: A Citizen Requests Help (or a Donor Browses Cases)
* **Requesting Aid**: A family in need opens the mobile app and fills out a simple **3-Step Aid Wizard** (selecting the type of need—Medical, Shelter, Food, Education—describing their situation, and uploading photos of their medical bill or damaged home).
* **Tracking Progress**: Just like tracking a delivery order, the family can see a live 6-stage timeline of their case (*Submitted -> Under Review -> Field Inspection -> Approved -> Funded -> Aid Delivered*).
* **Social Impact Feed & Donations**: Approved cases appear on an interactive social feed (complete with "Impact Reels" video/photo stories, comments, and likes). Donors can contribute directly using **Sham Cash**, **Syriatel Cash**, **MTN Cash**, or bank transfers, and watch the funding progress bar fill up.

#### Step 2: Artificial Intelligence (AI) Checks the Request Instantly
Before an administrator even opens the file, Athar's built-in **AI Engine** automatically inspects the submission:
* **Medical Invoice Auditor**: Reads uploaded hospital bills, extracts the hospital name and line items, and checks the math to make sure the total wasn't tampered with.
* **Shelter Damage Analyzer**: Looks at photos of damaged houses or tents and scores how dangerous the living conditions are.
* **Arabic Urgency Classifier**: Reads the Arabic description of the case, spots critical words (like *ICU, kidney dialysis, collapsed roof, orphans*), and assigns an **Urgency Score from 0 to 100** (ranking cases from Tier 1 Immediate Emergency to Tier 4 Standard Aid).
* **Duplicate Photo Detector**: Generates a visual "fingerprint" of every uploaded photo. If someone downloads a photo from an old case, crops it, and re-uploads it, the system flags it immediately as a duplicate.

#### Step 3: Command Center Triage & Volunteer Field Inspection
* Administrators in the **Web Command Center** see the highest-priority cases at the top of their screen.
* With one click, the admin assigns the nearest **Field Volunteer** to visit the family.
* The volunteer receives a notification on their phone, visits the family's home, and fills out a **Field Living Condition Survey** (checking roof/wall conditions, family size, children/elderly count, and income) to calculate an objective **Vulnerability Score**. Even if the volunteer has no internet connection in a remote area, the app saves the survey offline and syncs it automatically when they reconnect.

#### Step 4: Contactless Aid Delivery via Smart NFC Cards (Zero Double-Dipping)
* Every verified beneficiary family receives a physical **NFC Smart Card** (similar to a contactless bank card).
* When an aid truck arrives in a neighborhood for a campaign (e.g., *"Winter Warmth Campaign"*), the volunteer opens the **NFC Aid Scanner** on their smartphone and taps the family's card:
  * **First Tap**: In less than a second, the app verifies the family's identity, confirms their entitlement, records the delivery, and deducts the package from the warehouse inventory.
  * **Second Tap (Fraud Attempt)**: If the same card is tapped again for the same campaign—even at a different distribution point—the screen flashes red and **blocks the delivery immediately** (*"Double-Dipping Blocked"*).

#### Step 5: Rewarding Volunteers & Publishing Official Transparency Reports
* **Volunteer Digital Passport**: Every hour a volunteer spends in the field is logged. Volunteers earn ranks (like *"Knight of Impact"*), unlock digital badges, and can generate an **Official Printable Certificate with a QR Code** that universities or employers can scan to verify their humanitarian service.
* **Annual Impact Report**: The Command Center generates a printable, official financial and humanitarian audit report showing total families helped, funds distributed, warehouse stock, and 100% anti-duplication compliance.

---

## Part 2: Technical Architecture & Engineering Deep Dive

### 2.1 Technology Stack

| Layer | Technology / Framework | Purpose |
| :--- | :--- | :--- |
| **Mobile & Cross-Platform App** | Flutter (Dart 3.x), `flutter_bloc` | Multi-persona client app (User/Donor, Volunteer, Organization) following Clean Architecture. |
| **Backend Core & REST API** | Laravel 11 / 12 (PHP 8.2+) | Stateless REST API (`/api/*`) + Server-rendered Operations Command Center (`/dashboard/*`). |
| **Web Operations UI** | Laravel Blade, Tailwind CSS, Alpine.js | Responsive RTL Arabic command center with Dark/Light mode, interactive modals, and live telemetry. |
| **Geospatial Mapping (GIS)** | Leaflet.js 1.9.4 + OpenStreetMap Tiles | Interactive multi-layer map covering all 14 Syrian governorates and their districts. |
| **Hardware Simulation & NFC** | Mobile NFC Scanner + Web 3D NFC Simulator | ISO-14443 contactless smart card provisioning, pairing, tap verification, and anti-double-dipping ledger. |
| **Applied AI Engine** | Gemini 1.5 Vision API + Custom PHP Heuristic/dHash Fallbacks | Multimodal OCR invoice auditing, shelter damage scoring, Arabic NLP triage, and 64-bit perceptual image hashing. |
| **Database & Storage** | Relational DB (MySQL / PostgreSQL / SQLite) + Local/Cloud Disk | Relational persistence with transactional locking (`DB::transaction`) for inventory and aid distribution ledgers. |

---

### 2.2 System Architecture Diagram

```
                       ┌─────────────────────────────────────────┐
                       │       Athar Hybrid Operations Hub       │
                       └───────────────────┬─────────────────────┘
                                           │
         ┌─────────────────────────────────┴─────────────────────────────────┐
         ▼                                                                   ▼
┌─────────────────────────────────┐                       ┌─────────────────────────────────┐
│     Multi-Persona Flutter App   │                       │    Web Command Operations Center│
│  (Citizen / Donor / Volunteer)  │                       │  (Admins, Dispatchers, Auditors)│
├─────────────────────────────────┤                       ├─────────────────────────────────┤
│ • 3-Step Citizen Aid Wizard     │                       │ • Leaflet.js Real-time GIS Map  │
│ • 6-Stage Live Case Tracker     │                       │ • AI Triage Board (Tier 1-4)    │
│ • Impact Reels & Social Feed    │                       │ • AI Diagnostics & Fraud Lab    │
│ • Sham Cash & Direct Donations  │                       │ • NFC Provisioning & 3D Sim     │
│ • NFC Field Aid Tap & Offline Q │                       │ • Warehouse Logistics & Stock   │
│ • Field Survey & Emergency Join │                       │ • 18 Enterprise Admin Modules   │
│ • Volunteer Digital Passport    │                       │ • Printable Annual Impact Report│
└────────────────┬────────────────┘                       └────────────────┬────────────────┘
                 │                                                         │
                 └─────────────────────────┬───────────────────────────────┘
                                           │ HTTPS / REST API / Bearer Token
                                           ▼
                       ┌─────────────────────────────────────────┐
                       │     Laravel Production Core & AI Engine │
                       ├─────────────────────────────────────────┤
                       │ • Anti-Double Dipping Distribution Lock │
                       │ • DocumentAuditorService (OCR + Math)   │
                       │ • ShelterVisualAnalyzerService          │
                       │ • ArabicTriageClassifierService (NLP)   │
                       │ • ImageFingerprintService (64-bit dHash)│
                       │ • VolunteerMatchmakerService (Geo+Skill)│
                       └─────────────────────────────────────────┘
```

---

### 2.3 Detailed Breakdown of Technical Modules Built

#### Phase 1: Core Infrastructure, Auth, & Multi-Role Foundation
* **Custom Token Authentication**: Stateless API authentication via `api.token` middleware storing SHA-256 hashed tokens in `users.api_token`, supporting distinct roles (`user`, `volunteer`, `organization`, `admin`).
* **Clean Architecture in Flutter**: Feature-first modular structure (`lib/features/{auth,user,volunteer,organization,notifications,admin}`) separated into **Domain** (Entities, Repository Interfaces, UseCases), **Data** (Models, Repository Implementations, Remote/Local DataSources), and **Presentation** (BLoC state management, Screens, Widgets).
* **Centralized Network Client**: [`http_client.dart`](file:///d:/Senior%20Project/lib/core/network/http_client.dart) handles bearer token injection, multipart file uploads, timeout management, and structured error mapping.

#### Phase 2: Citizen Aid Experience, Social Engagement & Local Payment Gateways
* **3-Step Request Aid Wizard** ([`request_aid_wizard_screen.dart`](file:///d:/Senior%20Project/lib/features/user/presentation/screens/request_aid_wizard_screen.dart)): Interactive stepper for category selection, Arabic description, urgent flag, target amount, governorate selection, and supporting document/image uploads.
* **6-Stage Case Lifecycle Tracker** ([`case_tracking_screen.dart`](file:///d:/Senior%20Project/lib/features/user/presentation/screens/case_tracking_screen.dart)): Real-time visual progress tracker from submission to final delivery.
* **Social Aid Feed & Impact Stories Reel** ([`home_screen.dart`](file:///d:/Senior%20Project/lib/features/user/presentation/screens/home_screen.dart), [`field_reels_screen.dart`](file:///d:/Senior%20Project/lib/features/user/presentation/screens/field_reels_screen.dart), [`social_case_post_card.dart`](file:///d:/Senior%20Project/lib/features/user/presentation/widgets/social_case_post_card.dart)): Instagram/TikTok-style vertical field reels, case likes (`/cases/{id}/like`), interactive comments bottom sheet (`/cases/{id}/comments`), and favorites.
* **Syrian Payment Gateways Integration** ([`sham_cash_donation_sheet.dart`](file:///d:/Senior%20Project/lib/features/user/presentation/widgets/sham_cash_donation_sheet.dart)): Supports **Sham Cash (شام كاش)**, **Syriatel Cash**, **MTN Cash**, and Bank Transfers with transaction receipt numbers and instant case funding bar updates (`/cases/{id}/donate`).

#### Phase 3: Volunteer Field Operations, NFC Smart Cards, & Digital Passport
* **Beneficiary & NFC Card Provisioning** ([`BeneficiaryController.php`](file:///d:/Senior%20Project/backend/app/Http/Controllers/Api/BeneficiaryController.php)): Manages beneficiary households (`beneficiaries` table), national IDs, family members, vulnerability scores, and pairs physical NFC UIDs (`nfc_cards` table, e.g., `NFC-SYR-DAM-0001`).
* **Anti-Double Dipping Distribution Engine** ([`DistributionController.php`](file:///d:/Senior%20Project/backend/app/Http/Controllers/Api/DistributionController.php), [`nfc_aid_scanner_screen.dart`](file:///d:/Senior%20Project/lib/features/volunteer/presentation/screens/nfc_aid_scanner_screen.dart)):
  * Verifies the scanned NFC UID or National ID against the active campaign (`aid_campaigns`).
  * Checks `aid_distributions` for any existing record matching `(campaign_id, beneficiary_id)`. If found, returns `HTTP 409 Conflict` with detailed timestamp and distributor info to block double-dipping.
  * Supports **Offline Batch Sync** (`/distributions/batch-sync`) so field volunteers can scan cards without internet and sync queued transactions later.
* **Field Living Condition Surveys** ([`FieldAssessmentController.php`](file:///d:/Senior%20Project/backend/app/Http/Controllers/Api/FieldAssessmentController.php), [`field_assessment_screen.dart`](file:///d:/Senior%20Project/lib/features/volunteer/presentation/screens/field_assessment_screen.dart)): Captures home inspection data (housing type, roof/wall integrity, income level, special needs, recommended tier, GPS coordinates) and computes an objective `vulnerability_score` (0–100).
* **Emergency Missions & Rapid Response** ([`EmergencyMissionController.php`](file:///d:/Senior%20Project/backend/app/Http/Controllers/Api/EmergencyMissionController.php), [`emergency_missions_screen.dart`](file:///d:/Senior%20Project/lib/features/volunteer/presentation/screens/emergency_missions_screen.dart)): Enables volunteers to join urgent field missions and check in via GPS coordinates.
* **Volunteer Digital Passport & Public QR Verification** ([`VolunteerPassportController.php`](file:///d:/Senior%20Project/backend/app/Http/Controllers/Api/VolunteerPassportController.php), [`volunteer_passport_screen.dart`](file:///d:/Senior%20Project/lib/features/volunteer/presentation/screens/volunteer_passport_screen.dart)): Tracks verified hours (`volunteer_logs`), calculates dynamic ranks, awards badges, and provides a public verification URL (`/volunteer/passport/verify/{id}`) for printed QR certificates.

#### Phase 4: Applied AI Intelligence & Anti-Fraud Engine
Located in `backend/app/Services/Ai/` and exposed via [`AiIntelligenceController.php`](file:///d:/Senior%20Project/backend/app/Http/Controllers/Api/AiIntelligenceController.php):
1. **Medical Invoice & Document Auditor** ([`DocumentAuditorService.php`](file:///d:/Senior%20Project/backend/app/Services/Ai/DocumentAuditorService.php)):
   * Uses **Google Gemini 1.5 Flash Vision** (with deterministic local heuristic fallback when offline/no API key) to extract facility name, diagnosis, line-item costs, and stated total.
   * Performs programmatic arithmetic verification ($\sum \text{items} == \text{stated total}$) and flags tampered bills.
2. **Shelter & Damage Visual Analyzer** ([`ShelterVisualAnalyzerService.php`](file:///d:/Senior%20Project/backend/app/Services/Ai/ShelterVisualAnalyzerService.php)):
   * Evaluates structural damage in uploaded shelter/tent photos, outputting `structural_integrity_score`, detected hazards, and `urgency_classification`.
3. **Arabic NLP Triage Classifier** ([`ArabicTriageClassifierService.php`](file:///d:/Senior%20Project/backend/app/Services/Ai/ArabicTriageClassifierService.php)):
   * Analyzes Arabic case titles and descriptions using weighted morphological keyword dictionaries (Critical Medical, Moderate Medical, Shelter/Disaster, Vulnerable Demographics) combined with household context to calculate an **Urgency Index (0–100)** and classify into **Tier 1 (90–100)** through **Tier 4 (<50)**.
4. **64-Bit Perceptual Image Fingerprinting (`dHash`)** ([`ImageFingerprintService.php`](file:///d:/Senior%20Project/backend/app/Services/Ai/ImageFingerprintService.php)):
   * Unlike cryptographic hashes (`MD5`/`SHA-256`) that break if a single pixel changes, our custom `dHash` resizes images to $9 \times 8$ grayscale, compares adjacent horizontal pixel intensities, and produces a 64-bit hexadecimal perceptual hash stored in `case_image_fingerprints`.
   * Computes **Hamming Distance** across existing case images; if the bit difference is $\le 5$ bits ($\ge 92\%$ visual similarity), it flags the upload as a reused/fraudulent image.
5. **Smart Volunteer Matchmaker** ([`VolunteerMatchmakerService.php`](file:///d:/Senior%20Project/backend/app/Services/Ai/VolunteerMatchmakerService.php)):
   * Ranks available volunteers for emergency missions using the **Haversine geospatial distance formula**, skill overlap, vehicle availability, and past field experience.

#### Phase 5: Web Command Operations Center (`/dashboard/*`)
Built in [`AdminDashboardController.php`](file:///d:/Senior%20Project/backend/app/Http/Controllers/Web/AdminDashboardController.php) and `backend/resources/views/dashboard/`, featuring **18 full-featured enterprise modules**:
1. **Main Operations Command Center** (`/dashboard`): Live KPIs, verified NFC distribution stream, and critical AI case queue.
2. **Interactive Live GIS Operations Map** (`/dashboard/gis-map`): Multi-layer Leaflet.js map with red pins (aid cases), blue pins (field volunteers), and green pins (warehouses), governorate fly-to filtering, and instant warehouse creation modal with pre-mapped Syrian districts.
3. **Aid Campaigns Manager** (`/dashboard/campaigns`): Create, edit, and toggle active relief campaigns.
4. **AI Triage & Case Review Board** (`/dashboard/cases`): Filter cases by AI urgency, inspect AI audit reports, assign field volunteers, and approve/reject cases.
5. **AI Intelligence & Fraud Diagnostics Lab** (`/dashboard/ai-intelligence`): Interactive simulator to test Arabic NLP Triage and view perceptual `dHash` fraud logs.
6. **Field Surveys & Assessments Review** (`/dashboard/assessments`): Review volunteer home inspections and vulnerability scores.
7. **Emergency Missions Dispatch** (`/dashboard/missions`): Dispatch rapid response missions and track volunteer check-ins.
8. **Beneficiaries & NFC Card Hub** (`/dashboard/beneficiaries`): Register families and pair encrypted NFC UIDs.
9. **NFC Distributions Audit Ledger & 3D Hardware Simulator** (`/dashboard/distributions`): Global 3D interactive NFC terminal simulator (`nfc-3d-simulator.blade.php`) allowing live demonstration of valid NFC taps vs. blocked double-dipping attempts directly in the browser.
10. **Warehouse Logistics & Inventory** (`/dashboard/inventory`): Manage warehouses, stock items, and stock-in/stock-out transactions.
11. **Volunteer Roster, Opportunities & Certification** (`/dashboard/volunteers`): Manage volunteer recruitment opportunities, log verified hours, and award badges.
12. **NGO Partners & Accreditation** (`/dashboard/organizations`): Approve or reject partner charity registration requests.
13. **System Users & Role Governance** (`/dashboard/users`): Manage user accounts and role assignments.
14. **Financial Donations & Transparency Ledger** (`/dashboard/donations`): Audit Sham Cash and transfer donations with approval workflows.
15. **Executive Field Analytics** (`/dashboard/analytics`): Visual breakdowns of aid coverage and campaign performance.
16. **Emergency Broadcast & Notifications** (`/dashboard/notifications`): Send targeted or broadcast alerts to users and volunteers.
17. **Platform Settings & System Health** (`/dashboard/settings`): Manage categories and Syrian governorates.
18. **Printable Annual Impact Report** (`/dashboard/reports/annual-impact`): Official PDF-ready transparency and audit report.

---

### 2.4 Database Schema Summary (21 Principal Tables)

* `users`: Multi-role accounts (`user`, `volunteer`, `organization`, `admin`), skills, vehicle type, volunteer hours, GPS coordinates, and hashed `api_token`.
* `cases` (`AidCase`): Aid requests with `status`, `priority`, `target_amount`, `collected_amount`, `ai_urgency_index`, `ai_triage_tier`, `ai_audit_summary`, `category_id`, `governorate_id`, `organization_id`.
* `case_images`, `case_attachments`, `case_comments`, `case_donations`, `favorites`: Supporting case media, social engagement, and donor transactions.
* `case_image_fingerprints`: Stores 64-bit `dhash` perceptual hashes and `sha256_hash` for anti-fraud duplicate detection.
* `beneficiaries` & `nfc_cards`: Registered households, national IDs, vulnerability scores, and paired NFC card UIDs (`card_uid`, `security_hash`, `status`).
* `aid_campaigns` & `aid_distributions`: Relief campaigns and the immutable NFC distribution ledger enforcing zero double-dipping.
* `field_assessments`: Home visit inspection surveys submitted by field volunteers.
* `emergency_missions` & `mission_volunteers`: Rapid response dispatches and volunteer GPS check-ins.
* `warehouses`, `inventory_items`, `inventory_transactions`: Geospatial distribution hubs and stock ledger.
* `volunteer_opportunities`, `volunteer_applications`, `volunteer_logs`: Volunteer recruitment and verified service hours for the Digital Passport.
* `organization_requests`, `categories`, `governorates`, `notifications`: Platform governance and catalog tables.

---

### 2.5 How to Run the Project Locally

#### 1. Backend & Web Command Center (Laravel)
```bash
cd backend
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate --seed
php artisan storage:link
php artisan serve --host=0.0.0.0 --port=8000
```
* **Web Command Center URL**: `http://127.0.0.1:8000/dashboard`
* **Live GIS Map URL**: `http://127.0.0.1:8000/dashboard/gis-map`
* **REST API Base URL**: `http://127.0.0.1:8000/api`

#### 2. Mobile Application (Flutter)
```bash
flutter pub get
flutter run
```
*(Note: Configure the API base URL in [`lib/shared/constants/app_constants.dart`](file:///d:/Senior%20Project/lib/shared/constants/app_constants.dart) — use `http://10.0.2.2:8000` for Android Emulator or `http://127.0.0.1:8000` for Windows/Web/iOS Simulator).*

#### 3. Running Automated Tests
* **Backend Tests (PHPUnit)**:
  ```bash
  cd backend
  php artisan test
  ```
* **Frontend Widget & Integration Tests (Flutter)**:
  ```bash
  flutter test
  ```
  Includes dedicated test suites for:
  * [`test/phase_two_citizen_features_test.dart`](file:///d:/Senior%20Project/test/phase_two_citizen_features_test.dart)
  * [`test/phase_three_volunteer_field_test.dart`](file:///d:/Senior%20Project/test/phase_three_volunteer_field_test.dart)
  * [`test/phase_four_ai_features_test.dart`](file:///d:/Senior%20Project/test/phase_four_ai_features_test.dart)

