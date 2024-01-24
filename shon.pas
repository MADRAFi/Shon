program Shon;
{$librarypath '../blibs/'}
uses atari, crt, joystick, rmt, sysutils;

const
{$i const.inc}


    // 
	// fnt_Title: array [0..29] of byte = (
	// 	hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),
	// 	hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),
	// 	hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE3),hi(CHARSET_TITLE2),hi(CHARSET_TITLE3),hi(CHARSET_TITLE3),
	// 	hi(CHARSET_TITLE3),hi(CHARSET_TITLE3),hi(CHARSET_TITLE3),hi(CHARSET_GAME),hi(CHARSET_GAME),hi(CHARSET_GAME)
	// );

	// c0_Title: array [0..29] of byte = (
	// 	$10,$10,$10,$10,$10,$10,$10,$10,
	// 	$10,$10,$10,$10,$10,$10,$10,$10,
	// 	$D4,$D4,$D4,$D4,$D4,$D4,$D4,$D4,
	// 	$D4,$D4,$D4,$D4,$D4,$00
	// );

	// c1_Title: array [0..29] of byte = (
	// 	$14,$14,$14,$14,$14,$14,$14,$14,
	// 	$14,$14,$14,$14,$14,$14,$14,$14,
	// 	$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,
	// 	$D8,$D8,$D8,$D8,$D8,$00
	// );

	// c2_Title: array [0..29] of byte = (
	// 	$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C,
	// 	$8E,$1C,$1C,$1C,$1C,$1C,$1C,$1C,
	// 	$DC,$DC,$DC,$DC,$DC,$DC,$DC,$DC,
	// 	$DC,$DC,$DC,$DC,$DC,$00
	// );

	// c3_Title: array [0..29] of byte = (
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
    old_vbl,old_dli:Pointer;
    chrctl : Byte absolute $D401;
    // accessory variables in loops
    // x: Byte; 
    i: Byte;
    tmp: TString;
    addressTop: Word;
    addressBottom: Word;
    

    // variables used for scroll
    hposition: Byte;
    scroll: Boolean;

    newlms: Word;
    lms: Word;
    vi: Byte; // iteration in vbl interrupt


    // terrain positions
    posX: Byte;
    posY_top: Byte;
    posY_bottom: Byte;

    tile: TTerrain = NONE;
    prev_tileT: TTerrain = NONE;
    prev_tileB: TTerrain = NONE;

    // gameTime counter
    gameTime: Word;

    currentStage: byte;
    stage: ^TStage;
    stage1: TStage;
    stage2: TStage;
    stage3: TStage;
    stage4: TStage;
    levelStages: array [0..STAGEMAX-1] of Pointer = (@stage1, @stage2, @stage3, @stage4);

    tileset_top: array [0..TILEMAX-1] of Byte = (SUPT, SPLAINT, SDOWNT, SPADT, SWARN);
    tileset_bottom: array [0..TILEMAX-1] of Byte = (SUPB, SPLAINB, SDOWNB, SPADB, SWARN);


{$i 'strings.inc'}
{$i interrupts.inc}

// -----------------------------------------------------------------------------
// auxiliary procedures
function Atascii2Antic(c: char): char; overload;
begin
    asm {
        lda c
        asl
        php
        cmp #2*$60
        bcs @+
        sbc #2*$20-1
        bcs @+
        adc #2*$60
@       plp
        ror
        sta result;
    };
end;

procedure Str2Antic(var s: string);
var i:byte;
begin
    for i:=1 to byte(s[0]) do s[i] := Atascii2Antic(s[i]);
end;

procedure print_bottom( x, y: Byte; s: String);overload;
// prints string at x position on bottom row (1 line)

begin
    Str2Antic(s);

    addressBottom:=SCREEN_BOTTOM + ((VIEWWIDTH - 8) * y) + x;
    move(s[1], pointer(addressBottom), Length(s));  
end;

procedure print_bottom( x, y: Byte; d: Cardinal);overload;
// prints string at x position on bottom row (1 line)

begin
    tmp:=IntToStr(d);
    Str2Antic(tmp);

    addressBottom:=SCREEN_BOTTOM + ((VIEWWIDTH - 8) * y) + x;
    move(tmp[1], pointer(addressBottom), Length(tmp));  
end;


