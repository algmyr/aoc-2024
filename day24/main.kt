data class Command(
  val x: String,
  val op: String,
  val y: String,
  val dest: String,
  val cached: Int = -1,
){
  fun eval(inputs: Map<String, Int>, commands: Map<String, Command>): Int {
    if (cached != -1) return cached
    val xVal = commands.getOrElse(x) {
      Command(x, "VALUE", "", "", inputs[x]!!)
    }.eval(inputs, commands)
    val yVal = commands.getOrElse(y) {
      Command(y, "VALUE", "", "", inputs[y]!!)
    }.eval(inputs, commands)
    return when (op) {
      "AND" -> xVal and yVal
      "OR" -> xVal or yVal
      "XOR" -> xVal xor yVal
      else -> throw Exception("Unknown op: $op")
    }
  }
}

fun main() {
  val lines = generateSequence{readLine()}.toList()
  var outputs = mutableListOf<String>()
  var inputs = HashMap<String, Int>()
  var commands = HashMap<String, Command>()
  for (line in lines) {
    if (line.contains(": ")) {
      val parts = line.split(": ")
      val value = parts[1].toInt()
      inputs[parts[0]] = value
    } else if (line.contains("->")) {
      val parts = line.split(" ")
      val dest = parts[parts.size-1]
      commands[dest] = Command(parts[0], parts[1], parts[2], dest)
      if (dest.startsWith("z")) {
        outputs.add(dest)
      } 
    }
  }

  var res = 0L
  outputs.sort()
  outputs.reversed().map{
    commands[it]!!.eval(inputs, commands)
  }.forEach{
    res = res shl 1 or it.toLong()
  }
  println("Part 1: $res")

  // Manual solution
  var swapped = mutableListOf<String>()
  val swap = {x: String, y: String ->
    swapped.add(x)
    swapped.add(y)
  }
  swap("kth", "z12")
  swap("gsd", "z26")
  swap("tbt", "z32")
  swap("qnf", "vpm")

  swapped.sort()
  println("Part 2: ${swapped.joinToString(",")}")
}
