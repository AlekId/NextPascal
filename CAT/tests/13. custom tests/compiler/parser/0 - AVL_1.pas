unit AVL_1;

interface

uses System;

type                              

  TAVLTree<TKey, TData> = class(TObject)
  public
  type
    TAVLNode = record
    private
      FChilds: array[Boolean] of ^TAVLNode; {Child nodes}
      FBalance: Integer;         {Used during balancing}
    public
      Key: TKey;
      Data: TData;
    end;
    PAVLNode = ^TAVLNode;    
    TIterateFunc = function(Node: PAVLNode; OtherData: Pointer): Boolean of object;
    TCompareFunc = function(const NodeKey1, NodeKey2: TKey): NativeInt;
  private
  const
    StackSize = 40;
    Left = False;
    Right = True;
  type
    TStackNode = record
      Node : PAVLNode;
      Comparison : Integer;
    end;
    TStackArray = array[1..StackSize] of TStackNode;
  private
    FCount: Int32;
    FRoot: PAVLNode; {Root of tree}
    FCompareFunc: TCompareFunc;
    class procedure InsBalance(var P: PAVLNode; var SubTreeInc: Boolean; CmpRes: Integer); static;
    class procedure DelBalance(var P: PAVLNode; var SubTreeDec: Boolean; CmpRes: Integer); static;
    function FreeNode(Node: PAVLNode; OtherData : Pointer): Boolean; inline;
  protected
    class function DoCreateNode(const Key: TKey; const  Data: TData): PAVLNode; virtual;
    class procedure DoFreeNode(var Key: TKey; var Data: TData); virtual;
  public
    constructor Create(const CompareFunc: TCompareFunc);
    destructor Destroy; override;
    ///////////////////////////////////////////////////////////////////////////////////////////////
    procedure Clear;
    procedure Delete(const Key: TKey);
    function InsertNode(const Key: TKey; const Data: TData): PAVLNode;
    function Find(const Key: TKey): PAVLNode;
    function Iterate(Action: TIterateFunc; Up: Boolean; OtherData: Pointer): PAVLNode;
    function First: PAVLNode; inline;
    function Last: PAVLNode; inline;
    function Next(N: PAVLNode): PAVLNode;
    function Prev(N: PAVLNode): PAVLNode;
    property Count: Integer read FCount;
    property Root: PAVLNode read FRoot;
  end;


implementation

function Sign(I: Integer): Integer; 
begin
  if I < 0 then
    Result := -1
  else if I > 0 then
    Result := +1
  else
    Result := 0;
end;

constructor TAVLTree<TKey, TData>.Create(const CompareFunc: TCompareFunc);
begin
  FCompareFunc := CompareFunc;
end;

class procedure TAVLTree<TKey, TData>.DelBalance(var P: PAVLNode; var SubTreeDec: Boolean; CmpRes: Integer);
var
  P1, P2 : PAVLNode;
  B1, B2 : Integer;
  LR : Boolean;
begin
  CmpRes := Sign(CmpRes);
  if P.FBalance = CmpRes then
    P.FBalance := 0
  else if P.FBalance = 0 then begin
    P.FBalance := -CmpRes;
    SubTreeDec := False;
  end else begin
    LR := (CmpRes < 0);
    P1 := P.FChilds[LR];
    B1 := P1.FBalance;
    if (B1 = 0) or (B1 = -CmpRes) then begin

      P.FChilds[LR] := P1.FChilds[not LR];
      P1.FChilds[not LR] := P;
      if B1 = 0 then begin
        P.FBalance := -CmpRes;
        P1.FBalance := CmpRes;
        SubTreeDec := False;
      end else begin
        P.FBalance := 0;
        P1.FBalance := 0;
      end;
      P := P1;
    end else begin

      P2 := P1.FChilds[not LR];
      B2 := P2.FBalance;
      P1.FChilds[not LR] := P2.FChilds[LR];
      P2.FChilds[LR] := P1;
      P.FChilds[LR] := P2.FChilds[not LR];
      P2.FChilds[not LR] := P;
      if B2 = -CmpRes then
        P.FBalance := CmpRes
      else
        P.FBalance := 0;
      if B2 = CmpRes then
        P1.FBalance := -CmpRes
      else
        P1.FBalance := 0;
      P := P2;
      P2.FBalance := 0;
    end;
  end;
end;

class procedure TAVLTree<TKey, TData>.InsBalance(var P: PAVLNode; var SubTreeInc: Boolean; CmpRes: Integer);
var
  P1 : PAVLNode;
  P2 : PAVLNode;
  LR : Boolean;
