;------------------------------------------------------------------------------
;
;       Build Script using Inno Setup 5.5.6
;       
;
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;   DEFINE CONSTANS
;------------------------------------------------------------------------------

; APPLICATION NAME
#define   Name       "GraficRedactor"
; EXECUTE FILE NAME
#define   ExeName    "GraficRedactor.exe"

#define SrcApp "bin\Release\GraficRedactor.exe"

#define Version GetFileVersion(SrcApp)
;
;------------------------------------------------------------------------------
;   PARAMETERS
;------------------------------------------------------------------------------
[Setup]

; APPLICATION GUID
AppId={{BB3BB686-C1A5-4C41-BB6F-CFD7EF11E574}

; INFO ABOUT APPLICATION
AppName={#Name}
AppVerName={#ExeName} {#Version}
AppVersion={#Version}
; DEFAULT INSTALLATION DIR
DefaultDirName={pf}\{#Name}
; GROUP NAME
DefaultGroupName={#Name}

; DIR WHERE SCRIPT WILL BE CREATED
OutputDir={#SourcePath}\Installator
OutputBaseFileName=GraficRedactorInstalator

; COMPRESSION PARAMETERS
Compression=lzma
SolidCompression=yes


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"; 
Name: "russia"; MessagesFile: "compiler:Languages\Russian.isl"; 

[Tasks]
; CREATE SHORTCUT 
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]

; EXECUTABLE FILE
Source: "bin\Release\GraficRedactor.exe"; DestDir: "{app}"; Flags: ignoreversion

; Source: "D:\Soft\dotNET\NDP453-KB2969351-x86-x64-AllOS-ENU.exe"; DestDir: "{tmp}"; Check: not IsRequiredDotNetDetected

[Icons]
Name: "{group}\{#ExeName}"; Filename: "{app}\{#ExeName}"
Name: "{commondesktop}\{#ExeName}"; Filename: "{app}\{#ExeName}"; Tasks: desktopicon

[Code]
function IsDotNetDetected(version: string; release: cardinal): boolean;

var 
    reg_key: string;
    success: boolean;
    release45: cardinal;
    key_value: cardinal;
    sub_key: string;

begin 
    success := false;
    reg_key := 'SOFTWARE\Microsoft\NET Framework Setup\NDP\';

    if Pos('v4.5', version) = 1 then
      begin 
        sub_key := 'v4\Full';
        reg_key := reg_key + sub_key;
        success := RegQueryDWordValue(HKLM, reg_key, 'Release', release45);
        success := success and (release45 >= release);
      end;

    result := success;
  end;

function IsRequiredDotNetDetected(): boolean;
begin
    result := IsDotNetDetected('v4.5 Full Profile', 0);
end;

function GetUninstallString: string;
var
  sUnInstPath: string;
  sUnInstallString: String;
begin
  Result := '';
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{{BB3BB686-C1A5-4C41-BB6F-CFD7EF11E574}_is1'); //Your App GUID/ID
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;

function IsUpgrade: Boolean;
begin
  Result := (GetUninstallString() <> '');
end;

function InitializeSetup(): boolean;
var
  V: Integer;
  iResultCode: Integer;
  sUnInstallString: string;
  ErrCode: integer;
begin
 if not IsDotNetDetected('v4.5 Full Profile', 0) then
      begin
        MsgBox('{#Name} requires Microsoft .NET Framework 4.5 Full Profile.'#13#13
             'Click OK to go site with .NET Framework 4.5 installer', mbInformation, MB_OK);
         ShellExec('open', 'https://www.microsoft.com/ru-ru/download/details.aspx?id=44927',
      '', '', SW_SHOW, ewNoWait, ErrCode);
             Exit;
      end 
 else 
 begin
  Result := True; // in case when no previous version is found
  if RegValueExists(HKEY_LOCAL_MACHINE,'Software\Microsoft\Windows\CurrentVersion\Uninstall\{BB3BB686-C1A5-4C41-BB6F-CFD7EF11E574}_is1', 'UninstallString') then  //Your App GUID/ID
  begin
    V := MsgBox(ExpandConstant('Hey! An old version of app was detected. Do you want to uninstall it?'), mbInformation, MB_YESNO); //Custom Message if App installed
    if V = IDYES then
    begin
      sUnInstallString := GetUninstallString();
      sUnInstallString :=  RemoveQuotes(sUnInstallString);
      Exec(ExpandConstant(sUnInstallString), '', '', SW_SHOW, ewWaitUntilTerminated, iResultCode);
      Result := True; //if you want to proceed after uninstall
                //Exit; //if you want to quit after uninstall
    end
    else
      Result := False; //when older version present and not uninstalled
    end;
    
   

  result := true;
  end;
end;

[Run]
Filename: {tmp}\NDP453-KB2969351-x86-x64-AllOS-ENU.exe; Parameters: "/q:a /c:""install /l /q"""; Check: not IsRequiredDotNetDetected; StatusMsg: Microsoft Framework 4.5 is installed. Please wait...
