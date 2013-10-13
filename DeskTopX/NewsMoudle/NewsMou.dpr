{Module Name:NewsMou

Author:Grant Liu

This is the News Service DLL of DesktopX.

History:
Build1100: 2012-8-26

}


library NewsMou;
uses
  SysUtils,
  Classes,
  windows,
  IdBaseComponent,
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  IdHTTP;

{$R *.res}
const
  ver=1100;
type
  TNewsRec=record
    NewsTitle:widestring;
    NewsUrl:widestring;
  end;
  TNewsArr=array[1..100] of TNewsRec;

var
  NewsArr:TNewsArr;
  NewsCount,NewsFlag:integer;
  threading:boolean;
  getnewslistid:cardinal;

function GetDllVer:integer;
begin
   result:=ver;
end;

procedure GetNewsList;
var
  NewsHttp:tidhttp;
  NewsLists:tstringlist;
  f,f2:textfile;
  x,s:string;
  ttmp,t1,t2,t3,t4:integer;
begin
  NewsCount:=0;
  try
  try
  NewsHttp:=tidhttp.Create();
  NewsLists:=tstringlist.create;
  NewsHttp.Request.UserAgent:='Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';
  NewsLists.text:=NewsHttp.get('http://news.sina.com.cn/');
  NewsLists.SaveToFile('NewsRaw.NR');
  assign(f,'NewsRaw.NR');
  reset(f);

  assign(f2,'NewsList.list');
  rewrite(f2);

  x:='';
  while (x<>'<!-- 要闻区大字不超过24个字 小字不超过28个字 -->') and (not(eof(f))) do
    readln(f,x);
  while (x<>'<!-- 最后一行最多19个字，留意 -->') and (not(eof(f))) do
    begin
      readln(f,x);
      s:=copy(x,1,3);
      //VERY IMPORTANT!!!In order to find JUNK NEWS.
      if (s='<li') and (pos('class',x)<=1) then
        begin
          ttmp:=pos('href="',x);
          t1:=ttmp+6;
          ttmp:=pos('" target="_blank"',x);
          t2:=ttmp-1;
          t3:=ttmp+18;
          if pos('" target="_blank" >',x)>=1 then t3:=t3+1;
          ttmp:=pos('</a>',x);
          t4:=ttmp-1;
          inc(NewsCount);
          NewsArr[NewsCount].NewsUrl:=widestring(copy(x,t1,t2-t1+1));
          NewsArr[NewsCount].NewsTitle:=widestring(copy(x,t3,t4-t3+1));
          writeln(f2,NewsArr[NewsCount].NewsUrl);
          writeln(f2,NewsArr[NewsCount].NewsTitle);
        end;
   end;
  deletefile(pchar('NewsRaw.NR'));
  closefile(f);
  closefile(f2);
  except
    NewsCount:=0;
  end;
  finally
    NewsLists.Free;
    NewsHttp.Free;
  end;

  threading:=false;
end;

function GetNews:integer;
begin
  result:=-1;
  if NewsCount<>0 then
  begin
    result:=NewsFlag;
    inc(NewsFlag);
  //VERY IMPORTANT!!!MUST USE ANOTHER THREAD TO GET NEWS LISTS!
  if NewsFlag>NewsCount then
    begin
      if threading=false then begin createthread(nil,0,@GetNewsList,nil,0,GetNewsListid);threading:=true;end;
      NewsFlag:=0;
    end;
  end
  else if threading=false then begin createthread(nil,0,@GetNewsList,nil,0,GetNewsListid);threading:=true;result:=-1;end;
end;

exports
  GetDllVer,
  GetNews;


begin
  NewsFlag:=0;

end.