begin
  CmpRes := Sign(CmpRes);
  if P.FBalance = -CmpRes then begin
    P.FBalance := 0;
    SubTreeInc := False;
  end else if P.FBalance = 0 then
    P.FBalance := CmpRes
  else begin
    LR := (CmpRes > 0);
    P1 := P.FChilds[LR];
    if P1.FBalance = CmpRes then begin
      P.FChilds[LR] := P1.FChilds[not LR];
      P1.FChilds[not LR] := P;
      P.FBalance := 0;
      P := P1;
    end else begin
      P2 := P1.FChilds[not LR];
      P1.FChilds[not LR] := P2.FChilds[LR];
      P2.FChilds[LR] := P1;
      P.FChilds[LR] := P2.FChilds[not LR];
      P2.FChilds[not LR] := P;
      if P2.FBalance = CmpRes then
        P.FBalance := -CmpRes
      else
        P.FBalance := 0;
      if P2.FBalance = -CmpRes then
        P1.FBalance := CmpRes
      else
        P1.FBalance := 0;
      P := P2;
    end;
    P.FBalance := 0;
    SubTreeInc := False;
  end;
end;

procedure TAVLTree<TKey, TData>.Clear;
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try       
{$ENDIF}
    Iterate(FreeNode, True, nil);
    FRoot := nil;
    FCount := 0;
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;

procedure TAVLTree<TKey, TData>.Delete(const Key: TKey);
var
  P : PAVLNode;
  Q : PAVLNode;
  TmpData : TData;
  CmpRes : Integer;
  Found : Boolean;
  SubTreeDec : Boolean;
  StackP : Integer;
  Stack : TStackArray;
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try
{$ENDIF}
    P := FRoot;
    if not Assigned(P) then
      Exit;

    Found := False;
    StackP := 0;
    while not Found do begin
      CmpRes := FCompareFunc(P.Key, Key);
      Inc(StackP);
      if CmpRes = 0 then begin
        with Stack[StackP] do begin
          Node := P;
          Comparison := -1;
        end;
        Found := True;
      end else begin
        with Stack[StackP] do begin
          Node := P;
          Comparison := CmpRes;
        end;
        P := P.FChilds[CmpRes > 0];
        if not Assigned(P) then
          Exit;
      end;
    end;
    
    Q := P;
    if (not Assigned(Q.FChilds[Right])) or (not Assigned(Q.FChilds[Left])) then begin
      Dec(StackP);
      P := Q.FChilds[Assigned(Q.FChilds[Right])];
      if StackP = 0 then
        FRoot := P
      else with Stack[StackP] do
        Node.FChilds[Comparison > 0] := P;
    end else begin
      P := Q.FChilds[Left];
      while Assigned(P.FChilds[Right]) do begin
        Inc(StackP);
        with Stack[StackP] do begin
          Node := P;
          Comparison := 1;
        end;
        P := P.FChilds[Right];
      end;                   

 
      TmpData := Q.Data;
      Q.Data := P.Data;
      Q := P;
      
      with Stack[StackP] do begin
        Node.FChilds[Comparison > 0].Data := TmpData;
        Node.FChilds[Comparison > 0] := P.FChilds[Left];
      end;
    end;         
                    
    FreeNode(Q, nil);
    Dec(FCount);

    SubTreeDec := True;
    while (StackP > 0) and SubTreeDec do begin
      if StackP = 1 then
        DelBalance(FRoot, SubTreeDec, Stack[1].Comparison)
      else with Stack[StackP-1] do
        DelBalance(Node.FChilds[Comparison > 0], SubTreeDec, Stack[StackP].Comparison);
      dec(StackP);
    end;            
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;

destructor TAVLTree<TKey, TData>.Destroy;
begin
  Clear();
  inherited;
end;

class function TAVLTree<TKey, TData>.DoCreateNode(const Key: TKey; const Data: TData): PAVLNode;
begin
  New(Result);
  //FillChar(Result^, SizeOf(TAVLNode), #0);
  Result.Key := Key;
  Result.Data := Data;
end;

class procedure TAVLTree<TKey, TData>.DoFreeNode(var Key: TKey; var Data: TData);
begin

end;

function TAVLTree<TKey, TData>.Find(const Key: TKey): PAVLNode;
var
  P: PAVLNode;
  CmpRes: Integer;
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try
{$ENDIF}
    P := FRoot;
    while Assigned(P) do begin
      CmpRes := FCompareFunc(P.Key, Key);
      if CmpRes = 0 then begin
        Result := P;
        Exit;
      end else
        P := P.FChilds[CmpRes > 0];
    end;
    Result := nil;
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;

function TAVLTree<TKey, TData>.First: PAVLNode;
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try
{$ENDIF}
    if Count = 0 then
      Result := nil
    else begin
      Result := FRoot;
      while Assigned(Result.FChilds[Left]) do
        Result := Result.FChilds[Left];
    end;
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;

