(* define your types here *)

 
type TStage = record
   name: TString;
   numeric: byte;
   minTop: byte;
   maxTop: byte;
   minBottom: byte;
   maxBottom: byte;
   len: word;
   color: byte;
end;

type
   TGameState = (NEWGAME=0, GAMEINPROGRESS=1, GAMEOVER=2);
   // TTerrain = (UP=0, PLAIN=1, DOWN=2, PAD=3, WARN=4);
