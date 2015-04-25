unit ChatInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw, Vcl.ComCtrls,
  Vcl.StdCtrls, UProc, Vcl.ExtCtrls, UAuth, Vcl.Grids;

//глобальные переменные
var
//дата и время старта
sdate, stime:string;
//текущие дата и время
xdate,xtime:string;
//путь к программе
mydir:string;
//юзерид и токен
userid, token:string;
//проверка авторизации
auth:integer;
//количество конф
confcount:integer;
//последняя конфа
confex:integer;

confnom:string;
confdo:integer;

ctit,cid,cnm,slots,status:string;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    WebBrowser1: TWebBrowser;
    Image1: TImage;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    Button1: TButton;
    Button2: TButton;
    LabeledEdit5: TLabeledEdit;
    Button4: TButton;
    Button5: TButton;
    GroupBox2: TGroupBox;
    StringGrid1: TStringGrid;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure WebBrowser1TitleChange(ASender: TObject; const Text: WideString);
    procedure Memo1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    //потоки
    //авторизация
    Auth1:TAuth;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);//загрузка конф
begin
settabl;
addtime(xdate,xtime);
form1.Memo1.Lines.Append('Загрузка конф...');
if FileExists(mydir+'\files\c'+userid+'.txt') then
begin
LoadStringGrid(form1.StringGrid1, mydir+'\files\c'+userid+'.txt');
addtime(xdate,xtime);
confcount:=form1.StringGrid1.RowCount-2;
confex:=0;
form1.Memo1.Lines.Append('Список конф загружен из  файла! Проверяем наличие новых конф!');
form1.Enabled:=false;
getconf(confcount,confex,ctit,cid,cnm,slots,status);
end else confcount:=0;
if confcount=0 then
begin
addtime(xdate,xtime);
form1.Memo1.Lines.Append('Файл со списком конф не найден! Обновляем!');
confcount:=1;
confex:=0;
form1.Enabled:=false;
getconf(confcount,confex,ctit,cid,cnm,slots,status);
end;
end;

procedure TForm1.Button2Click(Sender: TObject);//обновление списка конф
begin
settabl;
addtime(xdate,xtime);
form1.Memo1.Lines.Append('Обновление списка конф...');
confcount:=1;
confex:=0;
form1.Enabled:=false;
getconf(confcount,confex,ctit,cid,cnm,slots,status);
end;

procedure TForm1.Button4Click(Sender: TObject);
var i:integer;
begin
i:=1;
confnom:='';
while form1.LabeledEdit5.Text[i]<>' ' do begin confnom:=confnom+form1.LabeledEdit5.Text[i]; i:=i+1; end;
confdo:=1;
doconfdo;
end;

procedure TForm1.Button5Click(Sender: TObject);
var i:integer;
begin
i:=1;
confnom:='';
while form1.LabeledEdit5.Text[i]<>' ' do begin confnom:=confnom+form1.LabeledEdit5.Text[i]; i:=i+1; end;
confdo:=2;
doconfdo;
end;

procedure TForm1.FormCreate(Sender: TObject);//при запуске
begin
auth:=0;
MyDIR:=ExtractFileDir(ParamStr(0));
formcenter;
loadauth;
addtime(sdate,stime);
form1.Memo1.Lines.Append('Программа запущена!');
form1.PageControl1.TabIndex:=0;
clearall;
settabl;
end;

procedure TForm1.Memo1Change(Sender: TObject); //вторая вкладка
begin
if auth=1 then
begin
form1.PageControl1.TabIndex:=1;
form1.TabSheet1.Caption:='Выход';
end else
begin
form1.TabSheet1.Caption:='Авторизация';
end;
end;

procedure TForm1.PageControl1Change(Sender: TObject);//выход
begin
if form1.PageControl1.TabIndex=0 then
begin
auth:=0;
form1.Memo1.Clear;
getdate(sdate);
gettime(stime);
form1.Memo1.Lines.Append(sdate + ' '+stime);
form1.Memo1.Lines.Append('Начат новый отчет!');
loadauth;
clearall;
settabl;
end else
begin
form1.PageControl1.TabIndex:=0;
end;
end;

procedure TForm1.StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
form1.LabeledEdit5.Text:=form1.StringGrid1.Cells[0,arow]+' '+form1.StringGrid1.Cells[1,arow];
if form1.StringGrid1.Cells[5,arow]='Вышел' then form1.Button4.Enabled:=true else form1.Button4.Enabled:=false;
if form1.StringGrid1.Cells[5,arow]='В конфе' then form1.Button5.Enabled:=true else form1.Button5.Enabled:=false;
end;

procedure TForm1.WebBrowser1TitleChange(ASender: TObject;
  const Text: WideString);//авторизация
var response:string;
    i:integer;
begin

//узнаем что сделал пользователь
response:=form1.WebBrowser1.LocationURL;
if response='https://oauth.vk.com/authorize?client_id=4848950&redirect_uri=https%3A%2F%2Foauth.vk.com%2Fblank.html&response_type=token&scope=6274559&v=5.29&state=&display=mobile&revoke=1' then
begin

end else begin

addtime(xdate,xtime);
form1.Memo1.Lines.append('Авторизация');
//при отмене перезагружаем авторизацию
if pos('error',response)<>0 then
  begin
  addtime(xdate,xtime);
  form1.Memo1.Lines.append('Не удалось авторизоваться!');
  form1.WebBrowser1.Navigate('https://oauth.vk.com/authorize?client_id=4848950&redirect_uri=https%3A%2F%2Foauth.vk.com%2Fblank.html&response_type=token&scope=6274559&v=5.29&state=&display=mobile&revoke=1');
  end else
  //при подтверждении получаем id и токен
  if pos('access_token', response)<>0 then
    begin
    token:='';
    userid:='';
    i:=pos('access_token=',response)+13;
    while response[i]<>'&' do begin token:=token+response[i]; i:=i+1; end;
    i:=pos('user_id=',response)+8;
    while response[i]<>'&' do begin userid:=userid+response[i]; i:=i+1;  end;
    //подгрузка данных в окно программы
    Auth1:=TAuth.Create(true);
    Auth1.Priority:=tpLower;
    Auth1.FreeOnTerminate:=True;
    Auth1.Resume;
    end;
end;
end;

end.
