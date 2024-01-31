var
  p_explode_spriteFrames: byte = $06;
  // spriteHeight: byte = $11;
  // spriteGap: byte = $00;

  p_explode_colors0: array [0..$05] of byte = (
    $0e, $0e, $0e, $0e, $0e, $0e
  );
  p_explode_colors1: array [0..$05] of byte = (
    $16, $16, $16, $16, $16, $16
  );

// sprite 0 data
  p_explode_frames0_0: array [0..$10] of byte = (
    $18, $18, $3c, $3c, $7e, $7e, $ff, $ff, $ff, $ff, $ff, $7e, $7e, $3c, $3c, $18,
    $18
  );
  p_explode_frames0_1: array [0..$10] of byte = (
    $00, $00, $18, $18, $3c, $3c, $7e, $7e, $7e, $7e, $7e, $3c, $3c, $18, $18, $00,
    $00
  );
  p_explode_frames0_2: array [0..$10] of byte = (
    $00, $00, $00, $00, $18, $18, $3c, $3c, $3c, $3c, $3c, $18, $18, $00, $00, $00,
    $00
  );
  p_explode_frames0_3: array [0..$10] of byte = (
    $00, $00, $00, $06, $06, $04, $04, $0c, $18, $78, $7c, $0c, $0c, $06, $06, $00,
    $00
  );
  p_explode_frames0_4: array [0..$10] of byte = (
    $00, $00, $00, $06, $06, $00, $00, $00, $00, $60, $60, $00, $00, $06, $06, $00,
    $00
  );
  p_explode_frames0_5: array [0..$10] of byte = (
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00
  );

// sprite 1 data
  p_explode_frames1_0: array [0..$10] of byte = (
    $18, $18, $24, $24, $42, $42, $81, $81, $81, $81, $81, $42, $42, $24, $24, $18,
    $18
  );
  p_explode_frames1_1: array [0..$10] of byte = (
    $18, $18, $3c, $3c, $7e, $7e, $ff, $ff, $ff, $ff, $ff, $7e, $7e, $3c, $3c, $18,
    $18
  );
  p_explode_frames1_2: array [0..$10] of byte = (
    $00, $00, $18, $18, $3c, $3c, $7e, $7e, $7e, $7e, $7e, $3c, $3c, $18, $18, $00,
    $00
  );
  p_explode_frames1_3: array [0..$10] of byte = (
    $00, $06, $06, $0f, $0f, $0e, $0e, $7e, $7c, $fc, $fe, $7e, $6e, $0f, $0f, $06,
    $06
  );
  p_explode_frames1_4: array [0..$10] of byte = (
    $00, $06, $06, $0f, $0f, $06, $06, $60, $60, $f0, $f0, $66, $66, $0f, $0f, $06,
    $06
  );
  p_explode_frames1_5: array [0..$10] of byte = (
    $00, $00, $00, $06, $06, $00, $00, $00, $00, $60, $60, $00, $00, $06, $06, $00,
    $00
  );

p_explode_0: array [0..$05] of pointer = (
  @p_explode_frames0_0, @p_explode_frames0_1, @p_explode_frames0_2, @p_explode_frames0_3, @p_explode_frames0_4, @p_explode_frames0_5
);
p_explode_1: array [0..$05] of pointer = (
  @p_explode_frames1_0, @p_explode_frames1_1, @p_explode_frames1_2, @p_explode_frames1_3, @p_explode_frames1_4, @p_explode_frames1_5
);