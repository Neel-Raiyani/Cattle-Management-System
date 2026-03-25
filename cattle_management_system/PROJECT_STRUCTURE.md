# 📁 Project Structure

## Complete Folder Organization

```
cattle_management_system/
│
├── android/                        # Android native code
├── ios/                           # iOS native code
├── web/                           # Web support files
├── windows/                       # Windows support files
├── linux/                         # Linux support files
├── macos/                         # macOS support files
│
├── assets/                        # Static assets
│   ├── images/                   # Image assets
│   │   ├── logos/               # App logos
│   │   ├── icons/               # Custom icons
│   │   ├── cattle/              # Cattle images
│   │   └── backgrounds/         # Background images
│   ├── icons/                    # Icon files
│   ├── animations/               # Lottie animations
│   └── fonts/                    # Custom fonts
│
├── lib/                          # Main source code
│   │
│   ├── core/                     # Core functionality (shared across features)
│   │   │
│   │   ├── config/              # Configuration files
│   │   │   └── app_config.dart  # App constants and settings
│   │   │
│   │   ├── theme/               # App theming
│   │   │   └── app_theme.dart   # Material 3 theme configuration
│   │   │
│   │   ├── di/                  # Dependency Injection
│   │   │   └── injection_container.dart  # GetIt service locator
│   │   │
│   │   ├── error/               # Error handling
│   │   │   ├── failures.dart    # Failure classes (domain layer)
│   │   │   └── exceptions.dart  # Exception classes (data layer)
│   │   │
│   │   ├── network/             # Network layer
│   │   │   ├── api_client.dart  # Dio HTTP client wrapper
│   │   │   └── network_info.dart # Connectivity checker
│   │   │
│   │   └── utils/               # Utility classes
│   │       ├── validators.dart  # Form validation functions
│   │       ├── date_time_utils.dart # Date/time formatting
│   │       ├── string_utils.dart    # String helpers (TODO)
│   │       └── number_utils.dart    # Number formatting (TODO)
│   │
│   ├── features/                # Feature modules (Clean Architecture)
│   │   │
│   │   ├── cattle/             # Cattle Management Feature
│   │   │   ├── domain/         # Business logic layer
│   │   │   │   ├── entities/   # Domain entities (pure Dart)
│   │   │   │   │   └── cattle.dart
│   │   │   │   ├── repositories/    # Repository interfaces (TODO)
│   │   │   │   │   └── cattle_repository.dart
│   │   │   │   └── usecases/        # Use cases (TODO)
│   │   │   │       ├── get_all_cattle.dart
│   │   │   │       ├── get_cattle_by_id.dart
│   │   │   │       ├── add_cattle.dart
│   │   │   │       ├── update_cattle.dart
│   │   │   │       └── delete_cattle.dart
│   │   │   │
│   │   │   ├── data/           # Data layer
│   │   │   │   ├── models/     # Data models (JSON serializable)
│   │   │   │   │   └── cattle_model.dart
│   │   │   │   ├── datasources/     # Data sources (TODO)
│   │   │   │   │   ├── cattle_remote_datasource.dart
│   │   │   │   │   └── cattle_local_datasource.dart
│   │   │   │   └── repositories/    # Repository implementations (TODO)
│   │   │   │       └── cattle_repository_impl.dart
│   │   │   │
│   │   │   └── presentation/   # UI layer
│   │   │       ├── bloc/       # BLoC state management
│   │   │       │   ├── cattle_bloc.dart
│   │   │       │   ├── cattle_event.dart
│   │   │       │   └── cattle_state.dart
│   │   │       ├── screens/    # UI screens
│   │   │       │   ├── cattle_list_screen.dart
│   │   │       │   ├── cattle_detail_screen.dart (TODO)
│   │   │       │   ├── add_cattle_screen.dart (TODO)
│   │   │       │   └── edit_cattle_screen.dart (TODO)
│   │   │       └── widgets/    # Feature-specific widgets (TODO)
│   │   │           ├── cattle_card.dart
│   │   │           └── cattle_filter_sheet.dart
│   │   │
│   │   ├── health/             # Health Records Feature (TODO)
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │
│   │   ├── milk/               # Milk Production Feature (TODO)
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │
│   │   ├── breeding/           # Breeding Management Feature (TODO)
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │
│   │   ├── feed/               # Feed Management Feature (TODO)
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │
│   │   ├── financial/          # Financial Tracking Feature (TODO)
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │
│   │   ├── reports/            # Reports & Analytics Feature (TODO)
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │
│   │   └── auth/               # Authentication Feature (TODO)
│   │       ├── domain/
│   │       ├── data/
│   │       └── presentation/
│   │
│   ├── presentation/           # Shared UI components
│   │   └── widgets/           # Reusable widgets
│   │       ├── buttons.dart   # Button widgets
│   │       ├── input_fields.dart # Input widgets
│   │       ├── state_widgets.dart # Loading/Error/Empty states
│   │       ├── cards.dart     # Card widgets (TODO)
│   │       ├── dialogs.dart   # Dialog widgets (TODO)
│   │       └── bottom_sheets.dart # Bottom sheet widgets (TODO)
│   │
│   └── main.dart              # App entry point
│
├── test/                      # Unit and widget tests (TODO)
│   ├── core/
│   ├── features/
│   └── presentation/
│
├── integration_test/          # Integration tests (TODO)
│
├── .gitignore                # Git ignore rules
├── pubspec.yaml              # Dependencies and assets
├── pubspec.lock              # Locked dependencies
├── analysis_options.yaml     # Linter rules
└── README.md                 # Project documentation
```

