import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ar')];

  String get appTitle;
  String get language;
  String get edit;
  String get cancel;
  String get languageSettings;
  String get selectYourAppLanguage;
  String get applicationLanguage;
  String get saveChanges;
  String get saved;
  String get languageUpdatedSuccessfully;
  String get validationError;
  String get english;
  String get arabic;
  String get goldWallet;
  String get shop;
  String get myWallet;
  String get myCart;
  String get transactions;
  String get youHaveNewNotification;
  String get myAccountSummary;
  String get home;
  String get product;
  String get wallet;
  String get cart;
  String get history;
}

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super('en');
  String get appTitle => 'ECommerce Gold Wallet';
  String get language => 'Language';
  String get edit => 'Edit';
  String get cancel => 'Cancel';
  String get languageSettings => 'Language Settings';
  String get selectYourAppLanguage => 'Select your app language.';
  String get applicationLanguage => 'Application Language';
  String get saveChanges => 'Save Changes';
  String get saved => 'Saved';
  String get languageUpdatedSuccessfully => 'Language updated successfully';
  String get validationError => 'Validation Error';
  String get english => 'English';
  String get arabic => 'Arabic';
  String get goldWallet => 'Gold Wallet';
  String get shop => 'Shop';
  String get myWallet => 'My Wallet';
  String get myCart => 'My Cart';
  String get transactions => 'Transactions';
  String get youHaveNewNotification => 'You have a new notification';
  String get myAccountSummary => 'My Account Summary';
  String get home => 'Home';
  String get product => 'Product';
  String get wallet => 'Wallet';
  String get cart => 'Cart';
  String get history => 'History';
}

class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr() : super('ar');
  String get appTitle => 'محفظة الذهب الإلكترونية';
  String get language => 'اللغة';
  String get edit => 'تعديل';
  String get cancel => 'إلغاء';
  String get languageSettings => 'إعدادات اللغة';
  String get selectYourAppLanguage => 'اختر لغة التطبيق.';
  String get applicationLanguage => 'لغة التطبيق';
  String get saveChanges => 'حفظ التغييرات';
  String get saved => 'تم الحفظ';
  String get languageUpdatedSuccessfully => 'تم تحديث اللغة بنجاح';
  String get validationError => 'خطأ في التحقق';
  String get english => 'الإنجليزية';
  String get arabic => 'العربية';
  String get goldWallet => 'محفظة الذهب';
  String get shop => 'المتجر';
  String get myWallet => 'محفظتي';
  String get myCart => 'سلتي';
  String get transactions => 'المعاملات';
  String get youHaveNewNotification => 'لديك إشعار جديد';
  String get myAccountSummary => 'ملخص حسابي';
  String get home => 'الرئيسية';
  String get product => 'المنتجات';
  String get wallet => 'المحفظة';
  String get cart => 'السلة';
  String get history => 'السجل';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture<AppLocalizations>(_lookupAppLocalizations(locale));

  @override
  bool isSupported(Locale locale) => <String>['en', 'ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ar':
      return AppLocalizationsAr();
  }
  throw FlutterError('Unsupported locale: $locale');
}
