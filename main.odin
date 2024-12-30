package main

import "core:math"
import lg "core:math/linalg"
import "core:math/rand"

main :: proc() {
	r := math.cos(f64(math.PI) / 4.0)

	world := Hittable_List{}
	ground_material := Lambertian{Color{0.5, 0.5, 0.5}}
	append(&world.objects, make_sphere(Point3{0, -1000, 0}, 1000, ground_material))
	for a in -11 ..< 11 {
		for b in -11 ..< 11 {
			choose_mat := rand.float64()
			center := Point3{f64(a) + 0.9 * rand.float64(), 0.2, f64(b) + 0.9 * rand.float64()}

			if lg.length(center - Point3{4, 0.02, 0}) > 0.9 {
				sphere_material: Material

				if choose_mat < 0.8 {
					// diffuse
					albedo := random_vec3() * random_vec3()
					sphere_material = Lambertian{albedo}
					append(&world.objects, make_sphere(center, 0.2, sphere_material))
				} else if (choose_mat < 0.95) {
					// metal
					albedo := random_vec3_range(0.5, 1)
					fuzz := rand.float64_range(0, 0.5)
					sphere_material = Metal{albedo, fuzz}
					append(&world.objects, make_sphere(center, 0.2, sphere_material))
				} else {
					// glass
					sphere_material = Dielectric{1.5}
					append(&world.objects, make_sphere(center, 0.2, sphere_material))
				}
			}
		}
	}

	material1 := Dielectric{1.5}
	append(&world.objects, make_sphere(Point3{0, 1, 0}, 1.0, material1))

	material2 := Lambertian{Color{0.4, 0.2, 0.1}}
	append(&world.objects, make_sphere(Point3{-4, 1, 0}, 1.0, material2))

	material3 := Metal{Color{0.7, 0.6, 0.5}, 0.0}
	append(&world.objects, make_sphere(Point3{4, 1, 0}, 1.0, material3))

	// Camera
	cam := Camera{}

	aspect_ratio := 16.0 / 9.0
	cam.aspect_ratio = aspect_ratio

	image_width := 1200
	cam.image_width = image_width

	samples_per_pixel := 500
	cam.samples_per_pixel = samples_per_pixel

	max_depth := 50
	cam.max_depth = max_depth

	v_fov := 20.0
	cam.v_fov = v_fov

	look_from := Point3{13, 2, 3}
	cam.look_from = look_from
	look_at := Point3{0, 0, 0}
	cam.look_at = look_at
	v_up := Vec3{0, 1, 0}
	cam.v_up = v_up

	defocus_angle := 0.6
	cam.defocus_angle = defocus_angle
	focus_dist := 10.0
	cam.focus_dist = focus_dist

	render(&cam, world)
}
