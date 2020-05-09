program Scramble;
{ $librarypath '../blibs/'}
uses atari, crt, rmt; // b_utils;

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
	fntTable: array [0..29] of byte = (
		hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),
		hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),
		hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE3),hi(CHARSET_TITLE2),hi(CHARSET_TITLE3),hi(CHARSET_TITLE3),
		hi(CHARSET_TITLE3),hi(CHARSET_TITLE3),hi(CHARSET_TITLE3),hi(CHARSET_GAME),hi(CHARSET_GAME),hi(CHARSET_GAME)
	);

	c0Table: array [0..29] of byte = (
		$10,$10,$10,$10,$10,$10,$10,$10,
		$10,$10,$10,$10,$10,$10,$10,$10,
		$D4,$D4,$D4,$D4,$D4,$D4,$D4,$D4,
		$D4,$D4,$D4,$D4,$D4,$00
	);

	c1Table: array [0..29] of byte = (
		$14,$14,$14,$14,$14,$14,$14,$14,
		$14,$14,$14,$14,$14,$14,$14,$14,
		$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,
		$D8,$D8,$D8,$D8,$D8,$00
	);

	c2Table: array [0..29] of byte = (
		$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C,
		$8E,$1C,$1C,$1C,$1C,$1C,$1C,$1C,
		$DC,$DC,$DC,$DC,$DC,$DC,$DC,$DC,
		$DC,$DC,$DC,$DC,$DC,$00
	);

	c3Table: array [0..29] of byte = (
		$0E,$0E,$8E,$8C,$8A,$86,$84,$82,
		$80,$00,$02,$04,$06,$08,$0A,$0C,
		$FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC,
		$FC,$FC,$FC,$FC,$FC,$00
	);


{$r resources.rc}
{$i types.inc}

var
    gamestate: TGameState;
    music: Boolean;

    msx: TRMT;
    old_vbl,old_dli:pointer;
    //strings:array [0..0] of word absolute STRINGS_ADDRESS;

{$i interrupts.inc}

procedure show_title;
begin

    GetIntVec(iVBL, old_vbl);
    GetIntVec(iDLI, old_dli);

    sdmctl := byte(normal or enable or missiles or players or oneline);
    // sdlstl := word(@dlist_title);	// ($230) = @dlist_title, New DLIST Program
    SDLSTL := DISPLAY_LIST_TITLE;

    SetIntVec(iVBL, @vbl_title);
    SetIntVec(iDLI, @dli_title);

    nmien := $c0;			// $D40E = $C0, Enable DLI
    
    fillbyte(pointer(SCREEN_TITLE+960+120), 120, 0);   // size 120 (3 x 40 chars in 1 line); + 
    
    repeat
      IF consol = CN_START then gamestate:=GAMEINPROGRESS;
      pause;
    until consol = CN_START;
end;


begin
    //chbas := Hi(CHARSET_ADDRESS); // set custom charset
    //savmsc := VIDEO_RAM_ADDRESS;  // set custom video address

(*  initialize RMT player  *)
    msx.player := pointer(RMT_PLAYER_ADDRESS);
    msx.modul := pointer(RMT_MODULE_TITLE);
    msx.Init(0);

(*  set custom display list  *)
    //Pause;
    //SDLSTL := DISPLAY_LIST_ADDRESS;

(*  set and run vbl interrupt *)
    // GetIntVec(iVBL, oldvbl);
    // SetIntVec(iVBL, @vbl);
    //nmien := $40;

(*  set and run display list interrupts *)
    //GetIntVec(iDLI, oldsdli);
    //SetIntVec(iDLI, @dli);
    //nmien := $c0; // set $80 for dli only (without vbl)
    
(*  your code goes here *)
    //Writeln(NullTermToString(strings[0]));
    //Writeln(NullTermToString(strings[1]));

    music:=false;    
    gamestate:= NEWGAME;

    while True do
    begin
      case gamestate of
        NEWGAME: show_title;
        // GAMEINPROGRESS: wirus;
        // GAMEOVER: gameover;
      end;
    end;

        
(*  restore system interrupts *)
    SetIntVec(iVBL, @old_vbl);
    SetIntVec(iDLI, old_dli);
    nmien := $40; // turn off dli

end.
