{Module Name:ClockMou

Author:Grant Liu

This is the Time and Date Service DLL of DesktopX.

History:
Build1151: 2012-9-9                *Add Week-Display function.
Build1100: 2012-8-26

}




library ClockMou;


uses
  SysUtils,
  Classes,
  mmsystem,
  dateutils;


const
  ver=1151;
var
  HourSave:integer;
{$R *.res}




function GetDate:widestring;
begin
  result:=formatdatetime('yyyy-mm-dd',now);
end;

function GetWeek:widestring;
var
  num:word;
begin
  num:=DayOfWeek(Now);
  result:=extractfilepath(paramstr(0))+'WeekPics\'+widestring(inttostr(num))+'.bmp';
end;

function GetTime(CBeepEna:boolean;CBeepStart,CBeepEnd:integer):widestring;
var
  hh,mm,ss:integer;
begin
  hh:=strtoint(formatdatetime('hh',now));
  mm:=strtoint(copy(formatdatetime('hh:mm:ss',now),4,2));
  ss:=strtoint(formatdatetime('ss',now));
  if (mm=0) and (hh<>HourSave) and (CBeepEna=true) and (hh>=CBeepStart) and (hh<=CBeepEnd) then
    begin
      //Check whether to play beep wav.
      HourSave:=hh;
      playsound(pchar('wav\'+inttostr(hh)+'.wav'),0,1);
    end;
 result:=formatdatetime('hh:mm:ss',now);
end;

function GetDllVer:integer;
begin
  result:=ver;
end;

exports
  GetDate,GetTime,GetWeek,GetDllVer;

begin
  HourSave:=-1;
end.
