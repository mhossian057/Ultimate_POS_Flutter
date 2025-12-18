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
- **Base URL**: `https://billmate.gtsoftwares.com/`
- **OAuth2 authentication** with bearer tokens and client credentials
- **Base API class** in `lib/apis/api.dart` handles authentication headers
- **Module-specific APIs** for different business functions
- **Configuration**: Base URL and API credentials in `lib/config.dart:6-9`

#### API Modules & Endpoints
1. **Authentication** (`api.dart`, `user.dart`)
   - `POST /oauth/token` - User login
   - `GET /connector/api/user/loggedin` - User profile & permissions

2. **Sales & POS** (`sell.dart`)
   - `POST /connector/api/sell` - Create transaction
   - `PUT /connector/api/sell/{id}` - Update transaction
   - `DELETE /connector/api/sell/{id}` - Delete transaction
   - `GET /connector/api/sell/{ids}` - Get specific transactions

3. **Contact Management** (`contact.dart`, `contact_payment.dart`)
   - `GET /connector/api/contactapi` - Get customers (paginated)
   - `POST /connector/api/contactapi` - Add customer
   - `GET /connector/api/contactapi/{id}` - Customer details & dues
   - `POST /connector/api/contactapi-payment` - Process payments

4. **Business Configuration** (`system.dart`)
   - `GET /connector/api/business-details` - Business info
   - `GET /connector/api/business-location` - Locations
   - `GET /connector/api/payment-methods` - Payment options
   - `GET /connector/api/brand` - Product brands
   - `GET /connector/api/taxonomy` - Categories & subcategories
   - `GET /connector/api/tax` - Tax configurations

5. **Inventory Management** (`variations.dart`)
   - Product variations and location-based inventory

6. **Expense Management** (`expenses.dart`)
   - `POST /connector/api/expense` - Create expense
   - `GET /connector/api/expense-categories` - Expense categories

7. **Field Force** (`field_force.dart`, `attendance.dart`)
   - `POST /connector/api/field-force/create` - Create visit
   - `POST /connector/api/clock-in` - Employee check-in
   - `POST /connector/api/clock-out` - Employee check-out
   - `GET /connector/api/get-attendance/{userId}` - Attendance records

8. **CRM & Follow-up** (`follow_up.dart`)
   - `GET /connector/api/crm/follow-ups/{id}` - Follow-up details
   - `POST /connector/api/crm/follow-ups` - Create/update follow-ups
   - `POST /connector/api/crm/call-logs` - Sync call logs

9. **Shipping** (`shipment.dart`)
   - `GET /connector/api/sell/` - Filter by shipping status
   - `POST /connector/api/update-shipping-status` - Update status

#### API Patterns
- All APIs use Bearer token authentication from base `Api` class
- Error handling with try-catch and null returns
- Local SQLite synchronization for offline functionality
- Pagination support for large datasets (customers, products)
- Multi-location business support across endpoints

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