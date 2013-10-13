program DXMain;

uses
  dialogs,
  windows,
  Forms,
  main in 'main.pas' {Form1},
  GIFImage in 'TGIFImage.v.2.2.D7\GIFImage.pas',
  SHBIG in 'SHBIG.pas' {Form2},
  SZBIG in 'SZBIG.pas' {Form3},
  setting in 'setting.pas' {Form4},
  Memo in 'Memo.pas' {Form5};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.
