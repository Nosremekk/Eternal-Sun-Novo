if (global.pause) exit;


roda_estado();

// Aplica zoom e posição da câmera
escala_camera = escala_atual; 
aplica_zoom();
camera_apply_pos();


//temporario
if (global.slow_motion)
{
    // Transiciona para a velocidade lenta
    global.vel_scale = lerp(global.vel_scale, global.slow_scale, global.lerp_slow_scale);
}
else
{
    // Transiciona de volta para a velocidade normal
    global.vel_scale = lerp(global.vel_scale, 1.0, global.lerp_slow_scale);
}


timer_ativacao++;
if (timer_ativacao > delay_ativacao)
{
    ativa_instancias();
    timer_ativacao = 0;
}

