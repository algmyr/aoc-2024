module queue
  implicit none

  type :: t_queue
    integer, allocatable :: data(:)
    integer :: front
    integer :: back
    integer :: size
    integer :: width
    contains
      procedure :: push
      procedure :: at
      procedure :: pop
      procedure :: qlen
  end type
contains
  subroutine make_queue(self, size, width)
    class(t_queue), intent(inout) :: self
    integer, intent(in) :: size, width
    allocate(self%data(size))
    self%front = 0
    self%back = 0
    self%size = size
    self%width = width
  end subroutine

  subroutine push(self, x, y)
    class(t_queue), intent(inout) :: self
    integer, intent(in) :: x, y
    integer :: value
    value = (y - 1)*self%width + (x - 1)
    self%data(self%back + 1) = value
    self%back = modulo(self%back + 1, self%size)
  end subroutine

  subroutine at(self, idx, x, y)
    class(t_queue), intent(in) :: self
    integer, intent(in) :: idx
    integer, intent(out) :: x, y
    integer :: value
    value = self%data(modulo(self%front + idx - 1, self%size) + 1)
    x = modulo(value, self%width) + 1
    y = value/self%width + 1
  end subroutine

  subroutine pop(self, x, y)
    class(t_queue), intent(inout) :: self
    integer, intent(out) :: x, y

    call at(self, 1, x, y)
    self%front = modulo(self%front + 1, self%size)
  end subroutine

  integer function qlen(self)
    class(t_queue), intent(in) :: self
    qlen = modulo(self%back - self%front, self%size)
  end function
end module

module map
  implicit none

  type :: t_map
    integer :: width
    integer :: height
    character(len=:), allocatable :: data
    contains
      procedure :: get
      procedure :: inside
      procedure :: set
  end type
contains
  subroutine set(self, x, y, value)
    ! Set value at x, y.
    class(t_map), intent(inout) :: self
    integer, intent(in) :: x, y
    character, intent(in) :: value
    integer :: idx

    idx = (y - 1)*(self%width + 1) + x
    self%data(idx:idx) = value
  end subroutine

  integer function get(self, x, y) result(res)
    ! Get value at x, y, or an invalid value if out of bounds.
    class(t_map), intent(in) :: self
    integer, intent(in) :: x, y
    integer :: idx
    if (self%inside(x, y)) then
      idx = (y - 1)*(self%width + 1) + x
      ! Return the ASCII value of the character.
      res = ichar(self%data(idx:idx)) - 48
    else
      res = 99
    endif
  end function

  logical function inside(self, x, y)
    ! Check if x, y is inside the map.
    class(t_map), intent(in) :: self
    integer, intent(in) :: x, y
    inside = 1 <= x .and. x <= self%width .and. 1 <= y .and. y <= self%height
  end function
end module

module my_personal_aoc_hell_revisited
  use map
  use queue;
  implicit none
contains
  subroutine search(dp, board, q)
    implicit none

    type(t_map), intent(in) :: board
    type(t_queue), intent(inout) :: q
    integer, intent(inout) :: dp(board%width, board%height)
    integer :: x, y
    integer :: i, j

    do i = 1, q%qlen()
      call q%at(i, x, y)
      dp(x, y) = 1
    enddo

    do i = 1, 9
      do j = 1, q%qlen()
        call q%pop(x, y)
        
        if (board%get(x+1, y) - board%get(x, y) .eq. 1) then
          if (dp(x+1, y) .eq. 0) then
            call q%push(x+1, y)
          endif
          dp(x+1, y) = dp(x+1, y) + dp(x, y)
        endif
        if (board%get(x-1, y) - board%get(x, y) .eq. 1) then
          if (dp(x-1, y) .eq. 0) then
            call q%push(x-1, y)
          endif
          dp(x-1, y) = dp(x-1, y) + dp(x, y)
        endif
        if (board%get(x, y+1) - board%get(x, y) .eq. 1) then
          if (dp(x, y+1) .eq. 0) then
            call q%push(x, y+1)
          endif
          dp(x, y+1) = dp(x, y+1) + dp(x, y)
        endif
        if (board%get(x, y-1) - board%get(x, y) .eq. 1) then
          if (dp(x, y-1) .eq. 0) then
            call q%push(x, y-1)
          endif
          dp(x, y-1) = dp(x, y-1) + dp(x, y)
        endif
        dp(x, y) = 0
      enddo
    enddo
  end subroutine

  subroutine part1(board)
    implicit none
    type(t_map), intent(in) :: board
    integer x, y
    integer :: i
    integer :: p1
    type(t_queue) :: q
    integer :: dp(board%width, board%height)
    integer :: xx, yy

    call make_queue(q, board%width*board%height, board%width)
    dp(:,:) = 0

    p1 = 0
    do y = 1, board%height
      do x = 1, board%width
        if (board%get(x, y) == 0) then
          call q%push(x, y)
          call search(dp, board, q)
          do i = 1, q%qlen()
            call q%pop(xx, yy)
            if (dp(xx, yy) .gt. 0) then
              p1 = p1 + 1
            endif
            dp(xx, yy) = 0
          enddo
        endif
      enddo
    enddo
      
    print '(A, I4)', "Part 1: ", p1
  end subroutine

  subroutine part2(board)
    implicit none
    type(t_map), intent(in) :: board
    integer x, y
    integer :: i
    integer :: p2
    type(t_queue) :: q
    integer :: dp(board%width, board%height)
    integer :: xx, yy

    call make_queue(q, board%width*board%height, board%width)
    dp(:,:) = 0

    p2 = 0
    do y = 1, board%height
      do x = 1, board%width
        if (board%get(x, y) == 0) then
          call q%push(x, y)
        endif
      enddo
    enddo

    call search(dp, board, q)
    do i = 1, q%qlen()
      call q%pop(xx, yy)
      p2 = p2 + dp(xx, yy)
      dp(xx, yy) = 0
    enddo
      
    print '(A, I4)', "Part 2: ", p2
  end subroutine
end module

program aoc
  use my_personal_aoc_hell_revisited
  implicit none
  real, dimension(2) :: tarray
  real :: result

  character(ishft(1, 12)) :: map_data
  character(ishft(1, 8)) :: buffer
  character(len=:), allocatable :: line
  integer :: width, height
  type(t_map) :: board

  map_data = ''
  height = 0
  do while (.true.)
    read (*, '(A)', end=99) buffer
    line = trim(buffer)
    height = height + 1
    width = len(line)
    map_data = trim(map_data) // line // char(10)
  enddo
  99 continue

  board%width = width
  board%height = height
  board%data = map_data

  call part1(board)
  call part2(board)

  call ETIME(tarray, result)
  print "(F6.3, A)", 1000*result, " ms"
end program
