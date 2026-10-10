[Setup]
AppName=Niji LOCAL
AppVersion=1.0.0
DefaultDirName={autopf}\NijiLocal
DefaultGroupName=Niji LOCAL
OutputDir=installer
OutputBaseFilename=NijiLocal_Setup
Compression=lzma
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=lowest

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Launcher
Source: "dist\NijiLocal.exe"; DestDir: "{app}"; Flags: ignoreversion

; Frontend
Source: "frontend\build\windows\x64\runner\Release\*"; DestDir: "{app}\frontend"; Flags: ignoreversion recursesubdirs createallsubdirs

; Backend
Source: "dist\run_server\*"; DestDir: "{app}\backend"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Niji LOCAL"; Filename: "{app}\NijiLocal.exe"
Name: "{autodesktop}\Niji LOCAL"; Filename: "{app}\NijiLocal.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\NijiLocal.exe"; Description: "{cm:LaunchProgram,Niji LOCAL}"; Flags: nowait postinstall skipifsilent
