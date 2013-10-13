unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    Button2: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    ProgressBar1: TProgressBar;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
{$I-}
 type
  //General Structure
  strtype=string[252];
  datestr=string[12]; //11!

  info=packed record   //520!!
    datatype:strtype;  //FILE OR DIR*
    dest:strtype;
    readsize:int64;

  end;
var
  coreid,corehandle:cardinal;





procedure TForm1.Button1Click(Sender: TObject);

var
  opener:tfilestream;
  createtime:datestr;
  usbid,root,destdic,indpath:strtype;
  tmpinfo:info;
  indfile:textfile;
  tmpstream:tfilestream;
  posi,nowposi:int64;
  i:integer;

begin
  assignfile(indfile,form1.edit1.text);
  reset(indfile);
  readln(indfile,usbid);
  readln(indfile,createtime);
  i:=length(form1.edit1.Text);

  while form1.Edit1.text[i]<>'\' do
      dec(i);

  indpath:=copy(form1.edit1.text,1,i);

  

  if not fileexists(indpath+usbid+'_'+createtime+'.CF') then showmessage('CF文件不存在!')
  else
    begin
  form1.button1.Enabled:=false;
  form1.button2.Enabled:=false;
  opener:=tfilestream.Create(usbid+'_'+createtime+'.CF',fmopenread);
  root:=usbid+'_'+createtime;
  form1.progressbar1.Max:=opener.size;
 nowposi:=0;

 createdirectory(pchar(usbid+'_'+createtime),nil);
 while not eof(indfile) do
    begin
      readln(indfile,tmpinfo.datatype);
      if tmpinfo.datatype='DIR*' then
        begin
          readln(indfile,destdic);
          createdirectory(pchar(root+destdic),nil);
        end;
      if tmpinfo.datatype='FILE' then
        begin
          readln(indfile,posi);
          readln(indfile,tmpinfo.readsize);
          readln(indfile,tmpinfo.dest);

          form1.label3.Caption:=tmpinfo.dest;

          opener.Seek(posi,sofrombeginning);
          try
          if fileexists(root+tmpinfo.dest) then tmpstream:=tfilestream.create(root+tmpinfo.dest,fmopenwrite)
                                           else tmpstream:=tfilestream.Create(root+tmpinfo.dest,fmcreate);
          tmpstream.CopyFrom(opener,tmpinfo.readsize);
          freeandnil(tmpstream);
          except
            showmessage(root+tmpinfo.dest+'展开失败!');
          end;

          nowposi:=nowposi+tmpinfo.readsize;
          form1.progressbar1.Position:=nowposi;
        end;
        application.processmessages;
    end;

  freeandnil(opener);
  closefile(indfile);
  showmessage('展开完成!');
  form1.progressbar1.Position:=0;
  form1.label3.Caption:='';
  form1.button2.Enabled:=true;

  end;
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
  button1.enabled:=false;
  button2.enabled:=true;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  opendialog1.filter:='index文件(*.index)|*.index';
  opendialog1.Execute;
  edit1.text:=opendialog1.FileName;
  button1.Enabled:=true;
end;

end.
