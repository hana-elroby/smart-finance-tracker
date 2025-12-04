# Clean Architecture Structure

## Current Project Organization

```
lib/
│
├── 📁 core/                                    # SHARED RESOURCES
│   │
│   ├── 📁 constants/                           # App-wide constants
│   │   └── 📄 app_constants.dart              # App name, durations, paths
│   │
│   ├── 📁 routes/                              # Navigation
│   │   └── 📄 app_routes.dart                 # Route constants
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
│   │       ├── 📁 pages/
│   │       │   └── 📄 splash_page.dart
│   │       └── 📁 widgets/
│   │           └── 📄 analytics_chart_icon.dart
│   │
│   ├── 📁 onboarding/                          # Onboarding Feature
│   │   ├── 📁 data/                            # Data Layer
│   │   │   └── 📄 onboarding_data.dart
│   │   │
│   │   ├── 📁 domain/                          # Domain Layer
│   │   │   └── 📁 models/
│   │   │       └── 📄 onboarding_model.dart
│   │   │
│   │   └── 📁 presentation/                    # Presentation Layer
│   │       ├── 📁 pages/
│   │       │   └── 📄 onboarding_page.dart
│   │       └── 📁 widgets/
│   │           ├── 📄 onboarding_button.dart
│   │           ├── 📄 onboarding_page_item.dart
│   │           └── 📄 page_indicator.dart
│   │
│   └── 📁 home/                                # Home Feature
│       └── 📁 presentation/
│           └── 📁 pages/
│               └── 📄 home_page.dart
│
└── 📄 main.dart                                # App Entry Point
```

## Layer Responsibilities

### 🎯 Core Layer
- **Purpose**: Shared resources used across all features
- **Contains**:
  - Theme configuration
  - App constants
  - Common utilities
  - Navigation helpers
  - Shared widgets (when needed)

### 🎯 Features Layer
Each feature follows Clean Architecture with 3 layers:

#### 1. **Data Layer** (`data/`)
- Data sources (API, local DB, cache)
- Repository implementations
- Data models/DTOs
- Data transformations

#### 2. **Domain Layer** (`domain/`)
- Business logic
- Domain models (entities)
- Repository interfaces
- Use cases

#### 3. **Presentation Layer** (`presentation/`)
- UI pages
- Widgets
- State management (BLoC, Provider, etc.)
- View models

## Benefits of This Structure

### ✅ Scalability
- Add new features without touching existing code
- Each feature is independent and self-contained

### ✅ Maintainability
- Clear organization makes code easy to find
- Separation of concerns simplifies debugging
- Changes are localized to specific layers

### ✅ Testability
- Each layer can be tested independently
- Mock dependencies easily
- Unit test business logic without UI

### ✅ Reusability
- Core utilities shared across features
- Widgets can be reused within features
- Clean separation prevents duplication

### ✅ Team Collaboration
- Multiple developers can work on different features
- Clear boundaries reduce merge conflicts
- Consistent structure aids onboarding

## Adding New Features

### Example: Adding a "Transactions" Feature

```
lib/features/transactions/
├── data/
│   ├── datasources/
│   │   ├── transaction_local_datasource.dart
│   │   └── transaction_remote_datasource.dart
│   ├── models/
│   │   └── transaction_dto.dart
│   └── repositories/
│       └── transaction_repository_impl.dart
│
├── domain/
│   ├── models/
│   │   └── transaction.dart
│   ├── repositories/
│   │   └── transaction_repository.dart
│   └── usecases/
│       ├── get_transactions.dart
│       └── add_transaction.dart
│
└── presentation/
    ├── pages/
    │   ├── transactions_list_page.dart
    │   └── add_transaction_page.dart
    ├── widgets/
    │   ├── transaction_card.dart
    │   └── transaction_filter.dart
    └── bloc/ (or provider/)
        ├── transactions_bloc.dart
        ├── transactions_event.dart
        └── transactions_state.dart
```

## Import Guidelines

### ✅ Good Imports (Relative within feature)
```dart
// Within same feature
import '../widgets/my_widget.dart';
import '../../domain/models/my_model.dart';
```

### ✅ Good Imports (Cross-feature via core)
```dart
// From core
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
```

### ❌ Bad Imports (Cross-feature direct)
```dart
// DON'T import directly from other features
import '../../transactions/domain/models/transaction.dart'; // ❌
```

## File Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `camelCase` or `SCREAMING_SNAKE_CASE`

## Code Organization Rules

1. **One class per file** (with related helpers)
2. **Pages** contain screen-level widgets
3. **Widgets** are reusable components
4. **Models** are immutable data classes
5. **Constants** group related values
