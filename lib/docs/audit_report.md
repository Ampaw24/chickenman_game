# Flutter Code Audit Report: Chickenman Food Match

**Date:** Thursday, March 19, 2026  
**Auditor:** Senior Flutter Software Architect  
**Status:** Pre-production Audit  
**Code Quality Score:** 6.5/10

---

## 1. CRITICAL ISSUES (Must Fix Before Release)

### ISSUE TYPE: Performance / Unnecessary Rebuilds
**SEVERITY: Critical**

**FILE LOCATION:** `lib/features/game/presentation/components/game_board.dart` & `lib/features/game/presentation/screens/game_screen.dart`

**PROBLEM DESCRIPTION:**  
The `GameBoard` widget uses `ref.watch(gameProvider)`. The `gameProvider` state includes a `timeLeft` property which is updated by a periodic timer every second. Consequently, the **entire game board (64 tiles) is rebuilt every second**, even when no game action is performed.

**IMPACT:**  
Massive CPU/GPU overhead. On mid-to-low-end devices, this will lead to significant battery drain, device heating, and potential frame drops (jank) during animations, as the framework must re-evaluate the entire widget tree and its `flutter_animate` configurations every second.

**RECOMMENDED FIX:**  
Split the `GameState` or use `select` to listen only to the grid changes. Alternatively, move the timer to a separate provider and only watch it where needed (e.g., in a specialized `TimerWidget`).

```dart
// Optimized watch in GameBoard
final grid = ref.watch(gameProvider.select((s) => s.grid));
final selectedTile = ref.watch(gameProvider.select((s) => 
  (s.selectedRow, s.selectedCol)));
```

---

## 2. HIGH SEVERITY ISSUES

### ISSUE TYPE: Architecture / State Management Anti-pattern
**SEVERITY: High**

**FILE LOCATION:** `lib/features/game/presentation/components/game_board.dart`

**PROBLEM DESCRIPTION:**  
`ref.listen<GameState>(gameProvider, ...)` is placed directly inside the `build` method to trigger a shake animation. While technically allowed, placing side-effect listeners inside `build` for animations that depend on complex state logic can lead to missed events or redundant triggers if the widget rebuilds for other reasons (like the timer issue mentioned above).

**IMPACT:**  
The shake animation might be triggered multiple times or inconsistently. It also tightly couples the UI animation logic with the global game state in an imperative way inside a declarative `build` method.

**RECOMMENDED FIX:**  
Use a specific `gameEventProvider` (a StreamProvider or a custom notifier) to broadcast events like `BigMatch`, or move the listener to a `ConsumerStatefulWidget`'s `initState` equivalent (though `ref.listen` is usually okay, it should listen to a refined selection).

---

### ISSUE TYPE: Performance / Graphics Overhead
**SEVERITY: High**

**FILE LOCATION:** `lib/features/auth/presentation/screens/auth_screen.dart`

**PROBLEM DESCRIPTION:**  
Excessive use of `BackdropFilter` (Blur) in the `AuthScreen` and its sub-widgets (`_SocialAuthButton`, `_GlassLogo`). `BackdropFilter` requires an off-screen buffer and is one of the most expensive operations in Flutter's Skia/Impeller rendering pipeline.

**IMPACT:**  
Significant frame-rate drops on older Android devices and lower-end iPhones. The combination of a particle animation (60fps) and multiple `BackdropFilter` layers is a "worst-case" scenario for the raster thread.

**RECOMMENDED FIX:**  
Replace `BackdropFilter` with semi-transparent colors or pre-rendered blurred assets for buttons. If blur is essential, use it only once for the entire background rather than per-component.

---

## 3. MEDIUM SEVERITY ISSUES

### ISSUE TYPE: Code Quality / Storage Efficiency
**SEVERITY: Medium**

**FILE LOCATION:** `lib/core/services/storage_service.dart`

**PROBLEM DESCRIPTION:**  
The `redeemVoucher` method performs a linear search (`O(n)`) through the Hive box to find a voucher by ID. It also creates a new `Map` for every entry during the search.

