unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.OleCtrls, SHDocVw,
  Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    WebBrowser1: TWebBrowser;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Timer1: TTimer;
    Image1: TImage;
    Memo1: TMemo;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure WebBrowser1DownloadBegin(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure WebBrowser1DocumentComplete(ASender: TObject;
      const pDisp: IDispatch; const URL: OleVariant);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  site:integer;
  loadok:boolean;

implementation

{$R *.dfm}
procedure doGo;
var
  s:WideString;
begin
  sleep(200);
  s:='http://xk'+inttostr(site)+'.cqupt.edu.cn/xk2013/kebiao.php';
  form1.Label2.Caption:=s;
  try
    form1.Webbrowser1.Navigate(s);
    form1.WebBrowser1.Visible:=false;
  except

  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 halt;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  beep;
end;

procedure TForm1.WebBrowser1DocumentComplete(ASender: TObject;
  const pDisp: IDispatch; const URL: OleVariant);
var
  doc:Variant;
  memo:TMemo;
begin
  doc:=Webbrowser1.Document;
  memo1.Text:=doc.body.innerhtml;
  if pos('Error',memo1.Text)<>0 then
    begin
      site:=(site mod 6)+1;
      doGo;
    end
  else  if (loadok=false) then

    begin
       loadok:=true;
       timer1.enabled:=true;
       form1.WebBrowser1.Visible:=false;
       showmessage('Connected!!!');
       button1.Caption:='Stop beep';
       button1.Enabled:=true;
    end;
end;

procedure TForm1.WebBrowser1DownloadBegin(Sender: TObject);
begin
  label1.caption:='loading site:'+inttostr(site);
end;





procedure TForm1.Button1Click(Sender: TObject);
begin
  if button1.Caption='Stop beep' then
    begin
      button1.Caption:='Run';
      button1.Enabled:=true;
      timer1.Enabled:=false;
    end
  else
    begin
      loadok:=false;
      button1.Enabled:=false;
      site:=1;
      doGo;
    end;
end;

end.
