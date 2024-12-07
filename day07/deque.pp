type
  TDeque = class
  private
    data: array of int64;
    front: integer;
    back: integer;
  public
    constructor Create;
    procedure PushFront(const x: int64);
    procedure PushBack(const x: int64);
    function PopFront: int64;
    function PopBack: int64;
    function Count: integer;
    function IndexOf(const x: int64): integer;
    procedure Clear;
  end;

Const  
  DequeMaxSize = 2*131072;  { 2^18 }

constructor TDeque.Create;
begin
  SetLength(data, DequeMaxSize);
  front := 0;
  back := 0;
end;

procedure TDeque.PushFront(const x: int64);
begin
  front := (front - 1 + DequeMaxSize) mod DequeMaxSize;
  data[front] := x;
end;

procedure TDeque.PushBack(const x: int64);
begin
  data[back] := x;
  back := (back + 1) mod DequeMaxSize;
end;

function TDeque.PopFront: int64;
begin
  PopFront := data[front];
  front := (front + 1) mod DequeMaxSize;
end;

function TDeque.PopBack: int64;
begin
  back := (back - 1 + DequeMaxSize) mod DequeMaxSize;
  PopBack := data[back];
end;

function TDeque.Count: integer;
begin
  Count := (back - front + DequeMaxSize) mod DequeMaxSize;
end;

procedure TDeque.Clear;
begin
  front := 0;
  back := 0;
end;

function TDeque.IndexOf(const x: int64): integer;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    if data[(front + i) mod DequeMaxSize] = x then begin
      IndexOf := i;
      exit;
    end;
  IndexOf := -1;
end;
