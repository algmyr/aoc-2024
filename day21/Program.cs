namespace AoC {
  class Solver {
    static IEnumerable<String> MakeDirs(int dx, int dy, String x, String y) {
      if (dx == 0 && dy == 0) {
        yield return "";
      }
      if (dx > 0) {
        foreach (var suffix in MakeDirs(dx - 1, dy, x, y)) {
          yield return x + suffix;
        }
      }
      if (dy > 0) {
        foreach (var suffix in MakeDirs(dx, dy - 1, x, y)) {
          yield return y + suffix;
        }
      }
    }

    static IEnumerable<String> Dirs(int dx, int dy) {
      String x = dx > 0 ? ">" : "<";
      String y = dy > 0 ? "^" : "v";
      return MakeDirs(Math.Abs(dx), Math.Abs(dy), x, y);
    }

    public long TypeKeypad(String input, int indirections) {
      // 789
      // 456
      // 123
      //  0A
      var cx = 2;
      var cy = 0;
      long res = 0;
      foreach (var c in input) {
        int x, y;
        if ("789".Contains(c)) y = 3;
        else if ("456".Contains(c)) y = 2;
        else if ("123".Contains(c)) y = 1;
        else y = 0;
        if ("147".Contains(c)) x = 0;
        else if ("0258".Contains(c)) x = 1;
        else x = 2;

        String banned = "None";
        if (cx == 0 && y == 0)
          banned = new String('v', cy - y) + new String('>', x - cx);
        if (cy == 0 && x == 0)
          banned = new String('<', cx - x) + new String('^', y - cy);

        long mini = long.MaxValue;
        foreach (var move in Dirs(x - cx, y - cy)) {
          if (move != banned) {
            var sub = TypeArrows(move + "A", indirections);
            if (sub < mini) {
              mini = sub;
            }
          }  
        }
        res += mini;
        cx = x;
        cy = y;
      }
      return res;
    }

    Dictionary<Tuple<String, int>, long> memo = new Dictionary<Tuple<String, int>, long>();

    public long TypeArrowsImpl(String input, int indirections) {
      if (indirections == 0) {
        return input.Count();
      }
      //  ^A
      // <v>
      var cx = 2;
      var cy = 1;
      long res = 0;
      foreach (var c in input) {
        int x, y;
        if ("^A".Contains(c)) y = 1;
        else y = 0;
        if ("<".Contains(c)) x = 0;
        else if ("v^".Contains(c)) x = 1;
        else x = 2;

        String banned = "None";
        if (cx == 0 && y == 1)
          banned = new String('^', y - cy) + new String('>', x - cx);
        if (cy == 1 && x == 0)
          banned = new String('<', cx - x) + new String('v', cy - y);

        long mini = long.MaxValue;
        foreach (var move in Dirs(x - cx, y - cy)) {
          if (move != banned) {
            var sub = TypeArrows(move + "A", indirections - 1);
            if (sub < mini) {
              mini = sub;
            }
          }  
        }
        res += mini;
        cx = x;
        cy = y;
      }
      return res;
    }

    public long TypeArrows(String input, int indirections) {
      var key = new Tuple<String, int>(input, indirections);
      if (!memo.ContainsKey(key)) {
        memo[key] = TypeArrowsImpl(input, indirections);
      }
      return memo[key];
    }
  }

  class Program {
    static void Main(string[] args) {
      var watch = System.Diagnostics.Stopwatch.StartNew();

      var s = new Solver();
      long p1 = 0;
      long p2 = 0;
      while (true) {
        var line = Console.ReadLine();
        if (line == "" || line == null) {
          break;
        }
        var num = int.Parse(line.Replace("A", ""));
        p1 += s.TypeKeypad(line, 2)*num;
        p2 += s.TypeKeypad(line, 25)*num;
      }
      Console.WriteLine($"Part 1: {p1}");
      Console.WriteLine($"Part 2: {p2}");

      watch.Stop();
      var elapsed = watch.Elapsed;
      Console.WriteLine($"Elapsed: {elapsed.Microseconds/1000.0} ms");
    }
  }
}
