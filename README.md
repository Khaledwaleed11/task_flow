# 🚀 TaskFlow

A modern task management application built with **Flutter** and **Firebase**, designed to help users organize projects, manage tasks, track progress, and work efficiently through a clean and intuitive interface.

TaskFlow also provides a dedicated **Admin Dashboard** where administrators can manage users, projects, tasks, and task assignments.

---

## 📱 Screenshots

> Add your application screenshots in the sections below.

#### Splash Screen
<p align="center">
<img width="300" alt="task_flow_splash" src="https://github.com/user-attachments/assets/750bc1f4-0dd6-40de-a80e-65f55ca66b14" />
<p>
#### Login
<p align="center">
<img width="300" alt="task_flow_login" src="https://github.com/user-attachments/assets/af56c099-1d11-4a4c-b692-fa0af2bc3205" />
<p>

#### Register
<p align="center">
<img width="300" alt="task_flow_register" src="https://github.com/user-attachments/assets/e0a3c933-5c41-4a65-a2dc-a878d2763b91" />
<p>


#### Home
<p align="center">
<img width="300" alt="task_flow_home_user" src="https://github.com/user-attachments/assets/8985eb90-932e-4354-8d66-aa03134ad2f3" />
<p>

#### Projects
<p align="center">
<img width="300" alt="task_flow_projects" src="https://github.com/user-attachments/assets/038ee4e7-ce15-41cf-85ea-91384d4adb69" />
<p>

#### Project Details
<p align="center">
<img width="300" alt="task_flow_project_detials" src="https://github.com/user-attachments/assets/e2d1da7a-589c-482f-813e-78c6b6e255e4" />
<p>

#### Create Project
<p align="center">
<img width="300" alt="task_flow_create_project" src="https://github.com/user-attachments/assets/7ba42590-bc10-41e8-8732-e6ce8234ae5d" />
<p>

#### Edit Project
<p align="center">
<img width="300" alt="task_flow_edit_project" src="https://github.com/user-attachments/assets/a921e34e-11cc-4f24-a002-855e708d2e6f" />
<p>

#### Create Task
<p align="center">
<img width="300" alt="task_flow_create_task" src="https://github.com/user-attachments/assets/08760740-5f1d-4862-92ba-fc21c28d3ea0" />
<p>

#### Create Task2
<p align="center">
<img width="300" alt="task_flow_create_task2" src="https://github.com/user-attachments/assets/47c4d612-256f-4253-b691-322d7e5002e9" />
<p>
  
#### Edit Task
<p align="center">
<img width="300" alt="task_flow_edit_task" src="https://github.com/user-attachments/assets/32be80a5-2e6e-4985-ae91-911015dd6734" />
<p>





#### Profile
<p align="center">
<img width="300" alt="task_flow_admin_profile" src="https://github.com/user-attachments/assets/b01468e9-7a74-49d6-a8ac-83e40997ff4f" />
<p>


#### Admin Dashboard
<p align="center">
<img width="300" alt="task_flow_admin_dashboard" src="https://github.com/user-attachments/assets/5606dcfe-5374-4850-ad5f-da2ada406120" />
<p>
#### Admin Users
<p align="center">
<img width="300" alt="task_flow_admin_users" src="https://github.com/user-attachments/assets/6f0f3883-87e7-4bbe-9578-1fc7c26ae3ff" />
<p>

## 📌 About The Project

**TaskFlow** is a task and project management application developed using Flutter.

The application provides two different experiences:

### 👤 Normal User

Users can:

* Login to their account.
* View their projects.
* Open project details.
* View assigned tasks.
* Track task completion.
* Edit their profile.
* Switch between Light and Dark Mode.
* Logout securely.

### 🛡️ Administrator

Administrators have additional permissions that allow them to:

* Access the Admin Dashboard.
* View application statistics.
* Manage users.
* Create projects.
* Edit projects.
* Delete projects.
* Create tasks.
* Edit tasks.
* Delete tasks.
* Assign tasks to application users.
* Monitor task progress.

The application does **not** provide a public option to register as an administrator.

Admin accounts are created and managed manually through Firebase, and the user's role is stored in the application database.

---

# ✨ Features

## 🔐 Authentication

* User Registration
* User Login
* User Logout
* Firebase Authentication
* Authentication state management
* Automatic authentication checking
* Splash screen
* Protected application flow

---

## 📁 Project Management

Users can work with projects and view their associated tasks.

Project functionality includes:

* Create Project
* View Projects
* View Project Details
* Edit Project
* Delete Project
* Track project progress
* View project statistics

---

## ✅ Task Management

TaskFlow provides complete task management functionality.

Users/Admins can work with:

* Create Task
* Edit Task
* Delete Task
* Complete / Uncomplete Task
* Task Priority
* Task Assignment
* Task Description
* Task Progress
* Task Statistics

### Task Priorities

* 🟢 Low
* 🟡 Medium
* 🔴 High

