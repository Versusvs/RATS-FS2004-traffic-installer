unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ZipForge, shellapi, Grids, ValEdit, Jpeg,
  MWAComp, MWAGIF, TransparentPanel{, ScrollView, CustomGridViewControl},
  {CustomGridView, GridView,} registry, Unit2, {Unit3,} StrUtils, inifiles;

type
  TForm1 = class(TForm)
    Notebook1: TNotebook;
    Button1: TButton;
    Edit1: TEdit;
    OpenDialog1: TOpenDialog;
    MWA_GIFCompressor1: TMWA_GIFCompressor;
    MWA_GIFDecompressor1: TMWA_GIFDecompressor;
    Button2: TButton;
    Edit2: TEdit;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    TransparentPanel2: TTransparentPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Edit3: TEdit;
    Button3: TButton;
    OpenDialog2: TOpenDialog;
    Label13: TLabel;
    Label14: TLabel;
    StringGrid1: TStringGrid;
    Label16: TLabel;
    Button4: TButton;
    OpenDialog3: TOpenDialog;
    Label15: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label22: TLabel;
    TransparentPanel1: TTransparentPanel;
    Image2: TImage;
    Panel1: TPanel;
    Button8: TButton;
    Label21: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Button9: TButton;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure GenStringTable(Table: Boolean);    // Заполняем StringGrid1 самолетами из инсталяционного пакета
    procedure Load_strings(st: Boolean);         // Загружаем строки из файла setup.cfg на форму
    procedure ErrorRATS(Err: Boolean);           // Если пакет не RATS, сбрасываем все поля формы
    procedure FS2004RegSearch(Sender: TObject);  // Поиск сима в реестре
    procedure FS2004RegWrite(Sender: TObject);   // Запись сима в реестр по пути opendialog
    procedure SelectInstall(Sender: TObject);    // Распознавание каталогов установки
    procedure DelEmptyStr(Sender: TObject);      // Удаление пустых строк (если встречается больше одной подряд)
    procedure GenFltsimXXX(Sender: TObject);     // Генерирование строк и запись во временный файл
    procedure FoldersCopy(Sender: TObject);      // Копирование папок
    procedure AirCFG(Sender: TObject);           // Запись найденных строк в существующий файл
    procedure DeleteSection(Sender: TObject);    // Удаление секций [fltsim] из файла aircraft.cfg
    procedure DeleteSectionRATS(Sender: TObject);// Удаление секций [fltsim] RATS из файла aircraft.cfg
    procedure DeleteSection_any(Sender: TObject);// Удаление секций [fltsim] (всех, которые содержат Texture=TIS)
    procedure ReNum(Sender: TObject);            // Перенумерация секций [fltsim]
    procedure FilesFoldersCopy(Sender: TObject); // Копирование содежимого папки в другую папку
    procedure IniRecord(Sender: TObject);        // Запись установленного пакета в файл RATS_installer_data.ini
    procedure Root_texture_check(Sender: TObject);// Проверка на наличие вложенных папок корневой папки .TIS
    procedure Notebook1PageChanged(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
  private
    { Private declarations }
  public
    xcell, ycell: integer;
    Column, Row: Longint;
    { Public declarations }
//////////////// ПРИМЕЧАНИЕ ///////////////////////////////////////////////////
// В комментариях встречаются параметры (например, Texture=TIS), которые справедливы для тестового инсталяционного пакета TESIS    
  end;

var
  Form1: TForm1;
  S {,RATScheckFolder str,}{ airline, Callsign, Painted, Model, Release, License} : string;
f: textfile;
archiver: TZipForge;
num, i: Integer;
ButtonTag: Integer;
MainArray: array [0..4000] of String;
mainPath: String; // Путь установки текстур
aircraft: String; // Устанавливаемый самолет
Fltsim: array [0..4000] of String;
tmpArr1, tmpArr2: Array [0..4000] of String;
h, j: Integer;
fltsimN, model_, title_: String;

implementation

uses Unit3;

{$R *.dfm}

{$WARN SYMBOL_PLATFORM OFF}

{ Копирование содержимого директории, вместе с поддиректориями.
Фукция копирует СОДЕРЖИМОЕ директории SourceDir в директорию TargetDir.
Копируются все файлы, подкаталоги, и файлы находящиеся в этих подкаталогах.
Аргумент StopIfNotAllCopied: если значение этого аргумента = True,
то при первой же ошибке копирования файла или папки, работы функции
прекратится а функуция вернёт False. В случае если этот аргумент = False,
то ошибки копирования учитываться не будут.
Аргумент OverWriteFiles: если True, то существующие файлы будут переписаны.
Зависимости: SysUtils, FileCtrl, Windows
Пример использования:

FullDirectoryCopy('C:\a', 'D:\b');
// Скопирует содержимое директории C:\a (не не саму директорию) в директорию D:\b}
function FullDirectoryCopy(SourceDir, TargetDir: string; StopIfNotAllCopied,
  OverWriteFiles: Boolean): Boolean;
var
  SR: TSearchRec;
  I: Integer;
begin
  Result := False;
  SourceDir := IncludeTrailingBackslash(SourceDir);
  TargetDir := IncludeTrailingBackslash(TargetDir);
  if not DirectoryExists(SourceDir) then
    Exit;
  if not ForceDirectories(TargetDir) then
    Exit;

  I := FindFirst(SourceDir + '*', faAnyFile, SR);
  try
    while I = 0 do
    begin
      if (SR.Name <> '') and (SR.Name <> '.') and (SR.Name <> '..') then
      begin
        if SR.Attr = faDirectory then
          Result := FullDirectoryCopy(SourceDir + SR.Name, TargetDir + SR.NAME,
            StopIfNotAllCopied, OverWriteFiles)
        else if not (not OverWriteFiles and FileExists(TargetDir + SR.Name))
          then
          Result := CopyFile(Pchar(SourceDir + SR.Name), Pchar(TargetDir +
            SR.Name), False)
        else
          Result := True;
        if not Result and StopIfNotAllCopied then
          exit;
      end;
      I := FindNext(SR);
    end;
  finally
    SysUtils.FindClose(SR);
  end;
end;




//Функция узнавания временной папки WinXP
function GetTempDir: String;
var
  Buf: array[0..1023] of Char;
begin
  SetString(Result, Buf, GetTempPath(Sizeof(Buf)-1, Buf));
end;


//Функция удаления папки с подпапками  (в программе не используется)
Function MyRemoveDir(sDir : String) : Boolean;
var
iIndex : Integer;
SearchRec : TSearchRec;
sFileName : String;
begin
Result := False;
sDir := sDir + '\*.*';
iIndex := FindFirst(sDir, faAnyFile, SearchRec);
while iIndex = 0 do begin
sFileName := ExtractFileDir(sDir)+'\'+SearchRec.Name;
if SearchRec.Attr = faDirectory then begin
if (SearchRec.Name <> '' ) and
(SearchRec.Name <> '.') and
(SearchRec.Name <> '..') then
MyRemoveDir(sFileName);
end else begin
if SearchRec.Attr <> faArchive then
FileSetAttr(sFileName, faArchive);
if NOT DeleteFile(sFileName) then
ShowMessage('Could NOT delete ' + sFileName);
end;
iIndex := FindNext(SearchRec);
end;
FindClose(SearchRec);
RemoveDir(ExtractFileDir(sDir));
Result := True
end;


// Удаление папок с подпапками 2
function DelDir(dir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_DELETE;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom  := PChar(dir + #0);
  end;
  Result := (0 = ShFileOperation(fos));
end;







// Кнопка открытия инсталяционного архива
procedure TForm1.Button1Click(Sender: TObject);
begin
// Проверяем, есть ли какая-нибудь временная папка RATS
if DirectoryExists(GetTempDir+'RATS_extracted') then
begin

//if NOT MyRemoveDir(GetTempDir+'RATS_extracted') then
if NOT DelDir(GetTempDir+'RATS_extracted') then
ShowMessage('Unable to delete RATS_extracted folder. Please remove this folder from TEMP directory to prevent installation errors.');
//DeleteTree(GetTempDir+'RATS_extracted');
//MessageDlg('Удалено!',mtConfirmation,[mbOK],0);
end;

archiver := TZipForge.Create(nil);
// try
//Metka1:
  with archiver do
  begin
    Opendialog1.InitialDir:=ExtractFilePath(Application.ExeName);
if not OpenDialog1.Execute then
     Exit;
//    OpenDialog1.Execute;
//s:=ExtractFilePath(OpenDialog1.FileName);
//If s='' then Exit; // Если пользователь ничего не выбрал, то прерываем выполнение
    // The name of the archive file
    FileName:=OpenDialog1.FileName;
    // Because we extract file from an existing archive,
    // we set Mode to fmOpenRead
    OpenArchive(fmOpenRead);

Edit2.Text:=OpenDialog1.FileName; // Напишем пользователю, что файл выбран

    // Set base (default) directory for all archive operations
    BaseDir:=GetTempDir+'RATS_extracted';
    // Extract test.txt file from the archive
    // to the default directory
    ExtractFiles('*.*');
    CloseArchive();


/// Проверки правильности расположения и содержимого файлов///
if FileExists(GetTempDir+'RATS_extracted'+'\readme.txt') then
   begin
Button4.Enabled:=true; // Подсвечиваем кнопку ридми
   end
  else
  Button4.Enabled:=false;
//exit;

if FileExists(GetTempDir+'RATS_extracted'+'\setup.cfg') then
     begin
      AssignFile(f,GetTempDir+'RATS_extracted'+'\Setup.cfg');
      Reset(f);
      Readln(f, S);
      CloseFile(f);
if s<>'[RATSSetup]' then
   ErrorRATS(true);
if S='[RATSSetup]' then
  begin
   Load_strings(true);


  if FileExists(GetTempDir+'RATS_extracted'+'\logo.gif') then
   begin
Button5.Enabled:=true;  // Все загружено, можно переходить к указанию пути к симу на PageIndex:=1
Image1.Picture.LoadFromFile(GetTempDir+'RATS_extracted'+'\logo.gif');
   end
   else
  ErrorRATS(true);

  end;
end
else
ErrorRATS(true);
  end;
end;


///// Загрузим все строчки из setup.cfg в наши label //////////////////////////////////
procedure TForm1.Load_strings(st: Boolean);
var
airline, Callsign, Textures, ICAO, Release, Decription : string;
begin
reset(f);
while not Eof(f) do
begin
  readln(f, airline);
  if pos('Airline=', airline)>0 then
  begin
    form1.Label2.Caption:=copy(airline,9,50);   // Читаем и записываем Airline
    break;
  end;
end;
closefile(f);
/////////////////////////////////////
reset(f);
while not Eof(f) do
begin
  readln(f, Textures);
  if pos('Textures Pack=', Textures)>0 then
  begin
    form1.Label4.Caption:=copy(Textures,15,30);   // Читаем и записываем Textures Pack
    break;
  end;
end;
closefile(f);
/////////////////////////////////////
reset(f);
while not Eof(f) do
begin
  readln(f, Callsign);
  if pos('Callsign=', Callsign)>0 then
  begin
    form1.Label6.Caption:=copy(Callsign,10,30);   // Читаем и записываем Callsign
    break;
  end;
end;
closefile(f);
/////////////////////////////////////
reset(f);
while not Eof(f) do
begin
  readln(f, ICAO);
  if pos('ICAO=', ICAO)>0 then
  begin
    form1.Label8.Caption:=copy(ICAO,6,20);   // Читаем и записываем ICAO
    break;
  end;
end;
closefile(f);
//////////////////////////////////////
reset(f);
while not Eof(f) do
begin
  readln(f, Release);
  if pos('Release Date=', Release)>0 then
  begin
    form1.Label10.Caption:=copy(Release,14,50);   // Читаем и записываем Release Date=
    break;
  end;
end;
closefile(f);
////////////////////////////////////
reset(f);
while not Eof(f) do
begin
  readln(f, Decription);
  if pos('Decription=', Decription)>0 then
  begin
    form1.Label12.Caption:=copy(Decription,12,27);   // Читаем и записываем Decription
    break;
  end;
end;
closefile(f);
//////////////////
end;


// Если пакет не RATS, сбрасываем все поля формы
procedure TForm1.ErrorRATS(Err: Boolean); //Если условия не выполняются, пишем, что ошибочка!
begin
// Далее очистка меток, картинок, кнопок, полей ввода
Button4.Enabled:=false;
Label2.Caption:='';
Label4.Caption:='';
Label6.Caption:='';
Label8.Caption:='';
Label10.Caption:='';
Label12.Caption:='';
//Label15.Caption:='';
//Edit3.Text:='';
Button4.Enabled:=false;
Button5.Enabled:=false;
Image1.Picture.Graphic := nil;
MessageDlg('This is not a RATS installation file',mtWarning,[mbOK],0);
//DeleteTree(GetTempDir+'RATS_extracted'); // Удаление распакованного ранее
end;


// Ищем симулятор в реестре
procedure TForm1.FS2004RegSearch(Sender: TObject);
var
      Data : Array of Byte;
      L : TStringList;
      S : String;
      sz : Word;
      I,J : Word;
      R: TRegistry;
begin
       R := TRegistry.Create;
      L := TStringList.Create;
      with R do
          begin
  // Задать корневую секцию
              RootKey := HKEY_LOCAL_MACHINE;
  // Открыть подсекцию
              OpenKey('Software\Microsoft\Microsoft Games\Flight Simulator\9.0\', False);
  // Получить названия элементов
              GetValueNames(L);
              If L.Count > 0 Then
  begin
  for I := 0 to L.Count- 1 do
  begin
  // Узнать тип данных каждого элемента
 case GetDataType(L[I]) of
  // Строка?
 rdString,
 rdExpandString :
 S := {'"' +} ReadString(L[I]) {+ '"'};
  // Целочисленный?
 rdInteger :
 S := IntToStr(ReadInteger(L[I]));
  // Бинарный?
 rdBinary :
 begin
  sz := GetDataSize(L[I]);
  SetLength(Data, sz);
  ReadBinaryData(L[I], Data[0], sz);
  S := '';
  for J := 0 to sz - 1 do
  begin
//  S := S + Format('%2x',[Data[I]]); // Убрано, потому что выдавалась ошибка access violation при чтении одной строки
  end;
 end;
  // Неизвестный?
 rdUnknown :
 S := 'Unknown';
  end;
  // Вывод результата
  if L[i]='EXE Path' then  // Если найдено EXE Path, то напишем в Edit3 Путь к симу S
    begin
      Edit3.Text:=S;
//      Memo1.Lines.Add(L[I]);
//      Memo1.Lines.Add(S);
    end;
//    else
  end;
              end;
          Free;
        end;
      L.Free;
end;



// Запись сима в реестр по пути opendialog
procedure TForm1.FS2004RegWrite(Sender: TObject);
Var
R: TRegistry;

begin
R := TRegistry.Create;
        R.RootKey := HKEY_LOCAL_MACHINE;
        R.OpenKey('Software\Microsoft\Microsoft Games\Flight Simulator\9.0\', True);
        R.WriteString('EXE Path', ExtractFilePath(OpenDialog2.FileName));
        R.CloseKey;
R.Free;
end;


procedure TForm1.FormCreate(Sender: TObject);
//var
//Reg: TRegistry;
//  S: TStringList;
//  i: Integer;
begin
StringGrid1.OnDrawCell:=nil;
Column:=0;// Изначальные св-ва StringGrid1
Row:=0;


FS2004RegSearch(self);  // Поиск симулятора в реестре
Label24.Caption:=Edit3.Text;
if Edit3.Text='' then
// if NoteBook1.PageIndex=1 then
begin
MessageDlg('               FS2004 is not correctly installed.'#13+'Please locate installation path manually during install.',mtWarning,[mbOK],0);
Label23.Caption:='FS2004 not found.';
end;

Label2.Caption:='';
Label4.Caption:='';
Label6.Caption:='';
Label8.Caption:='';
Label10.Caption:='';
Label12.Caption:='';
//Label24.Caption:='';
NoteBook1.PageIndex:=0;
//Edit3.Text:='';
Button4.Enabled:=false;
Button5.Enabled:=false;
Button6.Enabled:=false;
StringGrid1.ColWidths[0] := 180;
StringGrid1.ColWidths[1] := 150;
StringGrid1.ColWidths[2] := 80;
StringGrid1.ColWidths[3] := 80;
StringGrid1.Cells[0,0]:='Description';
StringGrid1.Cells[1,0]:='Aircraft';
StringGrid1.Cells[2,0]:='Textures';
StringGrid1.Cells[3,0]:='Install';
//StringGrid1.Cells[3,0]:='Install/UnInstall';
StringGrid1.RowCount:=10;



if DirectoryExists(GetTempDir+'RATS_extracted') then
begin
//if NOT MyRemoveDir(GetTempDir+'RATS_extracted') then
if NOT DelDir(GetTempDir+'RATS_extracted') then
ShowMessage('Unable to delete temp files');
end
else
exit
end;


procedure TForm1.Button2Click(Sender: TObject);
var i: Integer;
begin
i:=NoteBook1.PageIndex;    // Перелистывание страниц
NoteBook1.PageIndex:=i+1;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
Application.Terminate  // Кнопка Отмена
end;



// Проверка на наличие вложенных папок корневой папки .TIS
procedure TForm1.Root_texture_check(Sender: TObject);
var
x17: TStringlist;
MyIni: TIniFile;
r: Integer;
title_, Folder_: String;
SearchRec: TSearchRec;

begin
           // Читаем файл RATS_installer_data.ini и смотрим, есть ли устанавливаемый пакет
           x17:=TStringlist.Create;
           MyIni:=TIniFile.Create(Edit3.Text+'\'+'RATS_installer_data.ini');
           MyIni.ReadSection(label2.Caption, x17);

                     for r:=0 to x17.Count-1 do
                        begin  {3}
                           title_:=x17.Strings[r];
                           Folder_:=MyIni.ReadString(label2.Caption,title_,'');

/////////////////////////// Распознаем, где у нас вложенные папки, а где корневые ///////////////////////////////////////////////////
                            if copy(after(Folder_,'texture'),6,1)<>'' then
                               begin
                                     // Удалим соотв. вложенные папки
                                 //MyRemoveDir(Folder_);
                                 //ShowMessage(copy(after(Folder_,'texture'),6,100));   // Для теста
                               end
                                else
                                  begin
                                    // Проверим, есть ли в этой папке вложенные папки
                                     If FindFirst(Folder_+'\*', faDirectory, SearchRec)=0 then
                                       repeat
                                         if SearchRec.Name='.' then
                                         FindNext(SearchRec);
                                         if SearchRec.Name='..' then
                                         FindNext(SearchRec);

                                         //Showmessage(SearchRec.Name);
                                         // Если найдена какая-нибудь папка
                                         if SearchRec.Attr=faDirectory then
                                            begin
                                               //Showmessage('Вложенные папки еще остались! '+SearchRec.Name);   // Для теста
                                               Exit;
                                            end;

                                       until FindNext(SearchRec) <> 0;
                                       FindClose(SearchRec);

                                     // Удалим папку, если не найдены вложенные
                                     //MyRemoveDir(Folder_);
                                     DelDir(Folder_);
                                     ShowMessage('Удалено '+Folder_);                            // Для теста
                                     //RemoveDir(Folder_);
                                  end;
/////////////////////////// Распознаем, где у нас вложенные папки, а где корневые  конец ///////////////////////////////////////////////////
end;
x17.Free;
MyIni.Free;
end;



// Кнопка Next
procedure TForm1.Button5Click(Sender: TObject);
var
i, m: Integer;      // КНОПКА FINISH
MyIni: TIniFile;
x15: TStringlist;
//CfgFile: TextFile;
//rat5: String;
title_, Folder_: String;

//DeleteSection (модифицированный)
tt, airfile: TextFile;
sq, sj: String;
x10, x11: TStrings;
w: Integer;
SearchRec: TSearchRec;

// Renum (модифицированный)
srr: String;
x7: TStrings;
k: Integer;

// DelEmptyStr (модифицированный)
sw: String;
x8: TStrings;

// Finish check for not installed aircrafts
l: Integer;
fg: String;

label Metka4;
label Metka7;
label Metka5;

begin
if Button5.Caption='Finish' then
begin
  // проверка всех флагов 'OK' в последнем столбце StringGrid1.
  for l:=0 to ButtonTag do
    begin
       //
       fg:=StringGrid1.Cells[3,l];
       if fg='INSTALL?' then       // Если встречается хотя бы одна запись Install
         begin
           if MessageDlg('You have not installed ALL repaints. Do you want to return and correct this?',mtInformation,[mbYes, mbNo],0)=mrNo then
              goto Metka5;
            Exit;
         end;
     end;

Metka5:
MessageDlg('       Thank You for choosing RATS packages!'+#13+'Go to www.trafficsystem.ru for more flightplans and repaints.',mtInformation, [mbOK],0);
Application.Terminate;
end;

// Это в том случае, если не найден сим в реестре и мы попали на страницу 1.
if (NoteBook1.PageIndex=1) and (Edit3.Text<>'') then NoteBook1.PageIndex:=2;
if (copy(label4.Caption,0,6)='Update') and (Edit3.Text<>'') then NoteBook1.PageIndex:=2; // Если пакет апдейтовый, то не будем предупреждать пользователя о установленном пакете Tesis

   if FileExists(Edit3.Text+'\'+'RATS_installer_data.ini') then
        begin
           if NoteBook1.PageIndex<>0 then Exit; // Если находимся на странице отличной от страницы выбора инсталяционного пакета, то не обращаем внимания на файл базы данных
//           ShowMessage('Читать '+Edit3.Text+'\'+'RATS_installer_data.ini');

           // Читаем файл RATS_installer_data.ini и смотрим, есть ли устанавливаемый пакет
           x15:=TStringlist.Create;
           MyIni:=TIniFile.Create(Edit3.Text+'\'+'RATS_installer_data.ini');
           MyIni.ReadSection(label2.Caption, x15);
            if x15.Count>0 then
               begin {5656}
                 //ShowMessage(IntToStr(x15.Count));
                 if MessageDlg('You have '+label2.Caption+' airline already installed. Do you want to delete previous installed repaints?'{+#13+'Note. If you are applying an update, click "NO".'},mtInformation,[mbYes,mbNo],0)=mrNo then
                  begin
                   x15.Free;  // Ответ No
                   MyIni.Free;

                   Button5.Enabled:=false; // Кнопку Next отключаем
                   Edit2.Text:='';         // Поле с путем очищаем
                   NoteBook1.PageIndex:=0; // Сохраняем первую страницу инсталлера
                   label2.Caption:='';
                   label4.Caption:='';
                   label6.Caption:='';      // Очистим все label
                   label8.Caption:='';
                   label10.Caption:='';
                   label12.Caption:='';
                   Image1.Picture.Graphic := nil; // И картинку
                   Button4.Enabled:=false;        // Заглушим кнопу ридми
                   Exit;
                   //goto Metka4;         // Это если мы будем предоставлять пользователю возможность устанавливать новые самолеты в уже установленный пакет.
                                          // Бред. А вдруг? Тогда Exit убрать, а также 3 строки выше.
                  end;
//                         ShowMessage('Удалено!');
                     for m:=0 to x15.Count-1 do
                        begin  {3}
                           title_:=x15.Strings[m];
//                           Showmessage(title_); // Закомментировать. Для теста
                           Folder_:=MyIni.ReadString(label2.Caption,title_,'');
//                           Showmessage(Folder_); // Закомментировать. Для теста


/////////////////////////// Распознаем, где у нас вложенные папки, а где корневые ///////////////////////////////////////////////////
{                            if copy(after(Folder_,'texture'),6,1)<>'' then
                               begin
                                     // Удалим соотв. вложенные папки
                                 MyRemoveDir(Folder_);
                                 //ShowMessage('Вложенная папка '+copy(after(Folder_,'texture'),6,100)+' подлежит удалению.');   // Для теста
                               end
                                else
                                  begin
                                    // Проверим, есть ли в этой папке вложенные папки
                                     If FindFirst(Folder_+'\*', faDirectory, SearchRec)=0 then
                                       repeat
                                         if SearchRec.Name='.' then
                                         FindNext(SearchRec);
                                         if SearchRec.Name='..' then
                                         FindNext(SearchRec);

                                         //Showmessage(SearchRec.Name);
                                         // Если найдена какая-нибудь папка
                                         if SearchRec.Attr=faDirectory then
                                            begin
                                               //Showmessage('Вложенная папка есть! '+SearchRec.Name);
                                               goto Metka7;
                                            end;

                                       until FindNext(SearchRec) <> 0;
                                       FindClose(SearchRec);

                                     //ShowMessage(Folder_);                            // Для теста
                                     // Удалим папку, если не найдены вложенные
                                     MyRemoveDir(Folder_);                         // Включить
                                  end;  }
/////////////////////////// Распознаем, где у нас вложенные папки, а где корневые  конец ///////////////////////////////////////////////////



/////////////////////////// Удаление папок ///////////////////////////////////////////////////
// Здесь сделать распознавание корня папки и удалять только корневую папку вместе с вложенными.
{                            if copy(after(Folder_,'texture'),6,1)<>'' then
                               begin
                                  ShowMessage(before(Folder_,'.TIS\'));
                                     // Удалим соотв. вложенные папки
                                  MyRemoveDir(Folder_);
                               end; }
/////////////////////////// Удаление папок конец ///////////////////////////////////////////////////


                           // Удалим соотв. папки и подпапки.
  {Включить!}                         //MyRemoveDir(Folder_);
                                      DelDir(Folder_);
//Metka7:

//                         //Удалим секции aircraft.cfg, соотв. title_ и texture.TIS
//                         //DeleteSection, модифицированная на прием различных ассоциированных файлов aircraft.cfg
                           //ShowMessage(before(Folder_,'texture'));  // Закомментировать. Для теста
                                     w:=-1;
                                x10:=TStringlist.Create;
                                x11:=TStringlist.Create;
                                AssignFile(airfile,before(Folder_,'texture')+'aircraft.cfg');

                                append(airfile);
                                WriteLn(airfile, ''); // Добавим пустую строку для корректного чтения файла
                                CloseFile(airfile);

                                //MyRemoveDir(GetTempDir+'RATS_extracted\temp_Ini\'); // Удалим папку, если она была
                                DelDir(GetTempDir+'RATS_extracted\temp_Ini\'); // Удалим папку, если она была

                                if not DirectoryExists(GetTempDir+'RATS_extracted\temp_Ini\') then   // Создадим временную папку
                                    if not CreateDir(GetTempDir+'RATS_extracted\temp_Ini\') then
                                    raise Exception.Create('Cannot create temp_Ini directory!');


                                /////////Добавим пустые строки между секциями fltsim. //////////////////
                                reset(airfile);
                                 while not eof(airfile) do
                                        begin
                                           readln(airfile, sq);
                                           if copy(sq,0,8)='[fltsim.' then
                                              begin
                                                 x11.Add('');
                                              end; {if}

                                           if sq='[General]' then
                                              begin
                                                 x11.Add('');
                                              end; {if}

                                           x11.Add(sq);
                                        end; {while}
                                closefile(airfile);
                                // Для указания пути к файлу используем отсеченную Folder_
                                x11.SaveToFile(before(Folder_,'texture')+'aircraft.cfg');
                                /////////Конец Добавим пустые строки между секциями [fltsim. //////////////////

                                ///////////////// Разбираем файл на запчасти ///////////////////////////////////
                                reset(airfile);
                                      while not eof(airfile) do
                                        begin
                                //        i:=0;
                                          readln(airfile, sq);
                                          if copy(sq,0,8)='[fltsim.' then  // Читаем файл до
                                begin
                                inc(w);
                                AssignFile(tt,GetTempDir+'RATS_extracted\temp_Ini\fltsim.'+IntToStr(w)+'.txt');
                                rewrite(tt);
                                Append(tt);
                                writeln(tt, sq);

                                repeat
                                        readln(airfile, sq);
                                        writeln(tt,sq);
                                until copy(sq,0,1)=''; // Читаем и записываем в файлы до этого момента
                                closefile(tt);
                                end; (*if [fltsim.*)

                                x10.Add(sq);
                                        end; (*while*)
                                x10.Add('');                     // Добавим пустую строку для разрыва между [General] и секциями [fltsim.]
                                closefile(airfile);
                                ///////////////// Закончили разбирать файл на запчасти /////////////////////////

                                ///////////Отфильтруем из временной папки файлы с title_
                                If FindFirst(GetTempDir+'RATS_extracted\temp_Ini\*.*', faAnyFile, SearchRec)=0 then
                                repeat

                                if SearchRec.Name='.' then
                                FindNext(SearchRec);
                                if SearchRec.Name='..' then
                                FindNext(SearchRec);

                                assignfile(tt, GetTempDir+'RATS_extracted\temp_Ini\'+SearchRec.Name);
                                sj:='';
                              if FileExists(GetTempDir+'RATS_extracted\temp_Ini\'+SearchRec.Name) then
                              begin {22}
                                reset(tt);
                                 while not eof(tt) do
                                   begin
                                     readln(tt, sq);
                                     if sq='title='+title_ then
                                     // if pos('title=', sq)>0 then
                                        begin
                                           //ShowMessage(sq);
                                           sj:=sq;
                                        end;
                                   end;
                                closefile(tt);
                              end; {22}
                                if (sj<>'') then
                                        deletefile(GetTempDir+'RATS_extracted\temp_Ini\'+SearchRec.Name);

                                until FindNext(SearchRec) <> 0;
                                FindClose(SearchRec);
                                ///////////Конец Отфильтруем из временной папки файлы с Texture=TIS ////////////////

                                ///////////////// Собираем новый файл aircraft.cfg //////////////////////////////
                                //Первое: добавим в общий список x10 (это секция general и все остальное) Уже добавлено в x10

                                // Затем читаем файлы и добавляем в общий список из всех файлов по порядку
                                If FindFirst(GetTempDir+'RATS_extracted\temp_Ini\*.*', faAnyFile, SearchRec)=0 then
                                repeat
                                //SearchRec.Name - имя файла

                                if SearchRec.Name='.' then
                                FindNext(SearchRec);
                                if SearchRec.Name='..' then
                                FindNext(SearchRec);

                                if FileExists(GetTempDir+'RATS_extracted\temp_Ini\'+SearchRec.Name) then
                                  begin
                                assignfile(tt, GetTempDir+'RATS_extracted\temp_Ini\'+SearchRec.Name);
                                reset(tt);
                                 while not eof(tt) do
                                   begin
                                     readln(tt, sq);
                                     x10.Add(sq);
                                   end;
                                closefile(tt);
                                   end; {if file exists}

                                until FindNext(SearchRec) <> 0;
                                FindClose(SearchRec);
                                x10.SaveToFile(before(Folder_,'texture')+'aircraft.cfg');
                                ///////////////// Конец Собираем новый файл aircraft.cfg ////////////////////////
                                x10.Free;
                                   // Здесь вписать процедуру удаления двух подряд пустых строк.

                                   
                                x11.Free;
                                //MyRemoveDir(GetTempDir+'RATS_extracted\temp_Ini\');
                                DelDir(GetTempDir+'RATS_extracted\temp_Ini\');



                                         // Сделаем перенумерацию
                                         // Модификация Renum
                                         k:=-1;
                                        x7:=TStringlist.Create;
                                        AssignFile(airfile,before(Folder_,'texture')+'aircraft.cfg');

                                        append(airfile);
                                        WriteLn(airfile, ''); // Добавим пустую строку для корректного чтения файла
                                        CloseFile(airfile);

                                        reset(airfile);
                                              while not eof(airfile) do
                                                begin
                                                  readln(airfile, srr);
                                                  if copy(srr,0,8)='[fltsim.' then  // Читаем файл до
                                        begin
                                        inc(k);
                                        x7.Add('[fltsim.'+IntToStr(k)+']');
                                        repeat
                                        readln(airfile, srr);
                                        x7.Add(srr);

                                         until copy(srr,0,1)=''; // Читаем и записываем в файлы до этого момента
                                        end; (*if [fltsim.*)
                                        x7.Add(srr);
                                                end; (*while*)
                                        closefile(airfile);
                                        x7.SaveToFile(before(Folder_,'texture')+'aircraft.cfg');
                                        x7.Free; 



                                 // Удалим пустые строки
                                 // Модификация DelEmptyStr
                                 x8:=TStringlist.Create;
                                AssignFile(airfile,before(Folder_,'texture')+'aircraft.cfg');
                                reset(airfile);
                                while not eof(airfile) do
                                begin
                                readln(airfile, sw);
                                x8.Add(sw);
                                      if sw='' then
                                      repeat
                                           readln(airfile, sw);
                                            if sw<>'' then
                                              begin
                                                x8.Add(sw);
                                              end;
                                      until sw<>'';
                                end; //while not eof
                                closefile(airfile);
                                x8.Delete(x8.Count-1);    // Удалим последний элемент списка (квадратик)
                                x8.SaveToFile(before(Folder_,'texture')+'aircraft.cfg');
                                x8.Free;


                        end;   {3}
                          // Проверим еще раз пустая ли корневая папка .TIS
//                             Root_texture_check(self);

                         // Удалим из ini файла секцию Tesis
  {Включить!}                       MyIni.EraseSection(label2.Caption);
               end;  {5656}
           x15.Free;
           MyIni.Free;
        end;
Metka4:
i:=NoteBook1.PageIndex;
NoteBook1.PageIndex:=i+1;
if Edit3.Text<>'' then NoteBook1.PageIndex:=i+2; // Если сим определился корректно, то прыгаем сразу на 2 страницы вперед.
end;


procedure TForm1.Button6Click(Sender: TObject);
var i: Integer;
begin
i:=NoteBook1.PageIndex;        // Кнопка назад
if Button5.Enabled=false then exit;
NoteBook1.PageIndex:=i-1;
If Edit2.Text='' then
exit
else Button5.Enabled:=true;
end;

procedure TForm1.Button3Click(Sender: TObject);
//var
//st: String;
begin
if not OpenDialog2.Execute then  // Если путь выбран кнопкой
     Exit;
Edit3.Text:=ExtractFilePath(OpenDialog2.FileName);
if FileExists(Edit3.Text+'\Modules\terrain.dll') then
 begin
    Button5.Enabled:=true;    // Проверка симулятора на "вшивость"
    FS2004RegWrite(self);    // Если не найдена строка EXE Path, то нужно записать в реестр сим.
 end
 else
 Button5.Enabled:=false;
end;


procedure TForm1.Button4Click(Sender: TObject);
begin                                           // Загрузка и показ файла Readme
ShellExecute(0,nil,PChar(GetTempDir+'RATS_extracted'+'\Readme.txt'),nil,nil,SW_SHOWNORMAL);
end;




// Заполняем StringGrid1 самолетами из инсталяционного пакета
procedure TForm1.GenStringTable(Table: Boolean);
var
f: textfile;
s: String;
SR:TSearchRec; // поисковая переменная
FindRes:Integer; // переменная для записи результата поиска

begin
ButtonTag:=-2;
i:=0;
FindRes:=FindFirst(GetTempDir+'RATS_extracted\Textures\*.*',faDirectory,SR); // задание условий поиска и начало поиска
While FindRes=0 do // пока мы находим файлы (каталоги), то выполнять цикл
   begin
      inc(i);
      inc(ButtonTag);
      //MainArray[i]:=FindRes;
// добавление в список название найденного элемента
//чтобы не было файлов . и..
if (SR.Attr=faDirectory) and ((SR.Name='.')or(SR.Name='..')) then
begin
FindRes:=FindNext(SR);
Continue;
end;

      MainArray[ButtonTag]:=SR.Name; // Запишем имя в массив на всякий случай

AssignFile(f,GetTempDir+'RATS_extracted\Textures\'+SR.Name+'\[Fltsim.xxx].txt');
//label18.Caption:= GetTempDir+'RATS_extracted\Textures\'+SR.Name+'\[Fltsim.xxx].txt';
 reset(f);
      while not Eof(f) do // Загружаем всю инфу по пакету в поля StringGrid1
begin
  readln(f, s);
  if pos('description=', s)>0 then
  begin
    // Здесь нужно сосчитать количество символов до двойного слэша (для сокращения строки в stringgrid1)

    form1.StringGrid1.Cells[0,ButtonTag]:=copy(s,13,300);    // Инфа по разработчикам
    //break;
  end;
end;
closefile(f);

reset(f);
while not Eof(f) do  // Загружаем всю инфу по пакету в поля StringGrid1
begin
  readln(f, s);
  if pos('texture=', s)>0 then
  begin
                         // Инфа по текстурам
    form1.StringGrid1.Cells[2,ButtonTag]:='texture.'+copy(s,9,3);
    //break;
  end;
end;
closefile(f);

      StringGrid1.Cells[3,ButtonTag]:='INSTALL?';
      StringGrid1.Cells[1,ButtonTag]:=SR.Name;
      FindRes:=FindNext(SR); // продолжение поиска по заданным условиям
   end;
  if ButtonTag>10 then
  begin
StringGrid1.RowCount:=ButtonTag+1; // Сделаем количество строк таблицы таким же, как и количество самолетов в пакете
  end;
FindClose(SR); // закрываем поиск
end;




////////////////// Распознавание откуда и куда копировать
procedure TForm1.SelectInstall(Sender: TObject);
//var
//s: String;
begin
 OpenDialog3.InitialDir:=Edit3.Text+'\Aircraft';
 //OpenDialog3.Execute;
if not OpenDialog3.Execute then
     Exit;
// s:=Opendialog3.FileName;
// if s='' then exit;  // Если пользователь ничего не выбрал, то не продолжать

// Папка откуда копировать является составной из ячейки и пути к временной папке с распакованным содержимым
//aircraft:=GetTempDir+'RATS_extracted\Textures\'+MainArray[row];
aircraft:=GetTempDir+'RATS_extracted\Textures\'+MainArray[StringGrid1.row]+'\'+StringGrid1.Cells[2,ButtonTag];
label15.Caption:=aircraft;                      // ТЕСТ
// Путь к самолету КУДА будет установка
mainPath:=ExtractFilePath(Opendialog3.FileName);
label17.Caption:=mainPath;                      // ТЕСТ
// aircraft:=StringGrid1.Cells[1,2];
// label15.Caption:=GetTempDir+'RATS_extracted\Textures\'+StringGrid1.Cells[1,Column];

end;


///////// Перелистывание страницы ////////////////
procedure TForm1.Notebook1PageChanged(Sender: TObject);
begin
if NoteBook1.PageIndex=1 then
Button6.Enabled:=true;

if NoteBook1.PageIndex=1 then
if FileExists(Edit3.Text+'\Modules\terrain.dll') then
 begin
    Button5.Enabled:=true;    // Проверка симулятора на "вшивость"
 end
 else
 Button5.Enabled:=false;

if NoteBook1.PageIndex=2 then
 begin
    //
   GenStringTable(true);  //Построение списка устанавливаемых самолетов
   Button5.Caption:='Finish';
   Button6.Enabled:=false;
 end;
end;



// Генерирование строк [fltsim.] и запись во временный файл
procedure TForm1.GenFltsimXXX(Sender: TObject);
var
s, st, tmpstr, tmpstr2, s1: String;
{f, }f2, tempfile, airfile: TextFile;
L, u, m: Integer;
MyarrStr: array [0..10000] of String;
x:TStrings;
begin
 //
//Assignfile(tempfile, 'c:\temp.txt');
Assignfile(tempfile, GetTempDir+'RATS_extracted'+'\temp.txt');
AssignFile(airfile,mainPath+'aircraft.cfg');

//AssignFile(f,GetTempDir+'RATS_extracted'+'\[Fltsim.XXX]_temp.txt');
AssignFile(f2,GetTempDir+'RATS_extracted\Textures\'+MainArray[StringGrid1.row]+'\[Fltsim.XXX].txt');
//Rewrite(f); //Сделаем файлик
Rewrite(tempfile);   //Сделаем файлик
label18.Caption:=GetTempDir+'RATS_extracted\Textures\'+MainArray[StringGrid1.row]+'\[Fltsim.XXX].txt';

//////////////////
// Здесь процедура вычисления номеров fltsim.xxx
u:=0;
reset(airfile);
while not Eof(airfile) do
begin
   Inc(u);
   ReadLn(airfile,tmpstr);
   if copy(tmpstr,1,7)='[fltsim' then
     begin
// Запомним номера строк, в которых встречается '[fltsim' в массив
         MyArrStr[u]:=tmpstr;

//Memo1.Lines.Add(MyArrStr[u]);
     Rewrite(tempfile);
     WriteLn(tempfile, tmpstr); // записываем строку, с которой будем потом работать, в удобный текстовый файл
     CloseFile(tempfile);
     end;
//label1.Caption:=inside(tmpstr,'.',']');

reset(tempfile);
Readln(tempfile,tmpstr2);
if tmpstr2='' then     // Если в файле было пусто, то назначаем насильно
fltsimN:=IntToStr(-1)
else

////// Найдем, что в середине строки
fltsimN:=inside(tmpstr2,'.',']');     // ВОТ НАШ НОМЕР FLTSIM.XXX ИЗ AIRCRAFT.CFG ! ! !
closefile(tempfile);
/////////////////
end;
//closefile(airfile);
///////////-----------------------------------///////////////////////////////////
// НЕ УДАЛЯТЬ!!!!
//Append(f);    // Запишем в секцию sim= имя файла, выбранного в диалоге, но без расширения
L := Length(ExtractFileExt(ExtractFileName(OpenDialog3.FileName)));
s:= 'sim='+Copy(ExtractFileName(OpenDialog3.Filename),1,(Length(ExtractFileName(OpenDialog3.Filename))-L));
//WriteLn(f, 'sim='+Copy(ExtractFileName(OpenDialog3.Filename),1,(Length(ExtractFileName(OpenDialog3.Filename))-L)) );
//closefile(f);
// НЕ УДАЛЯТЬ!!!!


label22.Caption:='Последний номер fltsim.='+fltsimN;
x:=TStringList.Create;
m:=StrToInt(fltsimN);

//////////////////// Генерируем новый файл fltsim.xxx (временный [fltsim.xxx]_temp.txt) ////////
reset(f2);
while not Eof(f2) do
begin
  readln(f2, st);
   if st='[fltsim.XXX]' then
    m:=m+1;

if copy(st,0,4)='sim=' then
s1:=copy(st,5,50);

x.Text:=AnsiReplaceStr(x.Text,'[fltsim.XXX]','[fltsim.'+IntToStr(m)+']');
x.Text:=AnsiReplaceStr(x.Text,'sim='+s1, s);

    x.Add(st);
end;
x.Delete(0);  // Удаление нескольких строк из начала файла [fltsim.XXX].txt
x.Delete(1);

x.SaveToFile(GetTempDir+'RATS_extracted'+'\temp_fltsim.XXX.txt');
closefile(f2);
x.Free;
closefile(airfile);
end;



// Копирование папок
procedure TForm1.FoldersCopy(Sender: TObject);
var OpStruc: TSHFileOpStruct;
frombuf, tobuf: Array [0..128] of Char;
begin FillChar( frombuf, Sizeof(frombuf), 0 );
FillChar( tobuf, Sizeof(tobuf), 0 );
StrPCopy( frombuf, aircraft );  // Путь откуда копировать
StrPCopy( tobuf, MainPath );    // Путь куда копировать   // Определены в процедуре SelectInstall
with OpStruc do begin
   Wnd := Handle;
   wFunc := FO_COPY;
   pFrom := @frombuf;
   pTo := @tobuf;
   fFlags := FOF_NOCONFIRMATION or FOF_RENAMEONCOLLISION;
   fAnyOperationsAborted := False;
   hNameMappings := Nil;
   lpszProgressTitle := Nil;
end;
ShFileOperation( OpStruc );
end;



// Удаление пустых строк из aircraft.cfg (если больше одной подряд)
procedure TForm1.DelEmptyStr(Sender: TObject);
var
airfile: TextFile;
sw: String;
x8: TStrings;

begin
x8:=TStringlist.Create;
AssignFile(airfile,mainPath+'aircraft.cfg');
reset(airfile);
while not eof(airfile) do
begin
readln(airfile, sw);
x8.Add(sw);
      if sw='' then
      repeat
           readln(airfile, sw);
            if sw<>'' then
              begin
                x8.Add(sw);
              end;
      until sw<>'';
end; {while not eof}
closefile(airfile);
//x8.Delete(x8.Count-1); // Удалим последний элемент. Он получался в виде квадратика в конце файла aircraft.cfg
x8.SaveToFile(mainPath+'aircraft.cfg');
x8.Free;

end;




// Перенумерация секций [fltsim]
procedure TForm1.ReNum(Sender: TObject);
var
{tt, }airfile: TextFile;
srr: String;
x7: TStrings;
i: Integer;

begin
i:=-1;
x7:=TStringlist.Create;
AssignFile(airfile,mainPath+'aircraft.cfg');

append(airfile);
WriteLn(airfile, ''{#13}); // Добавим пустую строку для корректного чтения файла
CloseFile(airfile);

// Здесь д/б процка записи строк [fltsim.], если они находятся в начале фафла
      reset(airfile);
      while not eof(airfile) do
        begin
          readln(airfile, srr);
          if copy(srr,0,8)='[fltsim.' then  // Читаем файл до
begin
inc(i);
//AssignFile(tt,'c:\test\'+IntToStr(i)+'1.txt');    // Не удалять! Это для будущей процедуры удаления секций не RATS
//rewrite(tt);
//Append(tt);
//        writeln('[fltsim.'+IntToStr(i)+']');
x7.Add('[fltsim.'+IntToStr(i)+']');
repeat
readln(airfile, srr);
//        writeln(tt,srr);
x7.Add(srr);

 until copy(srr,0,1)=''; // Читаем и записываем в файлы до этого момента
//closefile(tt);


end; (*if [fltsim.*)
x7.Add(srr);
        end; (*while*)
closefile(airfile);
//Memo1.Lines.AddStrings(x7);
x7.SaveToFile(mainPath+'aircraft.cfg');
//x7.SaveToFile(mainPath+'aircraftrenum.cfg');
x7.Free;
end;




// Удаление секций [fltsim.] из файла aircraft.cfg  (все, которые содержат Texture=TIS)
// Отличие от DeleteSection только в одной проверке sj
procedure TForm1.DeleteSection_any(Sender: TObject);
var
tt, airfile: TextFile;
sq, sj: String;
x10, x11: TStrings;
w: Integer;
SearchRec: TSearchRec;
label Metka2;

begin
w:=-1;
x10:=TStringlist.Create;
x11:=TStringlist.Create;
AssignFile(airfile,mainPath+'aircraft.cfg');

append(airfile);
WriteLn(airfile, ''); // Добавим пустую строку для корректного чтения файла
CloseFile(airfile);

//MyRemoveDir(GetTempDir+'RATS_extracted\temp_any\'); // Удалим папку, если она была
DelDir(GetTempDir+'RATS_extracted\temp_any\'); // Удалим папку, если она была

if not DirectoryExists(GetTempDir+'RATS_extracted\temp_any\') then   // Создадим временную папку
    if not CreateDir(GetTempDir+'RATS_extracted\temp_any\') then
    raise Exception.Create('Cannot create temp_any directory!');

/////////Добавим пустые строки между секциями fltsim. //////////////////
reset(airfile);
 while not eof(airfile) do
        begin
           readln(airfile, sq);
           if copy(sq,0,8)='[fltsim.' then
              begin
                 x11.Add('');
              end; {if}

           if sq='[General]' then
              begin
                 x11.Add('');
              end; {if}

           x11.Add(sq);
        end; {while}
closefile(airfile);
x11.SaveToFile(mainPath+'aircraft.cfg');
/////////Конец Добавим пустые строки между секциями [fltsim. //////////////////

///////////////// Разбираем файл на запчасти ///////////////////////////////////
reset(airfile);
      while not eof(airfile) do
        begin
//        i:=0;
          readln(airfile, sq);
          if copy(sq,0,8)='[fltsim.' then  // Читаем файл до
begin
inc(w);
AssignFile(tt,GetTempDir+'RATS_extracted\temp_any\fltsim.'+IntToStr(w)+'.txt');
rewrite(tt);
Append(tt);
writeln(tt, sq);

repeat
        readln(airfile, sq);
//        if copy(sq,0,11)='texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3) then
//        if sq='texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3) then
//          begin
//            w:=w-1; // Запись будем производить в предыдущий файл
            //deletefile('c:\test\fltsim.'+IntToStr(w+1)+'.txt');
//          end;
        writeln(tt,sq);
until copy(sq,0,1)=''; // Читаем и записываем в файлы до этого момента
closefile(tt);
end; (*if [fltsim.*)

x10.Add(sq);
        end; (*while*)
x10.Add('');                     // Добавим пустую строку для разрыва между [General] и секциями [fltsim.]
closefile(airfile);
///////////////// Закончили разбирать файл на запчасти /////////////////////////

///////////Отфильтруем из временной папки файлы с Texture=TIS
If FindFirst(GetTempDir+'RATS_extracted\temp_any\*.*', faAnyFile, SearchRec)=0 then
repeat

if SearchRec.Name='.' then
FindNext(SearchRec);
if SearchRec.Name='..' then
FindNext(SearchRec);

assignfile(tt, GetTempDir+'RATS_extracted\temp_any\'+SearchRec.Name);
sj:='';
reset(tt);
 while not eof(tt) do
   begin
     readln(tt, sq);
      if copy(sq,0,11)='texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3) then
        begin
           sj:=sq;
        end;
   end;
closefile(tt);

if sj<>'' then
deletefile(GetTempDir+'RATS_extracted\temp_any\'+SearchRec.Name);

until FindNext(SearchRec) <> 0;
FindClose(SearchRec);
///////////Конец Отфильтруем из временной папки файлы с Texture=TIS ////////////////


///////////////// Собираем новый файл aircraft.cfg //////////////////////////////
//Первое: добавим в общий список x10 (это секция general и все остальное) Уже добавлено в x10

// Затем читаем файлы и добавляем в общий список из всех файлов по порядку
If FindFirst(GetTempDir+'RATS_extracted\temp_any\*.*', faAnyFile, SearchRec)=0 then
repeat
//SearchRec.Name - имя файла
// Здесь нужно написать сортировку файлов по дате

if SearchRec.Name='.' then
FindNext(SearchRec);
if SearchRec.Name='..' then
FindNext(SearchRec);

if FileExists(GetTempDir+'RATS_extracted\temp_any\'+SearchRec.Name) then
  begin
assignfile(tt, GetTempDir+'RATS_extracted\temp_any\'+SearchRec.Name);
reset(tt);
 while not eof(tt) do
   begin
     readln(tt, sq);
     x10.Add(sq);
   end;
closefile(tt);
   end; {if file exists}

until FindNext(SearchRec) <> 0;
FindClose(SearchRec);
x10.SaveToFile(mainPath+'aircraft.cfg');
///////////////// Конец Собираем новый файл aircraft.cfg ////////////////////////
x10.Free;
x11.Free;
//MyRemoveDir(GetTempDir+'RATS_extracted\temp_any\');
DelDir(GetTempDir+'RATS_extracted\temp_any\');
end;




// Удаление секций [fltsim.] из файла aircraft.cfg  (НЕ RATS!)
// Одна проверка на наличие Texture=TIS (sj)
procedure TForm1.DeleteSection(Sender: TObject);
var
tt, airfile: TextFile;
sq, sj, sh: String;
x10, x11: TStrings;
w: Integer;
SearchRec: TSearchRec;
//label Metka2;

begin
w:=-1;
x10:=TStringlist.Create;
x11:=TStringlist.Create;
AssignFile(airfile,mainPath+'aircraft.cfg');

append(airfile);
WriteLn(airfile, ''); // Добавим пустую строку для корректного чтения файла
CloseFile(airfile);

//MyRemoveDir(GetTempDir+'RATS_extracted\temp\'); // Удалим папку, если она была
DelDir(GetTempDir+'RATS_extracted\temp\'); // Удалим папку, если она была

if not DirectoryExists(GetTempDir+'RATS_extracted\temp\') then   // Создадим временную папку
    if not CreateDir(GetTempDir+'RATS_extracted\temp\') then
    raise Exception.Create('Cannot create temp directory!');


/////////Добавим пустые строки между секциями fltsim. //////////////////
reset(airfile);
 while not eof(airfile) do
        begin
           readln(airfile, sq);
           if copy(sq,0,8)='[fltsim.' then
              begin
                 x11.Add('');
              end; {if}

           if sq='[General]' then
              begin
                 x11.Add('');
              end; {if}

           x11.Add(sq);
        end; {while}
closefile(airfile);
x11.SaveToFile(mainPath+'aircraft.cfg');
/////////Конец Добавим пустые строки между секциями [fltsim. //////////////////


///////////////// Разбираем файл на запчасти ///////////////////////////////////
reset(airfile);
      while not eof(airfile) do
        begin
//        i:=0;
          readln(airfile, sq);
          if copy(sq,0,8)='[fltsim.' then  // Читаем файл до
begin
inc(w);
AssignFile(tt,GetTempDir+'RATS_extracted\temp\fltsim.'+IntToStr(w)+'.txt');
rewrite(tt);
Append(tt);
writeln(tt, sq);

repeat
        readln(airfile, sq);
//        if copy(sq,0,11)='texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3) then
//        if sq='texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3) then
//          begin
//            w:=w-1; // Запись будем производить в предыдущий файл
            //deletefile('c:\test\fltsim.'+IntToStr(w+1)+'.txt');
//          end;
        writeln(tt,sq);
until copy(sq,0,1)=''; // Читаем и записываем в файлы до этого момента
closefile(tt);
end; (*if [fltsim.*)

x10.Add(sq);
        end; (*while*)
x10.Add('');                     // Добавим пустую строку для разрыва между [General] и секциями [fltsim.]
closefile(airfile);
///////////////// Закончили разбирать файл на запчасти /////////////////////////


///////////Отфильтруем из временной папки файлы с Texture=TIS
If FindFirst(GetTempDir+'RATS_extracted\temp\*.*', faAnyFile, SearchRec)=0 then
repeat

if SearchRec.Name='.' then
FindNext(SearchRec);
if SearchRec.Name='..' then
FindNext(SearchRec);

assignfile(tt, GetTempDir+'RATS_extracted\temp\'+SearchRec.Name);
sj:='';
sh:='';
reset(tt);
 while not eof(tt) do
   begin
     readln(tt, sq);
      if copy(sq,0,11)='texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3) then
        begin
           sj:=sq;
        end;
///      if copy(sq,0,40)='model='+model_ then    //
///        begin
///           sh:=sq;
///        end;
//        end;
   end;
closefile(tt);

if (sj<>'') {and (sh<>'')} then
//if sj<>'' then
deletefile(GetTempDir+'RATS_extracted\temp\'+SearchRec.Name);

until FindNext(SearchRec) <> 0;
FindClose(SearchRec);
///////////Конец Отфильтруем из временной папки файлы с Texture=TIS ////////////////


///////////////// Собираем новый файл aircraft.cfg //////////////////////////////
//Первое: добавим в общий список x10 (это секция general и все остальное) Уже добавлено в x10

// Затем читаем файлы и добавляем в общий список из всех файлов по порядку
If FindFirst(GetTempDir+'RATS_extracted\temp\*.*', faAnyFile, SearchRec)=0 then
repeat
//SearchRec.Name - имя файла
// Здесь нужно написать сортировку файлов по дате

if SearchRec.Name='.' then
FindNext(SearchRec);
if SearchRec.Name='..' then
FindNext(SearchRec);

if FileExists(GetTempDir+'RATS_extracted\temp\'+SearchRec.Name) then
  begin
assignfile(tt, GetTempDir+'RATS_extracted\temp\'+SearchRec.Name);
reset(tt);
 while not eof(tt) do
   begin
     readln(tt, sq);
     x10.Add(sq);
   end;
closefile(tt);
   end; {if file exists}

until FindNext(SearchRec) <> 0;
FindClose(SearchRec);
x10.SaveToFile(mainPath+'aircraft.cfg');
///////////////// Конец Собираем новый файл aircraft.cfg ////////////////////////
x10.Free;
x11.Free;
//MyRemoveDir(GetTempDir+'RATS_extracted\temp\');
DelDir(GetTempDir+'RATS_extracted\temp\');
end;





// Удаление секций [fltsim.] RATS из файла aircraft.cfg // Отличие от DeleteSection только в sk и sh
procedure TForm1.DeleteSectionRATS(Sender: TObject);
var
tt, airfile: TextFile;
sq, sj, sh, sk, sl: String;
x10, x11: TStrings;
w: Integer;
SearchRec: TSearchRec;
//label Metka2;

begin
w:=-1;
x10:=TStringlist.Create;
x11:=TStringlist.Create;
AssignFile(airfile,mainPath+'aircraft.cfg');

append(airfile);
WriteLn(airfile, ''); // Добавим пустую строку для корректного чтения файла
CloseFile(airfile);

//MyRemoveDir(GetTempDir+'RATS_extracted\tempRATS\'); // Удалим папку, если она была
DelDir(GetTempDir+'RATS_extracted\tempRATS\'); // Удалим папку, если она была

if not DirectoryExists(GetTempDir+'RATS_extracted\tempRATS\') then   // Создадим временную папку
    if not CreateDir(GetTempDir+'RATS_extracted\tempRATS\') then
    raise Exception.Create('Cannot create tempRATS directory!');


/////////Добавим пустые строки между секциями fltsim. //////////////////
reset(airfile);
 while not eof(airfile) do
        begin
           readln(airfile, sq);
           if copy(sq,0,8)='[fltsim.' then
              begin
                 x11.Add('');
              end; {if}

           if sq='[General]' then
              begin
                 x11.Add('');
              end; {if}

           x11.Add(sq);
        end; {while}
closefile(airfile);
x11.SaveToFile(mainPath+'aircraft.cfg');
/////////Конец Добавим пустые строки между секциями [fltsim. //////////////////

///////////////// Разбираем файл на запчасти ///////////////////////////////////
reset(airfile);
      while not eof(airfile) do
        begin
//        i:=0;
          readln(airfile, sq);
          if copy(sq,0,8)='[fltsim.' then  // Читаем файл до
begin
inc(w);
AssignFile(tt,GetTempDir+'RATS_extracted\tempRATS\fltsim.'+IntToStr(w)+'.txt');
rewrite(tt);
Append(tt);
writeln(tt, sq);

repeat
        readln(airfile, sq);
        writeln(tt,sq);
until copy(sq,0,1)=''; // Читаем и записываем в файлы до этого момента
closefile(tt);
end; (*if [fltsim.*)

x10.Add(sq);
        end; (*while*)
x10.Add('');                     // Добавим пустую строку для разрыва между [General] и секциями [fltsim.]
closefile(airfile);
///////////////// Закончили разбирать файл на запчасти /////////////////////////

///////////Отфильтруем из временной папки файлы с Texture=TIS
If FindFirst(GetTempDir+'RATS_extracted\tempRATS\*.*', faAnyFile, SearchRec)=0 then
repeat

if SearchRec.Name='.' then
FindNext(SearchRec);
if SearchRec.Name='..' then
FindNext(SearchRec);

assignfile(tt, GetTempDir+'RATS_extracted\tempRATS\'+SearchRec.Name);
sj:='';
sh:='';
sk:='';
//sl:='';
reset(tt);
 while not eof(tt) do
   begin
     readln(tt, sq);
      if copy(sq,0,11)='texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3) then
        begin
           sj:=sq;
           sl:=copy(sq,13,30);
        end;
      if copy(sq,0,40)='model='+model_ then
        begin
           sh:=sq;
        end;
      if sq='setup=RATS' then
        begin
           sk:=sq;
        end;

//        end;
   end;
closefile(tt);

if (sj<>'') and (sh<>'') and (sk<>'') then
         begin
        deletefile(GetTempDir+'RATS_extracted\tempRATS\'+SearchRec.Name);
        if sl='' then continue; // Если нет вложенной папки, то просто продолжим цикл.
        //MyRemoveDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+sl); // Удаляем соотв. папки
        DelDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+sl); // Удаляем соотв. папки
//        ShowMessage(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+sl);
         end;
until FindNext(SearchRec) <> 0;
FindClose(SearchRec);


{// Включаем поиск по папке распакованного инсталяционного пакета и удаляем соотв. подпапки в месте установки
If FindFirst(GetTempDir+'RATS_extracted\Textures\'+StringGrid1.Cells[1,Row]+'\'+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\*.*', faAnyFile, SearchRec)=0 then
repeat
if SearchRec.Name='.' then
FindNext(SearchRec);
if SearchRec.Name='..' then
FindNext(SearchRec);
//ShowMessage(GetTempDir+'RATS_extracted\Textures\'+StringGrid1.Cells[1,Row]+'\'+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+SearchRec.Name);
   if DirectoryExists(GetTempDir+'RATS_extracted\Textures\'+StringGrid1.Cells[1,Row]+'\'+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+SearchRec.Name) then
  begin
     MyRemoveDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+SearchRec.Name); // Удаляем папки
//     ShowMessage(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+SearchRec.Name);
  end;
until FindNext(SearchRec) <> 0;
FindClose(SearchRec); }
///////////Конец Отфильтруем из временной папки файлы с Texture=TIS ////////////////



///////////////// Собираем новый файл aircraft.cfg //////////////////////////////
//Первое: добавим в общий список x10 (это секция general и все остальное) Уже добавлено в x10

// Затем читаем файлы и добавляем в общий список из всех файлов по порядку
If FindFirst(GetTempDir+'RATS_extracted\tempRATS\*.*', faAnyFile, SearchRec)=0 then
repeat
//SearchRec.Name - имя файла
// Здесь нужно написать сортировку файлов по дате

if SearchRec.Name='.' then
FindNext(SearchRec);
if SearchRec.Name='..' then
FindNext(SearchRec);

if FileExists(GetTempDir+'RATS_extracted\tempRATS\'+SearchRec.Name) then
  begin
assignfile(tt, GetTempDir+'RATS_extracted\tempRATS\'+SearchRec.Name);
reset(tt);
 while not eof(tt) do
   begin
     readln(tt, sq);
     x10.Add(sq);
   end;
closefile(tt);
   end; {if file exists}

until FindNext(SearchRec) <> 0;
FindClose(SearchRec);
x10.SaveToFile(mainPath+'aircraft.cfg');
///////////////// Конец Собираем новый файл aircraft.cfg ////////////////////////
x10.Free;
x11.Free;
// А теперь удалим нашу временную папку tempRATS
//MyRemoveDir(GetTempDir+'RATS_extracted\tempRATS\');
DelDir(GetTempDir+'RATS_extracted\tempRATS\');
end;





// Поиск места вкладывания строк в файл aircraft.cfg и запись их туда
procedure TForm1.AirCFG(Sender: TObject);
var
tempfile, airfile, temp_air: TextFile;
stt, s2, sr, s3: String;
x2, x3: TStrings;
//g: Integer;
begin
Assignfile(tempfile, GetTempDir+'RATS_extracted'+'\temp.txt');
Assignfile(temp_air, GetTempDir+'RATS_extracted'+'\temp_fltsim.XXX.txt');
AssignFile(airfile,mainPath+'aircraft.cfg');

reset(tempfile);
readln(tempfile, stt);
closefile(tempfile);

reset(airfile);
//rewrite(temp_air);
repeat
     readln(airfile, s2);
  if pos(stt, s2)>0 then  // Читаем файл до
begin
//     ShowMessage('Секция [fltsim] до General');       // Для теста

     // Прописываем секции в середину файла aircraft.cfg до секции [General]
     // Сначала заносим в x3 Строки из aircraft.cfg до [General]
//     closefile(airfile);
     
         x3:=TStringlist.Create;
      reset(airfile);
        repeat
         readln(airfile, s3);
      x3.Add(s3);
        until pos('[General]',s3)>0;
        // Удалим последний элемент из x3 (строчка [General])
        x3.Delete(x3.Count-1);
       closefile(airfile);

      // Затем заносим в x3 все строки из temp_fltsim.XXX.txt
      reset(temp_air);
      while not eof(temp_air) do
        begin
          readln(temp_air, s3);
          x3.Add(s3);
        end;
        closefile(temp_air);

        x3.Add('');  // Сначала отступим строку
//        x3.Add(#13); // Сначала отступим строку
        x3.Add('[General]'); // Запишем сначала нашу удаленную строку
      // И снова продолжаем читать файл aircraft.cfg, начиная с поз. [General]
        reset(airfile);
//         g:=0;
      while not eof(airfile) do
        begin
         readln(airfile, s3);
         if pos('[General]', s3)>0 then
        begin
           while not eof(airfile) do
              begin
               readln(airfile, s3);
               x3.Add(s3);
              end; {while not eof}
         end; {if pos}
        end;  { while not eof}
       closefile(airfile);

       x3.SaveToFile(mainPath+'aircraft.cfg');  // Сохраняем результат
       x3.Free;

     Exit;                                                       //Узнаем, где находятся секции [fltsim.]
end; {if pos}                                                    // до или после [General]
     until pos('[General]',s2)>0;

// ShowMessage('Секция [fltsim] после General');     // Для теста
closefile(airfile);

// Здесь процедура Append, то есть просто добавляем наши строки в конец файла aircraft.cfg
  x2:=TStringList.Create;

reset(airfile);
while not eof(airfile) do
begin
   readln(airfile, sr);
   x2.Add(sr);
end;
closefile(airfile);

reset(temp_air);
while not eof(temp_air) do
begin
   readln(temp_air, sr);
   x2.Add(sr);
end;
closefile(temp_air);

  x2.SaveToFile(mainPath+'aircraft.cfg');  // Сохраняем результат
  x2.Free;
end;



// Копируем без удаления папки назначения (процедура обновленния)
procedure TForm1.FilesFoldersCopy(Sender: TObject);
begin
FullDirectoryCopy(GetTempDir+'RATS_extracted\Textures\'+StringGrid1.Cells[1,Row]+'\texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3), mainpath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3),false,true);
end;



// Запись установленного пакета в RATS_installer_data.ini
procedure TForm1.IniRecord(Sender: TObject);
var
MyIni: TIniFile;
FltXXX: TextFile;
rat5, texture_: String;
begin
MyIni:=TIniFile.Create(Edit3.Text+'\RATS_installer_data.ini');
            // Теперь Получим title= и texture=
              AssignFile(FltXXX, GetTempDir+'RATS_extracted\Textures\'+StringGrid1.Cells[1,Row]+'\[Fltsim.xxx].txt');
                reset(FltXXX);
                while not Eof(FltXXX) do
                begin
                  readln(FltXXX, rat5);
                  if pos('title=',rat5)>0 then
                     begin
                       title_:=copy(rat5,7,100);
                       readln(FltXXX, rat5);
                       readln(FltXXX, rat5);
                       readln(FltXXX, rat5);
                       texture_:=copy(rat5,12,100);
                       MyIni.WriteString(label2.Caption, title_, mainpath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3));
                       // Строка ниже - запись в ини полного пути, вместе с вложенными папками.
                       //MyIni.WriteString(label2.Caption, title_, mainpath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+texture_);
                     end;
                   //if pos('texture=',rat5)>0 then
                   //  begin
                   //    texture_:=copy(rat5,12,100);
                   //  end;
                end;
                closeFile(FltXXX);
//   MyIni.WriteString(label2.Caption, title_, mainpath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+texture_);
MyIni.Free;
  //
end;



// Клик по таблице
procedure TForm1.StringGrid1Click(Sender: TObject);
var
recTmp:TGridRect;
f3, FltXXX: TextFile;
rat, rat2, {rat3, rat4,} rat5: String;

tt: TextFile;
sq, sj, sh, sk: String;
w, i: Integer;
SearchRec: TSearchRec;
x12, x13: TStrings;
Arraymodel: array[0..10000] of String;
Arraymodel2: array[0..10000] of String;
arraytitle: array[0..10000] of String;

  obr1, obr2, obr3: String; // образец для поиска
  found, found2, found3: boolean; // TRUE — совпадение образца с элементом массива
  u, u2, e, n: integer; // индекс элемента массива

airfile: TextFile;  // Эти переменные такие же, как и в процедуре delemptystr
sw: String;
x23: TStrings;

label Metka;
label Metka2;
//label Metka3;

begin
recTmp:=StringGrid1.selection;
Row:=recTmp.Top;
Column:=recTmp.Left;
if Column<>3 then exit; // Если нажатие в колонке, отличной от install/uninstall, то ничего не делаем
if Row>ButtonTag then exit; // Если нажатие в ряду, в котором нет самолетов, то ничего не делать
if StringGrid1.Cells[3,Row]='OK!' then exit; // Если данный самолет уже установлен

sh:='';
sj:='';  // Обнулим строки
sk:='';
aircraft:='';
mainpath:='';

SelectInstall(self); // открываем диалоговое окно быбора файла
// Там есть нужное нам имя air файла и путь, куда будем копировать тектуры и какие (откуда)

if mainPath='' then exit; // Если не был получен путь установки в OpenDialog3


// Теперь проверим, та ли модель самолета? (секцию model= из [fltsim.XXX] сравним с секцией в aircraft.cfg)
        AssignFile(FltXXX, GetTempDir+'RATS_extracted\Textures\'+StringGrid1.Cells[1,Row]+'\[Fltsim.xxx].txt');
        reset(FltXXX);
        while not Eof(FltXXX) do
        begin
          readln(FltXXX, rat5);
          if pos('model=',rat5)>0 then
             begin
               model_:=copy(rat5,7,20);
             end;
        end;
        closeFile(FltXXX);

// Проверяем соответствие модели в [fltsim.XXX] и в существующем файле Aircraft.cfg
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////Поиск model= в секции Texture=TIS /////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
w:=-1;
i:=0;
x12:=TStringlist.Create;
x13:=TStringlist.Create;
AssignFile(f3,mainPath+'aircraft.cfg');

append(f3);
WriteLn(f3, ''); // Добавим пустую строку для корректного чтения файла
CloseFile(f3);

//MyRemoveDir(GetTempDir+'RATS_extracted\temp2\'); // Удалим папку, если она была
DelDir(GetTempDir+'RATS_extracted\temp2\'); // Удалим папку, если она была

if not DirectoryExists(GetTempDir+'RATS_extracted\temp2\') then   // Создадим временную папку
    if not CreateDir(GetTempDir+'RATS_extracted\temp2\') then
    raise Exception.Create('Cannot create temp2 directory!');

/////////Добавим пустые строки между секциями fltsim. //////////////////
reset(f3);
 while not eof(f3) do
        begin
           readln(f3, sq);
           if copy(sq,0,8)='[fltsim.' then
              begin
                 x13.Add('');
              end; {if}

           if sq='[General]' then
              begin
                 x13.Add('');
              end; {if}

           x13.Add(sq);
        end; {while}
closefile(f3);
x13.SaveToFile(mainPath+'aircraft.cfg');
/////////Конец Добавим пустые строки между секциями [fltsim. //////////////////


///////////////// Разбираем файл на запчасти ///////////////////////////////////
reset(f3);
      while not eof(f3) do
        begin
          readln(f3, sq);
          if copy(sq,0,8)='[fltsim.' then  // Читаем файл до
begin
inc(w);
AssignFile(tt,GetTempDir+'RATS_extracted\temp2\fltsim.'+IntToStr(w)+'.txt');
rewrite(tt);
Append(tt);
writeln(tt, sq);

repeat
        readln(f3, sq);
        writeln(tt,sq);
until copy(sq,0,1)=''; // Читаем и записываем в файлы до этого момента
closefile(tt);
end; (*if [fltsim.*)

x12.Add(sq);
        end; (*while*)
x12.Add('');                     // Добавим пустую строку для разрыва между [General] и секциями [fltsim.]
closefile(f3);
///////////////// Закончили разбирать файл на запчасти /////////////////////////


///////////Проверим во временной папке файлы с Texture=TIS и с model=ge_no_refl
If FindFirst(GetTempDir+'RATS_extracted\temp2\*.*', faAnyFile, SearchRec)=0 then
repeat

if SearchRec.Name='.' then
FindNext(SearchRec);
if SearchRec.Name='..' then
FindNext(SearchRec);

assignfile(tt, GetTempDir+'RATS_extracted\temp2\'+SearchRec.Name);
if FileExists(GetTempDir+'RATS_extracted\temp2\'+SearchRec.Name) then
 begin {56}
reset(tt);
inc(i);
 while not eof(tt) do
   begin
     readln(tt, sq);
      if copy(sq,0,40)='model='+model_ then
        begin
           sh:=sq;
        end;
      if copy(sq,0,11)='texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3) then
        begin
           sj:=copy(sq,9,3);
        end;
      if sq='setup=RATS' then
        begin
           sk:=sq;
        end;
   end;
closefile(tt);
  end; {56}
  
if (sj<>'') and (sh<>'') then
       begin
          // Если найдено и то и другое, то запишем в массив значения texture= и model=
          // для дальнейшего использования.
         Arraymodel[i]:=sh+' '+sj;
//         Showmessage(arraymodel[i]);
       end;

if (sj<>'') and (sh<>'') and (sk<>'') then
       begin
          // Если найдено и то и другое, то запишем в массив значения texture= и model=
          // для дальнейшего использования.
         Arraymodel2[i]:=sh+' '+sj+' '+sk;
//         Showmessage(arraymodel2[i]);
       end;



until FindNext(SearchRec) <> 0;
FindClose(SearchRec);
///////////Конец Проверим во временной папке файлы с Texture=TIS и с model=111_no_refl
x12.Free;
x13.Free;
//MyRemoveDir(GetTempDir+'RATS_extracted\temp2\');  // Все, папка нам больше не нужна, удаляем ее
DelDir(GetTempDir+'RATS_extracted\temp2\');  // Все, папка нам больше не нужна, удаляем ее
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// Конец поиска model= в секции Texture=TIS //////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////




/////////////////////// UPDATE ////////////////////////////////////////////////////////////////////////
///////////// Если пакет является апдейтовым, то это совсем другая история  ///////////////////////////
if (copy(Label4.Caption,0,6)='Update') then
//  if (sj<>'') and (sh<>'') then
begin
/// Проверим, есть ли папка texture.TIS. Если есть, то все в порядке.
/// Если нет, то апдейт ставится в пустую папку без оригинального пакета. Поэтому напишем пользователю.
if not DirectoryExists(mainpath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)) then
      begin {7877}
        MessageDlg('Warning! You are trying to install update without original texture pack.'+#13+'Please install original full or optimized texture pack first.',mtWarning,[mbOK],0);
        Exit;
      end;  {7877}

///if DirectoryExists(mainpath+'texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3)) then
/// begin {44}

        // Теперь проверим, title= (из [fltsim.XXX] сравним строку, есть ли такая в aircraft.cfg)
              AssignFile(FltXXX, GetTempDir+'RATS_extracted\Textures\'+StringGrid1.Cells[1,Row]+'\[Fltsim.xxx].txt');
                reset(FltXXX);
                while not Eof(FltXXX) do
                begin
                  readln(FltXXX, rat5);
                  if pos('title=',rat5)>0 then
                     begin
                       title_:=copy(rat5,7,100);
                     end;
                end;
                closeFile(FltXXX);

// Поищем эту строку в aircraft.cfg
n:=0;
        AssignFile(f3, mainpath+'aircraft.cfg');
        reset(f3);
        while not Eof(f3) do
        begin
          readln(f3, rat5);
          if pos('title=',rat5)>0 then
             begin
             inc(n);
              arraytitle[n]:=copy(rat5,7,100);  // запишем в массив все строки title=
             end;
        end;
        closeFile(f3);
    // А теперь сверим title= из [fltsim.XXX] поэлементно с arraytitle[h]
  obr3:=title_;
  found3 := FALSE;
  e := 0;
          repeat
            if arraytitle[e] = obr3 then
              found3 := TRUE
            else
              inc(e);
          until (e > 10000) or (found3 = TRUE);
          if found3 then // Если найден такой же title= в aircraft.cfg
        begin
               ShowMessage('This aircraft is already installed  ('+title_+')');

                // Удалим пустые строчки (как в процедуре DelEmptyStr)
               x23:=TStringlist.Create;
                AssignFile(airfile,mainPath+'aircraft.cfg');
                reset(airfile);
                while not eof(airfile) do
                begin
                readln(airfile, sw);
                x23.Add(sw);
                      if sw='' then
                      repeat
                           readln(airfile, sw);
                            if sw<>'' then
                              begin
                                x23.Add(sw);
                              end;
                      until sw<>'';
                end; {while not eof}
                closefile(airfile);
                x23.Delete(x23.Count-1); // Удалим последний элемент. Он получался в виде квадратика в конце файла aircraft.cfg
                x23.SaveToFile(mainPath+'aircraft.cfg');
                x23.Free;
                Exit;
//               goto Metka3;
        end
        else
//   if MessageDlg('Would you like to update previous textures pack from RATS?', mtInformation,[mbYes, mbNo],0)=mrNo then
// Exit;
   begin
     // Установка в нормальном режиме
        goto Metka;
    end;
///    else
///      begin {55}
///        MessageDlg('Warning! You are trying to install update without original texture pack.'+#13+'Please install full or optimized texture pack first.',mtWarning,[mbOK],0);
///        Exit;
///      end; {55}
end; {label4.Caption Update}
///////////////////// UPDATE /////////////////////////////////////////////////////////////////////////


// Если папки нет, то не имеет смысла проверять, есть ли какие-то записи Texture.TIS соотв. model=.
if not DirectoryExists(mainPath+StringGrid1.Cells[2,ButtonTag]) then goto Metka2;


// Если встречается комбинация из texture=TIS и model=ge_no_refl, а может еще setup=RATS
// То выстроим дерево ответов пользователю.

// Поиск в массивах хотя бы одной строки по этому условию
obr1:=sh+' '+sj;
obr2:=sh+' '+sj+' '+sk;
found := FALSE; // пусть нужного элемента в массиве нет
found2 := FALSE; // пусть нужного элемента в массиве нет
u := 0;
  repeat
    if Arraymodel[u] = obr1 then
      found := TRUE
    else
      inc(u);
  until (u > 10000) or (found = TRUE);
  if found then // Если найдено model=ge_no_refl и texture.tis
begin
           // Проверим, есть ли во втором массиве что-нибудь
        u2 := 0;
          repeat
            if Arraymodel2[u] = obr2 then
              found2 := TRUE
            else
              inc(u2);
          until (u2 > 10000) or (found2 = TRUE);
          if found2 then // Если найдено model=ge_no_refl и texture.tis и еще и setup=RATS
        begin
           // Это RATS секция в нагрузку к не RATS, значит удалять или нет решит пользователь

{1}//           ShowMessage('Это RATS секция, значит удалять или нет решит пользователь');
           if MessageDLG('Previous version of RATS textures was found. Delete and install new RATS textures?',mtConfirmation,[mbYes,mbNo],0) = mrNo then
        //MessageDLG('Найдена установленная текстура RATS. Удалить и установить новую текстуру от RATS?',mtConfirmation,[mbYes,mbNo],0);
//           Exit; // Нажатие No
        begin
        form1.label20.Caption:=tmpArr2[0];                                          //2
        exit; // нажатие No
        end;
           // Здесь процедура удаления папки texture.tis и запуск установки
//           MyRemoveDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3));  // Удаляем texture.TIS (перенесено в процедуру DeleteSectionRATS)
           // Удаляем секции RATS, соответствующие папке  texture.tis
              DeleteSectionRATS(self); // Удаляем выборочно папки и секции из aircraft.cfg
              ReNum(self);  // Перенумеруем секции [fltsim]
           goto Metka; // Далее - установка в нормальном режиме.

        end {Если найдено RATS }
            else    // Если не найдено, то нет RATS секции, а есть просто связка model=ge_no_refl и texture.tis
                    // Значит пишем пользователю, что у него есть предыдущая texture.TIS
                begin

{2}//                   ShowMessage('Значит пишем пользователю, что у него есть предыдущая texture.TIS');
                    if MessageDLG('Previous version of '+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+' was found. Delete and install new RATS textures?',mtConfirmation,[mbYes,mbNo],0)= mrNo then
                        //MessageDLG('Найдена установленная текстура стороннего разработчика. Удалить и установить текстуру от RATS?',mtConfirmation,[mbYes,mbNo],0);
                        exit; // нажатие No

                           // Здесь процедура удаления папки texture.tis и запуск установки
                           //MyRemoveDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3));  // Удаляем texture.TIS
                           DelDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3));  // Удаляем texture.TIS
                           // Удаляем секции, соответствующие папке  texture.tis
                           DeleteSection(self); // Удалим секции не RATS                                              //1
                              ReNum(self);  // Перенумеруем секции [fltsim]
                           goto Metka; // Далее - установка в нормальном режиме.

                end;
end {Если найдено model=ge_no_refl и texture.tis }

  else
//  Если ничего не найдено, то нет ни RATS секции, ни не RATS,
// Значит просто установка без ограничений.
                begin

{3}//                  ShowMessage('Значит просто установка без ограничений.');
                  // Если существует такая папка
                  if DirectoryExists(mainPath+StringGrid1.Cells[2,ButtonTag]) then  // Если есть папка texture.tis
                        begin {1}

                        //  Если есть секции texture.tis в файле aircraft.cfg
                        AssignFile(f3,mainPath+'aircraft.cfg');
                        reset(f3);
                        while not Eof(f3) do
                        begin {2}
                          readln(f3, rat2);
                                // Поиск texture=ICAO в сущ. файле
                          if pos('texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3), rat2)>0 then
                          begin {3}
                       tmpArr2[1]:=rat2; // Запишем строку, для того, чтобы определить, есть ли вообще texture.папка
                          end;  {3}
                        end;  {EoF} {2}
                          closefile(f3);

                        // Если запись texture.TIS в файле aircraft.cfg не найдена, то папка есть, а записи соотв. нет.
                        if tmpArr2[1]='' then
                          begin   {4}
                        if  MessageDLG('You have no associated section [fltsim.] in aircraft.cfg file for '+'texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3)+', but this texture was found.'+#13+'Do you want to remove this folder and install new RATS textures?',mtWarning,[mbYes,mbNo],0) = mrNo then
                        exit;  // нажатие No
                          // Здесь процедура удаления папки texture.tis
                           //MyRemoveDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3));  // Удаляем texture.TIS
                           DelDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3));  // Удаляем texture.TIS
                             goto Metka; // Просто установка
                          end;   {4}

                        end {if DirectoryExists}  {1}
                           else
                            // А если папки нет, то нужно проверить есть ли записи в aircraft.cfg, соответствующие texture.TIS
Metka2:
        begin {5}
{4}//        ShowMessage('Папки нет, а запись Texture.TIS найдена!');
        AssignFile(f3,mainPath+'aircraft.cfg');
        reset(f3);
        while not Eof(f3) do
        begin                     // Поиск texture=ICAO в сущ. файле
          readln(f3, rat2);
          if pos('texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3), rat2)>0 then
            rat:=rat2;

        // Если у нас есть модель с именем, как /////////////////Доделать///////////////
        //  if pos()
        end; //while }
        closefile(f3);

        if rat<>'' then
        begin
     if MessageDLG('You have [fltsim.] section(s) associated with texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+', but texture was not found. Delete this section(s) and install new RATS textures?',mtConfirmation,[mbYes,mbNo],0)= mrNo then
           exit; // нажатие No
        // Если пользователь согласен с удалением, сносим все секции, где встречается
        // texture.TIS, и RATS, и нет.
             DeleteSection_any(self);
             ReNum(self);  // Перенумеруем секции [fltsim]
             goto Metka; // Далее - установка в нормальном режиме.
        end;
        end; {5}

                  goto Metka; // Просто установка
                end;




// Если ничего похожего не найдено, то просто продолжаем установку
Metka:  // Сюда указывают ответы ДА на перезапись папки (из диалоговых окон)

// Копирование файлов и папок в место назначения (opendialog3)
//FoldersCopy(self);    // Копируем папки в место назначения
FilesFoldersCopy(self);  // Копируем содержимое папки в место назначения



GenFltsimXXX(self); // Генерация строк для файла aircraft.cfg
//и запись их во временный файл.


// Поиск места в aircraft.cfg куда будем вставлять сгенерированные строки из процедуры GenFltsimXXX
// Добавление в существующий aircraft.cfg наших сгенерированных строк. (2а варианта, добавление в середину и в конец файла)
AirCFG(self);


// Перенумерация секций [fltsim] на всякий случай
//ReNum(self);

//Metka3:
// Процедура удаления двух подряд пустых строк
DelEmptyStr(self);

// В соответствующей ячейке StringGrid1. в 3 столбике пишем  "OK" после всей установки, удаления
StringGrid1.Cells[3,Row]:='OK!';

// Запись установленного самолета в файл RATS_installer_data.ini
IniRecord(self);


end;

procedure TForm1.Button8Click(Sender: TObject);
begin
// Покажем инфу о себе
MessageDlg('                                  RATS Installer'+#13+#13+'                                 Version 1.0.0.0'+#13+#13+'                          Created by Samarin Vasiliy'+#13+'                                versus@mail15.com'+#13+#13+'Copyright © 2009 Russian AI Traffic System. All rights reserved.',mtInformation,[mbOK],0);
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
//Запуск Help формы
//ShowMessage('Здесь будет описание работы программы');
Form3.Showmodal;

end;

end.
