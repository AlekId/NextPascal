unit range_type_1;

interface

type
  T = 0..7;
  
var
  G: T;
  
implementation

procedure Test;
begin
  G := 1;    // ��� �������� �� ������
end;

initialization
  Test();

finalization
  Assert(G = 1); 

end.