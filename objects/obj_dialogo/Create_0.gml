
dialogo = noone;   
indice  = 1;        
pag     = 0;        
player  = noone;    
escala_caixa = 0;   
alpha_nome   = 0;
timer_nome   = 0;
duracao_nome = 3;
status_animacao = 0;

// Trava Player/HUD
if (instance_exists(obj_hud)) obj_hud.talk = true;

libera_player = function()
{
    if (instance_exists(player)) with(player) troca_estado(estado_idle);
    if (instance_exists(obj_hud)) obj_hud.talk = false;
    instance_destroy();
}

desenha_dialogo = function()
{
    if (!is_struct(dialogo)) { instance_destroy(); exit; }

    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    
    // --- 1. APLICAÇÃO DA ESCALA (Igual ao HUD) ---
    var _s = max(1, _gui_h / ESCALA_UI); 

    // Dimensões da Caixa (Mantendo proporção visual agradável)
    var _box_w = 1100 * _s;
    var _box_h = 220 * _s;
    
    // Limita a largura se a tela for muito estreita (Mobile/Vertical)
    if (_box_w > _gui_w * 0.95) _box_w = _gui_w * 0.95;

    // Background Escuro (Dimmer)
    var _alpha_bg = 0.35 * escala_caixa;
    if (escala_caixa > 0.1) 
    {
        draw_set_color(c_black);
        draw_set_alpha(_alpha_bg); 
        draw_rectangle(0, 0, _gui_w, _gui_h, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }

    // Animação Pop-up (Lerp Suave)
    if (status_animacao == 0) 
    {
        escala_caixa = lerp(escala_caixa, 1.0, 0.1);
    }
    else 
    {
        escala_caixa = lerp(escala_caixa, 0.0, 0.15); 
        if (escala_caixa < 0.05) { libera_player(); exit; }
    }

    // --- 2. DESENHO DA CAIXA (CENTRALIZADA EM BAIXO) ---
    var _draw_w = _box_w * escala_caixa;
    var _draw_h = _box_h * escala_caixa;
    
    var _x = (_gui_w / 2) - (_draw_w / 2);
    // Margem inferior dinâmica baseada na escala
    var _y = _gui_h - _draw_h - (50 * _s); 

    // IMPORTANTE: O sprite 'spr_dialog_box' deve ter 9-Slice ativado no editor de sprites!
    draw_sprite_stretched(spr_dialog_box, 0, _x, _y, _draw_w, _draw_h);

    if (escala_caixa < 0.9) exit;

    // --- 3. TEXTOS ---
    draw_set_font(dialogo.fonte);
    draw_set_halign(fa_left); draw_set_valign(fa_top);

    var _txt_array = dialogo.texto;
    var _txt_full  = _txt_array[pag];
    var _txt_len   = string_length(_txt_full);
    
    // Config Som
    var _som = snd_test; 
    if (variable_struct_exists(dialogo, "som"))
    {
        if (is_array(dialogo.som)) _som = (pag < array_length(dialogo.som)) ? dialogo.som[pag] : snd_test;
        else if (dialogo.som != noone) _som = dialogo.som;
    }

    // Margens Internas (Padding) Escaladas
    var _pad_x = 30 * _s; 
    var _pad_y = 20 * _s; 
    
    var _txt_shown = string_copy(_txt_full, 1, floor(indice));
    var _largura_texto_max = _draw_w - (_pad_x * 2);
    var _sep = string_height("M") * 1.2;

    // AQUI ESTÁ A CORREÇÃO PRINCIPAL: Text Transformed
    // Isso garante que a fonte cresça junto com a caixa em resoluções altas
    draw_text_ext_transformed(_x + _pad_x, _y + _pad_y, _txt_shown, _sep, _largura_texto_max, _s, _s, 0);
    
    // Cursor "Aguardando"
    if (indice >= _txt_len)
    {
        var _bob_y = sin(current_time / 200) * (4 * _s);
        // Ajusta posição do cursor baseado na escala
        draw_sprite_ext(spr_cursor_dialogo, 0, _x + _draw_w - _pad_x, _y + _draw_h - _pad_y + _bob_y, _s, _s, 0, c_white, 1);
    }

    // --- 4. INPUTS ---
    if (InputPressed(INPUT_VERB.JUMP) or InputPressed(INPUT_VERB.ATTACK)) 
    {
        // Pula Texto
        if (indice < _txt_len) 
        {
            indice = _txt_len; 
        } 
        // Próxima Página
        else if (pag < array_length(_txt_array) - 1) 
        {
            audio_stop_sound(_som); 
            pag++;
            indice = 1;
        } 
        // Fecha Diálogo
        else 
        {
            audio_stop_sound(_som);
            if (variable_struct_exists(dialogo, "callback") and dialogo.callback != undefined) 
            {
                dialogo.callback(); 
            }
            status_animacao = 1; 
        }
    }

    // Avanço do Índice
    if (indice < _txt_len) 
    {
        indice += dialogo.txt_vel;
        if ((floor(indice) % 3 == 0) and !audio_is_playing(_som)) efeito_sonoro(_som, 50, 0.1); 
    }

    // Nome NPC (Topo Direito - Conforme sua função anterior)
    if (variable_struct_exists(dialogo, "nome")) 
    {
        var _n = dialogo.nome;
        if (_n != undefined and _n != "")
        {
            timer_nome += delta_time / 1000000; 
            
            if (timer_nome < duracao_nome and status_animacao == 0) alpha_nome = min(alpha_nome + 0.03, 1);
            else alpha_nome = max(alpha_nome - 0.05, 0); 
            
            // Chama a função que criamos no passo anterior
            desenha_nome_npc(_n, alpha_nome);
        }
    }

    draw_set_font(-1);
}