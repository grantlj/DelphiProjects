{Project Name   : DrawSth
 Version        : 1.0
 Project Start  : 2013/11/5
 Project Finish : 2013/11/9
 Author         : Grant Liu
 Design for Ivy Hu.
 History:
 2013/11/9      :*First version. Complete basic functions.
}
unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,JPEG,winsock2;

const
  MAX_STEPS=80000;

type
  {
    TPenAction is to save the pen's info.
    Pix:              the width of the pen.
    Color:            the color of the pen.
    StartX,StartY:    the location which pen starts at.
    EndX,EndY:        the location which pen ends at.
    Tag:              to determine the pen's position in a line.
    Interval:         to simulate the processing of drwaing ACCURATELY.
    DrawInt:          to record the interval BETWEEN TWO LINES.
  }

  TPenAction=record
    Pix:integer;
    Color:TColor;
    StartX,StartY:integer;
    EndX,EndY:integer;
    Tag:integer;
    Interval:longint;
    DrawInt:longint;
  end;

  TACTS=array[1..MAX_STEPS] of TPenAction;

  TGAMEINFO=record
    PenActs:TACTS;
    s:longint;
    key:String[15];
  end;

  PTQUEINFO=^TQUEINFO;
    TQUEINFO=record
    p:       integer;    //p is 1, then send game info.
                         //p is 2, then send result.
    GameInfo:TGAMEINFO;
    result  :boolean;
  end;

  TForm1 = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    ColorDialog1: TColorDialog;
    Button7: TButton;
    ComboBox1: TComboBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Image1: TImage;
    Label4: TLabel;
    procedure Button4Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);

  private
    { Private declarations }
  public
    procedure InitialCanvas;
    procedure PlayerComplete(win:boolean);
    procedure PlayerSubmit(PenActs:TACTS;PenActsCounts:longint);
  end;

  TMyThread=class(TThread)
    protected
      procedure Execute;override;
      //procedure RewriteCanvasByActs(x:TACTS;s:longint);
      procedure RewriteCanvasByActs;
  end;

  TSetOppo=class(TThread)
    protected
      procedure Execute;override;
      procedure SetOppoTurn;
  end;

  TSetPlayer=class(TThread)
    protected
      procedure Execute;override;
      procedure SetPlayerTurn;
  end;


var
  Form1: TForm1;
  ReadyToDraw:boolean;
  Tag:integer;



implementation

{$R *.dfm}




const
  BTN4_STANDBY_DRAW=1;
  BTN4_STANDBY_SUBMIT_PLAYER=2;
  BTN4_STANDBY_SUBMIT_OPPO=3;
  BTN4_IDLE=0;

var
  PenActs:TACTS;
  PenActsCounts:longint;
  TmpPenStart,TmpPenEnd:int64;
  TmpIntStart,TmpIntEnd:int64;
  Lives:integer;
  btn4_status:integer;

  Self,Recever:TSOCKET;
  Sender:TSOCKET;



  NowGame:TGAMEINFO;

  {*********************************
   NetWork varities defined here.
   *********************************
  }
  PlayerIP:string[15];
  Agree:string[15];
  DisAgree:string[15];
  ServSocketHandle,ServSocketID:DWORD;
  CliSocketHandle,CliSocketID:DWORD;
  CliSocketReady,ServSocketReady:boolean;
  MainHandle:DWORD;
  ServMode:boolean;
  DestThreadID,DestThreadHandle:DWORD;
  PointInfo:record
    you:integer;
    oppo:integer;
  end;

procedure SetScore(a:integer;b:integer);
begin
  PointInfo.you:=a;
  PointInfo.oppo:=b;
  form1.Label4.Caption:='SCORE:   YOU   '+inttostr(PointInfo.you)+'              :               '+inttostr(PointInfo.oppo)+'    OPPO';
end;
//Show Lives info.

procedure ShowLives(x:integer);

begin
  if x<0 then
     begin
       MessageBox(form1.Handle,'You lost all your lives!:(','You Lost!',MB_ICONERROR);
       Form1.InitialCanvas;
       form1.PlayerComplete(false);
       //Do SOMETHING.
     end
  else
     form1.Label3.Caption:='You have '+inttostr(x)+' lives left!';
end;

//procedure TMyThread.RewriteCanvasByActs(x: TACTS; s: Integer);
procedure TMyThread.RewriteCanvasByActs;
var
  i,s:longint;
  x:TACTS;
