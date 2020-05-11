(* declare your interrupt routines here *)

// procedure dli; assembler; interrupt;
// asm {
//     phr ; store registers

// ;   *** example test routine
// ;    lda #64 ; wait this number of lines
// ;@   cmp vcount
// ;    bpl @-
// ;    mva #$0f atari.colbk ; change backgroung color to white
    
//     plr ; restore registers
// };
// end;



// procedure vbl; interrupt;
// begin
// 	if music then msx.play;
// 	asm {
// 		phr ; store registers
		
// 	;   *** example test routine    
// 	;    mva 20 atari.colbk // blink background
		
// 	;   *** RMT play routine
// 	;    lda MSX
// 	;    ldy MSX+1
// 	;    jsr RMT.TRMT.PLAY

// 		plr ; restore registers
// 		jmp $E462 ; jump to system VBL handler
// 	};
// end;

procedure dli_game1; assembler; interrupt;
asm {
		pha             ; only using A register, so save it to the stack
		lda #$00        ; new background color
		sta WSYNC       ; first WSYNC gets us to start of scan line we want
		;sta ATARI.COLBK       ; change background color
		sta ATARI.COLPF2
		lda #<dli_game2      ; point to second DLI
		sta VDSLST
		pla             ; restore A register from stack

};
end;
procedure dli_game2; assembler; interrupt;
asm {
		pha ; store registers
		txa
		pha
		ldx #16        ; make 64 color changes
		lda #$8e        ; initial color
		sta WSYNC       ; first WSYNC gets us to start of scan line we want
?loop   sta ATARI.COLPF2       ; change background color
		sec
		sbc #1          ; make dimmer by decrementing luminance value
		dex             ; update iteration count
		sta WSYNC       ; make it the color change last ...
		sta WSYNC       ;   for two scan lines
		sta WSYNC       ;   for  scan lines
		sta WSYNC       ;   for  scan lines

		bne ?loop       ; sta doesn't affect processor flags so we are still checking result of dex
		lda #$00        ; reset color to black
		sta ATARI.COLPF2
		pla             ; restore X & A registers from stack
		tax
		lda #<dli_game3      ; point to second DLI
		sta VDSLST
		pla ; restore registers
};
end;
procedure dli_game3; assembler; interrupt;
asm {
		pha             ; only using A register, so save it to the stack
		lda #$00        ; new background color
		sta WSYNC       ; first WSYNC gets us to start of scan line we want
		;sta ATARI.COLBK       ; change background color
		sta ATARI.COLPF2
		pla             ; restore A register from stack

};
end;



procedure vbl_game; interrupt;
begin
	if music then msx.play;
	asm {
		phr ; store registers
		lda #<dli_game1      ; point to second DLI
		sta VDSLST
		plr ; restore registers
		jmp $E462 ; jump to system VBL handler
	};
end;



// -----------------------------------------------------------------------------


procedure vbl_title; interrupt;
begin
	if music then msx.play;
	asm
	{
		// phr ; store registers

		mva #1 dli_title.cnt

		mva adr.fnt_Title chbase
		mva adr.fnt_Title+1 dli_title.chbs

		mva adr.c0_Title color0
		mva adr.c0_Title+1 dli_title.col0
		mva adr.c1_Title color1
		mva adr.c1_Title+1 dli_title.col1
		mva adr.c2_Title color2
		mva adr.c2_Title+1 dli_title.col2
		mva adr.c3_Title color3
		mva adr.c3_Title+1 dli_title.col3

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

	lda adr.fnt_Title,x
	sta chbs

	lda adr.c0_Title,x
	sta col0

	lda adr.c1_Title,x
	sta col1

	lda adr.c2_Title,x
	sta col2

	lda adr.c3_Title,x
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