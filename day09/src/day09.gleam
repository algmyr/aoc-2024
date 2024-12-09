import gleam/erlang
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

type Block =
  #(Int, Int)

type Blocks =
  List(Block)

fn flatten_blocks(blocks: Blocks) -> List(Int) {
  blocks |> list.map(fn(x) { list.repeat(x.0, x.1) }) |> list.flatten
}

fn checksum(memory: List(Int)) -> Int {
  memory
  |> list.index_fold(0, fn(acc, x, i) {
    case x {
      -1 -> acc
      _ -> acc + x * i
    }
  })
}

fn compact_impl(
  target_len: Int,
  memory: List(Int),
  values: List(Int),
  result: List(Int),
) -> List(Int) {
  case target_len, memory, values {
    0, _, _ -> result
    _, [-1, ..memory], [v, ..values] ->
      compact_impl(target_len - 1, memory, values, [v, ..result])
    _, [m, ..memory], values ->
      compact_impl(target_len - 1, memory, values, [m, ..result])
    _, [], _ -> result
  }
}

fn compact(memory: List(Int), values: List(Int)) -> List(Int) {
  compact_impl(list.length(values), memory, values, [])
}

fn part1(blocks: Blocks) -> Int {
  let memory = flatten_blocks(blocks)
  let values = list.filter(memory, fn(x) { x != -1 }) |> list.reverse()
  let result = compact(memory, values) |> list.reverse() |> checksum
  result
}

fn insert_file_finalize(blocks: Blocks, file: Block, result: Blocks) {
  let #(value, size) = file
  case blocks {
    [#(v, _) as b, ..rest] -> {
      case v {
        -1 ->
          case v == value {
            True -> list.flatten([list.reverse(rest), [#(-1, size)], result])
            False -> insert_file_finalize(rest, file, [b, ..result])
          }
        _ if v == value ->
          list.flatten([list.reverse(rest), [#(-1, size)], result])
        _ -> insert_file_finalize(rest, file, [b, ..result])
      }
    }
    [] -> result
  }
}

fn insert_file(blocks: Blocks, file: Block, result: Blocks) -> Blocks {
  let #(value, size) = file
  case blocks {
    [#(v, sz) as b, ..rest] -> {
      let left = sz - size
      case v, left >= 0 {
        -1, True -> {
          case result {
            [#(rv, rsz), ..result] if rv == -1 -> {
              insert_file_finalize(rest, file, [
                #(-1, left + rsz),
                file,
                ..result
              ])
            }
            [r, ..result] -> {
              insert_file_finalize(rest, file, [#(-1, left), file, r, ..result])
            }
            [] ->
              insert_file_finalize(rest, file, [#(-1, left), file, ..result])
          }
        }
        -1, False -> insert_file(rest, file, [b, ..result])
        _, _ if v == value -> list.flatten([list.reverse(blocks), result])
        _, _ -> insert_file(rest, file, [b, ..result])
      }
    }
    [] -> result
  }
}

fn part2(blocks: Blocks) -> Int {
  let files =
    blocks
    |> list.index_fold([], fn(acc, x, i) {
      case i % 2 {
        0 -> [x, ..acc]
        _ -> acc
      }
    })

  files
  |> list.fold(blocks, fn(blocks, f) {
    insert_file(blocks, f, []) |> list.reverse()
  })
  |> flatten_blocks
  |> checksum
}

pub fn main() {
  case erlang.get_line("") {
    Ok(s) -> {
      let digits =
        s
        |> string.trim_end
        |> string.to_graphemes
        |> list.map(int.parse)
        |> result.all
        |> result.unwrap([])
      let blocks =
        digits
        |> list.index_map(fn(x, i) {
          case i % 2 {
            0 -> #(i / 2, x)
            _ -> #(-1, x)
          }
        })
      io.println("Part 1: " <> int.to_string(part1(blocks)))
      io.println("Part 2: " <> int.to_string(part2(blocks)))
      Nil
    }
    Error(_e) -> io.println("Error: #{e}")
  }
}
