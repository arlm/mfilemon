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

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "it"; MessagesFile: "compiler:Languages\Italian.isl"

[CustomMessages]
en.errRegister=Error in port monitor registration!
it.errRegister=Errore nella registrazione del port monitor!
en.errUnregister=Error in port monitor unregistration! Continue with removal anyway?
it.errUnregister=Errore nella deregistrazione del port monitor! Continuare ugualmente con la rimozione?

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
type
  SERVICE_STATUS = record
    dwServiceType: Cardinal;
    dwCurrentState: Cardinal;
    dwControlsAccepted: Cardinal;
    dwWin32ExitCode: Cardinal;
    dwServiceSpecificExitCode: Cardinal;
    dwCheckPoint: Cardinal;
    dwWaitHint: Cardinal;
  end;
        
  SERVICE_STATUS_PROCESS = record
    dwServiceType: Cardinal;
    dwCurrentState: Cardinal;
    dwControlsAccepted: Cardinal;
    dwWin32ExitCode: Cardinal;
    dwServiceSpecificExitCode: Cardinal;
    dwCheckPoint: Cardinal;
    dwWaitHint: Cardinal;
    dwProcessId: Cardinal;
    dwServiceFlags :Cardinal;
  end;

  HANDLE = Cardinal;
        
const
  SERVICE_QUERY_CONFIG        = $00000001;
  SERVICE_CHANGE_CONFIG       = $00000002;
  SERVICE_QUERY_STATUS        = $00000004;
  SERVICE_START               = $00000010;
  SERVICE_STOP                = $00000020;
  SERVICE_ALL_ACCESS          = $000f01ff;
  SC_MANAGER_ALL_ACCESS       = $000f003f;
  SERVICE_WIN32_OWN_PROCESS   = $00000010;
  SERVICE_WIN32_SHARE_PROCESS = $00000020;
  SERVICE_WIN32               = $00000030;
  SERVICE_INTERACTIVE_PROCESS = $00000100;
  SERVICE_BOOT_START          = $00000000;
  SERVICE_SYSTEM_START        = $00000001;
  SERVICE_AUTO_START          = $00000002;
  SERVICE_DEMAND_START        = $00000003;
  SERVICE_DISABLED            = $00000004;
  SERVICE_DELETE              = $00010000;
  SERVICE_CONTROL_STOP        = $00000001;
  SERVICE_CONTROL_PAUSE       = $00000002;
  SERVICE_CONTROL_CONTINUE    = $00000003;
  SERVICE_CONTROL_INTERROGATE = $00000004;
  SERVICE_STOPPED             = $00000001;
  SERVICE_START_PENDING       = $00000002;
  SERVICE_STOP_PENDING        = $00000003;
  SERVICE_RUNNING             = $00000004;
  SERVICE_CONTINUE_PENDING    = $00000005;
  SERVICE_PAUSE_PENDING       = $00000006;
  SERVICE_PAUSED              = $00000007;
  SC_STATUS_PROCESS_INFO      = $00000000;
  SERVICES_ACTIVE_DATABASE    = 'ServicesActive';
  
  szSpoolerService = 'SPOOLER';

var
  bIsAnUpdate: Boolean;
  bDeleteMonOk: Boolean;

{----------------------------------------------------------------------------------------}
function OpenSCManager(lpMachineName, lpDatabaseName: string; dwDesiredAccess: Cardinal): HANDLE;
external 'OpenSCManagerW@advapi32.dll stdcall';

function OpenService(hSCManager: HANDLE; lpServiceName: string; dwDesiredAccess: Cardinal): HANDLE;
external 'OpenServiceW@advapi32.dll stdcall';

function CloseServiceHandle(hSCObject: HANDLE): LongBool;
external 'CloseServiceHandle@advapi32.dll stdcall';

function StartService(hService: HANDLE; dwNumServiceArgs: Cardinal; lpServiceArgVectors: Cardinal): LongBool;
external 'StartServiceW@advapi32.dll stdcall';

