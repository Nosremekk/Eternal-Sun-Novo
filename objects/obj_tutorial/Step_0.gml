if (global.pause) exit;

if (!completo)
{
    if (instance_exists(obj_player))
    {
        var _dist = point_distance(x, y, obj_player.x, obj_player.y);
        
        // Fade In/Out
        var _alvo_alpha = (_dist < raio_ativacao) ? 1 : 0;
        alpha_atual = lerp(alpha_atual, _alvo_alpha, 0.1);
        
        // Lógica de Completar
        if (unico_uso && alpha_atual > 0.8)
        {
            // Verifica input
            if (InputCheck(verbo)) 
            {
                completo = true;
                
                // Salva
                global.eventos.tutorial[$ save_id] = true;
                

                
                efeito_sonoro(sfx_heal, 80, 0.1);
            }
        }
    }
}
// Lógica de quando JÁ completou (Animação de saída)
else 
{
    // Força o alpha a descer
    alpha_atual = lerp(alpha_atual, 0, 0.15);
    
    // Destrói quando ficar invisível
    if (alpha_atual <= 0.01) 
    {
        instance_destroy();
    }
}