package main

import "core:fmt"
import "core:math"
import lg "core:math/linalg"
import "core:math/rand"
import "core:os"
import "core:strings"
import image "vendor:stb/image"

Camera :: struct {
	aspect_ratio:        f64, // Ratio of image_widht / image_height
	image_width:         int, // Rendered image width in pixel count
	image_height:        int, // Rendered image height in pixel count 
	center:              Point3, // Camera center
	pixel00_loc:         Point3, // Location of pixel (0, 0)
	pixel_delta_u:       Vec3, // Offset to pixel to the right
	pixel_delta_v:       Vec3, // Offset pixel below
	samples_per_pixel:   int, // Count of random samples for each pixel
	pixel_samples_scale: f64, // Color scale factor for a sum of pixel samples
	max_depth:           int, // Maximum number of ray bounces into the scene
	v_fov:               f64, // Vertical view angle (field of view)
	look_from:           Point3, // Point the camera is looking from
	look_at:             Point3, // Point the camera is looking to
	v_up:                Vec3, // Camera-relative "up" direction
	u:                   Vec3, // Unit vector pointing in camera right direction
	v:                   Vec3, // Basis vector pointing in camera up direction
	w:                   Vec3, // Basis vector pointing in the opposite view direction
}

initialize :: proc(camera: ^Camera) {
	aspect_ratio := camera.aspect_ratio
	image_width := camera.image_width

	camera.pixel_samples_scale = f64(1.0) / f64(camera.samples_per_pixel)
	fmt.println("pixel_samples_scale", camera.pixel_samples_scale)

	// Calculate the image height, and ensure it's at least 1.
	image_height := int(f64(image_width) / aspect_ratio)
	image_height = (image_height < 1) ? 1 : image_height
	camera.image_height = image_height

	center := camera.look_from
	camera.center = center

	// Determine viewport dimensions
	focal_length := lg.length(camera.look_from - camera.look_at)
	thetha := math.to_radians(camera.v_fov)
	h := math.tan(thetha / 2)
	viewport_height := 2 * h * focal_length
	viewport_width := viewport_height * (f64(image_width) / f64(image_height))

	// Calculate the u,v,w unit basis vectors for the camera coordinate frame
	camera.w = unit_vector(camera.look_from - camera.look_at)
	camera.u = unit_vector(lg.cross(camera.v_up, camera.w))
	camera.v = lg.cross(camera.w, camera.u)

	// Calculate the vectors across the horizontal and down the vertical viewport edges
	viewport_u := viewport_width * camera.u // Vector across viewport horizontal edge
	viewport_v := viewport_height * -camera.v // Vector down viewport vertical edge

	// Calculate the horizontal and vertical delta vectors from pixel to pixel
	pixel_delta_u := viewport_u / f64(image_width)
	pixel_delta_v := viewport_v / f64(image_height)
	camera.pixel_delta_u = pixel_delta_u
	camera.pixel_delta_v = pixel_delta_v

	// Calculate the location of the upper left pixel
	viewport_upper_left := center - (focal_length * camera.w) - viewport_u / 2 - viewport_v / 2

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

			pixel_color := Color{0, 0, 0}
			for _ in 0 ..< camera.samples_per_pixel {
				ray := get_ray(camera^, i, j)
				pixel_color += ray_color(ray, camera.max_depth, world)
			}

			index := (j * camera.image_width + i) * 3
			write_color(data, index, camera.pixel_samples_scale * pixel_color)
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

get_ray :: proc(camera: Camera, i: int, j: int) -> Ray {
	// Construct a camera ray originating from the origin and directed at randomly sampled
	// point around the pixel location (i, j)
	offset := sample_square()
	pixel_sample :=
		camera.pixel00_loc +
		((f64(i) + offset.x) * camera.pixel_delta_u) +
		((f64(j) + offset.y) * camera.pixel_delta_v)

	ray_origin := camera.center
	ray_direction := pixel_sample - ray_origin

	return Ray{ray_origin, ray_direction}
}

sample_square :: proc() -> Vec3 {
	// Returns the vector to a random point in the [-0.5, -0.5] - [0.5, 0.5] unit square
	return Vec3{rand.float64() - 0.5, rand.float64() - 0.5, 0}
}

ray_color :: proc(ray: Ray, depth: int, world: Hittable_List) -> Color {
	// If we've exceeded the ray bounce limit, no more light is gathered
	if depth <= 0 {
		return Color{0, 0, 0}
	}

	rec := Hit_Record{}

	if hit(world, ray, Interval{0.001, math.INF_F64}, &rec) {
		scattered := Ray{}
		attenuation := Color{}
		if scatter(&rec.mat, ray, rec, &attenuation, &scattered) {
			return attenuation * ray_color(scattered, depth - 1, world)
		}
		return Color{0, 0, 0}
	}

	unit_direction := unit_vector(ray.dir)
	a := 0.5 * (unit_direction.y + 1.0)
	return (1.0 - a) * Color{1.0, 1.0, 1.0} + a * Color{0.5, 0.7, 1.0}
}

write_color :: proc(buffer: []byte, index: int, pixel_color: Color) {
	r := pixel_color.r
	g := pixel_color.g
	b := pixel_color.b

	// Apply a linear to gamma transform  for gamma 2
	r = linear_to_gamma(r)
	g = linear_to_gamma(g)
	b = linear_to_gamma(b)

	// Translate the [0, 1] component values to the byte range [0, 255]
	intensity :: Interval{0.000, 0.999}
	buffer[index + 0] = byte(256 * interval_clamp(intensity, r))
	buffer[index + 1] = byte(256 * interval_clamp(intensity, g))
	buffer[index + 2] = byte(256 * interval_clamp(intensity, b))
}

linear_to_gamma :: proc(linear_component: f64) -> f64 {
	if linear_component > 0 {
		return math.sqrt(linear_component)
	}

	return 0
}
