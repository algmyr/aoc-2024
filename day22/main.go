package main

import "fmt"

func rnd(x uint32) uint32 {
  x = x ^ x << 6 & 0xffffff
  x = x ^ x >> 5 & 0xffffff
  x = x ^ x << 11 & 0xffffff
  return x
}

func readInts() []uint32 {
  var ints []uint32
  for {
    var x uint32
    _, err := fmt.Scan(&x)
    if err != nil {
      break
    }
    ints = append(ints, x)
  }
  return ints
}

func main() {
  ints := readInts()
  p1 := uint64(0)
  scores := [0xfffff]uint64{}
  used := [0xfffff]bool{}
  for _, start := range ints {
    seq := make([]uint32, 2000)
    x := start
    for i := 0; i < 2000; i++ {
      x = rnd(x)
      seq[i] = x
    }

    p1 += uint64(seq[1999])
    rs := uint32(0xfffff)
    last := uint32(start)
    for _, x := range seq {
      r := 10 + x%10 - last%10
      rs = (rs << 5 & 0xfffff) | r
      last = x
      if rs>>19 == 0 {
        if !used[rs] {
          scores[rs] += uint64(x%10)
          used[rs] = true
        }
      }
    }

    // Clear used.
    last = uint32(start)
    for _, x := range seq {
      r := 10 + x%10 - last%10
      rs = (rs << 5 & 0xfffff) | r
      last = x
      used[rs] = false
    }
  }

  p2 := uint64(0)
  for _, v := range scores {
    if v > p2 {
      p2 = v
    }
  }
  fmt.Println("Part 1:", p1)
  fmt.Println("Part 2:", p2)
}
