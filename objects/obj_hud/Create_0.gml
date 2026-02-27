/// Create Event
depth = -9000;

// Variáveis de Estado
mostra_hud = true;
hud_alpha  = 0;
talk = false;
morto = false;

// --- NOVO: MULTIPLICADOR DE ESCALA (Porcentagem) ---
// 1.0 = 100% (Tamanho Original). 0.7 = 70% do tamanho. Ajuste como preferir!
hud_escala_mult = 0.7; 

// Refs globais (Agora pega direto da global)
vida_anterior = global.vida_atual;
combo_anterior = 0;

// Visuais
life_shake       = 0;
life_flash       = 0;
heal_flash       = 0;
avatar_scale_x   = 1;
avatar_scale_y   = 1;
heart_pop_index  = -1;
heart_pop_scale  = 0;
combo_flash      = 0;
hud_shake_x      = 0;
hud_shake_y      = 0;
combo_display    = 1;

// Marca
mark_scale = 1;
mark_flash = 0;
mark_active_prev = false;

//Dinheiro
dinheiro_alvo    = global.dinheiro; // O valor real
dinheiro_exibido = global.dinheiro; // O valor falso que "roda" até alcançar o alvo
timer_dinheiro   = 0;
alpha_dinheiro   = 0;
pop_moeda        = 1; // Multiplicador para o efeitinho de pular
// Area Vars
area_display_nome  = "";
area_display_alpha = 0;
area_timer         = 0;
area_duracao       = 3;
area_mini_nome     = "";
area_mini_alpha    = 0;
area_mini_timer    = 0;
area_mini_duracao  = 4;
area_mini_slide    = 0;


// Check inicial de area
var _nome_sala = get_nome_area(room);
if (!is_undefined(_nome_sala))
{
    if (_nome_sala != global.area_atual_memoria)
    {
        global.area_atual_memoria = _nome_sala;
        if (variable_struct_exists(global.areas_visitadas, _nome_sala))
        {
            area_mini_nome  = _nome_sala;
            area_mini_alpha = 0;
            area_mini_timer = 0;
            area_mini_slide = 50;
        }
        else
        {
            area_display_nome  = _nome_sala;
            area_display_alpha = 0;
            area_timer         = 0;
            global.areas_visitadas[$ _nome_sala] = true;
        }
    }
}


// Retorna o multiplicador de escala 
get_hud_scale = function()
{
    var _h = display_get_gui_height();
    return max(1, _h / ESCALA_UI); 
}

controla_alpha_hud = function()
{
    var _target = mostra_hud ? 1 : 0;
    hud_alpha = lerp(hud_alpha, _target, 0.1);
    if (abs(hud_alpha - _target) < 0.01) hud_alpha = _target;
}

pausando = function()
{
    if (morto or talk) exit;
    if (InputPressed(INPUT_VERB.PAUSE) and !global.abre_inventario)
    {
        if (!global.pause)
        {
            global.pause = true;
            instance_create_depth(x, y, depth, obj_menu);
            efeito_sonoro(sfx_pause, 50, 0.1);
            exit;
        }
        if (global.pause and instance_exists(obj_menu))
        {
            with (obj_menu)
            {
                InputVerbConsume(INPUT_VERB.PAUSE);
                global.pause = false;
                salvar_config();
                instance_destroy();
            }
        }
    }
    if (global.pause and !instance_exists(obj_menu) and !global.abre_inventario) global.pause = false;
}

abrindo_inventario = function()
{
    if (InputPressed(INPUT_VERB.OPEN_INVENTORY) and !global.pause and !global.abre_inventario and !talk and !morto)
    {
        global.abre_inventario = true;
        global.pause = true;
        instance_create_depth(x,y,depth,obj_inventario);
        efeito_sonoro(sfx_pause, 50, 0.1);
    }
}

verifica_hud = function()
{
    var _tem_tutorial = false;
    if (instance_exists(obj_tutorial))
    {
        with (obj_tutorial) { if (alpha_atual > 0) _tem_tutorial = true; }
    }

    if (global.timer_icone_save > 0 or area_display_alpha > 0 or talk or global.pause or _tem_tutorial) 
        mostra_hud = false;
    else 
        mostra_hud = true;
}

