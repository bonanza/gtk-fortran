! Copyright (C) 2011
! Free Software Foundation, Inc.

! This file is part of the gtk-fortran GTK+ Fortran Interface library.

! This is free software; you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation; either version 3, or (at your option)
! any later version.

! This software is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.

! Under Section 7 of GPL version 3, you are granted additional
! permissions described in the GCC Runtime Library Exception, version
! 3.1, as published by the Free Software Foundation.

! You should have received a copy of the GNU General Public License along with
! this program; see the files COPYING3 and COPYING.RUNTIME respectively.
! If not, see <http://www.gnu.org/licenses/>.
!
! Contributed by Vincent Magnin, Jerry DeLisle and Tobias Burnus, 01-23-2011
! Last modification: 02-09-2011

module gtk
  use iso_c_binding
  implicit none
  include "gtkenums-auto.f90"

  interface
    !**************************************************************************
    ! You can add your own additional interfaces here:
    !**************************************************************************
    subroutine g_signal_connect_data (instance, detailed_signal,&
                & c_handler, gobject, dummy) bind(c)
      use iso_c_binding, only: c_ptr, c_char, c_funptr
      character(c_char)     :: detailed_signal(*)
      type(c_ptr), value    :: instance, gobject, dummy
      type(c_funptr), value :: c_handler      
    end subroutine

    subroutine gtk_init_real(argc,argv) bind(c,name='gtk_init')
      use iso_c_binding, only: c_int, c_ptr
      integer(c_int) :: argc
      type(c_ptr)    :: argv
    end subroutine 
  
    !**************************************************************************
    ! The interfaces automatically generated by cfwrapper.py are included here.
    ! Do not modify.
    include "gtk-auto.f90"
    !**************************************************************************
  end interface 

  ! cairo_format (not yet automatically generated):
  integer(c_int), parameter :: CAIRO_FORMAT_INVALID   = -1
  integer(c_int), parameter :: CAIRO_FORMAT_ARGB32    = 0
  integer(c_int), parameter :: CAIRO_FORMAT_RGB24     = 1
  integer(c_int), parameter :: CAIRO_FORMAT_A8        = 2
  integer(c_int), parameter :: CAIRO_FORMAT_A1        = 3
  integer(c_int), parameter :: CAIRO_FORMAT_RGB16_565 = 4
  
  integer(c_int), parameter :: CAIRO_FONT_SLANT_NORMAL = 0
  integer(c_int), parameter :: CAIRO_FONT_SLANT_ITALIC = 1
  integer(c_int), parameter :: CAIRO_FONT_SLANT_OBLIQUE= 2

  integer(c_int), parameter :: CAIRO_FONT_WEIGHT_NORMAL = 0
  integer(c_int), parameter :: CAIRO_FONT_WEIGHT_BOLD   = 1

  ! Some useful parameters to ease coding:
  character(c_char), parameter :: CNULL = c_null_char
  type(c_ptr), parameter       :: NULL = c_null_ptr
  logical(c_bool), parameter   :: TRUE = .true.
  logical(c_bool), parameter   :: FALSE = .false.

contains
  subroutine g_signal_connect (instance, detailed_signal, c_handler)
      use iso_c_binding, only: c_ptr, c_char, c_funptr
      character(c_char):: detailed_signal(*)
      type(c_ptr)      :: instance
      type(c_funptr)   :: c_handler
      
      call g_signal_connect_data (instance, detailed_signal, c_handler, NULL, NULL)    
  end subroutine

  subroutine gtk_init()
    use iso_c_binding, only: c_ptr, c_char, c_int, c_null_char, c_loc

    character(len=256,kind=c_char) :: arg
    character(len=1,kind=c_char), dimension(:),pointer :: carg
    type(c_ptr), allocatable, target :: argv(:)
    integer(c_int) :: argc, strlen, i, j

    argc = command_argument_count()
    allocate(argv(0:argc))

    do i = 0, argc
      call get_command_argument (i,arg,strlen)
      allocate(carg(0:strlen))
      do j = 0, strlen-1
        carg(j) = arg(j+1:j+1)
      end do
      carg(strlen) = c_null_char
      argv(i) = c_loc (carg(0))
    end do

    argc = argc + 1
    call gtk_init_real (argc, c_loc(argv))
    !deallocate(argv)
    !deallocate(carg)
  end subroutine gtk_init

end module gtk

