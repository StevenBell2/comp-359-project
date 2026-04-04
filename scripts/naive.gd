class_name Naive


func get_nearby(entity, radius, entities) -> Array:
	var result = []
	
	for e in entities:
		if e == entity:
			continue
		
		if (entity.position.distance_to(e.position) < (radius + e.radius)):
			result.append(e)
	
	return result
