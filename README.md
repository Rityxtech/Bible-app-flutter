# KJV & ASV Study Bible - Flutter App

A beautifully designed, feature-rich offline Bible reading application built with **Flutter**. Developed for users desiring a fast, responsive, and seamless Scripture reading experience.

## Features

- **Dual Translation Support**: Instantly toggle between the King James Version (KJV) and American Standard Version (ASV).
- **Responsive & Modern UI**: Tailored with custom, aesthetically pleasing typography and seamless animations (using Flutter's `AnimationController` and Material 3 design system).
- **Dark Mode / Light Mode**: Dynamic, system-aware or user-controlled theme switching for comfortable reading in any environment.
- **Robust State Management**: Powered by `Provider` for highly reactive, localized state updates without performance lag.
- **Favorites & Highlighting**: Easily bookmark, save, and manage your favorite verses.
- **Advanced Sharing Engine**: Share scripture dynamically as plain text, or as a beautifully auto-generated, formatted Image quote right to social platforms (using `screenshot` and `share_plus` packages).
- **Text-to-Speech (Audio Bible)**: Built-in `flutter_tts` integration to listen to the Word hands-free.
- **Offline Capable**: Local JSON asset storage guarantees the app remains fully functional without an internet connection.

## Tech Stack & Architecture

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Local Persistence**: Shared Preferences
- **Custom UI**: Material 3, ScrollablePositionedList
- **Key Plugins**: `share_plus`, `screenshot`, `flutter_tts`, `speech_to_text`, `flutter_local_notifications`

## Getting Started

To run this project locally:

1. Guarantee you have the Flutter SDK installed on your system.
2. Clone this repository:
   ```bash
   git clone https://github.com/Rityxtech/Bible-app-flutter.git
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## Development & Best Practices

This app strictly adheres to standard Dart formatting and object-oriented architectural best practices, ensuring that the presentation layer (Widgets) is decoupled from the business logic layer (Providers and Services).

---
*Developed by **RityxTech***
