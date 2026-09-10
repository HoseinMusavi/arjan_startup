
🍔 Arjan Food

A modern food ordering and delivery application built with Flutter, designed with a scalable feature-based architecture and real-world business logic.

Arjan Food provides users with a complete food ordering experience, including authentication, restaurant discovery, menu browsing, cart management, checkout, delivery selection, payment flow, order management, and user profile features.

---

📱 Overview

Arjan Food is a mobile food ordering application developed as a real-world Flutter project.

The application focuses on building a scalable architecture while handling complex user flows such as:

- Authentication with OTP
- Restaurant discovery
- Restaurant menus
- Product details
- Shopping cart management
- Single-merchant cart validation
- Delivery address management
- Delivery date and time selection
- Payment methods
- Order checkout
- User profile management
- Favorite restaurants
- Reviews and ratings
- User points and rewards
- Order management

The project follows a Feature-Based Architecture combined with principles inspired by Clean Architecture.

---

✨ Features

🔐 Authentication

- Mobile number authentication
- OTP verification
- User registration
- Account verification
- Session management
- Logout functionality

---

🍽️ Restaurants

- Browse restaurants
- View restaurant information
- Browse restaurant menus
- View food details
- Restaurant reviews
- Favorite restaurants
- Merchant information

---

🛒 Shopping Cart

- Add items to cart
- Cart item management
- Cart count synchronization
- Cart details
- Single-merchant cart validation
- Merchant conflict handling
- Clear cart functionality
- Dynamic basket total calculation

---

📦 Checkout

- Delivery address management
- Saved address selection
- Create new delivery addresses
- Delivery date selection
- Delivery time selection
- Payment method selection
- Reward points redemption
- Pre-checkout validation
- Final order submission

---

👤 User Profile

- User profile management
- Edit profile information
- Address management
- Password management
- Notification settings
- User points and rewards

---

🏗️ Architecture

The project is organized using a Feature-Based Architecture with separation between:

lib/
│
├── config/
│   ├── routes/
│   └── theme/
│
├── core/
│   ├── constants/
│   ├── di/
│   ├── enums/
│   ├── error/
│   ├── network/
│   ├── services/
│   └── utils/
│
├── features/
│   ├── auth/
│   ├── cart/
│   ├── home/
│   ├── orders/
│   ├── profile/
│   ├── restaurant/
│   └── splash/
│
└── main.dart

Each feature is structured around three main layers:

feature/
│
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   └── repositories/
│
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/

---

🧠 State Management

The application uses BLoC for state management.

The general data flow is:

UI
 ↓
Event
 ↓
BLoC
 ↓
Repository
 ↓
Remote Data Source
 ↓
API

This approach helps keep business logic separate from the user interface and improves scalability and maintainability.

---

🛠️ Tech Stack

Framework

- Flutter
- Dart

State Management

- flutter_bloc
- Equatable

Architecture

- Feature-Based Architecture
- Repository Pattern
- Dependency Injection
- Separation of Data, Domain and Presentation layers

Networking

- Dio
- REST APIs

Dependency Injection

- GetIt

Routing

- GoRouter

Local Storage

- SharedPreferences

Functional Programming

- Dartz

UI & Performance

- Cached Network Image
- Flutter SVG
- Shimmer Loading

---

🔄 Application Flow

Authentication

Mobile Number
      ↓
Request OTP
      ↓
OTP Verification
      ↓
Authentication Success
      ↓
Session Management

Food Ordering

Home
 ↓
Restaurant
 ↓
Menu
 ↓
Food Details
 ↓
Add to Cart
 ↓
Checkout
 ↓
Delivery Information
 ↓
Payment
 ↓
Order Confirmation

---

🧩 Dependency Injection

The project uses GetIt for dependency management.

Dependencies are registered centrally through the service locator, allowing services, repositories, and BLoCs to be injected instead of being created directly throughout the application.

---

🌐 API Integration

The application communicates with remote services through a dedicated network layer.

The architecture separates API communication from business logic:

Presentation
     ↓
Repository
     ↓
Remote Data Source
     ↓
Dio Client
     ↓
REST API

This makes the application easier to maintain and allows the API layer to evolve independently from the UI.

---

🖼️ Screenshots

Screenshots and application previews will be added here.

assets/screenshots/
├── home.png
├── restaurant.png
├── menu.png
├── cart.png
├── checkout.png
└── profile.png

---

🚀 Getting Started

Clone the repository

git clone https://github.com/HoseinMusavi/arjan_startup.git

Navigate to the project

cd arjan_startup

Install dependencies

flutter pub get

Run the application

flutter run

---

🔧 Requirements

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Android Emulator or Physical Device

---

🧪 Testing

The project is designed with a scalable architecture that supports unit and widget testing.

Future testing coverage will focus on:

- BLoC logic
- Repository behavior
- Authentication flows
- Cart operations
- Checkout validation

---

🔮 Future Improvements

- Improved automated test coverage
- Push notifications
- Improved offline support
- Advanced caching
- Performance monitoring
- Analytics integration
- CI/CD pipeline
- Multi-language improvements
- Improved accessibility
- Enhanced error handling

---

👨‍💻 Developer

Hossein Mousavi

Flutter Developer | Mobile Application Developer

GitHub: https://github.com/HoseinMusavi

---

⭐ Project Goals

This project was built to explore and implement a scalable Flutter architecture for a real-world food ordering application.

The main focus of the project is not only the UI, but also:

- Scalable architecture
- Separation of concerns
- Maintainable code
- State management
- API integration
- Real-world business logic

---

If you found this project useful or interesting, feel free to ⭐ the repository.
