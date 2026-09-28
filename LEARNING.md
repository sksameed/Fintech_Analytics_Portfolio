# CredLite — Learning & Interview Guide 🎓

This guide explains how CredLite is engineered and prepares you for technical discussions in a Flutter interview at CRED.

---

## 1. Suggested Reading Order

1. [`lib/theme.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/theme.dart): Design tokens, colors, 8-pt spacing, typography, and neumorphic shadows.
2. [`lib/models.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/models.dart): Data models with hand-written `fromJson`/`toJson` (zero code generation).
3. [`lib/api_service.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/api_service.dart): Dio network client handling endpoints, query parameters, and error handling.
4. [`lib/local_store.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/local_store.dart): Hive CE wrapper storing JSON strings for zero-adapter offline storage.
5. [`lib/app_state.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/app_state.dart): Central `ChangeNotifier` driving the cache-first then refresh flow.
6. [`lib/main.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/main.dart): Storage initialization, Provider injection, and bottom navigation.
7. [`lib/widgets/credit_card_widget.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/widgets/credit_card_widget.dart): Explicit `AnimationController` and `Matrix4` 3D card flip.
8. [`lib/screens/home_screen.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/screens/home_screen.dart): Card carousel with `RepaintBoundary` and live countdown timer.
9. [`lib/screens/transactions_screen.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/screens/transactions_screen.dart): Search, category chips, pull-to-refresh, error states.
10. [`lib/analytics.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/analytics.dart): Pure spend aggregation and background `Isolate.run` execution.
11. [`lib/screens/analytics_screen.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/screens/analytics_screen.dart): `fl_chart` charts and real stopwatch performance benchmark.
12. [`lib/widgets/scratch_card.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/widgets/scratch_card.dart): Custom scratch canvas with `saveLayer` and `BlendMode.clear`.
13. [`lib/screens/rewards_screen.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/screens/rewards_screen.dart): 2-column scratch cards grid with persistent unlock state.
14. [`test/app_test.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/test/app_test.dart): Unit and widget tests with zero third-party mocking libraries.

---

## 2. Core Flutter Concepts Used

- **StatefulWidget Lifecycle**: Initializing controllers and timers in `initState()`, cancelling them in `dispose()` ([`home_screen.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/screens/home_screen.dart), [`credit_card_widget.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/widgets/credit_card_widget.dart)).
- **ChangeNotifier + Provider**: Central reactive state with clean `context.watch()` for rebuilds and `context.read()` for event callbacks ([`app_state.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/app_state.dart)).
- **REST via Dio**: Timeouts, query params, and structured error catching ([`api_service.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/api_service.dart)).
- **Hive CE Persistence**: Fast NoSQL key-value caching using plain JSON strings without adapters ([`local_store.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/local_store.dart)).
- **Background Isolates**: Dart's modern `Isolate.run` offloading heavy aggregation to worker threads ([`analytics.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/analytics.dart)).
- **Custom Shaders & Canvas**: `CustomPainter`, `canvas.saveLayer()`, and `BlendMode.clear` erasing paths ([`scratch_card.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/widgets/scratch_card.dart)).
- **3D Transform Math**: `Matrix4` perspective `setEntry(3, 2, 0.001)` for authentic credit card flips ([`credit_card_widget.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/widgets/credit_card_widget.dart)).

---

## 3. 12 Key Interview Questions & Concise Answers

### Q1: How is the offline-first caching implemented?
**A:** In [`app_state.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/app_state.dart#L39-L58), `load()` reads cached JSON strings from Hive via `LocalStore` and calls `notifyListeners()` instantly. It then triggers an asynchronous network refresh via `ApiService`, updating both the UI and local store upon completion.

### Q2: Why store JSON strings in Hive rather than using Hive TypeAdapters?
**A:** Avoids heavy build tools (`build_runner`), prevents database migration issues, and ensures every line of serialization is explicit, transparent, and easy to explain ([`local_store.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/local_store.dart#L25-L68)).

### Q3: Why execute data aggregation in an isolate instead of async/await on the main thread?
**A:** Dart is single-threaded; `async/await` only prevents I/O blocking, not CPU-bound calculation. Processing 5,000 transactions on the main thread causes UI frame drops (jank). `Isolate.run` runs on a separate OS thread ([`analytics.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/analytics.dart#L49-L52)).

### Q4: Why might the main thread be faster than an isolate for small transaction counts?
**A:** Spawning or delegating to an isolate incurs a fixed initialization and memory copying overhead. For small arrays, this overhead exceeds calculation time, which our real stopwatch benchmark truthfully highlights ([`analytics.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/analytics.dart#L54-L71)).

### Q5: How does the 3D card flip animation prevent text from being mirrored on the reverse?
**A:** In [`credit_card_widget.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/widgets/credit_card_widget.dart#L60-L70), once rotation passes 90° (0.5 progress), the back widget is rendered with an internal counter-rotation `Transform(transform: Matrix4.rotationY(math.pi))`.

### Q6: How does the scratch card erase the overlay mask?
**A:** Inside [`_ScratchMaskPainter`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/widgets/scratch_card.dart#L78-L108), `canvas.saveLayer()` creates an offscreen buffer. The touch paths are drawn with a `Paint` having `BlendMode.clear`, which zeroes out alpha pixels in that buffer.

### Q7: Why use `RepaintBoundary` on the carousel and scratch cards?
**A:** Continuous user gestures (pan gestures on scratch cards, swiping cards) trigger high-frequency repaints. Wrapping them in a `RepaintBoundary` prevents paint invalidation from propagating to the entire screen ([`home_screen.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/screens/home_screen.dart#L97-L107), [`scratch_card.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/widgets/scratch_card.dart#L50-L75)).

### Q8: How do you prevent timer memory leaks in Flutter?
**A:** Periodic timers keep strong references to callbacks. In [`HomeScreen`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/screens/home_screen.dart#L44-L48), `_countdownTimer?.cancel()` is explicitly executed in `dispose()` before the widget unmounts.

### Q9: What is the practical difference between `context.watch()` and `context.read()`?
**A:** `context.watch<T>()` registers the widget as a listener to rebuild on `notifyListeners()`. `context.read<T>()` fetches the instance once without subscribing, ideal inside button click handlers ([`transactions_screen.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/screens/transactions_screen.dart#L27), [`home_screen.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/screens/home_screen.dart#L61)).

### Q10: Why use `ListView.builder` over `SingleChildScrollView` + `Column`?
**A:** `ListView.builder` creates items lazily on demand as they scroll into viewport, recycling offscreen elements to keep RAM low across 5,000 items ([`transactions_screen.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/screens/transactions_screen.dart#L70-L77)).

### Q11: How did you unit test the widget flow without Mockito or build_runner?
**A:** In [`test/app_test.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/test/app_test.dart#L18-L47), we wrote plain Dart test doubles (`FakeApiService` with a `Completer` and `FakeLocalStore`) implementing the respective class interfaces directly.

### Q12: How are accessibility requirements met?
**A:** Interactive components are wrapped in `Semantics(label: ..., button: true)` with descriptive status messages, making them fully accessible to screen readers ([`credit_card_widget.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/widgets/credit_card_widget.dart#L51-L54), [`home_screen.dart`](file:///c:/Users/DELL/OneDrive/Documents/CREDLite/lib/screens/home_screen.dart#L173-L177)).
