package main

import "core:math"

Interval :: struct {
	min: f64,
	max: f64,
}

interval_size :: proc(interval: Interval) -> f64 {
	return interval.max - interval.min
}

interval_contains :: proc(interval: Interval, x: f64) -> bool {
	return interval.min <= x && x <= interval.max
}

interval_surrounds :: proc(interval: Interval, x: f64) -> bool {
	return interval.min < x && x < interval.max
}

interval_clamp :: proc(interval: Interval, x: f64) -> f64 {
	if x < interval.min {
		return interval.min
	}

	if x > interval.max {
		return interval.max
	}

	return x
}

EMPTY_INTERVAL :: Interval{math.INF_F64, math.NEG_INF_F64}
UNIVERSE_INTERVAL :: Interval{math.NEG_INF_F64, math.INF_F64}
