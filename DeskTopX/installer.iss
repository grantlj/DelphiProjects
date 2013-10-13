; 脚本用 Inno Setup 脚本向导 生成。
; 查阅文档获取创建 INNO SETUP 脚本文件详细资料！

#define MyAppName "DesktopX"
#define MyAppVerName "DesktopX 1.1 Build1151"
#define MyAppPublisher "Grant Liu"
#define MyAppURL "393444163@qq.com"
#define MyAppExeName "DXMain.exe"

[Setup]
; 注意: AppId 的值是唯一识别这个程序的标志。
; 不要在其他程序中使用相同的 AppId 值。
; (在编译器中点击菜单“工具 -> 产生 GUID”可以产生一个新的 GUID)
AppId={{550155C8-3F74-4E8C-B610-C34519F2A46D}
AppName={#MyAppName}
AppVerName={#MyAppVerName}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=C:\Users\LiuJiang\Desktop
OutputBaseFilename=DesktopX_Build1151_Setup
SetupIconFile=C:\Users\LiuJiang\Desktop\DesktopX\calendar.ico
Compression=lzma
SolidCompression=yes

[Languages]
Name: "default"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked;


[Files]
Source: "C:\Users\LiuJiang\Desktop\DesktopX\DXMain.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\LiuJiang\Desktop\DesktopX\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; 注意: 不要在任何共享的系统文件使用 "Flags: ignoreversion" 

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon;workingdir:"{app}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent
