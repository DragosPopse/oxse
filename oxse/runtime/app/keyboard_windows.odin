package oxse_app

import win32 "core:sys/windows"


Platform_Key :: enum {
	Unknown    = 0,
	A          = win32.VK_A,
	B          = win32.VK_B,
	C          = win32.VK_C,
	D          = win32.VK_D,
	E          = win32.VK_E,
	F          = win32.VK_F,
	G          = win32.VK_G,
	H          = win32.VK_H,
	I          = win32.VK_I,
	J          = win32.VK_J,
	K          = win32.VK_K,
	L          = win32.VK_L,
	M          = win32.VK_M,
	N          = win32.VK_N,
	O          = win32.VK_O,
	P          = win32.VK_P,
	Q          = win32.VK_Q,
	R          = win32.VK_R,
	S          = win32.VK_S,
	T          = win32.VK_T,
	U          = win32.VK_U,
	V          = win32.VK_V,
	W          = win32.VK_W,
	X          = win32.VK_X,
	Y          = win32.VK_Y,
	Z          = win32.VK_Z,
	Num1       = win32.VK_NUMPAD1,
	Num2       = win32.VK_NUMPAD2,
	Num3       = win32.VK_NUMPAD3,
	Num4       = win32.VK_NUMPAD4,
	Num5       = win32.VK_NUMPAD5,
	Num6       = win32.VK_NUMPAD6,
	Num7       = win32.VK_NUMPAD7,
	Num8       = win32.VK_NUMPAD8,
	Num9       = win32.VK_NUMPAD9,
	Num0       = win32.VK_NUMPAD0,
	F1         = win32.VK_F1,
	F2         = win32.VK_F2,
	F3         = win32.VK_F3,
	F4         = win32.VK_F4,
	F5         = win32.VK_F5,
	F6         = win32.VK_F6,
	F7         = win32.VK_F7,
	F8         = win32.VK_F8,
	F9         = win32.VK_F9,
	F10        = win32.VK_F10,
	F11        = win32.VK_F11,
	F12        = win32.VK_F12,
	Return     = win32.VK_RETURN,
	Escape     = win32.VK_ESCAPE,
	Backspace  = win32.VK_BACK,            // Note(Dragos): Is this correct?
	Tab        = win32.VK_TAB,
	Space      = win32.VK_SPACE,
	Minus      = win32.VK_OEM_MINUS,       // Note(Dragos): Is this correct?
	Equals     = win32.VK_OEM_NEC_EQUAL,
	LBracket   = win32.VK_OEM_4,           // US standard keyboard: [{
	RBracket   = win32.VK_OEM_6,           // US standard keyboard: ]}
	Backslash  = win32.VK_OEM_5,           // US standard keyboard: \|
	Semicolon  = win32.VK_OEM_1,           // US standard keyboard: ;:
	Apostrophe = win32.VK_OEM_7,           // US standard keyboard: '"
	Grave      = win32.VK_OEM_3,           // US standard keyboard: `~
	Comma      = win32.VK_OEM_COMMA,
	Period     = win32.VK_OEM_PERIOD,
	Slash      = win32.VK_OEM_2,           // US standard keyboard: /?
	Capslock   = win32.VK_CAPITAL,
	Right      = win32.VK_RIGHT,
	Left       = win32.VK_LEFT,
	Down       = win32.VK_DOWN,
	Up         = win32.VK_UP,
	LControl   = win32.VK_LCONTROL,
	LShift     = win32.VK_LSHIFT,
	LAlt       = win32.VK_LMENU,
	LSystem    = win32.VK_LWIN,
	RControl   = win32.VK_RCONTROL,
	RShift     = win32.VK_RSHIFT,
	RAlt       = win32.VK_RMENU,
	RSystem    = win32.VK_RWIN,
}