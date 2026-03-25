# 🐄 Cattle Management System - Flutter Frontend

A production-grade Flutter mobile application for managing cattle in gaushalas, dairy farms, and livestock facilities.

## 📱 Project Overview

This is a **frontend-only** Flutter application built with **Clean Architecture** and **BLoC pattern** for state management. The app is designed to integrate with backend APIs seamlessly.

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/
├── core/                          # Core functionality
│   ├── config/                    # App configuration
│   │   └── app_config.dart       # Constants and settings
│   ├── theme/                     # App theming
│   │   └── app_theme.dart        # Material 3 theme
│   ├── di/                        # Dependency Injection
│   │   └── injection_container.dart
│   ├── error/                     # Error handling
│   │   ├── failures.dart         # Failure classes
│   │   └── exceptions.dart       # Exception classes
│   ├── network/                   # Network layer
│   │   ├── api_client.dart       # Dio HTTP client
│   │   └── network_info.dart     # Connectivity checker
│   └── utils/                     # Utilities
│       ├── validators.dart       # Form validators
│       └── date_time_utils.dart  # Date/time helpers
│
├── features/                      # Feature modules
│   └── cattle/                    # Cattle management feature
│       ├── domain/                # Business logic layer
│       │   └── entities/         # Domain entities
│       │       └── cattle.dart
│       ├── data/                  # Data layer
│       │   ├── models/           # Data models
│       │   │   └── cattle_model.dart
│       │   ├── datasources/      # Data sources (TODO)
│       │   └── repositories/     # Repository implementations (TODO)
│       └── presentation/          # UI layer
│           ├── bloc/             # BLoC state management
│           │   ├── cattle_bloc.dart
│           │   ├── cattle_event.dart
│           │   └── cattle_state.dart
│           └── screens/          # UI screens
│               └── cattle_list_screen.dart
│
├── presentation/                  # Shared UI components
│   └── widgets/                   # Reusable widgets
│       ├── buttons.dart          # Button widgets
│       ├── input_fields.dart     # Input widgets
│       └── state_widgets.dart    # Loading/Error/Empty states
│
└── main.dart                      # App entry point
```

## 🎯 Key Features (Planned)

### Core Modules
- ✅ **Cattle Management** - Register, update, track cattle
- 🔄 **Health Records** - Medical history, vaccinations, treatments
- 🔄 **Milk Production** - Daily milk tracking and analytics
- 🔄 **Breeding Management** - Breeding cycles, pregnancy tracking
- 🔄 **Feed Management** - Feed inventory and distribution
- 🔄 **Financial Tracking** - Expenses, income, reports
- 🔄 **Reports & Analytics** - Visual charts and insights
- 🔄 **User Management** - Multi-role support

### Technical Features
- ✅ **BLoC Pattern** - Reactive state management
- ✅ **Clean Architecture** - Separation of concerns
- ✅ **Offline-First** - Local caching with Hive
- ✅ **Responsive Design** - ScreenUtil for all devices
- ✅ **Material 3** - Modern UI design
- ✅ **Form Validation** - Comprehensive validators
- 🔄 **Multi-language** - English, Hindi, Gujarati
- 🔄 **QR Code Scanning** - Cattle tagging
- 🔄 **PDF Reports** - Generate and share reports
- 🔄 **Image Upload** - Cattle photos

## 🛠️ Tech Stack

### State Management
- **flutter_bloc** (^8.1.6) - BLoC pattern implementation
- **equatable** (^2.0.5) - Value equality

### Networking
- **dio** (^5.4.0) - HTTP client
- **pretty_dio_logger** (^1.4.0) - API logging

### Local Storage
- **hive** (^2.2.3) - NoSQL database
- **sqflite** (^2.3.0) - SQLite database
- **shared_preferences** (^2.2.0) - Key-value storage

### UI & Design
- **google_fonts** (^6.1.0) - Custom fonts
- **flutter_screenutil** (^5.9.0) - Responsive design
- **shimmer** (^3.0.0) - Loading animations
- **lottie** (^3.1.0) - Animations
- **cached_network_image** (^3.3.0) - Image caching

### Utilities
- **get_it** (^7.6.0) - Dependency injection
- **logger** (^2.0.0) - Logging
- **connectivity_plus** (^6.0.0) - Network status
- **permission_handler** (^11.0.0) - Permissions

### Code Generation
- **build_runner** (^2.4.0)
- **json_serializable** (^6.7.0)
- **hive_generator** (^2.0.0)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.10.4)
- Dart SDK
- Android Studio / VS Code
- Android SDK / Xcode

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd cattle_management_system
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run code generation** (when models are added)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run the app**
```bash
flutter run
```

## 📝 Development Guidelines

### BLoC Pattern Usage

**NO setState()** - Use BLoC events and states instead:

```dart
// ❌ DON'T DO THIS
setState(() {
  _counter++;
});

