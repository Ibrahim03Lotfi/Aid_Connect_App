import 'package:flutter/material.dart';

// Light of Impact - Warm Hopeful Color System
const Color backgroundOffWhite = Color(0xFFF9FAFB);
const Color softBlueTint = Color(0xFFF3F8FC);
const Color friendlyBlue = Color(0xFF1E7ABF);
const Color softTeal = Color(0xFF3BB3A9);
const Color textDark = Color(0xFF1F2937);
const Color textMedium = Color(0xFF6B7280);
const Color textLight = Color(0xFF9CA3AF);
const Color cardWhite = Color(0xFFFFFFFF);
const Color borderLight = Color(0xFFE5E7EB);

/// Reusable error state widget
class ErrorState extends StatelessWidget {
  final String? title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color? iconColor;

  const ErrorState({
    super.key,
    this.title,
    required this.message,
    this.buttonText,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.red).withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: (iconColor ?? Colors.red).withAlpha(100),
              ),
            ),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: textMedium,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onRetry != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [friendlyBlue, softTeal],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: friendlyBlue.withAlpha(30),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        buttonText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error state
class NetworkError extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkError({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.wifi_off_outlined,
      iconColor: Colors.orange,
      title: 'لا يوجد اتصال',
      message: 'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
      buttonText: 'إعادة المحاولة',
      onRetry: onRetry,
    );
  }
}

/// Server error state
class ServerError extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerError({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.cloud_off_outlined,
      iconColor: Colors.red,
      title: 'خطأ في الخادم',
      message: 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً',
      buttonText: 'إعادة المحاولة',
      onRetry: onRetry,
    );
  }
}

/// Generic error state with refresh button
class GenericError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const GenericError({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.error_outline,
      message: message,
      buttonText: onRetry != null ? 'إعادة المحاولة' : null,
      onRetry: onRetry,
    );
  }
}

/// Auth error state (for login/register errors)
class AuthError extends StatelessWidget {
  final String message;

  const AuthError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.lock_outline,
      iconColor: Colors.orange,
      message: message,
    );
  }
}

/// Not found error state
class NotFoundError extends StatelessWidget {
  final String? message;
  final VoidCallback? onBack;

  const NotFoundError({
    super.key,
    this.message,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.search_off_outlined,
      iconColor: textMedium,
      title: 'غير موجود',
      message: message ?? 'العنصر المطلوب غير موجود',
      buttonText: onBack != null ? 'العودة' : null,
      onRetry: onBack,
    );
  }
}
