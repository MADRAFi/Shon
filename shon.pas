program Shon;
{$librarypath '../blibs/'}
uses atari, crt, joystick, rmt, sysutils;

const
{$i const.inc}
{$i types.inc}                  // including defined type

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

var

{$r resources.rc}               // including resource files with all assets
{$i sprites/player.inc}
{$i sprites/player_explosion.inc}
{$i sprites/player_missle.inc}



    gamestate: TGameState;
    music: Boolean;


    msx: TRMT;
    old_vbl,old_dli:Pointer;
    chrctl : Byte absolute $D401;
    // accessory variables in loops
    // x: Byte; 
    i: Byte;
    key: Byte;
    tmp: TString;
    t: byte;
    addressTop: Word;
    addressBottom: Word;
    

    // variables used for scroll
    hposition: Byte;
    scroll: Boolean;
    animrockets: Boolean;

    newlms: Word;
    lms: Word;
    vi: Byte; // iteration in vbl interrupt
    debval: byte;

    // values are based on MAXWIDTH const to replace multiply in row calculation y * MAXWIDTH
    row_max: array [0..MAXHEIGHT-1] of Word = (
        0, 96, 192, 288, 384, 480, 576, 672, 768, 864, 960, 1056, 1152, 1248, 1344, 1440, 1536, 1632, 1728, 1824, 1920
    );
    row_view: array [0..2] of Byte = (
        0, 40, 80
    );
    // terrain positions
    posX: Byte;
    posY_top: Byte;
    posY_bottom: Byte;


    // player position
    playerX: Byte;
    playerY: Byte;
    Missle1X: Byte;
    Missle1Y: Byte;
    Missle1X_prev: Byte;
    Missle1Y_prev: Byte;

    playerExplode: Boolean;
    joy: Byte;

    tileT: byte = NONE;
    tileB: byte = NONE;
    prev_tileT: byte = NONE;
    prev_tileB: byte = NONE;

    // gameTime counter
    gameTime: Word;
    rndNumber1: byte;
    rndNumber2: byte;

    currentStage: byte;
    stage: ^TStage;
    stage1: TStage;
    stage2: TStage;
    stage3: TStage;
    stage4: TStage;
    levelStages: array [0..STAGEMAX-1] of Pointer = (@stage1, @stage2, @stage3, @stage4);

    tileset_top: array [0..TILEMAX-1] of Byte = (SUPT, SPLAINT, SDOWNT, SPADT, SWARN);
    tileset_bottom: array [0..TILEMAX-1] of Byte = (SUPB, SPLAINB, SDOWNB, SPADB, SWARN);

    rocket_head: array [0..TILEROCKETMAX-1] of Byte = (SHEAD1, SHEAD2, SHEAD3, SHEAD4);
    rocket_engine: array [0..TILEROCKETMAX-1] of Byte = (SENGINE1, SENGINE2, SENGINE3, SENGINE4);
    rocket_loc: array[0..MAXWIDTH-1] of Word;

    tower_head_top: array [0..TILETOWERMAX-1] of Byte = (STOPT1, STOPT2, STOPT3, STOPT4);
    tower_base_top: array [0..TILETOWERMAX-1] of Byte = (SBASET1, SBASET2, SBASET3, SBASET4);
    tower_head_bottom: array [0..TILETOWERMAX-1] of Byte = (STOPB1, STOPB2, STOPB3, STOPB4);
    tower_base_bottom: array [0..TILETOWERMAX-1] of Byte = (SBASEB1, SBASEB2, SBASEB3, SBASEB4);

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
    addressBottom:=SCREEN_BOTTOM + row_view[y] + x;
    move(tmp[1], pointer(addressBottom), Length(tmp));  
end;


procedure print_game(x: Byte; y: Byte; b: Byte);overload;
// prints byte at x,y position in left and right game area
begin
    // addressTop:=SCREEN_GAME + (MAXWIDTH * y) + x;
    addressTop:=SCREEN_GAME + row_max[y] + x;
    Poke(addressTop, b);
    Poke(addressTop + VIEWWIDTH, b);
end;

// procedure print_right(x: Byte; y: Byte; b: Byte);overload;
// // prints byte at x,y position in right game area
// begin
//     Poke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2) + x, b);
// end;

// procedure print_right(x: Byte; y: Byte; s: String);overload;
// // prints byte at x,y position in right game area
// begin
//     for i:=1 to byte(s[0]) do
//     begin
//         Poke(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH div 2) + x + i, byte(s[i]));
//     end;    
// end;

