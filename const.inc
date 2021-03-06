//
// ;*** define your project wide constants here
// 
// ;*** I like to keep memory locations at top of this file
//

// Relative addressing
FREE_BOTTOM = $4000;                               // This address has to be higher then address shown as $DATA from compilator output.
SCREEN_GAME = FREE_BOTTOM;                         // Screen memory address of game's middle section area
SCREEN_BOTTOM = SCREEN_GAME + $900;                // Screen memory address of game's bottom row area
DISPLAY_LIST_GAME = SCREEN_BOTTOM + $100;
DISPLAY_LIST_TITLE = DISPLAY_LIST_GAME + $100;
PMG_BASE = DISPLAY_LIST_TITLE + $100;               // Player Missle Graphics
SCREEN_TITLE = PMG_BASE + $800;                     // Screen memory address of Title Screen 

RMT_PLAYER_ADDRESS = $6000;                         // RMT Player address NOTE: It concumes some memory before that address so we have to make sure it stays free
RMT_MODULE_TITLE = $6800;                           // RMT Module to play, song played during Title Screen
//RMT_MODULE_GAME = $8000;                          // RMT Module to play during game

CHARSET_TITLE1 = $9C00;
CHARSET_TITLE2 = CHARSET_TITLE1 + $400;         // Font size is 1KB which is $400 in hex
CHARSET_TITLE3 = CHARSET_TITLE2 + $400;
CHARSET_GAME = CHARSET_TITLE3 + $400;

////////////////////////////////////////////////////////////////////////////////////////////////////                          
// and here goes all other stuff

NONE = $ff;

MAXWIDTH = 96;
MAXHEIGHT = 21;
ROWLIMIT = 8;
////////////////////////////////////////////////////////////////////////////////////////////////////

TILEMAX = 4;
SUP = 70;
SDOWN = 71;
SPLANE = 77;
SPAD = 78;

////////////////////////////////////////////////////////////////////////////////////////////////////

SPLANELEFT = 14;
SPLANERIGHT = 15;
SFRAME = 10;
SFRAMEINV = 138;

////////////////////////////////////////////////////////////////////////////////////////////////////