package main

main :: proc() {

	material_ground := Lambertian{Color{0.8, 0.8, 0.0}}
	material_center := Lambertian{Color{0.1, 0.2, 0.5}}
	material_left := make_metal(Color{0.8, 0.8, 0.8}, 0.3)
	material_right := make_metal(Color{0.8, 0.6, 0.2}, 1.0)

	// World
	world := Hittable_List{}
	append(&world.objects, make_sphere(Point3{0, -100.5, -1}, 100, material_ground))
	append(&world.objects, make_sphere(Point3{0, 0, -1.2}, 0.5, material_center))
	append(&world.objects, make_sphere(Point3{-1.0, 0, -1.0}, 0.5, material_left))
	append(&world.objects, make_sphere(Point3{1.0, 0, -1.0}, 0.5, material_right))

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

	render(&cam, world)


}
