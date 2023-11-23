
package main

import "core:fmt"
import "oxse:runtime/app"
import "core:sys/windows"
import "vendor:directx/d3d12"
import "vendor:directx/dxc"
import "vendor:directx/d3d_compiler"
import "vendor:directx/dxgi"

import xm "oxse:runtime/xmath"

Vertex :: struct {
	pos: xm.Vec2f,
	col: xm.Col4f,
}

load_pipeline :: proc() {
	debug_controller: ^d3d12.IDebug
	if hr := d3d12.GetDebugInterface(d3d12.IDebug_UUID, auto_cast &debug_controller); hr < 0 {
		fmt.eprintf("Failed to load the debug interface\n")
	}

	factory: ^dxgi.IFactory4
	if hr := dxgi.CreateDXGIFactory2(dxgi.CREATE_FACTORY_DEBUG, dxgi.IFactory4_UUID, auto_cast &factory); hr < 0 {
		fmt.eprintf("Failed to create the factory\n")
	}

	hardware_adapter: dxgi.IAdapter1
	
	
}

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
