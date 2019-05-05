
{**
  @abstract(Journal.)
  Unit� pour la production d'un journal.
}

unit Journal;

interface

uses
  SysUtils;

type
  TJournal = class
    class procedure Ajoute(const ALigne: string; const AHtml: boolean = FALSE);
    class procedure AjouteTable(const ACoups, ANotes: array of integer; const n: integer; const ATitre: string);
  end;

implementation

uses
  Damier;

{$IFDEF DEBUG}
var
  GFichier: array[boolean] of text;
{$ENDIF}

class procedure TJournal.Ajoute(const ALigne: string; const AHtml: boolean);
begin
{$IFDEF DEBUG}
  if AHtml then
    WriteLn(GFichier[AHtml], ALigne)
  else
    WriteLn(GFichier[AHtml], Concat(DateTimeToStr(Now()), ' ', ALigne));
  Flush(GFichier[AHtml]);
{$ENDIF}
end;

class procedure TJournal.AjouteTable(const ACoups, ANotes: array of integer; const n: integer; const ATitre: string);
{$IFDEF DEBUG}
var
  s: string;
  i: integer;
{$ENDIF}
begin
{$IFDEF DEBUG}
  s := '<table><caption>' + ATitre + '</caption>'#13#10;
  s := s + '<tr>';
  for i := 0 to Pred(n) do
    s := s + Format('<th>%s</th>', [NomCoup(ACoups[i])]);
  s := s + '</tr>';
  s := s + '<tr>';
  for i := 0 to Pred(n) do
    s := s + Format('<td>%d</td>', [ANotes[i]]);
  s := s + '</tr>';
  s := s + '</table>';
  WriteLn(GFichier[TRUE], s);
  Flush(GFichier[TRUE]);
{$ENDIF}
end;

var
  LName: array[boolean] of string;
{$IFDEF DEBUG}
  LIdx: boolean;
{$ENDIF}

initialization
  LName[FALSE] := FormatDateTime('yyyymmddhhnnss".log"', Now);
  LName[TRUE] := ChangeFileExt(LName[FALSE], '.html');
{$IFDEF DEBUG}
  for LIdx := FALSE to TRUE do
  begin
    Assign(GFichier[LIdx], LName[LIdx]);
    Rewrite(GFichier[LIdx]);
  end;
  WriteLn(
    GFichier[TRUE],
    '<!DOCTYPE html>'#13#10 +
    '<html>'#13#10 +
    '<head>'#13#10 +
    '<link rel="stylesheet" href="style.css">'#13#10 +
    '</head>'#13#10 +
    '<body>'
  );
{$ENDIF}

finalization
{$IFDEF DEBUG}
  WriteLn(
    GFichier[TRUE],
    '</body>'#13#10 +
    '</html>'
  );
  Close(GFichier[FALSE]);
  Close(GFichier[TRUE]);
{$ENDIF}

end.
