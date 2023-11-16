package dragospopse_oxse_build

import "core:build"
import "core:os"
import "core:path/filepath"
import "core:fmt"

Build_Type :: enum {
	Debug,
	Release,
	Unsafe_Fast,
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
		platform = {ODIN_OS, ODIN_ARCH},
	},
	build_type = .Debug, 
}

target_release := Target {
	target = {
		name = "rel", // TODO(Dragos): check in core:build for similar names.
		platform = {ODIN_OS, ODIN_ARCH},
	},
	build_type = .Release, 
}

target_unsafe_fast := Target {
	target = {
		name = "fast", // TODO(Dragos): check in core:build for similar names.
		platform = {ODIN_OS, ODIN_ARCH},
	},
	build_type = .Unsafe_Fast, 
}

target_safe := Target {
	target = {
		name = "safe",
		platform = {ODIN_OS, ODIN_ARCH},
	},
	build_type = .Safe, 
}


run_target :: proc(target: ^build.Target, mode: build.Run_Mode, args: []build.Arg, loc := #caller_location) -> bool {
	target := cast(^Target)target
	config: build.Odin_Config
	config.platform = target.platform
	config.out_file = "oxse.exe" if target.platform.os == .Windows else "oxse"
	config.out_dir = build.trelpath(target, fmt.tprintf("out/%s", target.name))
	config.src_path = build.trelpath(target, "oxse")

	config.build_mode = .EXE
	
	switch target.build_type {
	case .Debug:
		config.opt = .None
		config.flags += {.Debug}
	case .Release:
		config.opt = .Speed
	case .Unsafe_Fast:
		config.opt = .Aggressive
		config.flags += {
			.Disable_Assert,
			.No_Bounds_Check,
		}
	case .Safe:
		config.opt = .None
		config.flags += {.Debug}
		config.sanitize += {
			.Address,
			.Memory,
			.Thread,
		}
	}

	switch mode {
	case .Build:
		build.odin(target, .Build, config) or_return
		return true
	case .Dev:
		build.generate_odin_devenv(target, config, args) or_return
		return true
	case .Help:
		return false // mode not implemented
	}

	return false
}

@init
_ :: proc() {
	project.name = "OXSE"
	build.add_target(&project, &target_debug, run_target)
	build.add_target(&project, &target_release, run_target)
}

main :: proc() {
	info: build.Cli_Info
	info.project = &project
	info.default_target = &target_debug
	build.run_cli(info, os.args)
}