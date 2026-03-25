# 🚀 Quick Start Guide - Cattle Management System

## ⚡ 5-Minute Setup

### Step 1: Install Dependencies
```bash
cd cattle_management_system
flutter pub get
```

### Step 2: Run Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 3: Run the App
```bash
flutter run
```

That's it! The app should now be running on your device/emulator.

---

## 📱 What You'll See

### 1. Splash Screen (2 seconds)
- Green background with app logo
- "Cattle Management System" title
- Loading indicator

### 2. Cattle List Screen
- Empty state with "Add Cattle" button
- This demonstrates the BLoC pattern in action

---

## 🎯 Understanding the BLoC Pattern

### How It Works

The app uses **BLoC (Business Logic Component)** pattern with **StreamBuilder** internally:

```dart
// 1. User taps "Add Cattle" button
onPressed: () {
  // 2. Dispatch an event to BLoC
  context.read<CattleBloc>().add(AddCattle(newCattle));
}

// 3. BLoC processes the event
class CattleBloc extends Bloc<CattleEvent, CattleState> {
  on<AddCattle>((event, emit) async {
    emit(CattleLoading());           // Show loading
    await apiCall();                  // Make API call
    emit(CattleAdded(cattle));       // Emit success state
  });
}

// 4. UI rebuilds automatically using BlocBuilder (StreamBuilder)
BlocBuilder<CattleBloc, CattleState>(
  builder: (context, state) {
    if (state is CattleLoading) return LoadingIndicator();
    if (state is CattleAdded) return SuccessMessage();
    if (state is CattleError) return ErrorDisplay();
    return CattleList();
  },
)
```

### Key Benefits
✅ **No setState()** - Cleaner code
✅ **Reactive** - UI updates automatically
✅ **Testable** - Easy to unit test
✅ **Scalable** - Separates business logic from UI
✅ **Maintainable** - Clear data flow

---

## 🏗️ Adding Your First Feature

### Example: Add a "Health Records" Feature

#### 1. Create the folder structure
```bash
lib/features/health/
├── domain/
│   ├── entities/
│   │   └── health_record.dart
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
└── presentation/
    ├── bloc/
    │   ├── health_bloc.dart
    │   ├── health_event.dart
    │   └── health_state.dart
    └── screens/
        └── health_list_screen.dart
```

#### 2. Create the Entity
```dart
// lib/features/health/domain/entities/health_record.dart
import 'package:equatable/equatable.dart';

class HealthRecord extends Equatable {
  final String id;
  final String cattleId;
  final String type; // vaccination, treatment, checkup
  final DateTime date;
  final String description;
  final String? veterinarian;
  
  const HealthRecord({
    required this.id,
    required this.cattleId,
    required this.type,
    required this.date,
    required this.description,
    this.veterinarian,
  });
  
  @override
  List<Object?> get props => [id, cattleId, type, date, description, veterinarian];
}
```

#### 3. Create BLoC Events
```dart
// lib/features/health/presentation/bloc/health_event.dart
abstract class HealthEvent extends Equatable {
  const HealthEvent();
  @override
  List<Object?> get props => [];
}

class LoadHealthRecords extends HealthEvent {
  final String cattleId;
  const LoadHealthRecords(this.cattleId);
  @override
  List<Object?> get props => [cattleId];
}

class AddHealthRecord extends HealthEvent {
  final HealthRecord record;
  const AddHealthRecord(this.record);
  @override
  List<Object?> get props => [record];
}
```

#### 4. Create BLoC States
```dart
// lib/features/health/presentation/bloc/health_state.dart
abstract class HealthState extends Equatable {
  const HealthState();
  @override
  List<Object?> get props => [];
}

class HealthInitial extends HealthState {}

class HealthLoading extends HealthState {}

class HealthRecordsLoaded extends HealthState {
  final List<HealthRecord> records;
  const HealthRecordsLoaded(this.records);
  @override
  List<Object?> get props => [records];
}

class HealthError extends HealthState {
  final String message;
  const HealthError(this.message);
  @override
  List<Object?> get props => [message];
}
```

#### 5. Create the BLoC
```dart
// lib/features/health/presentation/bloc/health_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'health_event.dart';
import 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  HealthBloc() : super(HealthInitial()) {
    on<LoadHealthRecords>(_onLoadHealthRecords);
    on<AddHealthRecord>(_onAddHealthRecord);
  }
  
  Future<void> _onLoadHealthRecords(
    LoadHealthRecords event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());
    try {
      // TODO: Call API
      await Future.delayed(Duration(seconds: 1));
      emit(HealthRecordsLoaded([]));
    } catch (e) {
      emit(HealthError(e.toString()));
    }
  }
  
  Future<void> _onAddHealthRecord(
    AddHealthRecord event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());
    try {
      // TODO: Call API
      await Future.delayed(Duration(seconds: 1));
      // Reload records after adding
      add(LoadHealthRecords(event.record.cattleId));
    } catch (e) {
      emit(HealthError(e.toString()));
    }
  }
}
```

