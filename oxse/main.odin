package main

import "core:fmt"
import "core:strings"
import "core:time"

import xm "runtime/xmath"
import mu "runtime/microui"
import "runtime/app"


main :: proc() {
	app_info: app.Init
	app_info.title = "Hello OXSE Engine"
	app.init(app_info)
	for app.update() {
		for event in app.poll_event() {
			#partial switch ev in event {
			case app.Quit: 
				app.quit()
			}
		}
	}
}