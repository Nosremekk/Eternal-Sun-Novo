if (mode != "idle")
{
    // --- FADE OUT ---
    if (mode == "fade_out")
    {
        alpha = clamp(alpha + fade_speed, 0, 1);
        
        if (alpha >= 1)
        {
            mode = "trocar"; 
        }
    }
    // --- TROCA DE SALA ---
    else if (mode == "trocar")
        {
           
            if (is_method(acao_callback)) acao_callback();
            
            if (room_exists(room_destino)) room_goto(room_destino);
            
            room_destino = noone;
            acao_callback = undefined;
            
            mode = "fade_in";
        }
    // --- FADE IN ---
    else if (mode == "fade_in")
    {
        alpha = clamp(alpha - fade_speed, 0, 1);
        
        if (alpha <= 0)
        {
            mode = "idle"; 
            // Garante que o player está livre ao terminar a transição
            if (instance_exists(obj_player))
            {
                if (obj_player.estado_atual == obj_player.estado_wait)
                {
                    with (obj_player) troca_estado(estado_idle);
                }
            }
        }
    }
}