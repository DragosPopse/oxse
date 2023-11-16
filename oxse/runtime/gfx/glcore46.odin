package oxse_gfx

import "api/gl"
import xm "../xmath"

import sdl "vendor:sdl2" // TODO(Dragos): Remove this from here



GLCORE46_Texture :: struct {
	object: gl.uint,
}

GLCORE46_Buffer :: struct {

}

glcore46_init :: proc() {
	gl.load_gl(sdl.gl_set_proc_address)
}

glcore46_texture_init :: proc(texture: ^GLCORE46_Texture, data: []byte) {

}