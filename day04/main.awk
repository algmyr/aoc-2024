function rot(cell) {
  for (i=1;i<=rows/2;i++) {
    for (j=1;j<=cols/2;j++) {
      tmp = cell[i,j]
      cell[i,j] = cell[rows-j+1,i]
      cell[rows-j+1,i] = cell[rows-i+1,cols-j+1]
      cell[rows-i+1,cols-j+1] = cell[j,cols-i+1]
      cell[j,cols-i+1] = tmp
    }
  }
}

function search(cell, count) {
  # Search a packed string rather than search loads of strings, just for fun.
  line = ""
  # Rows.
  for (i=1;i<=rows;i++) {
    for (j=1;j<=cols;j++)
      line = line cell[i,j]
    line = line "$"
  }
  # Diagonals.
  for (i=-rows+1;i<rows;i++) {
    for (j=1; j<=cols; j++)
      line = line cell[i+j,j]
    line = line "$"
  }
  return gsub("XMAS", "", line)
}

BEGIN {
  FS = ""
}
{
  for (i=1;i<=NF;i++)
    cell[NR,i] = $i
  cols = NF > cols ? NF : cols
  rows = NR
}
END {
  p1 += search(cell)
  rot(cell)
  p1 += search(cell)
  rot(cell)
  p1 += search(cell)
  rot(cell)
  p1 += search(cell)
  print "Part 1:", p1

  for (i=2;i<rows;i++) {
    for (j=2;j<cols;j++) {
      d1 = cell[i-1,j-1] cell[i,j] cell[i+1,j+1]
      d2 = cell[i-1,j+1] cell[i,j] cell[i+1,j-1]
      if ((d1 == "MAS" || d1 == "SAM") && (d2 == "MAS" || d2 == "SAM"))
        p2 += 1
    }
  }
  print "Part 2:", p2
}
