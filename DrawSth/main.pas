{Project Name   : DrawSth
 Version        : 1.0
 Project Start  : 2013/11/5
 Project Finish : 2013/11/??
 Author        : Grant Liu
 Design for Ivy Hu.
}
unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,JPEG,winsock2;
const
  MAX_STEPS=50000;
type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    ColorDialog1: TColorDialog;
    Button7: TButton;
    ComboBox1: TComboBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Image1: TImage;
    procedure Button4Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  {
    TPenAction is to save the pen's info.
    Pix:              the width of the pen.
    Color:            the color of the pen.
    StartX,StartY:    the location which pen starts at.
    EndX,EndY:        the location which pen ends at.
    Tag:              to determine the pen's position in a line.
    Interval:         to simulate the processing of drwaing ACCURATELY.
    DrawInt:          to record the interval BETWEEN TWO LINES.
  }

  TPenAction=record
    Pix:integer;
    Color:TColor;
    StartX,StartY:integer;
    EndX,EndY:integer;
    Tag:integer;
    Interval:longint;
    DrawInt:longint;
  end;

  TACTS=array[1..MAX_STEPS] of TPenAction;

var
  Form1: TForm1;
  ReadyToDraw:boolean;
  Tag:integer;


implementation

{$R *.dfm}



const
  btn4_str1='Draw!';
  btn4_str2='Submit!';


var
  PenActs:TACTS;
  PenActsCounts:longint;
  TmpPenStart,TmpPenEnd:int64;
  TmpIntStart,TmpIntEnd:int64;
  ServSocketHandle,ServSocketID:DWORD;
  CliSocketHandle,CliSocketID:DWORD;
  CliSocketReady,ServSocketReady:boolean;
  ServMode:boolean;


  {*********************************
   NetWork varities defined here.
   *********************************
  }
  PlayerIP:string[15];


//GetPenState is to refresh the PenState.
procedure SetPenMode(isPen:boolean);
begin
  if isPen then form1.Image1.Cursor:=crCross
           else form1.Image1.Cursor:=crNoDrop;
end;

procedure GetPenState;
begin
  with form1 do
    begin
      if RadioButton1.Checked then
        begin
          //Is Pen.
          Image1.Canvas.Pen.Width:=strtoint(ComboBox1.text);
          Image1.Canvas.Pen.Color:=ColorDialog1.Color;
        end
      else
        begin
          Image1.Canvas.Pen.Width:=strtoint(ComboBox1.Text);
          Image1.Canvas.Pen.Color:=clwhite;

        end;
    end;
end;

//Start to record the operation of the pen.
procedure NewPenActs(x,y:integer);
begin
  TmpPenStart:=GetTickCount;
  inc(PenActsCounts);
  PenActs[PenActsCounts].StartX:=x;
  PenActs[PenActsCounts].StartY:=y;
  PenActs[PenActsCounts].Pix:=Form1.Image1.Canvas.Pen.Width;
  PenActs[PenActsCounts].Color:=Form1.Image1.Canvas.Pen.Color;
  PenActs[PenActsCounts].DrawInt:=0;
end;

//Finish to record the operation of the pen.
procedure FinishPenActs(x,y,tag:integer);
begin
   TmpPenEnd:=GetTickCount;
   PenActs[PenActsCounts].EndX:=x;
   PenActs[PenActsCounts].EndY:=y;
   PenActs[PenActsCounts].Tag:=tag;
   PenActs[PenActsCounts].Interval:=TmpPenEnd-TmpPenStart;
end;

//Set the interval between drawing.
procedure SetDrawInt(int:int64);
begin
  PenActs[PenActsCounts].DrawInt:=int;
end;

//Initial the Canvas.
procedure InitialCanvas;
begin
  with form1 do
    begin
      //PenActsCounts:=0;
      Image1.Canvas.Pen.Color:=clwhite;
      Image1.Canvas.FillRect(Image1.Canvas.ClipRect);
      SetPenMode(RadioButton1.Checked);
      Image1.Canvas.Pen.Color:=clblack;
      ComboBox1.Text:='10';
      Image1.Canvas.Pen.Width:=strtoint(ComboBox1.Text);
      //GetPenState;
    end;
end;

//Clear Pen action queue.
procedure ClearPenActs;
begin
   PenActsCounts:=0;
end;

//Save the Canvas to file.
procedure SaveToJPGFile;
var
  jp:TJpegImage;
  FileName:string;
begin
  jp:=TJPEGImage.Create;
  FileName:=FormatDateTime('yyyymmddhhmmss',now)+'.jpg';
  try
    with jp do
    begin
      jp.CompressionQuality:=100;
      jp.Compress;
      Assign(form1.Image1.Picture.Bitmap);
      SaveToFile(FileName);
    end;
  finally
    jp.Free;
  end;
end;

//Simulate the drwaing processing.
procedure RewriteCanvasByActs(x:TACTS;s:integer);
var
  i:longint;