function ControlService(hService: HANDLE; dwControl: Cardinal; var ServiceStatus: SERVICE_STATUS): LongBool;
external 'ControlService@advapi32.dll stdcall';

function QueryServiceStatusEx(hService: HANDLE; InfoLevel: Cardinal; var lpBuffer: SERVICE_STATUS_PROCESS;
  cbBufSize: Cardinal; var pcbBytesNeeded: Cardinal): LongBool;
external 'QueryServiceStatusEx@advapi32.dll stdcall';

function GetTickCount: Cardinal;
external 'GetTickCount@kernel32.dll stdcall';

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
function WaitForServiceStatus(hService: HANDLE; status: Cardinal): Boolean;
var
  ssService: SERVICE_STATUS_PROCESS;
  cbSize: Cardinal;
  dwStartTickCount, dwOldCheckPoint, dwWaitTime: Cardinal;
  bFirst: Boolean;
begin
  Result := False;
  bFirst := True;
  while True do begin
    if not QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO,
    ssService, SizeOf(ssService), cbSize) then
      Break;
    case ssService.dwCurrentState of
      SERVICE_START_PENDING, SERVICE_STOP_PENDING: begin
        if bFirst or (ssService.dwCheckPoint > dwOldCheckPoint) then begin
          dwStartTickCount := GetTickCount;
          dwOldCheckPoint := ssService.dwCheckPoint;
          bFirst := False;
        end else if (GetTickCount - dwStartTickCount > ssService.dwWaitHint) then
          Break;
        dwWaitTime := ssService.dwWaitHint div 10;
        if dwWaitTime < 1000 then
          dwWaitTime := 1000
        else if dwWaitTime > 10000 then
          dwWaitTime := 10000;
        Sleep(dwWaitTime);
        Continue;
      end;
      SERVICE_RUNNING: begin
        if status = SERVICE_RUNNING then
          Result := True
        else
          Result := False;
        Break;
      end;
      SERVICE_STOPPED: begin
        if status = SERVICE_STOPPED then
          Result := True
        else
          Result := False;
        Break;
      end;
      else
        Break;
    end;
  end;
end;

{----------------------------------------------------------------------------------------}
function SetupStartService(ServiceName: string): Boolean;
var
  hSCM: HANDLE;
  hService: HANDLE;
begin
  Result := False;
  hSCM := OpenSCManager('', SERVICES_ACTIVE_DATABASE, SC_MANAGER_ALL_ACCESS);
  if hSCM <> 0 then begin
    hService := OpenService(hSCM, ServiceName, SERVICE_ALL_ACCESS);
    if hService <> 0 then begin
      if StartService(hService, 0, 0) then
        Result := WaitForServiceStatus(hService, SERVICE_RUNNING);
      CloseServiceHandle(hService);
    end;
    CloseServiceHandle(hSCM);
  end;
end;

{----------------------------------------------------------------------------------------}
function SetupStopService(ServiceName: string): Boolean;
var
	hSCM: HANDLE;
	hService: HANDLE;
	Status: SERVICE_STATUS;
begin
	Result := False;
	hSCM := OpenSCManager('', SERVICES_ACTIVE_DATABASE, SC_MANAGER_ALL_ACCESS);
	if hSCM <> 0 then begin
		hService := OpenService(hSCM, ServiceName, SERVICE_ALL_ACCESS);
    if hService <> 0 then begin
      if ControlService(hService, SERVICE_CONTROL_STOP, Status) then
        Result := WaitForServiceStatus(hService, SERVICE_STOPPED);
      CloseServiceHandle(hService);
		end;
    CloseServiceHandle(hSCM);
	end;
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
          SetupStopService(szSpoolerService);
      end;
    ssPostInstall:
      begin
        if bIsAnUpdate then
          SetupStartService(szSpoolerService)
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
          SetupStopService(szSpoolerService);
      end;
    usPostUninstall:
      begin
        if not bDeleteMonOk then
          SetupStartService(szSpoolerService);
      end;
  end;
end;



