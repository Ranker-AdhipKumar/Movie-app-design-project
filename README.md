# 🎬 FlickVault — Modern Flutter Movie Application
> **GDG & DCS Recruitment Task Submission**  
> Built with Flutter & Dart for Android & iOS. Inspired by [Dribbble: Movie Application 03](https://dribbble.com/shots/6444124-Movie-application-03).

---

## 🌟 Overview
**FlickVault** is a cinema browsing mobile application designed with a dark, immersive aesthetic, fluid navigation, and clean architecture.

The project demonstrates:
- **UI/UX Craftsmanship**: Cinema dark mode theme, hero transitions, glassmorphic badges, category filter chips, and an auto-advancing featured carousel.
- **Robust Data Layer**: Dual-source architecture supporting **both** rich offline sample data (10+ blockbusters with full overviews, cast, ratings, and backdrops) **and** live integration with **The Movie Database (TMDB) API**.
- **Clean Architecture**: Strict separation of concerns (Models, Services, Repositories, Config, Widgets, Screens). No API keys are hardcoded in UI files.
- **Resilient UX**: Shimmer-like loading states, graceful network image error fallbacks, live debounced search, and error retry handlers.

---

## ✨ Features

### 1. 🏠 Home Screen
- **Featured Trending Carousel**:
  - Horizontal swipeable hero banner highlighting top trending movies.
  - Smooth page indicator dots and auto-scroll timer.
  - Fire badge, release year, age rating, and vote badge overlay.
- **Category Filter Chip Bar**:
  - Filter movies dynamically by genres: *All, Action, Sci-Fi, Drama, Animation, Comedy, Thriller, Adventure, Fantasy, Crime*.
- **Live Search Bar**:
  - Instant client-side & server-side filter with debounce.
  - Clear button and active search count.
- **Responsive Movie Grid**:
  - Displays movie poster, title, release year, genre tag, and vote score.
  - Interactive bookmark / watchlist toggle with instant feedback.
  - Tap card to navigate smoothly with `Hero` animation.

### 2. 📽️ Movie Detail Screen
- **Collapsible Hero Header**:
  - High-res movie backdrop image that smoothly fades to dark on scroll.
  - Floating Back button to return to the Home Screen.
  - Quick bookmark / watchlist save button.
- **Rich Movie Metadata**:
  - Large elevated movie poster with shared Hero transition.
  - Movie title and official tagline.
  - Rating badge (⭐ `8.4 / 10`) with vote count.
  - Quick Info Bar: **Release Date**, **Duration / Runtime** (e.g. `2h 28m`), **Original Language**, **Age Rating** (PG-13, R, PG).
- **Genre Badges**:
  - Styled genre chips representing all categories of the movie.
- **Storyline & Overview**:
  - Formatted synopsis with expandable **"Read more / Show less"** toggle.
- **Cast & Characters Carousel**:
  - Horizontal list of actors with profile pictures and character names.
- **Action Buttons**:
  - **"Watch Trailer"**: Interactive trailer preview modal sheet.
  - **"Add to Watchlist"**: One-tap toggle with status feedback.

### 3. 🔍 Dedicated Search Screen
- Real-time debounced query to TMDB's `/search/movie` endpoint.
- Popular quick-search recommendation tags (*Oppenheimer, Interstellar, Batman, Dune, etc.*).
- Friendly empty states when no results are found.
- Error state with "Retry Search" button.

### 4. ⚙️ App & API Settings (Evaluator Friendly)
- **Data Source Switcher**: Toggle between **Offline Sample Movies** and **Live TMDB API** with a single tap.
- **In-App API Key Configuration**: Evaluators can enter their own TMDB v3 API key directly within the app without touching code or recompiling.

---

## 🏗️ Project Architecture

```
Movie_App_Design_Project/
├── assets/
│   └── data/
│       └── sample_movies.json       # 10+ rich offline movie records with cast & media
├── lib/
│   ├── main.dart                    # Application entry point & theme initialization
│   ├── config/
│   │   ├── api_config.dart          # Decoupled TMDB URLs & API key management
│   │   ├── app_constants.dart       # App strings, categories, and fallback assets
│   │   └── app_theme.dart           # Custom dark cinema theme & color tokens
│   ├── models/
│   │   ├── movie.dart               # Complete movie domain model with getters & JSON parser
│   │   └── cast_member.dart         # Actor & character data model
│   ├── services/
│   │   ├── tmdb_api_service.dart    # Live HTTP client for TMDB with error handling & timeouts
│   │   └── mock_movie_service.dart  # Offline asset loader with in-memory fallback
│   ├── repositories/
│   │   └── movie_repository.dart    # Repository pattern managing state, mode switching & favorites
│   ├── widgets/
│   │   ├── movie_card.dart          # Card widget for movie grid
│   │   ├── trending_carousel_card.dart # Featured banner card with gradient overlay
│   │   ├── category_chip_bar.dart   # Horizontal genre chips
│   │   ├── rating_badge.dart        # Compact star rating pill
│   │   ├── custom_search_bar.dart   # Styled search field with clear action
│   │   ├── custom_network_image.dart # Resilient network image with placeholder & error fallback
│   │   ├── section_header.dart      # Reusable section header
│   │   └── cast_card.dart           # Circular actor portrait card
│   └── screens/
│       ├── home_screen.dart         # Main browsing screen
│       ├── movie_detail_screen.dart # Detailed movie view with hero transitions
│       ├── search_screen.dart       # Dedicated TMDB search screen
│       └── settings_screen.dart     # API key configuration & data mode toggle
├── test/
│   ├── movie_model_test.dart        # Unit tests for JSON parsing & model helpers
│   └── widget_test.dart             # Widget test for app initialization
├── android/                         # Complete Android project wrapper with Internet permissions
└── pubspec.yaml                     # Dependencies and asset declarations
```

---

## 🚀 How to Run

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed (version 3.0+).
- Android Studio / VS Code with Flutter extension.
- Android Emulator or physical device connected with USB debugging.

### Step 1: Clone the repository
```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd Movie_App_Design_Project
```

### Step 2: Install dependencies
```bash
flutter pub get
```

### Step 3: Run the app
```bash
flutter run
```

> **Note on TMDB API Key**:  
> The app runs **100% out of the box** using the built-in offline dataset (no API key required).  
> To test live TMDB data, either:
> 1. Pass the key at runtime:  
>    ```bash
>    flutter run --dart-define=TMDB_API_KEY=your_api_key_here
>    ```
> 2. Or simply tap the **Settings icon (top right)** in the app and paste your TMDB v3 API Key!

---

## 🧪 Running Tests
Execute the unit and widget test suite:
```bash
flutter test
```

---

## 📦 Building the Android APK

To generate a standalone release APK for demo submission:
```bash
flutter build apk --release
```

The compiled APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📝 Submission Checklist
- [x] **Source Code**: Pushed to public GitHub repository.
- [x] **Screens**: Home Screen with carousel & grid + Movie Detail Screen with back navigation.
- [x] **Images**: Movie posters, backdrops, and cast photos with placeholders and fallbacks.
- [x] **Details**: Title, rating, release year, language, runtime, genres, storyline overview.
- [x] **Bonus**: Real-time search + Category filter chips + Watchlist bookmarking.
- [x] **Data Handling**: 10+ sample movies via JSON + TMDB live API endpoints with error handling.
- [x] **Security**: API key decoupled from UI code with in-app configuration.
- [x] **Clean Code**: Documented, typed Dart code following Flutter lints.
- [x] **APK Build**: Ready for upload to Google Drive.

---

## 🎨 UI Reference & Design Attribution
- Inspired by Dribbble design: [Movie application 03](https://dribbble.com/shots/6444124-Movie-application-03).
- Data & Poster Art provided by [The Movie Database (TMDB)](https://www.themoviedb.org/).
