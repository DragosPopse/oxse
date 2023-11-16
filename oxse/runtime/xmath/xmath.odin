package oxse_math

import "core:math"
import "core:math/linalg"

Vec2f :: linalg.Vector2f32
Vec3f :: linalg.Vector3f32
Vec4f :: linalg.Vector4f32

Vec2i :: distinct [2]int
Vec3i :: distinct [3]int

normalize :: linalg.normalize


Col3f :: distinct Vec3f // RGB floating point color
Col4f :: distinct Vec4f // RGBA floating point color

Col3b :: distinct [3]byte
Col4b :: distinct [4]byte

Mat3f :: linalg.Matrix3f32
Mat4f :: linalg.Matrix4f32

Rad :: distinct f32
Deg :: distinct f32

DEG_PER_RAD :: math.DEG_PER_RAD
RAD_PER_DEG :: math.RAD_PER_DEG
PI :: math.PI
TAU :: math.TAU
INFINITY :: math.INF_F32


Angle :: union {
	Rad,
	Deg,
}

Rectf :: struct {
	using pos: Vec2f,
	size: Vec2f,
}

Circle :: struct {
	pos: Vec2f,
	radius: f32,
}

magnitude :: proc {
	vec2f_magnitude,
}

sqr_magnitude :: proc {
	vec2f_sqr_magnitude,
}

minmax_t :: proc(val, min, max: $T) -> (min_result, max_result: T) {
	min_result, max_result = min, max
	if val > max do max_result = val
	if val < min do min_result = val
	return min_result, max_result
}

minmax :: proc {
	rectf_minmax,
	minmax_t,
}

slope :: proc {
	vec2f_slope,
}

minkowski_diff :: proc {
	minkowski_diff_rectf_rectf,
}

// The origin is relative to the size. an origin of {0.5, 0.5} will mean the center of the rectangle, while {1, 1} would mean bottom right
rectf_align_with_relative_origin :: proc(rect: Rectf, origin: Vec2f) -> (result: Rectf) {
	rect := rect
	rect.pos -= origin * rect.size
	return rect
}

// The origin is in local coordinates. An origin of rect.size / 2 would mean the center of the rectangle 
rectf_align_with_local_origin :: proc(rect: Rectf, origin: Vec2f) -> (result: Rectf) {
	rect := rect
	rect.pos -= origin
	return rect
}

// The origin is in world coordinates. Useful for setting the origin based on another object
rectf_align_with_world_origin :: proc(rect: Rectf, origin: Vec2f) -> (result: Rectf) {
	origin := rect.pos - origin // Needs testing. 
	return rectf_align_with_local_origin(rect, origin)
}

rectf_minmax :: proc(rect: Rectf) -> (min, max: Vec2f) {
	return rect.pos, rect.pos + rect.size
}

rectf_minmax_n :: proc(rect: ..Rectf) -> (min, max: Vec2f) {
	unimplemented()
}

// Set new width, keeping the ratio
rectf_ratio_resize_width :: proc(rect: Rectf, width: f32) -> (result: Rectf) {
	ratio := rect.size.y / rect.size.x
	result.pos = rect.pos
	result.size.x = width
	result.size.y = ratio * width
	return result
}

minkowski_diff_rectf_rectf :: proc(a, b: Rectf) -> (result: Rectf) {
	result.pos = a.pos - b.pos - b.size
	result.size = a.size + b.size
	return result
}

rectf_closest_point_on_bounds_to_point :: proc(r: Rectf, point: Vec2f) -> (bounds_point: Vec2f) {
	topleft, bottomright := minmax(r)
	min_dist := abs(point.x - topleft.x)
	bounds_point = {topleft.x, point.y}

	if m := abs(bottomright.x - point.x); m < min_dist {
		min_dist = m
		bounds_point = {bottomright.x, point.y}
	}
	if m := abs(bottomright.y - point.y); m < min_dist {
		min_dist = m
		bounds_point = {point.x, bottomright.y}
	}
	if m := abs(topleft.y - point.y); m < min_dist {
		min_dist = m
		bounds_point = {point.x, topleft.y}
	}

	return bounds_point
}

// Todo(Dragos): Rename this as `rect_origin_point`. The center is just a center
rectf_center :: proc(r: Rectf, origin: Vec2f) -> (res: Vec2f) {
	return r.pos + r.size * origin
}


rectf_origin_from_world_point :: proc(r: Rectf, point: Vec2f) -> (origin: Vec2f) {
	return (point - r.pos) / r.size
}

rectf_origin_from_relative_point :: proc(r: Rectf, point: Vec2f) -> (origin: Vec2f) {
	origin = point / r.size 
	return origin
}

vec2f_magnitude :: proc(v: Vec2f) -> f32 {
	return math.sqrt(v.x * v.x + v.y * v.y)
}

vec2f_sqr_magnitude :: proc(v: Vec2f) -> f32 {
	return v.x * v.x + v.y * v.y
}

vec2f_slope :: proc(a, b: Vec2f) -> f32 {
	return (b.y - a.y) / (b.x - a.x)
}

sin :: math.sin
cos :: math.cos
tan :: math.tan
atan :: math.atan
atan2 :: math.atan2
asin :: math.asin
acos :: math.acos

deg_to_rad :: proc(degrees: Deg) -> Rad {
	return Rad(degrees * RAD_PER_DEG)
}

rad_to_deg :: proc(radians: Rad) -> Deg {
	return Deg(radians * DEG_PER_RAD)
}

angle_deg :: proc(angle: Angle) -> (rad: Deg) {
	switch var in angle {
		case Deg: return var
		case Rad: return #force_inline rad_to_deg(var)
	}
	return
}

angle_rad :: proc(angle: Angle) -> (rad: Rad) {
	switch var in angle {
		case Deg: return #force_inline deg_to_rad(var)
		case Rad: return var
	}
	return
}

direction_to_angle :: proc(direction: Vec2f) -> (angle: Angle) {
	rads := cast(f32)math.atan2(direction.y, direction.x)
	return cast(Rad)rads
}

angle_to_direction :: proc(angle: Angle) -> (direction: Vec2f) {
	rads := cast(f32)angle_rad(angle)
	direction.x = math.cos(rads)
	direction.y = math.sin(rads)
	return direction
}