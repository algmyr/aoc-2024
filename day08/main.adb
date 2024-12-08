with Ada.Containers; use Ada.Containers;
with Ada.Containers.Vectors;
with Ada.Text_IO; use Ada.Text_IO;

procedure Main is
  type Point is record
    x : Integer;
    y : Integer;
  end record;

  package Point_Vectors is new
    Ada.Containers.Vectors
      (Index_Type   => Natural,
       Element_Type => Point);

  type Index is range 1 .. 64;
  type BoolGrid is array(Index, Index) of Boolean;
  type PointBuckets is array(1..75) of Point_Vectors.Vector;

  width : Integer;
  height : Integer;
  
  function ReadInput return PointBuckets is
    c : Integer;
    s : String(1 .. 64) := (others => ' ');
    buckets : PointBuckets := (others => Point_Vectors.Empty_Vector);
  begin
    while not End_Of_File loop
      height := height + 1;
      Get_Line(s, width);
      for i in 1..width loop
        c := Character'Pos(s(i));
        if s(i) /= '.' then
          buckets(c - 47).Append((i, height), 1);
        end if;
      end loop;
    end loop;
    return buckets;
  end ReadInput;

  procedure Set_At(grid : in out BoolGrid; x : Integer; y : Integer) is
  begin
    if x in 1..width and y in 1..height then
      grid(Index(x), Index(y)) := True;
    end if;
  end Set_At;
  
  function Sum(grid : BoolGrid) return Integer is
    sum : Integer := 0;
  begin
    for i in Index loop
      for j in Index loop
        if grid(j, i) then
          sum := sum + 1;
        end if;
      end loop;
    end loop;
    return sum;
  end Sum;

  type Setter_Access is access procedure(grid: in out BoolGrid; x: Integer; y: Integer; dx: Integer; dy: Integer);

  function Solve(buckets : PointBuckets; setter: Setter_Access) return Integer is
    dx : Integer;
    dy : Integer;
    grid : BoolGrid := (others => (others => False));
  begin
    for bucket of buckets loop
      if not bucket.Is_Empty then
        for i in 0..Natural(bucket.Length)-1 loop
          for j in i+1..Natural(bucket.Length)-1 loop
            dx := bucket(j).x - bucket(i).x;
            dy := bucket(j).y - bucket(i).y;
            setter(grid, bucket(i).x, bucket(i).y, dx, dy);
          end loop;
        end loop;
      end if;
    end loop;

    return Sum(grid);
  end Solve;

  procedure Part1_Setter(grid : in out BoolGrid; x: Integer; y: Integer; dx: Integer; dy: Integer) is
  begin
    Set_At(grid, x + 2*dx, y + 2*dy);
    Set_At(grid, x - dx, y - dy);
  end Part1_Setter;

  function Part1(buckets: PointBuckets) return Integer is
  begin
    return Solve(buckets, Part1_Setter'Access);
  end Part1;

  procedure Part2_Setter(grid : in out BoolGrid; x: Integer; y: Integer; dx: Integer; dy: Integer) is
  begin
    for k in -100..100 loop
      Set_At(grid, x + k*dx, y + k*dy);
    end loop;
  end Part2_Setter;

  function Part2(buckets: PointBuckets) return Integer is
  begin
    return Solve(buckets, Part2_Setter'Access);
  end Part2;

  buckets: PointBuckets;
begin
  buckets := ReadInput;
  Put_Line("Part 1: " & Integer'Image(Part1(buckets)));
  Put_Line("Part 2: " & Integer'Image(Part2(buckets)));
end Main;