function TAVLTree<TKey, TData>.FreeNode(Node: PAVLNode; OtherData: Pointer): Boolean;
begin
  DoFreeNode(Node.Key, Node.Data);
  Free(Node);
  Result := True;
end;

function TAVLTree<TKey, TData>.Iterate(Action: TIterateFunc; Up: Boolean; OtherData: Pointer): PAVLNode;
var
  P : PAVLNode;
  Q : PAVLNode;
  StackP : Integer;
  Stack : TStackArray;
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try
{$ENDIF}
    StackP := 0;
    P := FRoot;
    repeat
      while Assigned(P) do begin
        Inc(StackP);
        Stack[StackP].Node := P;
        P := P.FChilds[not Up];
      end;
      if StackP = 0 then begin
        Result := nil;
        Exit;
      end;

      P := Stack[StackP].Node;
      Dec(StackP);
      Q := P;
      P := P.FChilds[Up];
      if not Action(Q, OtherData) then begin
        Result := Q;
        Exit;
      end;
    until False;
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;

function TAVLTree<TKey, TData>.Last: PAVLNode;
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try
{$ENDIF}
    if Count = 0 then
      Result := nil
    else begin
      Result := FRoot;
      while Assigned(Result.FChilds[Right]) do
        Result := Result.FChilds[Right];
    end;
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;

function TAVLTree<TKey, TData>.Next(N: PAVLNode) : PAVLNode;
var
  Found : Integer;
  P : PAVLNode;
  StackP : Integer;
  Stack : TStackArray;
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try
{$ENDIF}
    Result := nil;
    Found := 0;
    StackP := 0;
    P := FRoot;
    repeat
      while Assigned(P) do begin
        Inc(StackP);
        Stack[StackP].Node := P;
        P := P.FChilds[Left];
      end;
      if StackP = 0 then
        Exit;

      P := Stack[StackP].Node;
      Dec(StackP);
      if Found = 1 then begin
        Result := P;
        Exit;
      end;
      if P = N then
        Inc(Found);
      P := P.FChilds[Right];
    until False;
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;

function TAVLTree<TKey, TData>.Prev(N: PAVLNode): PAVLNode;
var
  Found : Integer;
  P : PAVLNode;
  StackP : Integer;
  Stack : TStackArray;
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try
{$ENDIF}
    Result := nil;
    Found := 0;
    StackP := 0;
    P := FRoot;
    repeat
      while Assigned(P) do begin
        Inc(StackP);
        Stack[StackP].Node := P;
        P := P.FChilds[Right];
      end;
      if StackP = 0 then
        Exit;

      P := Stack[StackP].Node;
      Dec(StackP);
      if Found = 1 then begin
        Result := P;
        Exit;
      end;
      if P = N then
        Inc(Found);
      P := P.FChilds[Left];
    until False;
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;

function TAVLTree<TKey, TData>.InsertNode(const Key: TKey; const Data: TData): PAVLNode;
var
  P : PAVLNode;
  CmpRes : Integer;
  StackP : Integer;
  Stack : TStackArray;
  SubTreeInc : Boolean;
begin
  Result := nil;
  
  P := FRoot;
  if not Assigned(P) then begin
    FRoot := DoCreateNode(Key, Data);
    Inc(FCount);
    Exit;
  end;

  StackP := 0;
  CmpRes := 0;
  while Assigned(P) do begin
    CmpRes := FCompareFunc(P.Key, Key);
    if CmpRes = 0 then
      Exit(P);
    Inc(StackP);           
    with Stack[StackP] do begin
      Node := P;
      Comparison := CmpRes;
    end;
    P := P.FChilds[CmpRes > 0];
  end;

  Stack[StackP].Node.FChilds[CmpRes > 0] := DoCreateNode(Key, Data);
  Inc(FCount);

  SubTreeInc := True;
  while (StackP > 0) and SubTreeInc do begin
    if StackP = 1 then
      InsBalance(FRoot, SubTreeInc, Stack[1].Comparison)
    else with Stack[StackP-1] do
      InsBalance(Node.FChilds[Comparison > 0], SubTreeInc, Stack[StackP].Comparison);
    dec(StackP);
  end;
end;

type
  TTree = TAVLTree<Int32, Int32>; 

var
  Tree: TTree;
  GC, V: Int32;
   

function CMP(V1, V2: Int32): NativeInt;
begin
  Result := V1 - V2;
end;

procedure Test;
var
  Node: TTree.PAVLNode;
begin
  Tree := TTree.Create(CMP);
  Tree.InsertNode(1, 10);
  Tree.InsertNode(2, 20);
  Tree.InsertNode(3, 30);
  GC := Tree.Count;
  Node := Tree.Find(1);
  if Assigned(Node) then
    V := Node.Data;
end;

initialization
  Test();

finalization
  Assert(GC = 3);
  Assert(V = 10);  

end.