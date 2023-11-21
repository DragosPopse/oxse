package main

import "core:os"
import "core:encoding/json"
import "core:build"

Project :: struct {
	name: string,
}

Project_Json :: struct {
	name: string,
}

OXSE_PROJECT_JSON_PATH :: "./.oxse/project.json"

project_to_json :: proc(project: Project) -> (project_json: Project_Json) {
	project_json.name = project.name
	return project_json
}

json_to_project :: proc(project_json: Project_Json) -> (project: Project) {
	project.name = project_json.name
	return project
}

open_project :: proc() -> (project: Project, ok: bool) {
	project_data: []u8
	project_data, ok = os.read_entire_file(OXSE_PROJECT_JSON_PATH)
	project_json: Project_Json
	unmarshal_err := json.unmarshal(project_data, &project_json)
	ok = unmarshal_err == nil
	project = json_to_project(project_json)
	return project, ok
}

project_initialized :: proc() -> bool {
	return os.is_dir("./.oxse") && os.is_file(OXSE_PROJECT_JSON_PATH)
}

save_project :: proc(project: Project) -> bool {
	project_json := project_to_json(project)
	marshal_opts: json.Marshal_Options
	marshal_opts.pretty = true
	data, err := json.marshal(project_json, marshal_opts)
	build.make_directory("./oxse")
	if err != nil do return false
	return os.write_entire_file(OXSE_PROJECT_JSON_PATH, data)
}