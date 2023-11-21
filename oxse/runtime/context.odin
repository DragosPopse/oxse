//+build !wasm32
package oxse_runtime

import "core:runtime"

default_context: runtime.Context

@init
_init_default_context :: proc() {
	default_context = runtime.default_context()
}