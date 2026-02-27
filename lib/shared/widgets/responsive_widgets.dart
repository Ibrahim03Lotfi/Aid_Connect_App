import 'package:flutter/material.dart';

/// Responsive layout utilities
/// 
/// Provides helpers for building responsive layouts that adapt to different
/// screen sizes, orientations, and device types.

/// Breakpoints for responsive design
class Breakpoints {
  /// Small phones
  static const double xs = 320;
  
  /// Standard phones
  static const double sm = 375;
  
  /// Large phones / Small tablets
  static const double md = 414;
  
  /// Tablets
  static const double lg = 768;
  
  /// Large tablets / Small laptops
  static const double xl = 1024;
  
  /// Desktops
  static const double xxl = 1440;
}

/// Responsive layout builder
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= Breakpoints.xl && desktop != null) {
      return desktop!;
    }
    
    if (width >= Breakpoints.lg && tablet != null) {
      return tablet!;
    }
    
    return mobile;
  }
}

/// Responsive padding that adjusts based on screen size
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    EdgeInsets padding;
    if (width >= Breakpoints.xl && desktop != null) {
      padding = desktop!;
    } else if (width >= Breakpoints.lg && tablet != null) {
      padding = tablet!;
    } else {
      padding = mobile ?? const EdgeInsets.all(16);
    }
    
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Grid that adapts column count based on screen width
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final int mobileCrossAxisCount;
  final int tabletCrossAxisCount;
  final int desktopCrossAxisCount;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.mobileCrossAxisCount = 2,
    this.tabletCrossAxisCount = 3,
    this.desktopCrossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    int crossAxisCount;
    if (width >= Breakpoints.xl) {
      crossAxisCount = desktopCrossAxisCount;
    } else if (width >= Breakpoints.lg) {
      crossAxisCount = tabletCrossAxisCount;
    } else {
      crossAxisCount = mobileCrossAxisCount;
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Constrains content width on large screens while maintaining full width on mobile
class ConstrainedContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Alignment alignment;

  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Extension for responsive values
extension ResponsiveExtension on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Check if mobile
  bool get isMobile => screenWidth < Breakpoints.lg;
  
  /// Check if tablet
  bool get isTablet => screenWidth >= Breakpoints.lg && screenWidth < Breakpoints.xl;
  
  /// Check if desktop
  bool get isDesktop => screenWidth >= Breakpoints.xl;
  
  /// Get responsive value
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if ((isTablet || isDesktop) && tablet != null) return tablet;
    return mobile;
  }
}

/// Orientation-aware widget
class OrientationBuilder extends StatelessWidget {
  final Widget portrait;
  final Widget landscape;

  const OrientationBuilder({
    super.key,
    required this.portrait,
    required this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    
    return orientation == Orientation.portrait ? portrait : landscape;
  }
}

/// Safe area wrapper with optional padding
class SafeAreaWrapper extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets? minimum;

  const SafeAreaWrapper({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum ?? EdgeInsets.zero,
      child: child,
    );
  }
}

/// Bottom inset aware widget for keyboards
class KeyboardAware extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const KeyboardAware({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: padding.copyWith(bottom: padding.bottom + bottomInset),
      child: child,
    );
  }
}
