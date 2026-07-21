import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'EOTC Digital Contribution'**
  String get appName;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to EOTC'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Asrat, Bekuart & Donation Platform'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+251 9XX XXX XXX'**
  String get phoneHint;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendOtp;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Number'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendOtp;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @profileSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get profileSetup;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @selectChurch.
  ///
  /// In en, this message translates to:
  /// **'Select Your Church'**
  String get selectChurch;

  /// No description provided for @searchChurch.
  ///
  /// In en, this message translates to:
  /// **'Search church...'**
  String get searchChurch;

  /// No description provided for @joinChurch.
  ///
  /// In en, this message translates to:
  /// **'Join Church'**
  String get joinChurch;

  /// No description provided for @diocese.
  ///
  /// In en, this message translates to:
  /// **'Diocese'**
  String get diocese;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @contribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contribute;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {year}'**
  String memberSince(String year);

  /// No description provided for @totalContributions.
  ///
  /// In en, this message translates to:
  /// **'Total Contributions'**
  String get totalContributions;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @asrat.
  ///
  /// In en, this message translates to:
  /// **'Asrat (Tithe)'**
  String get asrat;

  /// No description provided for @bekuart.
  ///
  /// In en, this message translates to:
  /// **'Bekuart'**
  String get bekuart;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Contribution'**
  String get monthly;

  /// No description provided for @buildingFund.
  ///
  /// In en, this message translates to:
  /// **'Building Fund'**
  String get buildingFund;

  /// No description provided for @charity.
  ///
  /// In en, this message translates to:
  /// **'Charity'**
  String get charity;

  /// No description provided for @festival.
  ///
  /// In en, this message translates to:
  /// **'Festival Offering'**
  String get festival;

  /// No description provided for @candle.
  ///
  /// In en, this message translates to:
  /// **'Candle Offering'**
  String get candle;

  /// No description provided for @memorial.
  ///
  /// In en, this message translates to:
  /// **'Memorial Donation'**
  String get memorial;

  /// No description provided for @monastery.
  ///
  /// In en, this message translates to:
  /// **'Monastery Support'**
  String get monastery;

  /// No description provided for @priest.
  ///
  /// In en, this message translates to:
  /// **'Priest Support'**
  String get priest;

  /// No description provided for @sundaySchool.
  ///
  /// In en, this message translates to:
  /// **'Sunday School'**
  String get sundaySchool;

  /// No description provided for @youth.
  ///
  /// In en, this message translates to:
  /// **'Youth Association'**
  String get youth;

  /// No description provided for @women.
  ///
  /// In en, this message translates to:
  /// **'Women\'s Association'**
  String get women;

  /// No description provided for @development.
  ///
  /// In en, this message translates to:
  /// **'Development Project'**
  String get development;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency Fund'**
  String get emergency;

  /// No description provided for @selectContributionType.
  ///
  /// In en, this message translates to:
  /// **'Select Contribution Type'**
  String get selectContributionType;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get amountHint;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'ETB'**
  String get currency;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get note;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note...'**
  String get noteHint;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceedToPayment;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @chapa.
  ///
  /// In en, this message translates to:
  /// **'Chapa'**
  String get chapa;

  /// No description provided for @chapaDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay with Telebirr, CBE Birr, Dashen, cards via Chapa'**
  String get chapaDesc;

  /// No description provided for @telebirr.
  ///
  /// In en, this message translates to:
  /// **'Telebirr'**
  String get telebirr;

  /// No description provided for @telebirrDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay directly with your Telebirr wallet'**
  String get telebirrDesc;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount} ETB'**
  String pay(String amount);

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccess;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending'**
  String get paymentPending;

  /// No description provided for @receiptNumber.
  ///
  /// In en, this message translates to:
  /// **'Receipt No.'**
  String get receiptNumber;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download Receipt'**
  String get downloadReceipt;

  /// No description provided for @shareReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get shareReceipt;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @noTransactionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Your contribution history will appear here'**
  String get noTransactionsDesc;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @myChurch.
  ///
  /// In en, this message translates to:
  /// **'My Church'**
  String get myChurch;

  /// No description provided for @changeChurch.
  ///
  /// In en, this message translates to:
  /// **'Change Church'**
  String get changeChurch;

  /// No description provided for @membershipId.
  ///
  /// In en, this message translates to:
  /// **'Membership ID'**
  String get membershipId;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Ethiopian phone number'**
  String get invalidPhone;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get invalidAmount;

  /// No description provided for @minAmount.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount is {min} ETB'**
  String minAmount(String min);

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get networkError;

  /// No description provided for @networkErrorDesc.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again'**
  String get networkErrorDesc;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authError;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This cannot be undone.'**
  String get deleteAccountConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
