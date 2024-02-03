
  p_fire_spriteFrames: byte = $01;
  p_fire_spriteHeight: byte = $08;
  p_fire_spriteGap: byte = $02;

  p_fire_colors0: array [0..$01] of byte = (
    $00, $0e
  );
  p_fire_colors1: array [0..$01] of byte = (
    $00, $16
  );

// missiles
  p_fire_framesMIS_0: array [0..$07] of byte = (
    $01, $03, $03, $01, $00, $00, $00, $00
  );
  p_fire_framesMIS_1: array [0..$07] of byte = (
    $08, $0e, $0e, $08, $00, $00, $00, $00
  );