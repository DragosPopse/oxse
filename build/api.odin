package dragospopse_oxse_build

import "core:path/filepath"
import "core:build"

oxse_root :: proc() -> string {
	return target_debug.root_dir
}

oxse_package :: proc() -> string {
	return filepath.join({oxse_root(), "oxse"}, context.temp_allocator)
}

oxse_runtime :: proc() -> string {
	return filepath.join({oxse_root(), "oxse", "runtime"}, context.temp_allocator)
}

oxse_collection :: proc() -> build.Collection {
	return {"oxse", oxse_package()}
}