desenha_icone_save = function()
{
    if (global.timer_icone_save > 0)
    {
        global.timer_icone_save -= desconta_timer();
        var _s = get_hud_scale(); 
        var _w = display_get_gui_width();
        var _h = display_get_gui_height();
        draw_sprite_ext(spr_ui_save, 0, _w - (60*_s), _h - (60*_s), 2*_s, 2*_s, -current_time * 0.2, c_white, 1);
    }
}

desenha_vida = function()
{
    var _vida_max   = global.vida_max;
    var _vida_atual = global.vida_atual;

    if (_vida_atual < vida_anterior)
    {
        life_shake = 6; life_flash = 1.0;
        avatar_scale_x = 1.4; avatar_scale_y = 0.6;
        vida_anterior = _vida_atual;
    }
    else if (_vida_atual > vida_anterior)
    {
        heal_flash = 1.0;
        avatar_scale_x = 0.7; avatar_scale_y = 1.4;
        heart_pop_index = _vida_atual - 1; heart_pop_scale = 1.5;
        vida_anterior = _vida_atual;
    }

    life_shake = lerp(life_shake, 0, 0.1);
    life_flash = lerp(life_flash, 0, 0.1);
    heal_flash = lerp(heal_flash, 0, 0.05);
    avatar_scale_x = lerp(avatar_scale_x, 1, 0.15);
    avatar_scale_y = lerp(avatar_scale_y, 1, 0.15);
    heart_pop_scale = lerp(heart_pop_scale, 0, 0.2);

    // --- APLICA A REDUÇÃO DA ESCALA AQUI ---
    var _s = get_hud_scale() * hud_escala_mult; 
    
    var _shake_x = random_range(-life_shake, life_shake) * _s;
    var _shake_y = random_range(-life_shake, life_shake) * _s;
    var _mx = display_get_gui_width() * 0.03; 
    var _my = display_get_gui_height() * 0.03;

    // Avatar
    var _ax = _mx + _shake_x;
    var _ay = _my + _shake_y;
    var _cav = c_white;
    if (life_flash > 0.1) _cav = merge_color(c_white, c_red, life_flash);
    else if (heal_flash > 0.1) _cav = merge_color(c_white, c_aqua, heal_flash);

    var _spr = spr_avatar_life;
    var _fsx = _s * avatar_scale_x * 2; 
    var _fsy = _s * avatar_scale_y * 2;
    var _w_orig = sprite_get_width(_spr) * _s * 2; 
    var _h_orig = sprite_get_height(_spr) * _s * 2;
    
    var _offx = (_w_orig - (sprite_get_width(_spr) * _fsx)) / 2;
    var _offy = (_h_orig - (sprite_get_height(_spr) * _fsy)) / 2;

    draw_sprite_ext(_spr, 0, _ax + _offx, _ay + _offy, _fsx, _fsy, 0, _cav, 1 * hud_alpha);

    // Hearts
    var _bx = _ax + _w_orig + (_mx * 0.5);
    var _hbs = _s * 2;
    var _hh = sprite_get_height(spr_life_full) * _hbs;
    var _by = _ay + (_h_orig / 2) - (_hh / 2);

    for (var i = 0; i < _vida_max; i++)
    {
        var _spc = (sprite_get_width(spr_life_full) * _hbs) + (4 * _s);
        var _dx = _bx + (i * _spc);
        var _spt = (_vida_atual > i) ? spr_life_full : spr_life_empty;
        var _sc_ex = 0; var _clr = c_white;

        if (_vida_atual == 1 and i == 0) _sc_ex = ((sin(current_time / 150) + 1) * 0.5) * 0.4;
        if (i == heart_pop_index and _vida_atual > i) {
            _sc_ex = max(_sc_ex, heart_pop_scale);
            if (heart_pop_scale > 0.1) _clr = merge_color(c_white, c_aqua, 0.5);
        }

        var _fsc = _hbs + (_sc_ex * _s);
        var _dw = (sprite_get_width(_spt) * _fsc) - (sprite_get_width(_spt) * _hbs);
        var _dh = (sprite_get_height(_spt) * _fsc) - (sprite_get_height(_spt) * _hbs);
        
        draw_sprite_ext(_spt, 0, _dx - (_dw/2), _by - (_dh/2), _fsc, _fsc, 0, _clr, hud_alpha);
    }
}

