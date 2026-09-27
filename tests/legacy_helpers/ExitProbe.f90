program exit_probe
  implicit none
  integer :: status
  character(16) :: arg
  external exit
  call get_command_argument(1, arg)
  read(arg, *) status
  open(unit=77, file='exit-output.txt', status='replace')
  write(77, '(A)') 'output before exit'
  call exit(status)
  stop 99
end program
