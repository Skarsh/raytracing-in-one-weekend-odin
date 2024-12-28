package main

import "core:fmt"
import "core:math"
import lg "core:math/linalg"

Sphere :: struct {
	center: Point3,
	radius: f64,
	mat:    Material,
}

make_sphere :: proc(center: Point3, radius: f64, material: Material) -> Sphere {
	return Sphere{center, math.max(0, radius), material}
}

sphere_hit :: proc(sphere: Sphere, ray: Ray, ray_t: Interval, hit_record: ^Hit_Record) -> bool {
	oc := sphere.center - ray.origin
	a := lg.length2(ray.dir)
	h := lg.dot(ray.dir, oc)
	c := lg.length2(oc) - sphere.radius * sphere.radius
	discriminant := h * h - a * c
	if discriminant < 0 {
		return false
	}

	sqrtd := math.sqrt(discriminant)

	// Find the nearest root that lies in the acceptable range
	root := (h - sqrtd) / a
	if !interval_surrounds(ray_t, root) {
		root = (h + sqrtd) / a
		if !interval_surrounds(ray_t, root) {
			return false
		}
	}

	hit_record.t = root
	hit_record.point = at(ray, hit_record.t)
	outward_normal := (hit_record.point - sphere.center) / sphere.radius
	set_face_normal(hit_record, ray, outward_normal)
	hit_record.mat = sphere.mat

	return true
}
