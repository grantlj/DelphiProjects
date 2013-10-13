program QQT;

uses
  Forms,windows,sysutils,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}

begin
  //application.Title:='shit';
  //if findwindow(nil,pansichar('QQT'))=0 then begin
  //application.title:='QQT';
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  application.showmainform:=false;
  Application.Run;



end.
