
{**
  @abstract(Programme principal du moteur d'échecs UCI.)
  Dialogue avec l'utilisateur au moyen du protocole UCI.
}

program Alouette;

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes,
  SysUtils,
  Math,
  Journal,
  Joueur,
  Echecs,
  Utils,
{$IFDEF DEBUG}
  Essais,
{$ENDIF}
  Performance,
  Reglages;

{$I version.inc}
  
procedure Ecrire(const ATexte: string; const AEnvoi: boolean = TRUE);
begin
  WriteLn(output, ATexte);
  if AEnvoi then
    Flush(output);
end;

type
  {** Processus de recherche du meilleur coup. }
  TProcessus = class(TThread)
    protected
      procedure Execute; override;
  end;

var
  LTempsDispo: cardinal;
  LRecherche: boolean;

{** L'action du processus consiste à demander un coup au joueur d'échecs artificiel et à l'envoyer à l'utilisateur. }
procedure TProcessus.Execute;
var
  LTemps: cardinal;
  LCoup: string;
begin
  LTemps := GetTickCount64;
  LCoup := Joueur.Coup(LTempsDispo, LRecherche);
  LTemps := GetTickCount64 - LTemps;
  if not Terminated then
  begin
    Ecrire(Format('bestmove %s', [LCoup]));
    Journal.Ajoute(FormatDateTime('"Temps écoulé "hh:nn:ss:zzz"."', LTemps / (1000 * SECSPERDAY)));
  end;
end;

const
  CBoolStr: array[boolean] of string = ('false', 'true');
  
var
  LCmd: string;
  LIdx: integer;
  LCoup: string;
  LMTime, LWTime, LBTime, LMTG, LWInc, LBInc: integer;
  LPos: TPosition;
  LEchecs960: boolean;
  LProcessus: TProcessus;
  LProfondeur: integer;
  
begin
  LitFichierIni(LEchecs960, LRecherche);
  if not FichierIniExiste then
    EcritFichierIni(LEchecs960, LRecherche);
  RegleVariante(LEchecs960);
  if Pos('NOSEARCH', UpperCase(ParamStr(1))) > 0 then
    LRecherche := FALSE;
  Ecrire(Format('%s %s', [CApp, CVer]));
  while not EOF do
  begin
    ReadLn(input, LCmd);
    Journal.Ajoute(Concat('>> ', LCmd));
    if LCmd = 'quit' then
      Break
    else
      if LCmd = 'uci' then
      begin
        Ecrire(Format('id name %s %s', [CApp, CVer]), FALSE);
        Ecrire(Format('id author %s', [CAut]), FALSE);
        Ecrire(Format('option name UCI_Chess960 type check default %s', [CBoolStr[VarianteCourante]]), FALSE);
        Ecrire('uciok');
      end else
        if LCmd = 'isready' then
        begin
          Ecrire('readyok');
        end else
          if LCmd = 'ucinewgame' then
            Joueur.Oublie
          else
            if BeginsWith('position ', LCmd) then
            begin
              if WordPresent('startpos', LCmd) then
                Joueur.PositionDepart
              else
                if WordPresent('fen', LCmd) then
                  Joueur.NouvellePosition(GetFen(LCmd));
              if WordPresent('moves', LCmd) then
                for LIdx := 4 to WordsNumber(LCmd) do
                begin
                  LCoup := GetWord(LIdx, LCmd);
                  if IsChessMove(LCoup) then
                    Joueur.Rejoue(LCoup);
                end;
            end else
              if BeginsWith('go', LCmd) then
              begin
                LPos := Joueur.PositionCourante;
                if IsGoCmd(LCmd, LWTime, LBTime, LWInc, LBinc) then // go wtime 60000 btime 60000 winc 1000 binc 1000
                  LTempsDispo := IfThen(LPos.Trait, LBinc, LWInc)
                else
                  if IsGoCmd(LCmd, LWTime, LBTime, LMTG) then       // go wtime 59559 btime 56064 movestogo 38
                    LTempsDispo := IfThen(LPos.Trait, LBTime div LMTG, LWTime div LMTG)
                  else
                    if IsGoCmd(LCmd, LWTime, LBTime) then           // go wtime 600000 btime 600000
                      LTempsDispo := IfThen(LPos.Trait, LBTime, LWTime)
                    else
                      if IsGoCmd(LCmd, LMTime) then                 // go movetime 500
                        LTempsDispo := LMTime
                      else
                        Journal.Ajoute(Format('Commande non reconnue : %s', [LCmd]));
                
                LProcessus := TProcessus.Create(TRUE);
                with LProcessus do
                begin
                  FreeOnTerminate := TRUE;
                  //Priority := tpHigher;
                  Priority := tpNormal;
                  Start;
                end;
              end else
                if LCmd = 'stop' then
                begin
                  Ecrire(Format('bestmove %s', [Joueur.CoupImmediat]));
                  if Assigned(LProcessus) then
                    LProcessus.Terminate;
                end else
                  if BeginsWith('setoption name UCI_Chess960 value ', LCmd) then
                    RegleVariante(WordPresent('true', LCmd))
                  else
                    if LCmd = 'show' then
                      Ecrire(VoirPosition(PositionCourante))
                    else
                      if IsPerftCmd(LCmd, LProfondeur) then
                        EssaiPerf(PositionCourante, LProfondeur)
                      else
                        if LCmd = 'help' then
                          Ecrire(
                            'go movetime <x>'#13#10 +
                            'go wtime <x> btime <x>'#13#10 +
                            'go wtime <x> btime <x> movestogo <x>'#13#10 +
                            'go wtime <x> btime <x> winc <x> binc <x>'#13#10 +
                            'help'#13#10 +
                            'isready'#13#10 +
                            'perft <x>'#13#10 +
                            'position fen <fen> [moves ...]'#13#10 +
                            'position startpos [moves ...]'#13#10 +
                            'quit'#13#10 +
                            'setoption name UCI_Chess960 value <true,false>'#13#10 +
                            'show'#13#10 +
                            'stop'#13#10 +
                            'uci'#13#10 +
                            'ucinewgame'
                          )
                        else
                          Journal.Ajoute(Format('Commande non reconnue : %s', [LCmd]));
  end;
end.
