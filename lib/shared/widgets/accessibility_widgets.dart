import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Accessibility helper widgets and utilities
/// 
/// This file contains widgets and helpers for improving app accessibility
/// including screen reader support, focus management, and semantic labels.

/// Wraps a widget with semantic information for screen readers
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final bool enabled;
  final bool selected;
  final bool hidden;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.enabled = true,
    this.selected = false,
    this.hidden = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      enabled: enabled,
      selected: selected,
      hidden: hidden,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

/// Button with proper accessibility semantics
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final String label;
  final String? hint;
  final bool isPrimary;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.label,
    this.hint,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      label: label,
      hint: hint,
      onTap: onPressed,
      child: GestureDetector(
        onTap: onPressed,
        child: child,
      ),
    );
  }
}

/// Icon button with accessibility label
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String label;
  final String? hint;
  final Color? color;
  final double size;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
    this.hint,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      onTap: onPressed,
      child: IconButton(
        icon: Icon(icon, color: color, size: size),
        onPressed: onPressed,
        tooltip: label,
      ),
    );
  }
}

/// Image with accessibility description
class AccessibleImage extends StatelessWidget {
  final String? imageUrl;
  final String description;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AccessibleImage({
    super.key,
    this.imageUrl,
    required this.description,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = imageUrl != null
        ? Image.network(
            imageUrl!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          )
        : _buildPlaceholder();

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return Semantics(
      image: true,
      label: description,
      child: ExcludeSemantics(
        child: image,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}

/// Form field with accessibility support
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? helperText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const AccessibleTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.helperText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint ?? label,
      enabled: !readOnly,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        maxLines: maxLines,
        minLines: minLines,
        readOnly: readOnly,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helperText,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

/// Loading indicator with accessibility announcement
class AccessibleLoading extends StatelessWidget {
  final String message;
  final double size;

  const AccessibleLoading({
    super.key,
    this.message = 'جاري التحميل',
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message,
      liveRegion: true,
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Announces messages to screen readers
class AccessibilityAnnouncer extends StatelessWidget {
  final Widget child;
  final String announcement;
  final bool assertive;

  const AccessibilityAnnouncer({
    super.key,
    required this.child,
    required this.announcement,
    this.assertive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: announcement,
      child: child,
    );
  }
}

/// Focus trap for modals and dialogs
class FocusTrap extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const FocusTrap({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return FocusScope(
      canRequestFocus: true,
      child: child,
    );
  }
}

/// High contrast mode detection
class HighContrastDetector extends StatelessWidget {
  final Widget child;
  final Widget highContrastChild;

  const HighContrastDetector({
    super.key,
    required this.child,
    required this.highContrastChild,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isHighContrast = mediaQuery.highContrast;

    return isHighContrast ? highContrastChild : child;
  }
}

/// Large text scale factor handler
class LargeTextHandler extends StatelessWidget {
  final Widget child;
  final double maxScaleFactor;

  const LargeTextHandler({
    super.key,
    required this.child,
    this.maxScaleFactor = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(1.0, maxScaleFactor),
      ),
      child: child,
    );
  }
}

/// Skip link for accessibility (jumps to main content)
class SkipLink extends StatelessWidget {
  final FocusNode targetFocusNode;
  final String label;

  const SkipLink({
    super.key,
    required this.targetFocusNode,
    this.label = 'تخطي إلى المحتوى الرئيسي',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      onTap: () {
        targetFocusNode.requestFocus();
      },
      child: Builder(
        builder: (context) {
          // Only visible when focused
          return Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                targetFocusNode.requestFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black,
              child: Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Heading widget for proper heading hierarchy
class AccessibleHeading extends StatelessWidget {
  final String text;
  final int level; // 1-6
  final TextStyle? style;

  const AccessibleHeading({
    super.key,
    required this.text,
    this.level = 1,
    this.style,
  }) : assert(level >= 1 && level <= 6);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: text,
      child: Text(
        text,
        style: style ?? _getDefaultStyle(),
      ),
    );
  }

  TextStyle _getDefaultStyle() {
    final baseStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    switch (level) {
      case 1:
        return baseStyle.copyWith(fontSize: 32);
      case 2:
        return baseStyle.copyWith(fontSize: 24);
      case 3:
        return baseStyle.copyWith(fontSize: 20);
      case 4:
        return baseStyle.copyWith(fontSize: 18);
      case 5:
        return baseStyle.copyWith(fontSize: 16);
      case 6:
        return baseStyle.copyWith(fontSize: 14);
      default:
        return baseStyle;
    }
  }
}
