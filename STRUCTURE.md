# SaveIt - Finance Tracker App

A Flutter finance tracking application with clean architecture and best practices.

## 📁 Project Structure

The project follows **Clean Architecture** principles with feature-based organization:

```
lib/
├── core/                          # Shared resources across features
│   ├── constants/                 # App-wide constants
│   │   └── app_constants.dart     # App name, durations, asset paths
│   ├── routes/                    # Navigation routes
│   │   └── app_routes.dart        # Route definitions
│   ├── theme/                     # App theming
│   │   ├── app_colors.dart        # Color palette
│   │   └── app_theme.dart         # Theme configuration
│   └── utils/                     # Utility functions
│       └── navigation_helper.dart # Navigation utilities
│
├── features/                      # Feature modules
│   ├── splash/                    # Splash screen feature
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── splash_page.dart
│   │       └── widgets/
│   │           └── analytics_chart_icon.dart
│   │
│   ├── onboarding/                # Onboarding feature
│   │   ├── data/                  # Data layer
│   │   │   └── onboarding_data.dart
│   │   ├── domain/                # Domain layer
│   │   │   └── models/
│   │   │       └── onboarding_model.dart
│   │   └── presentation/          # Presentation layer
│   │       ├── pages/
│   │       │   └── onboarding_page.dart
│   │       └── widgets/
│   │           ├── onboarding_button.dart
│   │           ├── onboarding_page_item.dart
│   │           └── page_indicator.dart
│   │
│   └── home/                      # Home feature
│       └── presentation/
│           └── pages/
│               └── home_page.dart
│
└── main.dart                      # App entry point
```

## 🏗️ Architecture

### Clean Architecture Layers

1. **Core Layer**: Shared resources used across all features
   - Constants
   - Theme configuration
   - Utilities
   - Common widgets (if needed)

2. **Features Layer**: Each feature is self-contained with:
   - **Data**: Data sources, repositories implementation
   - **Domain**: Business logic, models, repository interfaces
   - **Presentation**: UI pages, widgets, and state management

### Benefits

✅ **Separation of Concerns**: Each layer has a specific responsibility  
✅ **Scalability**: Easy to add new features without affecting existing code  
✅ **Maintainability**: Code is organized and easy to locate  
✅ **Testability**: Each layer can be tested independently  
✅ **Reusability**: Shared code is in core, feature-specific code is isolated  

## 🎨 Features

### Splash Screen
- Animated logo with custom chart icon
- Smooth transitions and animations
- Auto-navigation to onboarding

### Onboarding
- 3 informative pages with Lottie animations
- Smooth page transitions
- Skip and back navigation
- Animated buttons with pulse effects

### Home
- Main application screen
- Ready for feature expansion

## 🚀 Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

## 📦 Dependencies

- `lottie`: For animated illustrations
- `flutter/material`: Core Flutter framework

## 🎯 Next Steps

To add a new feature:

1. Create a new folder in `lib/features/`
2. Add subdirectories: `data/`, `domain/`, `presentation/`
3. Create `pages/` and `widgets/` in `presentation/`
4. Follow the same structure as existing features

## 📝 Code Style

- Follow Flutter/Dart style guide
- Use const constructors where possible
- Extract widgets into separate files for reusability
- Keep business logic separate from UI
