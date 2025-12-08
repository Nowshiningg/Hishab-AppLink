# Hishab - Personal Finance Tracker

<div align="center">
  <img src="hishab-main/assets/logo_hishab.png" alt="Hishab Logo" width="120"/>
  
  ### আপনার খরচ ট্র্যাক করুন
  
  A beautiful, feature-rich expense tracking app built with Flutter that helps you manage your daily finances with ease.
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.24.4-blue.svg)](https://flutter.dev/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

---

## ✨ Features

### 🎯 Core Features
- **Smart Expense Tracking**: Add, edit, and categorize your daily expenses
- **Multi-Language Support**: Available in English (EN) and Bengali (বাংলা)
- **Dark Mode**: Eye-friendly dark theme with automatic switching
- **Daily Budget Tracking**: Set daily allowances and monitor spending status
- **Category Management**: Organize expenses with customizable categories and icons

### 🤖 AI-Powered Features
- **Voice Expense Entry**: Add expenses hands-free using voice commands
- **AI Chatbot Assistant**: Get financial insights and spending analysis
- **Smart Parsing**: Automatically extracts amount, category, and notes from voice input

### 📊 Analytics & Insights
- **Category Breakdown**: Visual pie charts showing spending by category
- **Weekly/Monthly Summaries**: Track spending trends over time
- **Budget Alerts**: Get notified when approaching budget limits
- **Category-wise Budgets**: Set individual budgets for different expense categories

### 🎁 Rewards System
- **Points & Streaks**: Earn points for consistent expense tracking
- **Daily Streak Tracking**: Build habits with streak counters
- **Achievement Badges**: Unlock rewards for milestones

### 💎 Premium Features (via Banglalink Integration)
- **SMS Integration**: Automatic expense tracking from SMS
- **Monthly Reports**: Detailed PDF expense reports
- **Priority Support**: Enhanced customer assistance
- **Ad-free Experience**: Enjoy uninterrupted tracking

### 🔔 Smart Notifications
- **Daily Reminders**: Never forget to log expenses
- **Budget Alerts**: Real-time notifications for budget status
- **Monthly Summary SMS**: Get spending reports via SMS

---

## 📱 Screenshots

| Home Screen | Voice Entry | Analytics | Chatbot |
|------------|-------------|-----------|---------|
| Beautiful dashboard with spending overview | Hands-free expense logging | Visual spending breakdown | AI financial assistant |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.4 or higher
- Dart SDK 3.7.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (API level 21+)
- iOS device or simulator (iOS 12.0+)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Nowshiningg/Hishab-AppLink.git
   cd hishab-main
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate launcher icons**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## 🛠️ Built With

### Core Technologies
- **Flutter** - UI framework
- **Provider** - State management
- **SQLite (sqflite)** - Local database storage
- **Shared Preferences** - Settings persistence

### Key Packages
| Package | Purpose |
|---------|---------|
| `intl` | Internationalization (EN/BN) |
| `fl_chart` | Beautiful charts and graphs |
| `speech_to_text` | Voice recognition |
| `permission_handler` | App permissions |
| `flutter_local_notifications` | Local notifications |
| `path_provider` | File system access |
| `url_launcher` | External links |
| `http` | API communication |
| `flutter_launcher_icons` | App icon generation |

---

## 📂 Project Structure

```
lib/
├── config/              # Configuration files
│   └── banglalink_config.dart
├── database/            # SQLite database layer
│   └── database_helper.dart
├── localization/        # i18n translations
│   └── app_localizations.dart
├── models/              # Data models
│   ├── expense.dart
│   ├── category.dart
│   └── reward.dart
├── providers/           # State management
│   └── finance_provider.dart
├── screens/             # UI screens
│   ├── home/            # Dashboard
│   ├── expense/         # Expense CRUD
│   ├── voice/           # Voice input
│   ├── chatbot/         # AI assistant
│   ├── rewards/         # Gamification
│   ├── budget/          # Budget management
│   ├── categories/      # Category management
│   ├── settings/        # App settings
│   ├── premium/         # Subscription
│   └── onboarding/      # First-time setup
├── services/            # Business logic
│   ├── voice_parser_service.dart
│   ├── chatbot_service.dart
│   ├── reward_system_service.dart
│   ├── notification_service.dart
│   ├── banglalink_integration_service.dart
│   ├── pdf_export_service.dart
│   └── update_checker_service.dart
└── main.dart            # App entry point
```

---

## 🎨 Design Philosophy

### Color Palette
- **Primary**: `#F16725` (Orange) - Energy and warmth
- **Secondary**: `#0066CC` (Blue) - Trust and stability
- **Accent**: `#4ECDC4` (Teal) - Freshness and clarity
- **Purple**: `#9C27B0` - Premium features

### UI/UX Principles
- **Material Design 3**: Modern, consistent UI
- **Responsive Layout**: Works on all screen sizes
- **Accessibility**: High contrast, readable fonts
- **Localization**: Native language support
- **Smooth Animations**: Delightful micro-interactions

---

## 🔐 Permissions

| Permission | Purpose |
|------------|---------|
| **Internet** | API calls, updates, premium features |
| **Microphone** | Voice expense entry |
| **Notifications** | Daily reminders, budget alerts |
| **Storage** | PDF export, data backup |
| **SMS** | Premium SMS integration (optional) |

---

## 🌍 Localization

Hishab supports:
- **English (EN)** - Default
- **Bengali (বাংলা)** - Full translation

To add a new language:
1. Add translations to `lib/localization/app_localizations.dart`
2. Update `supportedLocales` in `main.dart`
3. Test with `flutter run --locale=<code>`

---

## 🤝 Contributing

We welcome contributions! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart style guide
- Write meaningful commit messages
- Add comments for complex logic
- Test on both Android and iOS
- Update README for new features

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

- **Nowshiningg** - *Initial work* - [GitHub](https://github.com/Nowshiningg)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for design inspiration
- Contributors and testers
- Banglalink for premium integration support

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/Nowshiningg/Hishab-AppLink/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Nowshiningg/Hishab-AppLink/discussions)

---

## 🗺️ Roadmap

### Upcoming Features
- [ ] Cloud sync and backup
- [ ] Multi-currency support
- [ ] Receipt scanning with OCR
- [ ] Shared budgets (family/team)
- [ ] Investment tracking
- [ ] Bill reminders
- [ ] Recurring expenses
- [ ] Export to Excel/CSV
- [ ] Widgets for home screen
- [ ] Wear OS support

---

## 📊 Version History

- **1.0.0** (Current)
  - Initial release
  - Core expense tracking
  - Voice input & AI chatbot
  - Category budgets & rewards
  - Banglalink premium integration
  - EN/BN localization

---

<div align="center">
  
  ### Made with ❤️ using Flutter
  
  **Star ⭐ this repo if you find it helpful!**
  
</div>

