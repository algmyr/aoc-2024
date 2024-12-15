my ($map, $cmds) = '/dev/stdin'.IO.slurp.trim.split("\n\n");
$cmds ~~ s:g/\n//;

# Split the lines into arrays of characters, making them mutable
my @char_grid = $map.lines.map({ .trim.comb });

my $px = -1;
my $py = -1;
my $id = 0;

my @grid = [];
for @char_grid.kv -> $i, @row {
  my @new_row = [];
  for @row.kv -> $j, $c {
    if $c eq 'O' {
      @new_row.push(++$id);
    } elsif $c eq '#' {
      @new_row.push(-1);
    } elsif $c eq '@' {
      @new_row.push(0);
      $px = $j;
      $py = $i;
    } else {
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
  # Box.
  return can_move($x + $dx, $y + $dy, $dx, $dy);
}

sub do_move($x, $y, $dx, $dy) {
  my $neigh = @grid[$y + $dy][$x + $dx];
  my $me = @grid[$y][$x];
  if $neigh != 0 {
    do_move($x + $dx, $y + $dy, $dx, $dy);
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

my $p1 = 0;
for @grid.kv -> $i, $row {
  for $row.kv -> $j, $c {
    if $c > 0 {
      $p1 += 100*$i + $j;
    }
  }
}
"Part 1: $p1".say;
