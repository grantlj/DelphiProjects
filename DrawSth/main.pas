{Project Name   : DrawSth
 Version        : 1.0
 Project Start  : 2013/11/5
 Project Finish : 2013/11
 Author         : Grant Liu
 Design for Ivy Hu.
}
unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,JPEG;
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
    Image1: TImage;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    ColorDialog1: TColorDialog;
    Button7: TButton;
    ComboBox1: TComboBox;
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
  DefaultPenPix=15;

var
  PenActs:TACTS;
  PenActsCounts:longint;
  TmpPenStart,TmpPenEnd:int64;
  TmpIntStart,TmpIntEnd:int64;

//GetPenState is to refresh the PenState.
procedure GetPenState;
begin
  with form1 do
    begin
      Image1.Canvas.Pen.Width:=strtoint(ComboBox1.text);
      Image1.Canvas.Pen.Color:=ColorDialog1.Color;
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
      Image1.Canvas.Pen.Color:=clwhite;
      Image1.Canvas.FillRect(Image1.Canvas.ClipRect);
      GetPenState;
    end;
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
procedure RewriteCanvasByActs(x:TACTS;s:longint);
var
  i:longint;
begin
  InitialCanvas;

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
end;



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
       ReadyToDraw:=true;
       Image1.Enabled:=true;
       InitialCanvas;
     end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  InitialCanvas;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  //SaveToJPGFile;
    RewriteCanvasByActs(PenActs,PenActsCounts);
  //RewriteCanvasByActs(PenActsCounts);
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  ColorDialog1.Execute;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ReadyToDraw:=false;
  PenActsCounts:=0;
end;



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

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Tag:=0;
  //Tag 3 is the end of the line.
  FinishPenActs(x,y,3);
  TmpIntStart:=GetTickCount;
end;

end.
