uses crt,atari;

{$r shon_title12.rc}

const
	scr = $A600;

	fnt0 = $AC00;
	fnt1 = $B000;
	fnt2 = $B400;
	fnt3 = $B800;

	dlist: array [0..34] of byte = (
		$C4,lo(scr),hi(scr),
		$84,$84,$84,$84,$84,$84,$84,$84,
		$84,$84,$84,$84,$84,$84,$84,$84,
		$84,$84,$84,$84,$84,$84,$84,$84,
		$84,$84,$84,$84,$04,
		$41,lo(word(@dlist)),hi(word(@dlist))
	);

	fntTable: array [0..29] of byte = (
		hi(fnt0),hi(fnt0),hi(fnt0),hi(fnt0),hi(fnt0),hi(fnt0),hi(fnt0),hi(fnt0),
		hi(fnt0),hi(fnt0),hi(fnt0),hi(fnt0),hi(fnt0),hi(fnt1),hi(fnt1),hi(fnt1),
		hi(fnt1),hi(fnt1),hi(fnt1),hi(fnt1),hi(fnt2),hi(fnt1),hi(fnt2),hi(fnt2),
		hi(fnt2),hi(fnt2),hi(fnt2),hi(fnt3),hi(fnt3),hi(fnt3)
	);

	c0Table: array [0..29] of byte = (
		$10,$10,$10,$10,$10,$10,$10,$10,
		$10,$10,$10,$10,$10,$10,$10,$10,
		$D4,$D4,$D4,$D4,$D4,$D4,$D4,$D4,
		$D4,$D4,$D4,$D4,$D4,$D4
	);

	c1Table: array [0..29] of byte = (
		$14,$14,$14,$14,$14,$14,$14,$14,
		$14,$14,$14,$14,$14,$14,$14,$14,
		$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,
		$D8,$D8,$D8,$D8,$D8,$D8
	);

	c2Table: array [0..29] of byte = (
		$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C,
		$8E,$1C,$1C,$1C,$1C,$1C,$1C,$1C,
		$DC,$DC,$DC,$DC,$DC,$DC,$DC,$DC,
		$DC,$DC,$DC,$DC,$DC,$DC
	);

	c3Table: array [0..29] of byte = (
		$0E,$0E,$8E,$8C,$8A,$86,$84,$82,
		$80,$00,$02,$04,$06,$08,$0A,$0C,
		$FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC,
		$FC,$FC,$FC,$FC,$FC,$FC
	);

var
	old_dli, old_vbl: pointer;


procedure vbl; assembler; interrupt;
asm
{
	mva #1 dli.cnt

	mva adr.fntTable chbase
	mva adr.fntTable+1 dli.chbs

	mva adr.c0Table color0
	mva adr.c0Table+1 dli.col0
	mva adr.c1Table color1
	mva adr.c1Table+1 dli.col1
	mva adr.c2Table color2
	mva adr.c2Table+1 dli.col2
	mva adr.c3Table color3
	mva adr.c3Table+1 dli.col3

	mva #$00 colbak

	jmp xitvbv
};
end;


procedure dli; assembler; interrupt;
asm
{
	sta rA
	stx rX
	sty rY

	lda #0
chbs	equ *-1

	ldx #0
col0	equ *-1

	ldy #0
col1	equ *-1

	;sta wsync

	sta chbase
	lda #0
col2	equ *-1
	stx color0
	ldx #0
col3	equ *-1
	sty color1
	sta color2
	stx color3

	inc cnt

	ldx #0
cnt	equ *-1

	lda adr.fntTable,x
	sta chbs

	lda adr.c0Table,x
	sta col0

	lda adr.c1Table,x
	sta col1

	lda adr.c2Table,x
	sta col2

	lda adr.c3Table,x
	sta col3

	lda #0
rA	equ *-1
	ldx #0
rX	equ *-1
	ldy #0
rY	equ *-1
};
	end;


begin

 GetIntVec(iVBL, old_vbl);
 GetIntVec(iDLI, old_dli);

 sdmctl := byte(normal or enable or missiles or players or oneline);
 sdlstl := word(@dlist);	// ($230) = @dlist, New DLIST Program

 SetIntVec(iVBL, @vbl);
 SetIntVec(iDLI, @dli);

 nmien := $c0;			// $D40E = $C0, Enable DLI

 repeat
 until keypressed;

 SetIntVec(iVBL, old_vbl);
 SetIntVec(iDLI, old_dli);

end.
