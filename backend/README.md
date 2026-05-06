# Aid Connect - Laravel Backend

Laravel 12 API backend for the Aid Connect Flutter application.

## Requirements

- PHP >= 8.2
- Composer
- PostgreSQL >= 14

## Setup

### 1. Install dependencies

```bash
cd backend
composer install
composer update laravel/sanctum
```

### 2. Configure environment

The `.env` file is pre-configured for PostgreSQL. Update these values if needed:

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=aid_connect
DB_USERNAME=postgres
DB_PASSWORD=postgres
```

Create the PostgreSQL database:

```bash
psql -U postgres -c "CREATE DATABASE aid_connect;"
```

### 3. Run migrations and seeders

```bash
php artisan migrate --seed
```

### 4. Generate application key (if not already set)

```bash
php artisan key:generate
```

### 5. Start the development server

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

The API will be available at `http://localhost:8000/api`.

## API Endpoints

### Authentication
- `POST /api/auth/login` - Login
- `POST /api/auth/register` - Register
- `POST /api/auth/logout` - Logout (auth required)
- `GET /api/auth/me` - Current user (auth required)
- `PUT /api/auth/profile` - Update profile (auth required)
- `PUT /api/auth/password` - Change password (auth required)

### Public Data
- `GET /api/categories` - List categories
- `GET /api/governorates` - List governorates

### Cases
- `GET /api/cases` - List approved cases (with pagination, filter by governorate_id/category_id)
- `GET /api/cases/{id}` - Case details
- `POST /api/cases/{id}/views` - Increment views

### Favorites
- `GET /api/favorites` - List favorites
- `POST /api/favorites` - Add to favorites
- `DELETE /api/favorites/{caseId}` - Remove from favorites

### Notifications
- `GET /api/notifications` - List notifications
- `GET /api/notifications/stats` - Notification stats
- `POST /api/notifications/{id}/read` - Mark as read
- `POST /api/notifications/read-all` - Mark all as read
- `DELETE /api/notifications/{id}` - Delete notification

### Organization
- `GET /api/organization/cases` - My cases
- `POST /api/organization/cases` - Create case
- `GET /api/organization/cases/{id}` - Case details
- `PUT /api/organization/cases/{id}` - Update case
- `DELETE /api/organization/cases/{id}` - Delete case
- `POST /api/organization/request` - Submit organization request

### Volunteer
- `GET /api/volunteer/cases` - Available volunteer opportunities
- `GET /api/volunteer/cases/{id}` - Opportunity details
- `POST /api/volunteer/apply/{caseId}` - Apply to volunteer
- `GET /api/volunteer/applications` - My applications
- `DELETE /api/volunteer/applications/{id}` - Cancel application
- `GET /api/volunteer/profile` - Volunteer profile
- `PUT /api/volunteer/profile` - Update volunteer profile

### User
- `GET /api/user` - Get user
- `PUT /api/user` - Update user

## Default Demo Accounts

After running seeders, these accounts are available:

| Role         | Email                  | Password |
|--------------|------------------------|----------|
| User         | user@example.com       | password |
| Organization | org@example.com        | password |
| Volunteer    | volunteer@example.com  | password |

## Response Format

All API responses follow this structure:

```json
{
  "success": true,
  "message": "Success",
  "data": { ... },
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 10,
    "total": 50
  }
}
```

## Authentication

This API uses Laravel Sanctum for token-based authentication. Include the token in the `Authorization` header:

```
Authorization: Bearer <token>
```
