; MFILEMON - print to file with automatic filename assignment
; Copyright (C) 2007-2013 Monti Lorenzo
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#define SrcApp "..\win32\release\mfilemon.dll"
#define FileVerStr GetFileVersion(SrcApp)
#define StripBuild(str VerStr) Copy(VerStr, 1, RPos(".", VerStr) - 1)
#define AppVerStr StripBuild(FileVerStr)
#define AppName "Multi file port monitor (mfilemon)"

[Setup]
AppId={{A932243F-381F-434C-B18E-4F09D2F015F8}
AppName={#AppName}
AppVersion={#AppVerStr}
AppVerName={#AppName} {#AppVerStr}
AppPublisher=Monti Lorenzo
AppPublisherURL=http://mfilemon.sourceforge.net/
AppSupportURL=http://mfilemon.sourceforge.net/
AppUpdatesURL=http://mfilemon.sourceforge.net/
UninstallDisplayName={#AppName} {#AppVerStr}
VersionInfoCompany=Monti Lorenzo
VersionInfoCopyright=Copyright © 2007-2013 Monti Lorenzo
VersionInfoDescription={#AppName} setup program
VersionInfoProductName={#AppName}
VersionInfoVersion={#FileVerStr}

CreateAppDir=yes
DefaultDirName={pf}\mfilemon
DefaultGroupName=Multi File Port Monitor

; we take care of these on our own
CloseApplications=no
RestartApplications=no

OutputBaseFilename=mfilemon-setup
Compression=lzma
SolidCompression=yes
ArchitecturesAllowed=x86 x64
ArchitecturesInstallIn64BitMode=x64
MinVersion=0,5.0

LicenseFile=gpl-3.0.rtf

SignTool=lomosign /d "{#AppName}"

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "it"; MessagesFile: "compiler:Languages\Italian.isl"

[CustomMessages]
en.errRegister=Error in port monitor registration!
en.errUnregister=Error in port monitor unregistration! Continue with removal anyway?
en.stoppingSpooler=Stopping spooler...
en.startingSpooler=Starting spooler...

it.errRegister=Errore nella registrazione del port monitor!
it.errUnregister=Errore nella deregistrazione del port monitor! Continuare ugualmente con la rimozione?
it.stoppingSpooler=Arresto dello spooler...
it.startingSpooler=Avvio dello spooler...

[Files]
; x64 files
Source: "..\x64\release\mfilemon.dll"; DestDir: "{sys}"; Flags: promptifolder replacesameversion; Languages: en; Check: Is_x64
Source: "..\x64\release\mfilemonUI.dll"; DestDir: "{sys}"; Flags: promptifolder replacesameversion; Languages: en; Check: Is_x64
Source: "..\x64\release-ita\mfilemon.dll"; DestDir: "{sys}"; Flags: promptifolder replacesameversion; Languages: it; Check: Is_x64
Source: "..\x64\release-ita\mfilemonUI.dll"; DestDir: "{sys}"; Flags: promptifolder replacesameversion; Languages: it; Check: Is_x64
; x86 files
Source: "..\win32\release\mfilemon.dll"; DestDir: "{sys}"; Flags: promptifolder replacesameversion; Languages: en; Check: Is_x86
Source: "..\win32\release\mfilemonUI.dll"; DestDir: "{sys}"; Flags: promptifolder replacesameversion; Languages: en; Check: Is_x86
Source: "..\win32\release-ita\mfilemon.dll"; DestDir: "{sys}"; Flags: promptifolder replacesameversion; Languages: it; Check: Is_x86
Source: "..\win32\release-ita\mfilemonUI.dll"; DestDir: "{sys}"; Flags: promptifolder replacesameversion; Languages: it; Check: Is_x86
; files common to either architectures
Source: "..\docs\ghostscript-mfilemon-howto.html"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\docs\images\*"; DestDir: "{app}\images"; Flags: ignoreversion
Source: "release\setuphlp.dll"; DestDir: "{sys}"; Flags: dontcopy
Source: "..\conf\*"; DestDir: "{app}\conf"; Flags: ignoreversion

[Icons]
Name: "{group}\ghostscript-mfilemon howto"; Filename: "{app}\ghostscript-mfilemon-howto.html"; WorkingDir: "{app}";

[Code]
var
  bIsAnUpdate: Boolean;
  bDeleteMonOk: Boolean;

{----------------------------------------------------------------------------------------}
function RegisterMonitor: LongBool;
external 'RegisterMonitor@files:setuphlp.dll stdcall setuponly';

function DeleteMonitor(pName, pEnvironment, pMonitorName: String): LongBool;
external 'DeleteMonitorW@winspool.drv stdcall uninstallonly';

{----------------------------------------------------------------------------------------}
function Is_x86: Boolean;
begin
  Result := (ProcessorArchitecture = paX86);
end;

{----------------------------------------------------------------------------------------}
function Is_x64: Boolean;
begin
  Result := (ProcessorArchitecture = paX64);
end;

{----------------------------------------------------------------------------------------}
procedure StopSpooler;
var
  res: Integer;
begin
  WizardForm.StatusLabel.Caption := ExpandConstant('{cm:stoppingSpooler}');
  Exec(ExpandConstant('{sys}\net.exe'), 'stop Spooler', '', SW_HIDE, ewWaitUntilTerminated, res);
end;

{----------------------------------------------------------------------------------------}
procedure StartSpooler;
var
  res: Integer;
begin
  WizardForm.StatusLabel.Caption := ExpandConstant('{cm:startingSpooler}');
  Exec(ExpandConstant('{sys}\net.exe'), 'start Spooler', '', SW_HIDE, ewWaitUntilTerminated, res);
end;

{----------------------------------------------------------------------------------------}
function DestinationFilesExist: Boolean;
begin
  Result := FileExists(ExpandConstant('{sys}\mfilemon.dll')) and
            FileExists(ExpandConstant('{sys}\mfilemonUI.dll'));
end;

{----------------------------------------------------------------------------------------}
function InitializeSetup: Boolean;
begin
  bIsAnUpdate := DestinationFilesExist;
  Result := True;
end;

{----------------------------------------------------------------------------------------}
procedure CurStepChanged(CurStep: TSetupStep);
begin
  case CurStep of
    ssInstall:
      begin
        if bIsAnUpdate then
          StopSpooler;
      end;
    ssPostInstall:
      begin
        if bIsAnUpdate then
          StartSpooler
        else begin
          if not RegisterMonitor then
            MsgBox(CustomMessage('errRegister'), mbError, MB_OK);
        end;
      end;
  end;
end;

{----------------------------------------------------------------------------------------}
function InitializeUninstall: Boolean;
begin
  bDeleteMonOk := DeleteMonitor('', '', 'Multi File Port Monitor');
  if bDeleteMonOk then
    Result := True
  else begin
    if MsgBox(CustomMessage('errUnregister'), mbError, MB_YESNO) = IDYES then
      Result := True
    else
      Result := False;
  end;
end;

{----------------------------------------------------------------------------------------}
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  case CurUninstallStep of
    usUninstall:
      begin
        if not bDeleteMonOk then
          StopSpooler;
      end;
    usPostUninstall:
      begin
        if not bDeleteMonOk then
          StartSpooler;
      end;
  end;
end;



