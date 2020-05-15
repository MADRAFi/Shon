program hscrollDemo;
 
uses atari, crt;
 
const
     DL_HSCROLL = $10;
     TEXT_ADR = $5000;
     DISPLAY_LIST_ADR = $4000;
 
var
     DISPLAY_LIST: array [0..8] of byte =
     (
          $70,
          $70,
          $70,
          $42 + DL_HSCROLL,
          Lo(word(TEXT_ADR)),
          Hi(word(TEXT_ADR)),
          $41,
          Lo(word(DISPLAY_LIST_ADR)),
          Hi(word(DISPLAY_LIST_ADR))
     );
 
 
var
     tmpByte: byte;
     dlist: word absolute $230;
     hscroll: byte absolute $d404;
 
 
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
     // Write ('                                           Lorem ipsum dolor sit amet, consectetur adipiscing elit.                                            ');
     // Write('                                                ');

     // tymczasowa wartość, w której trzymamy wartość dla rejestru płynnego przesuwu
     tmpByte := 4;    
     // przypisujemy wartość w rejestrze sprzętowym, o ile cykli koloru ma być przesunięty wiersz      
     // hscroll := tmpByte;
 
     repeat
          WaitFrame;


          // zmniejszamy o jeden co każdą ramkę
          Dec(tmpByte);
          // i uaktualniamy rejestr sprzętowy
          hscroll := tmpByte;
          // jeśli przesunęliśmy o cztery pozycje to przesuwamy wskaźnik początku pamięci o jeden znak
          if tmpByte = 0 then begin
               poke(dpeek(word(@DISPLAY_LIST)+4)+44,ord('X'~));
               poke(dpeek(word(@DISPLAY_LIST)+4)+3,ord('X'~));
               // uaktualniamy LMS (piąty element w display liście)
               Inc(DISPLAY_LIST[4]);
               // jeśli przewinęliśmy 100 znaków, to resetujemy wskaźnik LMS do początku żeby zapętlić skrolla
               if DISPLAY_LIST[4] = 96 then DISPLAY_LIST[4] := 0;
               // resetujemy też rejestr sprzętowy hscroll
               tmpByte := 4;
               hscroll := tmpByte;
               // i tak w kółko
          end;
 
     until keypressed;
 
end.