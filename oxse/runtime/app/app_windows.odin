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

_Context :: struct {
	hinst: win32.HINSTANCE,
	hwnd: win32.HWND,
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

_window: Window

_init :: proc(info: Init) {
	window := new(Window, context.allocator)
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

