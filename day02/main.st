OrderedCollection extend [
  check [
    |last inc dec spacing delta|
    last := -1.
    inc := false.
    dec := false.
    spacing := true.
    self do: [ :num |
      last ~= -1 ifTrue: [
        num > last ifTrue: [ inc := true ].
        num < last ifTrue: [ dec := true ].
        
        delta := (num - last) abs.
        (delta < 1) | (delta > 3) ifTrue: [ spacing := false ].
      ].
      last := num.
    ].
    ^(inc ~= dec) & spacing.
  ]

  without: ix [
    |res|
    res := self copy.
    res removeAtIndex: ix.
    ^res.
  ]
]. 

f := FileStream open: '/dev/stdin' mode: FileStream read.

part1 := 0.
part2 := 0.

f linesDo: [ :line |
  nums := line subStrings
    collect: [ :word | word asInteger ].

  nums check ifTrue: [ part1 := part1 + 1 ].

  anyTrue := false.
  1 to: nums size do: [ :i |
    (nums without: i) check ifTrue: [
      anyTrue := true.
    ].
  ].
  anyTrue ifTrue: [ part2 := part2 + 1 ].
].

Transcript show: 'Part 1: ', part1 printString; nl.
Transcript show: 'Part 2: ', part2 printString; nl.
