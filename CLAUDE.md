# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Ultimate POS Flutter application - a point-of-sale system built with Flutter. The app supports multi-language localization, offline data storage with SQLite, and includes features for sales management, inventory tracking, contact management, expenses, and field force operations.

## Development Commands

### Flutter Commands
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build APK for Android
- `flutter build ios` - Build for iOS
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

### Android Build
- `cd android && ./gradlew assembleDebug` - Build debug APK
- `cd android && ./gradlew assembleRelease` - Build release APK
- `cd android && ./gradlew clean` - Clean Android build

### Testing
- `flutter test` - Run unit and widget tests
- `flutter test test/widget_test.dart` - Run specific test file

## Architecture Overview

### Core Structure
- **main.dart**: Entry point with localization setup and theme configuration
- **config.dart**: Central configuration including base URL, API credentials, and app settings
- **lib/helpers/routes.dart**: Route definitions for navigation

### Key Directories
- **lib/apis/**: API service classes for different modules (auth, sales, contacts, expenses)
- **lib/models/**: Data models and database schemas
- **lib/pages/**: UI screens and page components
- **lib/helpers/**: Utility classes (themes, routing, sizing, styling)
- **lib/locale/**: Internationalization support

### Database Architecture
The app uses SQLite with a custom database provider (`lib/models/database.dart`):
- **Tables**: system, contact, variations, variations_location_details, product_locations, sell, sell_lines, sell_payments
- **Database versioning**: Currently at version 6 with migration support
- **User-specific databases**: Each user gets their own database file (`PosDemo{userId}.db`)

### API Integration
- **OAuth2 authentication** with bearer tokens
- **Base API class** in `lib/apis/api.dart` handles authentication
- **Module-specific APIs** for different business functions
- **Configuration**: Base URL and API credentials in `config.dart`

### State Management
- **Provider pattern** for state management
- **AppLanguage provider** for localization
- **AppTheme** for theming

### Key Features
- **Multi-language support**: 8 languages (English, Arabic, German, French, Spanish, Turkish, Indonesian, Myanmar)
- **Offline functionality**: SQLite for local data storage
- **POS operations**: Sales, inventory, payments
- **Contact management**: Customer and supplier management
- **Field force**: Mobile workforce management
- **Expense tracking**: Business expense management
- **PDF generation**: Invoice and receipt printing

### Configuration Notes
- Update `Config.baseUrl` in `config.dart` for different environments
- API credentials (`clientId`, `clientSecret`) are in `config.dart`
- Google Maps API key placeholder in `config.dart`
- App supports both portrait orientation only

### Important Files to Modify for New Features
- Add new routes in `lib/helpers/routes.dart`
- Database schema changes require version increment in `database.dart`
- New API endpoints go in appropriate files under `lib/apis/`
- UI pages should be added to `lib/pages/`
- Localization strings in `i18n/*.json` files

### Testing
The project includes basic widget tests. The main test file references `MyApp` class from main.dart but appears to be a template test that needs updating for actual POS functionality.