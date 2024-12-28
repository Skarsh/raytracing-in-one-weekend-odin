package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:strings"
import image "vendor:stb/image"

Camera :: struct {
	aspect_ratio:  f64, // Ratio of image_widht / image_height
	image_width:   int, // Rendered image width in pixel count
	image_height:  int, // Rendered image height in pixel count 
	center:        Point3, // Camera center
	pixel00_loc:   Point3, // Location of pixel (0, 0)
	pixel_delta_u: Vec3, // Offset to pixel to the right
	pixel_delta_v: Vec3, // Offset pixel below
}

initialize :: proc(camera: ^Camera) {
	aspect_ratio := camera.aspect_ratio
	image_width := camera.image_width

	// Calculate the image height, and ensure it's at least 1.
	image_height := int(f64(image_width) / aspect_ratio)
	image_height = (image_height < 1) ? 1 : image_height
	camera.image_height = image_height

	center := Point3{0, 0, 0}
	camera.center = center

	// Determine viewport dimensions
	focal_length := 1.0
	viewport_height := 2.0
	viewport_width := viewport_height * (f64(image_width) / f64(image_height))

	// Calculate the vectors across the horizontal and down the vertical viewport edges
	viewport_u := Vec3{viewport_width, 0, 0}
	viewport_v := Vec3{0, -viewport_height, 0}

	// Calculate the horizontal and vertical delta vectors from pixel to pixel
	pixel_delta_u := viewport_u / f64(image_width)
	pixel_delta_v := viewport_v / f64(image_height)
	camera.pixel_delta_u = pixel_delta_u
	camera.pixel_delta_v = pixel_delta_v

	// Calculate the location of the upper left pixel
	viewport_upper_left := center - Vec3{0, 0, focal_length} - viewport_u / 2 - viewport_v / 2

	pixel00_loc := viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v)

	camera.pixel00_loc = pixel00_loc
}


render :: proc(camera: ^Camera, world: Hittable_List) {
	initialize(camera)

	// Allocate buffer for the image
	data := make([]byte, camera.image_width * camera.image_height * 3)
	defer delete(data)

	// Render

	for j in 0 ..< camera.image_height {
		progress := (f64(j) / f64(camera.image_height)) * 100
		fmt.eprintf("\rProgress: %.1f%%", progress)
		os.flush(os.stderr)

		for i in 0 ..< camera.image_width {

			pixel_center :=
				camera.pixel00_loc +
				(f64(i) * camera.pixel_delta_u) +
				(f64(j) * camera.pixel_delta_v)
			ray_direction := pixel_center - camera.center
			ray := Ray{camera.center, ray_direction}

			pixel_color := ray_color(ray, world)

			index := (j * camera.image_width + i) * 3
			write_color(data, index, pixel_color)
		}
	}
	fmt.eprintln("\rProgress: 100.0%")

	// Write the image as PNG
	comp := 3 // RGB components
	stride := camera.image_width * comp

	image_name := "image.png"

	image.write_png(
		strings.clone_to_cstring((image_name)),
		i32(camera.image_width),
		i32(camera.image_height),
		i32(comp),
		raw_data(data),
		i32(stride),
	)

	fmt.printfln("Image successfully written to '%v'", image_name)
}


ray_color :: proc(ray: Ray, world: Hittable_List) -> Color {
	rec := Hit_Record{}
	if hit(world, ray, Interval{0, math.INF_F64}, &rec) {
		return 0.5 * (rec.normal + Color{1, 1, 1})
	}

	unit_direction := unit_vector(ray.dir)
	a := 0.5 * (unit_direction.y + 1.0)
	return (1.0 - a) * Color{1.0, 1.0, 1.0} + a * Color{0.5, 0.7, 1.0}
}

write_color :: proc(buffer: []byte, index: int, pixel_color: Color) {
	r := pixel_color.r
	g := pixel_color.g
	b := pixel_color.b

	// Translate the [0, 1] component values to the byte range [0, 255]
	buffer[index + 0] = byte(255.999 * r)
	buffer[index + 1] = byte(255.999 * g)
	buffer[index + 2] = byte(255.999 * b)
}
