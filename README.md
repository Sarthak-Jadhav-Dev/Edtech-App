<div align="center">

# 🎓 Kids EduTech

### *An AI-Powered Learning Platform for Children*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Gemini AI](https://img.shields.io/badge/Google-Gemini_AI-4285F4?logo=google&logoColor=white)](https://ai.google.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Kids EduTech** is a feature-rich, cross-platform mobile application built with Flutter that reimagines how children aged 6–14 learn. It brings together **AI-driven personalized insights**, a **gamified learning experience**, **YouTube-based video content**, and a **real-time parent monitoring system** — all within a beautiful Material 3 interface.

---

[Features](#-features) · [Architecture](#-architecture) · [Tech Stack](#-tech-stack) · [Getting Started](#-getting-started) · [Screenshots](#-screenshots) · [Project Structure](#-project-structure) · [Contributing](#-contributing)

</div>

---

## ✨ Features

### 🔐 Authentication & Role-Based Access
- **Email/Password** sign-up and sign-in with real-time validation
- **Google Sign-In** with seamless first-time role selection
- **Three distinct roles**: Student, Teacher, and Parent — each with a dedicated dashboard and feature set
- Password reset via email
- Glassmorphism-styled auth screens with Lottie animations

### 👨‍🎓 Student Portal
| Feature | Description |
|---|---|
| **Home Dashboard** | Personalized feed with enrolled classes, pending assignments, and progress stats |
| **Course Enrollment** | Browse and enroll in classes created by teachers |
| **Video Lessons** | Watch YouTube-based video content with in-app player and progress tracking |
| **Assignments** | View, complete, and submit assignments with real-time status tracking |
| **Interactive Quizzes** | Timed MCQ quizzes with instant scoring and AI-powered performance insights |
| **AI Buddy Chatbot** | Powered by **Google Gemini 2.0 Flash** — a friendly learning companion that answers questions, encourages curiosity, and awards stars |
| **Progress Dashboard** | Visual progress tracking across all enrolled courses |
| **Class Leaderboard** | Compete with classmates via XP-based rankings |
| **Link Parent** | Connect up to 2 parent accounts for monitoring |

### 👩‍🏫 Teacher Portal
| Feature | Description |
|---|---|
| **Teacher Dashboard** | Overview of all created classes with student counts and quick actions |
| **Class Management** | Create, edit, and delete classes with subject tagging |
| **Content Management** | Add YouTube videos and assignments to any class |
| **Quiz Builder** | Create MCQ quizzes with configurable time limits and multiple questions |
| **Student Enrollment** | Invite and manage students via email search |
| **Quiz Insights** | View per-student quiz results with AI-generated analytical remarks |
| **Student Progress** | Detailed per-student progress views across content and quizzes |

### 👪 Parent Portal
| Feature | Description |
|---|---|
| **Parent Dashboard** | At-a-glance view of all linked children's academic activity |
| **Child Class Details** | Deep dive into each child's enrolled classes and content |
| **Quiz Insights** | View quiz scores with AI-generated supportive remarks tailored for parents |
| **Notification Center** | Real-time notifications for quiz scores, badge achievements, and milestones |
| **Multi-Child Support** | Separate data views and insights for each linked child |

### 🏆 Gamification Engine
- **XP System** — Earn XP for quizzes (20 base + 50 bonus for perfect scores), assignments (15 XP), and daily logins (10 XP)
- **Leveling** — 100 XP per level with visual progress bars
- **Badge System** — Unlock collectible badges:
  - 🏅 **Quiz Rookie** — Complete your first quiz
  - ⭐ **Quiz Pro** — Complete 5 quizzes
  - 🏆 **Perfectionist** — Achieve 3 perfect scores
  - ⚡ **XP Hunter** — Accumulate 500+ XP
  - 🎓 **Veteran Learner** — Reach Level 10
- **Daily Login Streaks** — Consecutive day tracking with streak XP rewards
- **Global Reward Overlay** — Animated toast notifications for XP gains, level-ups, and badge unlocks
- **Achievements Screen** — Beautiful showcase of all earned badges and stats

### 🤖 AI Integration (Google Gemini)
- **AI Buddy Chatbot** — Context-aware conversational AI tutor with:
  - Child-friendly personality with emoji-rich responses
  - Chat history for contextual follow-ups
  - Star rewards for smart questions and correct answers
  - Quick reply chips for guided learning
- **AI Quiz Evaluator** — Post-quiz analysis that generates:
  - Covered & understood topics
  - Focus areas for improvement
  - Personalized remarks for parents and teachers

### 🎨 UI/UX Highlights
- **Material 3 Design** with dynamic color schemes
- **Dark Mode** support with system-level theming
- **Lottie Animations** throughout the app (empty states, loading, drawer header, AI Buddy FAB)
- **Glassmorphism** on authentication screens
- **Native Splash Screen** with custom branding
- **Custom Fonts** — Google Sans & Poppins
- **Smooth transitions** and micro-animations via `flutter_animate`

---

## 🏗 Architecture

```
┌──────────────────────────────────────────────────────┐
│                    Presentation Layer                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │ Student  │  │ Teacher  │  │     Parent       │   │
│  │  Views   │  │  Views   │  │     Views        │   │
│  └────┬─────┘  └────┬─────┘  └───────┬──────────┘   │
│       │              │               │               │
│  ┌────┴──────────────┴───────────────┴──────────┐   │
│  │            Shared Components                  │   │
│  │  (Widget Tree, Settings, Gamification, Auth)  │   │
│  └──────────────────┬───────────────────────────┘   │
├─────────────────────┼────────────────────────────────┤
│                Service Layer                         │
│  ┌─────────────┐ ┌──────────────┐ ┌──────────────┐  │
│  │Auth Service │ │Firestore     │ │AI Service    │  │
│  │             │ │Service       │ │(Gemini)      │  │
│  ├─────────────┤ ├──────────────┤ ├──────────────┤  │
│  │Notification │ │Gamification  │ │AI Quiz       │  │
│  │Service      │ │Event Bus     │ │Evaluator     │  │
│  └─────────────┘ └──────────────┘ └──────────────┘  │
├──────────────────────────────────────────────────────┤
│                  Backend (Firebase)                   │
│  ┌──────────┐ ┌───────────┐ ┌────────────────────┐  │
│  │  Auth    │ │ Firestore │ │    Storage         │  │
│  └──────────┘ └───────────┘ └────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

---

## 🛠 Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart 3.x) |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **AI Engine** | Google Gemini 2.0 Flash (Generative AI) |
| **Video Player** | YouTube Player Flutter |
| **Animations** | Lottie, Flutter Animate |
| **State Management** | ValueNotifier, StreamBuilder, FutureBuilder |
| **Authentication** | Firebase Auth + Google Sign-In |
| **Design System** | Material 3 with custom theming |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.4+)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Android Studio / VS Code
- A Firebase project with Firestore, Auth, and Storage enabled
- A [Google AI Studio](https://aistudio.google.com/) API key for Gemini

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Sarthak-Jadhav-Dev/Edtech-App.git
   cd Edtech-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable **Email/Password** and **Google Sign-In** in Authentication
   - Create a **Cloud Firestore** database
   - Download your `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate platform directories
   - Update `lib/firebase_options.dart` with your project config (or use `flutterfire configure`)

4. **Gemini AI Setup**
   - Get an API key from [Google AI Studio](https://aistudio.google.com/)
   - Replace the API key in:
     - `lib/services/ai_service.dart`
     - `lib/services/ai_quiz_evaluator.dart`

5. **Run the app**
   ```bash
   flutter run
   ```

### Firestore Security Rules

Ensure your Firestore rules are configured for role-based access. A basic starter:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    match /classes/{classId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /notifications/{notifId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point & theme configuration
├── firebase_options.dart              # Firebase configuration
│
├── models/
│   └── chat_message_model.dart        # AI chatbot message model
│
├── services/
│   ├── auth_services.dart             # Email, Google Sign-In, account management
│   ├── firestore_service.dart         # All Firestore CRUD operations
│   ├── ai_service.dart                # Gemini AI chatbot integration
│   ├── ai_quiz_evaluator.dart         # AI-powered quiz analysis
│   ├── notification_service.dart      # Parent notification system
│   ├── gamification_event_bus.dart    # Reactive reward event stream
│   ├── app_state.dart                 # First-launch state management
│   ├── chat_firestore_service.dart    # Chat persistence
│   └── theme_notifier.dart            # Dark/Light theme toggle
│
└── views/
    ├── widget_tree.dart               # Role-based routing & navigation
    │
    ├── auth_pages/
    │   ├── signin.dart                # Sign-in screen with glassmorphism
    │   └── signup.dart                # Sign-up screen with role selection
    │
    ├── pages/
    │   ├── login.dart                 # Landing / onboarding page
    │   ├── home.dart                  # Student home wrapper
    │   └── home_section/
    │       ├── home_page.dart         # Student dashboard feed
    │       ├── profile_page.dart      # User profile management
    │       └── shared_components.dart # Reusable UI widgets
    │
    ├── student/
    │   ├── course_list.dart           # Available courses browser
    │   ├── class_detail_screen.dart   # Class content (videos, quizzes, assignments)
    │   ├── take_quiz_screen.dart      # Interactive timed quiz UI
    │   ├── quiz_result_screen.dart    # Post-quiz results & AI insights
    │   ├── assignment_view_screen.dart# Assignment details & submission
    │   ├── progress_dashboard.dart    # Visual progress tracking
    │   ├── achievements_screen.dart   # XP, levels, and badge showcase
    │   ├── link_parent_screen.dart    # Parent account linking
    │   ├── chatbot/
    │   │   ├── chatbot_screen.dart    # AI Buddy chat interface
    │   │   └── widgets/
    │   │       ├── chat_bubble.dart   # Chat message bubbles
    │   │       └── quick_reply_chips.dart # Suggested reply buttons
    │   └── widgets/
    │       └── class_leaderboard.dart # XP-based class rankings
    │
    ├── teacher/
    │   ├── teacher_dashboard.dart     # Teacher home with class overview
    │   ├── create_course.dart         # Class creation form
    │   ├── class_detail_screen.dart   # Manage class content & quizzes
    │   ├── add_content_screen.dart    # Add videos/assignments
    │   ├── create_quiz_screen.dart    # Quiz builder UI
    │   ├── enroll_user_screen.dart    # Student enrollment by email
    │   ├── quiz_results_screen.dart   # View all quiz submissions
    │   ├── teacher_quiz_insights.dart # AI insights per student
    │   ├── teacher_student_list.dart  # Enrolled students list
    │   └── teacher_student_detail.dart# Individual student progress
    │
    ├── parent/
    │   ├── parent_dashboard.dart      # Multi-child overview dashboard
    │   ├── child_class_detail.dart    # View child's class content
    │   ├── child_quiz_insights.dart   # AI quiz insights for child
    │   └── notification_center.dart   # Real-time notification feed
    │
    └── common/
        ├── settings_page.dart         # App settings & theme toggle
        ├── youtube_player_screen.dart # In-app YouTube video player
        └── gamification/
            └── global_reward_overlay.dart  # Animated XP/badge toast system
```

---

## 📊 Firestore Data Model

```
├── users/{uid}
│   ├── firstName, lastName, email, userType
│   ├── xp, level, quizzesTaken, perfectScores
│   ├── badges[], linkedParentIds[], linkedChildIds[]
│   ├── currentStreak, lastLoginDate
│   ├── progress/{videoId}          → watchedPercentage, completed
│   └── submissions/{contentId}     → classId, status, submittedAt
│
├── classes/{classId}
│   ├── name, description, subject, teacherId
│   ├── enrolledStudents[], enrolledParents[]
│   ├── content/{contentId}         → title, type, url, videoId
│   ├── quizzes/{quizId}            → title, questions[], timeLimitMinutes
│   ├── quiz_results/{resultId}     → studentId, score, aiInsights
│   └── student_progress/{uid}      → per-student tracking data
│
└── notifications/{notifId}
    ├── recipientId, studentId, studentName
    ├── title, message, type, timestamp, isRead
```

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

Please ensure your code follows Flutter linting standards (`flutter analyze`) and includes appropriate documentation.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Sarthak Jadhav**

- GitHub: [@Sarthak-Jadhav-Dev](https://github.com/Sarthak-Jadhav-Dev)

---

<div align="center">

**Built with ❤️ using Flutter & Firebase**

*Empowering the next generation of learners through AI and gamification.*

</div>
