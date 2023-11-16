package oxse_device

import win32 "core:sys/windows"
import "core:fmt"
import "core:runtime"

L :: win32.L

_A          :: win32.VK_A
_B          :: win32.VK_B
_C          :: win32.VK_C
_D          :: win32.VK_D
_E          :: win32.VK_E
_F          :: win32.VK_F
_G          :: win32.VK_G
_H          :: win32.VK_H
_I          :: win32.VK_I
_J          :: win32.VK_J
_K          :: win32.VK_K
_L          :: win32.VK_L
_M          :: win32.VK_M
_N          :: win32.VK_N
_O          :: win32.VK_O
_P          :: win32.VK_P
_Q          :: win32.VK_Q
_R          :: win32.VK_R
_S          :: win32.VK_S
_T          :: win32.VK_T
_U          :: win32.VK_U
_V          :: win32.VK_V
_W          :: win32.VK_W
_X          :: win32.VK_X
_Y          :: win32.VK_Y
_Z          :: win32.VK_Z
_Num1       :: win32.VK_NUMPAD1
_Num2       :: win32.VK_NUMPAD2
_Num3       :: win32.VK_NUMPAD3
_Num4       :: win32.VK_NUMPAD4
_Num5       :: win32.VK_NUMPAD5
_Num6       :: win32.VK_NUMPAD6
_Num7       :: win32.VK_NUMPAD7
_Num8       :: win32.VK_NUMPAD8
_Num9       :: win32.VK_NUMPAD9
_Num0       :: win32.VK_NUMPAD0
_F1         :: win32.VK_F1
_F2         :: win32.VK_F2
_F3         :: win32.VK_F3
_F4         :: win32.VK_F4
_F5         :: win32.VK_F5
_F6         :: win32.VK_F6
_F7         :: win32.VK_F7
_F8         :: win32.VK_F8
_F9         :: win32.VK_F9
_F10        :: win32.VK_F10
_F11        :: win32.VK_F11
_F12        :: win32.VK_F12
_Return     :: win32.VK_RETURN
_Escape     :: win32.VK_ESCAPE
_Backspace  :: win32.VK_BACK // Note(Dragos): Is this correct?
_Tab        :: win32.VK_TAB
_Space      :: win32.VK_SPACE
_Minus      :: win32.VK_OEM_MINUS // Note(Dragos): Is this correct?
_Equals     :: win32.VK_OEM_NEC_EQUAL
_LBracket   :: win32.VK_OEM_4 // US standard keyboard: [{
_RBracket   :: win32.VK_OEM_6 // US standard keyboard: ]}
_Backslash  :: win32.VK_OEM_5 // US standard keyboard: \|
_Semicolon  :: win32.VK_OEM_1 // US standard keyboard: ;:
_Apostrophe :: win32.VK_OEM_7 // US standard keyboard: '"
_Grave      :: win32.VK_OEM_3 // US standard keyboard: `~
_Comma      :: win32.VK_OEM_COMMA
_Period     :: win32.VK_OEM_PERIOD
_Slash      :: win32.VK_OEM_2 // US standard keyboard: /?
_Capslock   :: win32.VK_CAPITAL
_Right      :: win32.VK_RIGHT
_Left       :: win32.VK_LEFT
_Down       :: win32.VK_DOWN
_Up         :: win32.VK_UP
_LControl   :: win32.VK_LCONTROL
_LShift     :: win32.VK_LSHIFT
_LAlt       :: win32.VK_LMENU
_LSystem    :: win32.VK_LWIN
_RControl   :: win32.VK_RCONTROL
_RShift     :: win32.VK_RSHIFT
_RAlt       :: win32.VK_RMENU
_RSystem    :: win32.VK_RWIN


win32_arrow_cursor: win32.HCURSOR




win32_window_proc :: proc "stdcall" (wnd: win32.HWND, msg: win32.UINT, wparam: win32.WPARAM, lparam: win32.LPARAM) -> win32.LRESULT {
	switch msg {
	case win32.WM_SIZE:
		width := win32.GET_X_LPARAM(lparam)
		height := win32.GET_Y_LPARAM(lparam)

	case win32.WM_PAINT:
		ps: win32.PAINTSTRUCT
		//win32.BeginPaint(wnd, &ps)
		//win32.EndPaint(wnd, &ps)

	case win32.WM_DESTROY:
		win32.PostQuitMessage(0)
		return 0

	}
	return win32.DefWindowProcW(wnd, msg, wparam, lparam)
}

win32_get_current_instance :: proc() -> win32.HINSTANCE {
	return auto_cast win32.GetModuleHandleW(nil)
}

win32_register_class :: proc(inst: win32.HINSTANCE, name: win32.wstring) {
	if win32_arrow_cursor == nil {
		win32_arrow_cursor = auto_cast win32.LoadImageW(nil, transmute(win32.wstring)win32.IDC_ARROW, win32.IMAGE_CURSOR, 0, 0, win32.LR_DEFAULTSIZE | win32.LR_SHARED)
		if win32_arrow_cursor == nil {
			win32_print_last_error_and_exit("Cannot load cursor")
		}
	}
	wc: win32.WNDCLASSW
	wc.lpfnWndProc = win32_window_proc
	wc.hInstance = inst
	wc.lpszClassName = name
	wc.hCursor = win32_arrow_cursor
	win32.RegisterClassW(&wc)
}

win32_create_window :: proc(inst: win32.HINSTANCE, class_name: win32.wstring, text: win32.wstring) -> win32.HWND {
	hwnd := win32.CreateWindowExW(
		win32.CS_HREDRAW | win32.CS_VREDRAW | win32.CS_OWNDC, // optional window style
		class_name,
		text, // toolbar text
		win32.WS_OVERLAPPEDWINDOW, // window style
		win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, // size
		win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, // position
		nil, nil, // parent, menu
		inst,
		nil, // appdata
	)
	
	if hwnd == nil {
		win32_print_last_error_and_exit("Failed to create win32 window.")
	}

	return hwnd
}

win32_show_window :: proc(wnd: win32.HWND) {
	win32.ShowWindow(wnd, win32.SW_SHOW)
	win32.UpdateWindow(wnd)	
}

win32_poll_messages :: proc() {
	msg: win32.MSG
	for win32.PeekMessageW(&msg, nil, 0, 0, win32.PM_REMOVE) {
		win32.TranslateMessage(&msg)
		win32.DispatchMessageW(&msg)
		if msg.message == win32.WM_QUIT {
			should_quit = true
		}
	}
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