// --- VARIÁVEIS DE CONTROLE ---
tempo_cair_sec   = 1.0; 
tempo_voltar_sec = 3.0;
timer = 0;

start_x = x;
start_y = y;
shake_force = 1;

// Salva o sprite original para restaurar depois
meu_sprite_original = sprite_index; 

// --- DEFINIÇÃO DOS ESTADOS ---

// 1. NORMAL
estado_normal = new estado();
estado_normal.inicia = function()
{
    sprite_index = meu_sprite_original;
    mask_index   = meu_sprite_original; 
    visible      = true;
    image_blend  = c_white;
    
    x = start_x;
    y = start_y;
    shake_x = 0;
    shake_y = 0;
    
    // Liga a Sombra
    if (variable_instance_exists(id, "meu_oclusor") && is_struct(meu_oclusor))
    {
        meu_oclusor.visible = true;
        meu_oclusor.x = x;
        meu_oclusor.y = y;
    }
}
estado_normal.roda = function()
{
    if (instance_exists(obj_player))
    {
        var _p = obj_player;
        if (place_meeting(x, y - 2, _p) && _p.bbox_bottom <= bbox_top + 2 && _p.velv >= 0)
        {
            troca_estado(estado_tremendo);
        }
    }
}

// 2. TREMENDO
estado_tremendo = new estado();
estado_tremendo.inicia = function()
{
    timer = tempo_cair_sec;
    image_blend = c_red; 
}
estado_tremendo.roda = function()
{
    timer -= desconta_timer();
    
    // Tremor visual
    shake_x = choose(-shake_force, shake_force);
    shake_y = choose(-shake_force, shake_force);
    
    // Objeto físico parado, sombra acompanha o tremor
    x = start_x;
    y = start_y;
    
    if (variable_instance_exists(id, "meu_oclusor") && is_struct(meu_oclusor))
    {
        meu_oclusor.x = start_x + shake_x;
        meu_oclusor.y = start_y + shake_y;
    }

    if (timer <= 0)
    {
        troca_estado(estado_invisivel);
    }
}

// 3. INVISÍVEL (COM CHECAGEM DE SEGURANÇA)
estado_invisivel = new estado();
estado_invisivel.inicia = function()
{
    sprite_index = -1; // Visual off
    mask_index   = -1; // Colisão off
    timer = tempo_voltar_sec;
    
    // Sombra off
    if (variable_instance_exists(id, "meu_oclusor") && is_struct(meu_oclusor))
    {
        meu_oclusor.visible = false;
    }
    
    x = start_x;
    y = start_y;
    shake_x = 0;
    shake_y = 0;
}
estado_invisivel.roda = function()
{
    // Só desconta o timer se ele ainda for maior que zero
    if (timer > 0) timer -= desconta_timer();
    
    // Se o tempo acabou, tentamos voltar
    if (timer <= 0)
    {
        // --- O PULO DO GATO ---
        // 1. Ativa a colisão temporariamente (invisível pro jogador, mas visível pra engine)
        mask_index = meu_sprite_original;
        
        // 2. Verifica se o player está ocupando esse espaço
        if (place_meeting(x, y, obj_player))
        {
            // TEM GENTE AQUI! PERIGO!
            // Desativa a colisão imediatamente para não prender o player
            mask_index = -1;
            
            // Não trocamos de estado. 
            // O código vai rodar de novo no próximo frame (timer continua <= 0),
            // testando infinitamente até o player sair da frente.
        }
        else
        {
            // CAMINHO LIVRE!
            // Pode voltar ao normal.
            // (A máscara já está ativa da linha acima, então é seguro trocar)
            troca_estado(estado_normal);
        }
    }
}

inicia_estado(estado_normal);