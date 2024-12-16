import std/heapqueue
import std/sets
import std/strutils
import std/syncio
import std/tables

const inf = 1000000

type Point = tuple[x, y: int]
proc `+` (a, b: Point): Point = (a.x + b.x, a.y + b.y)
proc `-` (a, b: Point): Point = (a.x - b.x, a.y - b.y)
proc rot(p: Point): Point = (p.y, -p.x)
proc tor(p: Point): Point = (-p.y, p.x)

type Grid = tuple[width, height: int, data: seq[string]]
proc at(grid: Grid, p: Point): char = grid.data[p.y][p.x]

proc readGrid(): Grid =
  let content = stdin.readAll()
  let lines = content.strip().splitLines()
  let width = lines[0].len
  let height = lines.len
  return (width, height, lines)

let grid = readGrid()

let start: Point = (1, grid.height - 2)
let target: Point = (grid.width - 2, 1)

assert grid.at(start) == 'S'
assert grid.at(target) == 'E'

var heap = [(0, start, (1, 0))].toHeapQueue
var best = Table[(Point, Point), int]()
while heap.len > 0:
  let (dist, cur, dir) = heap.pop()
  if dist >= best.getOrDefault((cur, dir), inf):
    continue
  best[(cur, dir)] = dist
  if cur == target:
    echo "Part 1: ", dist
    break

  let next = cur + dir
  if grid.at(next) != '#':
    heap.push((dist + 1, next, dir))
  for d in [dir.rot, dir.tor]:
    let next = cur + d
    if grid.at(next) != '#':
      heap.push((dist + 1000, cur, d))

var stack: seq[(Point, Point)] = @[]
for d in [(1, 0), (0, 1), (-1, 0), (0, -1)]:
  if best.contains((target, d)):
    stack.add((target, d))

var on_path = HashSet[Point]()
while stack.len > 0:
  let (cur, dir) = stack.pop()
  on_path.incl(cur)
  let dist = best[(cur, dir)]
  if best.getOrDefault((cur - dir, dir), inf) == dist - 1:
    stack.add((cur - dir, dir))
  if best.getOrDefault((cur, dir.rot), inf) == dist - 1000:
    stack.add((cur, dir.rot))
  if best.getOrDefault((cur, dir.tor), inf) == dist - 1000:
    stack.add((cur, dir.tor))

echo "Part 2: ", on_path.len
