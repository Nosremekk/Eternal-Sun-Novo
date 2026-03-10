with (obj_spawn_point)
{
    if (distance_to_object(other) < 400) 
    {
        array_push(other.spawn_points, {x: x, y: y});
    }
}