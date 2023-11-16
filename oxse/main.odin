package main

import "core:fmt"
import "core:strings"

import xm "runtime/xmath"
import mu "runtime/microui"
import dev "runtime/device"




main :: proc() {
	instance := dev.win32_get_current_instance()
	main_wnd_class := dev.L("Main Window")
	dev.win32_register_class(instance, main_wnd_class)
	window := dev.win32_create_window(instance, main_wnd_class, dev.L("Welcome to OXSE"))
	dev.win32_show_window(window)
	
	for !dev.should_quit {
		dev.win32_poll_messages()
	}
}