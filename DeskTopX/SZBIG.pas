{Module Name:SZBIG

Author:Grant Liu

This is the Stocks Big Image form(SZ) of DesktopX.

History:
Build1100: 2012-8-26

}





unit SZBIG;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,shellapi;

type
  TForm3 = class(TForm)
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
  Form3: TForm3;

implementation

uses main;

{$R *.dfm}

procedure TForm3.Button2Click(Sender: TObject);
begin
  form3.hide;
  form1.show;
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
 ShellExecute(0,nil,pchar('http://finance.sina.com.cn/stock/'),nil,nil,1);
end;
end.
