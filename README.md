# Aid Connect — Senior Project

Version: main

## Overview

Aid Connect is a cross-platform mobile and web application that connects people in need with organizations and volunteers who can help. The project includes:

- A Laravel-based backend API (PHP) that manages users, cases (help requests), organizations, volunteer opportunities, favorites, notifications, and file attachments.
- A Flutter frontend (mobile and web) that consumes the API, handles authentication, displays lists and details of cases, and provides role-based features for normal users, volunteers, and organizations.

This README explains the system both technically and non-technically, documents the repository layout, how to run the project locally, key APIs, and other notes useful for developers and stakeholders.

## Audience

This document is written for two audiences:

- Technical readers (developers, devops): architecture, code layout, run instructions, and API contract.
- Non-technical readers (project managers, stakeholders): high-level flows, features and intended user interactions.

## Key features

- Authentication (register / login) with token-based API access.
- Browsing and searching aid cases (list + detail + pagination + filters).
- Organizations and volunteers can create, update, and delete cases.
- File uploads for case images and attachments (handled by the backend file storage).
- Favorites: users can add/remove cases to their favorites list.
- Volunteer applications: volunteers can apply to opportunities and manage their applications.
- Notifications: server-side notifications with read/unread and counts.
- Catalog services: categories and governorates for filtering and groupings.

## Repository layout

Top-level layout (most important paths):

- `backend/` — Laravel API project
  - `app/Http/Controllers/Api/` — API controllers
  - `app/Models/` — Eloquent models
  - `database/migrations/` — DB schema migrations
  - `routes/api.php` — API routes
  - `public/` — public entry and storage link
- `lib/` — Flutter client application
  - `core/network/` — HTTP client wrapper and network utilities
  - `features/` — feature folders (auth, user, organization, volunteer, notifications)
  - `services/` — local storage service, DI locator, notification services
  - `main.dart` — app entrypoint
- Platform folders: `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`

Other artifacts: `pubspec.yaml`, `composer.json`, migration files, and test directories.

## High-level architecture

1. Mobile App (Flutter)
   - UI for end users (role-aware: user, volunteer, organization).
   - Calls backend API endpoints using `HttpClient` wrapper.
   - Stores auth token and user info locally.

2. API Server (Laravel)
   - Stateless REST API.
   - Authentication via bearer token stored hashed in the `users` table.
   - Business logic, validation, persistence and file uploads.

3. Relational Database
   - Primary data store (MySQL/Postgres/SQLite as configured).

4. File Storage
   - Images and attachments stored on configured filesystem (local disk or cloud). Backend returns public URLs for images and attachments.

## Detailed components

### Backend (Laravel)

Technology: PHP 8+, Laravel.

Responsibilities:

- Auth: login, register, logout, profile, change password. Tokens are created and hashed in `users.api_token` and the plain token is returned to the client.
- Cases: list, detail, create/update/delete, views counter, images & attachments.
- Favorites: add/remove/list favorites per user.
- Notifications: create, list, stats, mark as read, mark all read, delete.
- Volunteer features: volunteer opportunities, applications (apply/cancel), volunteer dashboards.
- Organization: submit organization request, manage organization cases, organization dashboard and profile.

Key backend locations:

- `backend/routes/api.php` — API endpoints and middleware grouping.
- `backend/app/Http/Controllers/Api/` — controllers implementing endpoints (AuthController, CaseController, OrganizationController, VolunteerController, FavoriteController, NotificationController, CategoryController, GovernorateController, etc.).
- `backend/app/Models/` — Eloquent models for domain entities.
- `backend/database/migrations/` — database schema files.

Authorization & middleware:

- `api.token` middleware protects endpoints requiring authentication.
- Controllers verify `role` where necessary (e.g., only `organization` role can access `/organization/*` routes).

### Frontend (Flutter)

Technology: Flutter (Dart), BLoC or provider patterns in places.

Responsibilities:

- UI & navigation for users, volunteers and organizations.
- Repositories call `HttpClient` to access the API. `HttpClient` appends the bearer token when present and maps responses into typed models or Failure objects.

Key frontend files:

- `lib/core/network/http_client.dart` — central HTTP wrapper handling headers, JSON encode/decode, multipart uploads, and error mapping.
- `lib/features/*/data/repositories/*_repository_impl.dart` — actual API calls for features.
- `lib/features/*/presentation/screens/*` — UI screens.
- `lib/services/local_storage_service.dart` — token and user data storage.

## Data model summary (principal tables)

