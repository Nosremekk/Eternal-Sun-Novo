if (global.pause) 
{
    speed = 0;
    exit;
}
else if (!global.pause) and (speed == 0) speed = vel;
//Segurança
if (!instance_exists(pai))
{
    instance_destroy();
    exit;
}

//Indo
if (fase == 0)
{
    dist_percorrida += speed;
    
    //Prevendo colisão a frente (funciona em qualquer angulo)
    var _lx = lengthdir_x(speed, direction);
    var _ly = lengthdir_y(speed, direction);
    
    //Bateu na parede ou limite
    if (dist_percorrida >= max_dist) or (place_meeting(x + _lx, y + _ly, pai.colisor))
    {
        fase = 1;
        speed = 0;
    }
}
//Voltando
else 
{
    var _alvo_y = pai.y - (pai.sprite_height / 2);
    var _dir = point_direction(x, y, pai.x, _alvo_y);
    
    speed = lerp(speed, vel + 6, 0.1);
    direction = _dir;
        
    //Chegou no player
    if (place_meeting(x, y, pai)) 
    {
        instance_destroy();
    }
}


image_angle += 25;