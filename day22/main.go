package main

import "fmt"

func rnd(x int) int {
  x = x ^ x << 6 & 0xffffff
  x = x ^ x >> 5 & 0xffffff
  x = x ^ x << 11 & 0xffffff
  return x
}

func readInts() []int {
  var ints []int
  for {
    var x int
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
  p1 := 0
  for _, x := range ints {
    for i := 0; i < 2000; i++ {
      x = rnd(x)
    }
    p1 += x
  }
  fmt.Println("Part 1:", p1)

  scores := make(map[[4]int]int)

  for _, x := range ints {
    new_scores := make(map[[4]int]int)
    r2 := -999
    r1 := -999
    r0 := -999
    for i := 0; i < 2000; i++ {
      new_x := rnd(x)
      r := new_x%10 - x%10
      x = new_x
      if r2 != -999 {
        if _, ok := new_scores[[4]int{r2, r1, r0, r}]; !ok {
          new_scores[[4]int{r2, r1, r0, r}] = x%10
        }
      }
      r2 = r1
      r1 = r0
      r0 = r
    }

    for k, v := range new_scores {
      scores[k] += v
    }
  }

  best := 0
  for _, v := range scores {
    best = max(best, v)
  }
  fmt.Println("Part 2:", best)
}
