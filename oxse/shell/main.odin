package oxse_shell

when ODIN_OS != .Windows do #panic("OXSE can only run on windows.")

//+private
import "core:fmt"
import "core:strings"
import "core:time"
import "core:os"
import "core:path/filepath"
import "core:c/libc"
import "core:runtime"

import "core:build"

import win32 "core:sys/windows"

import "../runtime/memo"
import "../runtime/app"

foreign import shlwapi "system:Shlwapi.lib"

@(default_calling_convention="stdcall")
foreign shlwapi {
	PathIsDirectoryEmptyW :: proc(pszPath: win32.LPCWSTR) -> win32.BOOL ---
}

@(disabled = ODIN_BUILD_MODE != .Executable)
main :: proc() {
	context.allocator = context.temp_allocator
	fmt.printf("Found oxse root at %s\n", oxse_root())


	args, args_error := app.parse_args(os.args[1:])
	if args_error != nil {
		fmt.eprintf("Error parsing arguments, got %v\n", args_error)
		os.exit(1)
	}

	if len(args) == 0 {
		print_general_help()
		os.exit(0)
	}

	command, command_is_string := args[0].(string)
	if !command_is_string {
		fmt.eprintf("First argument of oxse must be a command\n")
		os.exit(1)
	}
	
	found_command := false
	if command == command_descriptions[.Init].name {
		command_descriptions[.Init].procedure(nil, args[1:])
		os.exit(0)
	}
	project, project_opened := open_project()
	if !project_opened {
		fmt.eprintf("Failed to open the oxse project. Make sure it's initialized via oxse init.\n")
		os.exit(1)
	}
	for command_desc in command_descriptions do if command == command_desc.name {
		command_desc.procedure(&project, args[1:])
		found_command = true
		break
	}
	if !found_command {
		fmt.eprintf("%s is not a recognized command\n", command)
		os.exit(1)
	}
}
