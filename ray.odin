package main

Ray :: struct {
	origin: Point3,
	dir:    Vec3,
}

origin :: proc(ray: Ray) -> Point3 {
	return ray.origin
}

direction :: proc(ray: Ray) -> Vec3 {
	return ray.dir
}

at :: proc(ray: Ray, t: f64) -> Point3 {
	return ray.origin + (t * ray.dir)
}
