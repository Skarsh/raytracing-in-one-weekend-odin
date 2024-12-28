package main

import lg "core:math/linalg"

Vec3 :: lg.Vector3f64
Color :: lg.Vector3f64
Point3 :: lg.Vector3f64

unit_vector :: proc(v: Vec3) -> Vec3 {
	return lg.normalize(v)
}

main :: proc() {

	// World
	world := Hittable_List{}
	append(&world.objects, make_sphere(Point3{0, 0, -1}, 0.5))
	append(&world.objects, make_sphere(Point3{0, -100.5, -1}, 100))

	// Camera
	cam := Camera{}

	aspect_ratio := 16.0 / 9.0
	cam.aspect_ratio = aspect_ratio

	image_width := 3072
	cam.image_width = image_width

	render(&cam, world)


}
