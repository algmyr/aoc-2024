program Aoc;

{$mode objfpc} { With 16 bit ints I run out of list size. }

uses FGL;

type IntList = specialize TFPGList<int64>;

{$INCLUDE deque}

procedure ParseCase(s: string; var target: int64; var items: IntList);
var
  res: int64;
  start: integer;
  ix: integer;
begin
  start := 1;
  ix := Pos(':', s);
  Val(s[start..ix-1], target);

  items := IntList.Create;
  start := ix + 2;
  repeat
    ix := Pos(' ', s, start);
    if ix = 0 then
      Val(s[start..Length(s)], res)
    else
      Val(s[start..ix-1], res);
    items.Add(res);
    start := ix + 1;
  until ix = 0;
end;

procedure MaybeAdd(var deque: TDeque; const item: int64; const target: int64);
begin
  if item <= target then deque.PushBack(item);
end;

function Cat(const x, y: int64): int64;
var
  p: int64;
begin
  p := 1;
  repeat p := p * 10 until p > y;
  Cat := x * p + y
end;

function Part1(var deque: TDeque; const target: int64; const items: IntList): int64;
var
  item: int64;
  cur: int64;
  n: integer;
begin
  deque.Clear;

  for item in items do begin
    n := deque.Count;

    if n > 0 then
      while n > 0 do begin
        cur := deque.PopFront;
        MaybeAdd(deque, cur + item, target);
        MaybeAdd(deque, cur * item, target);
        Dec(n);
      end
    else
      deque.PushBack(item);
  end;

  if deque.IndexOf(target) <> -1 then
    Part1 := target
  else
    Part1 := 0
end;

function Part2(var deque: TDeque; const target: int64; const items: IntList): int64;
var
  item: int64;
  cur: int64;
  n: integer;
begin
  deque.Clear;

  for item in items do begin
    n := deque.Count;

    if n > 0 then
      while n > 0 do begin
        cur := deque.PopFront;
        MaybeAdd(deque, cur + item, target);
        MaybeAdd(deque, cur * item, target);
        MaybeAdd(deque, Cat(cur, item), target);
        Dec(n);
      end
    else
      deque.PushBack(item);
  end;

  if deque.IndexOf(target) <> -1 then
    Part2 := target
  else
    Part2 := 0
end;

var
  s: string;
  p1: int64;
  p2: int64;
  target: int64;
  items: IntList;
  deque: TDeque;

begin
  deque := TDeque.Create;
  p1 := 0;
  p2 := 0;
  repeat
    ReadLn(s);
    if Length(s) = 0 then
      break;
    ParseCase(s, target, items);
    p1 := p1 + Part1(deque, target, items);
    p2 := p2 + Part2(deque, target, items);
  until false;
  WriteLn('Part 1: ', p1);
  WriteLn('Part 2: ', p2);
end.
