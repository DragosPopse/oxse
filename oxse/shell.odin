package main

import "core:fmt"
import "core:strings"
import "core:time"
import "core:os"
import "core:path/filepath"
import "core:c/libc"
import "core:runtime"

import "core:build"
import oxse_build "build"

import win32 "core:sys/windows"
import "runtime/memo"
import "runtime/app"

Shell :: struct {
	oxse_root: string,
	project_root: string,
	project: Project,
}

Command_Kind :: enum {
	Init,
	Build,
	Config,
	Info,
	Gen,
}

Command_Proc :: #type proc(shell: ^Shell, args: []app.Arg)

Command_Desc :: struct {
	name: string,
	display: string,
	info: string,
	flags: []Flag_Desc,
	procedure: Command_Proc,
}

Flag_Desc :: struct {
	flag: app.Flag_Arg,
	info: string,
}

command_descriptions := [Command_Kind]Command_Desc {
	.Init = Command_Desc {
		procedure = command_init,
		name = "init",
		display = "init <optional directory>",
		info = "Create a new oxse project in the directory specified. Current directory will be used if no directory is specified. Must be empty.",
	},
	.Build = Command_Desc {
		procedure = command_build,
		name = "build",
		display = "build",
		info = "Creates an executable of the build system. This ensures that the oxse collection is configured properly.",
	},
	.Config = Command_Desc {
		procedure = command_config,
		name = "config",
		display = "config",
		info = "Configures the current oxse project.",
		flags = {
			Flag_Desc {
				flag = app.Flag_Arg {
					flag = "-user",
				},
				info = "Specify user configuration. These are typically ignored by the version control software.",
			},
		},
	},
	.Info = Command_Desc {
		procedure = nil,
		name = "info",
		display = "info",
		info = "Shows information about the current oxse project",
	},
	.Gen = Command_Desc {
		procedure = command_regen,
		name = "gen",
		display = "gen",
		info = "Generates or regenerates specified files or configurations. This can overwrite your work.",
		flags = {
			Flag_Desc {
				flag = app.Flag_Arg {
					flag = "-build",
				},
				info = "Generates the build system under ./build",
			},
		},
	},
}

display_general_help :: proc(shell: ^Shell) {
	fmt.println("oxse is a tool for managing your oxse projects")
	fmt.println("syntax: oxse [command] [args]")
	fmt.println("available commands:")
	for command in command_descriptions {
		fmt.printf("\t%s\n", command.display)
		fmt.printf("\t\t%s\n", command.info)
		fmt.println()
	}
}

command_init :: proc(shell: ^Shell, args: []app.Arg) {
	init_command := args[0]

	init_dir := "."

	if project_initialized() {
		fmt.eprintf("Already found an oxse project at this location\n")
		os.exit(1)
	}
	
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
	os.set_current_directory(init_dir_abs)
	
	project_name: string
	for arg in args do if flag, is_flag := arg.(app.Flag_Arg); is_flag {
		switch flag.flag {
		case "-name":
			project_name = flag.key
		}
	}
	if project_name == "" {
		fmt.eprintf("init requires a project name. Please specify it with -name:\"projectname\"")
		os.exit(1)
	}
	project: Project
	project.name = project_name
	if !save_project(project) {
		fmt.eprintf("Failed to save the project.\n")
		os.exit(1)
	}

	if !write_oxse_build(project, args) {
		fmt.eprintf("Failed to generate build system\n")
		os.exit(1)
	}
}

command_build :: proc(shell: ^Shell, args: []app.Arg) {
	odin_config: build.Odin_Config
	odin_config.build_mode = .EXE
	odin_config.out_dir = "."
	odin_config.platform = {ODIN_OS, ODIN_ARCH}
	odin_config.out_file = "build.exe" if ODIN_OS == .Windows else "build"
	odin_config.src_path = "build"
	odin_config.opt = .Minimal
	odin_config.collections = {
		oxse_build.oxse_collection(),
	}
	build_ok := build.odin(nil, .Build, odin_config, true)
	if !build_ok {
		fmt.eprintf("Failed to build the build system.\n")
		os.exit(1)
	}
}

command_config :: proc(shell: ^Shell, args: []app.Arg) {
	fmt.eprintf("Command config not implemented\n")
	os.exit(1)
}

command_regen :: proc(shell: ^Shell, args: []app.Arg) {
	for arg in args do if flag, is_flag := arg.(app.Flag_Arg); is_flag {
		switch flag.flag {
		case "-build":
			build_system_string := generate_oxse_build_string(shell.project, args)
			build.make_directory("./build")
			if !write_text_file("./build/build.odin", build_system_string) {
				fmt.eprintf("Failed to generate build system")
			}
		}
	}
}

