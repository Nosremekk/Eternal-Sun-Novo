if (global.pause)
{
    if (speed != 0) 
    {
        velh = hspeed;
        velv = vspeed;
        hspeed = 0;
        vspeed = 0;
        if (grav) gravity = 0;
    }
    exit; 
}
else 
{
    if (velh != 0 or velv != 0)
    {
        hspeed = velh * global.vel_scale;
        vspeed = velv * global.vel_scale;
    }

    if (grav) gravity = 0.3 * global.vel_scale;
}   

image_angle += 5 * global.vel_scale;


var _player = instance_place(x, y, obj_player);
if (_player and !toquei_player)
{
    if (!_player.inv) 
    {
        _player.hurt_id = id; 
        _player.recebe_dano(1); 
        
        toquei_player = true;
        instance_destroy();
    }
}


if (place_meeting(x, y, obj_colisor) or place_meeting(x, y, layer_tilemap_get_id("Colisao_Tiles")))
{
    cria_particula(x, y, TIPO_PARTICULA.FAISCA, 3);
    instance_destroy();
    efeito_sonoro_3d(sfx_shot_destroy, x, y, 50, 200, 40, 0.2);
}