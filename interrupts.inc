(* declare your interrupt routines here *)

procedure dli_game; assembler; interrupt;
asm {
    phr ; store registers

;   *** example test routine
;    lda #64 ; wait this number of lines
;@   cmp vcount
;    bpl @-
;    mva #$0f atari.colbk ; change backgroung color to white
    
    plr ; restore registers
};
end;

procedure vbl_game; interrupt;
begin
	if music then msx.play;
	asm {
		phr ; store registers
		
	;   *** example test routine    
	;    mva 20 atari.colbk // blink background
		
	;   *** RMT play routine
	;    lda MSX
	;    ldy MSX+1
	;    jsr RMT.TRMT.PLAY

		plr ; restore registers
		jmp $E462 ; jump to system VBL handler
	};
end;

procedure vbl_title; interrupt;
begin
	if music then msx.play;
	asm
	{
		// phr ; store registers

		mva #1 dli_title.cnt

		mva adr.fntTable chbase
		mva adr.fntTable+1 dli_title.chbs

		mva adr.c0Table color0
		mva adr.c0Table+1 dli_title.col0
		mva adr.c1Table color1
		mva adr.c1Table+1 dli_title.col1
		mva adr.c2Table color2
		mva adr.c2Table+1 dli_title.col2
		mva adr.c3Table color3
		mva adr.c3Table+1 dli_title.col3

		mva #$00 colbak

		// plr ; restore registers

		jmp xitvbv
	};
end;


procedure dli_title; assembler; interrupt;
asm
{
	// phr ; store registers
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


    // plr ; restore registers	
};
	end;