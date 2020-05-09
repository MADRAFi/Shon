(* define your types here *)

(* example type 
type Tplayer = record
   name: TString;
   level: byte;
   score: cardinal; 
end;
*)
type
   TGameState = (NEWGAME=0, GAMEINPROGRESS=1, GAMEOVER=2);
