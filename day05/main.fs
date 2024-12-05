Create banned 100 100 * cells allot
banned 0 100 100 * cells fill

Variable p1
Variable p2
Variable violations

Create buff 1 cells allot
: gc ( -- )
  buff 1 stdin read-file throw
  buff @
  swap
  ;

: read_number ( -- n end)
  0
  begin
    gc
    over
    48 58 within *
  while
    48 - swap 10 * +
  repeat
  ;

: read_pair ( -- n1 n2 err)
  read_number
  \ handle end of pairs
  dup 10 = if
    drop
    0 0
    exit
  endif
  124 <> throw
  read_number
  10 <> throw
  1
  ;

: read_case ( -- n... err)
  read_number
  \ handle end of cases
  10 = if
    drop
    0
    exit
  endif

  \ read rest of numbers
  begin
    read_number
    10 <>
  while
  repeat
  1
  ;

: banned_at ( n1 n2 -- ptr ) 100 * + cells banned + ;

Create arr 100 cells allot
: compute_median
  depth
  dup 0 do
    dup pick swap
  loop
  0 do
    i cells arr + !
  loop

  depth
  dup 0 do
    dup 0 do
      i cells arr + @
      j cells arr + @
      over over
      banned_at @ 1 = if
        swap
      endif
      j cells arr + !
      i cells arr + !
    loop
  loop
  drop

  depth 2 / cells arr + @
  ;

: main ( -- )
  begin
    read_pair
  while
    swap
    banned_at 1 swap !
  repeat
  drop drop

  begin
    read_case
  while
    depth 2 / pick {: middle :}
    compute_median {: median :}

    0 violations !
    
    \ Loop through all pairs.
    depth
    1 do
      \ Duplicate stack
      depth
      dup 0 do
        dup pick swap
      loop

      dup 1 do
        -rot swap over
        \ Count violations.
        banned_at @ 1 = if
          1 violations +!
        endif
        swap
      loop
      drop drop drop
    loop
    drop

    violations @ 0= if
      middle p1 +!
    else
      median p2 +!
    endif
  repeat

  ." Part 1: " p1 @ . cr
  ." Part 2: " p2 @ . cr
  ;

main
