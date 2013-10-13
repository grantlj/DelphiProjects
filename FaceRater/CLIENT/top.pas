unit top;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,jpeg, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Image1: TImage;
   
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  form1.Hide;
end;


procedure TForm1.FormShow(Sender: TObject);
var
  f:textfile;
  st1,st2:string;
  x:string;
begin
  assignfile(f,extractfilepath(paramstr(0))+'\'+'SORTED.TXT');
  reset(f);
  readln(f,st1);
  form1.caption:='红人榜（更新时间:'+st1+'）';
  while not eof(f) do
   begin
     readln(f,st1);
     readln(f,st2);
     listbox1.Items.Add(st1+'     得票：'+st2);
   end;
  closefile(f);
  listbox1.itemindex:=0;
   x:=copy(listbox1.items.strings[listbox1.itemindex],1,13);
  x:=extractfilepath(paramstr(0))+'\'+'FACES'+'\'+x+'.jpg';
  image1.Picture.LoadFromFile(x);
end;

procedure TForm1.ListBox1Click(Sender: TObject);
var
  x:string;
begin
  x:=copy(listbox1.items.strings[listbox1.itemindex],1,13);
  x:=extractfilepath(paramstr(0))+'\'+'FACES'+'\'+x+'.jpg';
  image1.Picture.LoadFromFile(x);
  
end;

end.
