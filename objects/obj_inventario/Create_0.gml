current_tab = INVENTARIO_TAB.STATUS; 
cursor_col  = 0; 
cursor_row  = 0; 
scroll_row  = 0; 

cursor_lerp_x = 0;
cursor_lerp_y = 0;
cursor_scale  = 1; 

key_item_cols = 4;
array_itens_filtrados = [];
surf_items = -1; 

lista_abas = [
    INVENTARIO_TAB.STATUS, 
    INVENTARIO_TAB.MAPA, 
    INVENTARIO_TAB.ITENS, 
    INVENTARIO_TAB.AMULETOS, 
    INVENTARIO_TAB.MELHORIAS, 
    INVENTARIO_TAB.ESSENCIAS,
    INVENTARIO_TAB.BESTIARIO
];

// Filtra itens por aba
atualiza_lista_filtrada = function()
{
    array_itens_filtrados = [];
    
    // Abas que não usam listas ignoram o filtro
    if (current_tab == INVENTARIO_TAB.AMULETOS or current_tab == INVENTARIO_TAB.STATUS or current_tab == INVENTARIO_TAB.MAPA) return;

    // --- FILTRO DO BESTIÁRIO ---
    if (current_tab == INVENTARIO_TAB.BESTIARIO)
    {
        if (variable_global_exists("db_bestiario") and variable_global_exists("bestiario_kills"))
        {
            var _nomes = variable_struct_get_names(global.db_bestiario);
            for (var i = 0; i < array_length(_nomes); i++)
            {
                var _key = _nomes[i];
                var _kills = global.bestiario_kills[$ _key];
                
                // Só adiciona na lista se o jogador já tiver matado pelo menos 1 vez
                if (!is_undefined(_kills) and _kills > 0)
                {
                    array_push(array_itens_filtrados, _key);
                }
            }
        }
        return;
    }

    // --- FILTRO DE ITENS NORMAIS ---
    if (variable_global_exists("itens_chave") and ds_exists(global.itens_chave, ds_type_map))
    {
        var _key = ds_map_find_first(global.itens_chave);
        while (!is_undefined(_key))
        {
            if (global.itens_chave[? _key] > 0) 
            {
                var _info = variable_struct_get(global.db_itens_info, _key);
                if (_info != undefined) {
                    if (_info.categoria == current_tab) array_push(array_itens_filtrados, _key);
                    else if (current_tab == INVENTARIO_TAB.ITENS and !_info[$ "categoria"]) array_push(array_itens_filtrados, _key);
                }
            }
            _key = ds_map_find_next(global.itens_chave, _key);
        }
    }
}
atualiza_lista_filtrada(); 

// Dados visuais do item
pega_dados_item = function(_item)
{
    if (is_struct(_item)) return _item; 
    if (is_string(_item))
    {
        if (!variable_global_exists("db_itens_info")) return undefined;
        var _info = variable_struct_get(global.db_itens_info, _item);
        return (_info != undefined) ? _info : { nome_key: "Unknown", desc_key: "...", spr: spr_boss }; 
    }
    return undefined;
}

