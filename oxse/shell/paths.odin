package oxse_shell

import "core:path/filepath"
import "core:fmt"
import "core:build"


oxse_root :: proc() -> (path: string) {
	loc := #location()
	slash_count := 0
	#reverse for ch, i in loc.file_path {
		if ch == '/' || ch == '\\' {
			slash_count += 1
		}
		if slash_count == 3 {
			return loc.file_path[:i]
		}
	}
	panic("Cannot obtain location of oxse\n")
}

oxse_collection :: proc(allocator := context.temp_allocator) -> (collection: build.Collection) {
	return {"oxse", filepath.join({oxse_root(), "oxse"}, allocator)}
}