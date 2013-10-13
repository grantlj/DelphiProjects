unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls,math,jpeg,IdFTP,IdFTPList,winsock,wininet,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,top;
const
   FACEMAX=3942;
type
  TForm2 = class(TForm)
    Image1: TImage;
    TrackBar1: TTrackBar;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Timer1: TTimer;
    Image2: TImage;
    procedure TrackBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  link=^ftpq;
  ftpq=record
      orgname,ftpname:string;
  end;


var
  Form2: TForm2;
  NowFile,NowFileAdd,Mac:string;
  ftp:tidftp;
  ftpworkerhandle,ftpworkerid:dword;
  ClosePermission:boolean;

implementation

{$R *.dfm}

//Get Mac Address!!!
function getname: String;
var
  s:array[0..255] Of Char;
  u:cardinal;
begin
  u:=255;
  GetcomputerName(@s, u);
  Result:=s;
end;

function GetMacAddress(AServerName: string): string;
type
TNetTransportEnum = function(pszServer: PWideChar;
Level: DWORD;
var pbBuffer: pointer;
PrefMaxLen: LongInt;
var EntriesRead: DWORD;
var TotalEntries: DWORD;
var ResumeHandle: DWORD): DWORD; stdcall;

TNetApiBufferFree = function(Buffer: pointer): DWORD; stdcall;

PTransportInfo = ^TTransportInfo;
TTransportInfo = record
quality_of_service: DWORD;
number_of_vcs: DWORD;
transport_name: PWChar;
transport_address: PWChar;
wan_ish: boolean;
end;

var
E, ResumeHandle,
EntriesRead,
TotalEntries: DWORD;
FLibHandle: THandle;
sMachineName,
sMacAddr,
Retvar: string;
pBuffer: pointer;
pInfo: PTransportInfo;
FNetTransportEnum: TNetTransportEnum;
FNetApiBufferFree: TNetApiBufferFree;
pszServer: array[0..128] of WideChar;
i, ii, iIdx: integer;
begin
sMachineName := trim(AServerName);
Retvar := '00-00-00-00-00-00';

// Add leading \\ if missing
if (sMachineName <> '') and (length(sMachineName) >= 2) then
begin
if copy(sMachineName, 1, 2) <> '\\' then
sMachineName := '\\' + sMachineName
end;

// Setup and load from DLL
pBuffer := nil;
ResumeHandle := 0;
FLibHandle := LoadLibrary('NETAPI32.DLL');

// Execute the external function
if FLibHandle <> 0 then
begin
@FNetTransportEnum := GetProcAddress(FLibHandle, 'NetWkstaTransportEnum');
@FNetApiBufferFree := GetProcAddress(FLibHandle, 'NetApiBufferFree');
E := FNetTransportEnum(StringToWideChar(sMachineName, pszServer, 129), 0,
pBuffer, -1, EntriesRead, TotalEntries, Resumehandle);

if E = 0 then
begin
pInfo := pBuffer;

// Enumerate all protocols - look for TCPIP
for i := 1 to EntriesRead do
begin
if pos('TCPIP', UpperCase(pInfo^.transport_name)) <> 0 then
begin
// Got It - now format result 'xx-xx-xx-xx-xx-xx'
iIdx := 1;
sMacAddr := pInfo^.transport_address;

for ii := 1 to 12 do
begin
Retvar[iIdx] := sMacAddr[ii];
inc(iIdx);
if iIdx in [3, 6, 9, 12, 15] then
inc(iIdx);
end;
end;

inc(pInfo);
end;
if pBuffer <> nil then
FNetApiBufferFree(pBuffer);
end;

try
FreeLibrary(FLibHandle);
except
// Silent Error
end;
end;

Result := Retvar;
end;

//FTP Worker Moudle....
//===================================================

function ftpinit:boolean;
var
  bool:boolean;

function tryconnect:boolean;
begin
  ftp:=tidftp.create(nil);
  ftp.Host:='grantlj.gicp.net';
  ftp.username:='grantlj';
  ftp.Password:='940414';
  ftp.Port:=21;
  try
    ftp.connect;
    if ftp.Connected then result:=true else begin ftp.Free;result:=false;end;
  except
    ftp.free;
    result:=false;
  end;

