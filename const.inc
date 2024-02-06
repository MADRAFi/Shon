//
// ;*** define your project wide constants here
// 
// ;*** I like to keep memory locations at top of this file
//

// Relative addressing
FREE_BOTTOM = $5000;                               // This address has to be higher then address shown as $DATA from compilator output.
SCREEN_GAME = FREE_BOTTOM;                         // Screen memory address of game's middle section area
SCREEN_BOTTOM = SCREEN_GAME + $900;                // Screen memory address of game's bottom row area
DISPLAY_LIST_GAME = SCREEN_BOTTOM + $100;
DISPLAY_LIST_TITLE = DISPLAY_LIST_GAME + $100;

PMG_BASE = $6000;               // Player Missle Graphics
SCREEN_TITLE = PMG_BASE + $800;                     // Screen memory address of Title Screen 

RMT_PLAYER_ADDRESS = $7000;                         // RMT Player address NOTE: It concumes some memory before that address so we have to make sure it stays free
RMT_MODULE_TITLE = $7800;                           // RMT Module to play, song played during Title Screen
//RMT_MODULE_GAME = $8000;                          // RMT Module to play during game

CHARSET_TITLE1 = $9C00;
CHARSET_TITLE2 = CHARSET_TITLE1 + $400;         // Font size is 1KB which is $400 in hex
CHARSET_TITLE3 = CHARSET_TITLE2 + $400;
CHARSET_GAME = CHARSET_TITLE3 + $400;

////////////////////////////////////////////////////////////////////////////////////////////////////                          
// and here goes all other stuff

NONE = $ff;

MAXWIDTH = 96;
VIEWWIDTH = 48;   // needs to be half of MAXWIDTH
MAXHEIGHT = 21;
// ROWLIMIT = 8;
HPOSMIN = 0;
HPOSMAX = 3;
POFFSET = 6; //  player position -6 correction for 1/2 size of p_spriteHeight

////////////////////////////////////////////////////////////////////////////////////////////////////

UP = 0;
PLAIN = 1;
DOWN = 2;
PAD = 3;
WARN = 4;


TILEMAX = 5;
STAGEMAX = 4;

SUPT = 102;
SDOWNT = 103;
SPLAINT = 109;
SPADT = 110;

SUPB = 70;
SDOWNB = 71;
SPLAINB = 77;
SPADB = 78;
SWARN = 3;

////////////////////////////////////////////////////////////////////////////////////////////////////

SPLAINLEFTT = 107;
SPLAINRIGHTT = 108;
SSLOPELEFTT = 105;
SSLOPERIGHTT = 111;


SPLAINLEFTB = 75;
SPLAINRIGHTB = 76;
SSLOPELEFTB = 73;
SSLOPERIGHTB = 79;


SFRAME = 10;
SFRAMEINV = 138;

////////////////////////////////////////////////////////////////////////////////////////////////////
TILEROCKETMAX = 4;
MAXROCKETSLAUNCH = 3;

SENGINE1 = 66;
SENGINE2 = 67;
SENGINE3 = 72;
SENGINE4 = 69;

SHEAD1 = 11;
SHEAD2 = 12;
SHEAD3 = 13;
SHEAD4 = 14;

////////////////////////////////////////////////////////////////////////////////////////////////////

TILETOWERMAX = 4;

SBASET1 = 112;
SBASET2 = 113;
SBASET3 = 114;
SBASET4 = 112;

STOPT1 = 116;
STOPT2 = 117;
STOPT3 = 118;
STOPT4 = 119;

SBASEB1 = 97;
SBASEB2 = 98;
SBASEB3 = 99;
SBASEB4 = 82;

STOPB1 = 84;
STOPB2 = 85;
STOPB3 = 86;
STOPB4 = 87;

////////////////////////////////////////////////////////////////////////////////////////////////////

KEY_LEFT_CODE = 6;
KEY_RIGHT_CODE = 7;
KEY_UP_CODE = 14;
KEY_DOWN_CODE = 15;
