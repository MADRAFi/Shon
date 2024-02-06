var
  m_explode_spriteFrames: byte = $05;
  m_explode_spriteHeight: byte = $08;
  m_spriteGap: byte = $00;

  m_explode_colors0: array [0..$04] of byte = (
    $0e, $0e, $0e, $0e, $0e
  );
  m_explode_colors1: array [0..$04] of byte = (
    $16, $16, $16, $16, $16
  );

// sprite 0 data
  m_explode_frames0_0: array [0..$07] of byte = (
    $18, $3c, $7e, $ff, $ff, $7e, $3c, $18
  );
  m_explode_frames0_1: array [0..$07] of byte = (
    $00, $18, $3c, $7e, $7e, $3c, $18, $00
  );
  m_explode_frames0_2: array [0..$07] of byte = (
    $00, $00, $18, $3c, $3c, $18, $00, $00
  );
  m_explode_frames0_3: array [0..$07] of byte = (
    $00, $00, $00, $18, $18, $00, $00, $00
  );
  m_explode_frames0_4: array [0..$07] of byte = (
    $00, $00, $00, $00, $00, $00, $00, $00
  );

// sprite 1 data
  m_explode_frames1_0: array [0..$07] of byte = (
    $18, $24, $42, $81, $81, $42, $24, $18
  );
  m_explode_frames1_1: array [0..$07] of byte = (
    $18, $3c, $7e, $ff, $ff, $7e, $3c, $18
  );
  m_explode_frames1_2: array [0..$07] of byte = (
    $00, $18, $3c, $7e, $7e, $3c, $18, $00
  );
  m_explode_frames1_3: array [0..$07] of byte = (
    $00, $00, $18, $3c, $3c, $18, $00, $00
  );
  m_explode_frames1_4: array [0..$07] of byte = (
    $00, $00, $00, $18, $18, $00, $00, $00
  );

m_explode_0: array [0..$04] of pointer = (
  @m_explode_frames0_0, @m_explode_frames0_1, @m_explode_frames0_2, @m_explode_frames0_3, @m_explode_frames0_4
);
m_explode_1: array [0..$04] of pointer = (
  @m_explode_frames1_0, @m_explode_frames1_1, @m_explode_frames1_2, @m_explode_frames1_3, @m_explode_frames1_4
);