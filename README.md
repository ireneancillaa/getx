# To Do List App

A robust and feature-rich To-Do List application built with **Flutter**. This app utilizes **GetX** for seamless state management, routing, and dependency injection, alongside **Firebase** (Firestore & Cloud Messaging) for backend services and push notifications.

## 🚀 Features

* **Task Management:** Easily add, edit, delete, and mark tasks as pending or completed.
* **Swipe to Delete:** Quick swipe gestures to remove tasks, complete with an "Undo" option.
* **Real-Time Sync:** Instant data synchronization across devices using Firebase Firestore.
* **Smart Timestamps:** Displays relative time (e.g., "just now", "5m ago") for recent notes and exact dates for older ones.
* **Push Notifications:** Handles foreground and background notifications via Firebase Cloud Messaging (FCM).

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/)
* **State Management & Routing:** [GetX](https://pub.dev/packages/get)
* **Backend:** Firebase (Cloud Firestore & Cloud Messaging)

## ⚙️ Getting Started

Follow these steps to run the project locally:

1.  **Clone the repository**
    ```bash
    git clone [https://github.com/ireneancillaa/getx.git](https://github.com/ireneancillaa/getx.git)
    cd getx
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**
    This project uses the FlutterFire CLI for configuration. If you are setting this up on your own Firebase project, run:
    ```bash
    flutterfire configure
    ```
    *(Note: Ensure your `google-services.json` for Android and `GoogleService-Info.plist` for iOS are correctly placed in their respective directories if not using the generated `firebase_options.dart` directly).*

4.  **Run the App**
    ```bash
    flutter run
    ```
