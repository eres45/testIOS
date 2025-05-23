# SingleScreenApp

A single-screen SwiftUI app that demonstrates:

- Taking user input via a form
- Submitting data to an API
- Displaying results with smooth UI/UX
- Following modern MVVM architecture

## Features

- Create new users via API
- Fetch existing user data
- Modern SwiftUI interface with animations
- Error handling
- Async/await for network operations

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Project Structure

```
SingleScreenApp/
├── Views/
│   └── ContentView.swift
├── ViewModels/
│   └── UserViewModel.swift
├── Models/
│   └── UserModel.swift
├── Services/
│   └── APIService.swift
└── Utilities/
    └── AsyncButton.swift
```

## API

This app uses the [ReqRes](https://reqres.in) API for demonstration purposes.

## Getting Started

1. Open the project in Xcode
2. Build and run on a simulator or device

## Architecture

This app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures matching API responses
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: Business logic and state management
- **Services**: API interaction 