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
#define ManifestLocalFilename "{src}\krcimanifest.ini"
#define ManifestTempFilename "{tmp}\krcimanifest.ini"
#define ManifestOptionsHeader "[Options]"
#define ManifestVerControlOption = "MinVer"
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

SetupLogging=yes


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
(* Type declarations *)
type
  MItem = record
    (* The MItem type holds a key-value pair found in the installer manifest
    file. A single key can have multiple values assigned to it.

    Key: The key/name of the option or location listing in the manifest file.
    Value: The value(s) assigned to the key.
    *)
    
    Key: String;
    Value: String;
  end;

type
  MOption = record
    (* The MLocation type associates a given manifest option with one or more
    download locations for that option

    Option: The option for finding installation data at one or more locations
    Locations: The locations where installation data are found
    *) 

    Option: MItem;
    Locations: array of MItem;
  end;

(* Global variables *)
var
  ManifestLocation: String;   (* Manifest file actually used for setup *)
  ManVerControl: MItem;       (* Version control data from the manifest *)
  Options: array of MOption; (* Parsed data from the manifest *)


(* Functions and Procedures *)
function BoolToStr(const bool: Boolean): String;
begin
  if bool then begin
    Result := 'True';
  end else
    Result := 'False';
end;

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
  local: Boolean;
begin
  Log('RetrieveManifest(): Beginning function.');
  res := True;
  local := False;
  
  if FileExists(ExpandConstant('{#ManifestLocalFilename}')) then begin
    Log('RetrieveManifest(): Local manifest found.');
    local := True;
    ManifestLocation := ExpandConstant('{#ManifestLocalFilename}');
  end else
    Log('RetrieveManifest(): No local manifest found.');

  if not local then begin
    Log('RetrieveManifest(): Attempting to download remote manifest file.');
    res := idpDownloadFile('{#ManifestURL}', ExpandConstant('{#ManifestTempFilename}'));
        
    if res then begin
      Log('RetrieveManifest(): Remote manifest downloaded successfully.');
      ManifestLocation := ExpandConstant('{#ManifestTempFilename}');
    end else
      Log('RetrieveManifest(): Failed to download the manifest file.');
  end;

  Log('RetrieveManifest(): Exiting function. Result == ' + BoolToStr(res) + '.');
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
  Log('SplitManifestKeyValuePair(): Beginning function.');
  res := True;

  Log('SplitManifestKeyValuePair(): Locating the manifest key-value separator: {#ManifestKeyValueSeparator}.');
  p := Pos('{#ManifestKeyValueSeparator}', Line);
  if p <= 0 then begin
    Log('SplitManifestKeyValuePair(): Could not locate the manifest key-value separator: {#ManifestKeyValueSeparator}.');
    res := False;
  end;

  if res then begin
    Log('SplitManifestKeyValuePair(): Splitting key-value pair of line: ' + Line);
    Key := Line;
    Delete(Key, p, Length(Key)-(p-1));
    Key := Trim(Key);

    Value := Line;
    Delete(Value, 1, p);
    Value := Trim(Value);
  end;

  Log('SplitManifestKeyValuePair(): Exiting function. Result == ' + BoolToStr(res) + '.');
  Result := res;
end;

