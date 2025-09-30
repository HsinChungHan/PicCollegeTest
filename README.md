# 📘 README

## 🌟 Overview
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

<img width="925" height="793" alt="截圖 2025-09-30 下午1 23 36" src="https://github.com/user-attachments/assets/91248d7c-c170-4b53-bbb0-e4a205530c37" />




- The SwiftUI app entry loads **ContentView**, which injects the feature view - **TimelineFeatureView**.
- The **TimelineFeatureView** injects its domain/data stack.
- [**HLD UML**](https://drive.google.com/file/d/17wrR5KOqR2oMUJerBoClmJChUvTKxn6u/view?usp=sharing)

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

---
