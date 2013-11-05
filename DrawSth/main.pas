unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,JPEG;

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

procedure GetPenState;
begin
  with form1 do
    begin
      Image1.Canvas.Pen.Color:=clred;
      Image1.Canvas.Pen.Width:=strtoint(ComboBox1.text);
      Image1.Canvas.Pen.Color:=ColorDialog1.Color;
    end;
end;

procedure InitialCanvas;
begin
  with form1 do
    begin
      Image1.Canvas.Pen.Color:=clwhite;
      Image1.Canvas.FillRect(Image1.Canvas.ClipRect);
      GetPenState;
    end;
end;

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
  SaveToJPGFile;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  ColorDialog1.Execute;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ReadyToDraw:=false;

end;



procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Tag:=1;
  GetPenState;
  Image1.Canvas.MoveTo(x,y);
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Tag=1 then
     Image1.Canvas.LineTo(x,y);
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Tag:=0;
end;

end.
