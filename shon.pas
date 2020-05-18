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

    tileset: array [0..TILEMAX-1] of Byte = (SIGNUP, SIGNPLANE, SIGNDOWN, SIGNPLANE);

    d: Byte = 15; // debug
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
// prints byte at x,y position in left and right game area
begin
    // if hscroll_count > MAXWIDTH div 2 then
    // begin 
        // DPoke(SCREEN_GAME + (MAXWIDTH * y) + x, b);
    //     DPoke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2) + x, b);
    // end
    // else DPoke(SCREEN_GAME + (MAXWIDTH * y) + x, b);
    DPoke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2)-4 + x, b);
end;

// procedure print_game(x: Byte; y: Byte; c: Char);overload;
// // prints byte at x,y position in left and right game area
// begin
//     if hscroll_count > MAXWIDTH div 2 then
//     begin
//         DPoke(SCREEN_GAME + (MAXWIDTH * y) + x+4, byte(c));
//         DPoke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2)-4 + x, byte(c));
//     end
//     else DPoke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2)-4 + x, byte(c));

// end;

procedure print_right(x: Byte; y: Byte; b: Byte);overload;
// prints byte at x,y position in right game area
begin
    DPoke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2) + x, b);
end;

procedure print_right(x: Byte; y: Byte; s: String);overload;
// prints byte at x,y position in right game area
begin
    for i:=1 to byte(s[0]) do
    begin
        DPoke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2) + x + i, byte(s[i]));
    end;    
end;

procedure print_line(x: Byte; y: Byte; n: Byte; sign: Byte);
// prints streight line equal to n at x,y position in game area
begin
    for i:=0 to n - 1 do
    begin
        print_right(x + i, y, sign);
    end;    
end;

procedure print_box_right(x: Byte; y: Byte; s: String; txtcolor: Byte);
// draws a box at x,y position with a text inside and using c as color
const
    frmcolor = $0e;     // color used for frame drawing

begin
    color1:=frmcolor;
    print_line(x, y, byte(s[0]) + 8, SIGNFRAMEINV);
    print_right(x, y + 1, SIGNFRAMEINV); print_right(x + byte(s[0]) + 7, y + 1, SIGNFRAMEINV);
    print_right(x, y + 2, SIGNFRAMEINV); 
    color1:=txtcolor;                   
    print_right(x + 3, y + 2, s);
    color1:=frmcolor;
    print_right(x + byte(s[0]) + 7, y + 2, SIGNFRAMEINV);
    print_right(x, y + 3, SIGNFRAMEINV); print_right(x + byte(s[0]) + 7, y + 3, SIGNFRAMEINV);
    print_line(x, y + 4, byte(s[0]) + 8, SIGNFRAMEINV);
end;

procedure clear_game;
// clears game screen
begin
    //  DPoke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2) + x, 0);
    // fillbyte(pointer(SCREEN_GAME), (MAXWIDTH div 2 ) * MAXHEIGHT,0);
    fillbyte(pointer(SCREEN_GAME), $900, 0);
end;

procedure clear_box_right(x: Byte; y: Byte; sizeX:byte; sizeY:Byte);
// clears box sizex,sizey at x,y in game screen
begin
    for i:=0 to sizeY - 1 do
    begin
        fillbyte(pointer(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH * i) + (MAXWIDTH div 2) + x), sizeX, 0);
    end;
end;

procedure clear_box(x: Byte; y: Byte; sizeX:byte; sizeY:Byte);
// clears box sizex,sizey at x,y in game screen
begin
    for i:=0 to sizeY - 1 do
    begin
        fillbyte(pointer(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH * i) + x), sizeX, 64);
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

function RandomTile : TTerrain;
begin
    // randomize;
    x:=Random(0) and (TILEMAX-1);
    case x of
        0: Result:=UP;
        1: Result:=PLANE;
        2: Result:=DOWN;
        3: Result:=PLANE;
        // 4: Result:=PLANE;
    end;
