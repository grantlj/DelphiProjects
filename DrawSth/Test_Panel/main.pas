unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Button2: TButton;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    ComboBox1: TComboBox;
    Button3: TButton;
    ColorDialog1: TColorDialog;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


 const
  MAX_STEPS=80000;

 type
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

  TGAMEINFO=record
    PenActs:TACTS;
    s:longint;
    key:String[15];
  end;
var
  Form1: TForm1;
  AllowDraw:boolean;
   PenActs:TACTS;
  PenActsCounts:longint;
  TmpPenStart,TmpPenEnd:int64;
  TmpIntStart,TmpIntEnd:int64;

implementation

{$R *.dfm}
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

procedure InitialCanvas;
begin
      with form1 do
       begin
      Image1.Enabled:=true;
      Image1.Canvas.Pen.Color:=clwhite;
      Image1.Canvas.FillRect(Image1.Canvas.ClipRect);
      SetPenMode(RadioButton1.Checked);
      Image1.Canvas.Pen.Color:=clblack;
      ComboBox1.Text:='10';
      Image1.Canvas.Pen.Width:=strtoint(ComboBox1.Text);
       end;
end;
procedure TForm1.Button1Click(Sender: TObject);
begin
  InitialCanvas;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  f:textfile;
  i,counts:longint;
  x:TACTS;
  ques:string;
begin

  assignfile(f,'info.dat');
  rewrite(f);
  x:=PenActs;
  counts:=PenActsCounts;
  writeln(f,counts);

 for i:=1 to counts do
    begin
      writeln(f,x[i].DrawInt);
      writeln(f,x[i].Color);
      writeln(f,x[i].Pix);
      writeln(f,x[i].StartX);writeln(f,x[i].StartY);
      writeln(f,x[i].Interval);
      writeln(f,x[i].EndX);writeln(f,x[i].EndY);
    end;
  writeln(f,'I do love you.');
  closefile(f);
  showmessage('ok!');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  ColorDialog1.Execute;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   Tag:=0;
   ComboBox1.Text:='10';
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
  TmpIntStart:=GetTickCount
end;

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

end.