begin
  form1.InitialCanvas;
  form1.Image1.Enabled:=true;
  form1.ComboBox1.Enabled:=false;
  form1.RadioButton1.Enabled:=false;
  form1.RadioButton2.Enabled:=false;
  form1.Button5.Enabled:=false;
  form1.Button6.Enabled:=false;
  form1.Button7.Enabled:=false;

  x:=NowGame.PenActs;
  s:=NowGame.s;

  for i:=1 to s do
     with Form1.Image1.Canvas do
       begin
         if (x[i].DrawInt<>0) and (i<>1) then Sleep(x[i].DrawInt);
         Pen.Color:=x[i].Color;
         Pen.Width:=x[i].Pix;
         MoveTo(x[i].StartX,x[i].StartY);
         Application.ProcessMessages;
         Sleep(x[i].Interval);
         LineTo(x[i].EndX,x[i].EndY);
       end;

  ShowMessage('Time for you to guess!');
  form1.ComboBox1.Enabled:=true;
  form1.RadioButton1.Enabled:=true;
  form1.RadioButton2.Enabled:=true;
  form1.Button6.Enabled:=true;
  form1.Button5.Enabled:=true;
  form1.Button7.Enabled:=true;
  Lives:=3;
  ShowLives(Lives);
end;

procedure TMyThread.Execute;
begin
  // Synchronize(RewriteCanvasByActs(NowGame.PenActs,NowGame.s));
  Synchronize(RewriteCanvasByActs);
end;

//Button 4 is the KEY BUTTON. Save its statue is very important.
procedure SetBtn4(x:integer);
begin
  btn4_status:=x;
  if x=BTN4_STANDBY_DRAW then
     form1.Button4.Caption:='Draw!';

  if (x=BTN4_STANDBY_SUBMIT_PLAYER) or (x=BTN4_STANDBY_SUBMIT_OPPO) then
    form1.Button4.Caption:='Submit!';
end;

//GetPenState is to refresh the PenState.
procedure SetPenMode(isPen:boolean);
begin
  if isPen then form1.Image1.Cursor:=crCross
           else form1.Image1.Cursor:=crNoDrop;
end;

procedure GetPenState;
begin
  with form1 do
    begin
      if RadioButton1.Checked then
        begin
          //Is Pen.
          Image1.Canvas.Pen.Width:=strtoint(ComboBox1.text);
          Image1.Canvas.Pen.Color:=ColorDialog1.Color;
        end
      else
        begin
          Image1.Canvas.Pen.Width:=strtoint(ComboBox1.Text);
          Image1.Canvas.Pen.Color:=clwhite;

        end;
    end;
end;

//Start to record the operation of the pen.
procedure NewPenActs(x,y:integer);
begin
  TmpPenStart:=GetTickCount;
  inc(PenActsCounts);
  PenActs[PenActsCounts].StartX:=x;
  PenActs[PenActsCounts].StartY:=y;
  PenActs[PenActsCounts].Pix:=Form1.Image1.Canvas.Pen.Width;
  PenActs[PenActsCounts].Color:=Form1.Image1.Canvas.Pen.Color;
  PenActs[PenActsCounts].DrawInt:=0;
end;

//Finish to record the operation of the pen.
procedure FinishPenActs(x,y,tag:integer);
begin
   TmpPenEnd:=GetTickCount;
   PenActs[PenActsCounts].EndX:=x;
   PenActs[PenActsCounts].EndY:=y;
   PenActs[PenActsCounts].Tag:=tag;
   PenActs[PenActsCounts].Interval:=TmpPenEnd-TmpPenStart;
end;

//Set the interval between drawing.
procedure SetDrawInt(int:int64);
begin
  PenActs[PenActsCounts].DrawInt:=int;
end;

//Initial the Canvas.
procedure TForm1.InitialCanvas;
begin
  with form1 do
    begin
      //PenActsCounts:=0;
      Image1.Enabled:=true;
      Image1.Canvas.Pen.Color:=clwhite;
      Image1.Canvas.FillRect(Image1.Canvas.ClipRect);
      SetPenMode(RadioButton1.Checked);
      Image1.Canvas.Pen.Color:=clblack;
      ComboBox1.Text:='10';
      Image1.Canvas.Pen.Width:=strtoint(ComboBox1.Text);
      //GetPenState;
    end;
end;

