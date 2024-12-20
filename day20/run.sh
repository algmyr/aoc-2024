echo "Initial approach"
time luajit main.lua < input
echo
echo "Different approach, which allow for more optimization"
time luajit main_opt.lua < input
