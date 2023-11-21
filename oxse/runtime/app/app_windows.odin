package oxse_app

import win32 "core:sys/windows"
import "core:fmt"
import "../../runtime"
import "core:time"
import "core:dynlib"

import "../memo"
import xm "../xmath"

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
	default_cursor: win32.HCURSOR,
	class_name: win32.wstring,
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

_update :: proc() {
	msg: win32.MSG
	for win32.PeekMessageW(&msg, nil, 0, 0, win32.PM_REMOVE) {
		win32.TranslateMessage(&msg)
		win32.DispatchMessageW(&msg)
		if msg.message == win32.WM_QUIT {
			quit_event: Quit
			quit_event.timestamp = time.now()
			push_event(quit_event)
		}
	}
}

_init :: proc(info: Init) {
	using app_context.os
	wc: win32.WNDCLASSW
	hinst = auto_cast win32.GetModuleHandleW(nil)
	class_name = L("oxsewndclass")
	default_cursor = auto_cast win32.LoadImageW(nil, transmute(win32.wstring)win32.IDC_ARROW, win32.IMAGE_CURSOR, 0, 0, win32.LR_DEFAULTSIZE | win32.LR_SHARED)
	if default_cursor == nil {
		win32_print_last_error_and_exit("Cannot load cursor")
	}
	wc.lpfnWndProc = win32_window_proc
	wc.hInstance = hinst
	wc.lpszClassName = class_name
	wc.hCursor = default_cursor
	win32.RegisterClassW(&wc)
	

	title := win32.utf8_to_wstring(info.title, context.temp_allocator)

	wndsize, wndpos: [2]i32
	for i in 0..=1 {
		switch s in info.size[i] {
		case int: wndsize[i] = cast(i32)s
		case Size_Specifier:
			switch s {
			case .System_Default: wndsize[i] = win32.CW_USEDEFAULT
			case .Fullscreen: unimplemented("Fullscreen not supported yet.")
			}
		}
		switch p in info.pos[i] {
		case int: wndpos[i] = cast(i32)p
		case Pos_Specifier:
			switch p {
			case .Unspecified: wndpos[i] = win32.CW_USEDEFAULT
			case .Centered: unimplemented("Centered not implemented.")
			}
		}
	}
	

	hwnd = win32.CreateWindowExW(
		win32.CS_OWNDC, // optional window style
		class_name,
		title, // toolbar text
		win32.WS_OVERLAPPEDWINDOW, // window style
		win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, // size
		win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, // position
		nil, nil, // parent, menu
		hinst,
		nil,
	)
	
	if hwnd == nil {
		win32_print_last_error_and_exit("Failed to create win32 window.")
	}

	win32.ShowWindow(hwnd, win32.SW_SHOW)
	win32.UpdateWindow(hwnd)
}

_size :: proc "contextless" () -> xm.Vec2i {
	rect: win32.RECT
	win32.GetWindowRect(app_context.os.hwnd, &rect)
	return {int(rect.right - rect.left), int(rect.bottom - rect.top)}
}

@(private="file")
win32_window_proc :: proc "stdcall" (hwnd: win32.HWND, msg: win32.UINT, wparam: win32.WPARAM, lparam: win32.LPARAM) -> win32.LRESULT {
	context = runtime.default_context // Note(Dragos): This is not quite ok. 
	switch msg {
	case win32.WM_CREATE:

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

	case win32.WM_CHAR:
	
	case win32.WM_UNICHAR:

	case win32.WM_SYSCHAR:

	case win32.WM_KEYDOWN:
	case win32.WM_KEYUP:
	case win32.WM_SYSKEYDOWN:
	case win32.WM_SYSKEYUP:
	
	

	}
	return win32.DefWindowProcW(hwnd, msg, wparam, lparam)
}

@(private)
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

