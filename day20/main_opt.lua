local function read_grid_from_stdin()
  -- Read all.
  local grid = {}
  local i = 0
  local goal = {x = -1, y = -1}
  for line in io.lines() do
    i = i + 1
    local row = {}
    for j = 1, #line do
      row[j] = string.sub(line, j, j)
      if row[j] == "E" then
        goal = {x = j, y = i}
      end
    end
    grid[#grid + 1] = row
  end

  local grid_table = {
    grid = grid,
    height = #grid,
    width = #grid[1],
  }

  return goal, grid_table
end

function Push(q, v)
  q.data[q.tail + 1] = v
  q.tail = (q.tail + 1) % q.max_size
end

function Pop(q)
  local v = q.data[q.head + 1]
  q.head = (q.head + 1) % q.max_size
  return v
end

function Empty(q)
  return q.head == q.tail
end

function At(grid, p)
  return grid.grid[p.y][p.x]
end

function Key(p)
  return p.x .. "," .. p.y
end

local q = {
  data = {},
  max_size = 512,
  head = 0,
  tail = 0,
}

local goal, grid = read_grid_from_stdin()

local points = {}

local dist_to_goal = {}
dist_to_goal[Key(goal)] = 0
Push(q, {dist=1, pos=goal})
points[1] = goal

while not Empty(q) do
  local cur = Pop(q)

  for _, diff in ipairs({{1, 0}, {-1, 0}, {0, 1}, {0, -1}}) do
    local nx = cur.pos.x + diff[1]
    local ny = cur.pos.y + diff[2]
    local d = dist_to_goal[Key{x=nx, y=ny}]
    local new_dist = cur.dist + 1
    if d == nil and At(grid, {x=nx, y=ny}) ~= "#" then
      Push(q, {dist=new_dist, pos={x=nx, y=ny}})
      points[new_dist] = {x=nx, y=ny}
      dist_to_goal[Key{x=nx, y=ny}] = new_dist
    end
  end
end

function Solve(limit, search_limit)
  local res = 0
  for i = 1, #points do
    local p = points[i]
    local j = 1
    while j < i - limit do
      local q = points[j]
      local cost = math.abs(p.x - q.x) + math.abs(p.y - q.y)
      local out = cost - search_limit
      if out <= 0 and i - j >= limit + cost then
        res = res + 1
      end
      j = j + math.max(1, out)
    end
  end
  return res
end

local limit = 100
print("Part 1:", Solve(limit, 2))
print("Part 2:", Solve(limit, 20))
