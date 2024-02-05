
  p_fire_spriteFrames: byte = $01;
  p_fire_spriteHeight: byte = $08;
  p_fire_spriteGap: byte = $02;

  p_fire_colors0: array [0..$01] of byte = (
    $00, $fe
  );
  p_fire_colors1: array [0..$01] of byte = (
    $00, $f4
  );

// missiles
  p_fire_framesMIS_0: array [0..$07] of byte = (
    $00, $00, $00, $03, $03, $00, $00, $00
  );
  p_fire_framesMIS_1: array [0..$07] of byte = (
    $00, $00, $08, $04, $04, $04, $04, $00
  );