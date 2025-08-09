# Mood Tracker

Mood Tracker is a cross-platform Flutter application designed to help users log, visualize, and reflect on their daily emotions. It features a modern UI, mood history, insights, and Firebase authentication.

## Features

- **Mood Logging:** Select from predefined moods (Loving, Happy, Sad, Excited, Angry, Calm) with unique colors and icons.
- **Notes:** Add personal notes for each mood entry.
- **Mood History:** View a timeline of past moods with modern UI components.
- **Insights:** Visualize mood statistics and trends over time.
- **Authentication:** Secure login/logout using Firebase Auth.
- **Cross-Platform:** Runs on Android, iOS, Web, Windows, macOS, and Linux.

## Technologies Used

- **Flutter**: UI framework for building natively compiled applications.
- **Firebase**: Authentication and cloud storage for mood entries.
- **Dart**: Programming language for Flutter.

## Project Structure

```
lib/
	Auth/
		auth_page.dart
		auth_wrapper.dart
	models/
		mood_entry.dart
	Screens/
		home_page.dart
		history_page.dart
		history_page_new.dart
		insights_page.dart
	services/
		mood_service.dart
	firebase_options.dart
	main.dart
android/, ios/, web/, windows/, macos/, linux/  # Platform-specific code
```

## Getting Started

1. **Clone the repository:**
	 ```sh
	 git clone https://github.com/samardeeps/mood_tracker.git
	 cd mood_tracker
	 ```
2. **Install dependencies:**
	 ```sh
	 flutter pub get
	 ```
3. **Configure Firebase:**
	 - Add your Firebase configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS) in the respective platform folders.
	 - Update `firebase_options.dart` if needed.
4. **Run the app:**
	 ```sh
	 flutter run
	 ```

## Mood Types, Colors, and Icons

| Mood     | Color        | Icon                |
|----------|-------------|---------------------|
| Loving   | #FF8CAB     | favorite            |
| Happy    | #FFB347     | sentiment_very_satisfied |
| Sad      | #87CEEB     | sentiment_very_dissatisfied |
| Excited  | #C387EB     | electric_bolt       |
| Angry    | #FF322E     | mood_bad            |
| Calm     | #98FB98     | water_drop          |


## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License.
