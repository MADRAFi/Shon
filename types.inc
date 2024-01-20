(* define your types here *)

 
type TStage = record
   name: TString;
   numeric: byte;
   maxTop: byte;
   maxBottom: byte;
end;

type
   TGameState = (NEWGAME=0, GAMEINPROGRESS=1, GAMEOVER=2);
   TTerrain = (UP=0, PLANE=1, DOWN=2, PAD=3);