desenha_combo = function()
{
    if (!global.powerups[powerup.COMBO]) exit;
    combo_display = lerp(combo_display, global.combo, 0.1);

    if (global.combo > combo_anterior) { combo_flash = 1.0; hud_shake_x = 4; combo_anterior = global.combo; }
    else if (global.combo < combo_anterior) combo_anterior = global.combo;

    if (combo_flash > 0) combo_flash = lerp(combo_flash, 0, 0.1);
    if (hud_shake_x > 0) hud_shake_x = lerp(hud_shake_x, 0, 0.2);

    // --- APLICA A REDUÇÃO DA ESCALA AQUI ---
    var _s = get_hud_scale() * hud_escala_mult;
    
    var _mx = display_get_gui_width() * 0.03;
    var _my = display_get_gui_height() * 0.03;
    
    var _av_w = sprite_get_width(spr_avatar_life) * _s * 2;
    var _av_h = sprite_get_height(spr_avatar_life) * _s * 2;

    var _is_max = (global.combo >= global.limite_combo);
    var _is_over = (_is_max and (global.vida_atual >= global.vida_max));
    
    var _shx = random_range(-hud_shake_x, hud_shake_x) * _s;
    var _shy = random_range(-hud_shake_x, hud_shake_x) * _s;
    if (_is_over) { _shx += random_range(-1, 1)*_s; _shy += random_range(-1, 1)*_s; }

    var _pulse = _is_max ? ((sin(current_time / (_is_over ? 50 : 150)) + 1) * 0.5) : 0;
    var _fh = (6 + (combo_flash * 3) + _pulse) * _s * 1.5; 
    
    var _x = _mx + _av_w + (_mx * 0.5) + _shx;
    var _y = _my + _av_h - _fh + _shy; 
    var _bw = 150 * _s; 

    var _pct = clamp(max(0, combo_display - 1) / max(1, global.limite_combo - 1), 0, 1);
    
    var _ptm = 0;
    if (instance_exists(obj_player)) {
        _ptm = (global.combo > 1) ? (1 - (obj_player.timer_dano / global.timer_combo)) : 0;
    }

    var _cn = c_aqua;
    if (_is_max) _cn = _is_over ? merge_color(c_maroon, c_red, ((sin(current_time/50)+1)/2)*0.6) : merge_color(c_aqua, c_white, ((sin(current_time/150)+1)/2)*0.7);

    draw_set_alpha(hud_alpha);
    draw_set_color(_is_max ? _cn : c_black);
    draw_rectangle(_x - 2*_s, _y - 2*_s, _x + _bw + 2*_s, _y + _fh + 2*_s, false);
    draw_set_color(c_dkgray);
    draw_rectangle(_x, _y, _x + _bw, _y + _fh, false);

    if (_pct > 0) {
        draw_set_color(_is_max ? _cn : merge_color(c_blue, c_aqua, _pct));
        draw_rectangle(_x, _y, _x + (_bw * _pct), _y + _fh, false);
    }
    if (combo_flash > 0.01) {
        gpu_set_blendmode(bm_add);
        draw_set_alpha(combo_flash * hud_alpha);
        draw_set_color(c_white);
        draw_rectangle(_x, _y, _x + (_bw * _pct), _y + _fh, false);
        draw_set_alpha(hud_alpha);
        gpu_set_blendmode(bm_normal);
    }
    
    if (instance_exists(obj_player)) {
        if (obj_player.dispara_alarme and global.combo > 1 and !_is_max) {
            draw_set_color(c_white);
            draw_rectangle(_x, _y + _fh - (2*_s), _x + (_bw * _ptm), _y + _fh, false);
        }
    }
    
    draw_set_color(c_white); draw_set_alpha(1);
}

