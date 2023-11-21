
package oxse_project_build // Modify this name if you plan on including this build system into others

import "core:build"
import "core:fmt"
import "core:strings"
import "core:os"

import "oxse:shell"

// FILL THESE IN TO YOUR DESIRE. These are only needed if you plan on not modifying the generated build system too much

PROJECT_NAME   :: "bitflight"  // The name of the project
SOURCE_PATH    :: "./src"      // The path of the odin source
EXE_NAME       :: "bitflight"  // The produced executable name
OUT_DIR        :: "./out"      // The output directory
OUT_PER_TARGET :: true         // Generate a subfolder for each target

//

CURRENT_PLATFORM :: build.Platform{ODIN_OS, ODIN_ARCH}

Build_Type :: enum {
	Debug,
	Release,
	Safe,
}

Target :: struct {
	using target: build.Target,
	build_type: Build_Type,
}

project: build.Project

target_debug := Target {
	target = {
		name = "dbg",
		platform = CURRENT_PLATFORM,
	},
	build_type = .Debug,
}

target_release := Target {
	target = {
		name = "rel",
		platform = CURRENT_PLATFORM,
	},
	build_type = .Release,
}

target_safe := Target {
	target = {
		name = "safe",
		platform = CURRENT_PLATFORM,
	},
	build_type = .Safe,
}

run_target :: proc(target: ^build.Target, run_mode: build.Run_Mode, args: []build.Arg, loc := #caller_location) -> bool {
	target := cast(^Target)target
	odin_build: build.Odin_Config
	odin_build.platform = target.platform
	odin_build.build_mode = .EXE
	exe_name := EXE_NAME
	exe_extension: string
	#partial switch target.platform.os {
	case .Windows:
		exe_extension = ".exe"
	case: // Other platforms don't need extension right now.
	}
	odin_build.out_file = fmt.tprintf("%s%s", exe_name, exe_extension)

	if OUT_PER_TARGET {
		odin_build.out_dir = build.trelpath(target, fmt.tprintf("./%s/%s", OUT_DIR, target.name))
	} else {
		odin_build.out_dir = build.trelpath(target, OUT_DIR)
	}
	

	odin_build.src_path = build.trelpath(target, SOURCE_PATH)

	odin_build.collections = {
		shell.oxse_collection(),
		// Add more collections here
	}

	switch target.build_type {
	case .Debug:
		odin_build.opt = .None
		odin_build.flags += {
			.Debug,
		}

	case .Release:
		odin_build.opt = .Speed
	
	case .Safe:
		odin_build.opt = .None
		odin_build.flags += {
			.Debug,
		}
		odin_build.sanitize += {
			.Address,
			.Memory,
			.Thread,
		}
	}

	switch run_mode {
	case .Build: // Build your executable, you can add post/pre-build commands here, like copying files
		build.odin(target, .Build, odin_build) or_return
		return true
	
	case .Dev: // Generate config for the debugger, language server settings, etc
		build.generate_odin_devenv(target, odin_build, args) or_return
		return true
	
	case .Help: // Displays information about the current target
		return false // Mode is not implemented
	}

	return false // We should never get here
}

@init
_ :: proc() {
	project.name = PROJECT_NAME
	build.add_target(&project, &target_debug, run_target)
	build.add_target(&project, &target_release, run_target)
	build.add_target(&project, &target_safe, run_target)
}

main :: proc() {
	info: build.Cli_Info
	info.project = &project
	info.default_target = &target_debug
	build.run_cli(info, os.args)
}
