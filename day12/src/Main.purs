module Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)

import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile)
import Data.String as S
import Data.String.CodeUnits (toCharArray)
import Data.Array (head, length, (!!), filter, foldr, (..), fromFoldable)
import Data.Maybe (fromMaybe)
import Data.Foldable (sum, any, and)
import Data.Set as Set
import Data.List as List
import Data.List ((:))

type Grid = Array (Array Char)

type Point =
  { x :: Int
  , y :: Int
  }

pt :: Int -> Int -> Point
pt x y = {x: x, y: y}

up :: Point -> Point
up p = {x: p.x, y: p.y - 1}
down :: Point -> Point
down p = {x: p.x, y: p.y + 1}
left :: Point -> Point
left p = {x: p.x - 1, y: p.y}
right :: Point -> Point
right p = {x: p.x + 1, y: p.y}


readGrid :: String -> Grid
readGrid s = toCharArray <$> S.split (S.Pattern "\n") s

getAt :: Grid -> Point -> Char
getAt a p = fromMaybe '?' $ (\row -> row !! p.x) =<< (a !! p.y)

height :: Grid -> Int
height = length

width :: Grid -> Int
width a = fromMaybe 0 $ length <$> head a

neighbors :: Grid -> Point -> Array Point
neighbors grid cur = filter (\p -> (getAt grid p == c)) cands
  where
    cands = [up cur, down cur, left cur, right cur]
    c = getAt grid cur

find_component :: Grid -> Point -> Set.Set Point -> Set.Set Point
find_component grid cur visited = 
    if Set.member cur visited
    then visited
    else
      foldr (\p vis -> find_component grid p vis) (Set.insert cur visited) neighs
  where
    neighs = neighbors grid cur

area :: Set.Set Point -> Int
area = Set.size

asInt :: Boolean -> Int
asInt true = 1
asInt false = 0

non_perimeter :: Set.Set Point -> Int
non_perimeter comp = sum $ map (\p -> sum $ asInt <$> [
      is_member (up p),
      is_member (down p),
      is_member (left p),
      is_member (right p)
    ]) (fromFoldable comp)
  where
    is_member = flip Set.member comp

perimeter :: Set.Set Point -> Int
perimeter comp = (4 * area comp) - non_perimeter comp

check :: (Point -> Boolean) -> (Point -> Point) -> (Point -> Point) -> Point -> Boolean
check member next across p =
  if and [member (next p), not $ member (across p)]
  then not $ member (next (across p))
  else false

correction :: Set.Set Point -> Int
correction comp = sum $ map (\p -> sum $ asInt <$> [
      check is_member up left p,
      check is_member down right p,
      check is_member left down p,
      check is_member right up p
    ]) (fromFoldable comp)
  where
    is_member = flip Set.member comp

side_count :: Set.Set Point -> Int
side_count comp = (perimeter comp) - (correction comp)

components :: Grid -> List.List (Set.Set Point)
components grid = foldr (\p cs ->
      if any (Set.member p) cs
      then cs
      else (find_component grid p Set.empty):cs
    ) (List.fromFoldable []) coords
  where
    coords = pt <$> (0 .. (m-1)) <*> (0 .. (n-1))
    n = height grid
    m = width grid

f :: String -> String
f s = "Part 1: " <> show part1 <> "\nPart 2: " <> show part2
  where
    part2 = sum $ List.zipWith (*) areas side_counts
    part1 = sum $ List.zipWith (*) areas perimeters
    side_counts = side_count <$> comps
    perimeters = perimeter <$> comps
    areas = area <$> comps
    comps = components grid
    grid = readGrid s

main :: Effect Unit
main = do
  s <- S.trim <$> readTextFile UTF8 "/dev/stdin"
  log $ f s