// procedure print_line(x: Byte; y: Byte; n: Byte; sign: Byte);
// // prints streight line equal to n at x,y position in game area
// begin
//     for i:=0 to n - 1 do
//     begin
//         print_right(x + i, y, sign);
//     end;    
// end;

// procedure print_box_right(x: Byte; y: Byte; s: String; txtcolor: Byte);
// // draws a box at x,y position with a text inside and using c as color
// const
//     frmcolor = $0e;     // color used for frame drawing

// begin
//     color1:=frmcolor;
//     print_line(x, y, byte(s[0]) + 8, SFRAMEINV);
//     print_right(x, y + 1, SFRAMEINV); print_right(x + byte(s[0]) + 7, y + 1, SFRAMEINV);
//     print_right(x, y + 2, SFRAMEINV); 
//     color1:=txtcolor;                   
//     print_right(x + 3, y + 2, s);
//     color1:=frmcolor;
//     print_right(x + byte(s[0]) + 7, y + 2, SFRAMEINV);
//     print_right(x, y + 3, SFRAMEINV); print_right(x + byte(s[0]) + 7, y + 3, SFRAMEINV);
//     print_line(x, y + 4, byte(s[0]) + 8, SFRAMEINV);
// end;

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

// procedure clear_box_right(x: Byte; y: Byte; sizeX:byte; sizeY:Byte);
// // clears box sizex,sizey at x,y in game screen
// begin
//     for i:=0 to sizeY - 1 do
//     begin
//         fillbyte(pointer(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH * i) + (MAXWIDTH div 2) + x), sizeX, 0);
//     end;
// end;

// procedure clear_box(x: Byte; y: Byte; sizeX:byte; sizeY:Byte);
// // clears box sizex,sizey at x,y in game screen
// begin
//     for i:=0 to sizeY - 1 do
//     begin
//         fillbyte(pointer(SCREEN_GAME + (MAXWIDTH * y) + (MAXWIDTH * i) + x), sizeX, 64);
//     end;
// end;

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

// function RandomTile : Byte;
// begin
//     Result:=rnd and 3;
//     // Result:=Random(4);
// end;

procedure PMGInit;inline;
begin
    pmbase := Hi(PMG_BASE);
    sdmctl := %00111110;
    // sdmctl := byte(normal or enable or missiles or players or oneline);
    gractl := %00000011;
    gprior := %00100001;
    pcolr2 := 0;
    pcolr3 := 0;
    sizep0 := 2;
    sizep1 := 2;
    sizep2 := 1;
    sizep3 := 1;
    sizem := %00000101;
end;

// -----------------------------------------------------------------------------

procedure ReadInput;
begin
        if (skstat and 4 = 0) then 
            key := kbcode and %00111111;
    
        // joy := stick0 and %1111;
        joy := stick0;
        // if (joy <> 15) or (key <> NONE) then begin
            if ((joy and %0100) = 0) or (key = KEY_LEFT_CODE) then begin  
                dec(playerX);
                if playerX<48 then playerX:=48;
            end;
            if ((joy and %1000) = 0) or (key = KEY_RIGHT_CODE) then begin
                Inc(playerX);
                if playerX>200 then playerX:=200;
            end;
            if ((joy and %0001) = 0) or (key = KEY_UP_CODE) then begin
                Dec(playerY,2);
                if playerY<12 then playerY:=12;
            end;
            if ((joy and %0010) = 0) or (key = KEY_DOWN_CODE) then begin
                Inc(playerY,2);
                if playerY>162 then playerY:=162;
            end;
            
            if strig0 = 0 then begin
                if Missle1X = 0 then begin
                    Missle1X:=playerX + 4;
                    Missle1Y:=playerY + 4;
                end;
                Inc(Missle1X, 6);
                if Missle1X > 200 then Missle1X:=0;
            end else
            begin
                Missle1X:=0;
                Missle1Y:=0;
            end;
        // end;

