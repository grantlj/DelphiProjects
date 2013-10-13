program server;

{$APPTYPE CONSOLE}

uses
  SysUtils;

var
  stu:array[1..3942] of real;
  nums:array[1..3942] of integer;

procedure READDAT(st:string);
var
  f:text;
  name:string;
  point:longint;
  xh:integer;
begin
  assign(f,st);
  reset(f);
  while not eof(f) do
    begin
      readln(f,name);
      readln(f,point);
      xh:=strtoint(copy(name,length(name)-3,4));
      stu[xh]:=(stu[xh]+point)/2;
    end;
  close(f);
  deletefile(extractfilepath(paramstr(0))+'\'+st);
end;

procedure  searchfile;
var
  SearchRec:TSearchRec;
  found:integer;
  path:string;
begin
  path:=extractfilepath(paramstr(0))+'\';
  found:=FindFirst(path+'*.dat',faAnyFile,SearchRec);
  while found=0 do
  begin
    if (SearchRec.Name<>'.')  and (SearchRec.Name<>'..')
    and (SearchRec.Attr<>faDirectory) then READDAT(SearchRec.Name);
             found:=FindNext(SearchRec);
  end;
       FindClose(SearchRec);
end;

procedure readpoint;
var
  f:text;
  i:integer;
begin
  if not (fileexists('POINTS.TXT')) then
    begin
      assign(f,'POINTS.TXT');
      rewrite(f);
      for i:= 1 to 3942 do
        writeln(f,0);
      close(f);
    end;
  assign(f,'POINTS.TXT');
  reset(f);
  for i := 1 to 3942 do
    begin
      readln(f,stu[i]);
      nums[i]:=i;
    end;
  close(f);
end;

procedure sort;
var
  i,j,t:integer;
  t2:real;
begin
  for i:=1 to 3941 do
    for j:=i+1 to 3942 do
      if stu[i]<stu[j] then
        begin
          t:=nums[i];
          nums[i]:=nums[j];
          nums[j]:=t;
          t2:=stu[i];
          stu[i]:=stu[j];
          stu[j]:=t2;
        end;

end;

procedure savepoint;
var
  f:text;
  i:integer;
  st:string;
begin
  assign(f,'POINTS.TXT');
  rewrite(f);
  for i := 1 to 3942 do
      writeln(f,stu[i]);
  close(f);
  sort;

  assign(f,'SORTED.TXT');
  rewrite(f);
  writeln(f,formatdatetime('yyyy-mm-dd hh:mm:ss',now));

  for i := 1 to 3942 do
    begin
       st:='CQUPT2013';
       if (nums[i]<10) then st:=st+'000';
       if (nums[i]>=10)and (nums[i]<100) then st:=st+'00';
       if (nums[i]>=100) and (nums[i]<1000) then st:=st+'0';
       st:=st+inttostr(nums[i]);
      writeln(f,st);
      writeln(f,stu[i]:2:1);
    end;
  close(f);
end;

begin
  repeat
    readpoint;
    searchfile;
    savepoint;
    sleep(180000);
  until 1=2 ;
end.
