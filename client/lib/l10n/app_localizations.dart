import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('sw'),
    Locale('sw', 'KE'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kejapin'**
  String get appTitle;

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @becomePartner.
  ///
  /// In en, this message translates to:
  /// **'Become a Partner'**
  String get becomePartner;

  /// No description provided for @sakaKeja.
  ///
  /// In en, this message translates to:
  /// **'Find your home'**
  String get sakaKeja;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for properties...'**
  String get searchHint;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @landingTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t just list it. Pin it.'**
  String get landingTitle;

  /// No description provided for @landingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find your perfect home with real commute times, transparent costs, and verified listings. Kenya\'s smartest rental marketplace.'**
  String get landingSubtitle;

  /// No description provided for @startSearch.
  ///
  /// In en, this message translates to:
  /// **'Start Your Search'**
  String get startSearch;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @getStartedFree.
  ///
  /// In en, this message translates to:
  /// **'Get Started Free'**
  String get getStartedFree;

  /// No description provided for @featuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Life-Path Features'**
  String get featuresTitle;

  /// No description provided for @featuresSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect. Live. Thrive.'**
  String get featuresSubtitle;

  /// No description provided for @commuteTitle.
  ///
  /// In en, this message translates to:
  /// **'Real Commute Times'**
  String get commuteTitle;

  /// No description provided for @commuteDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculate exact travel times to your workplace, gym, and all your life pins.'**
  String get commuteDesc;

  /// No description provided for @transparencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Cost Transparency'**
  String get transparencyTitle;

  /// No description provided for @transparencyDesc.
  ///
  /// In en, this message translates to:
  /// **'See the complete monthly cost including rent, commute, and utilities.'**
  String get transparencyDesc;

  /// No description provided for @verifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified Listings'**
  String get verifiedTitle;

  /// No description provided for @verifiedDesc.
  ///
  /// In en, this message translates to:
  /// **'Every property is verified. Every landlord is screened. Your peace of mind guaranteed.'**
  String get verifiedDesc;

  /// No description provided for @communityTitle.
  ///
  /// In en, this message translates to:
  /// **'Join the Community'**
  String get communityTitle;

  /// No description provided for @communityDesc.
  ///
  /// In en, this message translates to:
  /// **'Thousands of tenants and landlords trust kejapin to find and list homes. Be part of Kenya\'s most transparent rental community.'**
  String get communityDesc;

  /// No description provided for @ctaTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to Find Your Home?'**
  String get ctaTitle;

  /// No description provided for @ctaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your journey to the perfect rental. It\'s free to browse.'**
  String get ctaSubtitle;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Find Your Perfect Fit'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In en, this message translates to:
  /// **'Discover homes curated by data and design. We analyze what matters to match you with properties that truly fit your lifestyle.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Route. Find Your Life Pins.'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In en, this message translates to:
  /// **'Visualize your commute and calculate real travel times to work, gym, and all the places that matter in your life.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Complete Cost Transparency'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Desc.
  ///
  /// In en, this message translates to:
  /// **'See the total monthly cost including rent, commute, and utilities. No hidden fees, just honest numbers.'**
  String get onboarding3Desc;

  /// No description provided for @onboarding4Title.
  ///
  /// In en, this message translates to:
  /// **'Trust Built In'**
  String get onboarding4Title;

  /// No description provided for @onboarding4Desc.
  ///
  /// In en, this message translates to:
  /// **'Verified landlords, secure payments, and a community-focused platform. Find your home with confidence.'**
  String get onboarding4Desc;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to your dashboard'**
  String get loginSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpLink;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find your perfect home today.'**
  String get joinSubtitle;

  /// No description provided for @registerStartJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your journey with us'**
  String get registerStartJourney;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordLengthError;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLink;

  /// No description provided for @resultsFor.
  ///
  /// In en, this message translates to:
  /// **'Results for'**
  String get resultsFor;

  /// No description provided for @filtersActive.
  ///
  /// In en, this message translates to:
  /// **'Filters Active'**
  String get filtersActive;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'Map View'**
  String get mapView;

  /// No description provided for @feedError.
  ///
  /// In en, this message translates to:
  /// **'Feed Error'**
  String get feedError;

  /// No description provided for @noListingsFound.
  ///
  /// In en, this message translates to:
  /// **'No Listings Found'**
  String get noListingsFound;

  /// No description provided for @noListingsMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any properties matching your criteria.'**
  String get noListingsMessage;

  /// No description provided for @allCategory.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategory;

  /// No description provided for @bedsitter.
  ///
  /// In en, this message translates to:
  /// **'Bedsitter'**
  String get bedsitter;

  /// No description provided for @oneBhk.
  ///
  /// In en, this message translates to:
  /// **'1BHK'**
  String get oneBhk;

  /// No description provided for @twoBhk.
  ///
  /// In en, this message translates to:
  /// **'2BHK'**
  String get twoBhk;

  /// No description provided for @sq.
  ///
  /// In en, this message translates to:
  /// **'SQ'**
  String get sq;

  /// No description provided for @bungalow.
  ///
  /// In en, this message translates to:
  /// **'Bungalow'**
  String get bungalow;

  /// No description provided for @propertyPinned.
  ///
  /// In en, this message translates to:
  /// **'Property Pinned! 📍'**
  String get propertyPinned;

  /// No description provided for @pinnedToLifePath.
  ///
  /// In en, this message translates to:
  /// **'You pinned property to your life-path.'**
  String get pinnedToLifePath;

  /// No description provided for @propertyRemoved.
  ///
  /// In en, this message translates to:
  /// **'Property Removed 🗑️'**
  String get propertyRemoved;

  /// No description provided for @removedFromLifePath.
  ///
  /// In en, this message translates to:
  /// **'Property removed from your life-path.'**
  String get removedFromLifePath;

  /// No description provided for @listingSaved.
  ///
  /// In en, this message translates to:
  /// **'Listing saved!'**
  String get listingSaved;

  /// No description provided for @listingRemoved.
  ///
  /// In en, this message translates to:
  /// **'Listing removed.'**
  String get listingRemoved;

  /// No description provided for @topPercentile.
  ///
  /// In en, this message translates to:
  /// **'TOP'**
  String get topPercentile;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'STATS'**
  String get stats;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'MAP'**
  String get map;

  /// No description provided for @fullPrice.
  ///
  /// In en, this message translates to:
  /// **'Full Price'**
  String get fullPrice;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @spatialPulse.
  ///
  /// In en, this message translates to:
  /// **'SPATIAL PULSE'**
  String get spatialPulse;

  /// No description provided for @dimensionalAnalysis.
  ///
  /// In en, this message translates to:
  /// **'10-DIMENSIONAL ANALYSIS'**
  String get dimensionalAnalysis;

  /// No description provided for @propScore.
  ///
  /// In en, this message translates to:
  /// **'Prop Score'**
  String get propScore;

  /// No description provided for @marketPercentile.
  ///
  /// In en, this message translates to:
  /// **'Market %'**
  String get marketPercentile;

  /// No description provided for @fit.
  ///
  /// In en, this message translates to:
  /// **'Fit'**
  String get fit;

  /// No description provided for @viewFullBlueprint.
  ///
  /// In en, this message translates to:
  /// **'VIEW FULL KEJAPIN BLUEPRINT'**
  String get viewFullBlueprint;

  /// No description provided for @kmFromYou.
  ///
  /// In en, this message translates to:
  /// **'km from you'**
  String get kmFromYou;

  /// No description provided for @propertyDetails.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get propertyDetails;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// No description provided for @beds.
  ///
  /// In en, this message translates to:
  /// **'Beds'**
  String get beds;

  /// No description provided for @baths.
  ///
  /// In en, this message translates to:
  /// **'Baths'**
  String get baths;

  /// No description provided for @sqft.
  ///
  /// In en, this message translates to:
  /// **'sqft'**
  String get sqft;

  /// No description provided for @yourLifePathCommutes.
  ///
  /// In en, this message translates to:
  /// **'Your Life Path Commutes'**
  String get yourLifePathCommutes;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculating;

  /// No description provided for @livingEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Living Efficiency'**
  String get livingEfficiency;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @connectWithLandlord.
  ///
  /// In en, this message translates to:
  /// **'Connect with Landlord'**
  String get connectWithLandlord;

  /// No description provided for @bookViewing.
  ///
  /// In en, this message translates to:
  /// **'Book Viewing'**
  String get bookViewing;

  /// No description provided for @showPhotos.
  ///
  /// In en, this message translates to:
  /// **'Show Photos'**
  String get showPhotos;

  /// No description provided for @showMap.
  ///
  /// In en, this message translates to:
  /// **'Show Map'**
  String get showMap;

  /// No description provided for @lifePathFit.
  ///
  /// In en, this message translates to:
  /// **'Life-Path Fit'**
  String get lifePathFit;

  /// No description provided for @stageRadar.
  ///
  /// In en, this message translates to:
  /// **'Stage Radar'**
  String get stageRadar;

  /// No description provided for @networkStrength.
  ///
  /// In en, this message translates to:
  /// **'Network Strength'**
  String get networkStrength;

  /// No description provided for @waterReliability.
  ///
  /// In en, this message translates to:
  /// **'Water Reliability'**
  String get waterReliability;

  /// No description provided for @powerStability.
  ///
  /// In en, this message translates to:
  /// **'Power Stability'**
  String get powerStability;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @retailDensity.
  ///
  /// In en, this message translates to:
  /// **'Retail Density'**
  String get retailDensity;

  /// No description provided for @healthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get healthcare;

  /// No description provided for @wellness.
  ///
  /// In en, this message translates to:
  /// **'Wellness'**
  String get wellness;

  /// No description provided for @vibeMatch.
  ///
  /// In en, this message translates to:
  /// **'Vibe Match'**
  String get vibeMatch;

  /// No description provided for @advancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get advancedFilters;

  /// No description provided for @refineSearch.
  ///
  /// In en, this message translates to:
  /// **'Refine your search'**
  String get refineSearch;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @propertyType.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get propertyType;

  /// No description provided for @furnishing.
  ///
  /// In en, this message translates to:
  /// **'Furnishing'**
  String get furnishing;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @availableNow.
  ///
  /// In en, this message translates to:
  /// **'Available Now'**
  String get availableNow;

  /// No description provided for @availableNowDesc.
  ///
  /// In en, this message translates to:
  /// **'Show only immediately available properties'**
  String get availableNowDesc;

  /// No description provided for @furnished.
  ///
  /// In en, this message translates to:
  /// **'Furnished'**
  String get furnished;

  /// No description provided for @semiFurnished.
  ///
  /// In en, this message translates to:
  /// **'Semi-Furnished'**
  String get semiFurnished;

  /// No description provided for @unfurnished.
  ///
  /// In en, this message translates to:
  /// **'Unfurnished'**
  String get unfurnished;

  /// No description provided for @searchHintMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Search location or apartment name...'**
  String get searchHintMarketplace;

  /// No description provided for @wifi.
  ///
  /// In en, this message translates to:
  /// **'WiFi'**
  String get wifi;

  /// No description provided for @parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get parking;

  /// No description provided for @water247.
  ///
  /// In en, this message translates to:
  /// **'Water 24/7'**
  String get water247;

  /// No description provided for @generator.
  ///
  /// In en, this message translates to:
  /// **'Generator'**
  String get generator;

  /// No description provided for @gym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get gym;

  /// No description provided for @swimmingPool.
  ///
  /// In en, this message translates to:
  /// **'Swimming Pool'**
  String get swimmingPool;

  /// No description provided for @garden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get garden;

  /// No description provided for @savedListings.
  ///
  /// In en, this message translates to:
  /// **'Saved Listings'**
  String get savedListings;

  /// No description provided for @noSavedListings.
  ///
  /// In en, this message translates to:
  /// **'No saved listings yet'**
  String get noSavedListings;

  /// No description provided for @noSavedListingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Pin your favorite properties to see them here.'**
  String get noSavedListingsMessage;

  /// No description provided for @exploreMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Explore Marketplace'**
  String get exploreMarketplace;

  /// No description provided for @errorLoadingSavedListings.
  ///
  /// In en, this message translates to:
  /// **'Error loading saved listings'**
  String get errorLoadingSavedListings;

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'PROFILE & SETTINGS'**
  String get profileAndSettings;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @chooseAnimated.
  ///
  /// In en, this message translates to:
  /// **'Choose Animated'**
  String get chooseAnimated;

  /// No description provided for @generateRandom.
  ///
  /// In en, this message translates to:
  /// **'Generate Random'**
  String get generateRandom;

  /// No description provided for @randomGenerator.
  ///
  /// In en, this message translates to:
  /// **'Random Generator'**
  String get randomGenerator;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @saveThisAvatar.
  ///
  /// In en, this message translates to:
  /// **'Save This Avatar'**
  String get saveThisAvatar;

  /// No description provided for @savingAvatar.
  ///
  /// In en, this message translates to:
  /// **'Saving avatar...'**
  String get savingAvatar;

  /// No description provided for @newAvatarGenerated.
  ///
  /// In en, this message translates to:
  /// **'New avatar generated!'**
  String get newAvatarGenerated;

  /// No description provided for @chooseAnAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose an Avatar'**
  String get chooseAnAvatar;

  /// No description provided for @avatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated!'**
  String get avatarUpdated;

  /// No description provided for @uploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading image...'**
  String get uploadingImage;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated!'**
  String get profilePictureUpdated;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'EDIT PROFILE'**
  String get editProfile;

  /// No description provided for @lifePins.
  ///
  /// In en, this message translates to:
  /// **'Life Pins'**
  String get lifePins;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE PROFILE'**
  String get completeProfile;

  /// No description provided for @letsGetToKnowYou.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get to know you'**
  String get letsGetToKnowYou;

  /// No description provided for @updatingProfileRecognize.
  ///
  /// In en, this message translates to:
  /// **'Updating your profile helps people recognize you in chats and marketplace interactions.'**
  String get updatingProfileRecognize;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. john_doe'**
  String get usernameHint;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'John'**
  String get firstNameHint;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Doe'**
  String get lastNameHint;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about yourself...'**
  String get bioHint;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'SAVE PROFILE'**
  String get saveProfile;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @manageNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage how we notify you about updates'**
  String get manageNotificationsSubtitle;

  /// No description provided for @securityAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get securityAndPrivacy;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your data will be erased.'**
  String get deleteAccountWarning;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @searchLandlordProperty.
  ///
  /// In en, this message translates to:
  /// **'Search landlord, property...'**
  String get searchLandlordProperty;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @generalInquiry.
  ///
  /// In en, this message translates to:
  /// **'General Inquiry'**
  String get generalInquiry;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @noMessagesHereYet.
  ///
  /// In en, this message translates to:
  /// **'No messages here yet'**
  String get noMessagesHereYet;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'MARK ALL READ'**
  String get markAllRead;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// No description provided for @noNewNotifications.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any new notifications.'**
  String get noNewNotifications;

  /// No description provided for @noPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'No payment methods added yet.'**
  String get noPaymentMethods;

  /// No description provided for @addPaymentMethodInfo.
  ///
  /// In en, this message translates to:
  /// **'Add Payment Method requires a payment gateway integration.'**
  String get addPaymentMethodInfo;

  /// No description provided for @addNewMethod.
  ///
  /// In en, this message translates to:
  /// **'Add New Method'**
  String get addNewMethod;

  /// No description provided for @defaultText.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get defaultText;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdated;

  /// No description provided for @errorSendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Error sending message'**
  String get errorSendingMessage;

  /// No description provided for @loginDetails.
  ///
  /// In en, this message translates to:
  /// **'Login Details'**
  String get loginDetails;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddressLabel;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @updatePasswordSecurely.
  ///
  /// In en, this message translates to:
  /// **'Update your password securely'**
  String get updatePasswordSecurely;

  /// No description provided for @enhancedSecurity.
  ///
  /// In en, this message translates to:
  /// **'Enhanced Security'**
  String get enhancedSecurity;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuth;

  /// No description provided for @twoFactorDesc.
  ///
  /// In en, this message translates to:
  /// **'Add an extra layer of security to your account.'**
  String get twoFactorDesc;

  /// No description provided for @twoFactorUpdated.
  ///
  /// In en, this message translates to:
  /// **'2FA settings updated'**
  String get twoFactorUpdated;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmDesc;

  /// No description provided for @supportContactSubmit.
  ///
  /// In en, this message translates to:
  /// **'Request submitted. Support will contact you.'**
  String get supportContactSubmit;

  /// No description provided for @permanentlyRemoveData.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your data'**
  String get permanentlyRemoveData;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get howCanWeHelp;

  /// No description provided for @findAnswers.
  ///
  /// In en, this message translates to:
  /// **'Find answers to common questions or reach out to our team.'**
  String get findAnswers;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'FREQUENTLY ASKED QUESTIONS'**
  String get frequentlyAskedQuestions;

  /// No description provided for @faq1Question.
  ///
  /// In en, this message translates to:
  /// **'How do I verify my account?'**
  String get faq1Question;

  /// No description provided for @faq1Answer.
  ///
  /// In en, this message translates to:
  /// **'Go to the Profile screen and click the \"Verify\" badge or apply through the \"Become a Partner\" section.'**
  String get faq1Answer;

  /// No description provided for @faq2Question.
  ///
  /// In en, this message translates to:
  /// **'Is my payment information secure?'**
  String get faq2Question;

  /// No description provided for @faq2Answer.
  ///
  /// In en, this message translates to:
  /// **'Yes, we use industry-standard encryption and partner with trusted payment gateways like Stripe/M-Pesa.'**
  String get faq2Answer;

  /// No description provided for @faq3Question.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel a booking?'**
  String get faq3Question;

  /// No description provided for @faq3Answer.
  ///
  /// In en, this message translates to:
  /// **'Cancellations depend on the landlord\'s policy. Check the specific listing details for cancellation terms.'**
  String get faq3Answer;

  /// No description provided for @faq4Question.
  ///
  /// In en, this message translates to:
  /// **'How do I contact a landlord?'**
  String get faq4Question;

  /// No description provided for @faq4Answer.
  ///
  /// In en, this message translates to:
  /// **'You can message a landlord directly through the \"Messages\" tab or from their listing page.'**
  String get faq4Answer;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'CONTACT US'**
  String get contactUs;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @availableHours.
  ///
  /// In en, this message translates to:
  /// **'Available 9am - 5pm'**
  String get availableHours;

  /// No description provided for @liveChatOffline.
  ///
  /// In en, this message translates to:
  /// **'Live chat agents are currently offline.'**
  String get liveChatOffline;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @bookingIssue.
  ///
  /// In en, this message translates to:
  /// **'e.g. Booking Issue'**
  String get bookingIssue;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @describeIssue.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue...'**
  String get describeIssue;

  /// No description provided for @ticketCreated.
  ///
  /// In en, this message translates to:
  /// **'Support ticket created. We will email you shortly.'**
  String get ticketCreated;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @receiveEmailUpdates.
  ///
  /// In en, this message translates to:
  /// **'Receive updates via email'**
  String get receiveEmailUpdates;

  /// No description provided for @smsNotifications.
  ///
  /// In en, this message translates to:
  /// **'SMS Notifications'**
  String get smsNotifications;

  /// No description provided for @receiveSmsAlerts.
  ///
  /// In en, this message translates to:
  /// **'Receive urgent alerts via SMS'**
  String get receiveSmsAlerts;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @newListings.
  ///
  /// In en, this message translates to:
  /// **'New Listings'**
  String get newListings;

  /// No description provided for @alertsSavedSearches.
  ///
  /// In en, this message translates to:
  /// **'Alerts for saved searches'**
  String get alertsSavedSearches;

  /// No description provided for @alertsChatMessages.
  ///
  /// In en, this message translates to:
  /// **'Chat messages from landlords/tenants'**
  String get alertsChatMessages;

  /// No description provided for @promotionsTips.
  ///
  /// In en, this message translates to:
  /// **'Promotions & Tips'**
  String get promotionsTips;

  /// No description provided for @newsTipsKejapin.
  ///
  /// In en, this message translates to:
  /// **'News and tips from Kejapin'**
  String get newsTipsKejapin;

  /// No description provided for @receiveDeviceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts on your device'**
  String get receiveDeviceAlerts;

  /// No description provided for @applyLandlordTitle.
  ///
  /// In en, this message translates to:
  /// **'PARTNER PROGRAM'**
  String get applyLandlordTitle;

  /// No description provided for @legalName.
  ///
  /// In en, this message translates to:
  /// **'Full Legal Name'**
  String get legalName;

  /// No description provided for @legalNameHint.
  ///
  /// In en, this message translates to:
  /// **'Must match ID/M-Pesa'**
  String get legalNameHint;

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'National ID Number'**
  String get idNumber;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get phoneNumber;

  /// No description provided for @yourRole.
  ///
  /// In en, this message translates to:
  /// **'YOUR ROLE'**
  String get yourRole;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'OWNER'**
  String get owner;

  /// No description provided for @agent.
  ///
  /// In en, this message translates to:
  /// **'AGENT'**
  String get agent;

  /// No description provided for @caretaker.
  ///
  /// In en, this message translates to:
  /// **'CARETAKER'**
  String get caretaker;

  /// No description provided for @kraPin.
  ///
  /// In en, this message translates to:
  /// **'KRA PIN'**
  String get kraPin;

  /// No description provided for @agencyName.
  ///
  /// In en, this message translates to:
  /// **'Agency/Brand Name (Optional)'**
  String get agencyName;

  /// No description provided for @proofOfAssociation.
  ///
  /// In en, this message translates to:
  /// **'PROOF OF ASSOCIATION'**
  String get proofOfAssociation;

  /// No description provided for @utilityBill.
  ///
  /// In en, this message translates to:
  /// **'Utility Bill'**
  String get utilityBill;

  /// No description provided for @regCert.
  ///
  /// In en, this message translates to:
  /// **'Agency Registration Cert'**
  String get regCert;

  /// No description provided for @authorityLetter.
  ///
  /// In en, this message translates to:
  /// **'Letter of Authority (Caretaker)'**
  String get authorityLetter;

  /// No description provided for @payoutDetails.
  ///
  /// In en, this message translates to:
  /// **'Payout Details'**
  String get payoutDetails;

  /// No description provided for @mpesa.
  ///
  /// In en, this message translates to:
  /// **'MPESA'**
  String get mpesa;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'BANK'**
  String get bank;

  /// No description provided for @paybillTill.
  ///
  /// In en, this message translates to:
  /// **'Paybill / Till / Phone'**
  String get paybillTill;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @tapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload'**
  String get tapToUpload;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueText;

  /// No description provided for @alreadyPartner.
  ///
  /// In en, this message translates to:
  /// **'Already a Partner? Tap to Verify'**
  String get alreadyPartner;

  /// No description provided for @autoVerified.
  ///
  /// In en, this message translates to:
  /// **'AUTO-VERIFIED'**
  String get autoVerified;

  /// No description provided for @welcomePartner.
  ///
  /// In en, this message translates to:
  /// **'WELCOME PARTNER'**
  String get welcomePartner;

  /// No description provided for @welcomePartnerDesc.
  ///
  /// In en, this message translates to:
  /// **'Your documents have been submitted and auto-approved for testing. You can now access the Landlord Dashboard.'**
  String get welcomePartnerDesc;

  /// No description provided for @goToDashboard.
  ///
  /// In en, this message translates to:
  /// **'GO TO DASHBOARD'**
  String get goToDashboard;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @legalNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Legal name is required'**
  String get legalNameRequired;

  /// No description provided for @idRequired.
  ///
  /// In en, this message translates to:
  /// **'ID Number is required'**
  String get idRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @kraPinRequired.
  ///
  /// In en, this message translates to:
  /// **'KRA PIN is required for verification'**
  String get kraPinRequired;

  /// No description provided for @idFrontRequired.
  ///
  /// In en, this message translates to:
  /// **'ID Front is required'**
  String get idFrontRequired;

  /// No description provided for @idBackRequired.
  ///
  /// In en, this message translates to:
  /// **'ID Back is required'**
  String get idBackRequired;

  /// No description provided for @selfieRequired.
  ///
  /// In en, this message translates to:
  /// **'Live selfie image is required'**
  String get selfieRequired;

  /// No description provided for @proofRequired.
  ///
  /// In en, this message translates to:
  /// **'Proof of association is required'**
  String get proofRequired;

  /// No description provided for @payoutRequired.
  ///
  /// In en, this message translates to:
  /// **'Payout details are required'**
  String get payoutRequired;

  /// No description provided for @partnerStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Partner status confirmed! Redirecting to dashboard...'**
  String get partnerStatusConfirmed;

  /// No description provided for @accountVerified.
  ///
  /// In en, this message translates to:
  /// **'Account verified! Refreshing your permissions...'**
  String get accountVerified;

  /// No description provided for @applicationPending.
  ///
  /// In en, this message translates to:
  /// **'Your application is still PENDING verification. Please wait for approval.'**
  String get applicationPending;

  /// No description provided for @noPartnerRecord.
  ///
  /// In en, this message translates to:
  /// **'No partner record found. Please proceed with the application.'**
  String get noPartnerRecord;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailed;

  /// No description provided for @partnerPortal.
  ///
  /// In en, this message translates to:
  /// **'PARTNER PORTAL'**
  String get partnerPortal;

  /// No description provided for @businessInsights.
  ///
  /// In en, this message translates to:
  /// **'Business Insights'**
  String get businessInsights;

  /// No description provided for @leads.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get leads;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @propertyPerformance.
  ///
  /// In en, this message translates to:
  /// **'Property Performance'**
  String get propertyPerformance;

  /// No description provided for @portfolioHealth.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Health'**
  String get portfolioHealth;

  /// No description provided for @addListing.
  ///
  /// In en, this message translates to:
  /// **'Add Listing'**
  String get addListing;

  /// No description provided for @pulseViews.
  ///
  /// In en, this message translates to:
  /// **'Pulse Views'**
  String get pulseViews;

  /// No description provided for @qualifiedLeads.
  ///
  /// In en, this message translates to:
  /// **'Qualified Leads'**
  String get qualifiedLeads;

  /// No description provided for @manageListings.
  ///
  /// In en, this message translates to:
  /// **'MANAGE LISTINGS'**
  String get manageListings;

  /// No description provided for @loadingListings.
  ///
  /// In en, this message translates to:
  /// **'Loading Listings'**
  String get loadingListings;

  /// No description provided for @noListings.
  ///
  /// In en, this message translates to:
  /// **'No Listings'**
  String get noListings;

  /// No description provided for @noListingsDesc.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t posted any properties yet.'**
  String get noListingsDesc;

  /// No description provided for @deleteListingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Listing?'**
  String get deleteListingConfirm;

  /// No description provided for @deleteListingWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure?'**
  String get deleteListingWarning;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @listingVisible.
  ///
  /// In en, this message translates to:
  /// **'Listing is now Visible'**
  String get listingVisible;

  /// No description provided for @listingHidden.
  ///
  /// In en, this message translates to:
  /// **'Listing is now Hidden'**
  String get listingHidden;

  /// No description provided for @landlordProfile.
  ///
  /// In en, this message translates to:
  /// **'Landlord Profile'**
  String get landlordProfile;

  /// No description provided for @landlordName.
  ///
  /// In en, this message translates to:
  /// **'Landlord Name'**
  String get landlordName;

  /// No description provided for @listingsByLandlord.
  ///
  /// In en, this message translates to:
  /// **'Listings by this landlord'**
  String get listingsByLandlord;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @kiswahiliSanifu.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili (Sanifu)'**
  String get kiswahiliSanifu;

  /// No description provided for @kiswahiliKenyan.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili (Kenyan)'**
  String get kiswahiliKenyan;

  /// No description provided for @reviewPropertyTitle.
  ///
  /// In en, this message translates to:
  /// **'Review {propertyName}'**
  String reviewPropertyTitle(Object propertyName);

  /// No description provided for @howWasYourStay.
  ///
  /// In en, this message translates to:
  /// **'How was your stay?'**
  String get howWasYourStay;

  /// No description provided for @reviewHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about the management, wifi, and neighborhood...'**
  String get reviewHint;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT REVIEW'**
  String get submitReview;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your review is live.'**
  String get reviewSubmitted;

  /// No description provided for @myLifeHub.
  ///
  /// In en, this message translates to:
  /// **'MY LIFE-HUB'**
  String get myLifeHub;

  /// No description provided for @spatialActivity.
  ///
  /// In en, this message translates to:
  /// **'Spatial Activity'**
  String get spatialActivity;

  /// No description provided for @avgLifePulse.
  ///
  /// In en, this message translates to:
  /// **'Avg. Life-Pulse'**
  String get avgLifePulse;

  /// No description provided for @top10Percent.
  ///
  /// In en, this message translates to:
  /// **'Top 10%'**
  String get top10Percent;

  /// No description provided for @lifePathJourney.
  ///
  /// In en, this message translates to:
  /// **'Life-Path Journey'**
  String get lifePathJourney;

  /// No description provided for @spatialSavings.
  ///
  /// In en, this message translates to:
  /// **'Spatial Savings'**
  String get spatialSavings;

  /// No description provided for @ratePerformance.
  ///
  /// In en, this message translates to:
  /// **'Rate Performance'**
  String get ratePerformance;

  /// No description provided for @shareContent.
  ///
  /// In en, this message translates to:
  /// **'Share Content'**
  String get shareContent;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @lease.
  ///
  /// In en, this message translates to:
  /// **'Lease'**
  String get lease;

  /// No description provided for @property.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get property;

  /// No description provided for @repair.
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get repair;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @acknowledge.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get acknowledge;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @rentDue.
  ///
  /// In en, this message translates to:
  /// **'Rent Due'**
  String get rentDue;

  /// No description provided for @repairRequest.
  ///
  /// In en, this message translates to:
  /// **'Repair Request'**
  String get repairRequest;

  /// No description provided for @viewingRequest.
  ///
  /// In en, this message translates to:
  /// **'Viewing Request'**
  String get viewingRequest;

  /// No description provided for @userInfo.
  ///
  /// In en, this message translates to:
  /// **'User Info'**
  String get userInfo;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUser;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;
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
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'sw':
      {
        switch (locale.countryCode) {
          case 'KE':
            return AppLocalizationsSwKe();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