end;


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
    stage1.minTop:= 0;
    stage1.maxTop:= 0;
    stage1.minBottom:= 2;
    stage1.maxBottom:= 5;
    stage1.len:= 2000;
    stage1.color:=$0e;

    stage2.name:= 'Stage 2';
    stage2.numeric:= 2;
    stage2.minTop:= 1;
    stage2.maxTop:= 3;
    stage2.minBottom:= 8;
    stage2.maxBottom:= 15;
    stage2.len:= 1200;
    stage2.color:=$0e;

    stage3.name:= 'Stage 3';
    stage3.numeric:= 3;
    stage3.minTop:= 8;
    stage3.maxTop:= 15;
    stage3.minBottom:= 1;
    stage3.maxBottom:= 3;
    stage3.len:= 1200;
    stage3.color:=$0e;

    stage4.name:= 'Stage 4';
    stage4.numeric:= 4;
    stage4.minTop:= 5;
    stage4.maxTop:= 8;
    stage4.minBottom:= 7;
    stage4.maxBottom:= 10;
    stage4.len:= 600;
    stage4.color:=$0e;

    // load stage data
    currentStage:=1;
    stage:=Pointer(levelStages[currentStage-1]);
    color1:=stage.color;
    gameTime:=0;
    animrockets:=true;
    scroll:= true;

    // setting starting position for terrain
    posX:=0;
    posY_top:= 0;
    posY_bottom:= MAXHEIGHT - 1;

    playerExplode:=false;
    playerX:= 100;
    playerY:= 100;

end;

procedure player(x, y: byte);
(*
   draws player
*)

begin
    pcolr0 := p_colors0[1];
    pcolr1 := p_colors1[1];
    hposp0 := x;
    hposp1 := x + p_spriteGap;
    // hposm0 := 0;
    // hposm1 := 0;
    // hposp2 := 0;
    // hposp3 := 0;

    fillbyte(pointer(PMG_BASE + $500 + y - 2), 1, 0);
    fillbyte(pointer(PMG_BASE + $500 + y + p_spriteHeight+1), 1, 0);
    Move(@p_frames0_0, pointer(PMG_BASE + $400 + y), p_spriteHeight);
    Move(@p_frames1_0, pointer(PMG_BASE + $500 + y), p_spriteHeight);
end;

procedure playerMissle1(x, y: byte);
(*
   draws missles
*)

begin
    // pcolr0 := p_fire_colors0[1];
    // pcolr1 := p_fire_colors1[1];
    // hposp2 := 0;
    // hposp3 := 0;
    
    fillbyte(pointer(PMG_BASE + $300 + Missle1Y_prev), p_fire_spriteHeight, 0);

    hposm0 := x;
    hposm1 := x + p_fire_spriteGap;
    Move(@p_fire_framesMIS_0, pointer(PMG_BASE + $300 + y), p_fire_spriteHeight);
    
    Missle1X_prev:=x;
    Missle1Y_prev:=y;
end;

procedure enemies;
(*
   generates enemies
*)
begin

end;

procedure terrainClean;
(*
   cleans terrain
*)

begin
        addressTop:=SCREEN_GAME;
        inc(addressTop, posX);
        // erasing top + gap in the middle
        for i:=0 to MAXHEIGHT - 1 do
        begin
            // we ned to clear both sides of the screen when we put tile during terrain procedure
            Poke(addressTop, 0);
            Poke(addressTop + VIEWWIDTH, 0);
            Inc(addressTop, MAXWIDTH);
        end;
end;

procedure terrainBottom;
(*
   generates terrain on Bottom
*)

