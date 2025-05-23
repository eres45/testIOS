# API Integration & State Management

This document outlines the API integration and state management approach used in the SingleScreenApp.

## API Integration

The app communicates with the [ReqRes](https://reqres.in) API for demonstration purposes.

### Implementation Details

1. **UserService**: A dedicated service for API calls
   - Uses `URLSession` with `async/await`
   - Handles request creation, data parsing, and error handling
   - Supports GET and POST operations

2. **API Endpoint**: 
   - POST to `https://reqres.in/api/users`
   - Default payload: `{ "name": "Ronit", "email": "ronit@example.com" }`
   - Option for custom user input

3. **Response Handling**:
   - Parses JSON response 
   - Extracts `id` and `createdAt` timestamp
   - Handles errors gracefully

## State Management

The app implements a robust state management system:

1. **ViewState Enum**:
   ```swift
   enum ViewState<T> {
       case idle       // Initial state
       case loading    // API request in progress
       case success(T) // Success with response data
       case error(String) // Error with message
   }
   ```

2. **ViewModel Implementation**:
   - Uses `@Published` properties to expose state
   - `createUserState` for user creation
   - `fetchUserState` for user fetching
   - Computed properties for convenient access to state values

3. **State Visualization**:
   - Visual indicators for each state
   - Loading animations
   - Success/failure feedback
   - Error message display

## Architecture Benefits

1. **Separation of Concerns**:
   - View: UI presentation only
   - ViewModel: Business logic and state management
   - Service: API communication

2. **Testability**:
   - Each layer can be tested independently
   - States can be mocked for UI testing

3. **Error Handling**:
   - Centralized error processing
   - User-friendly error messages
   - Graceful recovery options 