
alpha_atual = 0;
texto_final = get_text(texto_chave);
completo    = false;

// --- VERIFICAÇÃO NO STRUCT DE TUTORIAL ---
alarm[0] = 30;
if (unico_uso)
{
    // Verifica se a chave existe E se é verdadeira dentro de .tutorial
    if (variable_struct_exists(global.eventos.tutorial, save_id) && global.eventos.tutorial[$ save_id] == true)
    {
        completo = true;
        instance_destroy();
    }
}

// Helper de Escala (Mantém consistência com HUD)
get_hud_scale = function()
{
    var _h = display_get_gui_height();
    return max(1, _h / ESCALA_UI); 
}

