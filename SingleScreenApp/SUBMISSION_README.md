# SingleScreenApp - Final Submission

## Overview
SingleScreenApp is a modern iOS application that demonstrates building a clean, well-architected app with SwiftUI. The app features a form for user input, API integration with reqres.in, and displays the results with a smooth, modern UI/UX.

## Features
- Create User form with validation
- Fetch existing user data from API
- Dark mode support
- Adaptive UI for all iPhone sizes (SE to Pro Max)
- Modern UI with neumorphic design
- Comprehensive state management
- Network connectivity handling
- Smooth animations and transitions

## Technical Implementation

### Architecture
- MVVM architecture pattern
- Clean separation of concerns
- SwiftUI for UI construction
- Modern Swift features (async/await)

### API Integration
- URLSession for network requests
- Async/await for asynchronous operations
- Proper error handling

### State Management
- Generic `ViewState<T>` enum with four states:
  - `idle`
  - `loading`
  - `success(T)`
  - `error(String)`
- Visual state indicators
- Proper state transitions

### Error Handling
- Network connectivity detection
- User-friendly error messages
- Error recovery options

### Adaptivity
- Supports all iPhone sizes from SE to Pro Max
- Adapts layout, spacing, and font sizes
- Dark mode support with custom color palettes

### Testing
- Unit tests for API service
- Test cases for success and failure scenarios
- Simulated error conditions

## Usage Instructions

### Create User
1. Open the app and stay on the "Create User" tab
2. Either:
   - Use the default "Ronit" values by toggling "Use custom values" to OFF
   - Enter your own name and email by toggling "Use custom values" to ON
3. Tap "Submit" to send the request
4. View the response showing created user ID and timestamp

### Fetch User
1. Switch to the "Fetch User" tab
2. Tap "Fetch Random User" to get a random user from the API
3. View the user profile including avatar, name, email, and ID

## Testing Features
- Toggle airplane mode to test no internet handling
- Submit invalid email to test validation
- Rotate device to test adaptivity

## Demo Video
A demonstration video showing the app in action is included in the submission.

## Contributors
This app was built as part of a coding exercise.

## License
This project is for demonstration purposes only. 