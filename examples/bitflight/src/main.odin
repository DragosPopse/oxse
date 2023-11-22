
package main

import "core:fmt"
import "oxse:runtime/app"

main :: proc() {
	app_info: app.Init
	app_info.title = "Hello from OXSE!"
	
	app.init(app_info)
	
	for app.update() {
		for event in app.poll_event() do #partial switch variant in event {
		case app.Quit:
			app.quit()
		}
	}
}
