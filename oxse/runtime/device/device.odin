package oxse_device

import xm "../xmath"
import "../memo"
import "core:container/intrusive/list"
import "core:time"

Key :: enum {
	Unknown,
	A,
	B,
	C,
	D,
	E,
	F,
	G,
	H,
	I,
	J,
	K,
	L,
	M,
	N,
	O,
	P,
	Q,
	R,
	S,
	T,
	U,
	V,
	W,
	X,
	Y,
	Z,
	Num1,
	Num2,
	Num3,
	Num4,
	Num5,
	Num6,
	Num7,
	Num8,
	Num9,
	Num0,
	F1,
	F2,
	F3,
	F4,
	F5,
	F6,
	F7,
	F8,
	F9,
	F10,
	F11,
	F12,
	Return,
	Escape,
	Backspace,
	Tab,
	Space,
	Minus,
	Equals,
	LBracket,
	RBracket,
	Backslash,
	Semicolon,
	Apostrophe,
	Grave,
	Comma,
	Period,
	Slash,
	Capslock,
	Right,
	Left,
	Down,
	Up,
	LControl,
	LShift,
	LAlt,
	LSystem,
	RControl,
	RShift,
	RAlt,
	RSystem,
}

key_to_platform_key := [Key]Platform_Key {
	.Unknown    = .Unknown,
	.A          = .A,
	.B          = .B,
	.C          = .C,
	.D          = .D,
	.E          = .E,
	.F          = .F,
	.G          = .G,
	.H          = .H,
	.I          = .I,
	.J          = .J,
	.K          = .K,
	.L          = .L,
	.M          = .M,
	.N          = .N,
	.O          = .O,
	.P          = .P,
	.Q          = .Q,
	.R          = .R,
	.S          = .S,
	.T          = .T,
	.U          = .U,
	.V          = .V,
	.W          = .W,
	.X          = .X,
	.Y          = .Y,
	.Z          = .Z,
	.Num1       = .Num1,
	.Num2       = .Num2,
	.Num3       = .Num3,
	.Num4       = .Num4,
	.Num5       = .Num5,
	.Num6       = .Num6,
	.Num7       = .Num7,
	.Num8       = .Num8,
	.Num9       = .Num9,
	.Num0       = .Num0,
	.F1         = .F1,
	.F2         = .F2,
	.F3         = .F3,
	.F4         = .F4,
	.F5         = .F5,
	.F6         = .F6,
	.F7         = .F7,
	.F8         = .F8,
	.F9         = .F9,
	.F10        = .F10,
	.F11        = .F11,
	.F12        = .F12,
	.Return     = .Return,
	.Escape     = .Escape,
	.Backspace  = .Backspace,
	.Tab        = .Tab,
	.Space      = .Space,
	.Minus      = .Minus,
	.Equals     = .Equals,
	.LBracket   = .LBracket,
	.RBracket   = .RBracket,
	.Backslash  = .Backslash,
	.Semicolon  = .Semicolon,
	.Apostrophe = .Apostrophe,
	.Grave      = .Grave,
	.Comma      = .Comma,
	.Period     = .Period,
	.Slash      = .Slash,
	.Capslock   = .Capslock,
	.Right      = .Right,
	.Left       = .Left,
	.Down       = .Down,
	.Up         = .Up,
	.LControl   = .LControl,
	.LShift     = .LShift,
	.LAlt       = .LAlt,
	.LSystem    = .LSystem,
	.RControl   = .RControl,
	.RShift     = .RShift,
	.RAlt       = .RAlt,
	.RSystem    = .RSystem,
}