begin
  InitialCanvas;
  form1.ComboBox1.Enabled:=false;
  form1.RadioButton1.Enabled:=false;
  form1.RadioButton2.Enabled:=false;
  form1.Button5.Enabled:=false;
  form1.Button6.Enabled:=false;
  form1.Button7.Enabled:=false;
  for i:=1 to s do
     with Form1.Image1.Canvas do
       begin
         if (x[i].DrawInt<>0) and (i<>1) then Sleep(x[i].DrawInt);
         Pen.Color:=x[i].Color;
         Pen.Width:=x[i].Pix;
         MoveTo(x[i].StartX,x[i].StartY);
         Application.ProcessMessages;
         Sleep(x[i].Interval);
         LineTo(x[i].EndX,x[i].EndY);
       end;
  ShowMessage('Drawing processing shown successfully.');
  form1.ComboBox1.Enabled:=true;
  form1.RadioButton1.Enabled:=true;
  form1.RadioButton2.Enabled:=true;
  form1.Button6.Enabled:=true;
  form1.Button5.Enabled:=true;
  form1.Button7.Enabled:=true;
end;

//Ready To Draw.
procedure TForm1.Button4Click(Sender: TObject);
begin
  if ReadyToDraw=false then
     begin
       Button4.Caption:=btn4_str2;
       Button5.Enabled:=true;
       Button6.Enabled:=true;
       Button7.Enabled:=true;
       Edit2.Enabled:=true;
       ComboBox1.Enabled:=true;
       RadioButton1.Enabled:=true;
       RadioButton2.Enabled:=true;
       ReadyToDraw:=true;
       Image1.Enabled:=true;
       InitialCanvas;
     end;
end;

//Clear Button.
procedure TForm1.Button5Click(Sender: TObject);
begin
  InitialCanvas;
  ClearPenActs;
end;

//Save present canvas to jpg file.
procedure TForm1.Button6Click(Sender: TObject);
begin
   //SaveToJPGFile;
   RewriteCanvasByActs(PenActs,PenActsCounts);
  //RewriteCanvasByActs(PenActsCounts);
end;

//Select Color.
procedure TForm1.Button7Click(Sender: TObject);
begin
  ColorDialog1.Execute;
 // Button7.Font.Color:=ColorDialog1.Color;
end;

//ONLY 5-20 PEN PIX IS AVAILABLE.
procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if not( (strtoint(ComboBox1.Text)>=5) and (strtoint(ComboBox1.Text)<=20)) then
   ComboBox1.Text:='10';

end;

//You start to draw.


procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  TmpIntEnd:=GetTickCount;
  Tag:=1;
  GetPenState;
  NewPenActs(x,y);
  SetDrawInt(TmpIntEnd-TmpIntStart);
  Image1.Canvas.MoveTo(x,y);

end;

//You are moving the line.
procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Tag=1 then
     begin
       Image1.Canvas.LineTo(x,y);
       //Tag 1 is the middle of the line.
       FinishPenActs(x,y,1);
       NewPenActs(x,y);
     end;
end;

//You finish a line.
procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Tag:=0;
  //Tag 3 is the end of the line.
  FinishPenActs(x,y,3);
  TmpIntStart:=GetTickCount;
end;

//Select Pen or Eraser.
procedure TForm1.RadioButton1Click(Sender: TObject);
begin
  RadioButton1.Checked:=true;
  RadioButton2.Checked:=false;
  SetPenMode(RadioButton1.Checked);
end;
procedure TForm1.RadioButton2Click(Sender: TObject);

begin
  RadioButton1.Checked:=false;
  RadioButton2.Checked:=true;
  SetPenMode(RadioButton1.Checked);
end;


  {****************************************************
   Initial Network.                                   *
   We use Winsock API here.                           *
                                                      *
   ****************************************************
  }

procedure ServSocketThread;
var
  wVersionRequired:word;
  Self,Recever:TSOCKET;
  ServAddr:sockaddr_in;
  WSAData:TWSAData;
  CliAddr:SockAddr;
  CliAddrLen:integer;
  cmd:cardinal;
  ReturnVal:integer;
  Info:string;

procedure InitialWSA;
begin
  WSAStartup($0101,WSAData);
end;

procedure InitialSocket;
begin
  Self:=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
end;

procedure BindServInfo;
begin
  ServAddr.sin_family:=AF_INET;
  ServAddr.sin_port:=htons(1273);
  ServAddr.sin_addr.S_addr:=htonl(INADDR_ANY);
  bind(Self,SockAddr(ServAddr),sizeof(ServAddr));
end;

procedure StartListen;
begin
  listen(Self,1);
end;

begin
   ServSocketReady:=false;
   try
     //Initial Socket.
     InitialWSA;
     InitialSocket;
     BindServInfo;
     StartListen;
   except
     showmessage('Initial Network Failed.');
   end;
     //Yes is 6, No is 7.
   ServSocketReady:=true;

   repeat
     Recever:=accept(Self,@CliAddr,@CliAddrLen);
     recv(Recever,PlayerIP,sizeof(PlayerIP),0);
     info:='A new game request from:'+PlayerIP+', accept?';
     ReturnVal:=MessageBox(0,PWideChar(info),'New Game Request',MB_YESNO);
   until (ReturnVal=6) or (ServMode=false);

   //end;
end;

procedure CliSocketThread;
begin

end;

//Initial!Program run from here.
procedure TForm1.FormCreate(Sender: TObject);
begin
  ServMode:=true;
  ReadyToDraw:=false;
  ComboBox1.Text:='10';
  PenActsCounts:=0;
  ServSocketHandle:=CreateThread(nil,0,@ServSocketThread,nil,0,ServSocketID);
  CliSocketHandle:=CreateThread(nil,0,@CliSocketThread,nil,0,CliSocketID);
end;

end.


