local function read_grid_from_stdin()
  -- Read all.
  local grid = {}
  local i = 0
  local start = {x = -1, y = -1}
  local goal = {x = -1, y = -1}
  for line in io.lines() do
    i = i + 1
    local row = {}
    for j = 1, #line do
      row[j] = string.sub(line, j, j)
      if row[j] == "S" then
        start = {x = j, y = i}
      elseif row[j] == "E" then
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

  return start, goal, grid_table
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

local start, goal, grid = read_grid_from_stdin()

local dist_to_goal = {}
dist_to_goal[Key(goal)] = 0
Push(q, {dist=0, pos=goal})

while not Empty(q) do
  local cur = Pop(q)

  for _, diff in ipairs({{1, 0}, {-1, 0}, {0, 1}, {0, -1}}) do
    local nx = cur.pos.x + diff[1]
    local ny = cur.pos.y + diff[2]
    local d = dist_to_goal[Key{x=nx, y=ny}]
    local new_dist = cur.dist + 1
    if d == nil and At(grid, {x=nx, y=ny}) ~= "#" then
      Push(q, {dist=new_dist, pos={x=nx, y=ny}})
      dist_to_goal[Key{x=nx, y=ny}] = new_dist
    end
  end
end

function Solve(limit, search_limit)
  local function cheat(x, dx, y, dy)
    local cost = math.abs(dx) + math.abs(dy)
    local nx = x + dx
    local ny = y + dy
    if nx >= 1 and nx <= grid.width and ny >= 1 and ny <= grid.height then
      local dist = dist_to_goal[Key{x=x, y=y}] or -1
      local ndist = dist_to_goal[Key{x=nx, y=ny}] or 99999
      if dist - ndist >= limit + cost then
        return 1
      end
    end
    return 0
  end

  local function expand(x, y, rad)
    if At(grid, {x=x, y=y}) == "#" then
      return 0
    end
    local res = 0
    for r = 1, rad do
      for t = 0, r-1 do
        res = res + cheat(x, t, y, -r + t)
        res = res + cheat(x, r-t, y, t)
        res = res + cheat(x, -t, y, r - t)
        res = res + cheat(x, -r + t, y, -t)
      end
    end
    return res
  end

  local res = 0
  for y = 1, grid.height do
    for x = 1, grid.width do
      res = res + expand(x, y, search_limit)
    end
  end
  return res
end

local limit = 100
print("Part 1:", Solve(limit, 2))
print("Part 2:", Solve(limit, 20))
