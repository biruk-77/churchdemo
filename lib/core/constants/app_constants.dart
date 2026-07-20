import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGold = Color(0xFFC9A227);
  static const Color primaryGoldLight = Color(0xFFE8C84A);
  static const Color primaryGoldDark = Color(0xFF9C7A1A);
  static const Color orthodoxBlue = Color(0xFF1A237E);
  static const Color orthodoxBlueLight = Color(0xFF3949AB);
  static const Color orthodoxBlueDark = Color(0xFF0D1257);
  static const Color background = Color(0xFFFAF8F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color divider = Color(0xFFE0D9C8);
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textHint = Color(0xFF938F99);
}

class AppConstants {
  static const String appName = 'EOTC Digital Contribution';
  static const String appNameAmharic = 'ኢ.ኦ.ተ.ቤ.ክ ዲጂታል አስተዋፅዖ';
  static const String appBundleId = 'com.abyssiniasoftware.church';
  static const String securityChannel = 'com.abyssiniasoftware.church/security';

  // Firestore collections
  static const String colUsers = 'users';
  static const String colChurches = 'churches';
  static const String colMonasteries = 'monasteries';
  static const String colContributions = 'contributions';
  static const String colNotifications = 'notifications';
  static const String colAuditLogs = 'audit_logs';

  // Backward-compatible aliases
  static const String usersCollection = colUsers;
  static const String churchesCollection = colChurches;
  static const String monasteriesCollection = colMonasteries;
  static const String contributionsCollection = colContributions;

  // Payment keys — replace with real keys from your secure backend/env
  static const String chapaSecretKey = 'CHAPA_SECRET_KEY_PLACEHOLDER';
  static const String telebirrAppKey = 'TELEBIRR_APP_KEY_PLACEHOLDER';
  static const String telebirrAppSecret = 'TELEBIRR_APP_SECRET_PLACEHOLDER';

  // FCM topics
  static const String topicAll = 'all_members';

  // Payment
  static const String chapaBaseUrl = 'https://api.chapa.co/v1';
  static const String telebirrBaseUrl = 'https://api.ethiotelecom.et/payment';
  static const double minContributionAmount = 10.0;
  static const String defaultCurrency = 'ETB';

  // Session
  static const Duration sessionTimeout = Duration(minutes: 15);
  static const Duration otpResendDelay = Duration(seconds: 60);

  // Pagination
  static const int pageSize = 20;

  // Routes
  static const String routeSplash = '/';
  static const String routePhoneAuth = '/auth/phone';
  static const String routeOtp = '/auth/otp';
  static const String routeProfileSetup = '/auth/profile';
  static const String routeChurchSelection = '/church-select';
  static const String routeHome = '/home';
  static const String routeContribute = '/contribute';
  static const String routeAmount = '/contribute/amount';
  static const String routeConfirm = '/contribute/confirm';
  static const String routePaymentMethod = '/payment/method';
  static const String routePaymentSuccess = '/payment/success';
  static const String routeHistory = '/history';
  static const String routeReceipt = '/history/receipt';
  static const String routeProfile = '/profile';
  static const String routeNotifications = '/notifications';
}

class UserRole {
  static const String member = 'member';
  static const String churchAdmin = 'churchAdmin';
  static const String monasteryAdmin = 'monasteryAdmin';
  static const String dioceseAdmin = 'dioceseAdmin';
  static const String nationalAdmin = 'nationalAdmin';
}

class MembershipStatus {
  static const String pending = 'pending';
  static const String active = 'active';
  static const String suspended = 'suspended';
}

enum ContributionType {
  asrat,
  bekuart,
  monthly,
  buildingFund,
  charity,
  festival,
  candle,
  memorial,
  monastery,
  priest,
  sundaySchool,
  youth,
  women,
  development,
  emergency;

  String get displayNameEn {
    switch (this) {
      case ContributionType.asrat: return 'Asrat (Tithe)';
      case ContributionType.bekuart: return 'Bekuart';
      case ContributionType.monthly: return 'Monthly Contribution';
      case ContributionType.buildingFund: return 'Building Fund';
      case ContributionType.charity: return 'Charity';
      case ContributionType.festival: return 'Festival Offering';
      case ContributionType.candle: return 'Candle Offering';
      case ContributionType.memorial: return 'Memorial Donation';
      case ContributionType.monastery: return 'Monastery Support';
      case ContributionType.priest: return 'Priest Support';
      case ContributionType.sundaySchool: return 'Sunday School';
      case ContributionType.youth: return 'Youth Association';
      case ContributionType.women: return "Women's Association";
      case ContributionType.development: return 'Development Project';
      case ContributionType.emergency: return 'Emergency Fund';
    }
  }

  String get displayNameAm {
    switch (this) {
      case ContributionType.asrat: return 'አስራት';
      case ContributionType.bekuart: return 'በኩርት';
      case ContributionType.monthly: return 'ወርሃዊ አስተዋፅዖ';
      case ContributionType.buildingFund: return 'የቤተ ክርስቲያን ግንባታ';
      case ContributionType.charity: return 'ምፅዋት';
      case ContributionType.festival: return 'የሃይማኖት ዓውደ ዓመት';
      case ContributionType.candle: return 'ሻማ ቅድስቲ';
      case ContributionType.memorial: return 'ሶሪ ሶሪ';
      case ContributionType.monastery: return 'ለገዳም ድጋፍ';
      case ContributionType.priest: return 'ለካህን ድጋፍ';
      case ContributionType.sundaySchool: return 'ሰንበት ትምህርት ቤት';
      case ContributionType.youth: return 'የወጣቶች ማህበር';
      case ContributionType.women: return 'የሴቶች ማህበር';
      case ContributionType.development: return 'የልማት ፕሮጀክት';
      case ContributionType.emergency: return 'አስቸኳይ ፈንድ';
    }
  }

  IconData get icon {
    switch (this) {
      case ContributionType.asrat: return Icons.percent;
      case ContributionType.bekuart: return Icons.child_care;
      case ContributionType.monthly: return Icons.calendar_month;
      case ContributionType.buildingFund: return Icons.church;
      case ContributionType.charity: return Icons.volunteer_activism;
      case ContributionType.festival: return Icons.celebration;
      case ContributionType.candle: return Icons.local_fire_department;
      case ContributionType.memorial: return Icons.emoji_nature;
      case ContributionType.monastery: return Icons.account_balance;
      case ContributionType.priest: return Icons.person;
      case ContributionType.sundaySchool: return Icons.school;
      case ContributionType.youth: return Icons.groups;
      case ContributionType.women: return Icons.people;
      case ContributionType.development: return Icons.construction;
      case ContributionType.emergency: return Icons.emergency;
    }
  }
}

enum ContributionStatus { pending, completed, failed, refunded }

enum PaymentMethod { chapa, telebirr }
