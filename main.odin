package main

main :: proc() {

	// World
	world := Hittable_List{}
	append(&world.objects, make_sphere(Point3{0, 0, -1}, 0.5))
	append(&world.objects, make_sphere(Point3{0, -100.5, -1}, 100))

	// Camera
	cam := Camera{}

	aspect_ratio := 16.0 / 9.0
	cam.aspect_ratio = aspect_ratio

	image_width := 400
	cam.image_width = image_width

	samples_per_pixel := 100
	cam.samples_per_pixel = samples_per_pixel

	max_depth := 50
	cam.max_depth = max_depth

	render(&cam, world)


}
