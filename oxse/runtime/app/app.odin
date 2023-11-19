package oxse_app

import xm "../xmath"
import "../memo"
import "core:container/intrusive/list"
import "core:time"

Context :: struct {
	event_queue: list.List,
	should_quit: bool,
	os: _Context,
}

app_context: ^Context



Pos_Specifier :: enum {
	Unspecified,
	Centered,
}

Size_Specifier :: enum {
	System_Default,
	Fullscreen,
}


Window :: struct {
	pos: xm.Vec2i,
	size: xm.Vec2i,
	event_arena: memo.SArena(1 * memo.MiB), // Note(Dragos): maybe we can use the temp_allocator to allocate the event queue every time.
	event_queue: list.List,
	n_events: int,
	impl: _Window,
}

Init_Flag :: enum {
	Fullscreen,
}

Init_Flags :: bit_set[Init_Flag]

Init :: struct {
	pos: [2]union {
		int,
		Pos_Specifier,
	},
	size: [2]union {
		int,
		Size_Specifier,
	},
	flags: Init_Flags,
	title: string,
}

init :: proc(info: Init) {
	app_context = new(Context) // This is required for making this engine possibly available via dlls
	_init(info)
}

size :: proc "contextless" () -> xm.Vec2i {
	return _size()
}

update :: proc() -> bool {
	app_context.event_queue = {} // reset the event queue. Any unhandled event will be missed
	_update()
	return !app_context.should_quit
}

quit :: proc "contextless" () {
	app_context.should_quit = true
	// Note(Dragos): Probably there should be a _quit too. I'm also not sure about this approach with update(). We'll see how it behaves on wasm
}

@private
push_event :: proc(event: Event) {
	node, _ := new(Event_Node, context.temp_allocator)
	node.event = event
	list.push_back(&app_context.event_queue, &node.node)
}

@private
pop_event :: proc() -> Event {
	node := cast(^Event_Node)list.pop_front(&app_context.event_queue)
	return node.event if node != nil else nil
}

poll_event :: proc() -> (event: Event, ok: bool) {
	ev := pop_event()
	return ev, ev != nil
}

gl_set_proc_address :: proc(p: rawptr, name: cstring) {
	_gl_set_proc_address(p, name)
}