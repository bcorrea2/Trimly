# Trimly

## 🚀 Project Overview

Trimly is a simple iOS application that allows users to shorten URLs and keep a history of their recently shortened links. 
Built as a take-home test, it focuses on demonstrating solid software engineering principles, clean architecture, and comprehensive testing.

The main idea behind this project was to meet the requirements while keeping the project as simple as possible, achieving maximum code coverage with high-quality tests.

## ✨ Features

-   **URL Shortening**: Easily shorten long URLs using a dedicated backend service.
-   **History Display**: View a list of all previously shortened URLs.
-   **Client-Side Validation**: Instant feedback for invalid URL inputs.
-   **Robust Error Handling**: Clear messages for network issues or API failures.
-   **Loading Indicators**: Visual feedback during network operations.

## 🏗️ Architecture

The application is built using the **MVVM (Model-View-ViewModel)** architectural pattern, which promotes a clear separation of concerns, enhances testability, and integrates seamlessly with SwiftUI.

-   **Model**: Represents the data structures (e.g., `ShortenedURLResponse`, `Links`).
-   **View**: The SwiftUI interface (`ShortenerView`) responsible for displaying data and capturing user interactions. It observes changes from the ViewModel.
-   **ViewModel**: (`ShortenerViewModel`) Acts as a bridge between the View and the Model. It contains the business logic, manages the view's state, and interacts with the networking layer.

### Generic Networking Layer

A flexible and testable generic networking layer (`APIService`, `APIEndpoint`) has been implemented. This allows for easy integration with various backend APIs by defining specific `APIEndpoint` implementations (e.g., `ShortenerEndpoint`).

## 🧪 Testing

The project includes a comprehensive test suite to ensure reliability and correctness:

-   **Unit Tests**: Extensive coverage for the ViewModel, generic API service, and endpoint configurations.
-   **UI Tests**: End-to-end tests verifying core user flows, error handling, and loading states.

## 🔮 Future Improvements

-   **Integrate Launch Performance Test**: Uncomment and integrate the `testLaunch` UI test from `TrimlyUITestsLaunchTests.swift` to monitor app launch performance.
-   **Copy to Clipboard**: Allow users to easily copy shortened URLs.
-   **Empty State UI**: Display a friendly message when the history list is empty.
-   **UI Polish**: Further refine the visual design for an even better user experience.

## 📱 Screenshots

<img width="585" height="1266" alt="Captura de Tela 2026-10-02 à(s) 20 39 15" src="https://github.com/user-attachments/assets/2c609130-31d2-4fc5-9b8d-d94aa5b166cc" />


## ✅ Requirements

-   Xcode 26 or later
-   iOS 16.6+ deployment target
-   Swift 5.0

## 🚀 Getting Started

1.  Clone the repository:
    ```bash
    git clone https://github.com/bcorrea2/Trimly.git
    ```
2.  Open `Trimly.xcodeproj` in Xcode.
3.  Select the `Trimly` scheme and run on a simulator or device (`Cmd+R`).
4.  To run the test suite, use `Cmd+U` or:
    ```bash
    xcodebuild test -project Trimly.xcodeproj -scheme Trimly -destination 'platform=iOS Simulator,name=iPhone 16'
    ```

## 📄 License

This project is licensed under the [MIT License](LICENSE).
