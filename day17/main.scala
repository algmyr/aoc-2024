def readValue() = io.StdIn.readLine().split(": ").last

type State = (Long, Long, Long, Int)

def step(cmd: Int, arg: Int, state: State) =
  val (a, b, c, pc) = state

  val literal = () => arg
  val combo = () => arg match
    case 0 => 0L
    case 1 => 1L
    case 2 => 2L
    case 3 => 3L
    case 4 => a
    case 5 => b
    case 6 => c
    case _ => throw new Exception("Invalid combo")

  cmd match
    case 0 => (None, (a >> combo(), b, c, pc + 2)) // adv (A <- A >> combo)
    case 1 => (None, (a, b ^ literal(), c, pc + 2)) // bxl (B <- B ^ literal)
    case 2 => (None, (a, combo() % 8, c, pc + 2)) // bst (B <- combo % 8)
    case 3 => (None, (a, b, c, if (a != 0) literal() else pc + 2)) // jnz (if A != 0, jump to literal)
    case 4 => (None, (a, b ^ c, c, pc + 2)) // bxc (B <- B ^ C)
    case 5 => (Some(combo() % 8), (a, b, c, pc + 2)) // out (output combo % 8)
    case 6 => (None, (a, a >> combo(), c, pc + 2)) // bdv (B <- A >> combo)
    case 7 => (None, (a, b, a >> combo(), pc + 2)) // cdv (C <- A >> combo)
    case _ => throw new Exception("Invalid command")

def run(code: List[Int], reg_a: Long, reg_b: Long, reg_c: Long) =
  var output = List[Int]()
  var state = (reg_a, reg_b, reg_c, 0)
  while state(3) < code.length do
    val (a, b, c, pc) = state
    val cmd = code(pc)
    val arg = code(pc + 1)
    step(cmd, arg, state) match
      case (Some(out), next) =>
        output = out.toInt :: output
        state = next
      case (None, next) =>
        state = next
  output

def part2(code: List[Int]) =
  code.foldRight(IndexedSeq(0L))(
    (t, acc) => acc.flatMap(
      a => Range(0, 8).map(a<<3 | _).filter(run(code.init.init, _, 0, 0).head == t)
    )
  ).min

@main def aoc() =
  val reg_a = readValue().toLong
  val reg_b = readValue().toLong
  val reg_c = readValue().toLong
  io.StdIn.readLine()
  val code = readValue().split(",").map(_.toInt).toList

  println(s"Part 1: ${run(code, reg_a, reg_b, reg_c).reverse.mkString(",")}")
  println(s"Part 2: ${part2(code)}")
