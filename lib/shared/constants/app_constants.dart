class AppConstants {
  // API
  static const String baseUrl = 'http://192.168.1.14:8000/api';
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  
  // Timeouts
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  
  // Cache
  static const int cacheValidityDays = 7;
  
  // File Upload
  static const int maxImageSizeMB = 5;
  static const int maxFileSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedFileTypes = ['pdf', 'doc', 'docx'];
}

class UserRoles {
  static const String admin = 'admin';
  static const String user = 'user';
  static const String organization = 'organization';
  static const String volunteer = 'volunteer';
}

class CaseStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String draft = 'draft';
}

class OrganizationStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
}

class PriorityLevels {
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';
  static const String urgent = 'urgent';
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String user = 'user_data';
  static const String role = 'user_role';
  static const String language = 'app_language';
  static const String onboardingComplete = 'onboarding_complete';
}

class ErrorMessages {
  static const String networkError = 'لا يوجد اتصال بالإنترنت';
  static const String serverError = 'حدث خطأ في الخادم';
  static const String timeoutError = 'انتهت مهلة الاتصال';
  static const String unauthorizedError = 'غير مصرح';
  static const String notFoundError = 'العنصر غير موجود';
  static const String unknownError = 'حدث خطأ غير متوقع';
  static const String validationError = 'بيانات غير صحيحة';
}

class ValidationMessages {
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'البريد الإلكتروني غير صالح';
  static const String invalidPhone = 'رقم الهاتف غير صالح';
  static const String passwordTooShort = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
  static const String passwordsNotMatch = 'كلمات المرور غير متطابقة';
  static const String invalidUrl = 'رابط غير صالح';
}
