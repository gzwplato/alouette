
{**
  @abstract(Manipulation des chaînes de caractères.)
  Manipulation des chaînes de caractères.
}

unit Outils;

interface

function CommencePar(const AChaine1, AChaine2: string): boolean;
function NombreMots(const AChaine: string): integer;
function Contient(const AMot, AChaine: string): boolean;
function Extrait(const AIndex: integer; const AChaine: string): string;
function ExtraitEpd(const AChaine: string): string;
function DecodeChaineCoup(const AChaine: string): boolean;

implementation

uses
  SysUtils, StrUtils;

function CommencePar(const AChaine1, AChaine2: string): boolean;
begin
  result := Pos(AChaine1, AChaine2) = 1;
end;

function NombreMots(const AChaine: string): integer;
begin
  result := WordCount(AChaine, [' ']);
end;

function Contient(const AMot, AChaine: string): boolean;
begin
  result := IsWordPresent(AMot, AChaine, [' ']);
end;

function Extrait(const AIndex: integer; const AChaine: string): string;
begin
  result := ExtractWord(AIndex, AChaine, [' ']);
end;

function ExtraitEpd(const AChaine: string): string;
begin
  result := Format('%s %s %s %s', [
    Extrait(3, AChaine),
    Extrait(4, AChaine),
    Extrait(5, AChaine),
    Extrait(6, AChaine)
  ]);
end;

function DecodeChaineCoup(const AChaine: string): boolean;
begin
  result := (Length(AChaine) >= 4)
    and (AChaine[1] in ['a'..'h'])
    and (AChaine[2] in ['1'..'8'])
    and (AChaine[3] in ['a'..'h'])
    and (AChaine[4] in ['1'..'8']);
end;

end.
