// vim: set filetype=v:

import os

const w := 101
const h := 103

struct Pair {
  x i64
  y i64
}

struct Robot {
  p Pair
  v Pair
}

fn mod(a i64, m i64) i64 {
  return (a % m + m) % m
}

fn (r Robot) at(t i64) Pair {
  return Pair{mod(r.p.x + t * r.v.x, w), mod(r.p.y + t * r.v.y, h)}
}

fn parse_pair(s string) ?Pair {
  sx, sy := s.after("=").split_once(",")?
  x := sx.parse_int(10, 64) or { return ?Pair{} }
  y := sy.parse_int(10, 64) or { return ?Pair{} }
  return Pair{x, y}
}

fn parse_line(s string) ?Robot {
  p, v := s.split_once(" ")?
  return Robot{parse_pair(p)?, parse_pair(v)?}
}
    
fn quadrant(p Pair) int {
  if p.y < h/2 {
    if p.x < w/2 { return 1 }
    if p.x > w/2 { return 2 }
    return 0
  } 
  if p.y > h/2 {
    if p.x < w/2 { return 3 }
    if p.x > w/2 { return 4 }
    return 0
  }
  return 0
}

fn main() {
  lines := os.read_lines('/dev/stdin')!
  mut quadrant_counts := [0, 0, 0, 0, 0]
  mut robots := []Robot{cap: lines.len}
  for line in lines {
    robots << parse_line(line)?
  }
  for robot in robots {
    quadrant_counts[quadrant(robot.at(100))] += 1
  }
  mut res := 1
  for i in 1..quadrant_counts.len {
    res *= quadrant_counts[i]
  }
  println("Part 1: ${res}")

  mut canvas := []bool{len: w*h, init: false}
  for t in 1..1000000 {
    mut overlap := false
    for r in robots {
      p := r.at(t)
      if canvas[p.y*w + p.x] {
        overlap = true
        break
      }
      canvas[p.y*w + p.x] = true
    }

    if !overlap {
      for y in 0..h {
        for x in 0..w {
          if canvas[y*w + x] { print("#") } else { print(".") }
        }
        println("")
      }
      println("Part 2: ${t}")
      break
    }

    for r in robots {
      p := r.at(t)
      canvas[p.y*w + p.x] = false
    }
  }
}
