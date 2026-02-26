if (global.pause) exit;
    
event_inherited()

// Gira o sprite
image_angle -= 25;

if (!voltando)
{
    // ==========================================
    // FASE 1: INDO ATÉ O ALVO
    // ==========================================
    if (alvo != noone and instance_exists(alvo))
        {
            // Acha o centro do inimigo em vez do pé dele
            var _alvo_centro_y = (alvo.bbox_top + alvo.bbox_bottom) / 2;
            var _dir_alvo = point_direction(x, y, alvo.x, _alvo_centro_y); 
            
            var _diferenca = angle_difference(_dir_alvo, direction);
            direction += _diferenca * 0.15;
        }
    
    x += lengthdir_x(vel, direction);
    y += lengthdir_y(vel, direction);
    
    timer_ida += desconta_timer() ;
    
    // Bateu no alvo principal? Faz a faísca e COMEÇA A VOLTAR
    if (alvo != noone and instance_exists(alvo) and place_meeting(x, y, alvo))
    {
        cria_particula(x, y, TIPO_PARTICULA.FAISCA, 5); // Removido o obj_player.
        voltando = true;
    }
    // Bateu na parede? Volta
    else if (place_meeting(x, y, obj_colisor))
    {
        cria_particula(x, y, TIPO_PARTICULA.FAISCA, 5);
        voltando = true;
    }
    // O alvo fugiu demais ou sumiu? Volta
    else if (timer_ida >= limite_ida)
    {
        voltando = true;
    }
}
else
{
    // ==========================================
    // FASE 2: VOLTANDO PARA O PLAYER
    // ==========================================
    if (instance_exists(pai))
    {
        // Acha o centro do player para voltar perfeitamente para a mão dele
        var _pai_centro_y = (pai.bbox_top + pai.bbox_bottom) / 2;
        var _dir_pai = point_direction(x, y, pai.x, _pai_centro_y); 
        
        var _diferenca = angle_difference(_dir_pai, direction);
        direction += _diferenca * 0.2;
        
        // Volta um pouco mais rápido para não deixar o jogador esperando
        var _vel_volta = vel * 1.3; 
        x += lengthdir_x(_vel_volta, direction);
        y += lengthdir_y(_vel_volta, direction);
        
        // Pegou o bumerangue de volta! (Aí sim ele se destrói)
        if (place_meeting(x, y, pai))
        {
            instance_destroy();
        }
    }
    else
    {
        // Se o player morrer enquanto o bumerangue estava voando
        cria_particula(x, y, TIPO_PARTICULA.POEIRA_PULO, 3);
        instance_destroy();
    }
}