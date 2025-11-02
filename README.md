<div align="center">

# 🌅 DayRhythm AI
<img src="docs/screenshots/logo.PNG" width="100" alt="Logo"/>

### *Reimagine Your Day with Circular Time*

[![Platform](https://img.shields.io/badge/Platform-iOS%2015%2B-blue.svg)](https://www.apple.com/ios/) [![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org) [![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-blue.svg)](https://developer.apple.com/xcode/swiftui/) [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE) [![Backend](https://img.shields.io/badge/Backend-TypeScript-3178C6.svg)](https://www.typescriptlang.org/) [![AI](https://img.shields.io/badge/AI-Groq%20%7C%20Gemini-FF6B6B.svg)](https://groq.com) [![Database](https://img.shields.io/badge/Database-Supabase-3ECF8E.svg)](https://supabase.com) [![Deployment](https://img.shields.io/badge/Deployed%20on-Vercel-000000.svg)](https://vercel.com)

**DayRhythm AI** is a revolutionary iOS scheduling app that transforms how you visualize and manage your day. Instead of traditional linear calendars, experience time as it naturally flows—in a **circular 24-hour dial** inspired by the Circle of Time Planner methodology.

[Features](#-features) • [Demo](#-demo) • [Installation](#-installation) • [Architecture](#-architecture) • [API](#-api-documentation) • [Contributing](#-contributing)

</div>

---

## 📱 Demo

### App Walkthrough

<div align="center">

</div>

#### Screenshots

<div align="center">

<table>
  <tr>
    <td><img src="docs/screenshots/IMG_2043.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2044.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2045.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2046.PNG" width="200"/></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/IMG_2047.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2048.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2049.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2050.PNG" width="200"/></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/IMG_2051.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2052.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2053.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2054.PNG" width="200"/></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/IMG_2055.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2056.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2057.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2058.PNG" width="200"/></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/IMG_2059.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2060.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2061.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2062.jpg" width="200"/></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/IMG_2063.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2064.jpg" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2074.jpg" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2066.PNG" width="200"/></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/IMG_2067.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2068.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2069.PNG" width="200"/></td>
    <td><img src="docs/screenshots/IMG_2070.jpg" width="200"/></td>
  </tr>
</table>

</div>

---

## ✨ Features

### 🎨 Revolutionary Circular Time Visualization

- **24-Hour Circular Dial** - View your entire day as a clock face with colored event arcs
- **Multiple View Modes** - Switch between 24h full day, AM (12h daytime), PM (12h nighttime), or Auto mode
- **Live Time Tracking** - Animated pointer showing current time with real-time updates
- **Drag-to-Reschedule** - Intuitively adjust event times by dragging on the dial
- **3D Motion Effects** - Tilt-responsive dial using device accelerometer for depth
- **Swipe Navigation** - Effortlessly move between days with left/right gestures

### 🤖 AI-Powered Smart Scheduling

- **Natural Language Processing** - Type "Meeting at 3pm tomorrow and gym at 6pm" → instant structured tasks
- **Intelligent Time Inference** - Automatically determines AM/PM based on context ("breakfast at 8" = 8 AM)
- **Bulk Task Creation** - Create multiple events from a single sentence
- **Smart Emoji Selection** - AI picks relevant emojis for each task type (👥 meetings, 💪 gym, etc.)
- **Context-Aware Colors** - Automatic color assignment based on activity category
- **Premium AI Models** - Choose between Groq (fast & free) or Gemini Pro (advanced)
- **Image-Based Parsing** - Upload photos of schedules/notes for instant digitization (up to 3 images)

### 📊 Advanced Analytics & Insights

- **5 AI-Generated Insights** - Personalized productivity analysis for each day
- **Visual Time Breakdown** - Interactive pie chart showing time distribution by category
- **24-Hour Timeline** - Hourly bar chart for granular schedule visualization
- **Quick Stats Dashboard** - Total tasks, scheduled hours, and free time at a glance
- **Work-Life Balance Gauge** - Track harmony between professional and personal activities
- **Energy Heatmap** - Identify peak productivity periods
- **Focus Blocks Analysis** - Measure uninterrupted work sessions

### 🔗 Seamless Integration

- **Apple Calendar Sync** - Two-way synchronization with native Calendar app
- **Reminders Integration** - Bi-directional sync with iOS Reminders
- **Cloud Backup** - Automatic backup to Supabase with conflict resolution
- **Widget Extension** - Lock screen & home screen widgets showing current/next event
- **Live Activities** - iOS 18+ real-time event tracking on Dynamic Island
- **Push Notifications** - Customizable reminders for each task

### 🎯 Powerful Task Management

- **Rich Task Details** - Title, description, emoji, color, time, category, and participants
- **Visual Task Cards** - Beautiful cards below dial showing all events for the day
- **Completion Tracking** - Mark tasks as done with checkmarks
- **Color-Coded Categories** - Organize by work, personal, health, social, etc.
- **Quick Edit** - Long-press on dial or cards for instant editing
- **Smart Defaults** - 1-hour duration, context-based emoji/color suggestions

### 🔐 Security & Privacy

- **Email/Password Authentication** - Secure login via Supabase Auth
- **OAuth Ready** - Google Sign-In infrastructure in place
- **Session Persistence** - Secure token storage in iOS Keychain
- **Row-Level Security** - Database queries automatically filtered by user
- **End-to-End Encryption** - All data encrypted in transit and at rest
- **Local-First Architecture** - Full offline functionality with optional cloud sync

### ⚙️ Customization & Settings

- **24h/12h Toggle** - Switch between time formats globally
- **Clock Mode Preferences** - Set default view (24h, AM, PM, Auto)
- **Notification Settings** - Granular control per task or global defaults
- **Calendar Permissions** - Optional calendar and reminders access
- **Data Management** - View storage usage and clear old data
- **Theme Options** - Widget color theme customization

---

## 🏗 Architecture

### System Overview

```mermaid
graph TB
    A[iOS App - SwiftUI] -->|REST API| B[Backend - Express/TypeScript]
    A -->|Auth| C[Supabase Auth]
    A -->|Database| D[Supabase PostgreSQL]
    A -->|Local Storage| E[UserDefaults/Keychain]
    A -->|Calendar| F[EventKit/Apple Calendar]
    B -->|AI Models| G[Groq Llama 3.3 70B]
    B -->|Premium AI| H[Google Gemini Pro]
    B -->|Auth Verification| C
    B -->|Database| D
    I[Widget Extension] -->|Shared Storage| E
    I -->|Display| J[Lock Screen/Home Screen]
```

### iOS App Structure

```
DayRhythm AI/
├── App/
│   ├── DayRhythm_AIApp.swift          # App entry point with notification setup
│   ├── ContentView.swift              # Main content routing
│   ├── AppState.swift                 # Global app state management
│   └── Navigation/
│       └── MainTabView.swift          # Tab bar navigation
├── Features/
│   ├── Home/                          # Main screen with circular dial
│   │   ├── HomeView.swift
│   │   ├── HomeViewModel.swift
│   │   ├── CircularDayDial.swift     # Core circular visualization
│   │   ├── TaskCard.swift            # Task card component
│   │   └── Subfeatures/
│   │       ├── Calendar/             # Week view, month picker
│   │       ├── Tasks/                # Create, edit, detail sheets
│   │       └── Analytics/            # Charts, insights, stats
│   ├── AISchedule/                   # Natural language input
│   │   ├── AIScheduleView.swift
│   │   └── AIScheduleViewModel.swift
│   ├── Authentication/               # Login/signup
│   │   ├── AuthenticationService.swift
│   │   ├── AuthenticationViewModel.swift
│   │   ├── LoginSheet.swift
│   │   └── SignupSheet.swift
│   ├── Settings/                     # User preferences
│   │   ├── SettingsView.swift
│   │   ├── NotificationSettingsView.swift
│   │   └── CalendarSettingsView.swift
│   ├── Inbox/                        # Task inbox
│   └── Timeline/                     # Calendar timeline view
├── Services/
│   ├── API/
│   │   └── BackendService.swift      # REST API client
│   ├── Authentication/
│   │   └── AuthenticationService.swift
│   ├── Calendar/
│   │   └── EventKitService.swift     # Apple Calendar integration
│   ├── CloudSync/
│   │   └── CloudSyncService.swift    # Supabase sync
│   └── Notifications/
│       └── NotificationService.swift
├── Core/
│   ├── Managers/
│   │   ├── StorageManager.swift      # Local persistence
│   │   └── MotionManager.swift       # Accelerometer
│   ├── Models/
│   │   ├── DayEvent.swift            # Main event model
│   │   └── User.swift                # User model
│   ├── DesignSystem/
│   │   ├── Colors.swift              # Color palette
│   │   └── DesignConstants.swift     # Typography, spacing
│   ├── Extensions/                   # Swift extensions
│   └── Components/                   # Reusable UI components
├── Config/
│   └── Config.swift                  # API URLs and keys
└── Shared/
    └── SharedStorageManager.swift    # Widget data sharing

Widget Extension:
DayRhythmWidget/
├── DayRhythmWidget.swift             # Widget configuration
├── SimplifiedCircularDial.swift      # Mini dial visualization
├── Provider.swift                    # Timeline data provider
├── DayRhythmWidgetControl.swift      # Control widget
└── DayRhythmWidgetLiveActivity.swift # iOS 18 Live Activity
```

### Backend Structure

```
DayRhythm-AI-Backend/
├── src/
│   ├── config/
│   │   └── env.ts                    # Environment validation (Zod)
│   ├── controllers/
│   │   ├── ai.controller.ts          # AI logic (insights, parsing)
│   │   └── events.controller.ts      # Event management (future)
│   ├── middleware/
│   │   ├── supabaseAuth.ts           # JWT verification
│   │   ├── errorHandler.ts           # Global error handling
│   │   └── rateLimiter.ts            # Rate limiting (100/15min)
│   ├── routes/
│   │   ├── ai.routes.ts              # /api/ai/* endpoints
│   │   ├── events.routes.ts          # /api/events/* endpoints
│   │   └── index.ts                  # Route aggregation + health
│   ├── types/
│   │   └── express.d.ts              # TypeScript extensions
│   └── server.ts                     # Express app setup
├── dist/                             # Compiled JavaScript
├── package.json
├── tsconfig.json
├── .env.example
└── vercel.json                       # Deployment configuration
```

### Design Patterns

- **MVVM (Model-View-ViewModel)** - Clear separation of concerns
- **Observable Pattern** - Reactive state management with Combine
- **Service Layer** - Centralized API and business logic
- **Repository Pattern** - Data access abstraction (Storage, Cloud, Calendar)
- **Dependency Injection** - Loose coupling for testability
- **Singleton Pattern** - Shared managers (Storage, Motion, Config)

### Data Models

**DayEvent** (iOS)
```swift
struct DayEvent: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String?
    var emoji: String
    var startHour: Double        // 24-hour format (e.g., 15.5 = 3:30 PM)
    var endHour: Double
    var color: Color
    var colorHex: String
    var category: String?
    var participants: [String]?
    var isCompleted: Bool
    var syncStatus: SyncStatus   // local/synced/pending/conflict
    var cloudId: String?         // Supabase ID
    var ekEventIdentifier: String? // Apple Calendar ID
    var notificationSettings: NotificationSettings?
}
```

**WidgetEventData** (Shared)
```swift
struct WidgetEventData: Codable {
    let id: UUID
    let title: String
    let startHour: Double
    let endHour: Double
    let colorHex: String
    let emoji: String
}
```

**ParsedTask** (Backend)
```typescript
interface ParsedTask {
    title: string
    description?: string
    startTime: number    // 24-hour decimal
    endTime: number
    date: string         // YYYY-MM-DD
    emoji: string
    colorHex: string
    category?: string
}
```

### Technology Stack

#### iOS App
| Technology | Purpose |
|------------|---------|
| **SwiftUI** | Declarative UI framework |
| **Combine** | Reactive programming for state management |
| **EventKit** | Apple Calendar & Reminders integration |
| **UserNotifications** | Push notifications & reminders |
| **CoreMotion** | Accelerometer for 3D tilt effects |
| **Supabase Swift SDK** | Authentication & database client |
| **WidgetKit** | Widget extension & Live Activities |

#### Backend
| Technology | Purpose |
|------------|---------|
| **TypeScript** | Type-safe server-side code |
| **Express.js** | Web framework for REST API |
| **Groq SDK** | Llama 3.3 70B AI model access |
| **Google Gemini** | Premium AI & vision capabilities |
| **Supabase JS** | Database client & JWT verification |
| **Zod** | Runtime type validation |
| **Helmet.js** | Security headers |
| **express-rate-limit** | API rate limiting |

#### Infrastructure
| Service | Purpose |
|---------|---------|
| **Supabase** | PostgreSQL database + Auth + Storage |
| **Vercel** | Serverless backend deployment |
| **Groq Cloud** | Fast AI inference (14,400 req/day free) |
| **Google AI Studio** | Gemini API for premium features |

---

## 🚀 Installation

### Prerequisites

- **Xcode 15+** (for iOS development)
- **iOS 15+** device or simulator
- **Node.js 18+** and npm (for backend)
- **Supabase Account** (free tier works)
- **Groq API Key** (free at [console.groq.com](https://console.groq.com))
- Optional: **Google Gemini API Key** (free at [aistudio.google.com](https://aistudio.google.com))

### iOS App Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/kartikayy007/dayrhythm-ai.git
   cd dayrhythm-ai
   ```

2. **Open Xcode project**
   ```bash
   open "DayRhythm AI/DayRhythm AI.xcodeproj"
   ```

3. **Configure Supabase credentials**

   Update `DayRhythm AI/DayRhythm AI/Config/Config.swift`:
   ```swift
   struct Config {
       static let backendURL = "https://your-backend.vercel.app"
       static let supabaseURL = "https://your-project.supabase.co"
       static let supabaseAnonKey = "your-anon-key-here"
   }
   ```

4. **Set up Supabase database**

   Run this SQL in your Supabase SQL Editor:
   ```sql
   -- Create events table
   CREATE TABLE events (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       user_id UUID REFERENCES auth.users(id) NOT NULL,
       title TEXT NOT NULL,
       description TEXT,
       start_time DECIMAL NOT NULL,
       end_time DECIMAL NOT NULL,
       date DATE NOT NULL,
       emoji TEXT NOT NULL,
       color_hex TEXT NOT NULL,
       category TEXT,
       is_completed BOOLEAN DEFAULT FALSE,
       created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

   -- Enable Row Level Security
   ALTER TABLE events ENABLE ROW LEVEL SECURITY;

   -- Create policy: users can only see their own events
   CREATE POLICY "Users can view own events"
       ON events FOR SELECT
       USING (auth.uid() = user_id);

   CREATE POLICY "Users can insert own events"
       ON events FOR INSERT
       WITH CHECK (auth.uid() = user_id);

   CREATE POLICY "Users can update own events"
       ON events FOR UPDATE
       USING (auth.uid() = user_id);

   CREATE POLICY "Users can delete own events"
       ON events FOR DELETE
       USING (auth.uid() = user_id);

   -- Create indexes for performance
   CREATE INDEX idx_events_user_date ON events(user_id, date);
   CREATE INDEX idx_events_created_at ON events(created_at DESC);
   ```

5. **Enable Calendar permissions** (optional)

   In `DayRhythm-AI-Info.plist`, ensure these keys exist:
   ```xml
   <key>NSCalendarsUsageDescription</key>
   <string>DayRhythm AI needs access to sync your events with Apple Calendar</string>
   <key>NSRemindersUsageDescription</key>
   <string>DayRhythm AI needs access to sync with your Reminders</string>
   ```

6. **Build and run**
   - Select your target device or simulator
   - Press `⌘ + R` or click the Play button
   - The app will launch on your device

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd DayRhythm-AI-Backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` with your credentials:
   ```env
   # Server Configuration
   PORT=3000
   NODE_ENV=development

   # Supabase (get from https://supabase.com/dashboard)
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_SERVICE_KEY=your-service-role-key-here
   SUPABASE_ANON_KEY=your-anon-key-here

   # AI Models
   GROQ_API_KEY=gsk_your_groq_key_here
   GEMINI_API_KEY=AIzaSy_your_gemini_key_here

   # CORS (optional, defaults to *)
   CORS_ORIGIN=*
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

   Server will start at `http://localhost:3000`

5. **Test the API**
   ```bash
   # Health check
   curl http://localhost:3000/api/health

   # Should return: {"status":"ok","timestamp":"..."}
   ```

### Deploy Backend to Vercel

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Deploy**
   ```bash
   vercel
   ```

   Follow the prompts and add environment variables in Vercel dashboard.

3. **Update iOS Config**

   Change `Config.swift` to point to your Vercel URL:
   ```swift
   static let backendURL = "https://your-project.vercel.app"
   ```

---

## 🔌 API Documentation

### Base URL
```
Production: https://--------vercel.app
Development: http://localhost:3000
```

### Authentication
All endpoints except `/api/health` require a JWT token from Supabase.

**Headers:**
```http
Authorization: Bearer <your-supabase-jwt-token>
Content-Type: application/json
```

### Endpoints

#### Health Check
```http
GET /api/health
```

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-11-03T12:00:00.000Z"
}
```

---

#### Generate Day Insights
```http
POST /api/ai/insights
```

**Request Body:**
```json
{
  "date": "2025-11-03"
}
```

**Response:**
```json
{
  "insights": [
    "Great balance between meetings and focused work time!",
    "Consider scheduling breaks between back-to-back meetings.",
    "You have a productive afternoon planned with 3 deep work blocks.",
    "Morning is heavily scheduled - try to preserve some buffer time.",
    "Excellent time allocation for health with gym and meal times!"
  ],
  "date": "2025-11-03"
}
```

---

#### Parse Natural Language Schedule
```http
POST /api/ai/parse-schedule
```

**Request Body:**
```json
{
  "prompt": "Team standup at 10am tomorrow, lunch with Sarah at 1pm, gym at 6pm"
}
```

**Response:**
```json
{
  "tasks": [
    {
      "title": "Team Standup",
      "description": "Daily team sync",
      "startTime": 10.0,
      "endTime": 11.0,
      "date": "2025-11-04",
      "emoji": "👥",
      "colorHex": "#4A90E2",
      "category": "work"
    },
    {
      "title": "Lunch with Sarah",
      "description": "",
      "startTime": 13.0,
      "endTime": 14.0,
      "date": "2025-11-04",
      "emoji": "🍽️",
      "colorHex": "#F5A623",
      "category": "social"
    },
    {
      "title": "Gym",
      "description": "",
      "startTime": 18.0,
      "endTime": 19.0,
      "date": "2025-11-04",
      "emoji": "💪",
      "colorHex": "#7ED321",
      "category": "health"
    }
  ]
}
```

---

#### Parse Schedule (Premium - Gemini)
```http
POST /api/ai/parse-schedule-pro
```

Same request/response format as `/parse-schedule` but uses Google Gemini for more accurate parsing of complex schedules.

---

#### Parse Schedule from Image
```http
POST /api/ai/parse-schedule-image
```

**Request Body:**
```json
{
  "image": "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
  "prompt": "Extract my schedule for tomorrow"
}
```

**Response:**
```json
{
  "tasks": [
    // Array of parsed tasks from image
  ]
}
```

**Limits:**
- Max image size: 4MB
- Supported formats: JPEG, PNG, WEBP
- Can parse handwritten notes, printed schedules, screenshots

---

#### Parse Multiple Images
```http
POST /api/ai/parse-schedule-images
```

**Request Body:**
```json
{
  "images": [
    "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
    "data:image/PNG;base64,iVBORw0KGgoAAAAN...",
    "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
  ],
  "prompt": "Extract schedule from these meeting notes"
}
```

**Response:** Same as single image endpoint

**Limits:**
- Max 3 images per request
- Total combined size < 10MB

---

#### Generate Analytics
```http
POST /api/ai/analytics
```

**Request Body:**
```json
{
  "startDate": "2025-11-01",
  "endDate": "2025-11-07"
}
```

**Response:**
```json
{
  "summary": "You had a productive week with 42 total tasks...",
  "totalTasks": 42,
  "completedTasks": 38,
  "totalHours": 56.5,
  "categoryBreakdown": {
    "work": 32.5,
    "personal": 12.0,
    "health": 8.0,
    "social": 4.0
  },
  "averageTasksPerDay": 6,
  "mostProductiveDay": "2025-11-03",
  "suggestions": [
    "Consider scheduling more breaks",
    "Great work-life balance this week!"
  ]
}
```

---

#### Get Task Insight
```http
POST /api/ai/task-insight
```

**Request Body:**
```json
{
  "title": "Write Project Proposal",
  "description": "Draft proposal for new client project",
  "startTime": 14.0,
  "endTime": 16.0,
  "category": "work"
}
```

**Response:**
```json
{
  "insight": "This 2-hour block is well-suited for focused writing. Consider breaking into 45-minute segments with short breaks.",
  "suggestions": [
    "Block calendar notifications during this time",
    "Prepare outline beforehand to maximize efficiency",
    "Schedule in a quiet environment"
  ],
  "estimatedFocusLevel": "high"
}
```

---

### Rate Limits

- **100 requests per 15 minutes** per IP address
- Exceeding limit returns `429 Too Many Requests`
- Premium users: Contact for increased limits

### Error Responses

**401 Unauthorized**
```json
{
  "error": "Unauthorized",
  "message": "Missing or invalid authentication token"
}
```

**400 Bad Request**
```json
{
  "error": "Bad Request",
  "message": "Invalid request body",
  "details": ["date is required", "prompt must be a string"]
}
```

**500 Internal Server Error**
```json
{
  "error": "Internal Server Error",
  "message": "An unexpected error occurred"
}
```

---

## 🧪 Testing

### Run Backend Tests
```bash
cd DayRhythm-AI-Backend
npm test
```

### Manual API Testing

Use the included Postman collection or curl:

```bash
# Set your token
TOKEN="your-supabase-jwt-token"

# Test insights
curl -X POST https://day-rhythm-ai-backend.vercel.app/api/ai/insights \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"date":"2025-11-03"}'

# Test natural language parsing
curl -X POST https://day-rhythm-ai-backend.vercel.app/api/ai/parse-schedule \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Meeting at 3pm and gym at 6pm"}'
```

---

## 📊 Project Metrics

| Metric | Count |
|--------|-------|
| **iOS Swift Code** | ~14,800 lines |
| **Backend TypeScript** | ~1,700 lines |
| **Total iOS Files** | 91+ Swift files |
| **Backend Files** | 12 TypeScript files |
| **Features** | 6 major modules |
| **Services** | 6 service classes |
| **API Endpoints** | 8 endpoints |

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Getting Started

1. **Fork the repository**
   ```bash
   git clone https://github.com/kartikayy007/dayrhythm-ai.git
   cd dayrhythm-ai
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation if needed

3. **Test your changes**
   - Ensure iOS app builds without errors
   - Test all affected features manually
   - Run backend tests if applicable

4. **Commit with clear messages**
   ```bash
   git commit -m "Add: Description of your feature"
   ```

   Use prefixes: `Add:`, `Fix:`, `Update:`, `Refactor:`, `Docs:`

5. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

   Then open a Pull Request on GitHub.

   ----

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 DayRhythm AI

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

- **Circle of Time Planner** by X17 for the circular time visualization inspiration
- **Groq** for lightning-fast AI inference
- **Supabase** for excellent backend-as-a-service
- **Apple** for SwiftUI, WidgetKit, and EventKit
- **Vercel** for seamless serverless deployment
- **Google Gemini** for advanced AI capabilities

---

## 🌟 Star History

If you find DayRhythm AI useful, please consider giving it a ⭐️!

[![Star History Chart](https://api.star-history.com/svg?repos=kartikayy007/dayrhythm-ai&type=Date)](https://star-history.com/#kartikayy007/dayrhythm-ai&Date)

---

<div align="center">

**Made with ❤️ by the Kartikay**

[⬆ Back to Top](#-dayrhythm-ai)

</div>