//Clear Pen action queue.
procedure ClearPenActs;
begin
   PenActsCounts:=0;
end;

//Save the Canvas to file.
procedure SaveToJPGFile;
var
  jp:TJpegImage;
  FileName:string;
begin
  jp:=TJPEGImage.Create;
  FileName:=FormatDateTime('yyyymmddhhmmss',now)+'.jpg';
  try
    with jp do
    begin
      jp.CompressionQuality:=100;
      jp.Compress;
      Assign(form1.Image1.Picture.Bitmap);
      SaveToFile(FileName);
    end;
  finally
    jp.Free;
  end;
end;


//Initail for Opposite's turn.
//procedure SetOppoTurn(NowGame:TGameInfo);

//PlayerComplete:   Player complete answer.
//PlayerSubmit  :   Player complete question.
//*********************************************
//*********************************************
//set PostMessage here!
//*********************************************
//*********************************************

//Player complete answer.
procedure TForm1.PlayerComplete(win: Boolean);
var
  quetmp:PTQUEINFO;
begin
  if win then
    begin
      label3.Caption:='YOU WIN....YOUR TURN.';
    end
  else
    begin
      label3.Caption:='YOU LOST...YOUR TURN.';
    end;
    //Post Message to thread.
    ClearPenActs;
    new(quetmp);
    quetmp^.p:=2;
    quetmp^.result:=win;

    repeat

    until PostThreadMessage(DestThreadID,0,longint(quetmp),0);

   // SetPlayerTurn;
end;

//Player Submit questions.
procedure TForm1.PlayerSubmit(PenActs:TACTS;PenActsCounts:longint);
var
  NowGame:TGameInfo;
  quetmp:PTQUEINFO;
begin
  NowGame.PenActs:=PenActs;
  NowGame.s:=PenActsCounts;
  NowGame.key:=edit2.text;
  //Post Message to therad.
  new(quetmp);
  quetmp^.p:=1;
  quetmp^.GameInfo:=NowGame;
  //showmessage(inttostr(quetmp^.GameInfo.s));
 // ReWriteCanvasByActs(quetmp^.GameInfo.PenActs,quetmp^.GameInfo.s);
  repeat

  until PostThreadMessage(DestThreadID,0,longint(quetmp),0);
end;



procedure TForm1.Button4Click(Sender: TObject);
begin

  if btn4_status=BTN4_STANDBY_SUBMIT_OPPO then
      begin
        if (edit2.Text<>NowGame.key) then
          begin
            MessageBox(form1.Handle,'Sorry,your answer is not correct!','Wrong Anaser',MB_ICONERROR);
            edit2.Text:='';
            dec(Lives);
            ShowLives(Lives);
          end
        else
          begin
            MessageBox(form1.Handle,'Congratulation!You got the correct answer!:)','Complete!',MB_ICONWARNING);
            form1.PlayerComplete(true);
            SetBtn4(BTN4_IDLE);
          end;
      end;

  if btn4_status=BTN4_STANDBY_SUBMIT_PLAYER then
    begin
      PlayerSubmit(PenActs,PenActsCounts);
      SetBtn4(BTN4_IDLE);
    end;

  if btn4_status=BTN4_IDLE then
    begin
      //Do Nothing...
    end;
end;

//Clear Button.
procedure TForm1.Button5Click(Sender: TObject);
begin
  InitialCanvas;
  ClearPenActs;
end;

//Save present canvas to jpg file.
procedure TForm1.Button6Click(Sender: TObject);
begin
   //SaveToJPGFile;
  // RewriteCanvasByActs(PenActs,PenActsCounts);
   NowGame.s:=PenActsCounts;
   NowGame.PenActs:=PenActs;
   NowGame.key:=Edit2.Text;
   //SetOppoTurn(NowGame);
    TSetOppo.Create;
  //RewriteCanvasByActs(PenActsCounts);
end;

//Select Color.
procedure TForm1.Button7Click(Sender: TObject);
begin
  ColorDialog1.Execute;
 // Button7.Font.Color:=ColorDialog1.Color;
end;

//ONLY 5-20 PEN PIX IS AVAILABLE.
procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if not( (strtoint(ComboBox1.Text)>=5) and (strtoint(ComboBox1.Text)<=20)) then
   ComboBox1.Text:='10';

end;