desenha_marca = function()
{
    if (!global.powerups[powerup.MARK]) exit;
    var _active = (global.inimigo_marcado != noone);

    if (_active != mark_active_prev) { mark_scale = 1.4; mark_flash = 1.0; mark_active_prev = _active; }
    mark_scale = lerp(mark_scale, 1, 0.1);
    mark_flash = lerp(mark_flash, 0, 0.1);

    // --- APLICA A REDUÇÃO DA ESCALA AQUI ---
    var _s = get_hud_scale() * hud_escala_mult;
    
    var _mx = display_get_gui_width() * 0.03;
    var _my = display_get_gui_height() * 0.03;
    
    var _av_w = sprite_get_width(spr_avatar_life) * _s * 2;
    var _av_h = sprite_get_height(spr_avatar_life) * _s * 2;
    var _bh = 6 * _s * 1.5; 
    var _bw = 150 * _s;     
    var _spc = 25 * _s;     

    var _bar_x_start = _mx + _av_w + (_mx * 0.5);
    var _x = _bar_x_start + _bw + _spc;
    
    var _bar_top = (_my + _av_h) - _bh;
    var _bar_center = _bar_top + (_bh / 2);
    
    var _y = _bar_center;

    var _spr = spr_player_marca;
    if (sprite_exists(_spr))
    {
        var _fsc = _s * mark_scale * 2; 
        
        if (_active)
        {
            var _pct = global.timer_marcado / global.tempo_marcado;
            var _sh = sprite_get_height(_spr);
            var _vis = _sh * _pct;
            var _clr = (_pct < 0.25) ? merge_color(c_red, c_black, (sin(current_time/50)+1)/2) : c_red;
            
            draw_sprite_ext(_spr, 0, _x, _y, _fsc, _fsc, 0, c_dkgray, 0.5 * hud_alpha);
            
            var _dx = _x - (sprite_get_width(_spr) * _fsc / 2);
            var _dy_top = _y - (sprite_get_height(_spr) * _fsc / 2);
            var _dy_part = _dy_top + ((_sh - _vis) * _fsc); 
            
            draw_sprite_part_ext(_spr, 0, 0, _sh - _vis, sprite_get_width(_spr), _vis, _dx, _dy_part, _fsc, _fsc, _clr, hud_alpha);
        }
        else
        {
            draw_sprite_ext(_spr, 0, _x, _y, _fsc, _fsc, 0, c_white, hud_alpha);
            if (mark_flash > 0) { 
                gpu_set_blendmode(bm_add); 
                draw_sprite_ext(_spr, 0, _x, _y, _fsc, _fsc, 0, c_white, mark_flash*hud_alpha); 
                gpu_set_blendmode(bm_normal); 
            }
        }
    }
    draw_set_color(c_white); draw_set_alpha(1);
}

desenha_dinheiro = function()
{
    // 1. Aciona o fade e o efeito "Pop" se ganhou/gastou dinheiro
    if (global.dinheiro != dinheiro_alvo)
    {
        dinheiro_alvo = global.dinheiro;
        timer_dinheiro = 3; 
        pop_moeda = 2.0; // Faz o ícone inchar o dobro do tamanho instantaneamente!
    }

    // 2. Faz o número "rodar" suavemente até o valor real
    if (dinheiro_exibido != dinheiro_alvo)
    {
        dinheiro_exibido = lerp(dinheiro_exibido, dinheiro_alvo, 0.1);
        // Garante que não fique número quebrado no final
        if (abs(dinheiro_exibido - dinheiro_alvo) < 0.5) dinheiro_exibido = dinheiro_alvo; 
    }

    // 3. Suaviza os timers e efeitos
    if (timer_dinheiro > 0)
    {
        timer_dinheiro -= desconta_timer();
        alpha_dinheiro = lerp(alpha_dinheiro, 1, 0.15); 
    }
    else
    {
        alpha_dinheiro = lerp(alpha_dinheiro, 0, 0.05); 
    }
    
    // O ícone desincha suavemente de volta ao tamanho normal (1)
    pop_moeda = lerp(pop_moeda, 1, 0.15);

    // 4. Desenha na tela (CANTO SUPERIOR DIREITO)
    if (alpha_dinheiro > 0.01)
    {
        var _s = get_hud_scale() * hud_escala_mult;
        
        // --- HIERARQUIA VISUAL ---
        // Texto um pouco menor e mais elegante (1.2). Moeda grandona (3.0).
        var _escala_texto = _s * 1.2; 
        var _escala_moeda_base = _s * 3.0; 
        var _escala_animada = _escala_moeda_base * pop_moeda; 
        
        var _margem_tela = display_get_gui_width() * 0.03;
        var _my = display_get_gui_height() * 0.03;
        
        var _alpha_final = alpha_dinheiro * hud_alpha;
        draw_set_alpha(_alpha_final);
        
        // --- 1. CONFIGURA O TEXTO ---
        var _texto = string(round(dinheiro_exibido)); 
        
        draw_set_font(fnt_dialogo);
        draw_set_halign(fa_right); 
        draw_set_valign(fa_middle); 
        
       
        var _x_texto = round(display_get_gui_width() - _margem_tela);
        var _y_base = round(_my + (20 * _s)); 
        
        // Sombra leve e depois o texto
        draw_set_color(c_black);
        draw_text_transformed(_x_texto + (2*_s), _y_base + (2*_s), _texto, _escala_texto, _escala_texto, 0);
        draw_set_color(c_white); 
        draw_text_transformed(_x_texto, _y_base, _texto, _escala_texto, _escala_texto, 0);
        
        // --- 2. MATEMÁTICA ANTI-SOBREPOSIÇÃO ---
        var _largura_texto = string_width(_texto) * _escala_texto;
        var _largura_sprite = sprite_get_width(spr_dinheiro) * _escala_animada;
        
        // Pega exatamente a ponta esquerda do texto
        var _limite_esquerdo_texto = _x_texto - _largura_texto;
        
        // Recua a moeda com base no limite do texto, tira a metade direita da moeda e dá 10px de folga
        var _folga = 12 * _s;
        var _x_moeda = round(_limite_esquerdo_texto - (_largura_sprite / 2) - _folga);
        
        // Desenha a moeda cravada no grid
        draw_sprite_ext(spr_dinheiro, 0, _x_moeda, _y_base, _escala_animada, _escala_animada, 0, c_white, _alpha_final);
        
        // Reseta os defaults
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_set_font(-1); 
        draw_set_halign(-1); 
        draw_set_valign(-1);
    }
}

