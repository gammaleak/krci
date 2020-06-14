; -- krci.iss --
; Installs all client software needed to play FFXI on the Kujata Reborn server
; Within the [Code] section, type and function comments are done in python
; docstring style.

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
#define ManifestLocalFilename "{tmp}\krcimanifest.ini"
#define ManifestKeyValueSeparator "="

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
; Including some files for now that will go away eventually. This is just a
; placeholder in case I do have some important files to include later.
Source: "MyProg.exe"; DestDir: "{app}"
Source: "MyProg.chm"; DestDir: "{app}";
Source: "krcimanifest.ini"; DestDir: "{app}"
Source: "Readme.txt"; DestDir: "{app}"; Flags: isreadme

[Icons]
Name: "{group}\My Program"; Filename: "{app}\MyProg.exe"

[Code]
type
  MItem = record
    (* The MItem type holds a key-value pair found in the installer manifest
    file. A single key can have multiple values assigned to it.

    Key: The key/name of the option or location listing in the manifest file.
    Value: The value(s) assigned to the key.
    *)
    
    Key: String;
    Value: array of String;
  end;


var
  MVerControl: MItem;         (* The version control data from the manifest *)
  MOptions: array of MItem;   (* The data from the manifest's Option section *)
  MLocations: array of MItem; (* Locations of the various downloadable data *)

function RetrieveManifest(): Boolean;
(* Locates the manifest file. Usually it is downloaded from a well-known URL.
This behavior can be overridden by providing a manifest file in the same
directory as the setup file.

Parameters:
(none)

Returns
Boolean: True if successful acquiring the manivest, False if unsuccessful.
         Note that there is no data validation on the manifest file.
*)
var
  res: Boolean;
begin
  (* TODO: Check for local manifest first *)
  res := idpDownloadFile('{#ManifestURL}', ExpandConstant('{#ManifestLocalFilename}'));

  if not res then begin
    MsgBox('Failed to download the manifest file.', mbError, MB_OK);
  end;

  Result := res 
end;

function SplitManifestKeyValuePair(const Line: String; var Key: String; var Value: String): Boolean;
(* Takes a line from the manifest file and splites the key-value pair into
separate variables.

Parameters:
Line (String):  A line from the manifest file that contains a key-value pair
                (and nothing more).
Key (String):   Used to pass back the key from the key-value pair.
Value (String): Used to pass back the value from the key-value pair.

Returns:
Boolean: True if successful in splitting the key-value pair. False if
         unsuccessful.
*) 
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

function ParseManifestOptions(): Boolean;
(* Parses through the Options section of the manifest file and stores the data
in the MVerControl and MOptions global variables.

Parameters:
(none)

Returns:
Boolean: True if parsing the Options section is successful. False if it is not.
*)
var
  res: Boolean;
  Manifest: TStringList;
  i: Integer;
  key: String;
  value: String;
begin
  Manifest := TStringList.Create;
  Manifest.LoadFromFile(ExpandConstant('{#ManifestLocalFilename}'));
  (* TODO: Take proof-of-concept parsing currently in  ParseManifest and make
  it specific to parsing the Options section. *)
end;

function ParseManifestLocations(): Boolean;
(* Parses through the different Locations sections of the manifest file and
stores the data in the MLocations global variable

Parameters:
(none)

Returns:
Boolean: True if parsing the Locations sections is successful. False if it is
         not.

*)
var
  res: Boolean;
  Manifest: TStringList;
  i: Integer;
  key: String;
  value: String;
begin
  Manifest := TStringList.Create;
  Manifest.LoadFromFile(ExpandConstant('{#ManifestLocalFilename}'));
  (* TODO: Take proof-of-concept parsing currently in ParseManifest and make
  it specific to parsing the Locations sections. *)
end;

(* TODO: Awesome function documentation *)
function ParseManifest(): Boolean;
(* Parent function for parsing the entire manifest. Delegates most of the
actual work to ParseManifestOptions() and ParseManifestLocations().

Parameters:
(none)

Returns:
Boolean: True if parsing of the entire manifest is successful. False if it is
         not.
*)
var
  res: Boolean;
  i: Integer;
begin
  res := True;
  
  if res then begin
    res := ParseManifestOptions();
  end;

  if res then begin
    res := ParseManifestLocations()
  end;

  (* TODO: Take this proof-of-concept code and split it out into handling the
  the Options section and individual Locations sections separately
  for i := 1 to 4 do begin
    SplitManifestKeyValuePair(Manifest[i], key, value);
    MsgBox(Manifest[i], mbInformation, MB_OK);
    MsgBox(key, mbInformation, MB_OK);
    MsgBox(value, mbInformation, MB_OK);
  end;
  *)
end;

function InitializeSetup(): Boolean;
(* Locates the manifest file and parses it before the setup GUI is displayed.
See the Inno Setup documentation for futher details on this special event in
the Inno Setup system.

Parameters: 
(none)

Returns:
Boolean: True if initialization was succesful. False if not. If False is
         returned, the entire setup will be canceled.
*)
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