my ($map, $cmds) = '/dev/stdin'.IO.slurp.trim.split("\n\n");
$cmds ~~ s:g/\n//;

# Split the lines into arrays of characters, making them mutable
my @char_grid = $map.lines.map({ .trim.comb });

my $px = -1;
my $py = -1;
my $id = 0;
my $offset = 1000;

my @grid = [];
for @char_grid.kv -> $i, @row {
  my @new_row = [];
  for @row.kv -> $j, $c {
    if $c eq 'O' {
      @new_row.push(++$id);
      @new_row.push($id + $offset);
    } elsif $c eq '#' {
      @new_row.push(-1);
      @new_row.push(-1);
    } elsif $c eq '@' {
      @new_row.push(0);
      @new_row.push(0);
      $px = 2*$j;
      $py = $i;
    } else {
      @new_row.push(0);
      @new_row.push(0);
    }
  }
  @grid.push(@new_row);
}

sub can_move($x, $y, $dx, $dy) {
  my $neigh = @grid[$y + $dy][$x + $dx];
  if $neigh == -1 {
    # Wall.
    return False;
  }
  if $neigh == 0 {
    # Empty space.
    return True;
  }
  if $dy == 0 {
    return can_move($x + $dx, $y + $dy, $dx, $dy);
  } elsif $neigh >= $offset {
    # Right side of box.
    return can_move($x + $dx, $y + $dy, $dx, $dy) &&
           can_move($x + $dx - 1, $y + $dy, $dx, $dy);
  } else {
    # Left side of box.
    return can_move($x + $dx, $y + $dy, $dx, $dy) &&
           can_move($x + $dx + 1, $y + $dy, $dx, $dy);
  }
}

sub do_move($x, $y, $dx, $dy) {
  my $neigh = @grid[$y + $dy][$x + $dx];
  my $me = @grid[$y][$x];
  if $neigh != 0 {
    if $dy == 0 {
      do_move($x + $dx, $y + $dy, $dx, $dy);
    } elsif $neigh >= $offset {
      # Right side of box.
      do_move($x + $dx, $y + $dy, $dx, $dy);
      do_move($x + $dx - 1, $y + $dy, $dx, $dy);
    } else {
      # Left side of box.
      do_move($x + $dx, $y + $dy, $dx, $dy);
      do_move($x + $dx + 1, $y + $dy, $dx, $dy);
    }
  }
  @grid[$y + $dy][$x + $dx] = $me;
  @grid[$y][$x] = 0;
}

my @dirs = $cmds.comb.map({
  when $_ eq 'v' { [0, 1] }
  when $_ eq '^' { [0, -1] }
  when $_ eq '<' { [-1, 0] }
  when $_ eq '>' { [1, 0] }
});

for @dirs -> $cmd {
  my ($dx, $dy) = $cmd;
  if can_move($px, $py, $dx, $dy) {
    do_move($px, $py, $dx, $dy);
    $px += $dx;
    $py += $dy;
  }
}

my $p2 = 0;
for @grid.kv -> $i, $row {
  for $row.kv -> $j, $c {
    if $c > 0 && $c < $offset {
      $p2 += 100*$i + $j;
    }
  }
}
"Part 2: $p2".say;
