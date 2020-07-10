  ; -- krci.iss --
; Installs all client software needed to play FFXI on the Kujata Reborn server
; Within the [Code] section, type and function comments are done in python
; docstring style.

#pragma include __INCLUDE__ + ";" + ReadReg(HKLM, "Software\Mitrich Software\Inno Download Plugin", "InstallDir")
#pragma include __INCLUDE__ + ";" + "c:\lib\InnoDownloadPlugin"
#include <idp.iss>

#define TheAppName "Kujata Reborn Client"
#define TheAppVersion "0.8"
#define TheAppPublisher "KujataReborn.com"
#define TheAppURL "http://kujatareborn.com/wordpress/"
#define TheAppSupportURL "https://discord.com/invite/uBWtbz"
#define TheAppUpdateURL "http://kujatareborn.com/wordpress/"

#define ManifestURL "https://www.dropbox.com/s/45vsr8cjjphgfiy/krcimanifest.ini?dl=1"
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
#define ManifestOptionShortcut = "Shortcut"

#define StrNewLine = "#13#10"

#define WizTextIntroCaption = "Kujata Reborn Installation Overview"
#define WizTextIntroDescription = "Here is a quick overview of the installation:"
#define WizTextIntroMsgDownload = "You are about to install all the necessary files to play on the Final Fantasy XI private server, Kujata Reborn (kujatareborn.com). This installer will download the required installation files from the internet and install them on your machine. Please remain connected to the internet throughout the installation process (a wired connection would be advisable)."
#define WizTextIntroMsgRequired = "The following items are required to play on Kujata Reborn and will be downloaded and installed:"
#define WizTextIntroMsgOptions = "The next screen(s) will allow you to choose some elements of your installation."
#define WizTextIntroMsgFyi = "FYI:"
#define WizTextIntroMsgSize = "The minimum download size is over 7GB. Depending on which additional options you choose it can be significantly more."
#define WizTextIntroMsgHelp = "If you need assistance with this installer, please join our Discord (https://discord.com/invite/uBWtbz) and go ask for help in the ?helpdesk room."

#define WizTextCleanOptionCaption = "Remove Previous FFXI Installation"
#define WizTextCleanOptionDescription = "This installer will not complete successfully if you have an existing installation of Final Fantasy XI and the PlayOnline Viewer. They must be uninstalled first or this installer will fail."
#define WizTextCleanOptionSubcaption = "Do you want the Kujata Reborn Client Installer to uninstall any previous Final Fantasy XI and PlayOnline Viewer installations?"                                                                                                                                                                                 
#define WizTextCleanOptionYes = "Yes"
#define WizTextCleanOptionNo = "No"

#define WizTextShortcutsOptionCaption = "Kujata Reborn Shortcuts"
#define WizTextShortcutsOptionDescription = "Choose whether you want shortcuts and where you would like them to be placed."
#define WizTextShortcutsOptionSubcaption = "Do you want shortcuts in the Start Menu, Desktop, both, or neither?"
#define WizTextShortcutsOptionStartMenu = "Start Menu"
#define WizTextShortcutsOptionDesktop = "Desktop"

#define WizTextCleanNotifyCaption = "Removal of Previous Installation"
#define WizTextCleanNotifyDescription = ""
#define WizTextCleanNotifyMessage = "The Kujata Reborn Client Installer will now remove any existing PlayOnline Viewer and Final Fantasy XI installations."

#define CleanUninstallCommandPOLV = "msiexec /passive /x {81784E3A-1BDA-4743-B5F8-04E59DC7E031}"
#define CleanUninstallCommandFFXI = "msiexec /passive /x {07EB4C8B-3869-49B4-8CF8-D6D9FB8C8026}"

#define WizTextActionProgressCaption = "Installing Kujata Reborn Client Software"
#define WizTextActionProgressDescription = "The installer is now working to install all necessary and chosen components of your client installation."

#define URLDropboxQueryEnding = "?dl=1"

