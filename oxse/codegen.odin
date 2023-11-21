package main

import "core:strings"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:build"

import "runtime/app"

OXSE_BUILD_STRING := `
package {0:s}_build

import oxse_build "oxse:build"

import "core:build"
import "core:fmt"
import "core:strings"
import "core:os"

CURRENT_PLATFORM :: build.Platform{{ODIN_OS, ODIN_ARCH}}

Build_Type :: enum {{
	Debug,
	Release,
	Safe,
}}

Target :: struct {{
	using target: build.Target,
	build_type: Build_Type,
}}

project: build.Project

target_debug := Target {{
	target = {{
		name = "dbg",
		platform = CURRENT_PLATFORM,
	}},
	build_type = .Debug,
}}

target_release := Target {{
	target = {{
		name = "rel",
		platform = CURRENT_PLATFORM,
	}},
	build_type = .Release,
}}

target_safe := Target {{
	target = {{
		name = "safe",
		platform = CURRENT_PLATFORM,
	}},
	build_type = .Safe,
}}

run_target :: proc(target: ^build.Target, run_mode: build.Run_Mode, args: []build.Arg, loc := #caller_location) -> bool {{
	target := cast(^Target)target
	odin_build: build.Odin_Config
	odin_build.platform = target.platform
	odin_build.build_mode = .EXE
	exe_name := "{1:s}"
	exe_extension: string
	#partial switch target.platform.os {{
	case .Windows:
		exe_extension = ".exe"
	case: // Other platforms don't need extension right now.
	}}
	odin_build.out_file = fmt.tprintf("%%s%%s", exe_name, exe_extension)
	odin_build.out_dir = build.trelpath(target, fmt.tprintf("out/%%s", target.name))

	odin_build.src_path = build.trelpath(target, "{2:s}")

	odin_build.collections = {{
		oxse_build.oxse_collection(),
		// Add more collections here
	}}

	switch target.build_type {{
	case .Debug:
		odin_build.opt = .None
		odin_build.flags += {{
			.Debug,
		}}

	case .Release:
		odin_build.opt = .Speed
	
	case .Safe:
		odin_build.opt = .None
		odin_build.flags += {{
			.Debug,
		}}
		odin_build.sanitize += {{
			.Address,
			.Memory,
			.Thread,
		}}
	}}

	switch run_mode {{
	case .Build: // Build your executable, you can add post/pre-build commands here, like copying files
		build.odin(target, .Build, odin_build) or_return
		return true
	
	case .Dev: // Generate config for the debugger, language server settings, etc
		build.generate_odin_devenv(target, odin_build, args) or_return
		return true
	
	case .Help: // Displays information about the current target
		return false // Mode is not implemented
	}}

	return false // We should never get here
}}

@init
_ :: proc() {{
	project.name = "{0:s}"
	build.add_target(&project, &target_debug, run_target)
	build.add_target(&project, &target_release, run_target)
	build.add_target(&project, &target_safe, run_target)
}}

main :: proc() {{
	info: build.Cli_Info
	info.project = &project
	info.default_target = &target_debug
	build.run_cli(info, os.args)
}}
`

generate_oxse_build_string :: proc(project: Project, args: []app.Arg) -> string {
	sb := strings.builder_make()
	project_name := "testname"
	project_source := "test"
	project_exe_name := "testapp"
	fmt.sbprintf(&sb, OXSE_BUILD_STRING, project_name, project_exe_name, project_source)
	return strings.to_string(sb)
}

write_text_file :: proc(name: string, data: string) -> bool {
	return os.write_entire_file(name, transmute([]u8)data)
}

write_oxse_build :: proc(project: Project, args: []app.Arg) -> bool {
	str := generate_oxse_build_string(project, args)
	build.make_directory("./build")
	return write_text_file("./build/build.odin", str)
}

