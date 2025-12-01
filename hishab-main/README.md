# Hishab - Finance Tracking App

A beautiful and intuitive Flutter finance tracking application designed to help users manage their daily expenses and stay within their budget.

## 🎯 Features

### Phase 1 - Core Foundation (Current)

#### 1. **Onboarding Experience**
- Beautiful 3-screen onboarding flow introducing app features
- Monthly income setup screen
- Skip options for flexible first-time experience

#### 2. **Home Dashboard**
- **Today's Spending**: Prominently displayed at the top
- **Daily Allowance**: Calculated as (Monthly Income - Total Spent) ÷ Days Remaining
- **Color-Coded Status Indicator**:
  - 🟢 Green: Under 80% of daily allowance
  - 🟡 Yellow: 80-100% of daily allowance
  - 🔴 Red: Over 100% of daily allowance
- **Quick Stats Cards**:
  - This Week's total spending
  - This Month's total spending
  - Monthly income, spent, and remaining balance

#### 3. **Manual Expense Entry**
- Simple, clean form with validation
- Fields: Amount, Category, Note (optional), Date
- Category selection with visual chips
- Real-time validation
- Success confirmation
- Currency: ৳ (Bangladeshi Taka)

#### 4. **Expense List View**
- Chronologically organized expenses (newest first)
- Grouped by date: "Today", "Yesterday", specific dates
- Daily totals for each date group
- Swipe-to-delete with confirmation dialog
- Category icons and colors for easy identification
- Empty state with helpful message

#### 5. **Category Breakdown**
- Interactive pie chart showing monthly spending by category
- Percentage and amount for each category
- Detailed list view with progress bars
- Only displays categories with expenses
- Monthly total at the top

#### 6. **Settings Screen**
- **Monthly Income Management**: Edit your income anytime
- **Category Management**: 
  - View all categories
  - Add custom categories with icons and colors
  - Default categories: Food, Transport, Shopping, Bills, Entertainment, Health, Other
- **Data Management**: Clear all data with confirmation
- **About Section**: App version and description

## 🏗️ Technical Architecture

### Project Structure
```
lib/
├── database/
│   └── database_helper.dart      # SQLite database management
├── models/
│   ├── expense.dart              # Expense data model
│   ├── income.dart               # Income data model
│   └── category_model.dart       # Category data model
├── providers/
│   └── finance_provider.dart     # State management (Provider)
├── screens/
│   ├── onboarding/
│   │   ├── onboarding_screen.dart
│   │   └── income_setup_screen.dart
│   ├── home/
│   │   └── home_screen.dart      # Main dashboard
│   ├── expense/
│   │   ├── add_expense_screen.dart
│   │   └── expense_list_screen.dart
│   ├── categories/
│   │   └── category_breakdown_screen.dart
│   └── settings/
│       └── settings_screen.dart
└── main.dart                     # App entry point
```

### Database Schema

#### Expenses Table
```sql
CREATE TABLE expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  note TEXT,
  date TEXT NOT NULL,
  timestamp TEXT NOT NULL
)
```

#### Income Table
```sql
CREATE TABLE income (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  monthly_income REAL NOT NULL,
  date_set TEXT NOT NULL
)
```

#### Categories Table
```sql
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  icon TEXT NOT NULL,
  color TEXT NOT NULL
)
```

### Technologies Used
- **Framework**: Flutter 3.9.2+
- **State Management**: Provider (^6.1.1)
- **Database**: SQLite (sqflite ^2.3.0)
- **Charts**: FL Chart (^0.65.0)
- **Date Formatting**: intl (^0.19.0)
- **Local Storage**: SharedPreferences (^2.2.2)
- **Path Management**: path_provider (^2.1.1)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   cd hishab
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 💡 Key Features Explained

### Smart Daily Allowance Calculation
The app intelligently calculates your daily spending limit:
```
Daily Allowance = (Monthly Income - Total Spent This Month) ÷ Days Remaining
```
This dynamic calculation adjusts as you spend, helping you stay on budget.

### Color-Coded Spending Status
Visual indicators help you quickly understand your spending:
- **Green**: You're doing great! Under 80% of your daily allowance
- **Yellow**: Caution! Between 80-100% of your daily allowance  
- **Red**: Over budget! Exceeding your daily allowance

### Data Persistence
All data is stored locally using SQLite:
- ✅ No internet required
- ✅ Fast and reliable
- ✅ Privacy-focused (your data never leaves your device)
- ✅ No cloud sync (Phase 1)

## 🎨 Design Philosophy

### Material Design 3
- Clean, modern interface
- Calming color palette (blues, greens, whites)
- Consistent spacing and padding
- Smooth transitions and animations

### User Experience Priorities
1. **Simplicity**: Easy to understand and use
2. **Speed**: Quick expense entry (< 10 seconds)
3. **Clarity**: Clear visual hierarchy
4. **Feedback**: Immediate visual confirmation of actions

## 📱 App Flow

1. **First Launch**
   - Splash screen
   - Onboarding (3 screens)
   - Income setup
   - Navigate to dashboard

2. **Typical Usage**
   - View dashboard (spending status)
   - Tap (+) to add expense
   - Select category, enter amount
   - Save and return to dashboard
   - Check weekly/monthly totals
   - Review category breakdown

3. **Management**
   - Edit monthly income in settings
   - Add custom categories
   - View all expenses in list
   - Delete expenses with swipe gesture

## 🔐 Data Management

### Local Storage
- All data stored in SQLite database
- Shared Preferences for app state (onboarding, etc.)
- Database location: App's documents directory

### Clear Data
Users can clear all data from Settings:
- Deletes all expenses
- Deletes income records
- Resets categories to defaults
- Requires confirmation dialog

## 🐛 Error Handling

- Input validation on all forms
- Confirmation dialogs for destructive actions
- User-friendly error messages
- Graceful handling of edge cases

## 🔮 Future Enhancements (Phase 2+)

Potential features for future releases:
- ☁️ Cloud sync across devices
- 📊 Advanced analytics and insights
- 🏷️ Tags and custom filters
- 📸 Receipt photo capture
- 💰 Multiple currency support
- 📅 Budget planning tools
- 📈 Spending trends and predictions
- 🔔 Spending limit notifications
- 📤 Export to CSV/PDF
- 🌙 Dark mode
- 🌐 Multi-language support

## 📄 License

This project is private and not licensed for public use.

## 👨‍💻 Development

### Building for Release

**Android APK**:
```bash
flutter build apk --release
```

**Android App Bundle**:
```bash
flutter build appbundle --release
```

### Testing
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

## 🤝 Contributing

This is a private project. Contributions are not accepted at this time.

## 📞 Support

For issues or questions, please contact the development team.

---

**Version**: 1.0.0  
**Last Updated**: November 2025  
**Platform**: Android (iOS support coming soon)