platform_key_to_key := #sparse [Platform_Key]Key {
	.Unknown    = .Unknown,
	.A          = .A,
	.B          = .B,
	.C          = .C,
	.D          = .D,
	.E          = .E,
	.F          = .F,
	.G          = .G,
	.H          = .H,
	.I          = .I,
	.J          = .J,
	.K          = .K,
	.L          = .L,
	.M          = .M,
	.N          = .N,
	.O          = .O,
	.P          = .P,
	.Q          = .Q,
	.R          = .R,
	.S          = .S,
	.T          = .T,
	.U          = .U,
	.V          = .V,
	.W          = .W,
	.X          = .X,
	.Y          = .Y,
	.Z          = .Z,
	.Num1       = .Num1,
	.Num2       = .Num2,
	.Num3       = .Num3,
	.Num4       = .Num4,
	.Num5       = .Num5,
	.Num6       = .Num6,
	.Num7       = .Num7,
	.Num8       = .Num8,
	.Num9       = .Num9,
	.Num0       = .Num0,
	.F1         = .F1,
	.F2         = .F2,
	.F3         = .F3,
	.F4         = .F4,
	.F5         = .F5,
	.F6         = .F6,
	.F7         = .F7,
	.F8         = .F8,
	.F9         = .F9,
	.F10        = .F10,
	.F11        = .F11,
	.F12        = .F12,
	.Return     = .Return,
	.Escape     = .Escape,
	.Backspace  = .Backspace,
	.Tab        = .Tab,
	.Space      = .Space,
	.Minus      = .Minus,
	.Equals     = .Equals,
	.LBracket   = .LBracket,
	.RBracket   = .RBracket,
	.Backslash  = .Backslash,
	.Semicolon  = .Semicolon,
	.Apostrophe = .Apostrophe,
	.Grave      = .Grave,
	.Comma      = .Comma,
	.Period     = .Period,
	.Slash      = .Slash,
	.Capslock   = .Capslock,
	.Right      = .Right,
	.Left       = .Left,
	.Down       = .Down,
	.Up         = .Up,
	.LControl   = .LControl,
	.LShift     = .LShift,
	.LAlt       = .LAlt,
	.LSystem    = .LSystem,
	.RControl   = .RControl,
	.RShift     = .RShift,
	.RAlt       = .RAlt,
	.RSystem    = .RSystem,
}

Mouse_Button :: enum {
	Left,
	Right,
	Middle,
	X1,
	X2,
}

Key_Event :: struct {
	key: Key,
}

Mouse_Button_Event :: struct {
	pos: xm.Vec2i,
	button: Mouse_Button,
}

Mouse_Scroll :: struct {
	scroll: xm.Vec2i,
}

Mouse_Move :: struct {
	pos: xm.Vec2i,
	delta: xm.Vec2i,
}

Quit :: struct {
	timestamp: time.Time,
}

Resize :: struct {
	prev_size: xm.Vec2i,
	curr_size: xm.Vec2i,
}

Mouse_Button_Down :: distinct Mouse_Button_Event
Mouse_Button_Up :: distinct Mouse_Button_Event
Mouse_Button_Hold :: distinct Mouse_Button_Event

Key_Down :: distinct Key_Event
Key_Up :: distinct Key_Event
Key_Hold :: distinct Key_Event

Event :: union {
	Key_Down, Key_Up, Key_Hold,
	Mouse_Button_Down, Mouse_Button_Up, Mouse_Button_Hold,
	Mouse_Scroll,
	Quit,
	Resize,
}

Event_Node :: struct {
	using node: list.Node,
	event: Event,
}

Window_Pos_Specifier :: enum {
	Unspecified,
	Centered,
}

Window_Size_Specifier :: enum {
	System_Default,
}

Window_Init_Pos :: union {
	int,
	Window_Pos_Specifier,
}

Window_Init_Size :: union {
	int,
	Window_Size_Specifier,
}

Window_Init :: struct {
	pos: [2]Window_Init_Pos,
	size: [2]Window_Init_Size,

}

Window :: struct {
	pos: xm.Vec2i,
	size: xm.Vec2i,
	event_arena: memo.SArena(1 * memo.MiB), // Note(Dragos): maybe we can use the temp_allocator to allocate the event queue every time.
	event_queue: list.List,
	n_events: int,
	impl: _Window,
}

create_window :: proc(init: Window_Init) -> ^Window {
	window := _create_window(init)
	return window
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