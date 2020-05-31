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
    chrctl : Byte absolute $D401;
    // accessory variables in loops
    // x: Byte; 
    i: Byte;
    
    

    // variables used for scroll
    hposition: Byte;
    // hscroll_count: Byte;


    newlms: Word;
    lms: Word;
    vi: Byte; // iteration in vbl interrupt


    // terrain positions
    posX: Byte;
    posY: Byte;
    tile: TTerrain = PLANE;
    prev_tile: TTerrain = PLANE;

    // time counter
    time: Word;
    tmp: Word;

    tileset: array [0..TILEMAX-1] of Byte = (SUP, SPLANE, SDOWN, SPLANE, SPLANE);

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
    tmp:=SCREEN_GAME + (MAXWIDTH * y) + 48 + x;
    Poke(tmp, b);
    tmp:=SCREEN_GAME + (MAXWIDTH * y) + x;
    Poke(tmp, b);

end;

procedure print_right(x: Byte; y: Byte; b: Byte);overload;
// prints byte at x,y position in right game area
begin
    Poke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2) + x, b);
end;

procedure print_right(x: Byte; y: Byte; s: String);overload;
// prints byte at x,y position in right game area
begin
    for i:=1 to byte(s[0]) do
    begin
        Poke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2) + x + i, byte(s[i]));
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
    print_line(x, y, byte(s[0]) + 8, SFRAMEINV);
    print_right(x, y + 1, SFRAMEINV); print_right(x + byte(s[0]) + 7, y + 1, SFRAMEINV);
    print_right(x, y + 2, SFRAMEINV); 
    color1:=txtcolor;                   
    print_right(x + 3, y + 2, s);
    color1:=frmcolor;
    print_right(x + byte(s[0]) + 7, y + 2, SFRAMEINV);
    print_right(x, y + 3, SFRAMEINV); print_right(x + byte(s[0]) + 7, y + 3, SFRAMEINV);
    print_line(x, y + 4, byte(s[0]) + 8, SFRAMEINV);
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
    i:=Random(0) and 3;
    case i of
        0: Result:=UP;
        1: Result:=PLANE;
        2: Result:=DOWN;
        3: Result:=PAD;
        // 4: Result:=PLANE;
    end;
end;
// -----------------------------------------------------------------------------



procedure terrain;
(*
   generates terrain
*)

begin
        tile:=RandomTile;
        // tile:=PLANE;
        
        // Top limits check TODO
        // If posY > ROWLIMIT then tile:=UP;
        //
        
        // Bottom limits check
        If (posY <= MAXHEIGHT - ROWLIMIT) and (tile = UP) then
        begin
            tile:=PLANE;
            // Inc(posY); // inc y position to neutralise future dec ( can be replased with a flag)
        end; 
        if (posY >= MAXHEIGHT-2) and (tile = DOWN) then 
        begin
            tile:=PLANE;
            // Dec(posY);  // dec y position to neutralise future inc ( can be replased with a flag)
        end;

        if tile = prev_tile then
        begin 
            if tile = UP then
            begin
                print_game(posX, posY, SPLANERIGHT);
                print_game(posX - 1, posY - 1, SSLOPELEFT); //SSLOPELEFT
                Dec(posY);
            end;
            if tile = DOWN then
            begin
                print_game(posX - 1, posY + 1, SPLANELEFT);
                print_game(posX, posY, SSLOPERIGHT);
                Inc(posY);
            end;
        end
        else
        begin
            ///////////////////////////////////////////////////////////////////////////

            if (tile = UP) and ((prev_tile = PLANE) or (prev_tile = PAD)) then
            begin
                print_game(posX, posY, SPLANERIGHT);
                Dec(posY);
                // print_bottom(20,''~);
            end;
            // if (tile = UP) and (prev_tile = PAD) then
            // begin
            //     print_game(posX, posY, SPLANERIGHT);
            //     Dec(posY);
            //     // print_bottom(20,''~);
            // end;
            if (tile = PLANE) and (prev_tile = DOWN) then
            begin
                Inc(posY);
                print_game(posX - 1, posY, SPLANELEFT);
            end;
            if (tile = UP) and (prev_tile = DOWN) then
            begin
                print_game(posX - 1, posY + 1, SPLANELEFT);
                print_game(posX, posY + 1, SPLANERIGHT);    
            end;
            if (tile = PAD) and (prev_tile = PAD) then
            begin
                tile:= PLANE;
            end;
            if (tile = PAD) and (prev_tile = DOWN) then
            begin
                Inc(posY);
                tile:=PLANE;
                print_game(posX - 1, posY, SPLANELEFT);
            end;
            

            // if (tile = DOWN) and (prev_tile = PLANE) then Inc(posY);

        end;

        print_game(posX, posY, tileset[tile]);
        prev_tile:=tile;

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
    hposition:=$f;
    // hscroll_count:=0;
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
    // color4:=2;
    // print_bottom(0,strings[1]);

    // print_box_right(12, 10, strings[3],$0e);
    // Wait(6);
    // clear_box_right(12, 10, 18, 5);

    // print_bottom(30,'DONE'~);
    
    // setting starting position for terrain
    posX:=0;
    posY:= MAXHEIGHT-1;


    // for posY:=0 to 20 do
    // begin
    //     for posX:=0 to 47 do
    //     begin
    //         print_game(posX,posY,posY+33);
    //         // print_game(posX, posY, tileset[PLANE]);
    //     end;
    // end;


    repeat

        if hposition = $b then
        begin
        	poke($44E0 + posX,0);
            poke($4540 + posX,0);
            poke($45A0 + posX,0);
            poke($4600 + posX,0);
            poke($4660 + posX,0);
            poke($46C0 + posX,0);
            poke($4720 + posX,0);
            poke($4780 + posX,0);

            poke($44E0 + $30 + posX,0);
            poke($4540 + $30 + posX,0);
            poke($45A0 + $30 + posX,0);
            poke($4600 + $30 + posX,0);
            poke($4660 + $30 + posX,0);
            poke($46C0 + $30 + posX,0);
            poke($4720 + $30 + posX,0);
            poke($4780 + $30 + posX,0);
        
            Terrain;
        end;

        print_bottom(35,'  '~);print_bottom(35,posX);
        print_bottom(38,'  '~);print_bottom(38,posY);
        // print_bottom(d,hposition); if d< 40 then inc(d,2);
        WaitFrame;
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
    
    chrctl:=$02;
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