## 📝 File Naming Conventions

### Dart Files
- **Snake case**: `cattle_list_screen.dart`
- **Descriptive names**: `cattle_remote_datasource.dart`

### Classes
- **Pascal case**: `CattleListScreen`
- **Descriptive**: `CattleRemoteDataSource`

### Variables & Functions
- **Camel case**: `cattleList`, `getCattleById()`
- **Descriptive**: `isLoading`, `onCattleSelected()`

### Constants
- **Camel case**: `primaryColor`
- **Static const**: `static const String baseUrl`

## 🎯 Layer Responsibilities

### Domain Layer (Business Logic)
- **Entities**: Pure Dart classes, no dependencies
- **Repositories**: Interfaces only (abstract classes)
- **Use Cases**: Single responsibility business logic

### Data Layer
- **Models**: Extend entities, add JSON serialization
- **Data Sources**: API calls, local database operations
- **Repositories**: Implement domain repository interfaces

### Presentation Layer
- **BLoC**: State management, business logic orchestration
- **Screens**: UI composition, BLoC integration
- **Widgets**: Reusable UI components

## 🔄 Data Flow

```
UI (Screen)
    ↓ dispatch event
BLoC (Event Handler)
    ↓ call use case
Use Case (Business Logic)
    ↓ call repository
Repository (Data Orchestration)
    ↓ check network
    ├─→ Remote Data Source (API) → Server
    └─→ Local Data Source (Cache) → Database
    ↓ return data
BLoC (State Emission)
    ↓ emit state
UI (Screen) - Rebuild with new state
```

## 📦 Feature Module Template

When creating a new feature, follow this structure:

```
features/
└── your_feature/
    ├── domain/
    │   ├── entities/
    │   │   └── your_entity.dart
    │   ├── repositories/
    │   │   └── your_repository.dart
    │   └── usecases/
    │       ├── get_all_items.dart
    │       ├── get_item_by_id.dart
    │       ├── add_item.dart
    │       ├── update_item.dart
    │       └── delete_item.dart
    ├── data/
    │   ├── models/
    │   │   └── your_model.dart
    │   ├── datasources/
    │   │   ├── your_remote_datasource.dart
    │   │   └── your_local_datasource.dart
    │   └── repositories/
    │       └── your_repository_impl.dart
    └── presentation/
        ├── bloc/
        │   ├── your_bloc.dart
        │   ├── your_event.dart
        │   └── your_state.dart
        ├── screens/
        │   ├── list_screen.dart
        │   ├── detail_screen.dart
        │   ├── add_screen.dart
        │   └── edit_screen.dart
        └── widgets/
            └── custom_widgets.dart
```

## 🚀 Next Steps

1. ✅ Core architecture setup
2. ✅ Cattle feature (basic structure)
3. 🔄 Complete Cattle feature with API integration
4. 🔄 Add Health Records feature
5. 🔄 Add Milk Production feature
6. 🔄 Add Breeding Management feature
7. 🔄 Add Feed Management feature
8. 🔄 Add Financial Tracking feature
9. 🔄 Add Reports & Analytics feature
10. 🔄 Add Authentication feature
11. 🔄 Add multi-language support
12. 🔄 Add offline sync
13. 🔄 Add unit tests
14. 🔄 Add integration tests

---

**Remember**: Always follow Clean Architecture principles and use BLoC pattern for state management. No `setState()` allowed!
