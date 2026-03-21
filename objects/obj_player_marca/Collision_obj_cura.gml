
if (fase == 0)
{

    if (global.inimigo_marcado == noone)
    {
        global.inimigo_marcado = other.id;
        global.timer_marcado = global.tempo_marcado; 
        
        other.image_blend = c_lime;
        
        cria_particula(x, y, TIPO_PARTICULA.COLETAVEL, 1);
    }
    
    instance_destroy();
}