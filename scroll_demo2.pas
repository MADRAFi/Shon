program hscrollDemo;
 
uses atari, crt;
 
const
     DL_HSCROLL = $10;
     TEXT_ADR = $5000;
     DISPLAY_LIST_ADR = $4000;
     // SCREENWIDTH = 48;
     NUM = 96;
var
     DISPLAY_LIST: array [0..34] of byte =
     (
          $70,
          $42 + DL_HSCROLL,
          Lo(word(TEXT_ADR)),
          Hi(word(TEXT_ADR)),
          $42 + DL_HSCROLL,
          Lo(word(TEXT_ADR + (48 * 1))),
          Hi(word(TEXT_ADR + (48 * 1))),
          $42 + DL_HSCROLL,
          Lo(word(TEXT_ADR + (48 * 2))),
          Hi(word(TEXT_ADR + (48 * 2))),
          $42 + DL_HSCROLL,
          Lo(word(TEXT_ADR + (48 * 3))),
          Hi(word(TEXT_ADR + (48 * 3))),
          $42 + DL_HSCROLL,
          Lo(word(TEXT_ADR + (48 * 4))),
          Hi(word(TEXT_ADR + (48 * 4))),
          $42 + DL_HSCROLL,
          Lo(word(TEXT_ADR + (48 * 5))),
          Hi(word(TEXT_ADR + (48 * 5))),
          $42 + DL_HSCROLL,
          Lo(word(TEXT_ADR + (48 * 6))),
          Hi(word(TEXT_ADR + (48 * 6))),
          $42 + DL_HSCROLL,
          Lo(word(TEXT_ADR + (48 * 7))),
          Hi(word(TEXT_ADR + (48 * 7))),
          $42 + DL_HSCROLL,
          Lo(word(TEXT_ADR + (48 * 8))),
          Hi(word(TEXT_ADR + (48 * 8))),
          $42 + DL_HSCROLL,
          Lo(word(TEXT_ADR + (48 * 9))),
          Hi(word(TEXT_ADR + (48 * 9))),
          $70,
          $41,
          Lo(word(DISPLAY_LIST_ADR)),
          Hi(word(DISPLAY_LIST_ADR))
     );
 
 
var
     tmpByte: byte;
     dlist: word absolute $230;
     hscroll: byte absolute $d404;
     i:byte;
 
 
procedure WaitFrame;
begin
     asm {
          lda 20
          cmp 20
          beq *-2
     };
end;
 
begin
 
     // ustawiamy słowo savmsc na adres tekstu
     Savmsc := TEXT_ADR;
 
     // ustawiamy display listę
     WaitFrame;
     Dlist := word(@DISPLAY_LIST);

     // gotoxy(50,1);
     // Write ('0123456789012345678901234567890123456789');
     Write ('                                           Lorem ipsum dolor sit amet, consectetur adipiscing elit.                                            ');


     // tymczasowa wartość, w której trzymamy wartość dla rejestru płynnego przesuwu
     tmpByte := 4;    
     // przypisujemy wartość w rejestrze sprzętowym, o ile cykli koloru ma być przesunięty wiersz      
     hscroll := tmpByte;
 
     repeat
          WaitFrame;
     //     for i:=0 to 9 do
     //      begin
     //           gotoxy(40,i);
     //           Write ('#');
     //      end;
          



          // zmniejszamy o jeden co każdą ramkę
          Dec(tmpByte);
          // i uaktualniamy rejestr sprzętowy
          hscroll := tmpByte;
          // jeśli przesunęliśmy o cztery pozycje to przesuwamy wskaźnik początku pamięci o jeden znak
          if tmpByte = 0 then begin
               // uaktualniamy LMS (piąty element w display liście)
               Inc(DISPLAY_LIST[2]);
               // Inc(DISPLAY_LIST[5]);
               // Inc(DISPLAY_LIST[8]);
               // Inc(DISPLAY_LIST[11]);
               // Inc(DISPLAY_LIST[14]);
               // Inc(DISPLAY_LIST[17]);
               // Inc(DISPLAY_LIST[20]);
               // Inc(DISPLAY_LIST[23]);
               // Inc(DISPLAY_LIST[26]);
               // Inc(DISPLAY_LIST[29]);

               // jeśli przewinęliśmy 100 znaków, to resetujemy wskaźnik LMS do początku żeby zapętlić skrolla
               if DISPLAY_LIST[2] = NUM then DISPLAY_LIST[2] := 0;
               // if DISPLAY_LIST[5] = NUM then DISPLAY_LIST[5] := 0;
               // if DISPLAY_LIST[8] = NUM then DISPLAY_LIST[8] := 0;
               // if DISPLAY_LIST[11] = NUM then DISPLAY_LIST[2] := 0;
               // if DISPLAY_LIST[14] = NUM then DISPLAY_LIST[5] := 0;
               // if DISPLAY_LIST[17] = NUM then DISPLAY_LIST[8] := 0;
               // if DISPLAY_LIST[20] = NUM then DISPLAY_LIST[8] := 0;
               // if DISPLAY_LIST[23] = NUM then DISPLAY_LIST[8] := 0;
               // if DISPLAY_LIST[26] = NUM then DISPLAY_LIST[8] := 0;
               // if DISPLAY_LIST[29] = NUM then DISPLAY_LIST[8] := 0;

               // resetujemy też rejestr sprzętowy hscroll
               // tmpByte := 4;
               hscroll := tmpByte;
               // i tak w kółko
          end;
 
     until keypressed;
 
end.