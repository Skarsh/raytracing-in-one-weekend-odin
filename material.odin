package main

import "core:math"
import lg "core:math/linalg"

Material :: union {
	Dielectric,
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
	case Dielectric:
		return dielectric_scatter(&ty, ray_in, hit_record, attenuation, scattered)
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

Dielectric :: struct {
	// Refractive index in vacuum or air, or the ratio of the material's refractive index
	// over the refractive index of the enclosing media
	refraction_index: f64,
}

dielectric_scatter :: proc(
	dielectric: ^Dielectric,
	ray_in: Ray,
	hit_record: Hit_Record,
	attenuation: ^Color,
	scattered: ^Ray,
) -> bool {

	attenuation^ = Color{1.0, 1.0, 1.0}
	ri := hit_record.front_face ? (1.0 / dielectric.refraction_index) : dielectric.refraction_index

	unit_direction := unit_vector(ray_in.dir)

	cos_theta := math.min(lg.dot(-unit_direction, hit_record.normal), 1.0)
	sin_theta := math.sqrt(1.0 - cos_theta * cos_theta)

	cannot_refract := ri * sin_theta > 1.0
	direction := Vec3{}

	if cannot_refract {
		direction = reflect(unit_direction, hit_record.normal)
	} else {
		direction = refract(unit_direction, hit_record.normal, ri)
	}

	scattered^ = Ray{hit_record.point, direction}

	return true
}

reflectance :: proc(cosine: f64, refraction_index: f64) -> f64 {
	// Use Schlick's approximation for reflectance
	r0 := (1 - refraction_index) / (1 + refraction_index)
	r0 = r0 * r0
	return r0 + (1 - r0) * math.pow((1 - cosine), 5)
}
