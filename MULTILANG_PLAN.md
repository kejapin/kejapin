# Kejapin Multi-Language Implementation Plan

This document outlines the strategy for implementing the Three-Language System (English, Kiswahili Sanifu, and Kiswahili Kenyan) in the Kejapin app using free, open-source, and high-performance tools.

## 1. Core Technology Stack
- **Flutter Localizations**: The standard, built-in framework for high-performance string switching.
- **ARB (Application Resource Bundle)**: Open-source JSON-based format for keeping translations organized.
- **Provider**: For ultra-fast, reactive language switching without page reloads.

## 2. Language Variants
| Key | Language Name | Code | Style Example |
|-----|---------------|------|---------------|
| `en` | English | `en` | "Find your home" |
| `sw` | Kiswahili Sanifu | `sw` | "Tafuta nyumba yako" |
| `sw_KE` | Kiswahili Kenyan (Local) | `sw-KE` | "Saka keja yako" |

## 3. Implementation Steps

### Step 1: Dependencies
Add standard open-source localization packages to `pubspec.yaml`:
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any # Standard for date/number formatting
```

### Step 2: Configuration (`l10n.yaml`)
Create a config file in the `client` directory:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
# We generate directly in lib/l10n for maximum environment compatibility
```

### Step 3: Create Translation Files
Create three files in `lib/l10n/`:
1. `app_en.arb`: Base English.
2. `app_sw.arb`: Formal Tanzanian/Coastal Swahili.
3. `app_sw_KE.arb`: Nairobi/Local variant (Sheng-lite).

### Step 4: State Management (The Switcher)
Create a `LocaleProvider` to allow the user to change the language in real-time from the Settings screen.

### Step 5: Integration in `main.dart`
Update the `MaterialApp` to listen to the chosen locale and support the new Kiswahili variants.

## 4. Why this is "Fast and Free"
- **Zero Cost**: All tools are built into the Flutter SDK. No paid APIs (like Google Cloud Translate) are required for the app to function.
- **High Speed**: ARB files are compiled into binary Dart code during the build process, meaning language switching happens in **milliseconds**.
- **User Preference**: We will use `shared_preferences` (already in the project) to remember the user's choice even after the app closes.

## 5. Sample Translation Comparison (Sneak Peek)

| English | Kiswahili Sanifu | Kiswahili Kenyan |
|---------|------------------|------------------|
| Marketplace | Soko la Nyumba | Marketplace |
| Become a Partner | Kuwa Mshirika | Jiunge kama Partner |
| Search Property | Tafuta Nyumba | Saka Keja |
| Notifications | Arifa | Manotisi |

---

## 6. Implementation Progress Tracking

### Batch 1: Auth & Initial Flow (Completed ✅)
- [x] Landing Page (`landing_page.dart`)
- [x] Splash Screen (`splash_screen.dart`)
- [x] Onboarding Screen (`onboarding_screen.dart`)
- [x] Login Screen (`login_screen.dart`)
- [x] Register Screen (`register_screen.dart`)

### Batch 2: Marketplace & Exploration (Completed ✅)
- [x] Marketplace Feed (`marketplace_feed.dart`)
- [x] Map View (`marketplace_map.dart`)
- [x] Search & Filter Components (`marketplace_search_bar.dart`, `advanced_filters_sheet.dart`)
- [x] Property Detail Cards & Screen (`listing_card.dart`, `listing_details_screen.dart`)

### Batch 3: User Profile & Messages (Pending)
- [x] Profile Settings & Edit Profile
- [x] Messages / Chat Interface & Notifications
- [x] Partner Program (Apply Landlord)
- [ ] Booking & Schedule Screens (To be implemented)

### Batch 4: Payment & Advanced Features (Completed ✅)
- [x] Payment Gateway Integration UI (PaymentMethodsScreen localized; Backend pending)
- [x] Rent Payment History (Integrated into Life-Path Journey on Dashboard)
- [x] Review & Rating System (PropertyReviewScreen localized)
