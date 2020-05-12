program Shon;
{$librarypath '../mads/blibs/'}
uses atari, crt, joystick, rmt, b_crt;

const
{$i const.inc}
    // display list is translated to asm in dlist_title.asm
    // bellow code taken from g2f is left here for comparison 
	// dlist: array [0..34] of byte = (
	// 	$C4,lo(scr),hi(scr),
	// 	$84,$84,$84,$84,$84,$84,$84,$84,
	// 	$84,$84,$84,$84,$84,$84,$84,$84,
	// 	$84,$84,$84,$84,$84,$84,$84,$84,
	// 	$84,$84,$84,$84,$04,
	// 	$41,lo(word(@dlist)),hi(word(@dlist))
	// );


	fnt_Title: array [0..29] of byte = (
		hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),
		hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),
		hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE3),hi(CHARSET_TITLE2),hi(CHARSET_TITLE3),hi(CHARSET_TITLE3),
		hi(CHARSET_TITLE3),hi(CHARSET_TITLE3),hi(CHARSET_TITLE3),hi(CHARSET_GAME),hi(CHARSET_GAME),hi(CHARSET_GAME)
	);

	c0_Title: array [0..29] of byte = (
		$10,$10,$10,$10,$10,$10,$10,$10,
		$10,$10,$10,$10,$10,$10,$10,$10,
		$D4,$D4,$D4,$D4,$D4,$D4,$D4,$D4,
		$D4,$D4,$D4,$D4,$D4,$00
	);

	c1_Title: array [0..29] of byte = (
		$14,$14,$14,$14,$14,$14,$14,$14,
		$14,$14,$14,$14,$14,$14,$14,$14,
		$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,
		$D8,$D8,$D8,$D8,$D8,$00
	);

	c2_Title: array [0..29] of byte = (
		$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C,
		$8E,$1C,$1C,$1C,$1C,$1C,$1C,$1C,
		$DC,$DC,$DC,$DC,$DC,$DC,$DC,$DC,
		$DC,$DC,$DC,$DC,$DC,$00
	);

	c3_Title: array [0..29] of byte = (
		$0E,$0E,$8E,$8C,$8A,$86,$84,$82,
		$80,$00,$02,$04,$06,$08,$0A,$0C,
		$FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC,
		$FC,$FC,$FC,$FC,$FC,$00
	);

	// c0_Game: array [0..19] of byte = (
	// 	$8C,$8A,$88,$86,$84,$82,$80,$00,
    //     $02,$04,$06,$08,$0A,$0c,$00,$00,
    //     $00,$00,$00,$00
	// );

	// c1_Game: array [0..19] of byte = (
	// 	$14,$14,$14,$14,$14,$14,$14,$14,
	// 	$14,$14,$14,$14,$14,$14,$14,$14,
	// 	$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,
	// 	$D8,$D8,$D8,$D8,$D8,$00
	// );

	// c2_Game: array [0..19] of byte = (
	// 	$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C,
	// 	$8E,$1C,$1C,$1C,$1C,$1C,$1C,$1C,
	// 	$DC,$DC,$DC,$DC,$DC,$DC,$DC,$DC,
	// 	$DC,$DC,$DC,$DC,$DC,$00
	// );

	// c3_Game: array [0..19] of byte = (
	// 	$0E,$0E,$8E,$8C,$8A,$86,$84,$82,
	// 	$80,$00,$02,$04,$06,$08,$0A,$0C,
	// 	$FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC,
	// 	$FC,$FC,$FC,$FC,$FC,$00
	// );


{$r resources.rc}               // including resource files with all assets
{$i types.inc}                  // including defined type

var
    gamestate: TGameState;
    music: Boolean;

    msx: TRMT;
    old_vbl,old_dli:pointer;
    x: Byte; // accessory variable in loops
    // tmp: Word;
    hposition: Byte=0;
    // hposition: Byte = $91;       //; variable used to store HSCROL value
    // pc: ^byte;
    count: Byte;


{$i 'strings.inc'}              // including strings
{$i interrupts.inc}

// -----------------------------------------------------------------------------
// auxiliary procedures


