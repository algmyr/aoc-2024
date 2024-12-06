readarray grid < sample
n=${#grid[@]}
m=$((${#grid[0]} - 1))

for ((i=0; i<n; i++)); do
  for ((j=0; j<m; j++)); do
    [ "${grid[i]:j:1}" == "^" ] && (( x = j, y = i ))
  done
done

if [ -n "$1" ] && !(( bx == x && by == y )); then
  coords=($(echo "$1" | tr ',' ' '))
  (( bx = coords[0], by = coords[1] ))
else
  (( bx = -1, by = -1 ))
fi

(( dx = 0, dy = -1 ))
function turn_right() {
  (( old_dx = dx, old_dy = dy ))
  (( dx = -old_dy, dy = old_dx ))
}

function obstacle_ahead() {
  (( nx = x + dx ))
  (( ny = y + dy ))
  [ "${grid[$ny]:$nx:1}" == "#" ] || (( nx == bx && ny == by ))
}

limit=70000
points=()
while (( 0 <= x && x < m && 0 <= y && y < n )); do
  points+=("$x,$y")
  (( ${#points[@]} > limit )) && break
  obstacle_ahead && turn_right || (( x += dx, y += dy ))
done

if [ -z "$1" ]; then
  uniq_points=($(echo "${points[@]}" | tr ' ' '\n' | sort -u))
  echo "Part 1: ${#uniq_points[@]}"
  echo -n "Part 2: "
  echo "${uniq_points[@]}" | xargs -P16 -n1 bash run.sh | wc -l
else
  (( ${#points[@]} > limit )) && echo loop
fi
