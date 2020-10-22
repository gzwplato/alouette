
{**
  @abstract(Génération des coups.)
  Génération des coups.
}

unit Moves;

interface

uses
  Chess, Board, Move;

function GenMoves(const APos: TPosition; var AList: array of integer; out ACount: integer; const AQuick: boolean = FALSE): TBoard; overload;
{** Renvoie un damier représentant les cases pouvant être atteintes. Les coups ne sont pas conservés. }
function GenMoves(const APos: TPosition): TBoard; overload;
function GetMovesCount(const APos: TPosition): integer;
function GenPotentialPawnMoves(const APos: TPosition): TBoard;
function IsCheck(const APos: TPosition): boolean;
function GetProtectionsCount(const APos: TPosition): integer;

implementation

uses
  SysUtils, Tables, Log;

function GenMoves(const APos: TPosition; var AList: array of integer; out ACount: integer; const AQuick: boolean): TBoard;
var
  LCompte: integer = 0;

  procedure SaveMove(const i, j: integer; const p: TPieceType; const c: TMoveType = mtCommon);
  begin
    SwitchOn(result, CIndexToSquare[j]);
    Inc(LCompte);
    if not AQuick then
      if LCompte <= Length(AList) then
        AList[Pred(LCompte)] := EncodeMove(i, j, p, c)
      else
        Log.Append('** Cannot append move');
  end;

const
  CPion: array[boolean] of TPieceType = (ptWhitePawn, ptBlackPawn);
var
  { Toutes les pièces. }
  LPieces: TBoard;
  i, j, k: integer;
begin
  LPieces := APos.Pieces[FALSE] or APos.Pieces[TRUE];
  
  result := 0; { Damier vide. }
  
  for i := A1 to H8 do if IsOn(APos.Pieces[APos.SideToMove], CIndexToSquare[i]) then
  begin
    { Pion. }
    if IsOn(APos.Pawns, CIndexToSquare[i]) then
    begin
      { Pas en avant. }
      k := 8 - 16 * Ord(APos.SideToMove);
      j := i + k;
      if not IsOn(LPieces, CIndexToSquare[j]) then
      begin
        SaveMove(i, j, CPion[APos.SideToMove]);
        { Second pas en avant. }
        if ((j div 8 = 2) and not APos.SideToMove)
        or ((j div 8 = 5) and APos.SideToMove) then
        begin
          j := j + k;
          if not IsOn(LPieces, CIndexToSquare[j]) then
            SaveMove(i, j, CPion[APos.SideToMove]);
        end;
      end;
      { Prise côté dame. }
      if i mod 8 > 0 then
      begin
        j := Pred(i + k);
        if IsOn(APos.Pieces[not APos.SideToMove], CIndexToSquare[j]) xor (j = APos.EnPassant) then
          if j = APos.EnPassant then
          SaveMove(i, j, CPion[APos.SideToMove], mtEnPassant) else
          SaveMove(i, j, CPion[APos.SideToMove], mtCapture);
      end;
      { Prise côté roi. }
      if i mod 8 < 7 then
      begin
        j := Succ(i + k);
        if IsOn(APos.Pieces[not APos.SideToMove], CIndexToSquare[j]) xor (j = APos.EnPassant) then
          if j = APos.EnPassant then
          SaveMove(i, j, CPion[APos.SideToMove], mtEnPassant) else
          SaveMove(i, j, CPion[APos.SideToMove], mtCapture);
      end;
    end else
    { Tour. }
    if IsOn(APos.Rooks, CIndexToSquare[i]) then
    begin
      for j := A1 to H8 do
        if IsOn(CTargets[ptRook, i], CIndexToSquare[j])
        and not IsOn(APos.Pieces[APos.SideToMove], CIndexToSquare[j])
        and ((CPath[i, j] and LPieces) = 0) then
          if IsOn(APos.Pieces[not APos.SideToMove], CIndexToSquare[j]) then
          SaveMove(i, j, ptRook, mtCapture) else
          SaveMove(i, j, ptRook);
    end else
    { Cavalier. }
    if IsOn(APos.Knights, CIndexToSquare[i]) then
    begin
      for j := A1 to H8 do
        if IsOn(CTargets[ptKnight, i], CIndexToSquare[j])
        and not IsOn(APos.Pieces[APos.SideToMove], CIndexToSquare[j]) then
          if IsOn(APos.Pieces[not APos.SideToMove], CIndexToSquare[j]) then
          SaveMove(i, j, ptKnight, mtCapture) else
          SaveMove(i, j, ptKnight);
    end else
    { Fou. }
    if IsOn(APos.Bishops, CIndexToSquare[i]) then
    begin
      for j := A1 to H8 do
        if IsOn(CTargets[ptBishop, i], CIndexToSquare[j])
        and not IsOn(APos.Pieces[APos.SideToMove], CIndexToSquare[j])
        and ((CPath[i, j] and LPieces) = 0) then
          if IsOn(APos.Pieces[not APos.SideToMove], CIndexToSquare[j]) then
          SaveMove(i, j, ptBishop, mtCapture) else
          SaveMove(i, j, ptBishop);
    end else
    { Dame. }
    if IsOn(APos.Queens, CIndexToSquare[i]) then
    begin
      for j := A1 to H8 do
        if IsOn(CTargets[ptQueen, i], CIndexToSquare[j])
        and not IsOn(APos.Pieces[APos.SideToMove], CIndexToSquare[j])
        and ((CPath[i, j] and LPieces) = 0) then
          if IsOn(APos.Pieces[not APos.SideToMove], CIndexToSquare[j]) then
          SaveMove(i, j, ptQueen, mtCapture) else
          SaveMove(i, j, ptQueen);
    end else
    { Roi. }
    if IsOn(APos.Kings, CIndexToSquare[i]) then
    begin
      for j := A1 to H8 do
        if IsOn(CTargets[ptKing, i], CIndexToSquare[j])
        and not IsOn(APos.Pieces[APos.SideToMove], CIndexToSquare[j]) then
          if IsOn(APos.Pieces[not APos.SideToMove], CIndexToSquare[j]) then
          SaveMove(i, j, ptKing, mtCapture) else
          SaveMove(i, j, ptKing);
    end;
  end;
  ACount := LCompte;
