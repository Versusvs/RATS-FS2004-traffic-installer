unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShellAPI;

  const
Space = #$20;
BlackSpace = [#33..#126];


function LTrim(const Str: string): string;
function RTrim(Str: string): string;
function Trim(Str: string): string;
function RightStr(const Str: string; Size: Word): string;
function LeftStr(const Str: string; Size: Word): string;
function MidStr(const Str: string; Size: Word): string;
function inside(const Search, Front, Back: string): string;
function rightside(const Search, Front, Back: string): string;
function after(const Search, Find: string): string;
function before(const Search, Find: string): string;

implementation



function LTrim(const Str: string): string;
var
len: Byte absolute Str;
i: Integer;
begin
i := 1;
while (i <= len) and (Str[i] = Space) do
   Inc(i);
LTrim := Copy(Str, i, len)
end {LTrim};


function RTrim(Str: string): string;
var
len: Byte absolute Str;
begin
while (Str[len] = Space) do
   Dec(len);
RTrim := Str
end {RTrim};

 

function Trim(Str: string): string;
begin
Trim := LTrim(RTrim(Str))
end {Trim};

 

function RightStr(const Str: string; Size: Word): string;
var
len: Byte absolute Str;
begin
if Size > len then
   Size := len;
RightStr := Copy(Str, len - Size + 1, Size)
end {RightStr};



function LeftStr(const Str: string; Size: Word): string;
begin
LeftStr := Copy(Str, 1, Size)
end {LeftStr};

function MidStr(const Str: string; Size: Word): string;
var
len: Byte absolute Str;
begin
if Size > len then
   Size := len;
MidStr := Copy(Str, ((len - Size) div 2) + 1, Size)
end {MidStr};
//end;

// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//const
//BlackSpace = [#33..#126];
{squish() возвращает строку со всеми белыми пробелами и с удаленными
повторяющимися апострофами.}

{function squish(const Search: string): string;
var
Index: byte;
InString: boolean;
begin
InString := False;
Result := '';
for Index := 1 to Length(Search) do
begin
   if InString or (Search[Index] in BlackSpace) then
     AppendStr(Result, Search[Index]);
   InString := ((Search[Index] = '''') and (Search[Index - 1] <> '\'))
     xor InString;
end;
end;}
{before() возвращает часть стоки, находящейся перед
первой найденной подстроки Find в строке Search. Если
Find не найдена, функция возвращает Search.}

function before(const Search, Find: string): string;
var
index: byte;
begin
index := Pos(Find, Search);
if index = 0 then
   Result := Search
else
   Result := Copy(Search, 1, index - 1);
end;
{after() возвращает часть строки, находящейся после
первой найденной подстроки Find в строке Search. Если
Find не найдена, функция возвращает NULL.}

function after(const Search, Find: string): string;
var
index: byte;
begin
index := Pos(Find, Search);
if index = 0 then
   Result := ''
else
   Result := Copy(Search, index + Length(Find), 255);
end;
{RPos() возвращает первый символ последней найденной
подстроки Find в строке Search. Если Find не найдена,
функция возвращает 0. Подобна реверсированной Pos().}


function RPos(const Find, Search: string): byte;
var
FindPtr, SearchPtr, TempPtr: PChar;
begin
FindPtr := StrAlloc(Length(Find) + 1);
SearchPtr := StrAlloc(Length(Search) + 1);
StrPCopy(FindPtr, Find);
StrPCopy(SearchPtr, Search);
Result := 0;
repeat
   TempPtr := StrRScan(SearchPtr, FindPtr^);
   if TempPtr <> nil then
     if (StrLComp(TempPtr, FindPtr, Length(Find)) = 0) then
     begin
       Result := TempPtr - SearchPtr + 1;
       TempPtr := nil;
     end
     else
       TempPtr := #0;
until TempPtr = nil;
end;
{inside() возвращает подстроку, вложенную между парой
подстрок Front ... Back.}


function inside(const Search, Front, Back: string): string;
var
Index, Len: byte;
begin
Index := RPos(Front, before(Search, Back));
Len := Pos(Back, Search);
if (Index > 0) and (Len > 0) then
   Result := Copy(Search, Index + 1, Len - (Index + 1))
else
   Result := '';
end;
{leftside() возвращает левую часть "отстатка" inside() или Search.}


function leftside(const Search, Front, Back: string): string;
begin
Result := before(Search, Front + inside(Search, Front, Back) + Back);
end;
{rightside() возвращает правую часть "остатка" inside() или Null.}

function rightside(const Search, Front, Back: string): string;
begin
Result := after(Search, Front + inside(Search, Front, Back) + Back);
end;




end.
 