#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

[Setup]
AppId={{EB1BEEEF-EC84-4267-A9E7-078FE4863579}
AppName=Soul State
AppVersion={#AppVersion}
AppVerName=Soul State {#AppVersion}
AppPublisher=Shanmugananthan
AppPublisherURL=https://github.com/shanmugananthan/soulstate
AppSupportURL=https://github.com/shanmugananthan/soulstate/issues
AppUpdatesURL=https://github.com/shanmugananthan/soulstate/releases
DefaultDirName={autopf}\SoulState
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=..\build\installer
OutputBaseFilename=SoulState-windows-x64-setup
SetupIconFile=runner\resources\app_icon.ico
UninstallDisplayIcon={app}\SoulState.exe
UninstallDisplayName=Soul State
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Soul State"; Filename: "{app}\SoulState.exe"; AppUserModelID: "com.shanmugananthan.soulstate"
Name: "{autodesktop}\Soul State"; Filename: "{app}\SoulState.exe"; Tasks: desktopicon; AppUserModelID: "com.shanmugananthan.soulstate"

[Run]
Filename: "{app}\SoulState.exe"; Description: "{cm:LaunchProgram,Soul State}"; Flags: nowait postinstall skipifsilent
