package oxse_app

import win32 "core:sys/windows"
import "core:fmt"
import "core:runtime"
import "core:time"
import "core:dynlib"

import "../memo"

foreign import user32 "system:User32.lib"

@(default_calling_convention="stdcall")
foreign user32 {
	SetWindowLongPtrW :: proc(hWnd: win32.HWND, nIndex: win32.c_int, dwNewLong: win32.LONG_PTR) -> win32.LONG_PTR ---
	GetWindowLongPtrW :: proc(hWnd: win32.HWND, nIndex: win32.c_int) -> win32.LONG_PTR ---
}

L :: win32.L

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

win32_arrow_cursor: win32.HCURSOR

_Window :: struct {
	hinst: win32.HINSTANCE,
	hwnd: win32.HWND,
}

_gl_set_proc_address :: proc(p: rawptr, name: cstring) {
	func := win32.wglGetProcAddress(name)
	switch uintptr(func) {
	case 0, 1, 2, 3, ~uintptr(0):
		module := win32.LoadLibraryW(L("opengl32.dll"))
		func = win32.GetProcAddress(module, name)
	}
	(^rawptr)(p)^ = func
}


_poll_event :: proc(window: ^Window) -> (event: Event, ok: bool) {
	msg: win32.MSG
	if win32.PeekMessageW(&msg, nil, 0, 0, win32.PM_REMOVE) {
		win32.TranslateMessage(&msg)
		win32.DispatchMessageW(&msg)
		if msg.message == win32.WM_QUIT {
			quit_event: Quit
			quit_event.timestamp = time.now()
			push_event(window, quit_event)
		}
	}
	ev := pop_event(window)
	return ev, ev != nil
}

WIN32_WNDCLASS_NAME := L("oxsewnd")

_create_window :: proc(init: Window_Init) -> ^Window {
	window := new(Window, context.allocator) // Todo(Dragos): Change this
	memo.sarena_init(&window.event_arena)
	window.impl.hinst = win32_get_current_instance()
	@static class_registered: bool
	if !class_registered {
		class_registered = true
		if win32_arrow_cursor == nil {
			win32_arrow_cursor = auto_cast win32.LoadImageW(nil, transmute(win32.wstring)win32.IDC_ARROW, win32.IMAGE_CURSOR, 0, 0, win32.LR_DEFAULTSIZE | win32.LR_SHARED)
			if win32_arrow_cursor == nil {
				win32_print_last_error_and_exit("Cannot load cursor")
			}
		}
		wc: win32.WNDCLASSW
		wc.lpfnWndProc = win32_window_proc
		wc.hInstance = window.impl.hinst
		wc.lpszClassName = WIN32_WNDCLASS_NAME
		wc.hCursor = win32_arrow_cursor
		win32.RegisterClassW(&wc)
	}
	window.impl.hwnd = win32.CreateWindowExW(
		win32.CS_HREDRAW | win32.CS_VREDRAW | win32.CS_OWNDC, // optional window style
		WIN32_WNDCLASS_NAME,
		L("Hello OXSE"), // toolbar text
		win32.WS_OVERLAPPEDWINDOW, // window style
		win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, // size
		win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, // position
		nil, nil, // parent, menu
		window.impl.hinst,
		window, // appdata
	)
	
	if window.impl.hwnd == nil {
		win32_print_last_error_and_exit("Failed to create win32 window.")
	}

	win32_show_window(window.impl.hwnd)
	return window
}

win32_get_window :: proc "contextless" (hwnd: win32.HWND) -> ^Window {
	return transmute(^Window)GetWindowLongPtrW(hwnd, win32.GWLP_USERDATA)
}

win32_set_window :: proc "contextless" (hwnd: win32.HWND, window: ^Window) {
	SetWindowLongPtrW(hwnd, win32.GWLP_USERDATA, transmute(win32.LONG_PTR)window)
}

win32_window_proc :: proc "stdcall" (hwnd: win32.HWND, msg: win32.UINT, wparam: win32.WPARAM, lparam: win32.LPARAM) -> win32.LRESULT {
	context = runtime.default_context() // Note(Dragos): This is not quite ok. 
	switch msg {
	case win32.WM_CREATE:
		create_struct := transmute(^win32.CREATESTRUCTW)lparam
		window := transmute(^Window)create_struct.lpCreateParams
		win32_set_window(hwnd, window)

	case win32.WM_SIZE:
		width := win32.GET_X_LPARAM(lparam)
		height := win32.GET_Y_LPARAM(lparam)
		window := win32_get_window(hwnd)
		event: Resize
		event.prev_size = window.size
		window.size.x = cast(int)width
		window.size.y = cast(int)height
		event.curr_size = window.size
		push_event(window, event)

	case win32.WM_PAINT:
		ps: win32.PAINTSTRUCT
		//win32.BeginPaint(wnd, &ps)
		//win32.EndPaint(wnd, &ps)

	case win32.WM_DESTROY:
		win32.PostQuitMessage(0)
		return 0

	}
	return win32.DefWindowProcW(hwnd, msg, wparam, lparam)
}

win32_get_current_instance :: proc() -> win32.HINSTANCE {
	return auto_cast win32.GetModuleHandleW(nil)
}

win32_show_window :: proc(wnd: win32.HWND) {
	win32.ShowWindow(wnd, win32.SW_SHOW)
	win32.UpdateWindow(wnd)	
}


win32_print_last_error_and_exit :: proc(prefix: string) -> ! {
	error_message_id := win32.GetLastError()
	fmt.eprintf("OXSE WIN32 ERROR: %s\n", prefix)
	fmt.eprintf("WIN32 LAST-ERROR CODE: %v\n", error_message_id)
	if error_message_id != 0 {
		message_buffer: win32.wstring
		size := win32.FormatMessageW(win32.FORMAT_MESSAGE_ALLOCATE_BUFFER | win32.FORMAT_MESSAGE_FROM_SYSTEM | win32.FORMAT_MESSAGE_IGNORE_INSERTS, 
			nil, error_message_id, 0, message_buffer, 0, nil)
		message, _ := win32.wstring_to_utf8(message_buffer, cast(int)size, context.temp_allocator)
		fmt.eprintf("WIN32 ERROR MESSAGE: %s\n", message)
	}
	win32.ExitProcess(error_message_id)
}

