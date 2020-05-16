; Here is place for your custom display list definition.
; Handy constants are defined first:

DL_BLANK1 = 0; // 1 blank line
DL_BLANK2 = %00010000; // 2 blank lines
DL_BLANK3 = %00100000; // 3 blank lines
DL_BLANK4 = %00110000; // 4 blank lines
DL_BLANK5 = %01000000; // 5 blank lines
DL_BLANK6 = %01010000; // 6 blank lines
DL_BLANK7 = %01100000; // 7 blank lines
DL_BLANK8 = %01110000; // 8 blank lines

DL_DLI = %10000000; // Order to run DLI
DL_LMS = %01000000; // Order to set new memory address
DL_VSCROLL = %00100000; // Turn on vertical scroll on this line
DL_HSCROLL = %00010000; // Turn on horizontal scroll on this line

DL_MODE_40x24T2 = 2; // Antic Modes
DL_MODE_40x24T5 = 4;
DL_MODE_40x12T5 = 5;
DL_MODE_20x24T5 = 6;
DL_MODE_20x12T5 = 7;
DL_MODE_40x24G4 = 8;
DL_MODE_80x48G2 = 9;
DL_MODE_80x48G4 = $A;
DL_MODE_160x96G2 = $B;
DL_MODE_160x192G2 = $C;
DL_MODE_160x96G4 = $D;
DL_MODE_160x192G4 = $E;
DL_MODE_320x192G2 = $F;

DL_JMP = %00000001; // Order to jump
DL_JVB = %01000001; // Jump to begining

; It's always useful to include your program global constants here
    icl 'const.inc'

; and declare display list itself

dl_start
    dta DL_BLANK8 + DL_DLI                                                                  ; // 8 blank lines + color change in next row                                                   
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME)                               ; // 22 rows ANTIC 2, color change every row, adding horizontal scrolling     
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 1))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 2))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 3))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 4))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 5))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 6))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 7))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 8))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 9))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 10))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 11))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 12))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 13))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 14))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 15))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 16))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 17))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 18))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 19))
    dta DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, a(SCREEN_GAME + (MAXWIDTH * 20))
    dta DL_BLANK8                                               
    dta DL_BLANK8 + DL_DLI                                                                  ; // 8 blank lines (blank row) + color change in next row
    dta DL_MODE_40x24T2 + DL_LMS, a(SCREEN_BOTTOM)                                          ; // 1 row ANTIC 2
    ; dta DL_BLANK8                                                                           ; // 8 blank lines
    dta DL_JVB, a(dl_start)                                                                 ; // jump to beginning