procedure print_bottom( x: Byte; s: String);
// prints string at x position on bottom row (1 line)
begin
  CRT_Init(SCREEN_BOTTOM,40,1);
  CRT_GotoXY(x,0);
  CRT_Write(s);
end;

procedure print_game( x: Byte; y: Byte; s: String);overload;
// prints string at x,y position in game area
begin
  CRT_Init(SCREEN_GAME,SCREENWIDTH,21);      // 48 x 21 is size of screen with scroll (+ 8 bytes more)
  CRT_GotoXY(x,y);
  CRT_Write(s);

end;

procedure print_game( x: Byte; y: Byte; b: Byte);overload;
// prints byte at x,y position in game area
begin
  CRT_Init(SCREEN_GAME,SCREENWIDTH,21);      // 48 x 21 is size of screen with scroll (+ 8 bytes more)
  CRT_GotoXY(x,y);
  CRT_Write(chr(b));             // adding 32 bytes to display in ANTIC
end;



// -----------------------------------------------------------------------------


procedure show_title;
// Procedure to display title screen on start
begin
    SetIntVec(iVBL, @vbl_title);
    SetIntVec(iDLI, @dli_title);
    // sdlstl := word(@dlist_title);	// ($230) = @dlist_title, New DLIST Program

    // assign display list to TITLE screen
    SDLSTL := DISPLAY_LIST_TITLE;

    savmsc:= SCREEN_TITLE;

    // clear screen memory
    fillbyte(pointer(SCREEN_TITLE+1080), 120, 0);   // size 120 (3 x 40 chars in 1 line); + 960 of screen (40 x 24 chars) + (3 x 40 chars) for last 3 lines;
    
    repeat
        pause;
    until (consol = CN_START) or (strig0 = 0 ); 
    gamestate:=GAMEINPROGRESS;
end;

// -----------------------------------------------------------------------------

procedure show_game;
(*
   main game procedure
   displays game screen
*)
begin
    SetIntVec(iVBL, @vbl_game);
    SetIntVec(iDLI, @dli_game1);
    sdmctl := byte(normal or enable or missiles or players or oneline);
    
    // assign display list to GAME screen
    SDLSTL := DISPLAY_LIST_GAME;

    // setting up game playfield font
    chbas:= Hi(CHARSET_GAME);


    fillbyte(pointer(SCREEN_GAME), 2048, 0);    //  clearing SCREEN_GAME memory
    fillbyte(pointer(SCREEN_BOTTOM), 40, 0);   // size 40 (40 x 1 chars);

    //starting position of hscrol
    ATARI.hscrol:=15;

    count:=0; hposition:=0;
    // pc:=pointer(DISPLAY_LIST_GAME);
    // inc(pc, 28); 
    // tmp := pc^+6;
    
    color1:=$0e;
    // print_game(5,9,'Terrain test'~);

    // for x:=5 to 50 do
    // begin
    //     print_game(x,18,$4D);
    // end;
    
    // print_bottom(0,strings[1]);


    repeat
        pause;pause;
    until keypressed;

    //temporarly to test loop
    gamestate:= GAMEOVER
end;






// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------



begin
    CursorOff;
    Randomize;

(*  initialize RMT player  *)
    msx.player := pointer(RMT_PLAYER_ADDRESS);
    msx.modul := pointer(RMT_MODULE_TITLE);
    msx.Init(0);


    sdmctl := byte(normal or enable or missiles or players or oneline);

(*  set and run vbl interrupt *)
    GetIntVec(iVBL, old_vbl);
    GetIntVec(iDLI, old_dli);

    nmien := $c0;			// $D40E = $C0, Enable DLI
    
(*  your code goes here *)
    // clearing up screen memory space
    // size depends on display list dlist_game.asm


       
    music:=false;    
    gamestate:= GAMEINPROGRESS; // NEWGAME;

    while true do
    begin
      case gamestate of
        NEWGAME: show_title;
        GAMEINPROGRESS: show_game;
        // GAMEOVER: gameover;
      end;
    end;

        
(*  restore system interrupts *)
    // SetIntVec(iVBL, @old_vbl);
    // SetIntVec(iDLI, old_dli);
    // nmien := $40; // turn off dli

end.
