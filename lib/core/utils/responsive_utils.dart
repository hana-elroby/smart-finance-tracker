// Responsive Utils - أدوات التصميم المتجاوب
// Utilities for responsive design across different screen sizes

import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Get screen type
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  // Check if mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  // Check if tablet
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  // Check if desktop
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop;
  }

  // Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16);
      case ScreenType.tablet:
        return const EdgeInsets.all(24);
      case ScreenType.desktop:
        return const EdgeInsets.all(32);
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return baseFontSize * 0.9;
      case ScreenType.tablet:
        return baseFontSize;
      case ScreenType.desktop:
        return baseFontSize * 1.1;
    }
  }

  // Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return baseSpacing * 0.8;
      case ScreenType.tablet:
        return baseSpacing;
      case ScreenType.desktop:
        return baseSpacing * 1.2;
    }
  }

  // Get responsive width
  static double getResponsiveWidth(BuildContext context, double percentage) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * percentage;
  }

  // Get responsive height
  static double getResponsiveHeight(BuildContext context, double percentage) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * percentage;
  }

  // Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return baseSize;
      case ScreenType.tablet:
        return baseSize * 1.2;
      case ScreenType.desktop:
        return baseSize * 1.4;
    }
  }

  // Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, double baseRadius) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return baseRadius;
      case ScreenType.tablet:
        return baseRadius * 1.1;
      case ScreenType.desktop:
        return baseRadius * 1.2;
    }
  }

  // Get responsive card elevation
  static double getResponsiveElevation(BuildContext context, double baseElevation) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return baseElevation;
      case ScreenType.tablet:
        return baseElevation * 1.2;
      case ScreenType.desktop:
        return baseElevation * 1.5;
    }
  }

  // Get responsive grid count
  static int getResponsiveGridCount(BuildContext context, {
    int mobileCount = 2,
    int tabletCount = 3,
    int desktopCount = 4,
  }) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return mobileCount;
      case ScreenType.tablet:
        return tabletCount;
      case ScreenType.desktop:
        return desktopCount;
    }
  }

  // Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }

  // Get screen size info
  static ScreenSizeInfo getScreenSizeInfo(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    
    return ScreenSizeInfo(
      width: size.width,
      height: size.height,
      devicePixelRatio: devicePixelRatio,
      screenType: getScreenType(context),
    );
  }
}

// Screen type enum
enum ScreenType {
  mobile,
  tablet,
  desktop,
}

// Screen size info class
class ScreenSizeInfo {
  final double width;
  final double height;
  final double devicePixelRatio;
  final ScreenType screenType;

  const ScreenSizeInfo({
    required this.width,
    required this.height,
    required this.devicePixelRatio,
    required this.screenType,
  });

  // Get aspect ratio
  double get aspectRatio => width / height;

  // Check if landscape
  bool get isLandscape => width > height;

  // Check if portrait
  bool get isPortrait => height > width;

  // Get diagonal size in inches (approximate)
  double get diagonalInches {
    final diagonal = (width * width + height * height) / (devicePixelRatio * devicePixelRatio);
    return diagonal / 160; // Approximate conversion
  }

  @override
  String toString() {
    return 'ScreenSizeInfo(width: $width, height: $height, type: $screenType)';
  }
}