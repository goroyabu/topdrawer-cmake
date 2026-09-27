program helper_probe
  implicit none
  character(16) :: mode
  character(8) :: clock_text
  character(9) :: date_text
  real :: reltim, started, elapsed
  external reltim
  call get_command_argument(1, mode)
  select case(trim(mode))
  case ('datetime')
    call tdtime(clock_text)
    call date(date_text)
    if (clock_text(3:3) /= ':' .or. clock_text(6:6) /= ':') stop 2
    if (verify(clock_text(1:2)//clock_text(4:5)//clock_text(7:8), '0123456789') /= 0) stop 3
    if (date_text(3:3) /= '-' .or. date_text(7:7) /= '-') stop 4
    if (verify(date_text(1:2)//date_text(8:9), ' 0123456789') /= 0) stop 5
    if (index('JanFebMarAprMayJunJulAugSepOctNovDec', date_text(4:6)) == 0) stop 6
    started = reltim(0.0)
    call t2_wait(1.0)
    elapsed = reltim(started)
    if (elapsed < 1.0 .or. elapsed > 10.0) stop 7
    print *, 'DATETIME_OK'
  case ('short')
    call short_date
    stop 8
  case ('long')
    call long_date
    stop 9
  case default
    stop 10
  end select
end program

subroutine short_date
  character(8) :: fdate, result
  external fdate
  result = fdate()
  print *, 'UNEXPECTED_RETURN', result
end subroutine

subroutine long_date
  character(32) :: fdate, result
  external fdate
  result = fdate()
  print *, 'UNEXPECTED_RETURN', result
end subroutine
