# MoodJournal Flutter App

A Flutter application for tracking mood and journaling, built for a technical assessment.

![Mood Journal App](https://placekitten.com/500/300)

## Features

### Core Features
- **Authentication**: Email/password login and registration with Firebase (mock implementation included)
- **Mood Tracking**: Log daily moods (happy, neutral, sad) with timestamps
- **Journal Entries**: Add, edit, and delete journal entries
- **Gamification**: Earn points and badges for consistent usage
- **Offline Mode**: Full functionality even without internet connection
- **API Integration**: Secure REST API calls with token-based authentication and error handling

### Technical Highlights
- **State Management**: Provider pattern for efficient state handling
- **Clean Architecture**: Separation of concerns with services, providers, and UI
- **Mock Implementation**: Fully functional without backend setup using mock data
- **Error Handling**: Comprehensive error catching and user feedback
- **Responsive Design**: Works on various screen sizes

## Screenshots

| Login Screen | Home Screen | Mood Tracker | Profile |
|---|---|---|---|
| ![Login](https://placekitten.com/200/400) | ![Home](https://placekitten.com/200/401) | ![Tracker](https://placekitten.com/200/402) | ![Profile](https://placekitten.com/200/403) |

## Getting Started

### Prerequisites
- Flutter SDK (^3.9.0)
- Dart SDK (^3.3.0)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/mood_journal_app.git
```

2. Install dependencies
```bash
cd mood_journal_app
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Test Credentials
- Email: test@example.com
- Password: password123

## Project Structure

```
lib/
├── models/           # Data models
├── providers/        # State management
├── screens/
│   ├── auth/         # Authentication screens
│   ├── journal/      # Journal & mood tracking screens
├── services/         # API and business logic
├── utils/            # Helper functions
├── widgets/          # Reusable UI components
└── main.dart         # App entry point
```

## API Integration

The app demonstrates secure API integration with:
- Token-based authentication
- Automatic token refresh
- Error handling and retries
- Offline cache for uninterrupted usage

## CI/CD Pipeline

A GitHub Actions workflow is included for:
- Code quality checks
- Automated testing
- Building for iOS and Android platforms

See `.github/workflows/flutter.yml` for implementation details.

## Deployment

The app is configured for deployment to:
- Google Play Store (internal testing)
- Apple TestFlight

Detailed deployment documentation is available in the `deployment/` directory.

## Future Enhancements

- Video call feature using Agora SDK
- AI journaling assistant for mood analysis
- Enhanced analytics and reporting
- Cloud synchronization

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or feedback, please contact: your.email@example.com