begin
        // addressBottom:=SCREEN_GAME + (MAXWIDTH * (MAXHEIGHT - stage.maxBottom));
        // inc(addressBottom, posX);
        // for i:=0 to (stage.maxBottom - 1) do
        // begin
        //     // we ned to clear both sides of the screen when we put tile during terrain procedure
        //     Poke(addressBottom, 0);
        //     Poke(addressBottom + VIEWWIDTH, 0);
        //     inc(addressBottom, MAXWIDTH);
        // end;

        if stage.maxBottom > 0 then begin
            
            tileB:=rnd and (TILEMAX - 2); // do not use WARN tile
            // tileB:=rnd and 3; // do not use WARN tile


            // Max limits check
            If (posY_bottom <= MAXHEIGHT - stage.maxBottom) and (tileB = UP) then
            begin
                tileB:=PLAIN;
            end;
            // Min limits check
            if (posY_bottom >= MAXHEIGHT - 1) and (tileB = DOWN) then
            begin
                tileB:=PLAIN;
            end;

            case tileB of
                UP:     begin
                            if (prev_tileB = PLAIN) or (prev_tileB = PAD) then begin
                                if posY_bottom > MAXHEIGHT - stage.maxBottom then begin
                                    Dec(posY_bottom);
                                    print_game(posX, posY_bottom + 1, SPLAINRIGHTB);
                                end
                                else begin
                                    tileB:=PAD;
                                end;

                            end;
                            if prev_tileB = UP then begin
                                if posY_bottom > MAXHEIGHT - stage.maxBottom then begin
                                    Dec(posY_bottom);
                                    print_game(posX, posY_bottom + 1, SPLAINRIGHTB);
                                    print_game(posX - 1, posY_bottom, SSLOPELEFTB);
                                end
                                else begin
                                    tileB:=PLAIN;
                                end;
                            end;
                            if prev_tileB = DOWN then begin
                                print_game(posX - 1, posY_bottom + 1, SPLAINLEFTB);
                                print_game(posX, posY_bottom + 1, SPLAINRIGHTB);
                            end;
                        end;
                
                DOWN:   begin

                            if (prev_tileB = PLAIN) or (prev_tileB = PAD) then begin
                                if posY_bottom >= MAXHEIGHT - 1 then tileB:=PLAIN;
                            end;

                            if prev_tileB = DOWN then begin
                                Inc(posY_bottom);
                                if (posY_bottom + 1 < MAXHEIGHT - 1) then begin
                                    print_game(posX - 1, posY_bottom, SPLAINLEFTB);
                                    print_game(posX, posY_bottom - 1, SSLOPERIGHTB);
                                end
                                else
                                begin
                                    tileB:=PLAIN;
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
                                    tileB:=PLAIN;
                                    print_game(posX - 1, posY_bottom, SPLAINLEFTB);
                                end;
                            end;
                        end;
            end;
            
            print_game(posX, posY_bottom, tileset_bottom[tileB]);
            prev_tileB:=tileB;
        end;
end;


procedure terrainTop;
(*
   generates terrain on Top
*)

begin
        // Starting address is highest point when terrain can draw (posY_top)
        // addressTop:=SCREEN_GAME;
        // inc(addressTop, posX);
        // // erasing top + gap in the middle
        // for i:=0 to stage.maxTop + (MAXHEIGHT - stage.maxBottom - stage.maxTop) - 1 do
        // begin
        //     // we ned to clear both sides of the screen when we put tile during terrain procedure
        //     Poke(addressTop, 0);
        //     Poke(addressTop + VIEWWIDTH, 0);
        //     Inc(addressTop, MAXWIDTH);
        // end;

        // erasing gap in the middle
        // for i:=0 to MAXHEIGHT - stage.maxBottom - stage.maxTop - 1 do
        // begin
        //     // we ned to clear both sides of the screen when we put tile during terrain procedure
        //     Poke(addressTop, 0);
        //     Poke(addressTop + VIEWWIDTH, 0);
        //     Inc(addressTop, MAXWIDTH);
        // end;

        if stage.maxTop > 0 then begin

            tileT:=rnd and (TILEMAX - 2); // do not use WARN tile
            
             // Max limits check
            If (posY_top >= stage.maxTop) and (tileT = DOWN) then
            begin
                tileT:=PLAIN;
            end;
            // // Min limits check
            if (posY_top <= 0) and (tileT = UP) then
            begin
                tileT:=PLAIN;
            end;

            case tileT of
                DOWN:   begin
                            if (prev_tileT = PLAIN) or (prev_tileT = PAD) then begin
                                if posY_top < stage.maxTop - 1 then begin
                                    Inc(posY_top);
                                    print_game(posX, posY_top - 1, SPLAINLEFTT);
                                end
                                else begin
                                    tileT:=PAD;
                                end;
                            end;
                            if prev_tileT = DOWN then begin
                                if posY_top < stage.maxTop - 1  then begin
                                    Inc(posY_top);
                                    print_game(posX, posY_top - 1, SPLAINLEFTT);
                                    print_game(posX - 1, posY_top, SSLOPERIGHTT);
                                end
                                else begin
                                    tileT:=PLAIN;
                                end;
                            end;
                            if prev_tileT = UP then begin
                                print_game(posX - 1, posY_top - 1, SPLAINRIGHTT);
                                print_game(posX, posY_top - 1, SPLAINLEFTT);

                            end;
                        end;
                UP:     begin
                            if prev_tileT = UP then begin
                                Dec(posY_top);
                                if (posY_top - 1 <= 0 ) then begin
                                    // Dec(posY_top);
                                    tileT:=PLAIN;
                                    print_game(posX - 1, posY_top, SPLAINRIGHTT);
                                end
                                else
                                begin
                                    // Dec(posY_top);
                                    print_game(posX - 1, posY_top, SPLAINRIGHTT);
                                    print_game(posX, posY_top + 1, SSLOPELEFTT);
                                    
                                end;
                            end;
                            
                        end;

                PLAIN,
                PAD,
                WARN:   begin
                            if prev_tileT = UP then begin
                                if (posY_top - 1 >= 0) then begin
                                    Dec(posY_top);
                                    tileT:=PLAIN;
                                    print_game(posX - 1, posY_top, SPLAINRIGHTT);
                                end;
                            end;
                        end;
            end;

            print_game(posX, posY_top, tileset_top[tileT]);
            prev_tileT:=tileT;
        end;