//You start to draw.

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  TmpIntEnd:=GetTickCount;
  Tag:=1;
  GetPenState;
  NewPenActs(x,y);
  SetDrawInt(TmpIntEnd-TmpIntStart);
  Image1.Canvas.MoveTo(x,y);
end;

//You are moving the line.
procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Tag=1 then
     begin
       Image1.Canvas.LineTo(x,y);
       //Tag 1 is the middle of the line.
       FinishPenActs(x,y,1);
       NewPenActs(x,y);
     end;
end;

//You finish a line.
procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Tag:=0;
  //Tag 3 is the end of the line.
  FinishPenActs(x,y,3);
  TmpIntStart:=GetTickCount;
end;

//Select Pen or Eraser.
procedure TForm1.RadioButton1Click(Sender: TObject);
begin
  RadioButton1.Checked:=true;
  RadioButton2.Checked:=false;
  SetPenMode(RadioButton1.Checked);
end;

procedure TForm1.RadioButton2Click(Sender: TObject);

begin
  RadioButton1.Checked:=false;
  RadioButton2.Checked:=true;
  SetPenMode(RadioButton1.Checked);
end;


//============================================
//Use thread to handle SetOppo!!!!!!!!!!!
//============================================
procedure TSetOppo.SetOppoTurn;
procedure SetButtonsCondition;
begin
   with form1 do
     begin
       Edit2.Enabled:=true;
       Edit2.Text:='';
       ComboBox1.Enabled:=false;
       RadioButton1.Enabled:=false;
       RadioButton2.Enabled:=false;
       Button7.Enabled:=false;
       Button4.Enabled:=true;SetBtn4(BTN4_STANDBY_SUBMIT_OPPO);

       Button6.Enabled:=true;
       ClearPenActs;
       InitialCanvas;
       Image1.Enabled:=false;
       Button5.Enabled:=false;
     end;
end;

begin

  form1.Label3.Caption:=PlayerIP+' is Drawing....';
  TMyThread.Create;

  SetButtonsCondition;

end;

procedure TSetOppo.Execute;
begin
  Synchronize(SetOppoTurn);
end;


//===============================================
//Use thread to handle set player.
//===============================================
procedure TSetPlayer.SetPlayerTurn;
procedure SetButtonsCondition;
begin
   with form1 do
     begin
       Label3.Caption:='YOUR TURN...';
       Edit2.Enabled:=true;
       Edit2.Text:='';
       ComboBox1.Enabled:=true;
       RadioButton1.Enabled:=true;
       RadioButton2.Enabled:=true;
       Button7.Enabled:=true;
       Button4.Enabled:=true;SetBtn4(BTN4_STANDBY_SUBMIT_PLAYER);
       Button5.Enabled:=true;
       Button6.Enabled:=true;
       ClearPenActs;
       InitialCanvas;
       Image1.Enabled:=true;
       Image1.Enabled:=true;
       Button5.Enabled:=true;
     end;
end;

begin
  SetButtonsCondition;
  ClearPenActs;
  form1.InitialCanvas;
end;


procedure TSetPlayer.Execute;
begin
  Synchronize(SetPlayerTurn);
end;

{****************************************************
   Initial Network.                                   *
   We use Winsock API here.                           *
                                                      *
   ****************************************************
  }



procedure ServSocketThread;
var
  wVersionRequired:word;

  ServAddr:sockaddr_in;
  WSAData:TWSAData;
  CliAddr:SockAddr;
  CliAddrLen:integer;
  cmd:cardinal;
  ReturnVal:integer;
  Info:string;
  msg1:msg;
  p:PTQUEINFO;
  InitFlag:boolean;
  unbind:boolean;
  q:TQUEINFO;

function InitialWSA:boolean;
begin
  if WSAStartup($0101,WSAData)<>0
    then
      begin
        result:=false;
        showmessage(inttostr(WSAGetLastError));
      end
    else
      result:=true;
end;

function InitialSocket:boolean;
begin
  Self:=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
  if Self=INVALID_SOCKET then
    begin
      result:=false;
      showmessage(inttostr(WSAGetLastError));
    end
  else
    result:=true;
end;

function BindServInfo:boolean;
begin
  ServAddr.sin_family:=AF_INET;
  ServAddr.sin_port:=htons(1273);
  ServAddr.sin_addr.S_addr:=htonl(INADDR_ANY);
 if bind(Self,SockAddr(ServAddr),sizeof(ServAddr))=SOCKET_ERROR then
   begin
   result:=false;
   showmessage(inttostr(WSAGetLastError));
   end
 else
   result:=true;