### Task Status

* Not Started
* In Progress
* Completed

---

## 👥 Task Assignment

Administrators can assign tasks to specific application users.

The assignment system allows the administrator to:

* Select a user.
* Assign a task to that user.
* View the assigned user.
* Filter available users.
* Prevent invalid duplicate assignments.

---

# 🛡️ Admin System

TaskFlow contains a dedicated administrative experience.

The application uses user roles to distinguish between:

```text
Admin
User
```

The role is stored with the user's data and is used to determine which interface and permissions should be available.

### Admin Dashboard

The dashboard provides:

* Overview statistics
* User statistics
* Project statistics
* Task statistics
* Project management
* User management
* Task management

---

# 🎨 UI & Design

TaskFlow was designed with a modern and clean interface.

The UI focuses on:

* Minimal design
* Consistent spacing
* Rounded cards
* Clear typography
* Reusable components
* Responsive layouts
* Visual task indicators
* Clear status colors
* Professional dashboard design

---

# 🌓 Light & Dark Mode

TaskFlow supports both:

* ☀️ Light Mode
* 🌙 Dark Mode

The application uses a centralized theme system to keep the UI consistent throughout the application.

The selected theme is also **persisted locally**, so the user's preferred theme remains active after restarting the application.

### Theme Technologies

* Flutter `ThemeData`
* Material 3
* Custom `AppTheme`
* Custom `AppColors`
* `ThemeProvider`
* `SharedPreferences`

---

# 🎨 Color System

The application uses an olive-inspired visual identity.

### Primary Color

```text
#6B7A3D
```

### Primary Dark

```text
#55632F
```

The application also uses dedicated colors for:

* Success
* Warning
* Error
* Information
* Light/Dark backgrounds
* Borders
* Primary and secondary text

Colors are centralized inside:

```text
lib/core/theme/app_colors.dart
```

---

# 🏗️ Architecture

TaskFlow follows **Clean Architecture** principles.

The application is divided into three main layers:

```text
Presentation
    ↓
Domain
    ↓
Data
```

### Presentation Layer

Responsible for:

* Screens
* Widgets
* Providers
* UI state
* User interaction

### Domain Layer

Contains the business logic:

* Entities
* Repository contracts
* Use Cases

### Data Layer

Responsible for:

* Firebase
* Data Sources
* Models
* Repository implementations

---

# 🧠 State Management

TaskFlow uses **Provider** for state management.

Providers are responsible for managing application state and communicating between the UI and the domain layer.

Examples include:

```text
AuthProvider
ProjectProvider
TaskProvider
ThemeProvider
```

This keeps business logic outside the UI and makes the application easier to maintain.

---

# 💉 Dependency Injection

TaskFlow uses **GetIt** for dependency injection.

A centralized dependency injection container is used to register:

* Firebase services
* Data sources
* Repository implementations
* Use cases
* Application dependencies

Main file:

```text
lib/core/dependency_injection/injection_container.dart
```

Dependencies can then be accessed using:

```dart
sl()
```

---

# 🔥 Firebase

TaskFlow uses Firebase as its backend infrastructure.

Firebase services used in the project include:

### Firebase Authentication

Used for:

* Registration
* Login
* Logout
* Current user management

### Cloud Firestore

Used for storing:

* Users
* Projects
* Tasks
* Task assignments
* User roles

---

# 🗄️ Firestore Structure

The application uses Firestore collections to organize application data.

A simplified structure is:

```text
users
 └── userId
      ├── id
      ├── name
      ├── email
      └── role

projects
 └── projectId
      ├── id
      ├── name
      ├── description
      └── ...

tasks
 └── taskId
      ├── id
      ├── projectId
      ├── title
      ├── description
      ├── priority
      ├── isCompleted
      ├── assignedTo
      └── ...
```

---

# 📦 Technologies & Packages

## Flutter

The application is built using **Flutter** and **Dart**.

Flutter is used to build the complete cross-platform user interface.

---

## Firebase Core

Used to initialize Firebase inside the Flutter application.

```yaml
firebase_core
```

---

## Firebase Authentication

Used for user authentication.

```yaml
firebase_auth
```

---

## Cloud Firestore

Used as the application's cloud database.

```yaml
cloud_firestore
```

---

## Provider

Used for state management.

```yaml
provider
```

---

## GetIt

Used for dependency injection.

```yaml
get_it
```

---

## Shared Preferences

Used to locally persist the selected theme.

```yaml
shared_preferences
```

---

# 🧰 Development Tools

The project was developed using:

* Flutter
* Dart
* Android Studio
* Firebase Console
* Cloud Firestore
* Firebase Authentication
* Git
* GitHub

---

# 📂 Project Structure

The project follows a feature-based Clean Architecture structure.

