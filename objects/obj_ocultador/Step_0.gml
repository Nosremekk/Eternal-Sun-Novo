// Verifica colisão com o Player
if (place_meeting(x, y, obj_player))
{
    fade_out = true;
}

// Lógica de Fade
if (fade_out)
{
    // Desaparece suavemente
    image_alpha = lerp(image_alpha, 0, 0.05);
    
    // Se ficou invisível, se destrói para liberar memória
    if (image_alpha <= 0.01) 
    {
        global.permanentemente_quebrado[$ chave_id] = true;
        instance_destroy();
    }
}