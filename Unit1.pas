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
    procedure GenStringTable(Table: Boolean);    // ��������� StringGrid1 ���������� �� ��������������� ������
    procedure Load_strings(st: Boolean);         // ��������� ������ �� ����� setup.cfg �� �����
    procedure ErrorRATS(Err: Boolean);           // ���� ����� �� RATS, ���������� ��� ���� �����
    procedure FS2004RegSearch(Sender: TObject);  // ����� ���� � �������
    procedure FS2004RegWrite(Sender: TObject);   // ������ ���� � ������ �� ���� opendialog
    procedure SelectInstall(Sender: TObject);    // ������������� ��������� ���������
    procedure DelEmptyStr(Sender: TObject);      // �������� ������ ����� (���� ����������� ������ ����� ������)
    procedure GenFltsimXXX(Sender: TObject);     // ������������� ����� � ������ �� ��������� ����
    procedure FoldersCopy(Sender: TObject);      // ����������� �����
    procedure AirCFG(Sender: TObject);           // ������ ��������� ����� � ������������ ����
    procedure DeleteSection(Sender: TObject);    // �������� ������ [fltsim] �� ����� aircraft.cfg
    procedure DeleteSectionRATS(Sender: TObject);// �������� ������ [fltsim] RATS �� ����� aircraft.cfg
    procedure DeleteSection_any(Sender: TObject);// �������� ������ [fltsim] (����, ������� �������� Texture=TIS)
    procedure ReNum(Sender: TObject);            // ������������� ������ [fltsim]
    procedure FilesFoldersCopy(Sender: TObject); // ����������� ���������� ����� � ������ �����
    procedure IniRecord(Sender: TObject);        // ������ �������������� ������ � ���� RATS_installer_data.ini
    procedure Root_texture_check(Sender: TObject);// �������� �� ������� ��������� ����� �������� ����� .TIS
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
//////////////// ���������� ///////////////////////////////////////////////////
// � ������������ ����������� ��������� (��������, Texture=TIS), ������� ����������� ��� ��������� ��������������� ������ TESIS    
  end;

var
  Form1: TForm1;
  S {,RATScheckFolder str,}{ airline, Callsign, Painted, Model, Release, License} : string;
f: textfile;
archiver: TZipForge;
num, i: Integer;
ButtonTag: Integer;
MainArray: array [0..4000] of String;
mainPath: String; // ���� ��������� �������
aircraft: String; // ��������������� �������
Fltsim: array [0..4000] of String;
tmpArr1, tmpArr2: Array [0..4000] of String;
h, j: Integer;
fltsimN, model_, title_: String;

implementation

uses Unit3;

{$R *.dfm}

{$WARN SYMBOL_PLATFORM OFF}

