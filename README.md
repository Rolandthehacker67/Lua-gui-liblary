# 💎 Amethyst Admin v3.0 — Crystal Edition

**The most beautiful and feature-rich admin GUI library for Roblox.**

![Version](https://img.shields.io/badge/version-3.0.0-purple)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## ✨ Features

### 🎨 Stunning Amethyst Theme
- Deep purple crystal aesthetic with gradient accents
- Glassmorphism effects with animated glow
- Floating particle crystal system
- Smooth animated transitions on every interaction

### 📊 Dashboard
- Real-time FPS & Ping monitoring
- Player count tracking
- Server info (Job ID, Place ID, Server Age)
- Quick actions: Respawn All, Heal All, Freeze/Unfreeze

### 👥 Player Management
- Searchable player list with live avatars
- Teleport to / Bring players
- Spectate mode
- Detailed player info viewer

### ⌨️ Command System
- Text command input with `:prefix` support
- Quick command buttons (Speed, Jump, Gravity)
- Full command reference panel

### 🎨 Visual Controls
- FOV slider with live preview
- Free camera mode
- Lighting controls (Time, Brightness, Fog)
- Ambient presets: Amethyst Night, Golden Hour, Midnight, Crystal Cave
- Fullbright, Noclip, Invisible toggles
- Character material changer (Neon, Glass, ForceField, etc.)

### 🌀 Teleportation
- Teleport to Sky / Ground
- Save & Load position
- Random player teleport
- Custom waypoint system

### 🖥️ Server Tools
- Day/Night toggle
- Fog control
- Server rejoin
- Anti-AFK (toggleable)
- Auto Respawn

### 📜 Script Executor
- Multi-line code editor
- Execute with error handling
- Clear editor button

### ⚙️ Settings
- Toggle particle effects
- Toggle sound effects
- UI Scale slider (70%–130%)
- Keybind reference

### 🔔 Notification System
- Slide-in notifications with progress bars
- 5 types: Info, Success, Warning, Danger, Amethyst
- Auto-dismiss with smooth animations

---

## 🚀 Quick Start

```lua
-- Load Amethyst Admin v3.0
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_REPO/main/AmethystAdmin.lua"))()
```

### Keybinds
| Key | Action |
|-----|--------|
| `Right Shift` | Toggle GUI |
| `T` (hold) | Quick Teleport |

---

## 🖼️ Loading Screen

Amethyst Admin features a stunning animated loading screen with:
- 💎 Pulsing crystal logo with rotating glow rings
- Floating amethyst particle effects
- Multi-stage progress bar with shimmer effect
- Loading status text with percentage
- Smooth fade-out transition

---

## 🏗️ Architecture

```
AmethystAdmin.lua
├── Services & Config
├── Theme Engine (Full Amethyst palette)
├── Utility Functions (Create, Tween, Gradient, Glow, Sound)
├── Loading Screen (Animated crystal intro)
├── Notification System (Toast notifications)
├── Particle System (Floating crystals)
├── Main Window (Draggable, resizable)
├── Title Bar (Logo, title, window controls)
├── Sidebar Navigation (8 tabs with icons)
├── UI Components
│   ├── Section headers
│   ├── Cards with glass borders
│   ├── Buttons with hover/click effects
│   ├── Toggles with smooth animations
│   ├── Sliders with gradient fills
│   ├── Text inputs with focus glow
│   ├── Dropdowns with expand animation
│   └── Stat cards with icons
├── 8 Tab Panels
│   ├── Dashboard
│   ├── Players
│   ├── Commands
│   ├── Visuals
│   ├── Teleport
│   ├── Server
│   ├── Scripts
│   └── Settings
├── Status Bar (Version, players, time)
├── Window Controls (Close, Minimize, Maximize)
├── Real-time Updates (FPS, Ping, Players)
└── Cleanup Handlers
```

---

## 🎭 Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| Primary | `#9333EA` | Main accent |
| Primary Light | `#C084FC` | Highlights |
| Primary Dark | `#581C87` | Deep accents |
| Background | `#0A0714` | Main bg |
| Surface | `#16102A` | Cards, inputs |
| Text | `#F5F0FF` | Primary text |
| Success | `#4ADE80` | Positive actions |
| Danger | `#F87171` | Destructive actions |
| Warning | `#FBBF24` | Caution |
| Info | `#60A5FA` | Informational |

---

## 📝 License

MIT License — Built with 💜 for the Roblox community.

---

*Made by the Amethyst Dev Team*
