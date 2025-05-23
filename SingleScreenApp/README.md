# SingleScreenApp

## 📱 Overview

SingleScreenApp is a modern iOS application built with SwiftUI that demonstrates professional mobile development practices. The app provides a simple yet elegant user interface for creating and fetching user data through REST API integration.

![App Screenshot Placeholder](https://via.placeholder.com/800x400?text=App+Screenshot+Coming+Soon)

## ✨ Features

- **User Creation**: Create new users with name and email validation
- **User Fetching**: Retrieve user profiles from the API
- **Premium UI/UX**:
  - Neumorphic design with subtle shadows and rounded corners
  - Real-time form validation with feedback
  - Toast notifications for success/error states
  - Haptic feedback on interactions
  - Smooth animations and transitions
- **Robust Error Handling**: Comprehensive error states and user feedback
- **Dark Mode Support**: Full support for iOS light/dark appearances
- **Responsive Design**: Adapts to different iPhone sizes

## 🛠️ Technologies Used

- **Swift 5**: Latest language features including async/await
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **MVVM Architecture**: Clean separation of concerns
- **Unit Testing**: XCTest framework for reliability

## 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+

## 🚀 Getting Started

### Installation

1. Clone this repository
```bash
git clone https://github.com/eres45/testIOS.git
```

2. Open the project in Xcode
```bash
cd testIOS
open SingleScreenApp.xcodeproj
```

3. Build and run the app (⌘+R)

## 📁 Project Structure

```
SingleScreenApp/
├── Views/              # UI components and screens
├── ViewModels/         # Business logic and state management
├── Models/             # Data structures
├── Services/           # API and data services
├── Utilities/          # Helper extensions and components
└── Tests/              # Unit and UI tests
```

## 🏗️ Architecture

This app implements the MVVM (Model-View-ViewModel) architecture:

- **Models**: Data structures that match API responses
- **Views**: SwiftUI views responsible only for UI presentation
- **ViewModels**: Business logic, state management, and data processing
- **Services**: API interaction and data handling

## 🌐 API Integration

The app integrates with the [ReqRes](https://reqres.in) API for demonstration purposes:

- `POST /api/users` - Create user
- `GET /api/users/{id}` - Fetch user by ID

## 🧪 Testing

Run the tests in Xcode:

1. Select Product > Test (⌘+U)
2. View test results in the Test Navigator

---

Made with ❤️ by a passionate iOS developer 
