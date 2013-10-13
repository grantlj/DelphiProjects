{Module Name:SHBIG

Author:Grant Liu

This is the Stocks Big Image form(SH) of DesktopX.

History:
Build1100: 2012-8-26

}




unit SHBIG;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,Shellapi;

type
  TForm2 = class(TForm)
    Image1: TImage;
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses main;

{$R *.dfm}

procedure TForm2.Button2Click(Sender: TObject);
begin
  Form2.Hide;
  form1.show;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
 ShellExecute(0,nil,pchar('http://finance.sina.com.cn/stock/'),nil,nil,1);
end;

end.