**IMPACT:**  
As the user collects more vouchers, redeeming a voucher will become increasingly slow. This is an anti-pattern for NoSQL databases like Hive, which support key-based access (`O(1)`).

**RECOMMENDED FIX:**  
Use the Voucher ID as the Hive key.
```dart
// Save
await _vouchers.put(voucher.id, voucher.toMap());
// Redeem
final v = _vouchers.get(id);
if (v != null) { ... }
```

---

### ISSUE TYPE: Architecture / Separation of Concerns
**SEVERITY: Medium**

**FILE LOCATION:** `lib/features/game/presentation/providers/game_provider.dart`

**PROBLEM DESCRIPTION:**  
`GameNotifier` is a "God Object" for the game logic. It handles grid generation, move validation, match detection, cascading logic, scoring, and the game timer. 

**IMPACT:**  
Hard to test, difficult to maintain, and violates the Single Responsibility Principle. Testing the match logic requires instantiating the entire `GameNotifier` and its dependencies.

**RECOMMENDED FIX:**  
Inject `MatchDetector` and `ScoreCalculator` through the constructor (Dependency Injection). Move the timer logic to a dedicated `GameTimerNotifier`.

---

### ISSUE TYPE: UI Performance / HUD Rebuilds
**SEVERITY: Medium**

**FILE LOCATION:** `lib/features/game/presentation/screens/game_screen.dart`

**PROBLEM DESCRIPTION:**  
The `_GameHUD` widget watches the entire `GameState`. Like the board, the entire HUD (including the avatar image and nickname text) rebuilds every second because of the `timeLeft` change.

**IMPACT:**  
Unnecessary widget tree diffing. While less expensive than the board rebuild, it's still inefficient.

**RECOMMENDED FIX:**  
Pass only the necessary properties to sub-widgets or use `ref.watch(gameProvider.select(...))`.

---

## 4. LOW SEVERITY & BEST PRACTICES

### ISSUE TYPE: Flutter Best Practices / Const Constructors
**SEVERITY: Low**

**FILE LOCATION:** Multiple files.

**PROBLEM DESCRIPTION:**  
Missing `const` constructors on many static widgets and decorations.

**IMPACT:**  
Slightly higher memory usage and slower rebuilds as the framework cannot optimize these widgets during the build phase.

---

### ISSUE TYPE: Error Handling
**SEVERITY: Low**

**FILE LOCATION:** `lib/core/services/storage_service.dart`

**PROBLEM DESCRIPTION:**  
`Hive.openBox` calls are not wrapped in try-catch blocks. If the database file is corrupted, the app will crash on startup.

**IMPACT:**  
Poor user experience in case of rare file-system errors.

---

## FINAL SUMMARY

### Overall Code Quality Score: 6.5 / 10

The codebase is well-structured and uses modern libraries (Riverpod, GoRouter, Hive). The UI is visually impressive with high-quality animations. However, the performance architecture in the core game loop is currently suboptimal for production release.

### Top 5 Critical Issues to Fix Immediately:
1.  **Stop full-board rebuilds** on every timer tick (use `select` or split providers).
2.  **Optimize `BackdropFilter`** usage in `AuthScreen` to avoid jank on low-end devices.
3.  **Refactor `StorageService`** to use key-based access for vouchers instead of linear searches.
4.  **Decouple Timer Logic** from `GameNotifier` to improve maintainability and performance.
5.  **Implement proper Dependency Injection** for domain services (`MatchDetector`, etc.) to enable unit testing.

### Architecture Improvement Recommendations:
- Transition from `StateNotifier` to `AsyncNotifier` or `Notifier` (Riverpod 2.0 style) for better asynchronous handling.
- Create a `Domain` layer for the Game that is completely independent of Riverpod, making the core logic pure Dart and easily testable.

### Performance Improvement Opportunities:
- Use `RepaintBoundary` around the `GameBoard` to isolate its paint operations from the HUD.
- Pre-cache avatar images in the splash screen to avoid flickering when the game starts.
