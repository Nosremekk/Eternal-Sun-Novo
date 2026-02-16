if (global.pause)
{
    speed = 0; 
    exit;      
}

if (tempo_pogo > 0)
{
    tempo_pogo -= desconta_timer();
    speed = 0;
    exit;
}

image_angle += rotacao_vel;
var _dest_x = indo ? xstart + move_x : xstart;
var _dest_y = indo ? ystart + move_y : ystart;

var _dist = point_distance(x, y, _dest_x, _dest_y);

if (_dist > vel_move) 
{
    move_towards_point(_dest_x, _dest_y, vel_move);
} 
else 
{
    speed = 0;
    x = _dest_x;
    y = _dest_y;
    indo = !indo;
}