end;

function StartListen:boolean;
begin
  if listen(Self,1)=SOCKET_ERROR then
    begin
      result:=false;
      //showmessage(inttostr(WSAGetLastError));
    end
  else
    result:=true;
end;

begin
        // unbind:=true;
        // setsockopt(Self, SOL_SOCKET,SO_REUSEADDR,PAnsiChar(unbind),sizeof(unbind));
         //CloseSocket(Self);
       //  setsockopt(Recever,SOL_SOCKET,SO_REUSEADDR,PAnsiChar(unbind),sizeof(unbind));
         //CloseSocket(Recever);

   InitFlag:=false;
   try
     //Initial Socket.
     InitFlag:=InitialWSA       and
               InitialSocket    and
               BindServInfo     and
               StartListen;
   except
     showmessage('Initial Network Failed.');
   end;
     //Yes is 6, No is 7.

   if InitFlag=true then
     begin
          showmessage('Serv socket started.');
          CliAddrLen:=sizeof(CliAddr);
          Recever:=accept(Self,@CliAddr,@CliAddrLen);
          repeat
            recv(Recever,PlayerIP,sizeof(PlayerIP),0);
          until PlayerIP<>'';

          info:='A new game request from:'+PlayerIP+', accept?';
          ReturnVal:=MessageBox(form1.handle,PWideChar(info),'New Game Request',MB_YESNO);

          if ReturnVal=6 then
          begin
            send(Recever,Agree,sizeof(Agree),0);
            form1.Edit1.Enabled:=false;form1.Button1.Enabled:=false;

            repeat
              //Receive oppo's question.
              //showmessage('recving oppo game');
              form1.Label3.caption:='Waiting for question...';
              recv(Recever,NowGame,sizeof(NowGame),0);
              //showmessage('recving oppo game ok');
              form1.Label3.Caption:='Get question successfully...';
              //showmessage(inttostr(NowGame.s));
              //Get info from the opposite.
              //So we initial the turn for the opposite. and wait for the answer message.

              TSetOppo.CREATE;
             //PostThreadMessage(MainHandle,0,MSG_SET_OPPO_TURN,0);

              repeat
              until GetMessage(msg1,0,0,0);

              p:=PTQUEINFO(msg1.wParam);

              form1.Label3.Caption:='Sending your answer...';
              //showmessage('ready to send answer');
              //Send player's answer.
              if p^.p=2 then
                   begin
                     send(Recever,p^.result,sizeof(p^.result),0);
                     form1.Label3.Caption:='Send your answer successfully...';
                     if p^.result then
                       begin
                         form1.Label3.Caption:='You answers oppo question correctly...';
                         SetScore(PointInfo.you+1,PointInfo.oppo+2);
                         showmessage('You answer oppo question correctly! You get 1 points.');
                       end
                     else
                       begin
                        form1.Label3.Caption:='You answers oppo question wrong...';
                         SetScore(PointInfo.you,PointInfo.oppo+1);
                         showmessage('You answer oppo question wrong! You get 0 points.');
                       end;

                     dispose(p);
                   end;

              //Player's turn.
              //Set player's question.

              //SetPlayerTurn;
              //showmessage('Player turn ready');
              form1.Label3.Caption:='Starting your turn...';
              TSetPlayer.Create;
             // PostThreadMessage(MainHandle,0,MSG_SET_PLAYER_TURN,0);

              repeat
              until GetMessage(msg1,0,0,0);

              form1.Label3.Caption:='Sending your question...';
              //Send Player's question.
              p:=PTQUEINFO(msg1.wParam);
              if p^.p=1 then
                 begin
                   send(Recever,p^.GameInfo,sizeof(p^.GameInfo),0);
                   //showmessage('send player info ok');
                   form1.Label3.Caption:='Send your question successfully...';
                   dispose(p);
                 end;

             //Get oppo's reply.
              // showmessage('ready to get reply');
                 form1.Label3.Caption:='Waiting for reply...';
                 //new(p);
                 repeat
                   recv(Recever,q,sizeof(q),0);
                   //showmessage('Strange!?');
                   //showmessage(inttostr(q.p));
                 until q.p=2;
                  if q.p=2 then
                   begin
                    if q.result then
                       begin
                         form1.Label3.Caption:='Oppo answers your question correctly...';
                         SetScore(PointInfo.you+2,PointInfo.oppo+1);
                         showmessage('Oppo answer your question correctly! You get 2 points.');
                       end
                       //Form1.Label3.Caption:='Oppo answers your question correctly...'
                       //showmessage('SERV :Oppo answers your question ok')
                    else
                      begin
                        form1.Label3.Caption:='Oppo answers your question wrong...';
                        SetScore(PointInfo.you+1,PointInfo.oppo);
                        showmessage('Oppo answer your question wrong! You get 1 points.');
                      end;
                   end;
              //dispose(p);
             //Player's turn end.
         until (DestThreadID<>ServSocketID);
     end
     else
       //Rejected new game.
       send(Recever,DisAgree,sizeof(DisAgree),0);
     end
     else
       //Serv Socket Started failed.
       begin
         showmessage('Serv Socket Started failed.');

         {unbind:=true;
         setsockopt(Self, SOL_SOCKET,SO_REUSEADDR,PAnsiChar(unbind),sizeof(unbind));
         CloseSocket(Self);
         setsockopt(Recever,SOL_SOCKET,SO_REUSEADDR,PAnsiChar(unbind),sizeof(unbind));
         CloseSocket(Recever);
         }

         form1.Button1.enabled:=true;
         form1.Button2.Enabled:=false;
       end;

