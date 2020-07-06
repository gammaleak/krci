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
#define ManifestOptionExtension = "Extension"
#define ManifestOptionAction = "Action"

#define StrNewLine = "#13#10"

#define WizTextIntroCaption = "Kujata Reborn Installation Overview"
#define WizTextIntroDescription = "Here is a quick overview of the installation:"
#define WizTextIntroMsgDownload = "You are about to install all the necessary files to play on the Final Fantasy XI private server, Kujata Reborn (kujatareborn.com). This installer will download the required installation files from the internet and install them on your machine. Please remain connected to the internet throughout the installation process (a wired connection would be advisable)."
#define WizTextIntroMsgRequired = "The following items are required to play on Kujata Reborn and will be downloaded and installed:"
#define WizTextIntroMsgOptions = "The next screen(s) will allow you to choose some elements of your installation."
#define WizTextIntroMsgHelp = "If you need assistance with this installer, please join our Discord (https://discord.com/invite/uBWtbz) and go ask for help in the ?helpdesk room."

#define WizTextCleanOptionCaption = "Remove Previous FFXI Installation"
#define WizTextCleanOptionDescription = "This installer will not complete successfully if you have an existing installation of Final Fantasy XI and the PlayOnline Viewer. They must be uninstalled first or this installer will fail."
#define WizTextCleanOptionSubcaption = "Do you want the Kujata Reborn Client Installer to uninstall any previous Final Fantasy XI and PlayOnline Viewer installations?"                                                                                                                                                                                 
#define WizTextCleanOptionYes = "Yes"
#define WizTextCleanOptionNo = "No"

#define WizTextCleanNotifyCaption = "Removal of Previous Installation"
#define WizTextCleanNotifyDescription = ""
#define WizTextCleanNotifyMessage = "The Kujata Reborn Client Installer will now remove any existing PlayOnline Viewer and Final Fantasy XI installations."

#define CleanUninstallCommandPOLV = "msiexec /passive /x {81784E3A-1BDA-4743-B5F8-04E59DC7E031}"
#define CleanUninstallCommandFFXI = "msiexec /passive /x {07EB4C8B-3869-49B4-8CF8-D6D9FB8C8026}"

#define WizTextActionProgressCaption = "Installing Kujata Reborn Client Software"
#define WizTextActionProgressDescription = "The installer is now working to install all necessary and chosen components of your client installation."

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
    Extension: String;
    Locations: array of MItem;
    WizardPage: TInputOptionWizardPage;
    WizardListIndex: Integer;
    InstallActions: array of String;
  end;

(* Global variables *)
var
  ManifestLocation: String;   (* Manifest file actually used for setup *)
  ManVerControl: MItem;       (* Version control data from the manifest *)
  Options: array of MOption;  (* Parsed data from the manifest *)
  IntroPage: TOutputMsgWizardPage; (* Informs user about install process *)
  CleanOptionPage: TInputOptionWizardPage; (* Option to uninstall prev FFXI *)
  CleanNotificationPage: TOutputMsgWizardPage; (* Notifies user of removal *)
  ActionProgressPage: TOutputProgressWizardPage; (* Progress thru actions *)


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

function RetrieveFileExtension(const str: String; var ext: String): Boolean;
(* Finds the extension of a file and writes it back to the ext parameter

Parameters:
str: A filename or URL
ext: Passed to receive back the found extension

Returns:
Boolean: True if an extension is found. False if there's no extension.
*) 
var
  res: Boolean;
  dotLoc: Integer;
begin
  res := True;
  dotLoc := Length(str) - 3;
  if str[dotLoc] = '.' then begin
    ext := Copy(str, dotLoc+1, 3);
  end else begin
    res := False;
  end;

  Result := res;  
end;

function ShortFilenameFromURL(const url: String; var filename: String): Boolean;
(* Finds the short filename (i.e., without the fully qualified directory) from
a given URL

Parameters
url: The URL from which to get the filename.
filename: Passed to receive back the found filename.

Returns:
Boolean: True if a filename is found. False if no filename is found
*)
var
  res: Boolean;
  i: Integer;
  lastSlashPos: Integer;
