{Module Name:Main

Author:Grant Liu

This is the main form of DesktopX.

History:
Build1201: 2013-6-15                       *Project Restart!
                                           *Add Memo Function.
                                           *Fix bugs.
Build1151: 2012-9-9                        *Add Week-Display function.
                                           *Repair a bug in News-Display.
Build1101: 2012-9-4                        *Fix a bug in GS.
Build1100: 2012-8-26
Build1201: 2013-10-16                      *Rebuild with DELPHI XE5.
                                           *Dont need Administrator Privilege
                                            anymore.
}
unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,SHBIG,inifiles,setting,registry,shellapi,
  jpeg, Menus,dateutils,Memo,GIFImg;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    GroupBox3: TGroupBox;
    Button3: TButton;
    Button4: TButton;
    Timer1: TTimer;
    Timer2: TTimer;
    Image1: TImage;
    Timer3: TTimer;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Edit1: TEdit;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Image14: TImage;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    DesktopX1: TMenuItem;
    Label6: TLabel;
    Timer4: TTimer;
    Image15: TImage;
    Button1: TButton;
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure Image6Click(Sender: TObject);
    procedure Image7Click(Sender: TObject);
    procedure Image8Click(Sender: TObject);
    procedure Image9Click(Sender: TObject);
    procedure Image10Click(Sender: TObject);
    procedure Image11Click(Sender: TObject);
    procedure Image12Click(Sender: TObject);
    procedure Image13Click(Sender: TObject);
    procedure Image14Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure myminimize(var msg:TWMSYSCOMMAND);message wm_syscommand;
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure DesktopX1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image6MouseEnter(Sender: TObject);
    procedure Image1MouseEnter(Sender: TObject);
    procedure Image2MouseEnter(Sender: TObject);
    procedure Label6MouseEnter(Sender: TObject);
    procedure Timer4Timer(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure Label6MouseLeave(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  


  private
    { Private declarations }
  public
    { Public declarations }
    province,city:widestring;
    CBeepStart,CBeepEnd:integer;
    AutoStart,CBeepEna:boolean;
    timer2org,timer3org:integer;
  end;

var
  Form1: TForm1;
  ClockH,WeatherH,StockH,NewsH,GUH,UpdateH:cardinal;
  SHBIGEna,SZBigEna,NewsEna,AutoUpdate,ballooned:boolean;
  GScount:int64;
  Province,City:widestring;
  weburl:string;
  CBeepStart,CBeepEnd,FailInterval:integer;

implementation

uses SZBIG;

{$R *.dfm}

//Rewrite the Minimize Button in order for the TrayIcon Function.
procedure tform1.myminimize(var msg:TWMSYSCOMMAND);
begin 
  if msg.CmdType=sc_minimize then
        begin       
          trayicon1.Visible:=true;
          if ballooned=false then begin trayicon1.showballoonhint;ballooned:=true;end;
          form1.hide;
        end 
    else inherited;
end; 


procedure TForm1.N1Click(Sender: TObject);
begin
  halt;
end;

//Quick Restrat and Shutdown function here. Use winexec to run command.
procedure TForm1.N2Click(Sender: TObject);
begin
   winexec(pansichar('shutdown -r -t 0'),sw_hide);
end;

procedure TForm1.N3Click(Sender: TObject);
begin
   winexec(pansichar('shutdown -s -t 0'),sw_hide);
end;

//======================================================
//======================================================
//==============BASIC FUNCTION START====================
//======================================================
//======================================================



//Get Weather Moudle.
procedure GW;
type
  TWeatherRec=record
    bool:boolean;
    Wea,temp,wind:widestring;
  end;
  TMGetWeather=function(Province,City:widestring):TWeatherRec;
var
  MGetWeather:TMGetWeather;
  WeatherRec:TWeatherRec;
  fbitmap:tbitmap;
begin
  @MGetWeather:=GetProcaddress(WeatherH,pchar('GetWeather'));
  WeatherRec:=MGetWeather(Province,City);
  if WeatherRec.bool=true then
    begin
      //Success to get weather.
      form1.timer2.interval:=form1.timer2org;
      form1.label3.Visible:=true;form1.Label4.Visible:=true;form1.Label5.visible:=true;
      form1.Image3.Visible:=false;
      form1.label3.Caption:=WeatherRec.Wea;
      form1.label4.Caption:=WeatherRec.temp;
      form1.label5.Caption:=WeatherRec.wind;
    end
  Else
    begin
    //Fail to get weather;
    form1.Timer2.interval:=FailInterval;
    form1.label3.Visible:=false;
    form1.Label4.Visible:=false;
    form1.Label5.visible:=false;
    form1.Image3.visible:=true;
    FBitmap:=TBitmap.Create;
    fbitmap.LoadFromFile(extractfilepath((paramstr(0)))+'WeaFail.bmp');
    form1.Image3.Picture.Bitmap.Assign(FBitmap);
    fbitmap.Free;
    end;
end;


//Get Time and Date Moudle.
procedure GTD;
type
  TMGetDate=function:widestring;
  TMGetWeek=function:widestring;
  TMGetTime=function(CBeepEna:boolean;CBeepStart,CBeepEnd:integer):widestring;
var
  MGetDate:TMGetDate;
  MGetTime:TMGetTime;
  MGetWeek:TMGetWeek;
  MDate,MTime,WeekPicPath:widestring;
begin
  @MGetDate:=getprocaddress(ClockH,pchar('GetDate'));
  @MGetTime:=getprocaddress(ClockH,'GetTime');
  @MGetWeek:=getprocaddress(ClockH,'GetWeek');
  WeekPicPath:=MGetWeek;
  MDate:=MGetDate;
 //We need CBeeps to tell weather the Beep Function is available.
  MTime:=MGetTime(form1.CBeepEna,form1.CBeepStart,form1.CBeepEnd);
  form1.label1.Caption:=MDate;
  form1.label2.Caption:=MTime;
  form1.Image15.Picture.bitmap.loadfromfile(widechartostring(pwidechar(WeekPicPath)));
end;

//Get Stocks inforamtion function.
procedure GS;
type
  TMGetStockGIF=function(path:widestring):bool;
var
  MGetSHStockGIF,MGetSZStockGIF:TMGetStockGIF;
  Fbitmap:tbitmap;
  FGif:tgifimage;
begin

  inc(GSCount);
  @MGetSHStockGIF:=getprocaddress(StockH,pchar('GetSHStockGIF'));
  @MGetSZStockGIF:=getprocaddress(StockH,pchar('GetSZStockGIF'));

  if MGetSHStockGIF(extractfilepath((paramstr(0)))) then
    begin
      form1.timer3.interval:=form1.timer3org;
      fgif:=tgifimage.Create;
      fgif.LoadFromFile('sh.gif');
      FBitmap:=TBitmap.Create;
      FBitmap.Assign(FGif);
      form1.Image1.Picture.Bitmap.Assign(FBitmap);
      if form1.timer3.enabled=true then form2.Image1.Picture.Bitmap.Assign(FBitmap);
      fbitmap.Free;
      FGif.Free;
      //SHBig Form must be set to shown after the first turn.
      if GSCount>1 then SHBigEna:=true;

    end
  else
    begin
      form1.Timer3.interval:=FailInterval;
      SHBigEna:=false;
      FBitmap:=TBitmap.Create;
      fbitmap.LoadFromFile(extractfilepath((paramstr(0)))+'SHFail.bmp');
      form1.Image1.Picture.Bitmap.Assign(FBitmap);
      //If failed, disappear BIG at once.
      //WARNING: THERE USED TO BE A BUG HERE. SOMETIMES FORM2/3 HAVEN'T BEEN CREATED!
      if GScount>1 then form2.hide;
      fbitmap.Free;
    end;

  if MGetSZStockGIF(extractfilepath((paramstr(0)))) then
    begin
      form1.timer3.interval:=form1.timer3org;
      fgif:=tgifimage.Create;
      fgif.LoadFromFile('sz.gif');
      FBitmap:=TBitmap.Create;
      FBitmap.Assign(FGif);
      form1.Image2.Picture.Bitmap.Assign(FBitmap);
      if form1.Timer3.enabled=true then form3.Image1.Picture.Bitmap.Assign(FBitmap);
      fbitmap.Free;
      FGif.Free;
      if GScount>1 then SZBigEna:=true;
    end
  else
    begin
      form1.Timer3.interval:=FailInterval;
      SZBigEna:=false;
      FBitmap:=TBitmap.Create;
      fbitmap.LoadFromFile(extractfilepath((paramstr(0)))+'SZFail.bmp');
      form1.Image2.Picture.Bitmap.Assign(FBitmap);
      if GScount>1 then form3.hide;
      fbitmap.Free;
    end;
end;

//Get News Function.
procedure GN;
type
   TNewsRec=record
    NewsTitle:widestring;
    NewsUrl:widestring;
  end;
  TNewsArr=array[1..100] of TNewsRec;
  TMGetNews=function:integer;
var
  MGetNews:TMGetNews;
  sturl,sttitle:string;
  NewsRecNum:integer;
  f:textfile;
  i: Integer;
begin
  @MGetNews:=GetProcAddress(NewsH,pchar('GetNews'));
  NewsRecNum:=MGetNews;
  //NewsRecNum:-1 is failed. other number is the lines.
  if NewsRecNum<>-1 then
    begin
      assignfile(f,'NewsList.list');
      reset(f);
      for i := 1 to NewsRecNum-1 do
        begin
          readln(f);
          readln(f);
        end;
      readln(f,sturl);
      readln(f,sttitle);
      closefile(f);
      NewsEna:=true;
      form1.label6.caption:=sttitle;
      weburl:=sturl;
    end
  else
    begin
      NewsEna:=false;
      form1.label6.caption:='';
      weburl:='';
    end;

end;

//Get Update Fucntion.
procedure GU;
type
  TMCheckUpdate=procedure;
var
  MCheckUpdate:TMCheckUpdate;
begin
  @MCheckUpdate:=GetProcAddress(UpdateH,pchar('CheckUpdate'));
  MCheckUpdate;
end;

//======================================================
//======================================================
//==============BASIC FUNCTION END======================
//======================================================
//======================================================

//Program Init.
procedure Init;
type
  TMGetDllVer=function:integer;

  TSetting=record
    WeaInterval:integer;
    province,city:widestring;
    stockinterval:integer;
    autoupdate:0..1;
  end;

var
  MGetDllVer:TMGetDllVer;
  handle:cardinal;
  MoudleNum,i,ver:integer;
  Moudle:array[1..5] of string;

//Add itself to startup.
procedure addtostartup(exename,savepath:string);
var
  Reg:TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  Try
    RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\MicroSoft\Windows\CurrentVersion\Run',true) then
        Reg.WriteString(exename,savepath);
  finally
    Reg.Free;
  end;
end;                                

//remove itself from startup.
procedure removestartup(exename,savepath:string);
var
  Reg:TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  Try
    RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\MicroSoft\Windows\CurrentVersion\Run',true) then
       Reg.DeleteValue(exename);
  finally
    Reg.Free;
  end;
end;

//Load ini information.
procedure Getsetting;
var
  ini:tinifile;
  int:integer;
  str:widestring;
  bool:boolean;
begin
  ini:=tinifile.Create(extractfilepath(paramstr(0))+'setting.ini');
  try
      int:=ini.ReadInteger('Weather','WeatherInterval',10);
      form1.Timer2.Interval:=int*60*1000;
      form1.timer2org:=int*60*1000;

      int:=ini.ReadInteger('Stock','StockInterval',30);
      form1.Timer3.Interval:=int*1000;
      form1.timer3org:=int*1000;

      str:=ini.ReadString('Weather','Province','jiangsu');
      province:=str;
      form1.province:=str;
      str:=ini.readstring('Weather','City','nanjing');
      city:=str;
      form1.city:=str;

      bool:=ini.readbool('Clock','CBeepEna',true);
      form1.CBeepEna:=bool;

      int:=ini.readinteger('Clock','CBeepStart',8);
      CBeepStart:=int;
      form1.CBeepStart:=int;

      int:=ini.ReadInteger('Clock','CBeepEnd',22);
      CBeepEnd:=int;
      form1.CBeepEnd:=int;

      bool:=ini.ReadBool('System','AutoStart',true);
      form1.AutoStart:=bool;
      if bool=true then
        begin
          addtostartup('DesktopX',application.exename);
        end
      else
        begin
          try
            removestartup('DesktopX',application.exename);
          except
          end;
        end;
     ini.Free;

  except
    showmessage('未找到程序配置文件，请尝试重新安装本程序！');
    halt;
  end;
end;




begin

  GetSetting;
  ballooned:=false;
  FailInterval:=3000;
  MoudleNum:=5;
  Moudle[1]:='ClockMou.dll';
  Moudle[2]:='WeatherMou.dll';
  Moudle[3]:='StockMou.dll';
  Moudle[4]:='NewsMou.dll';
  Moudle[5]:='UpdateMou.dll';
  //Check DLLVersion.It seems its NO-NEED.
{  for i:=1 to MoudleNum do
    begin
      handle:=loadlibrary(pchar(moudle[i]));
      @MGetDLLVer:=getprocaddress(handle,'GetDllVer');
      ver:=MGetDllVer;
      FreeLibrary(handle);
    end; }

  form1.GroupBox2.caption:='天气:'+province+' '+city;

  //Load all Librarys.
  ClockH:=Loadlibrary(pchar('ClockMou.dll'));
  WeatherH:=Loadlibrary(pchar('WeatherMou.dll'));
  StockH:=LoadLibrary(pchar('StockMou.dll'));
  NewsH:=loadlibrary(pchar('NewsMou.dll'));
  UpdateH:=Loadlibrary(pchar('UpdateMou.dll'));
  //Start Basic Function.
  GTD;
  GW;
  GSCount:=0;
  GS;
  //VERY IMPORTANT. THE GETUPDATE FUNCTION WILL USE UP ALL THREAD RESOURCES IF IT'S
  //NOT ANOTHER THREAD!!

  createthread(nil,0,@GU,nil,0,GUH);
  form1.Timer1.Enabled:=true;
  form1.Timer2.Enabled:=true;
  form1.Timer3.Enabled:=true;
  form1.timer4.Enabled:=true;

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  halt;
end;

procedure TForm1.DesktopX1Click(Sender: TObject);
begin
  form1.show;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  init;
end;







procedure TForm1.FormShow(Sender: TObject);
begin
  trayicon1.Visible:=false;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  GTD;
end;



procedure TForm1.Timer2Timer(Sender: TObject);
begin
  GW;
end;


procedure TForm1.Timer3Timer(Sender: TObject);
begin
  GS;
end;


procedure TForm1.Timer4Timer(Sender: TObject);
begin
  GN;
end;

procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
  form1.show;

end;

//Quick Open webpages function here.
procedure TForm1.Image10Click(Sender: TObject);
begin
     shellexecute(0,nil,pchar('http://renren.com'),nil,nil,1);
end;

procedure TForm1.Image11Click(Sender: TObject);
begin
  shellexecute(0,nil,pchar('http://www.baidu.com.cn'),nil,nil,1);
end;

procedure TForm1.Image12Click(Sender: TObject);
begin
  shellexecute(0,nil,pchar('http://www.taobao.com.cn'),nil,nil,1);
end;

procedure TForm1.Image13Click(Sender: TObject);
begin
  shellexecute(0,nil,pchar('http://www.msn.com.cn'),nil,nil,1);
end;

procedure TForm1.Image14Click(Sender: TObject);
begin
  shellexecute(0,nil,pchar('http://www.163.com'),nil,nil,1);
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  if (SHBigEna=true) then
   begin
  //form1.hide;
  form2.show;
  end;
end;

procedure TForm1.Image1MouseEnter(Sender: TObject);
begin
  if SHBIGEna then begin image1.cursor:=crhandpoint;image1.showhint:=true;end
              else begin image1.cursor:=crdefault;image1.showhint:=false;end;
  
end;

procedure TForm1.Image2Click(Sender: TObject);
begin
  if (SZBigEna=true) then
  begin
  //form1.Hide;
  form3.show;
  end;
end;

procedure TForm1.Image2MouseEnter(Sender: TObject);
begin
  if SZBIGEna then begin image2.cursor:=crhandpoint;image2.showhint:=true;end
              else begin image2.cursor:=crdefault;image2.showhint:=false;end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  form5.show;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  form4.Show;
  form1.Hide;
end;

//Quick Restart and SHUTDOWN.
procedure TForm1.Image4Click(Sender: TObject);
begin
  winexec(pansichar('shutdown -s -t 0'),sw_hide);
end;

procedure TForm1.Image5Click(Sender: TObject);
begin
  winexec(pansichar('shutdown -r -t 0'),sw_hide);
end;

//Quick Search function.
procedure TForm1.Image6Click(Sender: TObject);
var
  s1,s2,url:string;
  p:boolean;
  i:integer;
begin
  if edit1.text<>'' then begin
  s2:='';
  s1:=edit1.text;
  p:=false;
  //We must generate the URL!!
  for i:=1 to length(s1) do
    begin
      if (s1[i]=' ') then
          if p=false then begin s2:=s2+'+';p:=true;end;
      if s1[i]<>' ' then begin p:=false;s2:=s2+s1[i];end;
    end;
  url:='http://baidu.com/s?wd='+s2;
  edit1.text:='';
  ShellExecute(0,nil,pchar(url),nil,nil,1);
  end;
end;

procedure TForm1.Image6MouseEnter(Sender: TObject);
begin
  if edit1.text<>'' then begin image6.Cursor:=crhandpoint;image6.showhint:=true;end
                    else begin image6.cursor:=crdefault;image6.showhint:=false;end;

end;

procedure TForm1.Image7Click(Sender: TObject);
begin
  shellexecute(0,nil,pchar('http://www.sina.com.cn'),nil,nil,1);
end;

procedure TForm1.Image8Click(Sender: TObject);
begin
  shellexecute(0,nil,pchar('http://www.ifeng.com'),nil,nil,1);
end;

procedure TForm1.Image9Click(Sender: TObject);
begin
shellexecute(0,nil,pchar('http://www.qq.com.cn'),nil,nil,1);
end;

procedure TForm1.Label6Click(Sender: TObject);
begin
  shellexecute(0,nil,pchar(weburl),nil,nil,1);
end;

procedure TForm1.Label6MouseEnter(Sender: TObject);
begin
  timer4.Enabled:=false;
  if NewsEna then
    begin
      label6.showhint:=true;
      label6.Cursor:=crhandpoint;
    end
  else
    begin
       label6.showhint:=false;
       label6.cursor:=crdefault;
    end;
end;

procedure TForm1.Label6MouseLeave(Sender: TObject);
begin
  timer4.enabled:=true;
  GN;
end;

end.
