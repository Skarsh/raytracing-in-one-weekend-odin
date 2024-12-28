package main

import "core:math"
import lg "core:math/linalg"
import "core:math/rand"

Vec3 :: lg.Vector3f64
Color :: lg.Vector3f64
Point3 :: lg.Vector3f64

unit_vector :: proc(v: Vec3) -> Vec3 {
	return lg.normalize(v)
}

random_unit_vector :: proc() -> Vec3 {
	for {
		p := random_vec3_range(-1, 1)
		lensq := lg.length2(p)
		// NOTE(Thomas): 1e-160 works here due to the precision
		// from using 64-bit floats
		if 1e-160 < lensq && lensq <= 1 {
			return p / math.sqrt(lensq)
		}
	}
}

random_on_hemisphere :: proc(normal: Vec3) -> Vec3 {
	on_unit_sphere := random_unit_vector()
	if lg.dot(on_unit_sphere, normal) > 0.0 {
		// In the same hemisphere as the normal
		return on_unit_sphere
	} else {
		return -on_unit_sphere
	}
}

reflect :: proc(v: Vec3, n: Vec3) -> Vec3 {
	return v - 2 * lg.dot(v, n) * n
}

refract :: proc(uv: Vec3, n: Vec3, etai_over_etat: f64) -> Vec3 {
	cos_theta := math.min(lg.dot(-uv, n), 1.0)
	r_out_perp := etai_over_etat * (uv + cos_theta * n)
	r_out_parallel := -math.sqrt(math.abs(1.0 - lg.length2(r_out_perp))) * n
	return r_out_perp + r_out_parallel
}

random_vec3 :: proc() -> Vec3 {
	return Vec3{rand.float64(), rand.float64(), rand.float64()}
}

random_vec3_range :: proc(min: f64, max: f64) -> Vec3 {
	return Vec3 {
		rand.float64_range(min, max),
		rand.float64_range(min, max),
		rand.float64_range(min, max),
	}
}

near_zero :: proc(vec: Vec3) -> bool {
	s := 1e-8
	return math.abs(vec.x) < s && math.abs(vec.y) < s && math.abs(vec.z) < s
}
