package main

import "core:math"

main :: proc() {
	r := math.cos(f64(math.PI) / 4.0)

	material_ground := Lambertian{Color{0.8, 0.8, 0.0}}
	material_center := Lambertian{Color{0.1, 0.2, 0.5}}
	material_left := Dielectric{1.50}
	material_bubble := Dielectric{1.00 / 1.50}
	material_right := Metal{Color{0.8, 0.6, 0.2}, 1.0}

	world := Hittable_List{}
	append(&world.objects, make_sphere(Point3{0.0, -100.5, -1.0}, 100.0, material_ground))
	append(&world.objects, make_sphere(Point3{0.0, 0.0, -1.2}, 0.5, material_center))
	append(&world.objects, make_sphere(Point3{-1.0, 0.0, -1.0}, 0.5, material_left))
	append(&world.objects, make_sphere(Point3{-1.0, 0.0, -1.0}, 0.4, material_bubble))
	append(&world.objects, make_sphere(Point3{1.0, 0.0, -1.0}, 0.5, material_right))

	// Camera
	cam := Camera{}

	aspect_ratio := 16.0 / 9.0
	cam.aspect_ratio = aspect_ratio

	image_width := 480
	cam.image_width = image_width

	samples_per_pixel := 100
	cam.samples_per_pixel = samples_per_pixel

	max_depth := 50
	cam.max_depth = max_depth

	v_fov := 20.0
	cam.v_fov = v_fov

	look_from := Point3{-2, 2, 1}
	cam.look_from = look_from
	look_at := Point3{0, 0, -1}
	cam.look_at = look_at
	v_up := Vec3{0, 1, 0}
	cam.v_up = v_up

	defocus_angle := 10.0
	cam.defocus_angle = defocus_angle
	focus_dist := 3.4
	cam.focus_dist = focus_dist

	render(&cam, world)
}
