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
#define ManifestKeyValueSeparator "="
#define ManifestBooleanTrue = "Yes"
#define ManifestOptionVerControl = "MinVer"
#define ManifestOptionRequired = "Required"
#define ManifestOptionExclusive = "Exclusive"

#define StrNewLine = "#13#10"

#define WizTextIntroCaption = "Kujata Reborn Installation Overview"
#define WizTextIntroDescription = "Here is a quick overview of the installation:"
#define WizTextIntroMsgDownload = "You are about to install all the necessary files to play on the Final Fantasy XI private server, Kujata Reborn (kujatareborn.com). This installer will download the required installation files from the internet and install them on your machine. Please remain connected to the internet throughout the installation process."
#define WizTextIntroMsgRequired = "The following items are required to play on Kujata Reborn and will be downloaded and installed:"
#define WizTextIntroMsgOptions = "The next screen(s) will allow you to choose some elements of your installation."
#define WizTextIntroMsgHelp = "If you need assistance with this installer, please join our Discord (https://discord.com/invite/uBWtbz) and go ask for help in the ?helpdesk room."

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
    Required: Boolean;
    Exclusive: Boolean;
    Selected: Boolean;
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

function FindInTStringList(const tstrl: TStringList; const str: String; var line: Integer): Boolean;
(* Finds a string within a TStringList. The string must be an exact match. The
TStringList.Find function is supposed to do this, but fails for inexplicable
reasons and can't be depended on. Therefore, this is my own brute-force
version of the same.

Parameters:
tstrl: The TStringList to scan
str: The string to scan for
line: Returns the line number if the string is found.

Returns
Boolean: True if successful finding the string, False if unsuccessful.
*)
var
  foundStr: Boolean;
  k: Integer;
begin
  foundStr := False;
  k := 0;
  while (not foundStr) and (k < tstrl.Count) do begin
    Log('FindInTStringList(): Checking TStringList line ' + IntToStr(k) + ', ' + tstrl[k] + ' against ' + str + '.');
    if tstrl[k] = str then begin
      line := k;
      foundStr := True
    end;
    k := k + 1;
  end;
  
  Result := foundStr;  
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

  (* res := Manifest.Find('{#ManifestOptionsHeader}', i); *)
  res := FindInTStringList(Manifest, '{#ManifestOptionsHeader}', i);

  if res then begin
    Log('ParseManifestOptions(): [Options] header found.');
    
    SetArrayLength(Options, Manifest.Count);
    
    while not done do begin
      i := i + 1;
      if not SplitManifestKeyValuePair(Manifest[i], key, value) then begin
        done := True;
      end else begin
        if key = '{#ManifestOptionVerControl}' then begin
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
  header: String;
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

    if FindInTStringList(Manifest, header, locSectionLine) then begin
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
          case key of
            '{#ManifestOptionRequired}' : begin
              if value = '{#ManifestBooleanTrue}' then begin
                Options[i].Required := True;
                Log('ParseManifestLocations(): Storing Options[' + IntToStr(i) + '].Required = True');
              end else begin
                Options[i].Required := False;
                Log('ParseManifestLocations(): Storing Options[' + IntToStr(i) + '].Required = False');
              end;
            end;
            '{#ManifestOptionExclusive}' : begin
              if value = '{#ManifestBooleanTrue}' then begin
                Options[i].Exclusive := True;
                Log('ParseManifestLocations(): Storing Options[' + IntToStr(i) + '].Exclusive = True');
              end else begin
                Options[i].Exclusive := False;
                Log('ParseManifestLocations(): Storing Options[' + IntToStr(i) + '].Exclusive = False');
              end;
            end;
            else begin
              Options[i].Locations[count].Key := key;
              Options[i].Locations[count].Value := value;
              Log('ParseManifestLocations(): Storing Options[' + IntToStr(i) + '].Locations[' + IntToStr(count) + '].Key = ' + key + ' | Options[' + IntToStr(i) + '].Locations[' + IntToStr(count) + '].Value = ' + value + '.');
              count := count + 1;
            end;
          end;
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

  Log('ParseManifest(): Exiting function. Result == ' + BoolToStr(res) + '.');
  Result := res;
