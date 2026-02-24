# Phase 3: User Module - Implementation Summary

## Overview
This phase implements the User Module with four main screens: Home Screen, Governorates Screen, Case Details Screen, and Profile Screen. Each screen includes its respective BLoC following Clean Architecture principles.

---

## What Was Implemented

### 1. Domain Layer

#### Entities Created:
- **Category** (`lib/features/user/domain/entities/category.dart`)
  - id, name, icon, casesCount

- **Case** (`lib/features/user/domain/entities/case.dart`)
  - id, title, description, governorate, category
  - categoryId, governorateId, status, priority
  - thumbnail, images, views, createdAt
  - isFavorited, organizationName, attachments

- **CaseAttachment** (nested in case.dart)
  - id, name, url, type, size

- **Governorate** (`lib/features/user/domain/entities/governorate.dart`)
  - id, name, code, casesCount

#### Repository Interface:
- **UserRepository** (`lib/features/user/domain/repositories/user_repository.dart`)
  - getCategories()
  - getLatestCases()
  - getCasesByGovernorate()
  - getCaseDetails()
  - incrementCaseViews()
  - getGovernorates()
  - getFavorites()
  - addToFavorites()
  - removeFromFavorites()
  - updateProfile()
  - changePassword()

### 2. Data Layer

#### Models Created:
- **CategoryModel** (`lib/features/user/data/models/category_model.dart`)
- **CaseModel** & **CaseAttachmentModel** (`lib/features/user/data/models/case_model.dart`)
- **GovernorateModel** (`lib/features/user/data/models/governorate_model.dart`)

#### Repository Implementation:
- **UserRepositoryImpl** (`lib/features/user/data/repositories/user_repository_impl.dart`)
  - All API calls using DioClient
  - Error handling with Failure types

### 3. Presentation Layer - BLoCs

#### HomeBloc
**Location:** `lib/features/user/presentation/bloc/home_bloc/`

**Events:**
- FetchHomeDataEvent - Load categories and latest cases
- FetchMoreCasesEvent - Pagination for cases
- RefreshHomeDataEvent - Pull-to-refresh

**States:**
- HomeInitial, HomeLoading, HomeLoaded, HomeError
- CasesLoadingMore - Shows loading while fetching more cases

**Features:**
- Fetches categories and latest cases in parallel
- Pagination support with hasMoreCases flag
- Pull-to-refresh functionality

#### GovernorateBloc
**Location:** `lib/features/user/presentation/bloc/governorate_bloc/`

**Events:**
- FetchGovernoratesEvent - Load all governorates
- SelectGovernorateEvent - Select a governorate and load its cases
- FetchMoreCasesEvent - Pagination for cases
- RefreshGovernorateDataEvent

**States:**
- GovernorateInitial, GovernorateLoading, GovernorateLoaded, GovernorateError
- CasesLoadingMore

**Features:**
- Category-based filtering (optional categoryId parameter)
- Horizontal governorate chips with case count badges
- Cases list for selected governorate

#### CaseDetailsBloc
**Location:** `lib/features/user/presentation/bloc/case_details_bloc/`

**Events:**
- FetchCaseDetailsEvent - Load case details
- ToggleFavoriteEvent - Add/remove from favorites
- ShareCaseEvent - Share case
- DownloadAttachmentEvent - Download file attachments

**States:**
- CaseDetailsInitial, CaseDetailsLoading, CaseDetailsLoaded
- CaseDetailsError, ToggleFavoriteSuccess

**Features:**
- Auto-increments view counter on load
- Optimistic update for favorite toggle

#### ProfileBloc
**Location:** `lib/features/user/presentation/bloc/profile_bloc/`

**Events:**
- FetchProfileEvent - Load user data
- UpdateProfileEvent - Update name/phone
- ChangePasswordEvent - Change password
- LogoutEvent - Clear token and logout

**States:**
- ProfileInitial, ProfileLoading, ProfileLoaded, ProfileError
- ProfileUpdateSuccess, PasswordChangeSuccess, LogoutSuccess

### 4. Presentation Layer - Screens

#### Home Screen
**Location:** `lib/features/user/presentation/screens/home_screen.dart`

**Features:**
- **Categories horizontal list**: Icon + name + case count
- **Latest cases vertical list**: Card with thumbnail, priority badge, title, location
- **Pull to refresh**: RefreshIndicator widget
- **Pagination**: "تحميل المزيد" button at bottom
- **Navigation**: Links to Profile, Notifications, Governorates, Case Details

**UI Components:**
- `_CategoryCard` - Shows category with icon and count
- `_CaseCard` - Shows case with image, priority, views, location

#### Governorates Screen
**Location:** `lib/features/user/presentation/screens/governorates_screen.dart`

**Features:**
- **Horizontal governorate chips**: Selectable with case count
- **Filter by category**: Accepts optional categoryId parameter
- **Cases list**: Shows cases for selected governorate
- **Infinite scrolling**: Load more button

**UI Components:**
- `_GovernorateChip` - Shows governorate name and case count
- `_CaseCard` - Reusable case card component

#### Case Details Screen
**Location:** `lib/features/user/presentation/screens/case_details_screen.dart`

**Features:**
- **Image slider**: PageView with dot indicators
- **Expandable description**: "عرض المزيد/أقل" toggle
- **Attachments download**: List of attachments with download button
- **Share button**: In app bar
- **Save to favorites**: Heart icon toggle
- **Increment view counter**: Auto-increment on view
- **Status badge**: Colored status indicator

