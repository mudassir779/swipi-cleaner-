/// App-wide constants
class AppConstants {
  // Grid layout
  static const int photoGridColumns = 3;
  static const double photoGridSpacing = 2.0;
  static const double photoGridAspectRatio = 1.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Pagination
  static const int photosPerPage = 100;

  // Recently deleted retention (days)
  static const int recentlyDeletedRetentionDays = 30;

  // File size limits (bytes)
  static const int largeSizeThreshold = 10 * 1024 * 1024; // 10MB
  static const int mediumSizeThreshold = 5 * 1024 * 1024; // 5MB

  // Date filters
  static const int daysInWeek = 7;
  static const int daysInMonth = 30;
  static const int daysInYear = 365;
}
