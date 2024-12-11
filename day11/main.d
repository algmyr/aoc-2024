import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.string;

int ndigits(long n) {
  int count = 1;
  while (n > 9) {
    n /= 10;
    count++;
  }
  return count;
}

long[] f(long n) {
  if (n == 0)
    return [1];
  int d = ndigits(n);

  if (d%2 == 1)
    return [2024*n];
  long x = 10^^(d/2);
  return [n/x, n%x];
}

void main(string[] args) {
  long[] numbers = readln().splitter.map!(a => a.to!long).array;

  long[long] counts;
  foreach (x; numbers) {
    counts[x] = 1;
  }

  foreach (i; 1..76) {
    long[long] new_counts;
    foreach (x, c; counts)
      foreach (y; f(x))
        new_counts[y] += c;
    counts = new_counts;
    if (i == 25)
      writefln("Part 1: %s", counts.values.sum());
  }
  writefln("Part 2: %s", counts.values.sum());
}
