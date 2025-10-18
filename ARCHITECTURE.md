# DayRhythm AI - Clean Architecture Documentation

## 📁 Project Structure

```
DayRhythm AI/
├── App/                                    # App entry point and navigation
│   ├── ContentView.swift
│   ├── DayRhythm_AIApp.swift
│   └── Navigation/
│       └── MainTabView.swift
│
├── Core/                                   # Shared resources
│   ├── DesignSystem/                       # Design tokens
│   │   ├── Colors.swift                    # Color palette & hex support
│   │   └── DesignConstants.swift           # Spacing, fonts, sizes
│   └── Extensions/                         # Reusable extensions
│       └── ViewExtensions.swift            # View modifiers
│
└── Features/                               # Feature modules
    └── Home/
        ├── Models/                         # Data models
        │   └── WeekDay.swift
        ├── ViewModels/                     # Business logic
        │   └── HomeViewModel.swift
        └── Views/                          # UI components
            ├── HomeView.swift              # Main container
            └── Components/                 # Reusable components
                ├── TopHeader.swift         # Header container
                ├── HeaderTopBar.swift      # Top bar component
                ├── WeekRowView.swift       # Week row container
                ├── WeekDayCell.swift       # Individual day cell
                └── MonthPickerView.swift   # Month picker sheet
```

## 🏗️ Architecture Principles

### 1. **Separation of Concerns**
- **Models**: Pure data structures (e.g., `WeekDay`)
- **ViewModels**: Business logic and state management
- **Views**: UI components with no business logic
- **Core**: Shared utilities and design system

### 2. **Component Modularity**
Each UI component is:
- **Single Responsibility**: Does one thing well
- **Reusable**: Can be used in different contexts
- **Testable**: Easy to preview and test
- **Composable**: Can be combined to build complex UIs

### 3. **Design System**
Centralized design tokens in `Core/DesignSystem/`:
- **Colors.swift**: Brand colors and theme
- **DesignConstants.swift**: Spacing, fonts, sizes

### 4. **Component Hierarchy**

```
HomeView
└── TopHeader (Container)
    ├── HeaderTopBar (Top section)
    │   ├── Month display
    │   ├── Month picker button
    │   └── Profile button
    └── WeekRowView (Week section)
        └── WeekDayCell × 7 (Individual days)
```

## 🎨 Design System Usage

### Colors
```swift
Color.appPrimary      // Main brand color (#d95639)
Color.appAccent       // Accent color (coral)
```

### Constants
```swift
DesignConstants.Spacing.medium        // 16pt
DesignConstants.FontSize.title        // 44pt
DesignConstants.CornerRadius.large    // 40pt
```

## 🔧 Component Examples

### Creating a New Reusable Component
```swift
struct MyComponent: View {
    let title: String
    let onAction: () -> Void
    
    var body: some View {
        Button(action: onAction) {
            Text(title)
                .font(.system(size: DesignConstants.FontSize.medium))
                .foregroundColor(.white)
        }
    }
}
```

## ✅ Benefits of This Architecture

1. **Maintainability**: Easy to find and modify specific features
2. **Scalability**: Simple to add new features without touching existing code
3. **Reusability**: Components can be reused across the app
4. **Testability**: Each component can be tested in isolation
5. **Collaboration**: Clear structure makes team collaboration easier
6. **Consistency**: Design system ensures consistent UI/UX

## 🚀 Future Enhancements

- Add unit tests for ViewModels
- Add snapshot tests for Views
- Implement dependency injection
- Add analytics tracking
- Create more reusable components
- Add accessibility improvements
