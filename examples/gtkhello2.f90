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
! gfortran -g gtkhello2.f90 `pkg-config --cflags --libs gtk+-2.0`
! Jerry DeLisle , Tobias Burnus, and Vincent Magnin

module handlers
  use gtk
  implicit none

contains
  ! User defined event handlers go here
  function delete_event (widget, event, gdata) result(ret)  bind(c)
    use iso_c_binding, only: c_ptr, c_int, c_bool
    logical(c_bool)    :: ret
    type(c_ptr), value :: widget, event, gdata
    print *, "my delete_event"
    ret = FALSE
  end function delete_event

  subroutine destroy (widget, gdata) bind(c)
    use iso_c_binding, only: c_ptr
    type(c_ptr), value :: widget, gdata
    print *, "my destroy"
    call gtk_main_quit ()
  end subroutine destroy

  function hello (widget, event, gdata ) result(ret)  bind(c)
    use iso_c_binding, only: c_ptr, c_int, c_bool
    logical(c_bool)    :: ret
    type(c_ptr), value :: widget, event, gdata
    print *, "Hello World!"
    ret = .false.
  end function hello

  function button1clicked (widget, event, gdata ) result(ret)  bind(c)
    use iso_c_binding, only: c_ptr, c_int, c_bool
    logical(c_bool)    :: ret
    type(c_ptr), value :: widget, event, gdata
    print *, "Button 1 clicked!"
    ret = .false.
  end function button1clicked

  function button2clicked (widget, event, gdata ) result(ret)  bind(c)
    use iso_c_binding, only: c_ptr, c_int, c_bool
    logical(c_bool)    :: ret
    type(c_ptr), value :: widget, event, gdata
    print *, "Button 2 clicked!"
    ret = .false.
  end function button2clicked
end module handlers

program gtkFortran
  use iso_c_binding !, only: c_ptr, c_null_ptr, c_loc
  use gtk
  use handlers
  implicit none
  
  type(c_ptr) :: window
  type(c_ptr) :: box1
  type(c_ptr) :: button1, button2, button3
  
  call gtk_init ()
  
  ! Create the window and set up some signals for it.
  window = gtk_window_new (GTK_WINDOW_TOPLEVEL)
  !call gtk_window_set_default_size(window, 500, 500)
  call gtk_window_set_title(window, "My title"//CNULL)
  call gtk_container_set_border_width (window, 10)
  call g_signal_connect (window, "delete-event"//CNULL, c_funloc(delete_event))
  call g_signal_connect (window, "destroy"//CNULL, c_funloc(destroy))

  box1 = gtk_hbox_new (TRUE, 10);
  call gtk_container_add (window, box1)

  button1 = gtk_button_new_with_label ("Button1"//CNULL)
  call gtk_box_pack_start (box1, button1, FALSE, FALSE, 0)
  call g_signal_connect (button1, "clicked"//CNULL, c_funloc(button1clicked))
  call gtk_widget_show (button1)

  button2 = gtk_button_new_with_label ("Button2"//CNULL)
  call gtk_box_pack_start (box1, button2, FALSE, FALSE, 0)
  call g_signal_connect (button2, "clicked"//CNULL, c_funloc(button2clicked))
  call gtk_widget_show (button2)

  button3 = gtk_button_new_with_label ("Exit"//CNULL)
  call gtk_box_pack_start (box1, button3, FALSE, FALSE, 0)
  call g_signal_connect (button3, "clicked"//CNULL, c_funloc(destroy))
  call g_signal_connect (button3, "clicked"//CNULL, c_funloc(hello))
  call gtk_widget_show (button3)

  call gtk_widget_show (box1)
  call gtk_widget_show (window)
  
  call gtk_main ()
 
end program gtkFortran