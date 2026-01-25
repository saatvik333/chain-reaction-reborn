class AppDimensions {
  // Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0; // formerly used as SizedBox height 32
  static const double paddingXXL = 40.0;
  static const double spacingXXL = 48.0; // Specific large spacing
  static const double paddingXXXL = 64.0; // found in winner screen

  // Border Radius
  static const double radiusS = 12.0;
  static const double radiusM = 24.0; // for dialogs

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 28.0;

  // Font Sizes
  static const double fontXS = 12.0;
  static const double fontS = 14.0;
  static const double fontM = 16.0;
  static const double fontL = 18.0;
  static const double fontXL = 20.0;
  static const double fontXXL = 24.0;
  static const double fontGiant = 40.0; // for Winner text

  // Specific Elements
  static const double pillButtonHeight = 56.0;
  static const double pillButtonBorderWidth = 1.5;
  static const double letterSpacingHeader = 1.5;
  static const double letterSpacingTitle = 2.0; // game selector
  static const double colorCircleSize = 24.0; // Standard color circle size

  // Orb/Grid
  static const double orbSizeLarge = 160.0; // Home screen central orb
  static const double orbSizeMedium = 80.0;
  static const double orbSizeSmall = 20.0; // Atom circle
  static const double orbBorderWidth = 16.0; // Central orb border

  // Game Grid Configurations
  static const double gridPadding = 16.0;
  static const double cellSpacing = 2.0;

  // Grid Sizes: (rows, cols)
  static const Map<String, (int, int)> gridSizes = {
    'X Small': (6, 4),
    'Small': (8, 5),
    'Medium': (10, 6),
    'Large': (12, 7),
    'X Large': (14, 8),
  };

  // Animation durations (ms)
  static const int explosionDurationMs = 50;
  static const int turnTransitionMs = 200;
}
