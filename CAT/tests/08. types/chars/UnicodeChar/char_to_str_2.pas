unit char_to_str_2;

interface

implementation

var C: Char = '�';
    S: string;

procedure Test;
begin
  S := C;  
end;

initialization
  Test();

finalization
  Assert(S = C);
end.