procedure print_game(x: Byte; y: Byte; b: Byte);overload;
// prints byte at x,y position in left and right game area
begin
    addressTop:=SCREEN_GAME + (MAXWIDTH * y) + VIEWWIDTH + x;
    Poke(addressTop, b);
    addressTop:=SCREEN_GAME + (MAXWIDTH * y) + x;
    Poke(addressTop, b);
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

procedure clear_game(min_row: Byte; max_row: Byte);
// clears game screen
begin
    //  DPoke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2) + x, 0);
    // fillbyte(pointer(SCREEN_GAME), (MAXWIDTH div 2 ) * MAXHEIGHT,0);
    // fillbyte(pointer(SCREEN_GAME), $900, 0);


    // addressBottom:=SCREEN_GAME + (MAXWIDTH * (MAXHEIGHT - stage.maxBottom));
    // inc(addressBottom, posX);
    // for i:=0 to (stage.maxBottom) - 1 do
    // begin
    //     // we ned to clear both sides of the screen when we put tile during terrain procedure
    //     Poke(addressBottom, 0);
    //     Poke(addressBottom + VIEWWIDTH, 0);
    //     inc(addressBottom, MAXWIDTH);
    // end;
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
    until s = gameTime div 60;
end;

function RandomTile : TTerrain;
begin
    i:=Random(0) and 3;
    case i of
        0: Result:=UP;
        1: Result:=PLAIN;
        2: Result:=DOWN;
        3: Result:=PAD;
    end;
end;
// -----------------------------------------------------------------------------



procedure initLevel;
(*
   assembly Level data
   maxTop and maxBottom sum must be lower or equal 18
   differerence between minBottom and maxBottom must be greater or equal 3
   minTop and minBottom must be greater then 2 if maxTop and maxBottom are greater then 1
*)
begin
    stage1.name:= 'Stage 1';
    stage1.numeric:= 1;
    stage1.minTop:= 2;
    stage1.maxTop:= 5;
    stage1.minBottom:= 2;
    stage1.maxBottom:= 5;
    stage1.len:= 2000;

    stage2.name:= 'Stage 2';
    stage2.numeric:= 2;
    stage2.minTop:= 1;
    stage2.maxTop:= 3;
    stage2.minBottom:= 8;
    stage2.maxBottom:= 15;
    stage2.len:= 1200;

    stage3.name:= 'Stage 3';
    stage3.numeric:= 3;
    stage3.minTop:= 8;
    stage3.maxTop:= 15;
    stage3.minBottom:= 1;
    stage3.maxBottom:= 3;
    stage3.len:= 1200;

    stage4.name:= 'Stage 4';
    stage4.numeric:= 4;
    stage4.minTop:= 5;
    stage4.maxTop:= 8;
    stage4.minBottom:= 7;
    stage4.maxBottom:= 10;
    stage4.len:= 600;

    // load stage data
    currentStage:=1;
    stage:=Pointer(levelStages[currentStage-1]);
    gameTime:=0;
    scroll:= true;

    // setting starting position for terrain
    posX:=0;
    posY_top:= 0;
    posY_bottom:= MAXHEIGHT - 1;
end;


procedure enemies;
(*
   generates enemies
*)
begin
    
end;

procedure terrainBottom;
(*
   generates terrain on Bottom
*)

