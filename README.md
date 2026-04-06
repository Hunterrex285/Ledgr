# Ledgr 💰

A personal finance tracking application built with Flutter, following Clean Architecture principles with a focus on structured code, efficient state management, and a polished user experience.

---

## Features

### Dashboard
- Personalised greeting based on time of day
- Wallet balance card showing monthly net balance
- Income vs expense summary for the current month
- Recent activity feed grouped by date (Today / Yesterday / older)

### Transactions
- Add income and expense transactions with title, amount, category, date, and notes
- Recurring transaction flag for monthly repeats
- Swipe to delete with instant UI feedback
- Transactions grouped by date with category-coloured avatars

### Budget
- Set monthly spending limits per category
- Live progress bars showing spent vs limit per category
- Hero card showing total remaining budget and days left in the month
- Automatic over-budget indicator (turns red at 80% and beyond)
- Add and remove budgets via bottom sheet

### Analytics
- Total monthly spending with week-over-week % change
- 6-month expense trend line chart
- Month selector to browse historical data
- Category breakdown list for the selected month

### IOUs
- Track money lent and borrowed with person name, amount, date, and optional note
- Separate "You lent" and "You owe" summary cards
- Mark entries as settled with one tap
- Settled and active IOUs shown in separate sections
- Swipe to delete

---

## Architecture

Ledgr follows **Clean Architecture** with a feature-first folder structure. Each feature is self-contained across three layers.

```
lib/
├── core/
│   ├── di/                         # Dependency injection
│   │   └── injection_container.dart
│   ├── navigation/
│   │   └── app_router.dart         # GoRouter with StatefulShellRoute
│   └── shell/
│       └── main_shell.dart         # Bottom navigation shell
│
└── features/
    ├── dashboard/
    │   └── presentation/
    │       ├── screens/
    │       └── widgets/
    ├── transactions/
    │   ├── domain/
    │   │   ├── entities/           # Pure Dart models (Transaction, TransactionType)
    │   │   ├── repositories/       # Abstract contracts
    │   │   └── usecases/           # One class per action
    │   ├── data/
    │   │   ├── models/             # Hive models with type adapters
    │   │   ├── datasources/        # Direct Hive box interactions
    │   │   └── repositories/       # Concrete implementations
    │   └── presentation/
    │       ├── providers/          # Riverpod Notifier + derived providers
    │       ├── screens/
    │       └── widgets/
    ├── budget/                     # Same structure as transactions
    ├── analytics/                  # Presentation only — derives from transactions
    └── iou/                        # Same structure as transactions
```

### Layer responsibilities

| Layer | Knows about | Does not know about |
|---|---|---|
| Domain | Nothing external | Hive, Flutter, Riverpod |
| Data | Hive, domain models | Flutter widgets, providers |
| Presentation | Flutter, Riverpod, domain entities | Hive, datasources |

### Data flow

```
UI (screen)
  → Notifier (Riverpod)
    → Use Case (domain)
      → Repository interface (domain)
        → Repository impl (data)
          → Local DataSource
            → Hive Box (disk)
```

State updates instantly in memory. Hive persists in the background. The UI never waits for disk I/O.

---

## Tech Stack

| Concern | Package |
|---|---|
| State management | `flutter_riverpod` — `Notifier` + `NotifierProvider` |
| Local storage | `hive_flutter` |
| Navigation | `go_router` (v17) with `StatefulShellRoute` |
| Charts | `fl_chart` |
| Unique IDs | `uuid` |
| Equality | `equatable` |
| Code generation | `build_runner` + `hive_generator` |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter plugin

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/your-username/ledgr.git
cd ledgr
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Generate Hive type adapters**

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates `*.g.dart` files for all Hive models. You must run this before the app will compile.

**4. Run the app**

```bash
flutter run
```

---

## State Management

Ledgr uses Riverpod 2.x with the modern `Notifier` pattern.

- `TransactionNotifier` — holds `List<Transaction>` in memory, syncs to Hive on mutations
- `BudgetNotifier` — holds `List<Budget>` in memory
- `IouNotifier` — holds `List<Iou>` in memory
- `monthlySpendingByCategoryProvider` — derived from transactions, used by budget screen
- `last6MonthsProvider` — derived from transactions, used by analytics screen
- `iouSummaryProvider` — derived from IOUs, shows lent/borrowed totals

All derived providers are computed in real time. There is no duplication of financial data across providers — transactions are the single source of truth for all money-related calculations.

---

## Dependency Injection

All dependencies are wired at app startup in `injection_container.dart` and injected into Riverpod via `ProviderScope` overrides. No service locator or global singletons.

```
Hive Box → DataSource → Repository → UseCase → Provider override
```

---

## Folder Naming Conventions

| Folder | Contains |
|---|---|
| `entities/` | Pure Dart classes, no external dependencies |
| `repositories/` | Abstract interfaces in domain, concrete impls in data |
| `usecases/` | One file per action, one public `call()` method |
| `models/` | Hive-annotated versions of domain entities |
| `datasources/` | Direct storage calls, nothing else |
| `providers/` | Riverpod notifiers and derived providers |
| `screens/` | Full-page `ConsumerWidget` classes |
| `widgets/` | Reusable UI components scoped to a feature |

---

## Running on Different Platforms

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Chrome (useful for development on Windows)
flutter run -d chrome

# Release APK
flutter build apk --release
```

The release APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

---

## Known Limitations

- Categories are currently hardcoded strings. A full category management screen is planned.
- Analytics month selector uses a date picker — a horizontal scroll month picker is planned.
- No cloud sync — all data is stored locally on device.
- No authentication — the app is single-user by design.

---

## Project Structure Decisions

**Why Notifier over StateNotifier?**
`StateNotifier` is deprecated in Riverpod 2.x. `Notifier` is the modern equivalent and removes the need for constructor injection — dependencies are accessed via `ref.read()` inside the class.

**Why not AsyncNotifier for local storage?**
Hive operations are async but nearly instantaneous. Using `AsyncNotifier` would introduce loading states that flash and disappear too quickly to be useful. Instead, state updates in memory synchronously and Hive persists in the background, giving the UI instant feedback without spinner noise.

**Why feature-first over layer-first folders?**
Feature-first (`features/transactions/domain/`) keeps all related code together. A reviewer or new developer can understand a full feature by looking at one folder tree rather than jumping between top-level `domain/`, `data/`, and `presentation/` folders.

---

## License

MIT