//Só interage se estiver indo
if (fase == 0) and (other.vida_atual > 0)
{
    //Sem marca atual
    if (global.inimigo_marcado == noone)
    {
        global.inimigo_marcado = other.id;
        global.timer_marcado = global.tempo_marcado;
        
        global.marca_pos_x = other.x + other.sprite_width/2;
        global.marca_pos_y = other.y - (other.sprite_height - other.sprite_height/2); 
        global.marca_room  = room;
        
        //Feedback visual
        other.image_blend = c_red;
        
        cria_particula(x, y, TIPO_PARTICULA.COLETAVEL, 1);
    }
    
    //Destroi ao impactar
    instance_destroy();
}