```text
lib/
│
├── app/
│   └── app.dart
│
├── core/
│   ├── dependency_injection/
│   │   └── injection_container.dart
│   │
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_theme.dart
│   │   └── theme_provider.dart
│   │
│   └── usecase/
│       └── usecase.dart
│
├── features/
│   │
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── home/
│   │   └── presentation/
│   │
│   ├── projects/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── tasks/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── admin/
│       └── presentation/
│
├── firebase_options.dart
└── main.dart
```

---

# 🔄 Application Flow

The general application flow is:

```text
Application Start
       ↓
Splash Screen
       ↓
Check Authentication
       ↓
 ┌───────────────┐
 │               │
 ▼               ▼
Logged Out     Logged In
 │               │
 ▼               ▼
Login         Check Role
Register          │
          ┌───────┴───────┐
          ▼               ▼
        Admin            User
          │               │
          ▼               ▼
   Admin Dashboard       Home
```

---

# 🔑 Authentication Flow

```text
Register
   ↓
Firebase Authentication
   ↓
Create User Document
   ↓
Firestore
   ↓
Login
   ↓
AuthProvider
   ↓
AuthGate
   ↓
Application
```

---

# 📊 Task Progress

TaskFlow provides visual progress tracking for projects.

The application calculates task progress based on completed tasks.

For example:

```text
Completed Tasks / Total Tasks
```

The result is represented visually through:

* Progress indicators
* Statistics cards
* Progress rings
* Status indicators

---

# 🧩 Reusable UI Components

The application contains reusable components to maintain consistency across the project.

Examples include:

* Project Cards
* Task Cards
* Section Headers
* Form Cards
* Buttons
* Status Indicators
* Priority Selectors
* Statistics Cards
* Empty States
* Loading States
* Error States
* Admin Cards
* Dashboard Components

This reduces duplicated UI code and makes future maintenance easier.

---

# 🧪 Error & Loading States

TaskFlow handles different application states instead of showing only the successful state.

The UI supports:

### Loading

Displays loading indicators while data is being retrieved or submitted.

### Empty

Displays dedicated empty-state widgets when there is no data.

### Error

Displays appropriate error messages and retry actions when needed.

### Success

Provides feedback after successful operations such as:

* Creating projects
* Updating projects
* Creating tasks
* Updating tasks
* Deleting tasks
* Authentication operations

---

# 🚀 Getting Started

## Prerequisites

Before running the project, make sure you have:

* Flutter SDK installed
* Dart SDK
* Android Studio
* Android SDK
* A Firebase project
* Firebase CLI
* FlutterFire CLI

---

## Clone The Repository

```bash
git clone https://github.com/Khaledwaleed11/task_flow  
```

Navigate to the project:

```bash
cd task_flow
```

---

## Install Dependencies

```bash
flutter pub get
```

---

## Firebase Configuration

Create a Firebase project and configure:

* Firebase Authentication
* Cloud Firestore

Then configure Firebase for the Flutter project using FlutterFire.

```bash
flutterfire configure
```

Make sure that the generated:

```text
firebase_options.dart
```

exists inside the project.

---

## Run The Application

```bash
flutter run
```

---

# 🔐 Admin Account

TaskFlow intentionally does not expose an **"Register as Admin"** option to public users.

An administrator account should be created manually and assigned the appropriate role.

The user's role is then stored in Firestore.

Example:

```text
role: admin
```

Normal users use:

```text
role: user
```

This prevents users from simply selecting the administrator role during registration.

---

# 🔒 Security Considerations

The application uses Firebase Authentication to identify users.

Firestore security rules should be configured carefully to ensure that:

* Users can only access permitted data.
* Admin operations are protected.
* Authentication is required for protected operations.
* Users cannot simply modify their own role to become administrators.

> For production deployment, Firebase Security Rules should always be reviewed and tested before publishing the application.

---

# 📈 Future Improvements

Possible future improvements include:

* Push Notifications
* Task Deadlines & Reminders
* Advanced Search
* Task Filtering
* Task Sorting
* Activity History
* More Advanced Analytics
* Team Collaboration
* File Attachments
* Web/Desktop Optimization

---

# 🎯 What I Learned

Building TaskFlow helped me practice and apply several important Flutter development concepts:

* Clean Architecture
* Feature-based project structure
* State Management with Provider
* Dependency Injection with GetIt
* Firebase Authentication
* Cloud Firestore
* CRUD operations
* User roles & permissions
* Task assignment
* Theme management
* Light/Dark Mode
* Local persistence
* Reusable UI components
* Form validation
* Loading & error handling
* Professional UI/UX design

---

# 👨‍💻 Author

**Khaled Waleed Helal Mahmoud**

Flutter Developer & Instructor

### Skills

* Flutter
* Dart
* Firebase
* .NET / C#
* Clean Architecture
* Provider
* GetIt
* REST APIs
* Firestore

---

# ⭐ Support

If you find this project useful or interesting, feel free to give the repository a ⭐ on GitHub.

---

# 📄 License

This project was created for educational and portfolio purposes.