- users: id, name, email, phone, password, role, avatar, bio, skills (json), is_active, api_token (hashed), address, registration_number, timestamps
- cases: id, title, description, status, priority, category_id, governorate_id, organization_id, thumbnail, views, rejection_reason, timestamps
- case_images: id, case_id, url, order
- case_attachments: id, case_id, name, url, type, size
- categories: id, name, icon
- governorates: id, name, code
- favorites: id, user_id, case_id
- notifications: id, user_id, title, body, type, is_read, related_case_id, related_entity_name, rejection_reason
- volunteer_opportunities: id, title, description, category, governorate, volunteers_needed, volunteers_applied, is_urgent, organization_id
- volunteer_applications: id, user_id, opportunity_id, case_id, status, case_title, organization_name, category
- organization_requests: id, name, email, phone, address, description, registration_number, status, rejection_reason

## Primary API endpoints (summary)

Public (no token required):

- POST /auth/login — login (accepts email or name depending on role, password, role)
- POST /auth/register — register new normal user
- POST /organization/request — submit organization registration request
- GET /categories — list categories
- GET /governorates — list governorates
- GET /cases — list cases
- GET /cases/{id} — case details

Authenticated (requires `api.token` middleware):

- POST /auth/logout
- GET /auth/me
- PUT /auth/profile
- PUT /auth/password
- POST /cases/{id}/views
- GET /favorites, POST /favorites, DELETE /favorites/{caseId}
- GET /notifications, GET /notifications/stats
- POST /notifications/{id}/read, POST /notifications/read-all, DELETE /notifications/{id}
- Organization routes: GET/POST/PUT/DELETE /organization/cases, GET /organization/dashboard, GET/PUT /organization/profile
- Volunteer routes: GET /volunteer/cases, GET /volunteer/cases/{id}, POST /volunteer/apply/{caseId}, GET /volunteer/applications, DELETE /volunteer/applications/{id}, GET /volunteer/dashboard, GET /volunteer/feed, GET/POST/PUT/DELETE /volunteer/my-cases

## Error handling and responses

The API returns JSON responses with consistent structure via a base ApiController. Successful responses include data and message. The Flutter client maps HTTP status codes and response payloads into typed Failure classes to show appropriate UI errors.

## Running the project locally

### Backend (Laravel)

Prerequisites: PHP 8+, Composer, a relational database (MySQL/Postgres/SQLite), and optional storage configuration (local or cloud).

From `backend/`:

1. Copy environment file: `cp .env.example .env` (or copy on Windows).
2. Configure DB_* and APP_URL in `.env`.
3. Install PHP deps: `composer install`.
4. Generate app key: `php artisan key:generate`.
5. Run migrations: `php artisan migrate`.
6. Create storage symlink for public files: `php artisan storage:link`.
7. Start dev server: `php artisan serve --host=0.0.0.0 --port=8000`.

Notes:

- For local mobile testing on Android emulator, use `10.0.2.2` to reach the host machine.
- Configure `FILESYSTEM_DRIVER` in `.env` to use cloud storage (S3) in production.

### Frontend (Flutter)

Prerequisites: Flutter SDK, platform tooling for Android/iOS/web as needed.

From repository root:

1. Fetch packages: `flutter pub get`.
2. Configure API base URL: edit `lib/shared/constants/app_constants.dart` (set `baseUrl` to backend address, e.g. `http://10.0.2.2:8000`).
3. Run app: `flutter run`.

## Testing

### Backend

- PHPUnit tests (if present) live under `backend/tests`. Run: `./vendor/bin/phpunit` inside `backend/`.

### Frontend

- Flutter tests: `flutter test` from project root.

## Deployment notes

- Backend: deploy as a normal Laravel application (Docker, Forge, Vapor, or traditional host). Ensure environment variables are secure, run migrations on deployment, and configure a persistent file store or cloud storage.
- Frontend: build Flutter apps for target platforms. Configure production `baseUrl` and ensure HTTPS.

## Security considerations

- Tokens: the current implementation stores a hashed static token on the user record (`api_token`). For production prefer short-lived JWTs with refresh tokens or Laravel Sanctum/Passport for better token lifecycle and revocation.
- File uploads: controllers validate file types and sizes; follow principle of least privilege when serving stored files.
- Authorization: controllers check `role` for sensitive actions but consider implementing Laravel Policies for more robust checks.

## Non-technical data flow (summary)

1. User registers or logs in. The app stores a bearer token locally.
2. User browses cases; the app calls `/cases` and `/cases/{id}` and displays images using URLs returned by the server.
3. Organizations/volunteers create cases with images; backend stores images and returns URLs.
4. Volunteers apply to opportunities; backend records applications and notifications are created for organizations.

## Contributing

Contributions are welcome. Suggested workflow:

1. Fork the repo.
2. Create a feature branch.
3. Run tests and linters locally.
4. Open a Pull Request with a clear description.

## License & credits

This project was created as a Senior Project. Inspect `composer.json` and `pubspec.yaml` for third-party licenses. Add a `LICENSE` file if you wish to declare a license.

## Contact & next steps

If you want diagrams, a Docker-based dev environment, CI/CD workflows, or more detailed API docs (OpenAPI/Swagger), tell me which artifact to generate next and I'll add it.

---

End of README
