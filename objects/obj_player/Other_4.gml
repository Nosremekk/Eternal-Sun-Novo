// Garante que o controlador existe (Seu código original de luz)
if (instance_exists(obj_controla_luz))
{
    minha_luz = new BulbLight(obj_controla_luz.renderer, spr_luz, 0, x, y); 
    minha_luz.blend = make_color_rgb(255, 240, 200);
    minha_luz.castShadows = true; 
    minha_luz.yscale = 2;
    minha_luz.xscale = 2;
    minha_luz.intensity = 0.8; 
    minha_luz.penumbraSize = 80;
}


if (variable_global_exists("player_nasce_invencivel") and global.player_nasce_invencivel)
{
    inv = true;
    inv_timer = 1; 
    blink(); 
    global.player_nasce_invencivel = false; 
}


if (place_meeting(x, y + 1, colisor))
{
    safe_x = x;
    safe_y = y;
    timer_solo_seguro = tempo_para_estabilizar;
}


if (variable_global_exists("respawn_anim") and global.respawn_anim)
{
    // Força o estado de levantar
    inicia_estado(estado_wakeup); 

    global.respawn_anim = false;
}