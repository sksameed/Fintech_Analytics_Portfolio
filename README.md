# Fintech Analytics Portfolio 📊

A comprehensive financial analytics application built with Flutter, showcasing modern mobile app development practices. Designed as a portfolio project for engineering interviews, this application demonstrates expertise in REST APIs, offline storage, state management, animations, and performance optimization.

The core focus of this project is **simplicity, readability, and clean architecture**. Every component avoids over-engineering while maintaining professional engineering standards.

---

## Features

* **Credit Card Carousel**
  Horizontal card navigation with a smooth 3D flip animation displaying credit limits and upcoming bill due dates.

* **Live Bill Countdown**
  Real-time countdown to upcoming bill due dates using `Timer.periodic`, along with a haptic-enabled Pay Now interaction.

* **Offline-First Transactions**
  Transactions are loaded instantly from local Hive storage, with pull-to-refresh, live search, and category-based filtering across 5,000+ transactions.

* **Spend Analytics**
  Monthly spending bar charts and category-wise distribution charts implemented using `fl_chart`.

* **Background Isolate Processing**
  Spend aggregation is performed using `Isolate.run`, with a stopwatch benchmark comparing background and main-thread execution.

* **Scratch-to-Reveal Rewards**
  Interactive scratch cards implemented using `CustomPainter`, `saveLayer`, and `BlendMode.clear`. Revealed rewards are persisted locally using Hive.

---

## Technology Stack

| Technology    | Purpose                          |
| ------------- | -------------------------------- |
| Flutter       | Mobile application development   |
| Dart          | Application programming language |
| Provider      | State management                 |
| Hive CE       | Local and offline data storage   |
| Dio           | REST API communication           |
| fl_chart      | Data visualization               |
| CustomPainter | Custom UI rendering              |
| Isolate.run   | Background computation           |
| Node.js       | Mock API server                  |

---

## Engineering Skills Demonstrated

| Feature          | Engineering Skill       | Implementation                                                    |
| ---------------- | ----------------------- | ----------------------------------------------------------------- |
| Data Sync        | REST API and Networking | `Dio` with request timeouts, query parameters, and error handling |
| Offline Cache    | Local NoSQL Storage     | `hive_ce` with raw JSON persistence                               |
| Heavy Processing | Multithreading          | `Isolate.run` for background calculations                         |
| Interactive UI   | Custom Rendering        | `CustomPainter`, `saveLayer`, and `BlendMode.clear`               |
| Animations       | 3D UI and Animation     | `AnimationController` and `Matrix4`                               |
| State Management | Reactive Architecture   | `ChangeNotifier` and `Provider`                                   |

---

## Performance Optimizations

### Isolated Repaints

`RepaintBoundary` is used around the credit card carousel and scratch-card canvas to prevent unnecessary repaint cascades.

### Background Processing

Spend aggregation across 5,000 transactions is moved to a worker isolate using `Isolate.run`, keeping computationally intensive operations away from the UI thread.

### Efficient List Rendering

`ListView.builder` is used to create transaction rows on demand, reducing unnecessary widget creation.

### Const Constructors

`const` constructors are used wherever applicable to improve widget reuse and minimize unnecessary rebuilds.

---

## Flutter DevTools Verification

Run the application in Profile mode:

```bash
flutter run --profile
```

Then use Flutter DevTools to inspect application performance:

1. Open the **Performance** tab.
2. Enable **Highlight Repaints**.
3. Interact with the credit card carousel and scratch cards.
4. Observe repaint activity during interactions.
5. Open the **CPU Profiler** while running the analytics benchmark.
6. Inspect background isolate activity and processing time.

---

## Project Structure

```text
fintech-analytics-portfolio/
|
├── lib/
│   ├── models/
│   ├── services/
│   ├── widgets/
│   ├── screens/
│   ├── analytics.dart
│   ├── app_state.dart
│   └── main.dart
│
├── mock_server/
│   ├── server.js
│   └── package.json
│
├── assets/
│
├── pubspec.yaml
└── README.md
```

---

## Setup and Installation

### Prerequisites

The following tools are required:

* Flutter
* Dart
* Node.js

### Clone the Repository

```bash
git clone https://github.com/sksameed/Fintech_Analytics_Portfolio.git
cd Fintech_Analytics_Portfolio
```

### Start the Mock Server

Navigate to the mock server directory:

```bash
cd mock_server
npm install
node server.js
```

The mock server runs on:

```text
http://localhost:3000
```

For an Android emulator, use:

```text
http://10.0.2.2:3000
```

### Run the Flutter Application

From the project root:

```bash
flutter pub get
flutter run
```

---

## Screenshots

| Credit Card Carousel |  Transactions  |
| :------------------: | :------------: |
|    Add Screenshot    | Add Screenshot |

| Spend Analytics | Scratch Card Rewards |
| :-------------: | :------------------: |
|  Add Screenshot |    Add Screenshot    |

Replace the placeholders with screenshots of the application.

---

## Known Limitations

### JSON-Based Hive Storage

Data is stored as raw JSON strings instead of binary Hive adapters. This keeps the implementation straightforward and avoids additional code generation through `build_runner`.

### In-Memory Mock Server

Changes made to rewards on the mock server are temporary and are lost when the Node.js server is restarted.

### Single Currency Support

The application currently supports Indian Rupees (`₹`) as the primary currency.

---

## Project Objective

This portfolio project demonstrates practical mobile engineering beyond UI implementation.

The project combines:

* REST API integration
* Offline-first data management
* Local persistence
* State management
* 3D animations
* Custom rendering
* Background isolates
* Performance optimization
* Flutter DevTools profiling

The implementation prioritizes simplicity, readability, maintainability, and practical engineering principles while avoiding unnecessary architectural complexity.

---

## Author

**Shaik Sameed**

* GitHub: [github.com/sksameed](https://github.com/sksameed)
* LinkedIn: [linkedin.com/in/sk-sameed-0909s](https://linkedin.com/in/sk-sameed-0909s)

---

## License

This project was created for educational and portfolio purposes.