end;
// -----------------------------------------------------------------------------



procedure terrain;
(*
   generates terrain
*)
var
    tile, prev_tile: TTerrain;

begin
    // tile:=RandomTile;
    tile:=PLANE;
    
    // Bottom limits check
    If (posY < MAXHEIGHT - ROWLIMIT) and (tile = UP) then tile:=PLANE; 
    if (posY+1 >= MAXHEIGHT) and (tile = DOWN) then tile:=PLANE;
    
    // Top limits check TODO
    // If posY > ROWLIMIT then tile:=UP;
    //
    
    // print_bottom(d,tile);
    // inc(d,2);


    if tile = prev_tile then
    begin 
        if tile = UP then
        begin
            print_game(posX + 1, posY, SIGNPLANERIGHT);
            Dec(posY);
        end;
        if tile = DOWN then
        begin
            print_game(posX, posY + 1, SIGNPLANELEFT);
            Inc(posY);
        end;
    end
    else
    begin  
        if (tile = UP) and (prev_tile = PLANE) then
        begin
            print_game(posX + 1, posY, SIGNPLANERIGHT);
            Dec(posY);
        end;
        if (tile = PLANE) and (prev_tile = DOWN) then
        begin
            Inc(posY);
            print_game(posX, posY, SIGNPLANELEFT);
        end;
        if (tile = UP) and (prev_tile = DOWN) then
        begin
            print_game(posX, posY + 1, SIGNPLANELEFT);
            print_game(posX+1, posY + 1, SIGNPLANERIGHT);    
        end;
        // if (tile = DOWN) and (prev_tile = PLANE) then Inc(posY);
    end;

    if posX < MAXWIDTH then
    begin
        Inc(posX);
    end    
    else
    begin
        posX:= 0;
    end;
    // if hscroll_count = 95 then clear_box(0, 0, MAXWIDTH div 2, MAXHEIGHT);
    print_game(posX, posY, tileset[tile]);
    prev_tile:=tile;


    // if posX > 4 then
    // begin
    //     clear_box(posX, 0, 1, MAXHEIGHT);
    // end;    
end;

// -----------------------------------------------------------------------------

// procedure coarse_scroll;
// (*
//    scrolls game's area
// *)

// begin
//     lms := DISPLAY_LIST_GAME + 2;
//     If hscroll_count = MAXWIDTH then
//     begin
//         // resets LMS to default
//         hscroll_count:=1;
//         newlms:=SCREEN_GAME + MAXWIDTH;
//         for i:=0 to 20 do
//         begin
//             dpoke(lms, newlms);
//             Inc(newlms,MAXWIDTH);
//             Inc(lms,3);
//         end;	
//     end
//     else
//     begin
//     	Inc(hscroll_count);
//         // coarse scroll
//         if hposition=0 then
//         begin  
//             for i:=0 to 20 do
//             begin
//                 newlms:=dpeek(lms);
//                 inc(newlms);
//                 dpoke(lms, newlms);
//                 Inc(lms,3);
//             end;
//             hposition:=3;
//         end;
//     end;
//     // if hscroll_count=96 then clear_box(0, 0, MAXWIDTH div 2, MAXHEIGHT);
//     // if hscroll_count=1 then clear_box(MAXWIDTH div 2, 0, MAXWIDTH, MAXHEIGHT);
// end; 
       
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
    hposition:=3;
    hscroll_count:=1;
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


    // print_right(20,8,'Terrain test'~);
    print_bottom(0,strings[1]);

    print_box_right(12, 10, strings[3],$0e);
    // Wait(6);
    // clear_box_right(12, 10, 18, 5);

    // print_bottom(30,'DONE'~);
    
    // setting starting position for terrain
    posX:=0; //MAXWIDTH div 2;
    posY:=MAXHEIGHT;
    
    repeat
        WaitFrame;
        // Terrain;
        // coarse_scroll;
        print_bottom(10,'  '~);print_bottom(10,hscroll_count);
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