begin
  res := True;
  lastSlashPos := -1;

  for i := 1 to Length(url) do begin
    if url[i] = '/' then begin
      lastSlashPos := i;
    end;
  end;

  if lastSlashPos < 0 then begin
    res := False;
  end else begin
    filename := Copy(url, lastSlashPos + 1, Length(url) - lastSlashPos);
  end;

  Result := res;
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

function ParseManifestDetails(): Boolean;
(* Parses through the different option details sections of the manifest file
and stores the data in the MLocations global variable

Parameters:
(none)

Returns:
Boolean: True if parsing the details sections is successful. False if it is
         not.

*)
var
  res: Boolean;
  done: Boolean;
  Manifest: TStringList;
  locSectionLine: Integer;
  key: String;
  value: String;
  locationsFound: Integer;
  actionsFound: Integer;
  i: Integer;
  j: Integer;
  header: String;
begin
  Log('ParseManifestDetails(): Beginning function.');
  res := True;
  Manifest := TStringList.Create;
  Manifest.LoadFromFile(ManifestLocation);

  for i := 0 to Manifest.Count - 1 do
    Log('ParseManifestDetails(): Manifest line ' + IntToStr(i) + ' is ' + Manifest[i]);

  for i := 0 to GetArrayLength(Options) - 1 do begin
    header := '[' + Options[i].Option.Key + ']';
    Log('ParseManifestDetails(): Trying to find ' + header + ' in the manifest file.');

    if FindInTStringList(Manifest, header, locSectionLine) then begin
      Log('ParseManifestDetails(): Found ' + header + ' in the manifest file.');
      done := False;
      j := locSectionLine;
      locationsFound := 0;
      actionsFound := 0;
      SetArrayLength(Options[i].Locations, Manifest.Count);
      SetArrayLength(Options[i].InstallActions, Manifest.Count);
      while not (done) and (j < Manifest.Count - 1) do begin
        j := j + 1;
        if not SplitManifestKeyValuePair(Manifest[j], key, value) then begin
          done := True;
        end else begin
          case key of
            '{#ManifestOptionRequired}' : begin
              if value = '{#ManifestBooleanTrue}' then begin
                Options[i].Required := True;
                Log('ParseManifestDetails(): Storing Options[' + IntToStr(i) + '].Required = True.');
              end else begin
                Options[i].Required := False;
                Log('ParseManifestDetails(): Storing Options[' + IntToStr(i) + '].Required = False.');
              end;
            end;
            '{#ManifestOptionExclusive}' : begin
              if value = '{#ManifestBooleanTrue}' then begin
                Options[i].Exclusive := True;
                Log('ParseManifestDetails(): Storing Options[' + IntToStr(i) + '].Exclusive = True.');
              end else begin
                Options[i].Exclusive := False;
                Log('ParseManifestDetails(): Storing Options[' + IntToStr(i) + '].Exclusive = False.');
              end;
            end;
            '{#ManifestOptionExtension}' : begin
              Log('ParseManifestDetails(): Intended extension for this URL Location = ' + value + '.');
              Options[i].Extension := value;
            end;
            '{#ManifestOptionAction}' : begin
              Log('ParseManifestDetails(): Storing Options[' + IntToStr(i) + '].InstallActions[' + IntToStr(actionsFound) + '] = ' + value);
              Options[i].InstallActions[actionsFound] := value;
              actionsFound := actionsFound + 1;
            end;
            else begin
              if key = Options[i].Option.Value then begin
                Options[i].Locations[locationsFound].Key := key;
                Options[i].Locations[locationsFound].Value := value;
                Log('ParseManifestDetails(): Storing Options[' + IntToStr(i) + '].Locations[' + IntToStr(locationsFound) + '].Key = ' + key + ' | Options[' + IntToStr(i) + '].Locations[' + IntToStr(locationsFound) + '].Value = ' + value + '.');
                locationsFound := locationsFound + 1;
              end;
            end;
          end;
        end;
      end;

      Log('ParseManifestDetails(): Setting Options[' + IntToStr(i) + '].Locations array length to ' + IntToStr(locationsFound) + '.');
      SetArrayLength(Options[i].Locations, locationsFound);
      Log('ParseManifestDetails(): Settings Options[' + IntToStr(i) + '].InstallActions array length to ' + IntToStr(actionsFound) + '.');
      SetArrayLength(Options[i].InstallActions, actionsFound);

    end else
      Log('ParseManifestDetails(): Did not find ' + header + ' in the manifest file.');
  end;

  Log('ParseManifestDetails(): Exiting function Result == ' + BoolToStr(res) + '.');
  Result := res;
