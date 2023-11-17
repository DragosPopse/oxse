package main

import "core:fmt"
import "core:strings"
import "core:time"

import xm "runtime/xmath"
import mu "runtime/microui"
import dev "runtime/device"




main :: proc() {
	window := dev.create_window({})
	
	running := true
	for running {
		for event in dev.poll_event(window) {
			#partial switch ev in event {
			case dev.Quit:
				running = false
				fmt.printf("Application exit at %s\n", time.weekday(ev.timestamp))
			case dev.Resize:
				fmt.printf("Prev Size: %v\n", ev.prev_size)
				fmt.printf("Curr Size: %v\n", ev.curr_size)
			}
		}
	}
}