<?php

function f($i, $ax, $ay, $bx, $by, $px, $py) {
  $num1 = $px - $ax*$i;
  $num2 = $py - $ay*$i;

  // Really j * bx * by, the relative magnitude is key.
  // This is what is being binary searched over.
  $j1 = $num1*$by;
  $j2 = $num2*$bx;
  return array($j1 - $j2, intdiv($j1, $by*$bx));
}

function solve1($ax, $ay, $bx, $by, $px, $py) {
  $l = 0;
  $ref = f($l, $ax, $ay, $bx, $by, $px, $py)[0];
  $r = 10**14;
  while ($r - $l > 1) {
    $mid = intdiv($l + $r, 2);
    $res = f($mid, $ax, $ay, $bx, $by, $px, $py);
    if ($res[0] == 0) {
      // Exact. Direction is correct.
      $i = $mid;
      $j = $res[1];
      if ($ax*$i + $bx*$j == $px && $ay*$i + $by*$j == $py) {
        return 3*$mid + $res[1];
      } else {
        // Fun case, exactly correct direction, but step doesn't work out.
        return 0;
      }
    }
    if ($ref*$res[0] < 0) {
      // Different sign, too large.
      $r = $mid;
    } else {
      // Same sign, too small.
      $l = $mid;
    }
  }
  return 0;
}

$content = file_get_contents("php://stdin");
$paragraphs = explode("\n\n", trim($content));
$p1 = 0;
$p2 = 0;
$boost = 10000000000000;
foreach($paragraphs as $p) {
  $lines = explode("\n", $p);
  sscanf($lines[0], "Button A: X+%d, Y+%d", $ax, $ay);
  sscanf($lines[1], "Button B: X+%d, Y+%d", $bx, $by);
  sscanf($lines[2], "Prize: X=%d, Y=%d", $px, $py);
  $p1 += solve1($ax, $ay, $bx, $by, $px, $py);
  $p2 += solve1($ax, $ay, $bx, $by, $boost + $px, $boost + $py);
}
echo "Part 1: $p1\n";
echo "Part 2: $p2\n";