[Setup]
AppId = {{2B9AF53B-8A41-4135-B0E8-6B39235624A2}
AppName={#TheAppName}
AppVersion={#TheAppVersion}
AppPublisher={#TheAppPublisher}
AppPublisherURL={#TheAppURL}
AppSupportURL={#TheAppURL}
AppUpdatesURL={#TheAppUpdateURL}
WizardStyle=modern
DefaultDirName={autopf}\ffxikr
DefaultGroupName=Kujata Reborn
Compression=lzma2
SolidCompression=yes
OutputBaseFilename=krci
OutputDir=userdocs:Inno Setup Examples Output

AllowNetworkDrive=no
AllowUNCPath=no

SetupLogging=yes

WizardImageFile=krciwizardimage.bmp
WizardSmallImageFile=krciwizardsmallimage.bmp
UninstallDisplayIcon=krciwizardsmallimage.bmp

RestartIfNeededByRun=yes

[Files]
; There are no files that get packaged in directly.
Source: "Readme.txt"; DestDir: "{app}"; Flags: isreadme
Source: "VC_redist.x86.exe"; DestDir: "{app}"; Flags: deleteafterinstall

[Run]
Filename: "{app}\VC_redist.x86.exe"; Parameters: "/passive /norestart"

[Code]
(* Type declarations *)
type
  MItem = record
    (* The MItem type holds a key-value pair found in the installer manifest
    file. MItems are used when the Key is not one of the predetermined,
    well-known values in either the [Options] section or one of the Option
    details sections.

    Key: The key/name of the option or location listing in the manifest file.
    Value: The value(s) assigned to the key.
    *)
    
    Key: String;
    Value: String;
  end;

type
  MOption = record
    (* The MOption stores the details for a given option defined in the
    Options section of the manifest. 

    Option:          The key-value pair defining the Option's type and name.
    Required:        Whether or not the Option type is required for
                     installation.
    Exclusive:       Set to True if the user can only choose one of potentially
                     many alternatives for this Option.
    Extension:       If the Inno Download Plugin does not capture an
                     intelligent filename from the URL and one cannot be
                     deciphered from analyzing the URL, this indicates the
                     extension that the download is intended to have. This
                     restricts any downloads for this option with unknown
                     extensions to a single file extension.
    Locations:       The URLs at which to download installation data for a
                     given Option.
    WizardPage:      The WizardPage (if any) that presents the alternatives for
                     this Option to the user.
    WizardListIndex: If there are other alternatives for this Option's type,
                     the user will be presented with this choice and the other
                     choices. This stores which index this choice has on the
                     Wizard Page. We need to keep track of this so that later
                     we can determine which choice(s) was/were selected.
    InstallActions:  The list of Actions defined in the manifest file to
                     install this Option.
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
    Shortcut: String;
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
  ShortcutsOptionPage: TInputOptionWizardPage; (* Option for shortcut loc *)


(* Functions and Procedures *)
function BoolToStr(const bool: Boolean): String;
(* Outputs an appropriate string representation of a boolean value.

Parameters:
bool: The boolean value to represent as a string

Returns:
String: The string representation of the passed boolean value.
*)
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

    (* Since it appears that we've find a final slash to the URL, try to excise
    any extraneous stuff, e.g., the ?dl=1 at the end of Dropbox links. *)
    StringChangeEx(filename, '{#URLDropboxQueryEnding}', '', True); 
  end;

  Result := res;
end;

function RemoveCharFromString(const c: WideChar; var str: String): Boolean;
(* Finds and removes every occurrence of a given character in the provided
string.

Parameters:

Returns:
Boolean: True if at least one occurence of the character was found. False if no
         occurrences were found.
*)
var
  res: Boolean;
  newStr: String;
  i: Integer;
begin
  res := False;
  newStr := '';

  for i := 1 to Length(str) do begin
    if str[i] <> c then begin
      newStr := newStr + str[i];
    end else begin
      res := True;
    end;
  end;

  str := newStr;

  Result := res;
end;

function CapFilenameWithQuotesAsNeeded(var filename: String): Boolean;
(* Inno Setup provides an AddQuotes() function that is supposed to add quotes
to a filename only if it has spaces. This function has not proved to be
working reliably. Therefore, this function removes all quotes from a given
filename and then looks for a space in the filename to see if it needs quotes
after all. If it finds a space, it caps each side of the filename with quotes.
Note that this function doesn't really do any error-checking if you pass it
something that is not a well-formed, fully-qualified filename.

Parameters:
filename: The fully-qualified filename that may need quotes.

Result:
Boolean: True if quotes were added. False if they were not.
*)
var
  res: Boolean;
  i: Integer;
begin
  res := False;
  i := 1;

  (* First, remove all quotes just in case we're passed a filename that doesn't
  need them to begin with. *)
  RemoveCharFromString('"', filename);

  while (not res) and (i <= Length(filename)) do begin  
    if filename[i] = ' ' then begin
      res := True;
    end else begin
      i := i + 1;
    end;
  end;

  if res then begin
    filename := '"' + filename + '"';
  end;

  Result := res;
end;

function CleanOldInstallation(): Boolean;
(* Cleans out old installations of PlayOnline Viewer, Final Fantasy XI, and any
files and all subdirectories left behind in the application install directory,
if any.

Parameters:
(none)

Returns
Boolean: True if successful in cleaning everything out. False if unsuccessful.
*)
var
  res: Boolean;
  execResult: Integer;
begin;
  res := True;

  Log('CleanOldInstallation(): Removing PlayOnline Viewer ...');
  if not Exec('>', '{#CleanUninstallCommandPOLV}', ExpandConstant('{tmp}'), SW_SHOW, ewWaitUntilTerminated, execResult) then begin
    Log('CleanOldInstallation(): Removing PlayOnline Viewer FAILED with error code: ' + IntToStr(execResult) + '.');
    res := False;
  end;
  
  Log('CleanOldInstallation(): Removing Final Fantasy XI client ...');
  if not Exec('>', '{#CleanUninstallCommandFFXI}', ExpandConstant('{tmp}'), SW_SHOW, ewWaitUntilTerminated, execResult) then begin
    Log('CleanOldInstallation(): Removing Final Fantasy XI client FAILED with error code: ' + IntToStr(execResult) + '.');
    res := False;
  end;

  Log('CleanOldInstallation(): Removing anything left in ' + ExpandConstant('{app}') + ' ...');
  if DirExists(ExpandConstant('{app}')) then begin
    if not Exec('cmd.exe', ExpandConstant('/c rmdir /Q  /S "{app}"'), ExpandConstant('{tmp}'), SW_SHOW, ewWaitUntilTerminated, execResult) then begin
      res := False;
      Log('CleanOldInstallation(): Removing anything left in ' + ExpandConstant('{app}') + ' FAILED with error code: ' + IntToStr(execResult) + '.');
    end; 
  end;

  Log('CleanOldInstallation(): Removing anything left in ' + ExpandConstant('{commonprograms}\Kujata Reborn') + ' ...');
  if DirExists(ExpandConstant('"{commonprograms}\Kujata Reborn"')) then begin
    if not Exec('cmd.exe', ExpandConstant('/c rmdir /Q  /S "{commonprograms}\Kujata Reborn"'), ExpandConstant('{tmp}'), SW_SHOW, ewWaitUntilTerminated, execResult) then begin
      res := False;
      Log('CleanOldInstallation(): Removing anything left in ' + ExpandConstant('{commonprograms}\Kujata Reborn') + ' FAILED with error code: ' + IntToStr(execResult) + '.');
    end; 
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

      (* Set some default values *)
      Options[i].Required := False;
      Options[i].Exclusive := False;
      Options[i].Selected := False;
      Options[i].Extension := '';
      Options[i].Shortcut := '';

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
            else begin
              if Pos(Options[i].Option.Value, key) > 0 then begin
                if Pos('{#ManifestOptionAction}', key) > 0 then begin
                  (* This is an Action for this particular option *)
                  Options[i].InstallActions[actionsFound] := value;
                  Log('ParseManifestDetails(): Storing Options[' + IntToStr(i) + '].InstallActions[' + IntToStr(actionsFound) + '] = ' + value + '.');
                  actionsFound := actionsFound + 1;
                end;
              end;
              if Pos(Options[i].Option.Value, key) > 0 then begin
                if Pos('{#ManifestOptionShortcut}', key) > 0 then begin
                  (* This is a Shortcut for this particular option. Only one
                  shortcut is kept, so only one should be defined in the
                  manifest file. *)
                  Options[i].Shortcut := value;
                  Log('ParseManifestDetails(): Storing Options[' + IntToStr(i) + '].Shortcut = ' + value + '.');
                end;
              end; 
              if key = Options[i].Option.Value then begin
                (* This is a location for the given option *)
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
  execResult: Integer;
begin
  Log('InitializeSetup(): Beginning function.');

  res := RetrieveManifest();

  (*
  Exec('>', 'cmd.exe /c mkdir "' + ExpandConstant('{commonprograms}\Kujata Reborn') + '"', ExpandConstant('{tmp}'), SW_SHOW, ewWaitUntilTerminated, execResult);
  CreateShellLink(ExpandConstant('{commonprograms}\Kujata Reborn\fuckyouheresmylink.lnk'), 'Shortcut to open bullshit', 'C:\Windows\System32\notepad.exe', '', ExpandConstant('{sys}'), '', 0, SW_SHOWNORMAL);
  *)

  if res then begin
    res := ParseManifest();
  end;

  if StrToFloat(ManVerControl.Value) > StrToFloat('{#TheAppVersion}') then begin
    res := False;
  end;

  if not res then begin
    Log('InitializeSetup(): res == FALSE, setup will not continue.');
  end;

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
          if Options[i].Required then begin
            Options[i].WizardPage.Values[Options[i].WizardListIndex] := True;
          end;
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

  introMsg := introMsg + {#StrNewLine} + {#StrNewLine} + '{#WizTextIntroMsgOptions}' + {#StrNewLine} + {#StrNewLine} + '{#WizTextIntroMsgFyi}' + {#StrNewLine} + '{#WizTextIntroMsgSize}' + {#StrNewLine} + {#StrNewLine} + '{#WizTextIntroMsgHelp}'

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
    CleanNotificationPage := CreateOutputMsgPage(wpReady, '{#WizTextCleanNotifyCaption}', '', '{#WizTextCleanNotifyMessage}');
  end;

  Result := res;
end;

function InitializeShortcutsOptionPage(): Boolean;
(* Gives the user the option to install shortcuts to Start Menu, Desktop, or
both

Parameters:
(none)

Returns:
Boolean True if initialization was successful. False if not.
*)
var
  res: Boolean;
begin
  res := True; 

  ShortcutsOptionPage := CreateInputOptionPage(wpSelectDir, '{#WizTextShortcutsOptionCaption}', '{#WizTextShortcutsOptionDescription}', '{#WizTextShortcutsOptionSubcaption}', False, False);
  ShortcutsOptionPage.Add('{#WizTextShortcutsOptionStartMenu}');
  ShortcutsOptionPage.Add('{#WizTextShortcutsOptionDesktop}');

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
    res := InitializeShortcutsOptionPage();
  end;

  if res then begin
    res := InitializeCleanNotificationPage();
  end;

  if res then begin
    ActionProgressPage := CreateOutputProgressPage('{#WizTextActionProgressCaption}', '{#WizTextActionProgressDescription}');
  end;

end;

function IsInstallDataPresent(filename: String) : Boolean;
(* Looks for the install data defined in the manifest file to see if it's
already downloaded or if it's in the working directory.

Parameters:
(none)

Returns:
Boolean: True if the data is already present. False if not
*)
var
  res: Boolean;
begin
  res := False;

  if FileExists(ExpandConstant('{src}\' + filename)) then begin
    res := True;
  end;

  Result := res;
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
  execResult: Integer;
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

          if IsInstallDataPresent(filename) then begin
            Log(ExpandConstant('PrepareToDownloadInstallData(): Found ' + filename + ' at {src}\' + filename + ' and attempting to copy to {tmp}\' + filename + '.'));
            if not Exec('>', ExpandConstant('cmd.exe /c copy /V /Y "{src}\' + filename + '" "{tmp}\' + filename + '"'), ExpandConstant('{tmp}'), SW_SHOW, ewWaitUntilTerminated, execResult) then begin
              Log(ExpandConstant('PrepareToDownloadInstallData(): Copy failed. Adding ' + filename + ' to download list.'));
              idpAddFile(Options[i].Locations[j].Value, ExpandConstant('{tmp}\' + filename));
            end;
          end else begin
            idpAddFile(Options[i].Locations[j].Value, ExpandConstant('{tmp}\' + filename));
          end;
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

function ProcessShortcuts(): Boolean;
(* Creates the shortcuts defined in the manifest file.

Parameters:
(none)

Returns:
Boolean: True if the shortcuts were processed correctly. False if they were
         not.
*)
var
  res: Boolean;
  execResult: Integer;
  startMenuDir: String;
  linkStartMenu: String;
  linkDesktop: String;
  runIn: String;
  i: Integer;
begin
  res := True;

  for i := 0 to GetArrayLength(Options) - 1 do begin
    if Options[i].Selected then begin
      if Length(Options[i].Shortcut) > 0 then begin
        (* Remove any quotes from the directory that the shortcut will run in
        because CreateShellLink will add them if they're needed. But it doesn't
        check to see if they're already there. *)
        runIn := ExtractFileDir(ExpandConstant(Options[i].Shortcut));
        RemoveCharFromString('"', runIn);
        startMenuDir := ExpandConstant('{userprograms}\Kujata Reborn'); 
        linkStartMenu := ExpandConstant('{userprograms}\Kujata Reborn\' + Options[i].Option.Value + '.lnk');
        linkDesktop := ExpandConstant('{userdesktop}\' + Options[i].Option.Value + '.lnk');
        if ShortcutsOptionPage.Values[0] then begin
          (* Start Menu shortcuts *)
          if not DirExists(startMenuDir) then begin
            Exec('>', 'cmd.exe /c mkdir "' + startMenuDir + '"', ExpandConstant('{tmp}'), SW_SHOW, ewWaitUntilTerminated, execResult);
          end;  
          CreateShellLink(linkStartMenu, 'Shortcut to open ' + Options[i].Option.Value, ExpandConstant(Options[i].Shortcut), '', runIn, ExpandConstant(Options[i].Shortcut), 0, SW_SHOWNORMAL);
        end;
        if ShortcutsOptionPage.Values[1] then begin
          (* Desktop shortcuts *)
          CreateShellLink(linkDesktop, 'Shortcut to open ' + Options[i].Option.Value, ExpandConstant(Options[i].Shortcut), '', runIn, ExpandConstant(Options[i].Shortcut), 0, SW_SHOWNORMAL);
        end;
      end;
    end;
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
  idpPageId: Integer;
  i: Integer;
begin
  idpPageId := -1

  case CurPageID of
    wpSelectDir : begin
      if CleanOptionPage.SelectedValueIndex = 1 then begin
        PrepareToDownloadInstallData(wpSelectDir);
        idpPageId := IDPForm.Page.ID;
      end;
      res := True; 
    end;
    CleanNotificationPage.ID : begin
      CleanOldInstallation();
      PrepareToDownloadInstallData(CleanNotificationPage.ID);
      idpPageId := IDPForm.Page.ID;
      res := True;
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

procedure CurStepChanged(CurStep: TSetupStep);
(* An event function of Inno Setup, this is called when the installation step
has changed. For our purposes, used to discover when the installation step has
been reached. Then we start processing the installation actions.

Parameters
CurStep: A TSetupStep which will be the installation step to which the sytem
         has just changed.

Returns:
(n/a)
*)
begin
  case CurStep of
    ssInstall : begin
      ProcessActions();
    end;
    ssPostInstall : begin
      ProcessShortcuts();
    end;
    else begin
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
(* An event function of Inno Setup, this is called when the uninstallation step
has changed. For our purposes, used to discover when the uninstall step has
been reached. Then we do a clean-out of the old install.

Parameters
CurUninstallStep: A TUninstallStep which will be the uninstallation step to
                  which the system has just changed.

Returns:
(n/a)
*)
begin
  case CurUninstallStep of
    usUninstall : begin
      CleanOldInstallation();
    end;
    else begin
    end;
  end;
end;