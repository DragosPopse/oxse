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

Oxse :: struct {
	fullpath: string,
	dir: string,
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

	args, args_error := app.parse_args(os.args[1:])
	if args_error != nil {
		fmt.eprintf("Error parsing arguments, got %v\n", args_error)
		os.exit(1)
	}

	if len(args) == 0 {
		fmt.eprintf("Please specify a command for oxse to run\n")
		os.exit(1)
	}

	oxse: Oxse
	oxse.fullpath = oxse_fullpath
	oxse.dir = oxse_dir
	command, command_is_string := args[0].(string)
	if !command_is_string {
		fmt.eprintf("First argument of oxse must be a command\n")
		os.exit(1)
	}
	switch command {
	case "init" : run_init_command(&oxse, args)
	case "build": run_build_command(&oxse, args)
	}
}

run_init_command :: proc(oxse: ^Oxse, args: []app.Arg) {
	init_command := args[0]
	assert(init_command == "init")
	init_dir := "."
	
	for arg in args[1:] do if dir, dir_is_string := arg.(string); dir_is_string {
		build.make_directory(dir)
		if !os.is_dir(dir) {
			fmt.eprintf("Error making directory %s\n", dir)
			os.exit(1)
		}
		init_dir = dir
		break
	}
	is_empty := cast(bool)PathIsDirectoryEmptyW(win32.utf8_to_wstring(init_dir))
	init_dir_abs, _ := filepath.abs(init_dir)
	if !is_empty {
		fmt.eprintf("oxse init expects an empty directory, got %v\n", init_dir_abs)
		os.exit(1)
	}
	
	fmt.printf("Initializing an oxse project at %s\n", init_dir_abs)
}

run_build_command :: proc(oxse: ^Oxse, args: []app.Arg) {
	
}

