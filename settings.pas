
unit Settings;

interface

procedure LoadSettings(out AVariante: boolean);
procedure SaveSettings(const AVariante: boolean);
function SettingsFileExists: boolean;

implementation

uses
  SysUtils, IniFiles;

const
  SECTION = '.';
  DEFAUT_VARIANTE = 'FALSE';
  CBoolStr: array[boolean] of string = ('false', 'true');
  
var
  LChemin: string;
  
procedure LoadSettings(out AVariante: boolean);
begin
  with TIniFile.Create(LChemin) do
  try
    AVariante := UpperCase(ReadString(SECTION, 'frc', DEFAUT_VARIANTE)) = 'TRUE';
  finally
    Free;
  end;
end;

procedure SaveSettings(const AVariante: boolean);
begin
  with TIniFile.Create(LChemin) do
  try
    WriteString(SECTION, 'frc', CBoolStr[AVariante]);
    UpdateFile;
  finally
    Free;
  end;
end;

function SettingsFileExists: boolean;
begin
  result := FileExists(LChemin);
end;

begin
  LChemin := ChangeFileExt(ParamStr(0), '.ini');
end.
