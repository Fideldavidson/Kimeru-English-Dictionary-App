# Kimeru Dictionary - Implementation Overview

This document provides a technical overview of the Kimeru-English Dictionary project, covering both the mobile application and the web-based administration portal.

## 🏗️ System Architecture

The project is built as a cross-platform solution using **Flutter**.

### 1. Mobile Application (`/mobile`)

- **Target:** Android (primary), iOS (compatible).
- **Role:** Offline-first dictionary for end-users.
- **Data Strategy:** Local storage (SQLite) with background synchronization capability.

### 2. Web Portal (`/web`)

- **Target:** Web Browsers.
- **Role:** Administrative interface for dictionary curators and public search.
- **Data Strategy:** Direct integration with GitHub's REST API for data persistence and content management.

---

## 🛠️ Technology Stack

| Layer                | Mobile (Flutter)                    | Web (Flutter Web)                         |
| :------------------- | :---------------------------------- | :---------------------------------------- |
| **Language**         | Dart                                | Dart                                      |
| **Local Storage**    | `sqflite` (SQLite)                  | `shared_preferences`                      |
| **State Management** | `StatefulWidget` / `ChangeNotifier` | `provider`                                |
| **Networking**       | `http`                              | `http`                                    |
| **Authentication**   | N/A (Client-only)                   | Custom GitHub Personal Access Token (PAT) |
| **Data Source**      | Local Database                      | GitHub API (JSON files)                   |

---

## ✨ Achieved Milestones & Features

### 📱 Mobile Features

- [x] **Dictionary Search:** FAST local searching for Kimeru and English words.
- [x] **Word Details:** Comprehensive view with definitions, examples, and synonyms.
- [x] **Data Seeding:** Automatic initialization of the local database with an expanded dataset on first run.
- [x] **Local Database Service:** Robust SQLite wrapper for word management.
- [x] **GitHub Sync Service:** (In progress/planned) Infrastructure to pull updates from the central repository.

### 🌐 Web Features

- [x] **Admin Dashboard:** Central hub for dictionary maintenance.
- [x] **Review Queue:** Powerful interface for managing proposed word additions and edits.
- [x] **Word Editor:** Interactive dialog for editing dictionary entries.
- [x] **Authentication:** Secure login using GitHub Personal Access Tokens (PAT).
- [x] **Public Search:** Lightweight web interface for public dictionary lookup.

---

## 📂 Directory Structure

- `mobile/`: Contains the Flutter mobile project source code.
- `web/`: Contains the Flutter web project source code.
- `data/`: (If present) Shared assets or JSON dataset templates.
