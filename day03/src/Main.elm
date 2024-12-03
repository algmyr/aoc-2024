module Main exposing (..)

import Html exposing (text)

input = """
...
"""

skipImpl t s acc =
  case (t, s) of
    ([], _) -> (acc, Ok s)
    (x::xs, y::ys) -> if x == y then skipImpl xs ys acc else (acc, Err ys)
    _ -> (acc, Err s)

skip t s acc =
  skipImpl (String.toList t) s acc

keepImpl pred s =
  case s of
    x::xs ->
      if pred x then
        let (match, rest) = keepImpl pred xs in
          (x::match, rest)
      else
        ([], Ok s)
    _ -> ([], Ok s)

keep pred s acc =
  case keepImpl pred s of
    (match, Ok rest) -> (match::acc, Ok rest)
    _ -> (acc, Err s)

parse spec s acc =
  case spec of
    x::xs ->
      case x s acc of
        (res, Ok rest) -> parse xs rest res
        (res, Err rest) -> (res, Err rest)
    _ -> (acc, Ok s)

tonum s = String.fromList s |> String.toInt |> Maybe.withDefault 0
prod nums = List.map tonum nums |> List.product

expr = [skip "mul(", keep Char.isDigit, skip ",", keep Char.isDigit, skip ")"]
part1 s =
  case s of
    [] -> 0
    _ -> case parse expr s [] of
      (res, Ok rest) -> (part1 rest) + prod res
      (res, Err rest) -> (part1 rest)

part2 s =
  let dos = String.split "do()" s in
      List.map (\x -> String.split "don't()" x |> List.head |> Maybe.withDefault "" |> String.toList |> part1) dos |> List.sum

main =
  (part1 (String.toList input), part2 input) |> Debug.toString |> text
