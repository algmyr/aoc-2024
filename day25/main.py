import string
import sys

s = sys.stdin.read(100000)
chunks = string.splitfields(s, '\n\n')

def blocksize(s, c):
  res = []
  lines = string.split(s)
  for j in range(len(lines[0])):
    count = 0
    for i in range(len(lines)):
      if lines[i][j] = c:
        count = count + 1
    res.append(count - 1)
  return res

def zip(a, b):
  res = []
  for i in range(len(a)):
    res.append((a[i], b[i]))
  return res

keys = []
locks = []
for chunk in chunks:
  if chunk[0] = '#':
    locks.append(blocksize(chunk, '#'))
  else:
    keys.append(blocksize(chunk, '#'))

res = 0
for key in keys:
  for lock in locks:
    ok = 1
    for k, l in zip(key, lock):
      if k + l > 5:
        ok = 0
    res = res + ok

print 'Part 1:', res
