if (global.pause) or (instance_exists(obj_dialogo)) exit;

switch(estado_animacao)
{
    case 0: // Entrando
        anim_y = lerp(anim_y, 0, 0.1); 
        alpha  = lerp(alpha, 1, 0.1);  
        
        if (alpha > 0.95) 
        {
            alpha = 1;
            anim_y = 0;
            estado_animacao = 1;
        }
    break;
    
    case 1: // Esperando
        timer_vida -= desconta_timer();
        if (timer_vida <= 0) estado_animacao = 2;
    break;
    
    case 2: // Saindo
        anim_y = lerp(anim_y, 50, 0.1); 
        alpha  = lerp(alpha, 0, 0.1);   
        
        if (alpha < 0.05) instance_destroy();
    break;
}

if (room == rm_menu) instance_destroy();