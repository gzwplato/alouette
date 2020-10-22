
{**
  @abstract(Roque.)
  Génération du roque.
}

unit Castling;

interface

uses
  Chess, Log;

procedure GenCastling(const APos: TPosition; var AList: array of integer; var ACount: integer);

implementation

uses
  SysUtils, Board, Tables, Moves;

procedure GenCastling(const APos: TPosition; var AList: array of integer; var ACount: integer);

  procedure SaveMove(const AFrom, ATo: integer);
  begin
    Inc(ACount);
    if ACount <= Length(AList) then
      AList[Pred(ACount)] := EncodeMove(AFrom, ATo, ptKing, mtCastling)
    else
      Log.Append('** Cannot append move');
  end;

var
{** Toutes les pièces. }
  LPieces,
{** Cases menacées par l'adversaire. }
  LThreats: TBoard;
  LRow,
{** Colonne de départ du roi. }
  LKingFromCol,
{** Colonne de départ de la tour. }
  LRookFromCol: integer;
  LPos: TPosition;
  
procedure Search(const AKingToCol, ARookToCol: integer); { Colonnes d'arrivée. }
var
  LKingFromIdx, LRookFromIdx, LKingToIdx, LRookToIdx: integer;
{ Chemin à parcourir, y compris la case d'arrivée. }
  LKingPath, LRookPath, LPath: TBoard;
{ Pièces autorisées sur le parcours. }
  LRooks, LKing: TBoard;
begin
  LKingFromIdx := ToIndex(LKingFromCol, LRow);
  LKingToIdx := ToIndex(AKingToCol, LRow);
  LRookFromIdx := ToIndex(LRookFromCol, LRow);
  LRookToIdx := ToIndex(ARookToCol, LRow);
  Log.Append(Format('** Generate castling king %s rook %s', [MoveToStr(LKingFromIdx, LKingToIdx), MoveToStr(LRookFromIdx, LRookToIdx)]));

{ Vérification de la première condition : il y a bien une tour à l'endroit prévu. }
  with APos do if IsOn(Pieces[SideToMove] and Rooks, CIndexToSquare[LRookFromIdx]) then
    Log.Append('** Rook on square (cond. 1/3)')
  else
    Exit;

{ Deuxième condition : aucune pièce n'est sur le passage du roi ni sur celui de la tour. }
  LKingPath := CPath[LKingFromIdx, LKingToIdx] or CIndexToSquare[LKingToIdx];
  LRookPath := CPath[LRookFromIdx, LRookToIdx] or CIndexToSquare[LRookToIdx];
  LPath := LKingPath or LRookPath;
  with APos do
  begin
    LRooks := Rooks and Pieces[SideToMove];
    LKing  := Kings and Pieces[SideToMove];
  end;
  if ((LPath and LPieces) = (LPath and (LRooks or LKing)))
  and (CountSquaresOn(LPath and LRooks) <= 1)
  and (CountSquaresOn(LPath and LKing) <= 1)
  then
    Log.Append('** No piece on the path (cond. 2/3)')
  else
    Exit;

{ Dernière condition : aucune des cases sur lesquelles le roi se trouve ou se trouvera n'est menacée. }
  LKingPath := CIndexToSquare[LKingFromIdx] or CPath[LKingFromIdx, LKingToIdx] or CIndexToSquare[LKingToIdx];
  if (LThreats and LKingPath) = 0 then
    Log.Append('** No attacked square (cond. 3/3)')
  else
    Exit;
  
  SaveMove(LKingFromIdx, LRookFromIdx);
end;

begin
  if APos.SideToMove then LRow := CRow8 else LRow := CRow1;
  LPieces := APos.Pieces[FALSE] or APos.Pieces[TRUE];
  LPos := APos;
  LPos.SideToMove := not LPos.SideToMove;
  LThreats := GenMoves(LPos) or GenPotentialPawnMoves(LPos);
  LKingFromCol := SquareToCol(APos.KingSquare[APos.SideToMove]);
  
  LRookFromCol := APos.Roque[APos.SideToMove].KingRookCol;
  if (LRookFromCol >= 0) and (LRookFromCol <= 7) then
    Search(CColG, CColF);
  
  LRookFromCol := APos.Roque[APos.SideToMove].QueenRookCol;
  if (LRookFromCol >= 0) and (LRookFromCol <= 7) then
    Search(CColC, CColD);
end;

end.
