unit ARC;

interface

{=======================================================================
{ ������� ARC
{=======================================================================


LOCAL_VAR
GLOBAL_VAR
CONST_PARAMETER
MUT_PARAMETER

LOCAL_VAR -> LOCAL_VAR        IL+   D+
LOCAL_VAR -> GLOBAL_VAR       IL+   D+
LOCAL_VAR -> CONST_PARAMETER  IL-   D-
LOCAL_VAR -> MUT_PARAMETER    IL+(������) D+(������)

GLOBAL_VAR -> LOCAL_VAR       IL+   D+
GLOBAL_VAR -> GLOBAL_VAR      IL+   D+
GLOBAL_VAR -> CONST_PARAMETER IL+   D-   
GLOBAL_VAR -> MUT_PARAMETER   IL+(������) D+(������) 

PARAMETER -> LOCAL_VAR        IL+   D+
PARAMETER -> GLOBAL_VAR       IL+   D+ 
PARAMETER -> CONST_PARAMETER  IL-   D-
PARAMETER -> MUT_PARAMETER    IL+(������) D+(������)

��������:
//////////////////////////////////////////////////
// LOCAL_VAR -> LOCAL_VAR +
procedure main;
var
  a, b: object;
begin
  a := object.create;  // rc = 1  
	b := a;              // rc = 2   
proc_epilog
  release(b);          // rc = 1
	release(a);          // rc = 0 - destroy
end;
//////////////////////////////////////////////////
// LOCAL_VAR -> GLOBAL_VAR +
var
  G: object;
procedure main;
var
  a: object;
begin
  a := object.create;  // rc = 1  
	G := a;              // rc = 2   
proc_epilog  
	release(a);          // rc = 1
end;

unit_epilog
  release(G);          // rc = 0 - destroy 
  
//////////////////////////////////////////////////	
// LOCAL_VAR -> CONST_PARAMETER -	
procedure test(const o: object);
begin
...  
end;

procedure main;
var
  a: object;
begin
  a := object.create;    // rc = 1  
	test(a);                
proc_epilog  
	release(a);            // rc = 0
end;

//////////////////////////////////////////////////	
// LOCAL_VAR -> MUT_PARAMETER + (������ ������ ��������� ��� MUT_PARAMETER)	
procedure test(o: object);
proc_prolog
  addref(o);             // rc = 2
begin
...  
proc_epilog     
	release(a);            // rc = 1
end;

procedure main;
var
  a: object;
begin
  a := object.create;    // rc = 1  
	test(a);                 
proc_epilog     
	release(a);            // rc = 0 - destroy
end;

//////////////////////////////////////////////////	
// PARAMETER -> CONST_PARAMETER -
procedure test(const o: object);  
begin
...  
end;

procedure main(o: object); // rc = 1
proc_prolog
  addref(o);                     // rc = 2
begin
  test(o);
proc_epilog     
	release(a);                    // rc = 1
end;

//////////////////////////////////////////////////	
// CONST_PARAMETER -> CONST_PARAMETER -
procedure test(const o: object);  
begin
...  
end;

procedure main(const o: object); // rc = 1
begin
  test(o);
end;

���������� ������ - GR (���������� ����������, ���� ���������/������)
��������� ������ - LR (��������� ����������, �������� ���������)
������� ������ - RC

������ ����� ���������� ���������������� RC:
  - GR -> GR
  - GR -> LR
  - LR -> GR

������ ����� ��� ������������� ���������������� RC:
  - LR -> LR

������� 1.
  ����� ��������� ����������� ������ (������/������/�������� ������) ��� RC = 1
  ��� ����������� ����� � ������������ ��������: RC = -1

������� 2.
  ���� � ��������� ���� �������� ������������ ���� (����������� ��� ��������� �����),
  ������� ����������(�����������������) � ���� ���������, �� � ������� �������� RC + 1
  � � ������� RC - 1;

{=======================================================================}

// ������:


implementation

uses SysUtils;

procedure P2(const str: string);
begin
//  str[1] := 'a';
  if str = 'asdasd' then;
end;

procedure P1;
var
  str, str2: string;
begin
  str := IntToStr(12345); // RC = 1;
  p2(str);
  if str2 = str then;
end;

procedure X2(const obj: IInterface);
begin
  if obj <> nil then;
end;

procedure X1;
var
  obj: IInterface;
begin
  obj := TInterfacedObject.Create;
  X2(obj);
end;


function GetRec: TVarRec;
begin
  Result.VInteger := 1;
  Result.VType := 2;
end;

procedure RECTEST;
var
  Rec: TVarRec;
begin
  Rec := GetRec;
end;

initialization
  X1;
  p1;
  RECTEST;

end.