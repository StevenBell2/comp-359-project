extends Node

func find_nearby_naive(balls, detector_pos, radius):

	var results = []

	for i in range(balls.size()):
		var ball = balls[i]

		var dist = ball.position.distance_to(detector_pos)

		if dist < radius:
			results.append(ball)

	return results