// ✅ DO THIS
context.read<CounterBloc>().add(IncrementCounter());
```

### StreamBuilder Pattern

Use `BlocBuilder` which internally uses StreamBuilder:

```dart
BlocBuilder<CattleBloc, CattleState>(
  builder: (context, state) {
    if (state is CattleLoading) {
      return LoadingIndicator();
    } else if (state is CattleListLoaded) {
      return ListView.builder(...);
    } else if (state is CattleError) {
      return ErrorDisplay(message: state.message);
    }
    return SizedBox.shrink();
  },
)
```

### Adding a New Feature

1. **Create feature folder structure**
```
features/
└── your_feature/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    ├── data/
    │   ├── models/
    │   ├── datasources/
    │   └── repositories/
    └── presentation/
        ├── bloc/
        ├── screens/
        └── widgets/
```

2. **Create entity** (domain/entities/)
```dart
class YourEntity extends Equatable {
  final String id;
  final String name;
  
  const YourEntity({required this.id, required this.name});
  
  @override
  List<Object?> get props => [id, name];
}
```

3. **Create BLoC** (presentation/bloc/)
- Create events (your_event.dart)
- Create states (your_state.dart)
- Create bloc (your_bloc.dart)

4. **Create UI** (presentation/screens/)
- Use BlocProvider and BlocBuilder
- Handle all states (loading, loaded, error, empty)

5. **Register dependencies** (core/di/injection_container.dart)

## 🎨 Design System

### Colors
- **Primary**: Green (#2E7D32) - Agriculture theme
- **Secondary**: Orange (#FF6F00) - Warmth
- **Success**: Green (#4CAF50)
- **Error**: Red (#F44336)
- **Warning**: Orange (#FF9800)
- **Info**: Blue (#2196F3)

### Cattle Status Colors
- **Healthy**: Green (#4CAF50)
- **Sick**: Red (#F44336)
- **Pregnant**: Purple (#9C27B0)
- **Dry**: Brown (#795548)

### Typography
- **Headings**: Poppins (Bold/SemiBold)
- **Body**: Inter (Regular/Medium)

### Spacing
- Use multiples of 4: 4, 8, 12, 16, 24, 32, 48, 64

## 🔌 API Integration (TODO)

### Base URL Configuration
Update in `lib/core/config/app_config.dart`:
```dart
static const String baseUrl = 'https://your-api.com/v1';
```

### Creating API Endpoints

1. **Create data source interface**
```dart
abstract class CattleRemoteDataSource {
  Future<List<CattleModel>> getAllCattle();
  Future<CattleModel> getCattleById(String id);
  Future<CattleModel> addCattle(CattleModel cattle);
}
```

2. **Implement data source**
```dart
class CattleRemoteDataSourceImpl implements CattleRemoteDataSource {
  final ApiClient client;
  
  @override
  Future<List<CattleModel>> getAllCattle() async {
    final response = await client.get('/cattle');
    return (response.data as List)
        .map((json) => CattleModel.fromJson(json))
        .toList();
  }
}
```

3. **Create repository**
4. **Create use cases**
5. **Inject into BLoC**

## 📦 Build & Release

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🧪 Testing (TODO)

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📄 License

[Add your license here]

## 👥 Contributors

[Add contributors here]

## 📞 Support

For issues and questions, please contact [your-email@example.com]

---

**Note**: This is a frontend-only application. Backend API integration is pending and marked with TODO comments throughout the codebase.
