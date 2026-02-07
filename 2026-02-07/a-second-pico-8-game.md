# Generate a Pico-8 Game

The idea from the [previous challenge](../2025-09-07/a-pico-8-game.md) was to use a game design document (GDD) and then let Gemini generate the code.

Snake-like games were among the first that generative AI could write, and Gemini 2.5 managed to create a working Pico-8 game with only a few minor errors.

This challenge increased the difficulty slightly by introducing:
1. Animation when creatures move between tiles.
2. Multiple levels with varying victory conditions.

---

## A Brief Reflection

This challenge proved to be much harder for Gemini than expected. Both Gemini 2.5 and 3 were used to generate the code. A separate [GDD](karavan_gdd.md) was used to design the tile-based arena, where a slime creature could move and be animated during transitions between tiles.

The second part of the challenge was to create the game logic, including different levels with unique victory conditions. A second [GDD](gdd.md) described the actual game mechanics.

### Observations
Using a GDD to guide the AI worked well, but even a small increase in complexity made it significantly harder for Gemini to generate the game. Common issues included:
- Overly verbose code with unnecessary methods.
- Frequent syntax errors.
- Missunderstandigs of game mechanics that was described in gdd.

The development process took much longer than the previous snake game.

Despite these challenges, it’s impressive that Gemini can generate Lua code for the Pico-8 platform.

*Note: The GDDs are written in Swedish but can easily be translated to English.*

---

## The Result

The final game is available on Lexaloffle:
**[The Slime Trail Society](https://www.lexaloffle.com/bbs/?pid=183379#p)**

The code is included in this folder.
