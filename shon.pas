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

    // 
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


{$r resources.rc}               // including resource files with all assets
{$i types.inc}                  // including defined type

var
    gamestate: TGameState;
    music: Boolean;

    msx: TRMT;
    old_vbl,old_dli:Pointer;

    // accessory variables in loops
    x: Byte; 
    i: Byte;

    // variables used for scroll
    hposition: Byte;
    hscroll_count: Byte;
    newlms: Word;
    lms: Word;

    // terrain positions
    posX: Byte;
    posY: Byte;


    // time counter
    time: Word;

{$i 'strings.inc'}
{$i interrupts.inc}

// -----------------------------------------------------------------------------
// auxiliary procedures


procedure print_bottom( x: Byte; s: String);overload;
// prints string at x position on bottom row (1 line)
begin
  CRT_Init(SCREEN_BOTTOM,40,1);
  CRT_GotoXY(x,0);
  CRT_Write(s);
end;

procedure print_bottom( x: Byte; b: Byte);overload;
// prints string at x position on bottom row (1 line)
begin
  CRT_Init(SCREEN_BOTTOM,40,1);
  CRT_GotoXY(x,0);
  CRT_Write(b);CRT_Write('  '~);
end;

procedure print_game(x: Byte; y: Byte; b: Byte);overload;
// prints byte at x,y position in game area
begin
     DPoke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2) + x,b);
end;

procedure print_game(x: Byte; y: Byte; c: Char);overload;
// prints byte at x,y position in game area
begin
     DPoke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2) + x, byte(c));
end;

procedure clear_game;
// clears game screen
begin
    //  DPoke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2) + x, 0);
    // fillbyte(pointer(SCREEN_GAME), (MAXWIDTH div 2 ) * MAXHEIGHT,0);
    fillbyte(pointer(SCREEN_GAME), $900, 0);
end;

procedure print_game(x: Byte; y: Byte; s: String);overload;
// prints byte at x,y position in game area
var
    size: Byte;
begin
    size:=byte(s[0]);
    for i:=1 to size do
    begin
        DPoke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2) + x + i, byte(s[i]));
    end;    
end;
procedure print_line(x: Byte; y: Byte; n: Byte; sign: Byte);
// prints streight line equal to n at x,y position in game area

begin
    for i:=0 to n do
    begin
        print_game(x+i, y, sign);
    end;    
end;


procedure WaitFrame;
begin
     asm {
          lda 20
          cmp 20
          beq *-2
     };
end;

procedure Wait(s:Byte);
// it waits s seconds
begin
    repeat
        waitframe;
    until s = time div 60;
end;

// -----------------------------------------------------------------------------
procedure print_box(x: Byte; y: Byte; s: String; txtcolor: Byte);
// draws a box at x,y position with a text inside and using c as color
const
    frmcolor = $0e;     // color used for frame drawing

begin
    color1:=frmcolor;
    print_game(x, y, SIGNFRAMEINV); print_line(x+1,y,x+3,SIGNFRAMEINV); print_game(x+byte(s[0])+7, y, SIGNFRAMEINV);
    print_game(x, y+1, SIGNFRAMEINV); print_game(x+byte(s[0])+7, y+1, SIGNFRAMEINV);
    print_game(x, y+2, SIGNFRAMEINV); color1:=txtcolor; print_game(x+3, y+2, s); color1:=frmcolor; print_game(x+byte(s[0])+7, y+2, SIGNFRAMEINV);
    print_game(x, y+3, SIGNFRAMEINV); print_game(x+byte(s[0])+7, y+3, SIGNFRAMEINV);
    print_game(x, y+4, SIGNFRAMEINV); print_line(x+1,y+4,x+3,SIGNFRAMEINV); print_game(x+byte(s[0])+7, y+4, SIGNFRAMEINV);
end;


procedure terrain;
(*
   generates terrain
*)
var
    tile, prev_tile: TTerrain;
begin
    tile:= PLANE; //Random(TILEMAX);
    print_game(posX, posY, tile);
    Inc(posX);
    // if tile = prev_tile then
    // begin
    //     if tile = UP then
    //     begin
    //         print_game(posX+1, posY, SIGNPLANERIGHT);
    //         Dec(posY);
    //     end;
    //     if tile = DOWN then
    //     begin
    //         print_game(posX-1, posY, SIGNPLANELEFT);
    //         Inc(posY);
    //     end;
    // end
    // else
    // begin
    //     if (tile = UP) and (prev_tile = PLANE) then
    //     begin
    //         Dec(posY);
    //     end;
    //     if (tile = DOWN) and (prev_tile = PLANE) then Inc(posY);
    // end;

    prev_tile:=tile;
    If posX = MAXWIDTH then posX:= 0;
end;

// -----------------------------------------------------------------------------

procedure show_title;
// Procedure to display title screen on start
begin
    SetIntVec(iVBL, @vbl_title);
    SetIntVec(iDLI, @dli_title);


    // assign display list to TITLE screen
    SDLSTL := DISPLAY_LIST_TITLE;

    savmsc:= SCREEN_TITLE;

    // clear screen memory
    fillbyte(pointer(SCREEN_TITLE+1080), 120, 0);   // size 120 (3 x 40 chars in 1 line); + 960 of screen (40 x 24 chars) + (3 x 40 chars) for last 3 lines;
    
    repeat
        pause;
    until (consol = CN_START) or (strig0 = 0); 
    gamestate:=GAMEINPROGRESS;
end;

// -----------------------------------------------------------------------------

procedure show_game;
(*
   main game procedure
   displays game screen
*)
begin
    hposition:=4;
    hscroll_count:=0;
    SetIntVec(iVBL, @vbl_game);
    SetIntVec(iDLI, @dli_game1);
    sdmctl := byte(normal or enable or missiles or players or oneline);
    
    // assign display list to GAME screen
    SDLSTL := DISPLAY_LIST_GAME;

    // setting up game playfield font
    chbas:= Hi(CHARSET_GAME);


    fillbyte(pointer(SCREEN_GAME), $900, 0);    // size as per memory map
    fillbyte(pointer(SCREEN_BOTTOM), $100, 0);  

    
    color1:=$0e;


    // print_game(20,12,'Terrain test'~);
    print_bottom(0,strings[1]);

    // print_game(12, 10, SIGNFRAMEINV); print_line(13,10,15,SIGNFRAMEINV); print_game(28, 10, SIGNFRAMEINV);
    // print_game(12, 11, SIGNFRAMEINV); print_game(28, 11, SIGNFRAMEINV);
    // print_game(12, 12, SIGNFRAMEINV); print_game(15, 12, 'GET READY'~); print_game(28, 12, SIGNFRAMEINV);
    // print_game(12, 13, SIGNFRAMEINV); print_game(28, 13, SIGNFRAMEINV);
    // print_game(12, 14, SIGNFRAMEINV); print_line(13,14,15,SIGNFRAMEINV); print_game(28, 14, SIGNFRAMEINV);
    print_box(12, 10, strings[3],$0e);
    // setting starting position for terrain
    posX:=0;
    posY:=MAXHEIGHT;

    Wait(6);
    clear_game;
    print_bottom(30,'DONE'~);
    repeat
        WaitFrame;
        // print_bottom(20,'  '~);print_bottom(20,hscroll_count);
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