end;

procedure rockets;
(*
   generates rockets
*)

begin
        // if (stage.maxBottom > 0) and (stage.maxTop = 0) then begin
            if tileB = PAD then begin
                rndNumber1:=rnd and (TILEROCKETMAX - 1);
                rndNumber2:=rnd and (TILEROCKETMAX - 1);
                print_game(posX, posY_Bottom - 1, rocket_engine[rndNumber2]);
                print_game(posX, posY_Bottom - 2, rocket_head[rndNumber1]);

                // do not rememeber all rocket locations for animation, they will remain stationary
                // if (rndNumber1 > 1) or (rndNumber2 > 1) then begin
                    rocket_loc[posX]:=SCREEN_GAME + row_max[posY_Bottom-2] + posX;
                    rocket_loc[posX+VIEWWIDTH]:=SCREEN_GAME + row_max[posY_Bottom-2] + posX + VIEWWIDTH;
                // end;
            end;
        

        // end;
end;


procedure rocketsMove;
(*
   move rockets
*)

begin
    // for i:=0 to MAXWIDTH -1 do begin
    //     if rocket_loc[i] <> 0 then begin
    //         addressTop:=rocket_loc[i];
    //         if addressTop - MAXWIDTH > SCREEN_GAME then begin
    //             t:=Peek(addressTop);
    //             Poke(addressTop - MAXWIDTH, t);

    //             addressBottom:=rocket_loc[i] + MAXWIDTH;
    //             t:=Peek(addressBottom);
    //             Poke(addressTop, t);
    //             Poke(addressBottom, 0);
    //             rocket_loc[i]:=addressTop - MAXWIDTH;
    //         end else
    //         begin
    //             // addressBottom:=rocket_loc[i] + MAXWIDTH;
    //             // t:=Peek(addressBottom);
    //             // Poke(addressTop, t);
    //             // Poke(addressBottom, 0);
    //             // rocket_loc[i]:=addressTop
    //         end;
    //     end;
    // end;
    // if animrockets then begin
        t:=0;
        while t < MAXROCKETSLAUNCH-1 do begin
        i:= rnd and 48;
        // for i:=0 to MAXWIDTH - 1 do begin
        // for i:=48 to 96 do begin
            if (rocket_loc[i] <> 0) and (rocket_loc[i+VIEWWIDTH] <> 0) then begin

                if (rocket_loc[i] - MAXWIDTH > SCREEN_GAME) and (rocket_loc[i+VIEWWIDTH] - MAXWIDTH > SCREEN_GAME) then begin
                    Poke(rocket_loc[i] - MAXWIDTH, Peek(rocket_loc[i]));
                    Poke(rocket_loc[i+VIEWWIDTH] - MAXWIDTH, Peek(rocket_loc[i+VIEWWIDTH]));

                    Poke(rocket_loc[i], Peek(rocket_loc[i] + MAXWIDTH));
                    Poke(rocket_loc[i+VIEWWIDTH], Peek(rocket_loc[i+VIEWWIDTH] + MAXWIDTH));

                    Poke(rocket_loc[i] + MAXWIDTH, 0);
                    Poke(rocket_loc[i+VIEWWIDTH] + MAXWIDTH, 0);

                    Dec(rocket_loc[i], MAXWIDTH);
                    Dec(rocket_loc[i+VIEWWIDTH], MAXWIDTH);
                end else
                begin
                    t:= Peek(rocket_loc[i] + MAXWIDTH);
                    if (t <> 0) then begin 
                        Poke(rocket_loc[i], t);
                        Poke(rocket_loc[i+VIEWWIDTH], Peek(rocket_loc[i+VIEWWIDTH] + MAXWIDTH));
                    
                        Poke(rocket_loc[i] + MAXWIDTH, 0);
                        Poke(rocket_loc[i+VIEWWIDTH] + MAXWIDTH, 0);
                    end else
                    begin
                        Poke(rocket_loc[i], 0);
                        Poke(rocket_loc[i+VIEWWIDTH], 0);
                        rocket_loc[i]:=0;
                        rocket_loc[i+VIEWWIDTH]:=0;
                    end;
                end;
            end;
            inc(t);
        end;
    // end;