end;

begin
  repeat
    sleep(40);
    bool:=tryconnect;
  until bool=true;
  result:=true;
end;

//FTP 队列上传
procedure ftpworker;
var
  currentdir:string;
  msg1:msg;
  p:link;
begin
  ftpinit;
  repeat
    if (getmessage(msg1,0,0,0)) and (ftp.connected=true) then begin
    sleep(20);
    p:=link(msg1.wparam);
         with p^ do
          begin
            try
              ftp.Put(orgname,ftpname,false);
              deletefile(orgname);
            except

            end;
        end;

    end
  else ftpinit;
  until CLOSEPERMISSION;
  ftp.disconnect;
  halt;
 // application.Terminate;

end;

//FTP EXTRA FUNCTION END!!!!
//====================================================
//====================================================



function submit:boolean;
var
  quetmp:link;
  bool:boolean;
  NowDatFile:string;
begin
     NowDatFile:=mac+'@'+formatdatetime('yyyymmddhhmmss',now)+'.dat';
     RenameFile(extractfilepath(paramstr(0))+'\tmp.dat',extractfilepath(paramstr(0))+'\'+NowDatFile);
     new(quetmp);
     quetmp.orgname:=extractfilepath(paramstr(0))+'\'+NowDatFile;
     quetmp.ftpname:=NowDatFile;
     repeat
       bool:=postthreadmessage(ftpworkerid,0,longint(quetmp),0);
     until bool=true;
     result:=true;
end;



procedure GenerateNextPic;
var
  i:integer;
  ok:boolean;
begin
repeat
  ok:=true;
try
  randomize;
  i:=randomrange(1,FACEMAX);
  NowFile:='CQUPT2013';
       if (i<10) then NowFile:=NowFile+'000';
       if (i>=10)and (i<100) then NowFile:=NowFile+'00';
       if (i>=100) and (i<1000) then NowFile:=NowFile+'0';
       NowFile:=NowFile+inttostr(i);
  NowFileAdd:=extractfilepath(paramstr(0))+'\FACES\'+NowFile+'.jpg';
  form2.Image1.Picture.LoadFromFile(NowFileAdd);
  form2.label4.Caption:=NowFile;
  form2.trackbar1.position:=5;
except
  ok:=false;
end;
until ok;
end;

procedure init;

begin
  //DO INIT HERE:
  //CREATE TWO THREADS;
  //START NUMBER ONE!
  ClosePermission:=false;
  Mac:=GetMacAddress(GetName);
  ftpworkerhandle:=createthread(nil,0,@ftpworker,nil,0,ftpworkerid);
  GenerateNextPic;
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  f:textfile;

begin
  assignfile(f,'tmp.dat');
  if not (fileexists('tmp.dat')) then rewrite(f) else append(f);
  writeln(f,NowFile);
  writeln(f,trackbar1.position);
  closefile(f);
  GenerateNextPic;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  GenerateNextPic;
end;

procedure TForm2.Button3Click(Sender: TObject);
var
  ftp:tidftp;
  ok:boolean;
begin
  ok:=true;
  ftp:=tidftp.create(nil);
  ftp.Host:='grantlj.gicp.net';
  ftp.username:='grantlj';
  ftp.Password:='940414';
  ftp.Port:=21;
  try
    ftp.connect;
    ftp.Get('SORTED.TXT',extractfilepath(paramstr(0))+'\'+'SORTED.TXT',TRUE);
  except
    ftp.disconnect;
    ftp.free;
    showmessage('连接远程服务器失败！请稍后重试！');
    ok:=false;
  end;
  if ok then begin form1.show;end;

end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  //form close;
  //continue thread;
  form2.hide;
  CLOSEPERMISSION:=true;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  init;

end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  submit;
end;

procedure TForm2.TrackBar1Change(Sender: TObject);
begin
 label1.Caption:=(inttostr(trackbar1.position));
end;

end.
