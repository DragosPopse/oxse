package main

import "core:fmt"
import "core:strings"
import "core:time"

import xm "runtime/xmath"
import mu "runtime/microui"
import "runtime/app"




main :: proc() {
	window := app.create_window({})
	
	running := true
	for running {
		for event in app.poll_event(window) {
			#partial switch ev in event {
			case app.Quit:
				running = false
				fmt.printf("Application exit at %s\n", time.weekday(ev.timestamp))
			case app.Resize:
				fmt.printf("Prev Size: %v\n", ev.prev_size)
				fmt.printf("Curr Size: %v\n", ev.curr_size)
			}
		}
	}
}