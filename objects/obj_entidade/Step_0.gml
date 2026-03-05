escala_x = lerp(escala_x, 1, 0.15);
escala_y = lerp(escala_y, 1, 0.15);

move_and_collide(velh * global.vel_scale, velv * global.vel_scale, colisor);
depth = -bbox_bottom;
if (minha_luz != undefined)
{
    minha_luz.x = x;
    minha_luz.y = y - sprite_height/2;
}

