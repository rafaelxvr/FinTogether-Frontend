# FinTogether Frontend

FinTogether is a personal-finance and shared-budgeting application for individuals and couples. This repository contains the Flutter client for Android, iOS, and web. It provides an offline-first interface for budgets, accounts, transactions, credit cards, savings goals, recurring expenses, imports, and household collaboration.

The API consumed by this client lives in the [FinTogether Backend](https://github.com/rafaelxvr/FinTogether-Backend) repository.

## What is included

- Authentication, registration, password recovery, token refresh, and session persistence.
- Shared budgets with members, categories, accounts, transfers, and dashboard analytics.
- Transactions with search, bulk entry, installments, recurring templates, and splits.
- Credit cards, invoices, monthly costs, merchants, savings goals, and contributions.
- CSV/import workflows, batch entry, notification preferences, and local notifications.
- Offline-first local persistence with Drift/SQLite, connectivity monitoring, and sync queues.
- English and Portuguese localization resources.

## Technology stack

- Flutter and Dart 3.5.4+
- Riverpod for state management and dependency injection helpers
- GoRouter for navigation
- Dio and Retrofit for HTTP APIs
- Drift/SQLite for local data and offline support
- `shared_preferences` and secure storage for local session data
- `fl_chart` for dashboard visualizations
- `flutter_local_notifications` and `permission_handler` for notifications

## Requirements

Install the following before running the project:

- Flutter SDK compatible with Dart `^3.5.4`
- Android Studio and an Android SDK for Android builds, or Xcode for iOS builds
- A running FinTogether Backend, normally at `http://localhost:8080`
- Chrome or another supported browser for web development

Verify the Flutter installation:

```bash
flutter doctor
```

## Setup

```bash
git clone https://github.com/rafaelxvr/FinTogether-Frontend.git
cd FinTogether-Frontend
flutter pub get
```

The checked-in client defaults to `http://localhost:8080` in `lib/core/network/api_constants.dart`. Change that value when the backend runs on another host, emulator address, or deployed environment. Android emulators commonly need `10.0.2.2` instead of `localhost` to reach a host-machine server.

## Run the app

```bash
# List available devices
flutter devices

# Run on the default connected device
flutter run

# Run in Chrome
flutter run -d chrome

# Run with a selected device
flutter run -d <device-id>
```

Start the backend before signing in. The client expects the API and its database to be available; the local Drift database still supports offline reads and queues changes for synchronization.

## Project structure

```text
lib/
├── core/
│   ├── database/          # Drift tables, connections, and sync persistence
│   ├── di/                # Dependency registration
│   ├── network/           # Dio client, API constants, auth headers
│   ├── notifications/     # Channels, permissions, preferences, scheduling
│   ├── router/            # GoRouter configuration
│   ├── sync/              # Connectivity monitoring and synchronization
│   └── utils/             # Failures, constants, and logging
├── features/
│   ├── auth/               # Authentication and password recovery
│   ├── account/            # Accounts and transfers
│   ├── budget/             # Budgets and household members
│   ├── budget_allocation/  # Planned-versus-actual allocation health
│   ├── category/           # Income and expense categories
│   ├── credit_card/        # Cards, invoices, and card costs
│   ├── dashboard/          # Summaries, comparisons, forecasts, and alerts
│   ├── import/             # Import profiles and transaction import
│   ├── merchant/           # Merchant management and analytics
│   ├── recurring/          # Recurring templates and fixed expenses
│   ├── savings_goal/       # Goals, contributions, and withdrawals
│   ├── splitting/          # Transaction splits and settlement balances
│   └── transaction/        # Transactions, search, installments, and bulk entry
└── l10n/                   # English and Portuguese ARB resources
```

Each feature follows a layered structure where practical:

```text
feature/
├── data/          # API/local data sources, DTOs, and repository implementations
├── domain/        # Entities, repository contracts, and use cases
└── presentation/ # Riverpod providers, state, pages, and widgets
```

## API integration

The shared Dio client is configured in `lib/core/network/dio_client.dart`. Retrofit data sources live alongside their feature and use generated implementations. Authentication tokens are read from secure storage where supported and from shared preferences on web. The client sends the access token as a bearer token and refreshes or clears session state through the auth provider.

To point the client at a deployed API, update `ApiConstants.baseUrl` and ensure the backend allows the client origin for web requests. Keep environment-specific URLs and credentials out of source control.

## Offline-first behavior

Drift stores the local application model, pending mutations, and sync log. The sync layer monitors connectivity and coordinates local changes with the API. A normal development flow is:

1. Start the backend and database.
2. Launch the client and sign in once while online.
3. Create or edit data while connected or offline.
4. Reconnect and allow the sync manager to flush pending changes.

The local database connection has native, web, and unsupported-platform implementations. Web builds use the checked-in SQLite worker assets under `web/`.

## Tests and quality checks

```bash
flutter analyze
flutter test
flutter test --coverage
```

Run a focused test file when iterating:

```bash
flutter test test/features/auth/domain/usecases/login_usecase_test.dart
```

Generated files may need to be refreshed after changing Retrofit, Riverpod, Drift, JSON, or Freezed annotations:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Build artifacts

```bash
# Web
flutter build web --release

# Android APK
flutter build apk --release

# Android app bundle
flutter build appbundle --release
```

Release signing, API endpoints, and service credentials must be supplied by the deployment environment. Do not place signing keys or production secrets in this repository.

## Related repository

- [FinTogether Backend](https://github.com/rafaelxvr/FinTogether-Backend) — REST API, authentication, persistence, migrations, and server-side business rules.

Planning and specification documents are intentionally excluded from this public repository. The repository contains the application source, tests, platform scaffolding, and operational documentation needed to run it.
