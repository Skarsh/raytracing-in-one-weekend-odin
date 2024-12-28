package main

import lg "core:math/linalg"

Hit_Record :: struct {
	point:      Point3,
	normal:     Vec3,
	// TODO(Thomas): Make the material a pointer / handle?
	mat:        Material,
	t:          f64,
	front_face: bool,
}

set_face_normal :: proc(hit_record: ^Hit_Record, ray: Ray, outward_normal: Vec3) {
	// Sets the hit record normal vector
	// NOTE: the parameter `outward_normal` is assumed to have unit length
	hit_record.front_face = lg.dot(ray.dir, outward_normal) < 0
	hit_record.normal = hit_record.front_face ? outward_normal : -outward_normal
}

Hittable :: union {
	Sphere,
}

Hittable_List :: struct {
	objects: [dynamic]Hittable,
}

hit :: proc(
	hittables_list: Hittable_List,
	ray: Ray,
	ray_t: Interval,
	hit_record: ^Hit_Record,
) -> bool {

	temp_rec := Hit_Record{}
	hit_anything := false
	closest_so_far := ray_t.max

	for hittable in hittables_list.objects {
		switch ty in hittable {
		case Sphere:
			if sphere_hit(ty, ray, Interval{ray_t.min, closest_so_far}, &temp_rec) {
				hit_anything = true
				closest_so_far = temp_rec.t
				hit_record^ = temp_rec
			}
		}
	}

	return hit_anything
}
