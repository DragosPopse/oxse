package oxse_app

import xm "../xmath"
import "../memo"
import "core:container/intrusive/list"
import "core:time"

Context :: struct {
	os: _Context,
}

app_context: Context



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
}

init :: proc(info: Init) {

}

push_event :: proc(window: ^Window, event: Event) -> bool {
	assert(window != nil, "oxse_device.push_event: window is null")
	if list.is_empty(&window.event_queue) { // queue is empty, free the memory, reset the list
		free_all(window.event_arena) // This is wrong, it will free the list before handling the event, this should be done in the push event
		window.event_queue = {}
	}
	node, err := new(Event_Node, window.event_arena)
	assert(err == nil, "oxse_device.push_event: Error allocating event.")
	node.event = event
	list.push_back(&window.event_queue, &node.node)
	window.n_events += 1
	return err == nil
}

pop_event :: proc(window: ^Window) -> Event {
	assert(window != nil, "oxse_device.pop_event: window is null")
	node := cast(^Event_Node)list.pop_front(&window.event_queue)
	window.n_events -= 1
	return node.event if node != nil else nil
}

poll_event :: proc(window: ^Window) -> (event: Event, ok: bool) {
	return _poll_event(window)
}

gl_set_proc_address :: proc(p: rawptr, name: cstring) {
	_gl_set_proc_address(p, name)
}