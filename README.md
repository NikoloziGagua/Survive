# Survive! - 68000 Assembly Survival Challenge

A text-based survival game written in Motorola 68000 Assembly. Players navigate a post-apocalyptic world, managing resources, health, and threats to achieve victory.

## Features

- **Two play styles:**
  - **Survivor** (high risk, high reward)
  - **Explorer** (steady gains, lower risk)
- **Randomized events:**
  - Resource discoveries
  - Threat encounters
  - Healing opportunities
- Score and health management with clear win/lose conditions
- Level progression and detailed on-screen messages

## Prerequisites

- **Easy68K assembler & debugger** (http://www.easy68k.com)
- **Motorola 68000 emulator** or hardware supporting TRAP #15 system calls (e.g., Atari ST/TOS)

## Setup & Build

1. **Clone this repository:**
   ```
   git clone <repo-url>
   cd <repo-directory>
   ```
2. **Open** `PROJECT.X68` in Easy68K.
3. **Assemble the code:**
   - Go to *Assemble* → *Create Output File*
   - Generate a binary or memory image.
4. **Load** the output into your emulator or flash to hardware.

## Usage

1. **Run** the assembled program.
2. **At the main menu, enter:**
   - `1` for Survivor mode
   - `2` for Explorer mode
   - `3` to Exit
3. **During gameplay, when prompted:**
   - Enter a number `1–100` to simulate events.
   - Press `[1]` to continue, `[5]` to restart, or any other key to quit.

## Code Overview

- **Source:** `PROJECT.X68`
- **Constants:** `MIN_RESOURCES`, `MAX_RESOURCES`, `MIN_THREATS`, `MAX_THREATS`, etc.
- **Labels & Handlers:**
  - `WELCOME`, `OBJECTIVE` – Display intro screens
  - `CHOICE_1`, `CHOICE_2` – Initialize game mode parameters
  - `HEALING_EVENT` – Restore health events
  - `FOUND_RESOURCE` – Resource gain events
  - `HIT_THREAT` – Threat encounter handling
  - `GAME_WON`, `GAME_OVER` – Endgame conditions
- **Data Section:** Message definitions via `DC.B` directives (strings displayed to the player).
