#skip
unit using_2;

interface

implementation

uses System;

// const ������������ ref 

type
  TArray<T> = record
  private
    FData: array of T;
  public
    procedure Add(const Value: T);
    function GetItem(Index:  Integer): T;   
  end; 

// ���������� ������� � not null ����������: 

// 1 - var A: array of !TObject;
// 1 - var A: array of TObject not nil;
// � ������, ���� ������ �������� ����� �������, �� 
// ��������� SetLength �� ���������, ��������� ������
// ��������� �������� �� ������ ��� ������� ����� 
// ��������� AppendNN(Array, Item)
// ����� ��������� ����� ������ SetCapacity(Array, ItemCount) 


procedure TArray.Add(const Value: TObject);
begin
  // AppendNN(FData, Value);
end;

function TArray.GetItem(Index: Integer): TObject;
begin
  
  using FData[Index] Val do
    Result := Val
  else 
    Assert(False);
    
           
 // Result := ExtractNN(FData, Index);    
end;    

var 
  A: array of TObject;


procedure Test;
begin

end;

initialization
  Test();

finalization

end.