end;

function ParseManifest(): Boolean;
(* Parent function for parsing the entire manifest. Delegates most of the
actual work to ParseManifestOptions() and ParseManifestDetails().

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
    res := ParseManifestDetails()
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

function InitializeOptionsPages(var lastOptionsPageId: Integer): Boolean;
(* Initializes the intro and options pages shown at the beginning of the
installation process.

Parameters:
lastOptionsPageId: Integer ID for the last options page created. This
                   makes it so that future custom pages can be inserted
                   after this one. Returns the value back to the calling
                   function.

Returns:
Boolean: True if initializing the pages was successful. False if not.
*)
var
  res: Boolean;
  introMsg: String; 
  prevPage: Integer;
  trueOption: Boolean;
  i: Integer;
  j: Integer;
begin
  res := True;
  prevPage := wpWelcome;

  introMsg := '{#WizTextIntroMsgDownload}' + {#StrNewLine} + {#StrNewLine} + '{#WizTextIntroMsgRequired}'


  (* Make all options set to unselected. *)
  for i := 0 to GetArrayLength(Options) - 1 do begin
    Options[i].Selected := False;
    Options[i].WizardListIndex := -1;
  end;

  (* Now look for true options with more than one choice. If there is no actual
  choice because it's a required option and there's only one version, then set
  it to Selected := True right away and skip making an option page for it.*)
  for i := 0 to GetArrayLength(Options) - 1 do begin
    for j := (i + 1) to GetArrayLength(Options) - 1 do begin
      if Options[i].Option.Key = Options[j].Option.Key then begin
        trueOption := True;
        if not Assigned(Options[i].WizardPage) then begin
          Options[i].WizardPage := CreateInputOptionPage(prevPage, Options[i].Option.Key, 'Choose a ' + Options[i].Option.Key + ' to download and install.', '', Options[i].Exclusive, False);
          prevPage := Options[i].WizardPage.ID;
          Options[i].WizardListIndex := Options[i].WizardPage.Add(Options[i].Option.Value);
          Options[i].WizardPage.Values[Options[i].WizardListIndex] := True;
        end;
        if Options[i].WizardListIndex < 0 then begin
          Options[i].WizardListIndex := Options[i].WizardPage.Add(Options[i].Option.Value);
        end;
        if not Assigned(Options[j].WizardPage) then begin
          Options[j].WizardPage := Options[i].WizardPage;
        end;
        if Options[j].WizardListIndex < 0 then begin
          Options[j].WizardListIndex := Options[j].WizardPage.Add(Options[j].Option.Value);
        end;
      end;
    end;

    if not trueOption and Options[i].Required then begin
      Options[i].Selected := True;
      introMsg := introMsg + {#StrNewLine} + '- ' + Options[i].Option.Key;
    end else begin
      (* There isn't more than one choice, but it isn't a requirement, so the
      user still gets the opportunity to check the box or not check the box. *)
      if not Assigned(Options[i].WizardPage) then begin
        Options[i].WizardPage :=  CreateInputOptionPage(prevPage, Options[i].Option.Key, 'Choose whether to download and install the ' + Options[i].Option.Key + '.', '', Options[i].Exclusive, False);
        Options[i].WizardListIndex := Options[i].WizardPage.Add(Options[i].Option.Value);
        prevPage := Options[i].WizardPage.ID;
      end;
    end;
  end;

  introMsg := introMsg + {#StrNewLine} + {#StrNewLine} + '{#WizTextIntroMsgOptions}' + {#StrNewLine} + {#StrNewLine} + '{#WizTextIntroMsgHelp}'

  IntroPage := CreateOutputMsgPage(wpWelcome, '{#WizTextIntroCaption}', '', introMsg);

  (* It's not clear that there actually is a failure condition other than any
  uncaught exception, which will error out of the installer anyway. *)
  Result := res;
end;

function InitializeCleanOptionPage(): Boolean;
(* Initializes a wizard page that gives the user the option to uninstall any
previous Final Fantasy XI installation

Parameters:
(none)

Returns:
Boolean True if initialization was successful. False if not.
*)
var
  res: Boolean;
begin
  res := True;

  CleanOptionPage := CreateInputOptionPage(IntroPage.ID, '{#WizTextCleanOptionCaption}', '{#WizTextCleanOptionDescription}', '{#WizTextCleanOptionSubcaption}', True, False);
  CleanOptionPage.Add('{#WizTextCleanOptionYes}');
  CleanOptionPage.Add('{#WizTextCleanOptionNo}');
  CleanOptionPage.SelectedValueIndex := 0;

  Result := res;
end;

function InitializeCleanNotificationPage(): Boolean;
(* Initializes a wizard page that notifies the user that existing PlayOnline
Viewer and Final Fantasy XI installations are about to be removed.

Parameters:
(none)

Returns:
Boolean True if initialization was successful. False if not.
*)
var
  res: Boolean;
begin
  res := True;

  if CleanOptionPage.SelectedValueIndex = 0 then begin
    CleanNotificationPage := CreateOutputMsgPage(wpSelectDir, '{#WizTextCleanNotifyCaption}', '', '{#WizTextCleanNotifyMessage}');
  end;

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
  lastOptionsPageId: Integer;
begin

  res := InitializeOptionsPages(lastOptionsPageId);

  if res then begin
    res := InitializeCleanOptionPage();
  end;

  if res then begin
    res := InitializeCleanNotificationPage();
  end;

  if res then begin
    ActionProgressPage := CreateOutputProgressPage('{#WizTextActionProgressCaption}', '{#WizTextActionProgressDescription}');
  end;

end;

function IsInstallDataPresent() : Boolean;
(* Looks for the install data defined in the manifest file to see if it's
already downloaded or if it's in the working directory.

Parameters:
(none)

Returns:
Boolean: True if the data is already present. False if not
*)
begin
  (* TODO: Actually code out this function so that it does as described. *)
  Result := False;
end;

function PrepareToDownloadInstallData(const afterPageId: Integer): Boolean;
(* Downloads the selected installation data. This function also handles all
the wizard progress screen updates, so it should not be called arbitrarily.
Call this function only from an appropriate point to process this data. Also,
note that if any of the file locations do not end with the actual filename,
(e.g., Google Drive links) and have more than one location (e.g., a multi-part
archive), this function is likely to fail spectacularly to reproduce the files
in a way that will work. So don't do that.

Parameters:
afterPageId: The ID of the wizard page after which the downloading should take
             place.

Returns:
Boolean: Returns True if the download was successful. False if it was not.
*)
var
  res: Boolean;
  filename: String;
  fileExtension: String;
  i: Integer;
  j: Integer;
begin
  res := True;

  for i := 0 to GetArrayLength(Options) - 1 do begin
    Log('PrepareToDownloadInstallData(): Options[' + IntToStr(i) + '].Selected == ' + BoolToStr(Options[i].Selected) + '.');
    if Options[i].Selected then begin
      for j := 0 to GetArrayLength(Options[i].Locations) - 1 do begin
        Log('PrepareToDownloadInstallData(): Options[' + IntToStr(i) + '].Option.Key == ' + Options[i].Option.Key + '.');
        Log('PrepareToDownloadInstallData(): Options[' + IntToStr(i) + '].Option.Value == ' + Options[i].Option.Value + '.');
        Log('PrepareToDownloadInstallData(): Options[' + IntToStr(i) + '].Locations[' + IntToStr(j) + '].Key == ' + Options[i].Locations[j].Key + '.');
        Log('PrepareToDownloadInstallData(): Options[' + IntToStr(i) + '].Locations[' + IntToStr(j) + '].Value == ' + Options[i].Locations[j].Value + '.');
        Log('PrepareToDownloadInstallData(): Looking for short filename in ' + Options[i].Locations[j].Value + '.');
        if ShortFilenameFromURL(Options[i].Locations[j].Value, filename) then begin
          Log('PrepareToDownloadInstallData(): Downloading ' + filename + ' from ' + Options[i].Locations[j].Value + '.');

          if not RetrieveFileExtension(filename, fileExtension) then begin
            filename := Options[i].Locations[j].Key + '.' + Options[i].Extension;
            Log('PrepareToDownloadInstallDate(): Modifying filename to ' + filename + '.');
          end;

          idpAddFile(Options[i].Locations[j].Value, ExpandConstant('{tmp}\' + filename));
        end;
      end;
    end;
  end;
  
  idpDownloadAfter(afterPageId);

  Result := res;
end;

function ProcessActions(): Boolean;
(* Processes all the actions for options in that manifest file that were
selected.

Parameters:
(none)

Returns:
Boolean: True if all actions were processed successfully. False if not.
*)
var
  res: Boolean;
  numOptions: Integer;
  numActions: Integer;
  i: Integer;
  j: Integer;
  execResult: Integer;
begin
  res := True;
  numOptions := GetArrayLength(Options);
  ActionProgressPage.Show;
  try begin
    for i := 0 to numOptions - 1 do begin
      if Options[i].Selected then begin
        numActions := GetArrayLength(Options[i].InstallActions) - 1
        for j := 0 to numActions do begin
          Log('ProcessActions(): Working on Option ' + IntToStr(i) + ' of ' + IntToStr(numOptions) + ' and Action ' + IntToStr(j) + ' of ' + IntToStr(numActions) + '.');
          ActionProgressPage.SetText('Processing actions to install ' + Options[i].Option.Key, 'Action: ' + ExpandConstant(Options[i].InstallActions[j]));
          ActionProgressPage.SetProgress(j, numActions);
          Log('ProcessActions(): Executing ' + Options[i].Option.Key + ' Action: ' + ExpandConstant(Options[i].InstallActions[j]));
          res := Exec('>', ExpandConstant(Options[i].InstallActions[j]), ExpandConstant('{tmp}'), SW_SHOW, ewWaitUntilTerminated, execResult);
          if not res then begin
            MsgBox('ProcessActions():' + {#StrNewLine} + {#StrNewLine} + 'Action: ' + ExpandConstant(Options[i].InstallActions[j]) + {#StrNewLine} + {#StrNewLine} + 'execResult: ' + IntToStr(execResult), mbInformation, MB_OK);
          end;
        end;
      end;
    end;
  end finally
    ActionProgressPage.Hide;
  end;

  Result := res;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
(* Handles what to do based on which page the user just clicked "next" on.

Parameters:
CurPageID: The ID of the current page (i.e., the one that was showing when the
           user clicked "Next").

Returns:
Boolean: Returning True will cause the wizard to move to the next page.
         Returning False will cause the wizard to stay on the page it's on.
*)
var
  res: Boolean;
  i: Integer;
  execResult: Integer;
begin
  case CurPageID of
    wpSelectDir : begin
      if CleanOptionPage.SelectedValueIndex = 1 then begin
        if not IsInstallDataPresent() then begin
          PrepareToDownloadInstallData(wpSelectDir);
        end;
      end;
      res := True; 
    end;
    CleanNotificationPage.ID : begin
      Exec('>', '{#CleanUninstallCommandPOLV}', ExpandConstant('{tmp}'), SW_SHOW, ewWaitUntilTerminated, execResult);
      Exec('>', '{#CleanUninstallCommandFFXI}', ExpandConstant('{tmp}'), SW_SHOW, ewWaitUntilTerminated, execResult);
      if not IsInstallDataPresent() then begin
        PrepareToDownloadInstallData(CleanNotificationPage.ID);
      end;
      res := True;
    end;
    wpReady : begin
      res := ProcessActions();
    end;    
    else begin
      for i := 0 to GetArrayLength(Options) - 1 do begin
        if Assigned(Options[i].WizardPage) then begin
          if CurPageID = Options[i].WizardPage.ID then begin
            if Options[i].WizardPage.Values[Options[i].WizardListIndex] = True then begin
              Log('NextButtonClick(): Options[' + IntToStr(i) + '].WizardPage.Values[Options[' + IntToStr(i) + '].WizardListIndex] was found to be True. Therefore ' + Options[i].Option.Value + ' is Selected.');
              Options[i].Selected := True;
            end;
          end;
        end;
      end;
      res := True;
    end;
  end;

  Result := res;
end;