{ ����������� ����������� ����������, ������ � ���������������.
������ �������� ���������� ���������� SourceDir � ���������� TargetDir.
���������� ��� �����, �����������, � ����� ����������� � ���� ������������.
�������� StopIfNotAllCopied: ���� �������� ����� ��������� = True,
�� ��� ������ �� ������ ����������� ����� ��� �����, ������ �������
����������� � �������� ����� False. � ������ ���� ���� �������� = False,
�� ������ ����������� ����������� �� �����.
�������� OverWriteFiles: ���� True, �� ������������ ����� ����� ����������.
�����������: SysUtils, FileCtrl, Windows
������ �������������:

FullDirectoryCopy('C:\a', 'D:\b');
// ��������� ���������� ���������� C:\a (�� �� ���� ����������) � ���������� D:\b}
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




//������� ��������� ��������� ����� WinXP
function GetTempDir: String;
var
  Buf: array[0..1023] of Char;
begin
  SetString(Result, Buf, GetTempPath(Sizeof(Buf)-1, Buf));
end;


//������� �������� ����� � ����������  (� ��������� �� ������������)
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


// �������� ����� � ���������� 2
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







// ������ �������� ��������������� ������
procedure TForm1.Button1Click(Sender: TObject);
begin
// ���������, ���� �� �����-������ ��������� ����� RATS
if DirectoryExists(GetTempDir+'RATS_extracted') then
begin

//if NOT MyRemoveDir(GetTempDir+'RATS_extracted') then
if NOT DelDir(GetTempDir+'RATS_extracted') then
ShowMessage('Unable to delete RATS_extracted folder. Please remove this folder from TEMP directory to prevent installation errors.');
//DeleteTree(GetTempDir+'RATS_extracted');
//MessageDlg('�������!',mtConfirmation,[mbOK],0);
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
//If s='' then Exit; // ���� ������������ ������ �� ������, �� ��������� ����������
    // The name of the archive file
    FileName:=OpenDialog1.FileName;
    // Because we extract file from an existing archive,
    // we set Mode to fmOpenRead
    OpenArchive(fmOpenRead);

Edit2.Text:=OpenDialog1.FileName; // ������� ������������, ��� ���� ������

    // Set base (default) directory for all archive operations
    BaseDir:=GetTempDir+'RATS_extracted';
    // Extract test.txt file from the archive
    // to the default directory
    ExtractFiles('*.*');
    CloseArchive();


/// �������� ������������ ������������ � ����������� ������///
if FileExists(GetTempDir+'RATS_extracted'+'\readme.txt') then
   begin
Button4.Enabled:=true; // ������������ ������ �����
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
Button5.Enabled:=true;  // ��� ���������, ����� ���������� � �������� ���� � ���� �� PageIndex:=1
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


///// �������� ��� ������� �� setup.cfg � ���� label //////////////////////////////////
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
    form1.Label2.Caption:=copy(airline,9,50);   // ������ � ���������� Airline
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
    form1.Label4.Caption:=copy(Textures,15,30);   // ������ � ���������� Textures Pack
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
    form1.Label6.Caption:=copy(Callsign,10,30);   // ������ � ���������� Callsign
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
    form1.Label8.Caption:=copy(ICAO,6,20);   // ������ � ���������� ICAO
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
    form1.Label10.Caption:=copy(Release,14,50);   // ������ � ���������� Release Date=
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
    form1.Label12.Caption:=copy(Decription,12,27);   // ������ � ���������� Decription
    break;
  end;
end;
closefile(f);
//////////////////
end;


// ���� ����� �� RATS, ���������� ��� ���� �����
procedure TForm1.ErrorRATS(Err: Boolean); //���� ������� �� �����������, �����, ��� ��������!
begin
// ����� ������� �����, ��������, ������, ����� �����
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
//DeleteTree(GetTempDir+'RATS_extracted'); // �������� �������������� �����
end;


// ���� ��������� � �������
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
  // ������ �������� ������
              RootKey := HKEY_LOCAL_MACHINE;
  // ������� ���������
              OpenKey('Software\Microsoft\Microsoft Games\Flight Simulator\9.0\', False);
  // �������� �������� ���������
              GetValueNames(L);
              If L.Count > 0 Then
  begin
  for I := 0 to L.Count- 1 do
  begin
  // ������ ��� ������ ������� ��������
 case GetDataType(L[I]) of
  // ������?
 rdString,
 rdExpandString :
 S := {'"' +} ReadString(L[I]) {+ '"'};
  // �������������?
 rdInteger :
 S := IntToStr(ReadInteger(L[I]));
  // ��������?
 rdBinary :
 begin
  sz := GetDataSize(L[I]);
  SetLength(Data, sz);
  ReadBinaryData(L[I], Data[0], sz);
  S := '';
  for J := 0 to sz - 1 do
  begin
//  S := S + Format('%2x',[Data[I]]); // ������, ������ ��� ���������� ������ access violation ��� ������ ����� ������
  end;
 end;
  // �����������?
 rdUnknown :
 S := 'Unknown';
  end;
  // ����� ����������
  if L[i]='EXE Path' then  // ���� ������� EXE Path, �� ������� � Edit3 ���� � ���� S
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



// ������ ���� � ������ �� ���� opendialog
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
Column:=0;// ����������� ��-�� StringGrid1
Row:=0;


FS2004RegSearch(self);  // ����� ���������� � �������
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
i:=NoteBook1.PageIndex;    // �������������� �������
NoteBook1.PageIndex:=i+1;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
Application.Terminate  // ������ ������
end;



// �������� �� ������� ��������� ����� �������� ����� .TIS
procedure TForm1.Root_texture_check(Sender: TObject);
var
x17: TStringlist;
MyIni: TIniFile;
r: Integer;
title_, Folder_: String;
SearchRec: TSearchRec;

begin
           // ������ ���� RATS_installer_data.ini � �������, ���� �� ��������������� �����
           x17:=TStringlist.Create;
           MyIni:=TIniFile.Create(Edit3.Text+'\'+'RATS_installer_data.ini');
           MyIni.ReadSection(label2.Caption, x17);

                     for r:=0 to x17.Count-1 do
                        begin  {3}
                           title_:=x17.Strings[r];
                           Folder_:=MyIni.ReadString(label2.Caption,title_,'');

/////////////////////////// ����������, ��� � ��� ��������� �����, � ��� �������� ///////////////////////////////////////////////////
                            if copy(after(Folder_,'texture'),6,1)<>'' then
                               begin
                                     // ������ �����. ��������� �����
                                 //MyRemoveDir(Folder_);
                                 //ShowMessage(copy(after(Folder_,'texture'),6,100));   // ��� �����
                               end
                                else
                                  begin
                                    // ��������, ���� �� � ���� ����� ��������� �����
                                     If FindFirst(Folder_+'\*', faDirectory, SearchRec)=0 then
                                       repeat
                                         if SearchRec.Name='.' then
                                         FindNext(SearchRec);
                                         if SearchRec.Name='..' then
                                         FindNext(SearchRec);

                                         //Showmessage(SearchRec.Name);
                                         // ���� ������� �����-������ �����
                                         if SearchRec.Attr=faDirectory then
                                            begin
                                               //Showmessage('��������� ����� ��� ��������! '+SearchRec.Name);   // ��� �����
                                               Exit;
                                            end;

                                       until FindNext(SearchRec) <> 0;
                                       FindClose(SearchRec);

                                     // ������ �����, ���� �� ������� ���������
                                     //MyRemoveDir(Folder_);
                                     DelDir(Folder_);
                                     ShowMessage('������� '+Folder_);                            // ��� �����
                                     //RemoveDir(Folder_);
                                  end;
/////////////////////////// ����������, ��� � ��� ��������� �����, � ��� ��������  ����� ///////////////////////////////////////////////////
end;
x17.Free;
MyIni.Free;
end;



// ������ Next
procedure TForm1.Button5Click(Sender: TObject);
var
i, m: Integer;      // ������ FINISH
MyIni: TIniFile;
x15: TStringlist;
//CfgFile: TextFile;
//rat5: String;
title_, Folder_: String;

//DeleteSection (����������������)
tt, airfile: TextFile;
sq, sj: String;
x10, x11: TStrings;
w: Integer;
SearchRec: TSearchRec;

// Renum (����������������)
srr: String;
x7: TStrings;
k: Integer;

// DelEmptyStr (����������������)
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
  // �������� ���� ������ 'OK' � ��������� ������� StringGrid1.
  for l:=0 to ButtonTag do
    begin
       //
       fg:=StringGrid1.Cells[3,l];
       if fg='INSTALL?' then       // ���� ����������� ���� �� ���� ������ Install
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

// ��� � ��� ������, ���� �� ������ ��� � ������� � �� ������ �� �������� 1.
if (NoteBook1.PageIndex=1) and (Edit3.Text<>'') then NoteBook1.PageIndex:=2;
if (copy(label4.Caption,0,6)='Update') and (Edit3.Text<>'') then NoteBook1.PageIndex:=2; // ���� ����� ����������, �� �� ����� ������������� ������������ � ������������� ������ Tesis

   if FileExists(Edit3.Text+'\'+'RATS_installer_data.ini') then
        begin
           if NoteBook1.PageIndex<>0 then Exit; // ���� ��������� �� �������� �������� �� �������� ������ ��������������� ������, �� �� �������� �������� �� ���� ���� ������
//           ShowMessage('������ '+Edit3.Text+'\'+'RATS_installer_data.ini');

           // ������ ���� RATS_installer_data.ini � �������, ���� �� ��������������� �����
           x15:=TStringlist.Create;
           MyIni:=TIniFile.Create(Edit3.Text+'\'+'RATS_installer_data.ini');
           MyIni.ReadSection(label2.Caption, x15);
            if x15.Count>0 then
               begin {5656}
                 //ShowMessage(IntToStr(x15.Count));
                 if MessageDlg('You have '+label2.Caption+' airline already installed. Do you want to delete previous installed repaints?'{+#13+'Note. If you are applying an update, click "NO".'},mtInformation,[mbYes,mbNo],0)=mrNo then
                  begin
                   x15.Free;  // ����� No
                   MyIni.Free;

                   Button5.Enabled:=false; // ������ Next ���������
                   Edit2.Text:='';         // ���� � ����� �������
                   NoteBook1.PageIndex:=0; // ��������� ������ �������� ����������
                   label2.Caption:='';
                   label4.Caption:='';
                   label6.Caption:='';      // ������� ��� label
                   label8.Caption:='';
                   label10.Caption:='';
                   label12.Caption:='';
                   Image1.Picture.Graphic := nil; // � ��������
                   Button4.Enabled:=false;        // �������� ����� �����
                   Exit;
                   //goto Metka4;         // ��� ���� �� ����� ������������� ������������ ����������� ������������� ����� �������� � ��� ������������� �����.
                                          // ����. � �����? ����� Exit ������, � ����� 3 ������ ����.
                  end;
//                         ShowMessage('�������!');
                     for m:=0 to x15.Count-1 do
                        begin  {3}
                           title_:=x15.Strings[m];
//                           Showmessage(title_); // ����������������. ��� �����
                           Folder_:=MyIni.ReadString(label2.Caption,title_,'');
//                           Showmessage(Folder_); // ����������������. ��� �����


/////////////////////////// ����������, ��� � ��� ��������� �����, � ��� �������� ///////////////////////////////////////////////////
{                            if copy(after(Folder_,'texture'),6,1)<>'' then
                               begin
                                     // ������ �����. ��������� �����
                                 MyRemoveDir(Folder_);
                                 //ShowMessage('��������� ����� '+copy(after(Folder_,'texture'),6,100)+' �������� ��������.');   // ��� �����
                               end
                                else
                                  begin
                                    // ��������, ���� �� � ���� ����� ��������� �����
                                     If FindFirst(Folder_+'\*', faDirectory, SearchRec)=0 then
                                       repeat
                                         if SearchRec.Name='.' then
                                         FindNext(SearchRec);
                                         if SearchRec.Name='..' then
                                         FindNext(SearchRec);

                                         //Showmessage(SearchRec.Name);
                                         // ���� ������� �����-������ �����
                                         if SearchRec.Attr=faDirectory then
                                            begin
                                               //Showmessage('��������� ����� ����! '+SearchRec.Name);
                                               goto Metka7;
                                            end;

                                       until FindNext(SearchRec) <> 0;
                                       FindClose(SearchRec);

                                     //ShowMessage(Folder_);                            // ��� �����
                                     // ������ �����, ���� �� ������� ���������
                                     MyRemoveDir(Folder_);                         // ��������
                                  end;  }
/////////////////////////// ����������, ��� � ��� ��������� �����, � ��� ��������  ����� ///////////////////////////////////////////////////



/////////////////////////// �������� ����� ///////////////////////////////////////////////////
// ����� ������� ������������� ����� ����� � ������� ������ �������� ����� ������ � ����������.
{                            if copy(after(Folder_,'texture'),6,1)<>'' then
                               begin
                                  ShowMessage(before(Folder_,'.TIS\'));
                                     // ������ �����. ��������� �����
                                  MyRemoveDir(Folder_);
                               end; }
/////////////////////////// �������� ����� ����� ///////////////////////////////////////////////////


                           // ������ �����. ����� � ��������.
  {��������!}                         //MyRemoveDir(Folder_);
                                      DelDir(Folder_);
//Metka7:

//                         //������ ������ aircraft.cfg, �����. title_ � texture.TIS
//                         //DeleteSection, ���������������� �� ����� ��������� ��������������� ������ aircraft.cfg
                           //ShowMessage(before(Folder_,'texture'));  // ����������������. ��� �����
                                     w:=-1;
                                x10:=TStringlist.Create;
                                x11:=TStringlist.Create;
                                AssignFile(airfile,before(Folder_,'texture')+'aircraft.cfg');

                                append(airfile);
                                WriteLn(airfile, ''); // ������� ������ ������ ��� ����������� ������ �����
                                CloseFile(airfile);

                                //MyRemoveDir(GetTempDir+'RATS_extracted\temp_Ini\'); // ������ �����, ���� ��� ����
                                DelDir(GetTempDir+'RATS_extracted\temp_Ini\'); // ������ �����, ���� ��� ����

                                if not DirectoryExists(GetTempDir+'RATS_extracted\temp_Ini\') then   // �������� ��������� �����
                                    if not CreateDir(GetTempDir+'RATS_extracted\temp_Ini\') then
                                    raise Exception.Create('Cannot create temp_Ini directory!');


                                /////////������� ������ ������ ����� �������� fltsim. //////////////////
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
                                // ��� �������� ���� � ����� ���������� ���������� Folder_
                                x11.SaveToFile(before(Folder_,'texture')+'aircraft.cfg');
                                /////////����� ������� ������ ������ ����� �������� [fltsim. //////////////////

                                ///////////////// ��������� ���� �� �������� ///////////////////////////////////
                                reset(airfile);
                                      while not eof(airfile) do
                                        begin
                                //        i:=0;
                                          readln(airfile, sq);
                                          if copy(sq,0,8)='[fltsim.' then  // ������ ���� ��
                                begin
                                inc(w);
                                AssignFile(tt,GetTempDir+'RATS_extracted\temp_Ini\fltsim.'+IntToStr(w)+'.txt');
                                rewrite(tt);
                                Append(tt);
                                writeln(tt, sq);

                                repeat
                                        readln(airfile, sq);
                                        writeln(tt,sq);
                                until copy(sq,0,1)=''; // ������ � ���������� � ����� �� ����� �������
                                closefile(tt);
                                end; (*if [fltsim.*)

                                x10.Add(sq);
                                        end; (*while*)
                                x10.Add('');                     // ������� ������ ������ ��� ������� ����� [General] � �������� [fltsim.]
                                closefile(airfile);
                                ///////////////// ��������� ��������� ���� �� �������� /////////////////////////

                                ///////////����������� �� ��������� ����� ����� � title_
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
                                ///////////����� ����������� �� ��������� ����� ����� � Texture=TIS ////////////////

                                ///////////////// �������� ����� ���� aircraft.cfg //////////////////////////////
                                //������: ������� � ����� ������ x10 (��� ������ general � ��� ���������) ��� ��������� � x10

                                // ����� ������ ����� � ��������� � ����� ������ �� ���� ������ �� �������
                                If FindFirst(GetTempDir+'RATS_extracted\temp_Ini\*.*', faAnyFile, SearchRec)=0 then
                                repeat
                                //SearchRec.Name - ��� �����

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
                                ///////////////// ����� �������� ����� ���� aircraft.cfg ////////////////////////
                                x10.Free;
                                   // ����� ������� ��������� �������� ���� ������ ������ �����.

                                   
                                x11.Free;
                                //MyRemoveDir(GetTempDir+'RATS_extracted\temp_Ini\');
                                DelDir(GetTempDir+'RATS_extracted\temp_Ini\');



                                         // ������� �������������
                                         // ����������� Renum
                                         k:=-1;
                                        x7:=TStringlist.Create;
                                        AssignFile(airfile,before(Folder_,'texture')+'aircraft.cfg');

                                        append(airfile);
                                        WriteLn(airfile, ''); // ������� ������ ������ ��� ����������� ������ �����
                                        CloseFile(airfile);

                                        reset(airfile);
                                              while not eof(airfile) do
                                                begin
                                                  readln(airfile, srr);
                                                  if copy(srr,0,8)='[fltsim.' then  // ������ ���� ��
                                        begin
                                        inc(k);
                                        x7.Add('[fltsim.'+IntToStr(k)+']');
                                        repeat
                                        readln(airfile, srr);
                                        x7.Add(srr);

                                         until copy(srr,0,1)=''; // ������ � ���������� � ����� �� ����� �������
                                        end; (*if [fltsim.*)
                                        x7.Add(srr);
                                                end; (*while*)
                                        closefile(airfile);
                                        x7.SaveToFile(before(Folder_,'texture')+'aircraft.cfg');
                                        x7.Free; 



                                 // ������ ������ ������
                                 // ����������� DelEmptyStr
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
                                x8.Delete(x8.Count-1);    // ������ ��������� ������� ������ (���������)
                                x8.SaveToFile(before(Folder_,'texture')+'aircraft.cfg');
                                x8.Free;


                        end;   {3}
                          // �������� ��� ��� ������ �� �������� ����� .TIS
//                             Root_texture_check(self);

                         // ������ �� ini ����� ������ Tesis
  {��������!}                       MyIni.EraseSection(label2.Caption);
               end;  {5656}
           x15.Free;
           MyIni.Free;
        end;
Metka4:
i:=NoteBook1.PageIndex;
NoteBook1.PageIndex:=i+1;
if Edit3.Text<>'' then NoteBook1.PageIndex:=i+2; // ���� ��� ����������� ���������, �� ������� ����� �� 2 �������� ������.
end;


procedure TForm1.Button6Click(Sender: TObject);
var i: Integer;
begin
i:=NoteBook1.PageIndex;        // ������ �����
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
if not OpenDialog2.Execute then  // ���� ���� ������ �������
     Exit;
Edit3.Text:=ExtractFilePath(OpenDialog2.FileName);
if FileExists(Edit3.Text+'\Modules\terrain.dll') then
 begin
    Button5.Enabled:=true;    // �������� ���������� �� "��������"
    FS2004RegWrite(self);    // ���� �� ������� ������ EXE Path, �� ����� �������� � ������ ���.
 end
 else
 Button5.Enabled:=false;
end;


procedure TForm1.Button4Click(Sender: TObject);
begin                                           // �������� � ����� ����� Readme
ShellExecute(0,nil,PChar(GetTempDir+'RATS_extracted'+'\Readme.txt'),nil,nil,SW_SHOWNORMAL);
end;




// ��������� StringGrid1 ���������� �� ��������������� ������
procedure TForm1.GenStringTable(Table: Boolean);
var
f: textfile;
s: String;
SR:TSearchRec; // ��������� ����������
FindRes:Integer; // ���������� ��� ������ ���������� ������

begin
ButtonTag:=-2;
i:=0;
FindRes:=FindFirst(GetTempDir+'RATS_extracted\Textures\*.*',faDirectory,SR); // ������� ������� ������ � ������ ������
While FindRes=0 do // ���� �� ������� ����� (��������), �� ��������� ����
   begin
      inc(i);
      inc(ButtonTag);
      //MainArray[i]:=FindRes;
// ���������� � ������ �������� ���������� ��������
//����� �� ���� ������ . �..
if (SR.Attr=faDirectory) and ((SR.Name='.')or(SR.Name='..')) then
begin
FindRes:=FindNext(SR);
Continue;
end;

      MainArray[ButtonTag]:=SR.Name; // ������� ��� � ������ �� ������ ������

AssignFile(f,GetTempDir+'RATS_extracted\Textures\'+SR.Name+'\[Fltsim.xxx].txt');
//label18.Caption:= GetTempDir+'RATS_extracted\Textures\'+SR.Name+'\[Fltsim.xxx].txt';
 reset(f);
      while not Eof(f) do // ��������� ��� ���� �� ������ � ���� StringGrid1
begin
  readln(f, s);
  if pos('description=', s)>0 then
  begin
    // ����� ����� ��������� ���������� �������� �� �������� ����� (��� ���������� ������ � stringgrid1)

    form1.StringGrid1.Cells[0,ButtonTag]:=copy(s,13,300);    // ���� �� �������������
    //break;
  end;
end;
closefile(f);

reset(f);
while not Eof(f) do  // ��������� ��� ���� �� ������ � ���� StringGrid1
begin
  readln(f, s);
  if pos('texture=', s)>0 then
  begin
                         // ���� �� ���������
    form1.StringGrid1.Cells[2,ButtonTag]:='texture.'+copy(s,9,3);
    //break;
  end;
end;
closefile(f);

      StringGrid1.Cells[3,ButtonTag]:='INSTALL?';
      StringGrid1.Cells[1,ButtonTag]:=SR.Name;
      FindRes:=FindNext(SR); // ����������� ������ �� �������� ��������
   end;
  if ButtonTag>10 then
  begin
StringGrid1.RowCount:=ButtonTag+1; // ������� ���������� ����� ������� ����� ��, ��� � ���������� ��������� � ������
  end;
FindClose(SR); // ��������� �����
end;




////////////////// ������������� ������ � ���� ����������
procedure TForm1.SelectInstall(Sender: TObject);
//var
//s: String;
begin
 OpenDialog3.InitialDir:=Edit3.Text+'\Aircraft';
 //OpenDialog3.Execute;
if not OpenDialog3.Execute then
     Exit;
// s:=Opendialog3.FileName;
// if s='' then exit;  // ���� ������������ ������ �� ������, �� �� ����������

// ����� ������ ���������� �������� ��������� �� ������ � ���� � ��������� ����� � ������������� ����������
//aircraft:=GetTempDir+'RATS_extracted\Textures\'+MainArray[row];
aircraft:=GetTempDir+'RATS_extracted\Textures\'+MainArray[StringGrid1.row]+'\'+StringGrid1.Cells[2,ButtonTag];
label15.Caption:=aircraft;                      // ����
// ���� � �������� ���� ����� ���������
mainPath:=ExtractFilePath(Opendialog3.FileName);
label17.Caption:=mainPath;                      // ����
// aircraft:=StringGrid1.Cells[1,2];
// label15.Caption:=GetTempDir+'RATS_extracted\Textures\'+StringGrid1.Cells[1,Column];

end;


///////// �������������� �������� ////////////////
procedure TForm1.Notebook1PageChanged(Sender: TObject);
begin
if NoteBook1.PageIndex=1 then
Button6.Enabled:=true;

if NoteBook1.PageIndex=1 then
if FileExists(Edit3.Text+'\Modules\terrain.dll') then
 begin
    Button5.Enabled:=true;    // �������� ���������� �� "��������"
 end
 else
 Button5.Enabled:=false;

if NoteBook1.PageIndex=2 then
 begin
    //
   GenStringTable(true);  //���������� ������ ��������������� ���������
   Button5.Caption:='Finish';
   Button6.Enabled:=false;
 end;
end;



// ������������� ����� [fltsim.] � ������ �� ��������� ����
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
//Rewrite(f); //������� ������
Rewrite(tempfile);   //������� ������
label18.Caption:=GetTempDir+'RATS_extracted\Textures\'+MainArray[StringGrid1.row]+'\[Fltsim.XXX].txt';

//////////////////
// ����� ��������� ���������� ������� fltsim.xxx
u:=0;
reset(airfile);
while not Eof(airfile) do
begin
   Inc(u);
   ReadLn(airfile,tmpstr);
   if copy(tmpstr,1,7)='[fltsim' then
     begin
// �������� ������ �����, � ������� ����������� '[fltsim' � ������
         MyArrStr[u]:=tmpstr;

//Memo1.Lines.Add(MyArrStr[u]);
     Rewrite(tempfile);
     WriteLn(tempfile, tmpstr); // ���������� ������, � ������� ����� ����� ��������, � ������� ��������� ����
     CloseFile(tempfile);
     end;
//label1.Caption:=inside(tmpstr,'.',']');

reset(tempfile);
Readln(tempfile,tmpstr2);
if tmpstr2='' then     // ���� � ����� ���� �����, �� ��������� ��������
fltsimN:=IntToStr(-1)
else

////// ������, ��� � �������� ������
fltsimN:=inside(tmpstr2,'.',']');     // ��� ��� ����� FLTSIM.XXX �� AIRCRAFT.CFG ! ! !
closefile(tempfile);
/////////////////
end;
//closefile(airfile);
///////////-----------------------------------///////////////////////////////////
// �� �������!!!!
//Append(f);    // ������� � ������ sim= ��� �����, ���������� � �������, �� ��� ����������
L := Length(ExtractFileExt(ExtractFileName(OpenDialog3.FileName)));
s:= 'sim='+Copy(ExtractFileName(OpenDialog3.Filename),1,(Length(ExtractFileName(OpenDialog3.Filename))-L));
//WriteLn(f, 'sim='+Copy(ExtractFileName(OpenDialog3.Filename),1,(Length(ExtractFileName(OpenDialog3.Filename))-L)) );
//closefile(f);
// �� �������!!!!


label22.Caption:='��������� ����� fltsim.='+fltsimN;
x:=TStringList.Create;
m:=StrToInt(fltsimN);

//////////////////// ���������� ����� ���� fltsim.xxx (��������� [fltsim.xxx]_temp.txt) ////////
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
x.Delete(0);  // �������� ���������� ����� �� ������ ����� [fltsim.XXX].txt
x.Delete(1);

x.SaveToFile(GetTempDir+'RATS_extracted'+'\temp_fltsim.XXX.txt');
closefile(f2);
x.Free;
closefile(airfile);
end;



// ����������� �����
procedure TForm1.FoldersCopy(Sender: TObject);
var OpStruc: TSHFileOpStruct;
frombuf, tobuf: Array [0..128] of Char;
begin FillChar( frombuf, Sizeof(frombuf), 0 );
FillChar( tobuf, Sizeof(tobuf), 0 );
StrPCopy( frombuf, aircraft );  // ���� ������ ����������
StrPCopy( tobuf, MainPath );    // ���� ���� ����������   // ���������� � ��������� SelectInstall
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



// �������� ������ ����� �� aircraft.cfg (���� ������ ����� ������)
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
//x8.Delete(x8.Count-1); // ������ ��������� �������. �� ��������� � ���� ���������� � ����� ����� aircraft.cfg
x8.SaveToFile(mainPath+'aircraft.cfg');
x8.Free;

end;




// ������������� ������ [fltsim]
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
WriteLn(airfile, ''{#13}); // ������� ������ ������ ��� ����������� ������ �����
CloseFile(airfile);

// ����� �/� ������ ������ ����� [fltsim.], ���� ��� ��������� � ������ �����
      reset(airfile);
      while not eof(airfile) do
        begin
          readln(airfile, srr);
          if copy(srr,0,8)='[fltsim.' then  // ������ ���� ��
begin
inc(i);
//AssignFile(tt,'c:\test\'+IntToStr(i)+'1.txt');    // �� �������! ��� ��� ������� ��������� �������� ������ �� RATS
//rewrite(tt);
//Append(tt);
//        writeln('[fltsim.'+IntToStr(i)+']');
x7.Add('[fltsim.'+IntToStr(i)+']');
repeat
readln(airfile, srr);
//        writeln(tt,srr);
x7.Add(srr);

 until copy(srr,0,1)=''; // ������ � ���������� � ����� �� ����� �������
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




// �������� ������ [fltsim.] �� ����� aircraft.cfg  (���, ������� �������� Texture=TIS)
// ������� �� DeleteSection ������ � ����� �������� sj
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
WriteLn(airfile, ''); // ������� ������ ������ ��� ����������� ������ �����
CloseFile(airfile);

//MyRemoveDir(GetTempDir+'RATS_extracted\temp_any\'); // ������ �����, ���� ��� ����
DelDir(GetTempDir+'RATS_extracted\temp_any\'); // ������ �����, ���� ��� ����

if not DirectoryExists(GetTempDir+'RATS_extracted\temp_any\') then   // �������� ��������� �����
    if not CreateDir(GetTempDir+'RATS_extracted\temp_any\') then
    raise Exception.Create('Cannot create temp_any directory!');

/////////������� ������ ������ ����� �������� fltsim. //////////////////
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
/////////����� ������� ������ ������ ����� �������� [fltsim. //////////////////

///////////////// ��������� ���� �� �������� ///////////////////////////////////
reset(airfile);
      while not eof(airfile) do
        begin
//        i:=0;
          readln(airfile, sq);
          if copy(sq,0,8)='[fltsim.' then  // ������ ���� ��
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
//            w:=w-1; // ������ ����� ����������� � ���������� ����
            //deletefile('c:\test\fltsim.'+IntToStr(w+1)+'.txt');
//          end;
        writeln(tt,sq);
until copy(sq,0,1)=''; // ������ � ���������� � ����� �� ����� �������
closefile(tt);
end; (*if [fltsim.*)

x10.Add(sq);
        end; (*while*)
x10.Add('');                     // ������� ������ ������ ��� ������� ����� [General] � �������� [fltsim.]
closefile(airfile);
///////////////// ��������� ��������� ���� �� �������� /////////////////////////

///////////����������� �� ��������� ����� ����� � Texture=TIS
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
///////////����� ����������� �� ��������� ����� ����� � Texture=TIS ////////////////


///////////////// �������� ����� ���� aircraft.cfg //////////////////////////////
//������: ������� � ����� ������ x10 (��� ������ general � ��� ���������) ��� ��������� � x10

// ����� ������ ����� � ��������� � ����� ������ �� ���� ������ �� �������
If FindFirst(GetTempDir+'RATS_extracted\temp_any\*.*', faAnyFile, SearchRec)=0 then
repeat
//SearchRec.Name - ��� �����
// ����� ����� �������� ���������� ������ �� ����

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
///////////////// ����� �������� ����� ���� aircraft.cfg ////////////////////////
x10.Free;
x11.Free;
//MyRemoveDir(GetTempDir+'RATS_extracted\temp_any\');
DelDir(GetTempDir+'RATS_extracted\temp_any\');
end;




// �������� ������ [fltsim.] �� ����� aircraft.cfg  (�� RATS!)
// ���� �������� �� ������� Texture=TIS (sj)
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
WriteLn(airfile, ''); // ������� ������ ������ ��� ����������� ������ �����
CloseFile(airfile);

//MyRemoveDir(GetTempDir+'RATS_extracted\temp\'); // ������ �����, ���� ��� ����
DelDir(GetTempDir+'RATS_extracted\temp\'); // ������ �����, ���� ��� ����

if not DirectoryExists(GetTempDir+'RATS_extracted\temp\') then   // �������� ��������� �����
    if not CreateDir(GetTempDir+'RATS_extracted\temp\') then
    raise Exception.Create('Cannot create temp directory!');


/////////������� ������ ������ ����� �������� fltsim. //////////////////
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
/////////����� ������� ������ ������ ����� �������� [fltsim. //////////////////


///////////////// ��������� ���� �� �������� ///////////////////////////////////
reset(airfile);
      while not eof(airfile) do
        begin
//        i:=0;
          readln(airfile, sq);
          if copy(sq,0,8)='[fltsim.' then  // ������ ���� ��
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
//            w:=w-1; // ������ ����� ����������� � ���������� ����
            //deletefile('c:\test\fltsim.'+IntToStr(w+1)+'.txt');
//          end;
        writeln(tt,sq);
until copy(sq,0,1)=''; // ������ � ���������� � ����� �� ����� �������
closefile(tt);
end; (*if [fltsim.*)

x10.Add(sq);
        end; (*while*)
x10.Add('');                     // ������� ������ ������ ��� ������� ����� [General] � �������� [fltsim.]
closefile(airfile);
///////////////// ��������� ��������� ���� �� �������� /////////////////////////


///////////����������� �� ��������� ����� ����� � Texture=TIS
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
///////////����� ����������� �� ��������� ����� ����� � Texture=TIS ////////////////


///////////////// �������� ����� ���� aircraft.cfg //////////////////////////////
//������: ������� � ����� ������ x10 (��� ������ general � ��� ���������) ��� ��������� � x10

// ����� ������ ����� � ��������� � ����� ������ �� ���� ������ �� �������
If FindFirst(GetTempDir+'RATS_extracted\temp\*.*', faAnyFile, SearchRec)=0 then
repeat
//SearchRec.Name - ��� �����
// ����� ����� �������� ���������� ������ �� ����

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
///////////////// ����� �������� ����� ���� aircraft.cfg ////////////////////////
x10.Free;
x11.Free;
//MyRemoveDir(GetTempDir+'RATS_extracted\temp\');
DelDir(GetTempDir+'RATS_extracted\temp\');
end;





// �������� ������ [fltsim.] RATS �� ����� aircraft.cfg // ������� �� DeleteSection ������ � sk � sh
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
WriteLn(airfile, ''); // ������� ������ ������ ��� ����������� ������ �����
CloseFile(airfile);

//MyRemoveDir(GetTempDir+'RATS_extracted\tempRATS\'); // ������ �����, ���� ��� ����
DelDir(GetTempDir+'RATS_extracted\tempRATS\'); // ������ �����, ���� ��� ����

if not DirectoryExists(GetTempDir+'RATS_extracted\tempRATS\') then   // �������� ��������� �����
    if not CreateDir(GetTempDir+'RATS_extracted\tempRATS\') then
    raise Exception.Create('Cannot create tempRATS directory!');


/////////������� ������ ������ ����� �������� fltsim. //////////////////
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
/////////����� ������� ������ ������ ����� �������� [fltsim. //////////////////

///////////////// ��������� ���� �� �������� ///////////////////////////////////
reset(airfile);
      while not eof(airfile) do
        begin
//        i:=0;
          readln(airfile, sq);
          if copy(sq,0,8)='[fltsim.' then  // ������ ���� ��
begin
inc(w);
AssignFile(tt,GetTempDir+'RATS_extracted\tempRATS\fltsim.'+IntToStr(w)+'.txt');
rewrite(tt);
Append(tt);
writeln(tt, sq);

repeat
        readln(airfile, sq);
        writeln(tt,sq);
until copy(sq,0,1)=''; // ������ � ���������� � ����� �� ����� �������
closefile(tt);
end; (*if [fltsim.*)

x10.Add(sq);
        end; (*while*)
x10.Add('');                     // ������� ������ ������ ��� ������� ����� [General] � �������� [fltsim.]
closefile(airfile);
///////////////// ��������� ��������� ���� �� �������� /////////////////////////

///////////����������� �� ��������� ����� ����� � Texture=TIS
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
        if sl='' then continue; // ���� ��� ��������� �����, �� ������ ��������� ����.
        //MyRemoveDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+sl); // ������� �����. �����
        DelDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+sl); // ������� �����. �����
//        ShowMessage(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+sl);
         end;
until FindNext(SearchRec) <> 0;
FindClose(SearchRec);


{// �������� ����� �� ����� �������������� ��������������� ������ � ������� �����. �������� � ����� ���������
If FindFirst(GetTempDir+'RATS_extracted\Textures\'+StringGrid1.Cells[1,Row]+'\'+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\*.*', faAnyFile, SearchRec)=0 then
repeat
if SearchRec.Name='.' then
FindNext(SearchRec);
if SearchRec.Name='..' then
FindNext(SearchRec);
//ShowMessage(GetTempDir+'RATS_extracted\Textures\'+StringGrid1.Cells[1,Row]+'\'+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+SearchRec.Name);
   if DirectoryExists(GetTempDir+'RATS_extracted\Textures\'+StringGrid1.Cells[1,Row]+'\'+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+SearchRec.Name) then
  begin
     MyRemoveDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+SearchRec.Name); // ������� �����
//     ShowMessage(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+'\'+SearchRec.Name);
  end;
until FindNext(SearchRec) <> 0;
FindClose(SearchRec); }
///////////����� ����������� �� ��������� ����� ����� � Texture=TIS ////////////////



///////////////// �������� ����� ���� aircraft.cfg //////////////////////////////
//������: ������� � ����� ������ x10 (��� ������ general � ��� ���������) ��� ��������� � x10

// ����� ������ ����� � ��������� � ����� ������ �� ���� ������ �� �������
If FindFirst(GetTempDir+'RATS_extracted\tempRATS\*.*', faAnyFile, SearchRec)=0 then
repeat
//SearchRec.Name - ��� �����
// ����� ����� �������� ���������� ������ �� ����

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
///////////////// ����� �������� ����� ���� aircraft.cfg ////////////////////////
x10.Free;
x11.Free;
// � ������ ������ ���� ��������� ����� tempRATS
//MyRemoveDir(GetTempDir+'RATS_extracted\tempRATS\');
DelDir(GetTempDir+'RATS_extracted\tempRATS\');
end;





// ����� ����� ����������� ����� � ���� aircraft.cfg � ������ �� ����
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
  if pos(stt, s2)>0 then  // ������ ���� ��
begin
//     ShowMessage('������ [fltsim] �� General');       // ��� �����

     // ����������� ������ � �������� ����� aircraft.cfg �� ������ [General]
     // ������� ������� � x3 ������ �� aircraft.cfg �� [General]
//     closefile(airfile);
     
         x3:=TStringlist.Create;
      reset(airfile);
        repeat
         readln(airfile, s3);
      x3.Add(s3);
        until pos('[General]',s3)>0;
        // ������ ��������� ������� �� x3 (������� [General])
        x3.Delete(x3.Count-1);
       closefile(airfile);

      // ����� ������� � x3 ��� ������ �� temp_fltsim.XXX.txt
      reset(temp_air);
      while not eof(temp_air) do
        begin
          readln(temp_air, s3);
          x3.Add(s3);
        end;
        closefile(temp_air);

        x3.Add('');  // ������� �������� ������
//        x3.Add(#13); // ������� �������� ������
        x3.Add('[General]'); // ������� ������� ���� ��������� ������
      // � ����� ���������� ������ ���� aircraft.cfg, ������� � ���. [General]
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

       x3.SaveToFile(mainPath+'aircraft.cfg');  // ��������� ���������
       x3.Free;

     Exit;                                                       //������, ��� ��������� ������ [fltsim.]
end; {if pos}                                                    // �� ��� ����� [General]
     until pos('[General]',s2)>0;

// ShowMessage('������ [fltsim] ����� General');     // ��� �����
closefile(airfile);

// ����� ��������� Append, �� ���� ������ ��������� ���� ������ � ����� ����� aircraft.cfg
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

  x2.SaveToFile(mainPath+'aircraft.cfg');  // ��������� ���������
  x2.Free;
end;



// �������� ��� �������� ����� ���������� (��������� �����������)
procedure TForm1.FilesFoldersCopy(Sender: TObject);
begin
FullDirectoryCopy(GetTempDir+'RATS_extracted\Textures\'+StringGrid1.Cells[1,Row]+'\texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3), mainpath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3),false,true);
end;



// ������ �������������� ������ � RATS_installer_data.ini
procedure TForm1.IniRecord(Sender: TObject);
var
MyIni: TIniFile;
FltXXX: TextFile;
rat5, texture_: String;
begin
MyIni:=TIniFile.Create(Edit3.Text+'\RATS_installer_data.ini');
            // ������ ������� title= � texture=
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
                       // ������ ���� - ������ � ��� ������� ����, ������ � ���������� �������.
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



// ���� �� �������
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

  obr1, obr2, obr3: String; // ������� ��� ������
  found, found2, found3: boolean; // TRUE � ���������� ������� � ��������� �������
  u, u2, e, n: integer; // ������ �������� �������

airfile: TextFile;  // ��� ���������� ����� ��, ��� � � ��������� delemptystr
sw: String;
x23: TStrings;

label Metka;
label Metka2;
//label Metka3;

begin
recTmp:=StringGrid1.selection;
Row:=recTmp.Top;
Column:=recTmp.Left;
if Column<>3 then exit; // ���� ������� � �������, �������� �� install/uninstall, �� ������ �� ������
if Row>ButtonTag then exit; // ���� ������� � ����, � ������� ��� ���������, �� ������ �� ������
if StringGrid1.Cells[3,Row]='OK!' then exit; // ���� ������ ������� ��� ����������

sh:='';
sj:='';  // ������� ������
sk:='';
aircraft:='';
mainpath:='';

SelectInstall(self); // ��������� ���������� ���� ������ �����
// ��� ���� ������ ��� ��� air ����� � ����, ���� ����� ���������� ������� � ����� (������)

if mainPath='' then exit; // ���� �� ��� ������� ���� ��������� � OpenDialog3


// ������ ��������, �� �� ������ ��������? (������ model= �� [fltsim.XXX] ������� � ������� � aircraft.cfg)
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

// ��������� ������������ ������ � [fltsim.XXX] � � ������������ ����� Aircraft.cfg
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////����� model= � ������ Texture=TIS /////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
w:=-1;
i:=0;
x12:=TStringlist.Create;
x13:=TStringlist.Create;
AssignFile(f3,mainPath+'aircraft.cfg');

append(f3);
WriteLn(f3, ''); // ������� ������ ������ ��� ����������� ������ �����
CloseFile(f3);

//MyRemoveDir(GetTempDir+'RATS_extracted\temp2\'); // ������ �����, ���� ��� ����
DelDir(GetTempDir+'RATS_extracted\temp2\'); // ������ �����, ���� ��� ����

if not DirectoryExists(GetTempDir+'RATS_extracted\temp2\') then   // �������� ��������� �����
    if not CreateDir(GetTempDir+'RATS_extracted\temp2\') then
    raise Exception.Create('Cannot create temp2 directory!');

/////////������� ������ ������ ����� �������� fltsim. //////////////////
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
/////////����� ������� ������ ������ ����� �������� [fltsim. //////////////////


///////////////// ��������� ���� �� �������� ///////////////////////////////////
reset(f3);
      while not eof(f3) do
        begin
          readln(f3, sq);
          if copy(sq,0,8)='[fltsim.' then  // ������ ���� ��
begin
inc(w);
AssignFile(tt,GetTempDir+'RATS_extracted\temp2\fltsim.'+IntToStr(w)+'.txt');
rewrite(tt);
Append(tt);
writeln(tt, sq);

repeat
        readln(f3, sq);
        writeln(tt,sq);
until copy(sq,0,1)=''; // ������ � ���������� � ����� �� ����� �������
closefile(tt);
end; (*if [fltsim.*)

x12.Add(sq);
        end; (*while*)
x12.Add('');                     // ������� ������ ������ ��� ������� ����� [General] � �������� [fltsim.]
closefile(f3);
///////////////// ��������� ��������� ���� �� �������� /////////////////////////


///////////�������� �� ��������� ����� ����� � Texture=TIS � � model=ge_no_refl
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
          // ���� ������� � �� � ������, �� ������� � ������ �������� texture= � model=
          // ��� ����������� �������������.
         Arraymodel[i]:=sh+' '+sj;
//         Showmessage(arraymodel[i]);
       end;

if (sj<>'') and (sh<>'') and (sk<>'') then
       begin
          // ���� ������� � �� � ������, �� ������� � ������ �������� texture= � model=
          // ��� ����������� �������������.
         Arraymodel2[i]:=sh+' '+sj+' '+sk;
//         Showmessage(arraymodel2[i]);
       end;



until FindNext(SearchRec) <> 0;
FindClose(SearchRec);
///////////����� �������� �� ��������� ����� ����� � Texture=TIS � � model=111_no_refl
x12.Free;
x13.Free;
//MyRemoveDir(GetTempDir+'RATS_extracted\temp2\');  // ���, ����� ��� ������ �� �����, ������� ��
DelDir(GetTempDir+'RATS_extracted\temp2\');  // ���, ����� ��� ������ �� �����, ������� ��
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// ����� ������ model= � ������ Texture=TIS //////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////




/////////////////////// UPDATE ////////////////////////////////////////////////////////////////////////
///////////// ���� ����� �������� ����������, �� ��� ������ ������ �������  ///////////////////////////
if (copy(Label4.Caption,0,6)='Update') then
//  if (sj<>'') and (sh<>'') then
begin
/// ��������, ���� �� ����� texture.TIS. ���� ����, �� ��� � �������.
/// ���� ���, �� ������ �������� � ������ ����� ��� ������������� ������. ������� ������� ������������.
if not DirectoryExists(mainpath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)) then
      begin {7877}
        MessageDlg('Warning! You are trying to install update without original texture pack.'+#13+'Please install original full or optimized texture pack first.',mtWarning,[mbOK],0);
        Exit;
      end;  {7877}

///if DirectoryExists(mainpath+'texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3)) then
/// begin {44}

        // ������ ��������, title= (�� [fltsim.XXX] ������� ������, ���� �� ����� � aircraft.cfg)
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

// ������ ��� ������ � aircraft.cfg
n:=0;
        AssignFile(f3, mainpath+'aircraft.cfg');
        reset(f3);
        while not Eof(f3) do
        begin
          readln(f3, rat5);
          if pos('title=',rat5)>0 then
             begin
             inc(n);
              arraytitle[n]:=copy(rat5,7,100);  // ������� � ������ ��� ������ title=
             end;
        end;
        closeFile(f3);
    // � ������ ������ title= �� [fltsim.XXX] ����������� � arraytitle[h]
  obr3:=title_;
  found3 := FALSE;
  e := 0;
          repeat
            if arraytitle[e] = obr3 then
              found3 := TRUE
            else
              inc(e);
          until (e > 10000) or (found3 = TRUE);
          if found3 then // ���� ������ ����� �� title= � aircraft.cfg
        begin
               ShowMessage('This aircraft is already installed  ('+title_+')');

                // ������ ������ ������� (��� � ��������� DelEmptyStr)
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
                x23.Delete(x23.Count-1); // ������ ��������� �������. �� ��������� � ���� ���������� � ����� ����� aircraft.cfg
                x23.SaveToFile(mainPath+'aircraft.cfg');
                x23.Free;
                Exit;
//               goto Metka3;
        end
        else
//   if MessageDlg('Would you like to update previous textures pack from RATS?', mtInformation,[mbYes, mbNo],0)=mrNo then
// Exit;
   begin
     // ��������� � ���������� ������
        goto Metka;
    end;
///    else
///      begin {55}
///        MessageDlg('Warning! You are trying to install update without original texture pack.'+#13+'Please install full or optimized texture pack first.',mtWarning,[mbOK],0);
///        Exit;
///      end; {55}
end; {label4.Caption Update}
///////////////////// UPDATE /////////////////////////////////////////////////////////////////////////


// ���� ����� ���, �� �� ����� ������ ���������, ���� �� �����-�� ������ Texture.TIS �����. model=.
if not DirectoryExists(mainPath+StringGrid1.Cells[2,ButtonTag]) then goto Metka2;


// ���� ����������� ���������� �� texture=TIS � model=ge_no_refl, � ����� ��� setup=RATS
// �� �������� ������ ������� ������������.

// ����� � �������� ���� �� ����� ������ �� ����� �������
obr1:=sh+' '+sj;
obr2:=sh+' '+sj+' '+sk;
found := FALSE; // ����� ������� �������� � ������� ���
found2 := FALSE; // ����� ������� �������� � ������� ���
u := 0;
  repeat
    if Arraymodel[u] = obr1 then
      found := TRUE
    else
      inc(u);
  until (u > 10000) or (found = TRUE);
  if found then // ���� ������� model=ge_no_refl � texture.tis
begin
           // ��������, ���� �� �� ������ ������� ���-������
        u2 := 0;
          repeat
            if Arraymodel2[u] = obr2 then
              found2 := TRUE
            else
              inc(u2);
          until (u2 > 10000) or (found2 = TRUE);
          if found2 then // ���� ������� model=ge_no_refl � texture.tis � ��� � setup=RATS
        begin
           // ��� RATS ������ � �������� � �� RATS, ������ ������� ��� ��� ����� ������������

{1}//           ShowMessage('��� RATS ������, ������ ������� ��� ��� ����� ������������');
           if MessageDLG('Previous version of RATS textures was found. Delete and install new RATS textures?',mtConfirmation,[mbYes,mbNo],0) = mrNo then
        //MessageDLG('������� ������������� �������� RATS. ������� � ���������� ����� �������� �� RATS?',mtConfirmation,[mbYes,mbNo],0);
//           Exit; // ������� No
        begin
        form1.label20.Caption:=tmpArr2[0];                                          //2
        exit; // ������� No
        end;
           // ����� ��������� �������� ����� texture.tis � ������ ���������
//           MyRemoveDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3));  // ������� texture.TIS (���������� � ��������� DeleteSectionRATS)
           // ������� ������ RATS, ��������������� �����  texture.tis
              DeleteSectionRATS(self); // ������� ��������� ����� � ������ �� aircraft.cfg
              ReNum(self);  // ������������ ������ [fltsim]
           goto Metka; // ����� - ��������� � ���������� ������.

        end {���� ������� RATS }
            else    // ���� �� �������, �� ��� RATS ������, � ���� ������ ������ model=ge_no_refl � texture.tis
                    // ������ ����� ������������, ��� � ���� ���� ���������� texture.TIS
                begin

{2}//                   ShowMessage('������ ����� ������������, ��� � ���� ���� ���������� texture.TIS');
                    if MessageDLG('Previous version of '+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+' was found. Delete and install new RATS textures?',mtConfirmation,[mbYes,mbNo],0)= mrNo then
                        //MessageDLG('������� ������������� �������� ���������� ������������. ������� � ���������� �������� �� RATS?',mtConfirmation,[mbYes,mbNo],0);
                        exit; // ������� No

                           // ����� ��������� �������� ����� texture.tis � ������ ���������
                           //MyRemoveDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3));  // ������� texture.TIS
                           DelDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3));  // ������� texture.TIS
                           // ������� ������, ��������������� �����  texture.tis
                           DeleteSection(self); // ������ ������ �� RATS                                              //1
                              ReNum(self);  // ������������ ������ [fltsim]
                           goto Metka; // ����� - ��������� � ���������� ������.

                end;
end {���� ������� model=ge_no_refl � texture.tis }

  else
//  ���� ������ �� �������, �� ��� �� RATS ������, �� �� RATS,
// ������ ������ ��������� ��� �����������.
                begin

{3}//                  ShowMessage('������ ������ ��������� ��� �����������.');
                  // ���� ���������� ����� �����
                  if DirectoryExists(mainPath+StringGrid1.Cells[2,ButtonTag]) then  // ���� ���� ����� texture.tis
                        begin {1}

                        //  ���� ���� ������ texture.tis � ����� aircraft.cfg
                        AssignFile(f3,mainPath+'aircraft.cfg');
                        reset(f3);
                        while not Eof(f3) do
                        begin {2}
                          readln(f3, rat2);
                                // ����� texture=ICAO � ���. �����
                          if pos('texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3), rat2)>0 then
                          begin {3}
                       tmpArr2[1]:=rat2; // ������� ������, ��� ����, ����� ����������, ���� �� ������ texture.�����
                          end;  {3}
                        end;  {EoF} {2}
                          closefile(f3);

                        // ���� ������ texture.TIS � ����� aircraft.cfg �� �������, �� ����� ����, � ������ �����. ���.
                        if tmpArr2[1]='' then
                          begin   {4}
                        if  MessageDLG('You have no associated section [fltsim.] in aircraft.cfg file for '+'texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3)+', but this texture was found.'+#13+'Do you want to remove this folder and install new RATS textures?',mtWarning,[mbYes,mbNo],0) = mrNo then
                        exit;  // ������� No
                          // ����� ��������� �������� ����� texture.tis
                           //MyRemoveDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3));  // ������� texture.TIS
                           DelDir(mainPath+'texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3));  // ������� texture.TIS
                             goto Metka; // ������ ���������
                          end;   {4}

                        end {if DirectoryExists}  {1}
                           else
                            // � ���� ����� ���, �� ����� ��������� ���� �� ������ � aircraft.cfg, ��������������� texture.TIS
Metka2:
        begin {5}
{4}//        ShowMessage('����� ���, � ������ Texture.TIS �������!');
        AssignFile(f3,mainPath+'aircraft.cfg');
        reset(f3);
        while not Eof(f3) do
        begin                     // ����� texture=ICAO � ���. �����
          readln(f3, rat2);
          if pos('texture='+copy(StringGrid1.Cells[2,ButtonTag],9,3), rat2)>0 then
            rat:=rat2;

        // ���� � ��� ���� ������ � ������, ��� /////////////////��������///////////////
        //  if pos()
        end; //while }
        closefile(f3);

        if rat<>'' then
        begin
     if MessageDLG('You have [fltsim.] section(s) associated with texture.'+copy(StringGrid1.Cells[2,ButtonTag],9,3)+', but texture was not found. Delete this section(s) and install new RATS textures?',mtConfirmation,[mbYes,mbNo],0)= mrNo then
           exit; // ������� No
        // ���� ������������ �������� � ���������, ������ ��� ������, ��� �����������
        // texture.TIS, � RATS, � ���.
             DeleteSection_any(self);
             ReNum(self);  // ������������ ������ [fltsim]
             goto Metka; // ����� - ��������� � ���������� ������.
        end;
        end; {5}

                  goto Metka; // ������ ���������
                end;




// ���� ������ �������� �� �������, �� ������ ���������� ���������
Metka:  // ���� ��������� ������ �� �� ���������� ����� (�� ���������� ����)

// ����������� ������ � ����� � ����� ���������� (opendialog3)
//FoldersCopy(self);    // �������� ����� � ����� ����������
FilesFoldersCopy(self);  // �������� ���������� ����� � ����� ����������



GenFltsimXXX(self); // ��������� ����� ��� ����� aircraft.cfg
//� ������ �� �� ��������� ����.


// ����� ����� � aircraft.cfg ���� ����� ��������� ��������������� ������ �� ��������� GenFltsimXXX
// ���������� � ������������ aircraft.cfg ����� ��������������� �����. (2� ��������, ���������� � �������� � � ����� �����)
AirCFG(self);


// ������������� ������ [fltsim] �� ������ ������
//ReNum(self);

//Metka3:
// ��������� �������� ���� ������ ������ �����
DelEmptyStr(self);

// � ��������������� ������ StringGrid1. � 3 �������� �����  "OK" ����� ���� ���������, ��������
StringGrid1.Cells[3,Row]:='OK!';

// ������ �������������� �������� � ���� RATS_installer_data.ini
IniRecord(self);


end;

procedure TForm1.Button8Click(Sender: TObject);
begin
// ������� ���� � ����
MessageDlg('                                  RATS Installer'+#13+#13+'                                 Version 1.0.0.0'+#13+#13+'                          Created by Samarin Vasiliy'+#13+'                                versus@mail15.com'+#13+#13+'Copyright � 2009 Russian AI Traffic System. All rights reserved.',mtInformation,[mbOK],0);
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
//������ Help �����
//ShowMessage('����� ����� �������� ������ ���������');
Form3.Showmodal;

end;

end.