end;

procedure CliSocketThread;
var
  wVersionRequired:word;
  ServAddr:TSockAddrin;
  WSAData:TWSAData;
  cmd:cardinal;
  msg1:msg;
  p:PTQUEINFO;
  InitFlag:boolean;
  re:integer;
  RequestRply:string[15];
  round:integer;
  q:TQUEINFO;


function InitialWSA:boolean;
begin
  if WSAStartup($0101,WSAData)<>0
    then
      result:=false
    else
      result:=true;
end;

function InitialSocket:boolean;
begin
  Sender:=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
  if Sender=INVALID_SOCKET then
    result:=false
  else
    result:=true;
end;

procedure SetServInfo;
var
 IP:AnsiString;
begin
  ServAddr.sin_family:=AF_INET;
  ServAddr.sin_port:=htons(1273);
  IP:=form1.edit1.text;
  ServAddr.sin_addr.S_addr:=inet_addr(PAnsiChar(IP));
end;

function TryConnect:boolean;
var
  i:integer;
begin
   i:=0;
   repeat
     inc(i);
     sleep(500);
     //showmessage('connecting1'+inttostr(i));
     re:=connect(Sender,sockaddr(ServAddr),sizeof(ServAddr));
     //showmessage('connecting2'+inttostr(i));

   until ((re<>SOCKET_ERROR) or (i>5));
   if re<>SOCKET_ERROR then result:=true
                       else begin result:=false;showmessage(inttostr(re));end;
end;

