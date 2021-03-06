
uses
  SysUtils, Board, Tables, Chess, Moves, Castling;

const
  CPos: array[0..3] of string = (
    'rnbqkbnr/pp1ppppp/2p5/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq -',
    'rnbqkbnr/2pppppp/p7/Pp6/8/8/1PPPPPPP/RNBQKBNR w KQkq b6',
    'rnbqkbnr/ppp3pp/3p1p2/4p3/4P3/5N2/PPPPBPPP/RNBQK2R w KQkq -',
    'rnbqk1nr/2pp1ppp/pp2p3/1Bb5/4P3/5P1N/PPPP2PP/RNBQK2R w KQkq -'
  );

{ Génération des coups pour une position donnée. }

var
  LPos: TPosition;
  LMoves: array[0..99] of integer;
  LCount, i: integer;

begin
  LPos := EncodePosition(CPos[3]);
  GenMoves(LPos, LMoves, LCount);
  GenCastling(LPos, LMoves, LCount);
  for i := 0 to Pred(LCount) do
    WriteLn(MoveToStr(LMoves[i]));
end.
