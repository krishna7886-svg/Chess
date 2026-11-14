# CHESS NEXUS DESIGN SYSTEM SPECIFICATION

## Brand Identity & Creative Direction
- **Brand Name:** CHESS NEXUS
- **Tagline:** Beyond the Board
- **Design Language:** Editorial Luxury Dark Chess Experience, Architectural Minimalist Grid, High-Tactility Feedback.

## Color Palette (Tokens)
- `color.primary.obsidian`: `#080B0A` (Deepest Void Background)
- `color.primary.deep_forest`: `#111A16` (Card and Elevated Surface Background)
- `color.primary.emerald`: `#19382B` (Brand Primary Accent, Dark Squares, Active Elements)
- `color.accent.mint`: `#A6D6B5` (High-Energy Accent, Highlights, Legal Move Indicators)
- `color.accent.champagne`: `#C6A66B` (Rating Badges, Premium Trophies, Master Class)
- `color.surface.ivory`: `#EAE8DF` (Primary Text, Light Squares, High Contrast)
- `color.text.secondary`: `#9CA99F` (Muted Captions, Clocks Standby, Inactive Icons)
- `color.status.danger`: `#E05353` (Check, Blunder, Timeout Warning)
- `color.status.success`: `#38C172` (Best Move, Win Indicator, Solved Puzzle)

## Typography
- **Editorial Display:** Playfair Display / Cormorant Garamond for Grandmaster Headlines, Rating Trophies, and Editorial Storytelling.
- **UI & System:** Inter / Plus Jakarta Sans for clean readability, navigation, buttons, and settings.
- **Game Notation & Clocks:** JetBrains Mono for algebraic notation (SAN), FEN strings, and high-precision digital clocks.

## Spacing & Elevation
- Base grid: 4px / 8px / 16px / 24px / 32px
- Card Radius: 16px
- Button Radius: 12px
- Board Border: 4px solid `#19382B` with 24px drop-shadow `rgba(0, 0, 0, 0.6)`.

## Component Library
1. **NexusBoard:** 64-square grid with dynamic coordinates, last move highlight (mint tint), check glow (crimson pulse), and interactive drag pieces.
2. **DualChessClock:** Monotonic high-contrast time boxes with active player pulsing border and low-time danger states.
3. **MoveHistoryTape:** Horizontal or vertical scrolling algebraic notation ribbon with real-time Stockfish accuracy pills.
4. **EvaluationGauge:** Vertical and horizontal centipawn advantage bar with smooth spring animation.
5. **EditorialCard:** Deep forest container with emerald gradient border and champagne headline typography.

