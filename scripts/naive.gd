class_name Naive


func get_nearby(entity, _radius, entities) -> Array:
    var result: Array = []

    for e in entities:
        if e == entity:
            continue

        result.append(e)

    return result