**UI Components:**
- `_ImageSlider` - Swipeable image gallery with dots
- `_ExpandableDescription` - Text with show more/less
- `_AttachmentTile` - File with icon, name, size, download button

#### Profile Screen
**Location:** `lib/features/user/presentation/screens/profile_screen.dart`

**Features:**
- **User data display**: Avatar, name, email, role badge
- **Update profile**: Dialog for editing name and phone
- **Change password**: Dialog with current/new/confirm fields
- **Logout**: Confirmation dialog, clears token, navigates to login
- **Favorites navigation**: Link to favorites list

**UI Components:**
- `_ProfileContent` - Main profile UI
- `_MenuItem` - Reusable menu list tile
- Dialogs: Edit Profile, Change Password, Logout Confirmation, About

### 5. Dependency Injection

**Updated:** `lib/services/locator.dart`

**Added Registrations:**
```dart
// Repositories
locator.registerLazySingleton<UserRepository>(
  () => UserRepositoryImpl(dioClient: locator<DioClient>()),
);

// BLoCs
locator.registerFactory<HomeBloc>(
  () => HomeBloc(userRepository: locator<UserRepository>()),
);

locator.registerFactory<GovernorateBloc>(
  () => GovernorateBloc(userRepository: locator<UserRepository>()),
);

locator.registerFactory<CaseDetailsBloc>(
  () => CaseDetailsBloc(userRepository: locator<UserRepository>()),
);

locator.registerFactory<ProfileBloc>(
  () => ProfileBloc(
    userRepository: locator<UserRepository>(),
    authRepository: locator<AuthRepository>(),
    localStorage: locator<LocalStorageService>(),
  ),
);
```

---

## API Endpoints Used

```
GET  /categories              - Get all categories
GET  /cases/latest            - Get latest cases (paginated)
GET  /cases                   - Get cases by governorate
GET  /cases/:id               - Get case details
POST /cases/:id/view         - Increment view counter
GET  /governorates           - Get all governorates
GET  /favorites              - Get user's favorites
POST /favorites             - Add to favorites
DELETE /favorites/:id        - Remove from favorites
PUT  /profile               - Update profile
PUT  /profile/password      - Change password
```

---

## Testing Instructions

### 1. Home Screen Test
```bash
# Navigate from Splash/Login to Home
# Expected: Shows categories list and latest cases
# Test pull-to-refresh: Pull down to reload
# Test pagination: Click "تحميل المزيد" for more cases
# Test navigation: Click category → Governorates, Click case → Case Details
```

### 2. Governorates Screen Test
```bash
# Navigate to Governorates from Home or other screens
# Expected: Shows list of governorates as horizontal chips
# Test: Click a governorate → Shows cases for that governorate
# Test with category filter: Navigate with categoryId parameter
# Test pagination: Load more cases
```

### 3. Case Details Screen Test
```bash
# Navigate to Case Details (click any case card)
# Expected: Shows image slider, title, description, attachments
# Test image slider: Swipe left/right if multiple images
# Test expandable description: Click "عرض المزيد/أقل"
# Test favorite: Click heart icon (toggle on/off)
# Test share: Click share button
# Test status badge: Shows colored status indicator
```

### 4. Profile Screen Test
```bash
# Navigate to Profile from Home or other screens
# Expected: Shows user avatar, name, email, role
# Test update profile: Click "تعديل الملف الشخصي" → Edit → Save
# Test change password: Click "تغيير كلمة المرور" → Enter passwords → Change
# Test logout: Click "تسجيل الخروج" → Confirm → Returns to Login
# Test favorites navigation: Click "المفضلات"
```

---

## File Structure Created/Modified

```
lib/
├── features/
│   └── user/
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── category.dart
│       │   │   ├── case.dart
│       │   │   └── governorate.dart
│       │   └── repositories/
│       │       └── user_repository.dart
│       ├── data/
│       │   ├── models/
│       │   │   ├── category_model.dart
│       │   │   ├── case_model.dart
│       │   │   └── governorate_model.dart
│       │   └── repositories/
│       │       └── user_repository_impl.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── home_bloc/
│           │   │   ├── home_bloc.dart
│           │   │   ├── home_event.dart
│           │   │   └── home_state.dart
│           │   ├── governorate_bloc/
│           │   │   ├── governorate_bloc.dart
│           │   │   ├── governorate_event.dart
│           │   │   └── governorate_state.dart
│           │   ├── case_details_bloc/
│           │   │   ├── case_details_bloc.dart
│           │   │   ├── case_details_event.dart
│           │   │   └── case_details_state.dart
│           │   └── profile_bloc/
│           │       ├── profile_bloc.dart
│           │       ├── profile_event.dart
│           │       └── profile_state.dart
│           └── screens/
│               ├── home_screen.dart (UPDATED)
│               ├── governorates_screen.dart (UPDATED)
│               ├── case_details_screen.dart (UPDATED)
│               └── profile_screen.dart (UPDATED)
├── services/
│   └── locator.dart (UPDATED)
```

---

## Next Phase (Phase 4)

Phase 4 will implement the **Organization Module** with:
1. Organization Cases List (with status badges and rejection reasons)
2. Create Case Screen (complex form with multi-image picker, file upload)
3. Organization Profile

---

## Status: ✅ COMPLETED

Phase 3 is now complete and ready for testing. All User Module features have been implemented following Clean Architecture and BLoC pattern.
