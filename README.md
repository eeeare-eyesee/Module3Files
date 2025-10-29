# Dungeon Adventure Game

This is a practice project where you'll build a text-based dungeon adventure game in Python. The goal is to apply your understanding of variables, operators, lists, dictionaries, loops, and conditionals.

## Project Overview

You will build a game where:
- The player moves through 5 rooms in a dungeon.
- The player can choose to search for treasure, move forward, check their health and inventory, or quit.
- Searching for treasure has a risk: the player may find a treasure or trigger a trap that reduces their health.
- The game ends when the player finishes all rooms, quits, or loses all their health.
- At the end, the game displays the player’s final health, inventory of treasures, and the total treasure value.

## Concepts Practiced
- Variables and operators
- Lists and dictionaries
- Loops and conditional logic
- The `random` module
- Writing docstrings and organizing functions

## Instructions
1. Fork and Clone this repository to your local machine.
2. Open the project folder in VS Code or your preferred editor.
3. Open `dungeon_adventure.py`, read the docstrongs and implement the TODOs in each function.
4. Run the game from the terminal:
   - macOS/Linux: `python3 dungeon_adventure.py`
   - Windows: `python dungeon_adventure.py`
5. Play through the game and iterate on your code as needed.
6. When finished, save, add, commit, and push your work back to your GitHub repository.

## Implementation Checklist
-  `setup_player()` returns a dict with name, health, and inventory.
-  `create_treasures()` returns a dict of treasure names mapped to integer values.
-  `display_options(room_number)` prints the 4 choices.
-  `search_room(player, treasures)` randomly yields a treasure or a trap and updates the player.
-  `check_status(player)` prints health and inventory contents.
-  `end_game(player, treasures)` prints final summary including total treasure value.
-  `run_game_loop(player, treasures)` manages room flow, choices, and exit conditions.

## Stretch Goals (optional)
- Create a dictionary of traps with varying damage levels.
- Implement a scoring system that combines health and treasure value.
- Allow players to play multiple rounds and track high scores across games.
- Add a healing potion event with limited uses.
- Gate certain rooms behind a key that must be found first.

## Submission
Submit the link to your completed GitHub repository in OpenClass when finished.

