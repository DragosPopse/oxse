package oxse_gfx

API :: enum {
	software,
	glcore46,
	webgl2,
	d3d11,
}

Renderer_VTable :: struct {
	draw: proc(base_elem, elem_count, instance_count: int)
}

Renderer_Init :: struct {
	api: API,
}

Renderer :: struct {
	api: API,
	using vtable: Renderer_VTable,
	api_data: rawptr,
}

create_renderer :: proc() {
	
}

Surface :: struct {

}

Pixel_Format :: enum {
	Invalid,
	A8,
	RGBA8,
	RGB8,
	DEPTH24_STENCIL8,
}

Texture_Type :: enum {
	Invalid,
	T1D,
	T2D,
	T3D,
	Cubemap,
}

Texture_Scale_Mode :: enum {
	Nearest,
	Linear,
}

Texture :: struct {

	api_data: rawptr,
}