begin
        // border:=false;
        addressBottom:=SCREEN_GAME + (MAXWIDTH * (MAXHEIGHT - stage.maxBottom));
        inc(addressBottom, posX);
        for i:=0 to (stage.maxBottom - 1) do
        begin
            // we ned to clear both sides of the screen when we put tile during terrain procedure
            Poke(addressBottom, 0);
            Poke(addressBottom + VIEWWIDTH, 0);
            inc(addressBottom, MAXWIDTH);
        end;

        if stage.maxBottom > 0 then begin
            
            tile:=RandomTile;


            // Max limits check
            If (posY_bottom <= MAXHEIGHT - stage.maxBottom) and (tile = UP) then
            begin
                tile:=PLAIN;
            end;
            // Min limits check
            if (posY_bottom >= MAXHEIGHT - 1) and (tile = DOWN) then
            begin
                tile:=PLAIN;
            end;

            case tile of
                UP:     begin
                            if (prev_tileB = PLAIN) or (prev_tileB = PAD) then begin
                                if posY_bottom > MAXHEIGHT - stage.maxBottom then begin
                                    Dec(posY_bottom);
                                    print_game(posX, posY_bottom + 1, SPLAINRIGHTB);
                                end
                                else begin
                                    tile:=PAD;
                                end;

                            end;
                            if prev_tileB = UP then begin
                                if posY_bottom > MAXHEIGHT - stage.maxBottom then begin
                                    Dec(posY_bottom);
                                    print_game(posX, posY_bottom + 1, SPLAINRIGHTB);
                                    print_game(posX - 1, posY_bottom, SSLOPELEFTB);
                                end
                                else begin
                                    tile:=PLAIN;
                                end;
                            end;
                            if prev_tileB = DOWN then begin
                                print_game(posX - 1, posY_bottom + 1, SPLAINLEFTB);
                                print_game(posX, posY_bottom + 1, SPLAINRIGHTB);
                            end;
                        end;
                
                DOWN:   begin

                            if (prev_tileB = PLAIN) or (prev_tileB = PAD) then begin
                                if posY_bottom >= MAXHEIGHT - 1 then tile:=PLAIN;
                            end;

                            if prev_tileB = DOWN then begin
                                Inc(posY_bottom);
                                if (posY_bottom + 1 < MAXHEIGHT - 1) then begin
                                    print_game(posX - 1, posY_bottom, SPLAINLEFTB);
                                    print_game(posX, posY_bottom - 1, SSLOPERIGHTB);
                                end
                                else
                                begin
                                    tile:=PLAIN;
                                    print_game(posX - 1, posY_bottom, SPLAINLEFTB);
                                end;
                            end;
                        end;

                PLAIN,
                PAD,
                WARN:   begin
                            if prev_tileB = DOWN then begin
                                if posY_bottom < MAXHEIGHT - 1 then begin
                                    Inc(posY_bottom);
                                    tile:=PLAIN;
                                    print_game(posX - 1, posY_bottom, SPLAINLEFTB);
                                end;
                            end;
                        end;
            end;
            
            print_game(posX, posY_bottom, tileset_bottom[tile]);
            prev_tileB:=tile;
        end;
end;


procedure terrainTop;
(*
   generates terrain on Top
*)

begin
        // Starting address is highest point when terrain can draw (posY_top)
        addressTop:=SCREEN_GAME;
        inc(addressTop, posX);
        // erasing top + gap in the middle
        for i:=0 to stage.maxTop + (MAXHEIGHT - stage.maxBottom - stage.maxTop) - 1 do
        begin
            // we ned to clear both sides of the screen when we put tile during terrain procedure
            Poke(addressTop, 0);
            Poke(addressTop + VIEWWIDTH, 0);
            Inc(addressTop, MAXWIDTH);
        end;

        // erasing gap in the middle
        // for i:=0 to MAXHEIGHT - stage.maxBottom - stage.maxTop - 1 do
        // begin
        //     // we ned to clear both sides of the screen when we put tile during terrain procedure
        //     Poke(addressTop, 0);
        //     Poke(addressTop + VIEWWIDTH, 0);
        //     Inc(addressTop, MAXWIDTH);
        // end;

        if stage.maxTop > 0 then begin
            tile:=RandomTile;
            
             // Max limits check
            If (posY_top >= stage.maxTop) and (tile = DOWN) then
            begin
                tile:=PLAIN;
            end;
            // // Min limits check
            if (posY_top <= 0) and (tile = UP) then
            begin
                tile:=PLAIN;
            end;

            case tile of
                DOWN:   begin
                            if (prev_tileT = PLAIN) or (prev_tileT = PAD) then begin
                                if posY_top < stage.maxTop - 1 then begin
                                    Inc(posY_top);
                                    print_game(posX, posY_top - 1, SPLAINLEFTT);
                                end
                                else begin
                                    tile:=PAD;
                                end;
                            end;
                            if prev_tileT = DOWN then begin
                                if posY_top < stage.maxTop - 1  then begin
                                    Inc(posY_top);
                                    print_game(posX, posY_top - 1, SPLAINLEFTT);
                                    print_game(posX - 1, posY_top, SSLOPERIGHTT);
                                end
                                else begin
                                    tile:=PLAIN;
                                end;
                            end;
                            if prev_tileT = UP then begin
                                print_game(posX - 1, posY_top - 1, SPLAINRIGHTT);
                                print_game(posX, posY_top - 1, SPLAINLEFTT);

                            end;
                        end;
                UP:     begin
                            if prev_tileT = UP then begin
                                if (posY_top - 1 < 0 ) then begin
                                    Dec(posY_top);
                                    // print_game(posX - 1, posY_top, SPLAINLEFTT);
                                    // print_game(posX, posY_top - 1, SSLOPERIGHTT);
                                end
                                else
                                begin
                                    Dec(posY_top);
                                    tile:=PLAIN;
                                    print_game(posX - 1, posY_top, SPLAINRIGHTT);
                                end;
                            end;
                            
                        end;

                PLAIN,
                PAD,
                WARN:   begin
                            if prev_tileT = UP then begin
                                if (posY_top - 1 >= 0) then begin
                                    Dec(posY_top);
                                    tile:=PLAIN;
                                    print_game(posX - 1, posY_top, SPLAINRIGHTT);
                                end;
                            end;
                        end;
            end;

            print_game(posX, posY_top, tileset_top[tile]);
            prev_tileT:=tile;
        end;
