# 📘 README

## 🌟 Overview
https://github.com/user-attachments/assets/972cd7d4-bb49-4c70-932b-205e3d5c4828
- **PicCollegeTest** is a SwiftUI demo for **timeline trimming**.  
- It showcases how to connect **Repository → UseCase → ViewModel → View** in a single feature screen, building a clean end-to-end architecture from data to presentation.

---

## 🚀 Demo Features

### 🏗️ Architecture Showcase
- The feature view initializes the **Repository, Domain UseCases, and ViewModel** before rendering SwiftUI sections, clearly demonstrating **Clean Architecture boundaries**.

### 🎨 Custom Component Demonstration
- **KeyTimeSelectionView**: Animates pink buttons for key-time markers with an optional indicator bar.  
- **ScrollingWaveformTrimmer**: Uses a fixed half-width selection frame, renders the waveform, supports drag gestures, and fills playback progress in green.

### 💾 Data Management Strategy
- An **in-memory repository** normalizes and sorts key-time markers, returning instant cached data for immediate rendering.

### 🔄 State Management
- The ViewModel uses `@Published` properties to store state, clamps the selection window, formats outputs, and coordinates a **Combine playback clock** to safely manage play/pause actions on the main run loop.

---

## 🗂️ Project Architecture

<img width="827" height="772" alt="截圖 2025-09-30 下午2 00 55" src="https://github.com/user-attachments/assets/47fcec1e-b36c-4de4-ae9a-cd69d629c74d" />

- The SwiftUI app entry loads **ContentView**, which injects the feature view - **TimelineFeatureView**.
- The **TimelineFeatureView** injects its domain/data stack.
- [**HLD UML**](https://drive.google.com/file/d/17wrR5KOqR2oMUJerBoClmJChUvTKxn6u/view?usp=sharing)

### 🔑 Core UseCases

#### 📌 GetTimelineUseCase
- **Responsibility**: Reads a `Timeline` from `TimelineRepository`, separating the responsibility of data retrieval from UI/ViewModel.  
- **Rule / Side effects**: No side effects. The data source can be swapped (memory, network, disk), and the ViewModel does not need to know the details.  
- **Interaction**: Used in `TimelineFeatureViewModel.refreshTimeline()`.  

#### 📌 JumpToKeyTimeUseCase
- **Responsibility**: When the user taps a key time, calculates the new start percentage (`startPercent`).  
- **Rule / Side effects**:  
  1. Future extensibility for snapping or easing jump strategies.  
  2. Always normalized through `StartBounds.clamp(_:)` to stay within a valid range (0…1 and right boundary `1 - selectionRatio`).  
  3. No side effects.  
- **Interaction**: Called inside `TimelineFeatureViewModel.onUserTappedKeyTime`.  

#### 📌 PlaybackClockUseCase
- **Responsibility**: Provides a timer mechanism that “fills the green progress bar every second” and exposes progress updates via a `Publisher (indexPublisher)`. Responsible for starting, pausing, and resetting playback.  
- **Rule / Side effects**:  
  1. Increments once per second, automatically stops at the end of the selection window, and sends a final index. Communicates only via Publisher, never touching the UI directly.  
  2. Has side effects: creates/cancels `Timer` and manages internal state (`current`, `end`, `isPlaying`).  
- **Interaction**:  
  1. `TimelineFeatureViewModel` subscribes to `indexPublisher`, converts the index into elapsed seconds → percentage → UI progress updates.  
  2. The ViewModel decides when to call `play() / pause() / reset()`.  

---

## 🏆 Key Achievements
- **Clean Architecture**: Protocol-based use cases and repositories ensure isolation across Data, Domain, and Presenter layers.  
- **MVVM Pattern**: `TimelineFeatureView` binds to `TimelineFeatureViewModel` with observable state and formatting helpers.  
- **Custom Components**: Encapsulated SwiftUI views for the key-time selector and waveform trimmer, designed for reuse.  
- **Data Caching**: Repository caches a normalized timeline in memory for fast repeated fetches.

---

## ✅ Feature Checklist
- [x] **Dual selection readouts**: Percent and mm:ss labels remain synchronized through ViewModel formatting.  
- [x] **Animated key-time markers**: Pink buttons snap and animate when selecting key times.  
- [x] **Half-width waveform selection**: Fixed-width selection frame with drag gestures, bounded scrolling, and green progress fill.  
- [x] **Playback controls with auto-stop**: Play/Pause/Reset buttons drive the playback clock, which stops automatically after the selection duration.  
- [x] **Start clamp & range protection**: Enforces a 10-second selection window with business rules in both gestures and ViewModel logic.  
- [x] **Preloaded timeline dataset**: Repository ships with default key-time markers for instant rendering.  
