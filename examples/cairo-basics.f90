! Copyright (C) 2011
! Free Software Foundation, Inc.

! This file is part of the gtk-fortran gtk+ Fortran Interface library.

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
! gfortran -g ../src/gtk.f90 cairo-basics.f90 `pkg-config --cflags --libs gtk+-2.0`
! Contributed by Jerry DeLisle and Vincent Magnin

module handlers
  use gtk
  implicit none

  integer(c_int) :: run_status = TRUE
  integer(c_int) :: boolresult
  logical :: boolevent
  integer :: width, height
  
contains
  ! User defined event handlers go here
  function delete_event (widget, event, gdata) result(ret)  bind(c)
    use iso_c_binding, only: c_ptr, c_int
    integer(c_int)    :: ret
    type(c_ptr), value :: widget, event, gdata
    run_status = FALSE
    ret = FALSE
  end function delete_event

  subroutine pending_events ()
    do while(IAND(gtk_events_pending(), run_status) /= FALSE)
      boolresult = gtk_main_iteration_do(FALSE) ! False for non-blocking
    end do
  end subroutine pending_events

  function expose_event (widget, event, gdata) result(ret)  bind(c)
    use iso_c_binding
    use gtk
    implicit none
    real(8), parameter :: pi = 4*atan(1d0)
    integer(c_int)    :: ret
    type(c_ptr), value, intent(in) :: widget, event, gdata
    type(c_ptr) :: my_cairo_context
    integer :: cstatus
    integer :: t
    
    my_cairo_context = gdk_cairo_create (gtk_widget_get_window(widget))
    
    ! Bezier curve:
    call cairo_set_source_rgb(my_cairo_context, 0.9d0, 0.8d0, 0.8d0)
    call cairo_set_line_width(my_cairo_context, 4d0)
    call cairo_move_to(my_cairo_context, 0d0, 0d0)  
    call cairo_curve_to(my_cairo_context, 600d0, 50d0, 115d0, 545d0, width*1d0, height*1d0)
    call cairo_stroke(my_cairo_context) 

    ! Lines:
    call cairo_set_source_rgb(my_cairo_context, 0d0, 0.5d0, 0.5d0)
    call cairo_set_line_width(my_cairo_context, 2d0)
    do t = 0, int(height), +20
      call cairo_move_to(my_cairo_context, 0d0, t*1d0)  
      call cairo_line_to(my_cairo_context, t*1d0, height*1d0)
      call cairo_stroke(my_cairo_context) 
    end do
  
    ! Text:
    call cairo_set_source_rgb(my_cairo_context, 0d0, 0d0, 1d0)
    call cairo_select_font_face(my_cairo_context, "Times"//CNULL, CAIRO_FONT_SLANT_NORMAL, &
                                 &  CAIRO_FONT_WEIGHT_NORMAL)
    call cairo_set_font_size (my_cairo_context, 40d0)
    call cairo_move_to(my_cairo_context, 100d0, 30d0)
    call cairo_show_text (my_cairo_context, "gtk-fortran"//CNULL)
    call cairo_move_to(my_cairo_context, 100d0, 75d0)
    call cairo_show_text (my_cairo_context, "Cairo & Fortran are good friends"//CNULL)

    ! Circles:
    call cairo_new_sub_path(my_cairo_context)
    do t = 1, 50
        call cairo_set_source_rgb(my_cairo_context, t/50d0, 0d0, 0d0)
        call cairo_set_line_width(my_cairo_context, 5d0*t/50d0)
        call cairo_arc(my_cairo_context, 353d0+200d0*cos(t*2d0*pi/50), 350d0+200d0*sin(t*2d0*pi/50), 50d0, 0d0, 2*pi) 
        call cairo_stroke(my_cairo_context) 
    end do
    
    ! Save:
    cstatus = cairo_surface_write_to_png(cairo_get_target(my_cairo_context), "cairo.png"//CNULL)
    
    call cairo_destroy(my_cairo_context)
    ret = FALSE
  end function expose_event
end module handlers


program cairo_basics
  use iso_c_binding
  use gtk
  use handlers
  implicit none
  type(c_ptr) :: my_window
  type(c_ptr) :: my_drawing_area
  
  call gtk_init ()
  
  ! Properties of the main window :
  width = 700
  height = 700
  my_window = gtk_window_new (GTK_WINDOW_TOPLEVEL)
  call gtk_window_set_default_size(my_window, width, height)
  call gtk_window_set_title(my_window, "Cairo basics demo"//CNULL)
  call g_signal_connect (my_window, "delete-event"//CNULL, c_funloc(delete_event))
      
  my_drawing_area = gtk_drawing_area_new()
  call g_signal_connect (my_drawing_area, "expose-event"//CNULL, c_funloc(expose_event))
  call gtk_container_add(my_window, my_drawing_area)
  call gtk_widget_show (my_drawing_area)

  call gtk_widget_show (my_window)
        
  ! The window stays opened after the computation:
  do
    call pending_events()
    if (run_status == FALSE) exit
    call sleep(1) ! So we don't burn CPU cycles
  end do
  print *, "All done"

end program cairo_basics 
