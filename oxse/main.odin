package main

when ODIN_OS != .Windows do #panic("OXSE can only run on windows.")

import "core:fmt"
import "core:strings"
import "core:time"
import "core:os"
import "core:path/filepath"
import "core:c/libc"
import "core:runtime"

import "core:build"

import win32 "core:sys/windows"
import "runtime/memo"
import "runtime/app"

foreign import shlwapi "system:Shlwapi.lib"

@(default_calling_convention="stdcall")
foreign shlwapi {
	PathIsDirectoryEmptyW :: proc(pszPath: win32.LPCWSTR) -> win32.BOOL ---
}


main :: proc() {
	context.allocator = context.temp_allocator
	fullpath_buffer: [2 * memo.KiB]byte
	path_size := cast(int)win32.GetModuleFileNameW(nil, transmute(win32.LPWSTR)&fullpath_buffer, len(fullpath_buffer))
	if !(path_size != 0) {
		fmt.eprintf("Error locating the oxse file path.\n")
		os.exit(1)
	}

	oxse_fullpath, _ := win32.wstring_to_utf8(transmute(win32.wstring)&fullpath_buffer, path_size)
	
	oxse_exe := filepath.base(oxse_fullpath)
	oxse_dir := filepath.dir(oxse_fullpath)

	shell: Shell
	shell.oxse_root = oxse_dir

	args, args_error := app.parse_args(os.args[1:])
	if args_error != nil {
		fmt.eprintf("Error parsing arguments, got %v\n", args_error)
		os.exit(1)
	}

	if len(args) == 0 {
		display_general_help(&shell)
		os.exit(0)
	}

	
	command, command_is_string := args[0].(string)
	if !command_is_string {
		fmt.eprintf("First argument of oxse must be a command\n")
		os.exit(1)
	}
	
	found_command := false
	for command_desc in command_descriptions do if command == command_desc.name {
		command_desc.procedure(&shell, args)
		found_command = true
		break
	} 
	if !found_command {
		fmt.eprintf("%s is not a recogneizd command\n", command)
		os.exit(1)
	}
}