end;

function InitializeSetup(): Boolean;
(* Locates the manifest file and parses it before the setup GUI is displayed.
Also initializes the custom GUI pages. See the Inno Setup documentation for
futher details on this special event in the Inno Setup system.

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
    res := ParseManifest();
  end;

  if not res then begin
    Log('InitializeSetup(): res == FALSE, setup will not continue.');
  end;

  Log('InitializeSetup(): Exiting function. Result == ' + BoolToStr(res) + '.');
  Result := res;
end;

procedure InitializeWizard;
(* Initializes the custom GUI pages for the installer.

Parameters: 
(none)

Returns:
Boolean: True if initialization was succesful. False if not.
*)
var
  res: Boolean;
  introPage: TOutputMsgWizardPage;
  introMsg: String;
  optionsPages: array of TInputOptionWizardPage;
  prevPage: Integer;
  matchingPage: Integer;
  trueOption: Boolean;
  i: Integer;
  j: Integer;
begin
  introMsg := '{#WizTextIntroMsgDownload}' + {#StrNewLine} + {#StrNewLine} + '{#WizTextIntroMsgRequired}'


  (* Make all options set to unselected. *)
  for i := 0 to GetArrayLength(Options) - 1 do begin
    Options[i].Selected := False;
  end;

  (* Now look for true options with more than one choice. If there is no actual
  choice because it's a required option and there's only one version, then set
  it to Selected := True right away and skip making an option page for it
  later. *)
  for i := 0 to GetArrayLength(Options) - 1 do begin
    for j := (i + 1) to GetArrayLength(Options) - 1 do begin
      if Options[i].Option.Key = Options[j].Option.Key then begin
        trueOption := True;
      end;
    end;

    if not trueOption and Options[i].Required then begin
      Options[i].Selected := True;
      introMsg := introMsg + {#StrNewLine} + '- ' + Options[i].Option.Key;
    end;
  end;

  prevPage := wpWelcome;

  SetArrayLength(optionsPages, GetArrayLength(Options));

  for i := 0 to GetArrayLength(Options) - 1 do begin
    matchingPage := -1;
    j := 0;

    while (matchingPage < 0) and (j < GetArrayLength(optionsPages)-1) do begin
      Log('InitializeWizard(): Looking for a matchingPage at optionsPages[' + IntToStr(j) + '].');
      if Assigned(optionsPages[j]) then begin
        Log('InitializeWizard(): Comparing optionsPages[j].Caption=' + optionsPages[j].Caption + ' with Options[i].Option.Key=' + Options[i].Option.Key + '.');
        if optionsPages[j].Caption = Options[i].Option.Key then begin
          Log('InitializeWizard(): Matching page found at Comparing optionsPages[' + IntToStr(j) + '].');
          matchingPage := j;
        end;
      end;
      j := j + 1;
    end;
    
    if matchingPage > -1 then begin
      optionsPages[matchingPage].Add(Options[i].Option.Value);
    end else begin
      if not Options[i].Selected then begin
        optionsPages[i] := CreateInputOptionPage(prevPage, Options[i].Option.Key, 'Choose a ' + Options[i].Option.Key + ' to download and install.', '', Options[i].Exclusive, False);
        optionsPages[i].Add(Options[i].Option.Value);
        optionsPages[i].Values[0] := True;
        prevPage := optionsPages[i].ID;
      end;
    end;    
  end;

  introMsg := introMsg + {#StrNewLine} + {#StrNewLine} + '{#WizTextIntroMsgOptions}' + {#StrNewLine} + {#StrNewLine} + '{#WizTextIntroMsgHelp}'

  introPage := CreateOutputMsgPage(wpWelcome, '{#WizTextIntroCaption}', '', introMsg);

end;