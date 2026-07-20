// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'EOTC Digital Contribution';

  @override
  String get welcomeTitle => 'Welcome to EOTC';

  @override
  String get welcomeSubtitle => 'Digital Asrat, Bekuart & Donation Platform';

  @override
  String get getStarted => 'Get Started';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneHint => '+251 9XX XXX XXX';

  @override
  String get sendOtp => 'Send Verification Code';

  @override
  String get otpTitle => 'Verify Your Number';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get verifyOtp => 'Verify';

  @override
  String get resendOtp => 'Resend Code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get profileSetup => 'Complete Your Profile';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get email => 'Email (Optional)';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get continueBtn => 'Continue';

  @override
  String get save => 'Save';

  @override
  String get selectChurch => 'Select Your Church';

  @override
  String get searchChurch => 'Search church...';

  @override
  String get joinChurch => 'Join Church';

  @override
  String get diocese => 'Diocese';

  @override
  String get location => 'Location';

  @override
  String get home => 'Home';

  @override
  String get contribute => 'Contribute';

  @override
  String get history => 'History';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String memberSince(String year) {
    return 'Member since $year';
  }

  @override
  String get totalContributions => 'Total Contributions';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get viewAll => 'View All';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get asrat => 'Asrat (Tithe)';

  @override
  String get bekuart => 'Bekuart';

  @override
  String get monthly => 'Monthly Contribution';

  @override
  String get buildingFund => 'Building Fund';

  @override
  String get charity => 'Charity';

  @override
  String get festival => 'Festival Offering';

  @override
  String get candle => 'Candle Offering';

  @override
  String get memorial => 'Memorial Donation';

  @override
  String get monastery => 'Monastery Support';

  @override
  String get priest => 'Priest Support';

  @override
  String get sundaySchool => 'Sunday School';

  @override
  String get youth => 'Youth Association';

  @override
  String get women => 'Women\'s Association';

  @override
  String get development => 'Development Project';

  @override
  String get emergency => 'Emergency Fund';

  @override
  String get selectContributionType => 'Select Contribution Type';

  @override
  String get enterAmount => 'Enter Amount';

  @override
  String get amountHint => '0.00';

  @override
  String get currency => 'ETB';

  @override
  String get note => 'Note (Optional)';

  @override
  String get noteHint => 'Add a note...';

  @override
  String get proceedToPayment => 'Proceed to Payment';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get chapa => 'Chapa';

  @override
  String get chapaDesc =>
      'Pay with Telebirr, CBE Birr, Dashen, cards via Chapa';

  @override
  String get telebirr => 'Telebirr';

  @override
  String get telebirrDesc => 'Pay directly with your Telebirr wallet';

  @override
  String pay(String amount) {
    return 'Pay $amount ETB';
  }

  @override
  String get paymentSuccess => 'Payment Successful!';

  @override
  String get paymentFailed => 'Payment Failed';

  @override
  String get paymentPending => 'Payment Pending';

  @override
  String get receiptNumber => 'Receipt No.';

  @override
  String get downloadReceipt => 'Download Receipt';

  @override
  String get shareReceipt => 'Share Receipt';

  @override
  String get done => 'Done';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get allTime => 'All Time';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get noTransactionsDesc => 'Your contribution history will appear here';

  @override
  String get myProfile => 'My Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get myChurch => 'My Church';

  @override
  String get changeChurch => 'Change Church';

  @override
  String get membershipId => 'Membership ID';

  @override
  String get language => 'Language';

  @override
  String get security => 'Security';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get noNotifications => 'No notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidPhone => 'Enter a valid Ethiopian phone number';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get invalidAmount => 'Enter a valid amount';

  @override
  String minAmount(String min) {
    return 'Minimum amount is $min ETB';
  }

  @override
  String get networkError => 'No internet connection';

  @override
  String get networkErrorDesc => 'Please check your connection and try again';

  @override
  String get sessionExpired => 'Session expired. Please sign in again.';

  @override
  String get authError => 'Authentication failed. Please try again.';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This cannot be undone.';
}
