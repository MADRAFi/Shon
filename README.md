# Shon
Unfinished Atari 8 bit Shoot up action game

Files Description
=================

All assets are kept in Assets directory. You can find there source files and final versions compiled into the game.
1. compile.bat - Executes compilation process on WIN machines
2. const.inc - ALL Constants used in the game, You can find there Memory allocation segments. More detailed memory allocation can be found in separate file called gamememory.ods
3. dlist_game.asm - Display list for game area screen
4. dlist_title.asm - Display list for title screen
5. game memory.ods - spreadsheet helping in memory allocation. It recalculates memory usage based on the values.
6. interrupts.inc - Interrupt procedures (vbl and dli)
7. resources.rc - Assigining resource files (graphics and music) to constant names.
8. shon.pas - Main game source code
9. strings.asm - Currently unused. You may use it to store strings used in the game or use an array table
10. types.inc - Custom types definitions.
