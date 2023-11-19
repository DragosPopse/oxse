package oxse_app

import xm "../xmath"
import "core:time"
import "core:container/intrusive/list"

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