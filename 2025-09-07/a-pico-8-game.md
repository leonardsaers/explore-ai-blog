# Generate a pico 8 game

This is the result after working together with Gemini 2.5 to generate a simple game. The idea is to describe the game in a game design document, and then let Gemini generate the code.

As of today, Gemini is excellent at generating simpler games using JavaScript, but could Gemini also generate a Lua-based game on the Pico 8 platform?

## The Game Design Document

The first step was to ask Gemini to generate a simple game design (GDD) document for Snake. The document describes the characters, challenges, and game mechanics.

The second step was to ask Gemini to generate code for that game in Lua and on the Pico 8 platform. The genereated code could then be inserted in Pico 8 and verified.

This process could then be repeated, where the game document was updated with more details about the story, the characters and game mechanics, and the generated code was tested and verified on Pico 8. This process should be done in small steps where you start with simple game mechanics and step by step builds up more compex game mechanics.

## Helping out with manual tasks

You have to create the sprites and sounds your self in the Pico 8 platform. Gemini instructs you which sprites and sound trakst that should be created.

## Problems with syntax errors and buggs

Gemini was instructed to create the first version of the code with the most simple game mechanics. That code was tested in Pico 8, and Gemini could then get the feedback it needed to make the code work.

Sometimes, the code contained syntax errors, or buggs in the game mecanics. By working iterative in small steps it become easy for Gemini to resolve the problems that arised.

## The Result

The final game is uploaded to LexaLoffel: [Chromatic Serpent 1](https://www.lexaloffle.com/bbs/?pid=173516#p)

This is the final [GDD](gdd.md) (it's in Swedish)

The final version of [the lua code](chromatic_serpent.lua)

