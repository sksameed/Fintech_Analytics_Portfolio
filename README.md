# CredLite 💳

**CredLite** is a credit-card bill and rewards tracker built as a portfolio project for a Flutter internship application at **CRED**.

The core focus of this project is **simplicity, readability, and neat organization**. Designed for a student preparing for engineering interviews, every component avoids over-engineering, code generation, and complex dependency injection while delivering a smooth, high-fidelity dark neumorphic experience.

---

## Features

- **Credit Card Carousel**: Horizontal paging of credit cards with a smooth 180° 3D flip animation revealing card limits and due dates.
- **Live Bill Countdown**: Real-time ticker counting down to bill due dates using `Timer.periodic`, paired with a haptic "Pay now" action.
- **Offline-First Transactions**: Instant loading from local Hive storage, pull-to-refresh, live search, and category filter chips across 5,000 transactions.
- **Spend Analytics**: Monthly bar charts and category distribution pie charts powered by `fl_chart`.
- **Background Isolate Benchmark**: Offloads spend aggregation to worker isolates via `Isolate.run` and provides a live stopwatch benchmark against the main thread.
- **Scratch-to-Reveal Rewards**: Interactive voucher cards using `CustomPainter` with `saveLayer` and `BlendMode.clear`, permanently saved in Hive once revealed.

---

## Skills Matrix

| Feature | Engineering Skill Demonstrated | Key Implementation |
|---|---|---|
| **Data Sync** | REST API & Networking | `Dio` client with timeouts, queries, and clean error handling in `api_service.dart`. |
| **Offline Cache** | Local NoSQL Storage | `hive_ce` storing raw JSON strings (zero code-gen or adapters) in `local_store.dart`. |
| **Heavy Processing**| Multi-Threading & Isolates | Background computation via `Isolate.run` and `Stopwatch` in `analytics.dart`. |
| **Interactive UI** | Custom Canvas & Shaders | `CustomPainter` with `saveLayer` and `BlendMode.clear` in `scratch_card.dart`. |
| **Animations** | Explicit Animation & 3D Math | `AnimationController` and `Matrix4` 3D perspective rotation in `credit_card_widget.dart`. |
| **State Management**| Clean Reactive Architecture | Native `ChangeNotifier` + `Provider` cache-first flow in `app_state.dart`. |

---

## Performance & DevTools Verification

### Optimizations Applied
1. **Isolated Repaints**: `RepaintBoundary` wraps both the credit card carousel and scratch canvas to eliminate repaint cascades.
2. **Main-Thread Offloading**: Spend aggregation across 5,000 records runs in a worker isolate via `Isolate.run`, ensuring zero dropped frames.
3. **Efficient List Rendering**: `ListView.builder` recycles transaction rows on demand.
4. **Const Constructors**: Maximize element tree reuse and minimize dirty widget rebuilds.

### How to Verify in Flutter DevTools
1. Run the app in Profile mode: `flutter run --profile`.
2. Open DevTools from your terminal or IDE.
3. Navigate to the **Performance** tab and enable **Highlight Repaints**. Notice only the active card or scratch tile repaints during interactions.
4. Open the **CPU Profiler** tab during aggregation to observe work executing on the background isolate rather than the UI thread.

---

## Setup & Running

### 1. Start the Mock Server
```bash
cd mock_server
npm install
node server.js
# Runs on http://localhost:3000 (maps to http://10.0.2.2:3000 in Android emulator)
```

### 2. Run the Flutter App
```bash
flutter pub get
flutter run
```

---

## Screenshots

| Card Carousel & Bill Due | Search & Filter Transactions | Spend Analytics & Benchmark | Scratch Card Perks |
|:---:|:---:|:---:|:---:|
| *(Screenshot Placeholder 1)* | *(Screenshot Placeholder 2)* | *(Screenshot Placeholder 3)* | *(Screenshot Placeholder 4)* |

---

## Honest Known Limitations

1. **JSON String Serialization**: Data is persisted in Hive as raw JSON strings rather than binary type adapters to keep code simple and readable without `build_runner`.
2. **Mock Server In-Memory State**: Changes made to scratched rewards on the mock server reset when the Node process restarts.
3. **Single Currency**: Currency formatting is currently tailored strictly for Indian Rupees (₹).
