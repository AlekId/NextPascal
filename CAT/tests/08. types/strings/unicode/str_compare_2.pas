unit str_compare_2;

interface

implementation

var S1, S2: string;
    B: Boolean;

procedure Test;
begin
  S1 := 'aaa';
  S2 := 'AAA';
  B := S1 < S2;  
end;

initialization
  Test();

finalization
  Assert(B = True);
end.