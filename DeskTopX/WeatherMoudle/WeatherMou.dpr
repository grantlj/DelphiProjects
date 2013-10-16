{Module Name:WeatherMou

Author:Grant Liu

This is the Weather Service DLL of DesktopX.

History:
Build1100: 2012-8-26
Bulid1201: 2013-10-16           *Repair the error when DesktopX doesent run
                                 with admin privilege.

}
library WeatherMou;
uses
  wininet,
  SysUtils,
  Classes,
  urlmon;

type
  TWeatherRec=record
    bool:boolean;
    Wea,temp,wind:widestring;
  end;

const
  Ver=1201;
{$R *.res}

//GET WEATHER FORM IP138.
function GetWeather(Province,City:widestring):TweatherRec;
var
  f1:textfile;
  bool:boolean;
  x,url:string;
  p1,p2:integer;
  TmpSavePath:string;
  WeatherRec:TWeatherRec;
begin
  province:=lowercase(province);
  city:=lowercase(city);
  //VERY IMPORTANT. SOME CITIES DONT BELONG TO ANY PROVINCES!!!
  if (province='beijing') or (province='shanghai')
    or (province='chongqing') or (province='tianjin')
    or (province='xianggang') or (province='aomen')
  then url:='http://qq.ip138.com/weather/'+Province+'/index.htm'
  else url:='http://qq.ip138.com/weather/'+Province+'/'+city+'.htm';
  deleteurlcacheentry(pchar(url));
  WeatherRec.bool:=false;
  TmpSavePath:='WeatherTmp.htm';
  bool:=urldownloadtofile(nil,pchar(url),pchar(TmpSavePath),0,nil)=0;
  if not((bool=false) or (not(fileexists(TmpSavePath)))) then
   begin
     assignfile(f1,TmpSavePath);
     reset(f1);
     while pos('<td align="center">天气</td>',x)=0 do
      readln(f1,x);
     readln(f1,x);
     p1:=pos('<br/>',x);
     p2:=pos('</td>',x);
     WeatherRec.wea:=copy(x,p1+5,p2-p1-5)+' ';

     while pos('<td align="center">气温</td>',x)=0 do
       readln(f1,x);
     readln(f1,x);
     p1:=pos('<td>',x);
     p2:=pos('</td>',x);
     WeatherRec.temp:=copy(x,p1+4,p2-p1-4)+' ';

    while pos('<td align="center">风向</td>',x)=0 do
       readln(f1,x);
     readln(f1,x);
     p1:=pos('<td>',x);
     p2:=pos('</td>',x);
     WeatherRec.wind:=copy(x,p1+4,p2-p1-4);
     closefile(f1);
     deletefile(TmpSavePath);
     WeatherRec.bool:=true;

  end;
  result:=WeatherRec;
end;

function GetDllVer:integer;
begin
  result:=Ver;
end;

exports
  GetDllVer,
  GetWeather;

begin
end.

