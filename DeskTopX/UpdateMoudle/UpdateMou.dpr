{Module Name:UpdateMou

Author:Grant Liu

This is the Update Service DLL of DesktopX.

History:
Build1151: 2012-9-9
Build1101: 2012-9-4
Build1100: 2012-8-26

}





library UpdateMou;

uses
  dialogs,
  SysUtils,
  Classes,
  windows,
  shellapi,
  IdBaseComponent,
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  IdHTTP;


{$R *.res}
const
  ver=1151;
var
  UpdateInfo:widestring;

function GetDllVer:integer;
begin
  result:=ver;
end;

procedure CheckUpdate;
const
  UpdateName='DesktopX_1151_Update.exe';
  UpdateServer='http://grantlj.gicp.net/DesktopXServer/';
var
  url:string;
  bool:boolean;
  DownLoadFile:TFileStream; 
  idhttp:tidhttp;
  f:file;
begin
  repeat
  url:=UpdateServer+UpdateName;
  UpdateInfo:='ERR';
  bool:=true;
  downloadfile:=tfilestream.Create(UpdateName,fmcreate);
  idhttp:=tidhttp.create();
  idhttp.Request.UserAgent:='Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';
  try
    idhttp.Get(url,downloadfile);
    updateinfo:=updatename;
  except
    UpdateInfo:='ERR';
    bool:=false;
  end;
  downloadfile.Free;
  idhttp.Free;
  assign(f,updatename);
  reset(f);
  //VERY IMPORTANT.SOMETIMES THE DLL MAY DOWNLOAD INCORRECT UPDATE PACK!!!CHECK SIZE TO AVOID!
  if filesize(f)<=100 then begin bool:=false;close(f);deletefile(pchar(updatename));end
                      else close(f);

  if (UpdateInfo<>'ERR') and (bool=true) then
    begin
      showmessage('发现可用更新:'+UpdateName+'您必须更新后使用！');
      shellexecute(0,nil,UpdateName,nil,nil,sw_shownormal);
      halt;
    end;
  //2 HOURS PER CHECKING.
  sleep(120*60*1000);
  until 1=2;
end;

exports
  GetDllVer,CheckUpdate;
begin

end.