#### 6. Create the Screen
```dart
// lib/features/health/presentation/screens/health_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/health_bloc.dart';
import '../bloc/health_event.dart';
import '../bloc/health_state.dart';

class HealthListScreen extends StatelessWidget {
  final String cattleId;
  
  const HealthListScreen({super.key, required this.cattleId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Health Records')),
      body: BlocProvider(
        create: (context) => HealthBloc()..add(LoadHealthRecords(cattleId)),
        child: BlocBuilder<HealthBloc, HealthState>(
          builder: (context, state) {
            if (state is HealthLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is HealthRecordsLoaded) {
              return ListView.builder(
                itemCount: state.records.length,
                itemBuilder: (context, index) {
                  final record = state.records[index];
                  return ListTile(
                    title: Text(record.type),
                    subtitle: Text(record.description),
                  );
                },
              );
            } else if (state is HealthError) {
              return Center(child: Text(state.message));
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
```

---

## 🔌 Connecting to Backend API

### Step 1: Update API Base URL
```dart
// lib/core/config/app_config.dart
static const String baseUrl = 'https://your-api.com/v1';
```

### Step 2: Create Data Source
```dart
// lib/features/cattle/data/datasources/cattle_remote_datasource.dart
import '../../../../core/network/api_client.dart';
import '../models/cattle_model.dart';

abstract class CattleRemoteDataSource {
  Future<List<CattleModel>> getAllCattle();
  Future<CattleModel> getCattleById(String id);
  Future<CattleModel> addCattle(CattleModel cattle);
}

class CattleRemoteDataSourceImpl implements CattleRemoteDataSource {
  final ApiClient client;
  
  CattleRemoteDataSourceImpl(this.client);
  
  @override
  Future<List<CattleModel>> getAllCattle() async {
    final response = await client.get('/cattle');
    return (response.data as List)
        .map((json) => CattleModel.fromJson(json))
        .toList();
  }
  
  @override
  Future<CattleModel> getCattleById(String id) async {
    final response = await client.get('/cattle/$id');
    return CattleModel.fromJson(response.data);
  }
  
  @override
  Future<CattleModel> addCattle(CattleModel cattle) async {
    final response = await client.post('/cattle', data: cattle.toJson());
    return CattleModel.fromJson(response.data);
  }
}
```

### Step 3: Register in Dependency Injection
```dart
// lib/core/di/injection_container.dart
void _initCattleFeature() {
  // Data sources
  sl.registerLazySingleton<CattleRemoteDataSource>(
    () => CattleRemoteDataSourceImpl(sl()),
  );
  
  // Repository
  sl.registerLazySingleton<CattleRepository>(
    () => CattleRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // BLoC
  sl.registerFactory(() => CattleBloc(repository: sl()));
}
```

---

## 🎨 Customizing the Theme

### Update Colors
```dart
// lib/core/theme/app_theme.dart
static const Color primaryColor = Color(0xFF2E7D32); // Change this
static const Color secondaryColor = Color(0xFFFF6F00); // Change this
```

### Update Fonts
```dart
// Use different Google Fonts
titleTextStyle: GoogleFonts.roboto(  // Change from poppins
  fontSize: 20,
  fontWeight: FontWeight.w600,
),
```

---

## 📝 Common Tasks

### Add a New Screen
1. Create screen file in `features/[feature]/presentation/screens/`
2. Use BlocProvider and BlocBuilder
3. Handle all states (loading, loaded, error, empty)

### Add a New Widget
1. Create widget file in `presentation/widgets/`
2. Make it reusable and configurable
3. Use theme colors and text styles

### Add Form Validation
```dart
import '../../../../core/utils/validators.dart';

CustomTextField(
  label: 'Email',
  validator: Validators.email,
)

CustomTextField(
  label: 'Phone',
  validator: Validators.phone,
)

CustomTextField(
  label: 'Cattle Tag',
  validator: Validators.cattleTag,
)
```

---

## 🐛 Troubleshooting

### Build Runner Issues
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Dependency Conflicts
```bash
flutter pub upgrade
```

### Hot Reload Not Working
```bash
# Stop the app and run again
flutter run
```

---

## 📚 Next Steps

1. ✅ Understand the BLoC pattern
2. ✅ Explore the cattle feature
3. 🔄 Add more features (health, milk, breeding)
4. 🔄 Connect to your backend API
5. 🔄 Customize the theme
6. 🔄 Add multi-language support
7. 🔄 Implement offline sync
8. 🔄 Add unit tests

---

## 💡 Pro Tips

1. **Always use BLoC** - Never use setState()
2. **Handle all states** - Loading, loaded, error, empty
3. **Use const constructors** - Better performance
4. **Follow naming conventions** - Consistency is key
5. **Comment your TODOs** - Track pending work
6. **Test on real devices** - Emulators can be misleading

---

**Happy Coding! 🚀**

For questions, refer to README.md or PROJECT_STRUCTURE.md
