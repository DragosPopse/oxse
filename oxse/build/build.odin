package dragospopse_oxse_build

when ODIN_OS != .Windows do #panic("The OXSE tools can only be built on windows.")

import "core:build"
import "core:os"
import "core:os/os2"
import "core:path/filepath"
import "core:fmt"

copy_file :: proc(src, dst: string) -> bool {
	err := os2.copy_file(dst, src)
	return true
}

Build_Type :: enum {
	Debug,
	Release,
	Unsafe_Fast,
	Safe,
	Small,
}

Target :: struct {
	using target: build.Target,
	build_type: Build_Type,
}

project: build.Project

CURRENT_PLATFORM :: build.Platform{ODIN_OS, ODIN_ARCH}

target_install := Target {
	target = {
		name = "install",
		platform = CURRENT_PLATFORM,
	},
}

target_debug := Target {
	target = {
		name = "dbg",
		platform = CURRENT_PLATFORM,
	},
	build_type = .Debug, 
}

target_release := Target {
	target = {
		name = "rel", // TODO(Dragos): check in core:build for similar names.
		platform = CURRENT_PLATFORM,
	},
	build_type = .Release, 
}

target_unsafe_fast := Target {
	target = {
		name = "fast", // TODO(Dragos): check in core:build for similar names.
		platform = CURRENT_PLATFORM,
	},
	build_type = .Unsafe_Fast, 
}

target_safe := Target {
	target = {
		name = "safe",
		platform = CURRENT_PLATFORM,
	},
	build_type = .Safe,
}

target_small := Target {
	target = {
		name = "small",
		platform = CURRENT_PLATFORM,
	},
	build_type = .Small,
}

OUT_DIR :: "."


run_target :: proc(target: ^build.Target, mode: build.Run_Mode, args: []build.Arg, loc := #caller_location) -> bool {
	target := cast(^Target)target
	config: build.Odin_Config
	config.platform = target.platform
	config.out_file = "oxse.exe" if target.platform.os == .Windows else "oxse"
	config.out_dir = build.trelpath(target, OUT_DIR)
	config.src_path = build.trelpath(target, "oxse")
	config.build_mode = .EXE

	config.collections = {
		{"oxse", build.trelpath(target, "oxse/runtime")},
	}
	
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
	case .Small:
		config.opt = .Size
		config.flags += {
			.Disable_Assert,
			.No_Bounds_Check,
			.No_CRT,
		}
	}

	switch mode {
	case .Build:
		build.odin(target, .Build, config) or_return

		/*
		if ODIN_OS == .Windows && target.platform.os == .Windows {
			copy_file(fmt.tprintf("%svendor/sdl2/SDL2.dll", ODIN_ROOT), fmt.tprintf("%s/SDL2.dll", config.out_dir)) or_return
		}
		*/
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
	build.add_target(&project, &target_debug, run_target, 2)
	build.add_target(&project, &target_release, run_target, 2)
	build.add_target(&project, &target_safe, run_target, 2)
	build.add_target(&project, &target_unsafe_fast, run_target, 2)
	build.add_target(&project, &target_small, run_target, 2)
}

main :: proc() {
	info: build.Cli_Info
	info.project = &project
	info.default_target = &target_debug
	build.run_cli(info, os.args)
}