desenha_nome_area = function()
{
    if (global.pause) exit;
    if (area_display_nome == "" or (area_display_alpha <= 0 and area_timer > area_duracao)) exit;

    area_timer += delta_time / 1000000;
    if (area_timer < area_duracao) area_display_alpha = min(area_display_alpha + 0.02, 1);
    else area_display_alpha = max(area_display_alpha - 0.02, 0);

    if (area_display_alpha <= 0) exit;

    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    var _s = get_hud_scale();
    
    var _zoom = 1 + (area_timer * 0.02);
    var _scf = 2.0 * _s * _zoom; 

    draw_set_alpha(area_display_alpha);
    draw_set_font(fnt_dialogo);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    
    var _texto = get_text(area_display_nome)
    
    draw_set_color(c_black);
    draw_text_transformed((_w/2) + 2*_s, (_h*0.30) + 2*_s, _texto , _scf, _scf, 0);
    draw_set_color(c_ltgray);
    draw_text_transformed(_w/2, _h*0.30, _texto , _scf, _scf, 0);
    
    draw_set_font(-1); draw_set_halign(-1); draw_set_valign(-1); draw_set_color(c_white); draw_set_alpha(1);
}

desenha_nome_area_mini = function()
{
    if (global.pause) exit;
    if (area_mini_nome == "" or (area_mini_alpha <= 0 and area_mini_timer > area_mini_duracao)) exit;

    area_mini_timer += delta_time / 1000000;
    if (area_mini_timer < area_mini_duracao) { area_mini_alpha = min(area_mini_alpha + 0.05, 1); area_mini_slide = lerp(area_mini_slide, 0, 0.1); }
    else area_mini_alpha = max(area_mini_alpha - 0.02, 0);

    var _alpha = area_mini_alpha * hud_alpha;
    if (_alpha <= 0) exit;

    var _s = get_hud_scale();
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    
    var _x = (_w - (_w * 0.05)) + (area_mini_slide * _s);
    var _y = _h * 0.05;
    var _scf = 1.0 * _s;
    
    var _texto = get_text(area_mini_nome);
   
    draw_set_alpha(_alpha); draw_set_font(fnt_dialogo);
    draw_set_halign(fa_right); draw_set_valign(fa_top);
    draw_set_color(c_black); draw_text_transformed(_x + 2*_s, _y + 2*_s, _texto, _scf, _scf, 0);
    draw_set_color(c_white); draw_text_transformed(_x, _y, _texto, _scf, _scf, 0);
    draw_set_font(-1); draw_set_halign(-1); draw_set_valign(-1); draw_set_alpha(1);
}

desenha_tudo = function()
{
    desenha_nome_area();
    if (hud_alpha > 0)
    {
        desenha_vida();
        desenha_combo();
        desenha_marca();
        desenha_dinheiro(); 
        desenha_nome_area_mini();
    }
    desenha_icone_save();
}