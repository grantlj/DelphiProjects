{Module Name:StockMou

Author:Grant Liu

This is the Stock Service DLL of DesktopX.

History:
Build1101: 2012-9-4              *fix a small bug in function: GetSZStockGIF
Build1100: 2012-8-26

}

library StockMou;


uses
  Wininet,
  urlmon,
  SysUtils,
  Classes;
const
  ver=1101;
{$R *.res}


//Get stock gifs from SINA API.
function GetSHStockGIF(path:widestring):boolean;
var
  bool:boolean;
begin
  DeleteUrlCacheEntry(pchar('http://image.sinajs.cn/newchart/min/n/sh000001.gif'));
  bool:=urldownloadtofile(nil,pchar('http://image.sinajs.cn/newchart/min/n/sh000001.gif'),pchar(widechartostring(pwidechar(path))+'sh.gif'),0,nil)=0;
  if fileexists(path+'sh.gif') and (bool=true) then result:=true
                                           else begin  result:=false;end;
end;

function GetSZStockGIF(path:widestring):boolean;
var
  bool:boolean;
begin
  deleteurlcacheentry(pchar('http://image.sinajs.cn/newchart/min/n/sz399001.gif'));
  bool:=urldownloadtofile(nil,pchar('http://image.sinajs.cn/newchart/min/n/sz399001.gif'),pchar(widechartostring(pwidechar(path))+'sz.gif'),0,nil)=0;
  if fileexists(path+'sz.gif') and (bool=true) then result:=true
                                           else begin result:=false;end;
end;

function GetDllVer:integer;
begin
  result:=ver;
end;

exports
  GetDllVer,
  GetSHStockGIF,
  GetSZStockGIF;
begin
end.
