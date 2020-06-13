; -- krci.iss --
; Installs all client software to play FFXI on the Kujata Reborn server

#pragma include __INCLUDE__ + ";" + ReadReg(HKLM, "Software\Mitrich Software\Inno Download Plugin", "InstallDir")
#pragma include __INCLUDE__ + ";" + "c:\lib\InnoDownloadPlugin"
#include <idp.iss>

#define TheAppName "Kujata Reborn Client"
#define TheAppVersion "0.1"
#define TheAppPublisher "KujataReborn.com"
#define TheAppURL "http://kujatareborn.com/wordpress/"
#define TheAppSupportURL "https://discord.com/invite/uBWtbz"
#define TheAppUpdateURL "http://kujatareborn.com/wordpress/"
#define ManifestURL "https://drive.google.com/uc?export=download&id=1emgTwMWvGLPLBsT2o9t9yd7p0E7glW48"
#define ManifestKeyValueSeparator "="
; #define ManifestURL "https://drive.google.com/uc?export=download&id=1emgTwMWvGLPLBsT2o9t9yd7p0E7glW489"

[Setup]
AppId = {{2B9AF53B-8A41-4135-B0E8-6B39235624A2}
AppName={#TheAppName}
AppVersion={#TheAppVersion}
AppPublisher={#TheAppPublisher}
AppPublisherURL={#TheAppURL}
AppSupportURL={#TheAppURL}
AppUpdatesURL={#TheAppUpdateURL}
WizardStyle=modern
DefaultDirName={autopf}\My Program
DefaultGroupName=My Program
UninstallDisplayIcon={app}\MyProg.exe
Compression=lzma2
SolidCompression=yes
OutputBaseFilename=krci
OutputDir=userdocs:Inno Setup Examples Output

AllowNetworkDrive=no
AllowUNCPath=no


[Files]
Source: "MyProg.exe"; DestDir: "{app}"
Source: "MyProg.chm"; DestDir: "{app}";
Source: "krcimanifest.ini"; DestDir: "{app}"
Source: "Readme.txt"; DestDir: "{app}"; Flags: isreadme

[Icons]
Name: "{group}\My Program"; Filename: "{app}\MyProg.exe"

[Code]
(* TODO: Awesome type documentation *)
type
  MItem = record
    Key: String;
    Value: array of String;
  end;

(* TODO: Give description of global variables *)
var
  MVerControl: MItem;
  MOptions: array of MItem;
  MLocations: array of MItem;

(* TODO: Awesome function documentation *)
function RetrieveManifest(): Boolean;
var
  res: Boolean;
begin
  (* TODO: Check for local manifest first *)
  res := idpDownloadFile('{#ManifestURL}', ExpandConstant('{tmp}\krcimanifest.ini'));

  if not res then begin
    MsgBox('Failed to download the manifest file.', mbError, MB_OK);
  end;

  Result := res 
end;

(* TODO: Awesome function documentation *)
function SplitManifestKeyValuePair(const Line: String; var Key: String; var Value: String): Boolean;
var
  res: Boolean;
  p: Integer;
begin
  res := True

  p := Pos('{#ManifestKeyValueSeparator}', Line);
  if p <= 0 then begin
    res := False;
  end;

  if res then begin
    MsgBox('Line == ' + Line, mbInformation, MB_OK);
    Key := Line;
    Delete(Key, p, Length(Key)-(p-1));
    Key := Trim(Key);

    Value := Line;
    Delete(Value, 1, p);
    Value := Trim(Value);
  end;

  Result := res;
end;

(* TODO: Awesome function documentation *)
function ParseManifestOptions(): Boolean;
var
  res: Boolean;
  Manifest TStringList;
  i: Integer;
  key: String;
  value: String;
begin
  Manifest := TStringList.Create;
  Manifest.LoadFromFile(ExpandConstant('{tmp}\krcimanifest.ini'));
  (* TODO *)
end;

function ParseManifestLocations(): Boolean;
var
  res: Boolean;
  Manifest TStringList;
  i: Integer;
  key: String;
  value: String:
begin
  Manifest := TStringList.Create;
  Manifest.LoadFromFile(ExpandConstant('{tmp}\krcimanifest.ini'));
  (* TODO *)
end;

(* TODO: Awesome function documentation *)
function ParseManifest(): Boolean;
var
  res: Boolean;
begin
  res := True;
  
  if res then begin
    res := ParseManifestOptions();
  end;

  if res then begin
    res := ParseManifestLocations()

  for i := 1 to 4 do begin
    SplitManifestKeyValuePair(Manifest[i], key, value);
    MsgBox(Manifest[i], mbInformation, MB_OK);
    MsgBox(key, mbInformation, MB_OK);
    MsgBox(value, mbInformation, MB_OK);
  end;
end;

(* TODO: Awesome function documentation *)
function InitializeSetup(): Boolean;
var
  res: Boolean;
  Manifest: TStringList;
  i: Integer;
begin
  MsgBox('About to download manifest', mbInformation, MB_OK);

  res := RetrieveManifest();

  if res then begin
    ParseManifest();
  end;

  if not res then begin
    MsgBox('The installer could not initialize', mbError, MB_OK);
  end;
  Result := res;
end;