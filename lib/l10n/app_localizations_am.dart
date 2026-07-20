// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appName => 'ኢ.ኦ.ተ.ቤ.ክ ዲጂታል አስተዋፅዖ';

  @override
  String get welcomeTitle => 'ወደ ኢ.ኦ.ተ.ቤ.ክ እንኳን ደህና መጡ';

  @override
  String get welcomeSubtitle => 'ዲጂታል አስራት፣ በኩርት እና ስጦታ መድረክ';

  @override
  String get getStarted => 'ጀምር';

  @override
  String get signIn => 'ግባ';

  @override
  String get signOut => 'ውጣ';

  @override
  String get phoneNumber => 'ስልክ ቁጥር';

  @override
  String get phoneHint => '+251 9XX XXX XXX';

  @override
  String get sendOtp => 'የማረጋገጫ ኮድ ላክ';

  @override
  String get otpTitle => 'ቁጥርዎን ያረጋግጡ';

  @override
  String otpSubtitle(String phone) {
    return 'ወደ $phone የተላከው 6-አሃዝ ኮድ ያስገቡ';
  }

  @override
  String get verifyOtp => 'አረጋግጥ';

  @override
  String get resendOtp => 'ኮድ እንደገና ላክ';

  @override
  String resendIn(int seconds) {
    return 'እንደገና ላክ በ $seconds ሰ';
  }

  @override
  String get profileSetup => 'መገለጫዎን ያጠናቅቁ';

  @override
  String get fullName => 'ሙሉ ስም';

  @override
  String get fullNameHint => 'ሙሉ ስምዎን ያስገቡ';

  @override
  String get email => 'ኢሜይል (አማራጭ)';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get continueBtn => 'ቀጥል';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get selectChurch => 'ቤተ ክርስቲያን ይምረጡ';

  @override
  String get searchChurch => 'ቤተ ክርስቲያን ፈልግ...';

  @override
  String get joinChurch => 'ቤተ ክርስቲያን ተቀላቀል';

  @override
  String get diocese => 'ሀገረ ስብከት';

  @override
  String get location => 'አካባቢ';

  @override
  String get home => 'ዋና ገፅ';

  @override
  String get contribute => 'አስተዋፅዖ';

  @override
  String get history => 'ታሪክ';

  @override
  String get profile => 'መገለጫ';

  @override
  String get notifications => 'ማሳወቂያዎች';

  @override
  String get goodMorning => 'እንደምን አደሩ';

  @override
  String get goodAfternoon => 'እንደምን ዋሉ';

  @override
  String get goodEvening => 'እንደምን አምሹ';

  @override
  String memberSince(String year) {
    return 'አባል ከ $year ጀምሮ';
  }

  @override
  String get totalContributions => 'ጠቅላላ አስተዋፅዖ';

  @override
  String get recentActivity => 'የቅርብ ጊዜ እንቅስቃሴ';

  @override
  String get viewAll => 'ሁሉንም ይመልከቱ';

  @override
  String get noRecentActivity => 'ምንም የቅርብ ጊዜ እንቅስቃሴ የለም';

  @override
  String get asrat => 'አስራት';

  @override
  String get bekuart => 'በኩርት';

  @override
  String get monthly => 'ወርሃዊ አስተዋፅዖ';

  @override
  String get buildingFund => 'የቤተ ክርስቲያን ግንባታ';

  @override
  String get charity => 'ምፅዋት';

  @override
  String get festival => 'የሃይማኖት ዓውደ ዓመት';

  @override
  String get candle => 'ሻማ ቅድስቲ';

  @override
  String get memorial => 'ሶሪ ሶሪ';

  @override
  String get monastery => 'ለገዳም ድጋፍ';

  @override
  String get priest => 'ለካህን ድጋፍ';

  @override
  String get sundaySchool => 'ሰንበት ትምህርት ቤት';

  @override
  String get youth => 'የወጣቶች ማህበር';

  @override
  String get women => 'የሴቶች ማህበር';

  @override
  String get development => 'የልማት ፕሮጀክት';

  @override
  String get emergency => 'አስቸኳይ ፈንድ';

  @override
  String get selectContributionType => 'የአስተዋፅዖ አይነት ይምረጡ';

  @override
  String get enterAmount => 'መጠን ያስገቡ';

  @override
  String get amountHint => '0.00';

  @override
  String get currency => 'ብር';

  @override
  String get note => 'ማስታወሻ (አማራጭ)';

  @override
  String get noteHint => 'ማስታወሻ ያስጨምሩ...';

  @override
  String get proceedToPayment => 'ወደ ክፍያ ይቀጥሉ';

  @override
  String get selectPaymentMethod => 'የክፍያ ዘዴ ይምረጡ';

  @override
  String get chapa => 'ቻፓ';

  @override
  String get chapaDesc => 'ቴሌብር፣ ሲቢኢ ብር፣ ዳሸን፣ ካርዶች በቻፓ ይክፈሉ';

  @override
  String get telebirr => 'ቴሌብር';

  @override
  String get telebirrDesc => 'በቴሌብር ቀጥታ ይክፈሉ';

  @override
  String pay(String amount) {
    return '$amount ብር ክፈል';
  }

  @override
  String get paymentSuccess => 'ክፍያ ተሳክቷል!';

  @override
  String get paymentFailed => 'ክፍያ አልተሳካም';

  @override
  String get paymentPending => 'ክፍያ በሂደት ላይ';

  @override
  String get receiptNumber => 'ደረሰኝ ቁጥር';

  @override
  String get downloadReceipt => 'ደረሰኝ አውርድ';

  @override
  String get shareReceipt => 'ደረሰኝ አጋራ';

  @override
  String get done => 'ጨርስ';

  @override
  String get tryAgain => 'እንደገና ሞክር';

  @override
  String get transactionHistory => 'የግብይት ታሪክ';

  @override
  String get allTime => 'ሁሉም ጊዜ';

  @override
  String get thisMonth => 'ይህ ወር';

  @override
  String get thisYear => 'ይህ ዓመት';

  @override
  String get noTransactions => 'ምንም ግብይቶች የሉም';

  @override
  String get noTransactionsDesc => 'የአስተዋፅዖ ታሪክዎ እዚህ ይታያል';

  @override
  String get myProfile => 'የእኔ መገለጫ';

  @override
  String get editProfile => 'መገለጫ አርትዕ';

  @override
  String get myChurch => 'የእኔ ቤተ ክርስቲያን';

  @override
  String get changeChurch => 'ቤተ ክርስቲያን ቀይር';

  @override
  String get membershipId => 'የአባልነት መታወቂያ';

  @override
  String get language => 'ቋንቋ';

  @override
  String get security => 'ደህንነት';

  @override
  String get about => 'ስለ መተግበሪያው';

  @override
  String version(String version) {
    return 'ስሪት $version';
  }

  @override
  String get noNotifications => 'ምንም ማሳወቂያዎች የሉም';

  @override
  String get markAllRead => 'ሁሉንም እንደተነበቡ ምልክት አድርግ';

  @override
  String get loading => 'በመጫን ላይ...';

  @override
  String get error => 'ችግር ተፈጥሯል';

  @override
  String get retry => 'እንደገና ሞክር';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get confirm => 'አረጋግጥ';

  @override
  String get yes => 'አዎ';

  @override
  String get no => 'አይ';

  @override
  String get ok => 'እሺ';

  @override
  String get close => 'ዝጋ';

  @override
  String get back => 'ተመለስ';

  @override
  String get next => 'ቀጣይ';

  @override
  String get skip => 'ዝለል';

  @override
  String get requiredField => 'ይህ መስክ አስፈላጊ ነው';

  @override
  String get invalidPhone => 'ትክክለኛ የኢትዮጵያ ስልክ ቁጥር ያስገቡ';

  @override
  String get invalidEmail => 'ትክክለኛ ኢሜይል አድራሻ ያስገቡ';

  @override
  String get invalidAmount => 'ትክክለኛ መጠን ያስገቡ';

  @override
  String minAmount(String min) {
    return 'አነስተኛ መጠን $min ብር ነው';
  }

  @override
  String get networkError => 'ኢንተርኔት አለ';

  @override
  String get networkErrorDesc => 'እባክዎ ግንኙነትዎን ያረጋግጡ እና እንደገና ይሞክሩ';

  @override
  String get sessionExpired => 'ክፍለ ጊዜ አብቅቷል። እባክዎ እንደገና ይግቡ።';

  @override
  String get authError => 'ማረጋገጫ አልተሳካም። እባክዎ እንደገና ይሞክሩ።';

  @override
  String get signOutConfirm => 'እርግጠኛ ነዎት መውጣት ይፈልጋሉ?';

  @override
  String get deleteAccountConfirm => 'አካውንትዎን ለመሰረዝ እርግጠኛ ነዎት? ይህ ሊቀለበስ አይችልም።';
}
