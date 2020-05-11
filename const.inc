//
// ;*** define your project wide constants here
// 
// ;*** I like to keep memory locations at top of this file
//

// Relative addressing
FREE_BOTTOM = $4000;                                // This address has to be higher then address shown as $DATA from compilator output.  
CHARSET_TITLE1 = FREE_BOTTOM;
CHARSET_TITLE2 = CHARSET_TITLE1 + $400;         // Font size is 1KB which is $400 in hex
CHARSET_TITLE3 = CHARSET_TITLE2 + $400;
CHARSET_GAME = CHARSET_TITLE3 + $400;
DISPLAY_LIST_TITLE = CHARSET_GAME + $400;
DISPLAY_LIST_GAME = DISPLAY_LIST_TITLE + $100;

PMG = $5400;                                        // Player Missle Graphics

RMT_PLAYER_ADDRESS = $8000;                         // RMT Player address NOTE: It concumes some memory before that address so we have to make sure it stays free
RMT_MODULE_TITLE = $8800;                           // RMT Module to play, song played during Title Screen
//RMT_MODULE_GAME = $8800;                          // RMT Module to play during game

SCREEN_TITLE = $AA00;                               // Screen memory address of Title Screen 
SCREEN_GAME = $AE00;                                // Screen memory address of game's middle section area
SCREEN_BOTTOM = $B300;                              // Screen memory address of game's bottom row area
// ;*** and here goes all other stuff

NONE = $ff;