end;


procedure MoveRight;
(*
   moves terrain
*)

begin

    if (hposition = HPOSMAX) then begin
        If posX = 48 then
        begin
            // reset LMS to default
            posX:=0;
            newlms:=SCREEN_GAME;
            lms := DISPLAY_LIST_GAME;
            pause;
            for vi:=0 to MAXHEIGHT - 1 do
            begin
                dpoke(lms + 2, newlms);
                Inc(newlms,MAXWIDTH);
                Inc(lms,3);
            end;	
        end;

        // coarse scroll
        lms := DISPLAY_LIST_GAME + 2;
        pause;
        for vi:=0 to MAXHEIGHT - 1 do
        begin
            newlms:=dpeek(lms);
            inc(newlms);
            dpoke(lms, newlms);
            Inc(lms,3)
        end;

        Inc(posX);
    end;


    ATARI.hscrol:=hposition;
    // // want register to be [3 2 1 0]
    if (hposition = HPOSMIN) then hposition := HPOSMAX
    else dec(hposition);
	Inc(gameTime);
end;

// -----------------------------------------------------------------------------

procedure show_title;
// Procedure to display title screen on start
begin
    // SetIntVec(iVBL, @vbl_title);
    // SetIntVec(iDLI, @dli_title);


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
    initLevel;

    hposition:=HPOSMAX;
    SetIntVec(iVBL, @vbl_game);
    SetIntVec(iDLI, @dli_game1);
    sdmctl := byte(normal or enable or missiles or players or oneline);
    
    // assign display list to GAME screen
    SDLSTL := DISPLAY_LIST_GAME;

    // setting up game playfield font
    chbas:= Hi(CHARSET_GAME);


    fillbyte(pointer(SCREEN_GAME), $900, 0);    // size as per memory map
    fillbyte(pointer(SCREEN_BOTTOM), $100, 0);  

    // CRT_Init(SCREEN_BOTTOM, VIEWWIDTH - 8,1);
    color1:=$0e;
    // color4:=2;
    // print_bottom(0,strings[1]);

    // print_box_right(12, 10, strings[3],$0e);
    // Wait(6);
    // clear_box_right(12, 10, 18, 5);

    // print_bottom(30,'DONE'~);
    


    // for posY_bottom:=0 to 20 do
    // begin
    //     for posX:=0 to 47 do
    //     begin
    //         print_game(posX,posY_bottom,posY_bottom+33);
    //         // print_game(posX, posY_bottom, tileset[PLAIN]);
    //     end;
    // end;


    repeat

        if scroll then
        begin

            if (hposition = HPOSMAX) then begin
                if (gameTime > 0) and (gameTime mod stage.len = 0) then begin
                    if currentStage < STAGEMAX then begin
                        Inc(currentStage);
                        stage:=Pointer(levelStages[currentStage-1]);
                    end else
                    begin
                        scroll:=false;
                        currentStage:=STAGEMAX;
                    end;
                end; 
                terrainTop;
                terrainBottom;

            end;
            MoveRight;
        end;

        if (gameTime mod 20) = 0 then
        begin
            print_bottom(5, 0, gameTime);
            // print_bottom(15, 0, tile);
            print_bottom(20, 0, stage.numeric);

            print_bottom(35, 0, '  ');print_bottom(35, 0, stage.maxTop);
            print_bottom(38,0, '  ');print_bottom(38, 0, stage.maxBottom);

            // print_bottom(35, 0, '  ');print_bottom(35, 0, posY_top);
            // print_bottom(38,0, '  ');print_bottom(38, 0, posY_bottom);

        end;
        // if keypressed then scroll:= not scroll;
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