begin
   //showmessage('CLIENT START');
   try
     //Initial Socket.
     InitFlag:=InitialWSA and
               InitialSocket;

   except
     showmessage('Initial Network Failed.');
   end;

   if InitFlag=true then
     begin
        SetServInfo;
        //showmessage('INFO SETTED');
        if not(TryConnect) then
        begin
          showmessage('Connect to Player failed!');
          shutdown(Sender,SD_BOTH);
          closeSocket(Sender);
          form1.Button2.Click;
        end
       else

         begin
           //CONNECTED.
           //=================================================
           //===================CORE==========================
           //=================================================
           //showmessage('Connect to player'+form1.edit1.text+' Successfully!');
           PlayerIP:=form1.edit1.text;
           //Send
           send(Sender,PlayerIP,sizeof(PlayerIP),0);
           recv(Sender,RequestRply,sizeof(RequestRply),0);

           if RequestRply=Agree then showmessage('Your request is approved.');
           if RequestRply=DisAgree then showmessage('Your request is rejected.');

           if RequestRply=Agree then
           begin
               repeat
                   //showmessage('Ready to set player turn');
                    form1.Label3.Caption:='Starting your turn...';
                   //round:=0;
                  //Player's turn.
                  //inc(round);
                  TSetPlayer.create;
                  //PostThreadMessage(MainHandle,0,MSG_SET_PLAYER_TURN,0);
                  repeat
                  until GetMessage(msg1,0,0,0);


                  p:=PTQUEINFO(msg1.wParam);

                  //After finished. Send player's question.
                  if p^.p=1 then
                     begin
                      // showmessage(inttostr(round)+' to send!');
                      //showmessage('get player question. ready to send');
                       form1.Label3.Caption:='Sending your question...';
                       send(Sender,p^.GameInfo,sizeof(p^.GameInfo),0);
                       form1.Label3.Caption:='Send your question successfully...';
                       dispose(p);
                     end;

                  //Receive oppo's answer.
                  new(p);
                  //showmessage('ready to get oppo answer');
                  form1.Label3.Caption:='Waiting for reply...';
                  recv(Sender,p^.result,sizeof(p^.result),0);
                 // showmessage('get oppo answer successful');
                  if p^.result then
                                 begin
                                   form1.Label3.Caption:='Oppo answers your question correctly...';
                                   SetScore(PointInfo.you+2,PointInfo.oppo+1);
                                   showmessage('Oppo answer your question correctly! You get 2 points.');
                                 end
                               else
                                  begin
                                    form1.Label3.Caption:='Oppo answers your question wrong...';
                                    SetScore(PointInfo.you+1,PointInfo.oppo);
                                    showmessage('Oppo answer your question wrong! You get 1 points.');
                                  end;
                  //Oppo's turn.
                  //Get Oppo's question.
                 //showmessage('ready to get question');
                  form1.Label3.Caption:='Waiting for question...';
                  recv(Sender,NowGame,sizeof(NowGame),0);
                  form1.Label3.Caption:='Get question successfully...';
                  TSetOppo.Create;
                  //PostThreadMessage(MainHandle,0,MSG_SET_OPPO_TURN,0);

                  repeat

                  until GetMessage(msg1,0,0,0);

                  p:=PTQUEINFO(msg1.wParam);
                  q.p:=p^.p;
                  q.GameInfo:=p^.GameInfo;
                  q.result:=p^.result;
                  //Send Player's answer.
                  if p^.p=2 then
                     begin
                       //showmessage('get player answer.ready to send');
                       form1.Label3.Caption:='Sending your answer...';
                       send(Sender,q,sizeof(q),0);
                      // showmessage('Answer SENDED!!!!'+booltostr(p^.result));
                        //showmessage('player answer send ok');
                       form1.Label3.Caption:='Send your answer successfully...';
                       dispose(p);
                     end;
                  //Oppo's turn end.
         until (DestThreadID<>CliSocketID);
         //Agree end;
         end
         //Connected end;
         end

     //Init true end;
     end
   else
       begin
          showmessage('Start connect service failed!');
          shutdown(Sender,SD_BOTH);
          closeSocket(Sender);
          form1.Button2.Click;
       end;

       //Client Socket end.
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  unbind:boolean;
begin
   edit1.Enabled:=false;
   button1.Enabled:=false;
   Button2.Enabled:=true;
   //as the accept() function is hang up at ServSocket thread.
   //We MUST EXIT THREAD Directly.

  // repeat

   //until (CloseHandle(ServSocketHandle)<>false);

   CliSocketHandle:=CreateThread(nil,0,@CliSocketThread,nil,0,CliSocketID);
   DestThreadID:=CliSocketID;
   DestThreadHandle:=ServSocketHandle;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   //as the accept() function is hang up at CliSocket thread.
   //We MUST EXIT THREAD Directly.
   Edit1.Enabled:=true;
   button2.Enabled:=false;
   button1.Enabled:=true;
   repeat
   until (CloseHandle(CliSocketHandle)<>false);

   ServSocketHandle:=CreateThread(nil,0,@ServSocketThread,nil,0,ServSocketID);
   DestThreadID:=ServSocketID;
   DestThreadHandle:=ServSocketHandle;
   edit1.Text:='';
   button2.enabled:=false;
   button1.Enabled:=true;
end;


//Initial!Program run from here.
procedure TForm1.FormCreate(Sender: TObject);
begin

  ServMode:=true;
  //ReadyToDraw:=false;
  ComboBox1.Text:='10';
  SetBtn4(BTN4_IDLE);
  Agree:='YES';
  DisAgree:='NO';
  PenActsCounts:=0;
  InitialCanvas;
  PointInfo.you:=0;
  PointInfo.oppo:=0;
  ServSocketHandle:=CreateThread(nil,0,@ServSocketThread,nil,0,ServSocketID);
  DestThreadID:=ServSocketID;

end;

end.