function ParseManifestOptions(): Boolean;
(* Parses through the Options section of the manifest file and stores the data.

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
  count: Integer;
  done: Boolean;
begin
  Log('ParseManifestOptions(): Beginning function.');
  res := True;
  done := False;
  count := 0;
  Manifest := TStringList.Create;
  Manifest.LoadFromFile(ManifestLocation);
  (* TODO: Take proof-of-concept parsing currently in  ParseManifest and make
  it specific to parsing the Options section. *)
  res := Manifest.Find('{#ManifestOptionsHeader}', i);

  if res then begin
    Log('ParseManifestOptions(): [Options] header found.');
    
    SetArrayLength(Options, Manifest.Count);
    
    while not done do begin
      i := i + 1;
      if not SplitManifestKeyValuePair(Manifest[i], key, value) then begin
        done := True;
      end else begin
        if key = '{#ManifestVerControlOption}' then begin
          ManVerControl.Key := key;
          ManVerControl.Value := value;
        end else begin
          Options[count].Option.Key := key;
          Options[count].Option.Value := value;
          Log('ParseManifestOptions(): Storing option ' + Options[count].Option.Key + ' with value ' + Options[count].Option.Value + ' in Options[' + IntToStr(count) + '].Option');
          count := count + 1;
         end;
      end;
    end;
  end;
  
  SetArrayLength(Options, count);

  Log('ParseManifestOptions(): Exiting function. Result == ' + BoolToStr(res) + '.');
  Result := res;
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
  done: Boolean;
  Manifest: TStringList;
  locSectionLine: Integer;
  key: String;
  value: String;
  count: Integer;
  i: Integer;
  j: Integer;
  k: Integer;
  header: String;
  foundHeader: Boolean;
begin
  Log('ParseManifestLocations(): Beginning function.');
  res := True;
  Manifest := TStringList.Create;
  Manifest.LoadFromFile(ManifestLocation);

  for i := 0 to Manifest.Count - 1 do
    Log('ParseManifestLocations(): Manifest line ' + IntToStr(i) + ' is ' + Manifest[i]);

  for i := 0 to GetArrayLength(Options) - 1 do begin
    header := '[' + Options[i].Option.Key + ']';
    Log('ParseManifestLocations(): Trying to find ' + header + ' in the manifest file.');

    (* The whole next block of code is absolutely stupid. In
    ParseManifestOptions() above I use TStringList.Find() and it works just
    fine. For some reason, it won't work when trying to search for the 'header'
    variable assigned above. Makes zero sense. So, I brute force it below
    instead. Totally lame, but whatcha gonna do? *)
    foundHeader := False;
    k := 0;
    while (not foundHeader) and (k < Manifest.Count) do begin
      Log('ParseManifestLocations(): Checking Manifest line ' + IntToStr(k) + ', ' + Manifest[k] + ' against ' + header + '.');
      if Manifest[k] = header then begin
        locSectionLine := k;
        foundHeader := True
      end;
      k := k + 1;
    end;

    if foundHeader then begin
      Log('ParseManifestLocations(): Found ' + header + ' in the manifest file.');
      done := False;
      j := locSectionLine;
      count := 0;
      SetArrayLength(Options[i].Locations, Manifest.Count);
      while not (done) and (j < Manifest.Count - 1) do begin
        j := j + 1;
        if not SplitManifestKeyValuePair(Manifest[j], key, value) then begin
          done := True;
          SetArrayLength(Options[i].Locations, count);
        end else begin
          Options[i].Locations[count].Key := key;
          Options[i].Locations[count].Value := value;
          Log('ParseManifestLocations(): Storing Options[' + IntToStr(i) + '].Locations[' + IntToStr(count) + '].Key = ' + key + ' | Options[' + IntToStr(i) + '].Locations[' + IntToStr(count) + '].Value = ' + value + '.');
          count := count + 1;
        end;
      end;
    end else
      Log('ParseManifestLocations(): Did not find ' + header + ' in the manifest file.');
  end;

  Log('ParseManifestLocations(): Exiting function Result == ' + BoolToStr(res) + '.');
  Result := res;
end;

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
begin
  Log('ParseManifest(): Beginning function.');
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
  Log('ParseManifest(): Exiting function. Result == ' + BoolToStr(res) + '.');
  Result := res;
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
begin
  Log('InitializeSetup(): Beginning function.');

  res := RetrieveManifest();

  if res then begin
    ParseManifest();
  end;

  if not res then begin
    Log('InitializeSetup(): res == FALSE, setup will not continue.');
  end;

  Log('InitializeSetup(): Exiting function. Result == ' + BoolToStr(res) + '.');
  Result := res;
end;