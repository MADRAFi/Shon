  p_spriteFrames: byte = $01;
  p_spriteHeight: byte = $11;
  p_spriteGap: byte = $00;

  p_colors0: array [0..$01] of byte = (
    $0e, $0c
  );
  p_colors1: array [0..$01] of byte = (
    $0e, $24
  );

// player sprite 0 data
  p_frames0_0: array [0..$10] of byte = (
    $00, $00, $00, $00, $18, $00, $18, $3e, $3f, $3e, $18, $00, $18, $00, $00, $00,
    $00
  );

// player sprite 1 data
  p_frames1_0: array [0..$10] of byte = (
    $10, $00, $10, $18, $18, $18, $3e, $3f, $01, $3f, $3e, $18, $18, $18, $10, $00,
    $10
  );