// Controle e Navegação
navega_inventario = function()
{
    var _c = controles_menu();
    var _troca_aba = 0; 

    if (_c.pag_esq) _troca_aba = -1;
    if (_c.pag_dir) _troca_aba = 1;

    var _dx = (_c.direita - _c.esquerda);
    var _dy = (_c.baixo - _c.cima);

    // Grid Amuletos
    if (current_tab == INVENTARIO_TAB.AMULETOS)
    {
        var _cols = ds_grid_width(global.inventario);
        var _lins = ds_grid_height(global.inventario);
        
        if (_dx != 0) 
        {
            var _ncol = cursor_col + _dx;
            if (_ncol >= _cols) _troca_aba = 1;
            else if (_ncol < 0) _troca_aba = -1;
            else { cursor_col = _ncol; cursor_scale = 0.8; efeito_sonoro(sfx_menu_click, 50, 0.1); }
            InputVibrateConstant(0.05, 0.0, 20);
        }
        if (_dy != 0) {
            cursor_row = (cursor_row + _dy + _lins) mod _lins;
            cursor_scale = 0.8; efeito_sonoro(sfx_menu_click, 50, 0.1);
            InputVibrateConstant(0.05, 0.0, 20);
        }
        
        if (_c.confirma) { 
            var _item = global.inventario[# cursor_col, cursor_row];
            if (is_struct(_item)) { _item.alterna_equipamento(); efeito_sonoro(sfx_pause, 50, 0.1); }
        }
    }
    // Listas (Itens e Bestiário)
    else 
    {
        var _total = array_length(array_itens_filtrados);
        if (_total == 0) { if (_dx != 0) _troca_aba = _dx; }
        else
        {
            // O Bestiário é uma lista de 1 coluna, as outras usam key_item_cols (ex: 4)
            var _cols_atuais = (current_tab == INVENTARIO_TAB.BESTIARIO) ? 1 : key_item_cols;
            var _rows = max(1, ceil(_total / _cols_atuais));
            
            if (_dx != 0) 
            {
                var _ncol = cursor_col + _dx;
                if (_ncol >= _cols_atuais) _troca_aba = 1;
                else if (_ncol < 0) _troca_aba = -1;
                else {
                    var _idx = (cursor_row * _cols_atuais) + _ncol;
                    if (_idx < _total) { cursor_col = _ncol; cursor_scale = 0.8; efeito_sonoro(sfx_menu_click, 50, 0.1); }
                    else if (_dx > 0) _troca_aba = 1; 
                }
            }
            if (_dy != 0) {
                var _nr = cursor_row + _dy;
                if (_nr >= 0 and _nr < _rows) {
                    var _idx = (_nr * _cols_atuais) + cursor_col;
                    if (_idx >= _total) cursor_col = (_total - 1) % _cols_atuais;
                    cursor_row = _nr;
                    cursor_scale = 0.8; efeito_sonoro(sfx_menu_click, 50, 0.1);
                    
                    // Ajuste de scroll dinâmico
                    var _max_vis = (current_tab == INVENTARIO_TAB.BESTIARIO) ? 8 : 2; 
                    if (cursor_row < scroll_row) scroll_row = cursor_row;
                    if (cursor_row > scroll_row + _max_vis) scroll_row = cursor_row - _max_vis; 
                }
            }
        }
    }

    // Executa Troca de Aba Dinâmica
    if (_troca_aba != 0)
    {
        var _idx = 0;
        var _tot_abas = array_length(lista_abas);
        
        for (var i = 0; i < _tot_abas; i++) if (lista_abas[i] == current_tab) { _idx = i; break; }
        
        current_tab = lista_abas[(_idx + _troca_aba + _tot_abas) % _tot_abas];
        
        cursor_lerp_x = -1; 
        atualiza_lista_filtrada();
        cursor_row = 0; scroll_row = 0;
        
        if (_troca_aba == 1) cursor_col = 0;
        else {
            if (current_tab == INVENTARIO_TAB.AMULETOS) cursor_col = ds_grid_width(global.inventario) - 1;
            else {
                var _c_atuais = (current_tab == INVENTARIO_TAB.BESTIARIO) ? 1 : key_item_cols;
                cursor_col = _c_atuais - 1;
                var _tot = array_length(array_itens_filtrados);
                if (current_tab != INVENTARIO_TAB.AMULETOS and _tot > 0) 
                    while ((cursor_row * _c_atuais) + cursor_col >= _tot and cursor_col > 0) cursor_col--;
            }
        }
        efeito_sonoro(sfx_menu_click, 50, 0.15);
        InputVibrateConstant(0.1, 0.0, 30);
    }
    
    // Sair
    if (_c.voltar_btn or _c.abre_inventario or _c.aplica_pause) {
        InputVerbConsumeAll();
        global.abre_inventario = false;
        global.pause = false;
        instance_destroy();      
    }    
}

// ==============================================================
//                    FUNÇÕES DE DESENHO (MÓDULOS)
// ==============================================================

desenha_fundo_e_abas = function(_inv_x, _inv_y, _inv_w, _inv_h, _head_h)
{
    draw_sprite_stretched(spr_inventario_fundo, 0, _inv_x, _inv_y, _inv_w, _inv_h);
    
    draw_set_valign(fa_middle); 
    draw_set_halign(fa_center); 
    var _tab_y = _inv_y + (_head_h / 2);
    
    var _keys = ["tab_status", "tab_mapa", "tab_itens", "tab_amuletos", "tab_melhorias", "tab_essencias", "tab_bestiario"];
    var _enums = lista_abas; 
    var _tot_abas = array_length(_enums);
    var _div = _inv_w / _tot_abas; 
    
    for (var i = 0; i < _tot_abas; i++) {
        var _sel = (current_tab == _enums[i]);
        var _c = _sel ? c_white : c_gray;
        var _txt = get_text(_keys[i]);
        var _tx = _inv_x + (_div*i) + (_div/2);
        
        if (_sel) draw_text_color(_tx, _tab_y, "["+_txt+"]", c_yellow, c_yellow, c_yellow, c_yellow, 1);
        else draw_text_color(_tx, _tab_y, _txt, _c, _c, _c, _c, 0.4);
    }
}

desenha_aba_status = function(_inv_x, _inv_w, _cont_y, _cont_h)
{
    var _margem = 40;
    var _meio_x = _inv_x + (_inv_w / 2);
    var _col1_x = _inv_x + _margem * 2;
    var _col2_x = _meio_x + _margem;
    var _linha_y = _cont_y + 20;
    var _espaco_linhas = 40;
    
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    
    // ==========================================
    // COLUNA 1: ATRIBUTOS E FRAGMENTOS
    // ==========================================
    draw_set_color(c_yellow);
    draw_text(_col1_x, _linha_y, get_text("status_titulo_atributos"));
    draw_set_color(c_white);
    
    var _atr_y = _linha_y + _espaco_linhas * 1.5;
    draw_text(_col1_x, _atr_y, get_text("status_vida") + ": " + string(global.vida_max)); _atr_y += _espaco_linhas;
    draw_text(_col1_x, _atr_y, get_text("status_dano") + ": " + string(global.dano)); _atr_y += _espaco_linhas;
    draw_text(_col1_x, _atr_y, get_text("status_velocidade") + ": " + string(global.velh_calculada)); _atr_y += _espaco_linhas;
    draw_text(_col1_x, _atr_y, get_text("status_slots") + ": " + string(global.player_slots_maximos)); _atr_y += _espaco_linhas * 1.5;
    
    // --- SEÇÃO DE FRAGMENTOS (TRADUZIDA) ---
    draw_set_color(c_yellow);
    draw_text(_col1_x, _atr_y, get_text("status_fragmentos"));
    draw_set_color(c_white);
    _atr_y += _espaco_linhas;
    
    var _alt_centro = string_height("M") / 2;
    
    // Fragmentos de Vida
    var _frag_vida_atual = global.fragmentos_vida mod global.fragmentos_por_ponto;
    var _str_vida = get_text("status_frag_vida");
    draw_text(_col1_x, _atr_y, _str_vida);
    
    // Calcula a largura dinâmica da palavra traduzida
    var _icon_x = _col1_x + string_width(_str_vida) + 15;
    var _escala_icon = 1.5; 
    
    for (var i = 0; i < global.fragmentos_por_ponto; i++) 
    {
        var _tem_fragmento = (i < _frag_vida_atual);
        var _cor = _tem_fragmento ? c_white : c_black;
        var _alpha = _tem_fragmento ? 1.0 : 0.3;
        
        draw_sprite_ext(spr_fragmento_vida, 0, _icon_x + (i * 35), _atr_y + _alt_centro, _escala_icon, _escala_icon, 0, _cor, _alpha);
    }
    _atr_y += _espaco_linhas;
    
    // Fragmentos de Foco (Tempo)
    var _frag_tempo_atual = global.fragmentos_tempo mod global.fragmentos_tempo_por_ponto;
    var _str_foco = get_text("status_frag_foco");
    draw_text(_col1_x, _atr_y, _str_foco);
    
    var _icon_x2 = _col1_x + string_width(_str_foco) + 15;
    
    for (var i = 0; i < global.fragmentos_tempo_por_ponto; i++) 
    {
        var _tem_fragmento = (i < _frag_tempo_atual);
        var _cor = _tem_fragmento ? c_white : c_black;
        var _alpha = _tem_fragmento ? 1.0 : 0.3;
        
        draw_sprite_ext(spr_fragmento_tempo, 0, _icon_x2 + (i * 35), _atr_y + _alt_centro, _escala_icon, _escala_icon, 0, _cor, _alpha);
    }
    _atr_y += _espaco_linhas * 1.5;
    
    // Tempo de jogo
    var _t = global.tempo_de_jogo_segundos;
    var _str_tempo = string(_t div 3600) + "h " + (((_t mod 3600) div 60) < 10 ? "0" : "") + string((_t mod 3600) div 60) + "m " + ((_t mod 60) < 10 ? "0" : "") + string(_t mod 60) + "s";
    draw_set_color(c_gray);
    draw_text(_col1_x, _atr_y, get_text("status_tempo") + ": " + _str_tempo);
    
    // ==========================================
    // COLUNA 2: HABILIDADES
    // ==========================================
    draw_set_color(c_yellow);
    draw_text(_col2_x, _linha_y, get_text("status_titulo_habilidades"));
    
    var _hab_y = _linha_y + _espaco_linhas * 1.5;
    var _nomes_hab = ["hab_dash", "hab_walljump", "hab_doublejump", "hab_combo", "hab_float", "hab_mark"];
    
    for (var i = 0; i < array_length(_nomes_hab); i++) {
        if (global.powerups[i]) {
            draw_set_color(c_white); draw_text(_col2_x, _hab_y, "- " + get_text(_nomes_hab[i]));
        } else {
            draw_set_color(c_dkgray); draw_text(_col2_x, _hab_y, "- ???");
        }
        _hab_y += _espaco_linhas;
    }
    
    // Linha divisória central
    draw_set_color(c_gray); draw_set_alpha(0.3);
    draw_line(_meio_x, _linha_y, _meio_x, max(_atr_y, _hab_y)); 
    draw_set_alpha(1.0);

    // ==========================================
    // CARTEIRA DE DINHEIRO (Canto Inferior Direito)
    // ==========================================
    draw_set_halign(fa_right); 
    draw_set_valign(fa_bottom); 
    draw_set_color(c_white);
    
    var _str_dinheiro = string(global.dinheiro);
    var _din_x = _inv_x + _inv_w - _margem; 
    var _din_y = _cont_y + _cont_h;         
    
    draw_text(_din_x, _din_y, _str_dinheiro);
    
    if (sprite_exists(spr_dinheiro)) 
    {
        var _w = string_width(_str_dinheiro);
        var _escala_moeda = 1.5;
        
        draw_sprite_ext(spr_dinheiro, 0, _din_x - _w - 15, _din_y - (_alt_centro), _escala_moeda, _escala_moeda, 0, c_white, 1);
    }
}

desenha_aba_bestiario = function(_area_x, _cont_y, _area_w, _cont_h, _area_desc_x, _area_desc_w)
{
    var _len = array_length(array_itens_filtrados);
    
    // Se não encontrou nenhum monstro ainda
    if (_len == 0) {
        draw_set_halign(fa_center); draw_set_valign(fa_middle);
        draw_set_color(c_gray); draw_text(_area_x + _area_w/2, _cont_y + _cont_h/2, "- Bestiário Vazio -");
        return;
    }

    // --- ESQUERDA: LISTA DE MONSTROS ---
    var _alt_item = 44; 
    
    for (var i = 0; i < _len; i++) {
        var _yy = _cont_y + (i - scroll_row) * _alt_item;
        
        // Renderiza só o que está visível no scroll
        if (_yy >= _cont_y and _yy + _alt_item <= _cont_y + _cont_h) {
            var _key = array_itens_filtrados[i];
            var _data = global.db_bestiario[$ _key];
            var _nome = get_text(_data.nome_key);
            
            var _c = (cursor_row == i) ? c_yellow : c_white;
            
            if (cursor_row == i) {
                draw_set_alpha(0.2); draw_set_color(c_yellow);
                draw_rectangle(_area_x, _yy, _area_x + _area_w, _yy + _alt_item - 4, false);
                draw_set_alpha(1.0);
            }
            
            draw_set_halign(fa_left); draw_set_valign(fa_middle);
            draw_set_color(_c);
            draw_text(_area_x + 15, _yy + (_alt_item/2) - 2, _nome);
        }
    }

    // --- DIREITA: DETALHES E ANIMAÇÃO ---
    if (cursor_row < _len) {
        var _key = array_itens_filtrados[cursor_row];
        var _data = global.db_bestiario[$ _key];
        var _kills = global.bestiario_kills[$ _key];
        var _req = _data.mortes_req;
        
        var _completo = (_kills >= _req);
        var _cx = _area_desc_x + (_area_desc_w / 2);
        var _cy = _cont_y + 120; // Centro da sprite
        
        // 1. ANIMAÇÃO VIVA DO MONSTRO E COMPENSAÇÃO DE ORIGEM
        var _spr = _data.spr;
        var _frames = sprite_get_number(_spr);
        var _img_animada = (current_time / 150) mod _frames; 
        
        var _escala = 2; // Inimigos desenhados com o dobro do tamanho
        var _spr_w = sprite_get_width(_spr) * _escala;
        var _spr_h = sprite_get_height(_spr) * _escala;
        
        // Pega a origem do inimigo (Bottom Center)
        var _xoff = sprite_get_xoffset(_spr) * _escala;
        var _yoff = sprite_get_yoffset(_spr) * _escala;
        
        // Aplica o cálculo matemático de centro
        var _draw_x = _cx - (_spr_w / 2) + _xoff;
        var _draw_y = _cy - (_spr_h / 2) + _yoff;
        
        if (_completo) {
            // Desenha o monstro normal
            draw_sprite_ext(_spr, _img_animada, _draw_x, _draw_y, _escala, _escala, 0, c_white, 1);
        } else {
            // Desenha a silhueta preta
            gpu_set_fog(true, c_black, 0, 0);
            draw_sprite_ext(_spr, _img_animada, _draw_x, _draw_y, _escala, _escala, 0, c_white, 1);
            gpu_set_fog(false, c_black, 0, 0);
        }
        
        // 2. TEXTOS (Nomes e Atributos)
        var _texto_y = _cy + 80;
        draw_set_halign(fa_center); draw_set_valign(fa_top);
        
        draw_set_color(c_yellow);
        draw_text(_cx, _texto_y, get_text(_data.nome_key));
        _texto_y += 35;
        
        if (_completo) {
            // Stats revelados
            draw_set_color(c_white);
            draw_text(_cx, _texto_y, "HP: " + string(_data.vida) + "  |  Dano: " + string(_data.dano));
            _texto_y += 50;
            
            // Descrição da Lore
            draw_text_ext(_cx, _texto_y, get_text(_data.desc_key), 22, _area_desc_w - 20);
            
            // Contador de Abates (Completo)
            draw_set_color(c_gray);
            draw_text(_cx, _cont_y + _cont_h - 40, "Abates totais: " + string(_kills));
        } else {
            // Stats e descrições ocultas
            draw_set_color(c_gray);
            draw_text(_cx, _texto_y, "HP: ???  |  Dano: ???");
            _texto_y += 50;
            
            draw_text_ext(_cx, _texto_y, "Continue caçando esta criatura para revelar sua pesquisa completa.", 22, _area_desc_w - 20);
            
            // Contador de Abates (Progresso)
            draw_set_color(c_white);
            draw_text(_cx, _cont_y + _cont_h - 40, "Pesquisa: " + string(_kills) + " / " + string(_req));
        }
    }
}

desenha_aba_amuletos = function(_area_x, _cont_y, _area_w, _cont_h, _inv_y, _inv_h, _pad_y)
{
    var _cols = ds_grid_width(global.inventario);
    var _lins = ds_grid_height(global.inventario);
    var _sep = 8; 
    var _sz = min((_area_w - ((_cols-1)*_sep))/_cols, ((_cont_h-30)-((_lins-1)*_sep))/_lins);
    var _tx = 0; var _ty = 0; 
    
    // Fundos
    for (var _i = 0; _i < _lins; _i++) {
        for (var _j = 0; _j < _cols; _j++) {
            var _xx = _area_x + _j * (_sz + _sep);
            var _yy = _cont_y + _i * (_sz + _sep);
            var _item = global.inventario[# _j, _i];
            
            if (cursor_col == _j and cursor_row == _i) { _tx = _xx; _ty = _yy; }
            var _frm = (is_struct(_item) and _item.equipado) ? 2 : 0;   
            draw_sprite_stretched(spr_inventario_caixa, _frm, _xx, _yy, _sz, _sz);
        }
    }
    
    // Cursor
    if (cursor_lerp_x == -1) { cursor_lerp_x = _tx; cursor_lerp_y = _ty; }
    else { cursor_lerp_x = lerp(cursor_lerp_x, _tx, 0.25); cursor_lerp_y = lerp(cursor_lerp_y, _ty, 0.25); }
    var _csz = _sz * cursor_scale;
    draw_sprite_stretched(spr_inventario_caixa, 1, cursor_lerp_x + (_sz-_csz)/2, cursor_lerp_y + (_sz-_csz)/2, _csz, _csz);

    // Itens
    for (var _i = 0; _i < _lins; _i++) {
        for (var _j = 0; _j < _cols; _j++) {
            var _xx = _area_x + _j * (_sz + _sep);
            var _yy = _cont_y + _i * (_sz + _sep);
            var _item = global.inventario[# _j, _i];
            
            if (is_struct(_item)) {
                var _p = _sz * 0.15;
                draw_sprite_stretched(_item.spr, _item.meu_id, _xx+_p, _yy+_p, _sz-(_p*2), _sz-(_p*2));
            }
        }
    }
    
    draw_set_halign(fa_left); draw_set_valign(fa_bottom);
    draw_text(_area_x, _inv_y + _inv_h - (_pad_y/2), get_text("inv_slots") + " " + string(global.player_slots_usados) + "/" + string(global.player_slots_maximos));
}

desenha_aba_listas = function(_area_x, _cont_y, _area_w, _cont_h)
{
    var _cols = key_item_cols; var _sep = 8;
    var _sz = (_area_w - ((_cols-1) * _sep)) / _cols;
    
    if (!surface_exists(surf_items)) surf_items = surface_create(_area_w, _cont_h);
    
    surface_set_target(surf_items);
    draw_clear_alpha(c_black, 0); 
    
    var _len = array_length(array_itens_filtrados);
    if (_len == 0) { 
        draw_set_halign(fa_center); draw_set_valign(fa_middle);
        draw_set_color(c_gray); draw_text(_area_w/2, _cont_h/2, get_text("inv_vazio"));
    }
    else {
        var _tx = -1; var _ty = -1;

        // Fundos
        for (var i = 0; i < _len; i++) {
            var _c = i mod _cols; var _r = i div _cols;
            var _xx = _c * (_sz + _sep);
            var _yy = (_r * (_sz + _sep)) - (scroll_row * (_sz + _sep));
            if (cursor_col == _c and cursor_row == _r) { _tx = _xx; _ty = _yy; }
            if (_yy + _sz > 0 and _yy < _cont_h) draw_sprite_stretched(spr_inventario_caixa, 0, _xx, _yy, _sz, _sz);
        }

        // Cursor
        if (_tx != -1) {
            if (cursor_lerp_x == -1) { cursor_lerp_x = _tx; cursor_lerp_y = _ty; }
            else { cursor_lerp_x = lerp(cursor_lerp_x, _tx, 0.25); cursor_lerp_y = lerp(cursor_lerp_y, _ty, 0.25); }
            var _csz = _sz * cursor_scale;
            draw_sprite_stretched(spr_inventario_caixa, 1, cursor_lerp_x + (_sz-_csz)/2, cursor_lerp_y + (_sz-_csz)/2, _csz, _csz);
        }

        // Itens
        for (var i = 0; i < _len; i++) {
            var _c = i mod _cols; var _r = i div _cols;
            var _xx = _c * (_sz + _sep);
            var _yy = (_r * (_sz + _sep)) - (scroll_row * (_sz + _sep));
            
            if (_yy + _sz > 0 and _yy < _cont_h) {
                var _id = array_itens_filtrados[i];
                var _d = pega_dados_item(_id);
                if (_d != undefined) {
                    var _p = _sz * 0.15;
                    draw_sprite_stretched(_d.spr, 0, _xx+_p, _yy+_p, _sz-(_p*2), _sz-(_p*2));
                    
                    var _q = global.itens_chave[? _id]; 
                    if (_q > 1) {
                        draw_set_halign(fa_right); draw_set_valign(fa_bottom); draw_set_font(fnt_dialogo);
                        draw_set_color(c_black); draw_text_transformed(_xx+_sz-2, _yy+_sz+2, string(_q), 0.7, 0.7, 0);
                        draw_set_color(c_white); draw_text_transformed(_xx+_sz-4, _yy+_sz-4, string(_q), 0.7, 0.7, 0);
                    }
                }
            }
        }
    }
    surface_reset_target();
    draw_surface(surf_items, _area_x, _cont_y);
}

desenha_painel_info = function(_desc_x, _desc_w, _cont_y, _cont_h)
{
    var _sel = undefined;
    if (current_tab == INVENTARIO_TAB.AMULETOS) _sel = global.inventario[# cursor_col, cursor_row];
    else {
        var _idx = cursor_col + (cursor_row * key_item_cols);
        if (_idx < array_length(array_itens_filtrados)) _sel = array_itens_filtrados[_idx];
    }
    
    if (_sel != undefined and _sel != 0) {
        var _d = pega_dados_item(_sel);
        if (_d != undefined) {
            var _isz = 96; var _ixc = _desc_x + (_desc_w - _isz)/2;
            var _frm = is_struct(_sel) ? _sel.meu_id : 0;
            draw_sprite_stretched(_d.spr, _frm, _ixc, _cont_y, _isz, _isz);
            
            draw_set_halign(fa_center); draw_set_valign(fa_top);
            draw_set_color(c_yellow); draw_text_ext(_desc_x + _desc_w/2, _cont_y + 120, get_text(_d.nome_key), 24, _desc_w);
            draw_set_color(c_white); 
            
            var _desc = get_text(_d.desc_key);
            if (current_tab != INVENTARIO_TAB.AMULETOS) {
                 var _q = global.itens_chave[? _sel];
                 if (_q > 1) _desc += "\n(x" + string(_q) + ")";
            }
            draw_text_ext(_desc_x + _desc_w/2, _cont_y + 160, _desc, 20, _desc_w);

            // =======================================================
            // INPUT PARA EQUIPAR (Canto Inferior Direito do Painel)
            // =======================================================
            if (current_tab == INVENTARIO_TAB.AMULETOS and is_struct(_sel)) 
            {
                var _str_equipar = get_text("inv_equipar");
                
                var _escala_icon = 2.0; // <-- Aumentamos bem o tamanho do botão!
                var _text_w = string_width(_str_equipar);
                
                // Ancorando no canto direito do painel de descrição (-20 de margem)
                var _prompt_x = _desc_x + _desc_w - 20; 
                var _prompt_y = _cont_y + _cont_h - 20; // Fundo do painel
                
                // Desenha o texto alinhado pela direita
                draw_set_halign(fa_right); 
                draw_set_valign(fa_middle);
                draw_text(_prompt_x, _prompt_y, _str_equipar);
                
                // Acha a posição X ideal para o botão (Texto + Margem segura)
                // Usamos a proporção da escala pra não encavalar
                var _dist_botao = _text_w + (20 * _escala_icon); 
                
                desenha_input_verbo(INPUT_VERB.JUMP, _prompt_x - _dist_botao, _prompt_y, _escala_icon);
            }
        }
    }
}

// ==============================================================
//             RENDERIZAÇÃO PRINCIPAL (FICOU ENXUTA!)
// ==============================================================

desenha_inventario = function()
{
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    draw_set_font(fnt_dialogo); 
    
    // Layout Principal
    var _inv_w = _gui_w * 0.95; 
    var _inv_h = _gui_h * 0.95;
    var _inv_x = (_gui_w - _inv_w)/2; 
    var _inv_y = (_gui_h - _inv_h)/2;
    
    var _pad_x = _inv_w * 0.03; 
    var _pad_y = _inv_h * 0.05; 
    var _head_h = _inv_h * 0.12;
    var _cont_y = _inv_y + _head_h;
    var _cont_h = _inv_h - _head_h - _pad_y;
    
    var _area_itens_w = (_inv_w - (_pad_x*3)) * 0.60;
    var _area_desc_w  = (_inv_w - (_pad_x*3)) * 0.40;
    var _area_itens_x = _inv_x + _pad_x;
    var _area_desc_x  = _area_itens_x + _area_itens_w + _pad_x;
    
    cursor_scale = lerp(cursor_scale, 1, 0.2);

    // 1. Fundo e Abas Superiores
    desenha_fundo_e_abas(_inv_x, _inv_y, _inv_w, _inv_h, _head_h);

    // 2. Conteúdo Dinâmico por Aba
    if (current_tab == INVENTARIO_TAB.AMULETOS) {
        desenha_aba_amuletos(_area_itens_x, _cont_y, _area_itens_w, _cont_h, _inv_y, _inv_h, _pad_y);
    }
    else if (current_tab == INVENTARIO_TAB.ITENS or current_tab == INVENTARIO_TAB.MELHORIAS or current_tab == INVENTARIO_TAB.ESSENCIAS) {
        desenha_aba_listas(_area_itens_x, _cont_y, _area_itens_w, _cont_h);
    }
    else if (current_tab == INVENTARIO_TAB.BESTIARIO) {
        desenha_aba_bestiario(_area_itens_x, _cont_y, _area_itens_w, _cont_h, _area_desc_x, _area_desc_w);
    }
    else if (current_tab == INVENTARIO_TAB.STATUS) {
        desenha_aba_status(_inv_x, _inv_w, _cont_y, _cont_h);
    }
    else if (current_tab == INVENTARIO_TAB.MAPA) {
        draw_set_halign(fa_center); draw_set_valign(fa_middle);
        draw_text(_inv_x + _inv_w/2, _cont_y + _cont_h/2, "- WIP: Mapa do Jogo -");
    }
    
    // 3. Painel de Informações Lateral (se for aba de itens)
    if (current_tab == INVENTARIO_TAB.AMULETOS or current_tab == INVENTARIO_TAB.ITENS or current_tab == INVENTARIO_TAB.MELHORIAS or current_tab == INVENTARIO_TAB.ESSENCIAS) {
        // Agora passamos o _cont_h também!
        desenha_painel_info(_area_desc_x, _area_desc_w, _cont_y, _cont_h);
    }
    
    draw_set_halign(-1); draw_set_valign(-1); draw_set_font(-1); draw_set_color(c_white);
}