end;


procedure towers;
(*
   generates towers
*)

begin   
        if stage.maxTop > 0 then begin
            if tileT = PAD then begin
                rndNumber1:=rnd and (TILETOWERMAX - 1);
                rndNumber2:=rnd and (TILETOWERMAX - 1);
                print_game(posX, posY_Top + 1, tower_base_top[rndNumber1]);
                print_game(posX, posY_Top + 2, tower_head_top[rndNumber2]);
            end;
        end;


        if stage.maxBottom > 0 then begin
            if tileB = PAD then begin
                rndNumber1:=rnd and (TILETOWERMAX - 1);
                rndNumber2:=rnd and (TILETOWERMAX - 1);
                print_game(posX, posY_Bottom - 1, tower_base_bottom[rndNumber2]);
                print_game(posX, posY_Bottom - 2, tower_head_bottom[rndNumber1]);
            end;
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


procedure collisionDetection;

begin
    // player collision
    // if (hposm1 or hposm0) and 2 <> 0 then playerExplode:=true;
    if ((hposm1 or hposm0)) <> 0 then playerExplode:=true;

    waitframe;
    // reset collision detection
    hitclr:=$ff;
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
    // color1:=$0e;
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
        // if (gameTime mod 200) = 0 then begin
        //     animrockets:=true;
        // end;
        // if (gameTime mod 96) = 0 then begin
        //     animrockets:=false;
        // end;

        if scroll then
        begin

            if (hposition = HPOSMAX) then begin
                if (gameTime > 0) and (gameTime mod stage.len = 0) then begin
                    if currentStage < STAGEMAX then begin
                        Inc(currentStage);
                        stage:=Pointer(levelStages[currentStage-1]);
                        color1:=stage.color;
                    end else
                    begin
                        scroll:=false;
                        currentStage:=STAGEMAX;
                    end;
                end;

                terrainClean;
                terrainTop;
                terrainBottom;
                rockets;
                rocketsMove;
                // towers;
                // collisionDetection;

            end;
            MoveRight;
        end;

        if (gameTime mod 20) = 0 then
        begin

            print_bottom(2, 0, gameTime);
            print_bottom(10, 0, posX);
            print_bottom(20, 0, stage.numeric);

            // print_bottom(35, 0, '  ');print_bottom(35, 0, stage.maxTop);
            // print_bottom(38,0, '  ');print_bottom(38, 0, stage.maxBottom);

            print_bottom(35, 0, '  ');print_bottom(35, 0, t);
            print_bottom(38,0, '  ');print_bottom(38, 0, debval);

        end;
        

        
        if playerExplode then begin
            scroll:=false;
            for i:=0 to p_explode_spriteFrames - 1 do
            begin
                fillbyte(pointer(PMG_BASE + $400 + playerY), p_spriteHeight, 0);
                fillbyte(pointer(PMG_BASE + $500 + playerY), p_spriteHeight, 0);
                pcolr0 := p_explode_colors0[i];
                pcolr1 := p_explode_colors1[i];
                Move(pointer(p_explode_0[i]), pointer(PMG_BASE + $400 + playerY), p_spriteHeight);
                Move(pointer(p_explode_1[i]), pointer(PMG_BASE + $500 + playerY), p_spriteHeight);
                // Move(pointer(p_explode_0[0]), pointer(PMG_BASE + $400 + playerY), p_spriteHeight);
                // Move(pointer(p_explode_1[0]), pointer(PMG_BASE + $500 + playerY), p_spriteHeight);
                
                WaitFrame;
                WaitFrame;
                WaitFrame;
                WaitFrame;
                WaitFrame;
                WaitFrame;
            end;
        end else
        begin
            ReadInput;
            player(playerX, playerY);
            playerMissle1(Missle1X, Missle1Y)
        end;
        
        // if keypressed then scroll:= not scroll;
        WaitFrame;
    until false;
    
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
    PMGInit;

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