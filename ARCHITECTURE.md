# SaveIt - Clean Architecture Structure

## Project Overview

SaveIt is a Flutter finance tracking application built with Clean Architecture principles and BLoC pattern for state management. It features offline-first data persistence with Firebase cloud sync.

## Current Project Organization

```
lib/
│
├── 📁 core/                                    # SHARED RESOURCES
│   │
│   ├── 📁 constants/                           # App-wide constants
│   │   └── 📄 app_constants.dart              # App name, durations, paths
│   │
│   ├── 📁 database/                            # Local Database
│   │   └── 📄 database_helper.dart            # SQLite operations
│   │
│   ├── 📁 models/                              # Data Models
│   │   ├── 📄 expense_model.dart              # Expense entity
│   │   └── 📄 user_model.dart                 # User entity
│   │
│   ├── 📁 repositories/                        # Data Repositories
│   │   └── 📄 expense_repository.dart         # Expense data operations
│   │
│   ├── 📁 routes/                              # Navigation
│   │   └── 📄 app_routes.dart                 # Route constants
│   │
│   ├── 📁 services/                            # Business Services
│   │   ├── 📄 firebase_auth_service.dart      # Authentication
│   │   ├── 📄 firestore_service.dart          # Cloud database
│   │   └── 📄 sync_service.dart               # Offline sync
│   │
│   ├── 📁 theme/                               # Styling
│   │   ├── 📄 app_colors.dart                 # Color palette
│   │   └── 📄 app_theme.dart                  # Material theme config
│   │
│   └── 📁 utils/                               # Utilities
│       └── 📄 navigation_helper.dart          # Navigation helpers
│
├── 📁 features/                                # FEATURE MODULES
│   │
│   ├── 📁 splash/                              # Splash Screen Feature
│   │   └── 📁 presentation/
│   │       ├── 📁 bloc/
│   │       ├── 📁 pages/
│   │       └── 📁 widgets/
│   │
│   ├── 📁 onboarding/                          # Onboarding Feature
│   │   ├── 📁 data/
│   │   ├── 📁 domain/
│   │   └── 📁 presentation/
│   │
│   ├── 📁 auth/                                # Authentication Feature
│   │   └── 📁 presentation/
│   │       ├── 📁 bloc/
│   │       │   ├── 📄 auth_bloc.dart
│   │       │   ├── 📄 auth_event.dart
│   │       │   └── 📄 auth_state.dart
│   │       ├── 📁 pages/
│   │       │   ├── 📄 auth_page.dart
│   │       │   ├── 📄 login_page.dart
│   │       │   ├── 📄 signup_page.dart
│   │       │   └── 📄 forgot_password_page.dart
│   │       └── 📁 widgets/
│   │
│   ├── 📁 expenses/                            # Expenses Feature
│   │   └── 📁 presentation/
│   │       ├── 📁 bloc/
│   │       │   ├── 📄 expense_bloc.dart
│   │       │   ├── 📄 expense_event.dart
│   │       │   └── 📄 expense_state.dart
│   │       ├── 📁 pages/
│   │       │   ├── 📄 expenses_page.dart
│   │       │   └── 📄 add_expense_page.dart
│   │       └── 📁 widgets/
│   │           ├── 📄 expense_card.dart
│   │           ├── 📄 expense_summary_card.dart
│   │           └── 📄 category_filter_chips.dart
│   │
│   └── 📁 home/                                # Home Feature
│       ├── 📄 home_page.dart                  # Main container with bottom nav
│       └── 📁 pages/
│           ├── 📄 dashboard_page.dart         # Dashboard overview
│           ├── 📄 analytics_page.dart         # Expense analytics
│           └── 📄 profile_page.dart           # User profile & settings
│
└── 📄 main.dart                                # App Entry Point
```

## Key Features

### 🔐 Authentication
- Email/Password login & registration
- Google Sign-In integration
- Password reset via email
- Persistent auth state

### 💰 Expense Management
- Add, edit, delete expenses
- Category-based organization
- Date filtering
- Search functionality

### 📊 Analytics
- Daily/Weekly/Monthly summaries
- Category breakdown with charts
- Visual spending trends

### 🔄 Offline-First Sync
- Local SQLite storage
- Automatic cloud sync when online
- Manual sync option
- Sync status indicators

## Technology Stack

- **State Management**: flutter_bloc
- **Local Database**: sqflite
- **Cloud Services**: Firebase (Auth, Firestore)
- **Animations**: Lottie
- **Network**: connectivity_plus

## Layer Responsibilities

### 🎯 Core Layer
- Shared resources used across all features
- Services (Auth, Firestore, Sync)
- Repositories (data access abstraction)
- Models (data entities)
- Theme & constants

### 🎯 Features Layer
Each feature follows Clean Architecture with 3 layers:

#### 1. **Data Layer** (`data/`)
- Data sources (API, local DB, cache)
- Repository implementations
- Data models/DTOs

#### 2. **Domain Layer** (`domain/`)
- Business logic
- Domain models (entities)
- Repository interfaces

#### 3. **Presentation Layer** (`presentation/`)
- UI pages
- Widgets
- BLoC (state management)

## BLoC Pattern

```
User Action → Event → Bloc → State → UI Update
```

### Example: Expense Flow
```dart
// Event
class AddExpense extends ExpenseEvent {
  final String title;
  final double amount;
  // ...
}

// State
class ExpenseState {
  final List<Expense> expenses;
  final ExpenseStatus status;
  // ...
}

// Bloc handles business logic
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  // Process events, emit states
}
```

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Adding New Features

1. Create feature folder in `lib/features/`
2. Add `presentation/bloc/`, `presentation/pages/`, `presentation/widgets/`
3. Create BLoC files (bloc, event, state)
4. Implement pages and widgets
5. Register routes in `app_routes.dart`
