package main

import "core:fmt"
import lg "core:math/linalg"

Material :: union {
	Lambertian,
	Metal,
}

scatter :: proc(
	material: ^Material,
	ray_in: Ray,
	hit_record: Hit_Record,
	attenuation: ^Color,
	scattered: ^Ray,
) -> bool {
	switch &ty in material {
	case Lambertian:
		return lambertian_scatter(&ty, ray_in, hit_record, attenuation, scattered)
	case Metal:
		return metal_scatter(&ty, ray_in, hit_record, attenuation, scattered)
	}

	return false
}

Lambertian :: struct {
	albedo: Color,
}

lambertian_scatter :: proc(
	lambertian: ^Lambertian,
	ray_in: Ray,
	hit_record: Hit_Record,
	attenuation: ^Color,
	scattered: ^Ray,
) -> bool {
	scatter_direction := hit_record.normal + random_unit_vector()

	// Catch degenerate scatter direction
	if near_zero(scatter_direction) {
		scatter_direction = hit_record.normal
	}

	scattered^ = Ray{hit_record.point, scatter_direction}
	attenuation^ = lambertian.albedo

	return true
}

Metal :: struct {
	albedo: Color,
	fuzz:   f64,
}

make_metal :: proc(albedo: Color, fuzz: f64) -> Metal {
	return Metal{albedo, fuzz < 1 ? fuzz : 1}
}

metal_scatter :: proc(
	metal: ^Metal,
	ray_in: Ray,
	hit_record: Hit_Record,
	attenuation: ^Color,
	scattered: ^Ray,
) -> bool {
	reflected := reflect(ray_in.dir, hit_record.normal)
	reflected = unit_vector(reflected) + (metal.fuzz * random_unit_vector())
	scattered^ = Ray{hit_record.point, reflected}
	attenuation^ = metal.albedo
	return lg.dot(scattered.dir, hit_record.normal) > 0
}
