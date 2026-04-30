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
    String get catalog;
  String get marketWatch;
  String get noProductsFound;
  String get noProductsMatchFilters;
  String get tickers;
  String get orders;
  String get weightPrefix;
  String get sellerPrefix;
  String get updatedPrefix;
  String get lastOneMinute;
  String get ask;
  String get bid;
  String get high;
  String get low;
  String get placeOrder;
  String get productDetail;
  String get material;
  String get weight;
  String get purity;
  String get description;
  String get bestSeller;
  String get reviewsCount;
  String get quantity;
  String get addToCart;
  String get buyNow;
  String get authenticityCertificate;
  String get verifiedByImseeh;
  String get videoNotSupported;
  String get videoDeviceLoadError;
  String get videoLoadError;
  String get productVideo;
  String get specialOffer;
  String get offerNow;
  String get addedToCart;
  String get addedToCartMessage;
  String get addToCartFailed;
  String get buyNowFailed;
  String get percentOff;
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
  String get totalPortfolioValue;
  String get availableCashBalance;
  String get goldInvestment;
  String get silverInvestment;
  String get recentTransactions;
  String get noTransactionsYet;
  String get viewAll;
  String get noTransactionsFound;
  String get quickActions;
  String get buy;
  String get sell;
  String get transfer;
  String get convert;
  String get noOfferProducts;
  String get all;
  String get gold;
  String get silver;
  String get diamond;
  String get jewelry;
  String get coin;
  String get bar;
  String get allSellers;
  String get walletItems;
  String get noItemsInWallet;
  String get walletEmptyMessage;
  String get noItemsForSelectedForm;
  String get tryChangingProductForm;
  String get sellGold;
  String get units;
  String get payout;
  String get walletCash;
  String get seller;
  String get form;
  String get qty;
  String get investment;
  String get currentValue;
  String get livePrice;
  String get cancelRequest;
  String get gift;
  String get pickup;
  String get taxInvoice;
  String get verified;
  String get viewDetails;
  String get totalWeight;
  String get totalPriceValue;
  String get totalHoldings;
  String get assets;
  String get summary;
  String get grossAmount;
  String get fee;
  String get assetSummary;
  String get status;
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
  String get totalPortfolioValue => 'Total Portfolio Value';
  String get availableCashBalance => 'Available cash balance:';
  String get goldInvestment => 'Gold Investment:';
  String get silverInvestment => 'Silver Investment:';
  String get recentTransactions => 'Recent Transactions';
  String get noTransactionsYet => 'No transactions yet';
  String get viewAll => 'View All';
  String get noTransactionsFound => 'No transactions found.';
  String get quickActions => 'Quick Actions';
  String get buy => 'Buy';
  String get sell => 'Sell';
  String get transfer => 'Transfer';
  String get convert => 'Convert';
  String get noOfferProducts => 'No offer products available right now.';

  String get catalog => 'Catalog';
  String get marketWatch => 'Market Watch';
  String get noProductsFound => 'No Products Found';
  String get noProductsMatchFilters => 'No products match the selected filters. Try changing material type or product form.';
  String get tickers => 'Tickers';
  String get orders => 'Orders';
  String get weightPrefix => 'Weight:';
  String get sellerPrefix => 'Seller:';
  String get updatedPrefix => 'Updated:';
  String get lastOneMinute => 'Last: 1m';
  String get ask => 'Ask';
  String get bid => 'Bid';
  String get high => 'High';
  String get low => 'Low';
  String get placeOrder => 'Place Order';
  String get productDetail => 'Product Detail';
  String get material => 'Material';
  String get weight => 'Weight';
  String get purity => 'Purity';
  String get description => 'Description';
  String get bestSeller => 'BEST SELLER';
  String get reviewsCount => '(128 reviews)';
  String get quantity => 'Quantity';
  String get addToCart => 'Add to Cart';
  String get buyNow => 'Buy Now';
  String get authenticityCertificate => 'Authenticity Certificate';
  String get verifiedByImseeh => 'Verified by Imseeh';
  String get videoNotSupported => 'Video preview is not supported on this device.';
  String get videoDeviceLoadError => 'Unable to load product video on this device.';
  String get videoLoadError => 'Unable to load product video.';
  String get productVideo => 'Product Video';
  String get specialOffer => 'Special Offer';
  String get offerNow => 'Offer • Now';
  String get addedToCart => 'Added to Cart';
  String get addedToCartMessage => 'added to cart';
  String get addToCartFailed => 'Add to Cart Failed';
  String get buyNowFailed => 'Buy Now Failed';
  String get percentOff => 'OFF';
  String get all => 'All';
  String get gold => 'Gold';
  String get silver => 'Silver';
  String get diamond => 'Diamond';
  String get jewelry => 'Jewelry';
  String get coin => 'Coin';
  String get bar => 'Bar';
  String get allSellers => 'All Sellers';
  String get walletItems => 'Wallet Items';
  String get noItemsInWallet => 'No Items in Wallet';
  String get walletEmptyMessage => 'Your wallet is empty. Start by adding your first gold item to view it here.';
  String get noItemsForSelectedForm => 'No Items for Selected Form';
  String get tryChangingProductForm => 'Try changing the product form filter to see wallet items.';
  String get sellGold => 'Sell Gold';
  String get units => 'Units';
  String get payout => 'Payout';
  String get walletCash => 'Wallet Cash';
  String get seller => 'Seller';
  String get form => 'Form';
  String get qty => 'Qty';
  String get investment => 'Investment';
  String get currentValue => 'Current Value:';
  String get livePrice => 'Live Price:';
  String get cancelRequest => 'Cancel Request';
  String get gift => 'Gift';
  String get pickup => 'Pickup';
  String get taxInvoice => 'Tax Invoice';
  String get verified => 'Verified';
  String get viewDetails => 'View Details';
  String get totalWeight => 'Total Weight';
  String get totalPriceValue => 'Total Price Value';
  String get totalHoldings => 'Total Holdings';
  String get assets => 'Assets';
  String get summary => 'Summary';
  String get grossAmount => 'Gross Amount';
  String get fee => 'Fee';
  String get assetSummary => 'Asset Summary';
  String get status => 'Status';}

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
  String get totalPortfolioValue => 'إجمالي قيمة المحفظة';
  String get availableCashBalance => 'الرصيد النقدي المتاح:';
  String get goldInvestment => 'استثمار الذهب:';
  String get silverInvestment => 'استثمار الفضة:';
  String get recentTransactions => 'أحدث المعاملات';
  String get noTransactionsYet => 'لا توجد معاملات بعد';
  String get viewAll => 'عرض الكل';
  String get noTransactionsFound => 'لم يتم العثور على معاملات.';
  String get quickActions => 'إجراءات سريعة';
  String get buy => 'شراء';
  String get sell => 'بيع';
  String get transfer => 'تحويل';
  String get convert => 'تحويل عملة';
  String get noOfferProducts => 'لا توجد منتجات عروض متاحة حالياً.';

  String get catalog => 'الكتالوج';
  String get marketWatch => 'مراقبة السوق';
  String get noProductsFound => 'لا توجد منتجات';
  String get noProductsMatchFilters => 'لا توجد منتجات تطابق الفلاتر المحددة. جرّب تغيير نوع المادة أو شكل المنتج.';
  String get tickers => 'الأسعار';
  String get orders => 'الطلبات';
  String get weightPrefix => 'الوزن:';
  String get sellerPrefix => 'البائع:';
  String get updatedPrefix => 'آخر تحديث:';
  String get lastOneMinute => 'آخر: 1 د';
  String get ask => 'طلب';
  String get bid => 'عرض';
  String get high => 'الأعلى';
  String get low => 'الأدنى';
  String get placeOrder => 'إضافة طلب';
  String get productDetail => 'تفاصيل المنتج';
  String get material => 'المادة';
  String get weight => 'الوزن';
  String get purity => 'النقاء';
  String get description => 'الوصف';
  String get bestSeller => 'الأكثر مبيعًا';
  String get reviewsCount => '(128 مراجعة)';
  String get quantity => 'الكمية';
  String get addToCart => 'أضف إلى السلة';
  String get buyNow => 'اشترِ الآن';
  String get authenticityCertificate => 'شهادة الأصالة';
  String get verifiedByImseeh => 'موثق بواسطة Imseeh';
  String get videoNotSupported => 'معاينة الفيديو غير مدعومة على هذا الجهاز.';
  String get videoDeviceLoadError => 'تعذّر تحميل فيديو المنتج على هذا الجهاز.';
  String get videoLoadError => 'تعذّر تحميل فيديو المنتج.';
  String get productVideo => 'فيديو المنتج';
  String get specialOffer => 'عرض خاص';
  String get offerNow => 'عرض • الآن';
  String get addedToCart => 'تمت الإضافة إلى السلة';
  String get addedToCartMessage => 'تمت إضافته إلى السلة';
  String get addToCartFailed => 'فشل الإضافة إلى السلة';
  String get buyNowFailed => 'فشل الشراء الآن';
  String get percentOff => 'خصم';
  String get all => 'الكل';
  String get gold => 'ذهب';
  String get silver => 'فضة';
  String get diamond => 'ألماس';
  String get jewelry => 'مجوهرات';
  String get coin => 'عملات';
  String get bar => 'سبائك';
  String get allSellers => 'كل البائعين';
  String get walletItems => 'عناصر المحفظة';
  String get noItemsInWallet => 'لا توجد عناصر في المحفظة';
  String get walletEmptyMessage => 'محفظتك فارغة. ابدأ بإضافة أول عنصر ذهب لعرضه هنا.';
  String get noItemsForSelectedForm => 'لا توجد عناصر للشكل المحدد';
  String get tryChangingProductForm => 'جرّب تغيير فلتر شكل المنتج لعرض عناصر المحفظة.';
  String get sellGold => 'بيع الذهب';
  String get units => 'وحدات';
  String get payout => 'التحصيل';
  String get walletCash => 'نقد المحفظة';
  String get seller => 'البائع';
  String get form => 'الشكل';
  String get qty => 'الكمية';
  String get investment => 'الاستثمار';
  String get currentValue => 'القيمة الحالية:';
  String get livePrice => 'السعر المباشر:';
  String get cancelRequest => 'إلغاء الطلب';
  String get gift => 'هدية';
  String get pickup => 'استلام';
  String get taxInvoice => 'فاتورة ضريبية';
  String get verified => 'موثّق';
  String get viewDetails => 'عرض التفاصيل';
  String get totalWeight => 'إجمالي الوزن';
  String get totalPriceValue => 'إجمالي قيمة السعر';
  String get totalHoldings => 'إجمالي الحيازات';
  String get assets => 'أصول';
  String get summary => 'الملخص';
  String get grossAmount => 'المبلغ الإجمالي';
  String get fee => 'الرسوم';
  String get assetSummary => 'ملخص الأصل';
  String get status => 'الحالة';}

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