end;

function GenMoves(const APos: TPosition): TBoard;
var
  LListe: array[0..0] of integer;
  LCompte: integer;
begin
  result := GenMoves(APos, LListe, LCompte, TRUE);
end;

function GetMovesCount(const APos: TPosition): integer;
var
  LListe: array[0..0] of integer;
begin
  GenMoves(APos, LListe, result, TRUE);
end;

function GenPotentialPawnMoves(const APos: TPosition): TBoard;
var
  { Pièces. }
  i, j: integer;
  LPion: TPieceType;
begin
  if APos.SideToMove then
    LPion := ptBlackPawn
  else
    LPion := ptWhitePawn;
  result := 0; { Damier vide. }
  for i := A1 to H8 do if IsOn(APos.Pieces[APos.SideToMove], CIndexToSquare[i]) then
  begin
    { Pion. }
    if IsOn(APos.Pawns, CIndexToSquare[i]) then
    begin
      for j := A1 to H8 do
        if IsOn(CTargets[LPion, i], CIndexToSquare[j])
        and not IsOn(APos.Pieces[APos.SideToMove], CIndexToSquare[j]) then
          SwitchOn(result, CIndexToSquare[j]);
    end;
  end;
end;

function IsCheck(const APos: TPosition): boolean;
var
  LPos: TPosition;
begin
  LPos := APos;
  LPos.SideToMove := not LPos.SideToMove;
  result := (GenMoves(LPos) and LPos.Kings) <> 0;
end;

function GetProtectionsCount(const APos: TPosition): integer;
(*
const
  CPion: array[boolean] of TPieceType = (ptWhitePawn, ptBlackPawn);
*)
var
  { Toutes les pièces. }
  LPieces: TBoard;
  i, j, k: integer;
begin
  LPieces := APos.Pieces[FALSE] or APos.Pieces[TRUE];
  result := 0;
  
  for i := A1 to H8 do if IsOn(APos.Pieces[APos.SideToMove], CIndexToSquare[i]) then
  begin
    { Pion. }
    if IsOn(APos.Pawns, CIndexToSquare[i]) then
    begin
      //Log.Append(CSquareToStr[i], TRUE);
      k := 8 - 16 * Ord(APos.SideToMove);
      j := i + k;
      { Prise côté A. }
      if i mod 8 > 3 then
      begin
        j := Pred(i + k);
        if IsOn(APos.Pieces[APos.SideToMove] and APos.Pawns, CIndexToSquare[j]) then
          Inc(result);
      end;
      { Prise côté H. }
      if i mod 8 < 4 then
      begin
        j := Succ(i + k);
        if IsOn(APos.Pieces[APos.SideToMove] and APos.Pawns, CIndexToSquare[j]) then
          Inc(result);
      end;
    end else
    { Tour. }
    if IsOn(APos.Rooks, CIndexToSquare[i]) then
    begin
      (*
      for j := A1 to H8 do
        if IsOn(CTargets[ptRook, i], CIndexToSquare[j])
        and IsOn(APos.Pieces[APos.SideToMove] and (APos.Pawns or APos.Knights or APos.Bishops or APos.Rooks), CIndexToSquare[j])
        and ((CPath[i, j] and LPieces) = 0) then
          Inc(result);
      *)
    end else
    { Cavalier. }
    if IsOn(APos.Knights, CIndexToSquare[i]) then
    begin
      (*
      for j := A1 to H8 do
        if IsOn(CTargets[ptKnight, i], CIndexToSquare[j])
        and IsOn(APos.Pieces[APos.SideToMove] and (APos.Pawns or APos.Knights or APos.Bishops), CIndexToSquare[j]) then
          Inc(result);
      *)
    end else
    { Fou. }
    if IsOn(APos.Bishops, CIndexToSquare[i]) then
    begin
      (*
      for j := A1 to H8 do
        if IsOn(CTargets[ptBishop, i], CIndexToSquare[j])
        and IsOn(APos.Pieces[APos.SideToMove] and (APos.Pawns or APos.Knights or APos.Bishops), CIndexToSquare[j])
        and ((CPath[i, j] and LPieces) = 0) then
          Inc(result);
      *)
    end else
    { Dame. }
    if IsOn(APos.Queens, CIndexToSquare[i]) then
    begin
      (*
      for j := A1 to H8 do
        if IsOn(CTargets[ptQueen, i], CIndexToSquare[j])
        and IsOn(APos.Pieces[APos.SideToMove] and (APos.Pawns or APos.Knights or APos.Bishops or APos.Rooks or APos.Queens), CIndexToSquare[j])
        and ((CPath[i, j] and LPieces) = 0) then
          Inc(result);
      *)
    end else
    { Roi. }
    if IsOn(APos.Kings, CIndexToSquare[i]) then
    begin
      (*
      for j := A1 to H8 do
        if IsOn(CTargets[ptKing, i], CIndexToSquare[j])
        and IsOn(APos.Pieces[APos.SideToMove] and APos.Pawns, CIndexToSquare[j]) then
          Inc(result);
      *)
    end;
  end;
end;

end.
