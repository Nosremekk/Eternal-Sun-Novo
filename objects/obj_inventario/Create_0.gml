current_tab = INVENTARIO_TAB.AMULETOS;
cursor_col  = 0; 
cursor_row  = 0; 
scroll_row  = 0; 


cursor_lerp_x = 0;
cursor_lerp_y = 0;
cursor_scale  = 1; 


key_item_cols = 4;
array_itens_filtrados = [];
surf_items = -1; 
lista_abas = [INVENTARIO_TAB.AMULETOS, INVENTARIO_TAB.ITENS, INVENTARIO_TAB.MELHORIAS, INVENTARIO_TAB.ESSENCIAS];



// Filtra itens por aba
atualiza_lista_filtrada = function()
{
    array_itens_filtrados = [];
    if (current_tab == INVENTARIO_TAB.AMULETOS) return;

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
            InputVibrateConstant(0.05, 0.0, 20)    
        }
        if (_dy != 0) {
            cursor_row = (cursor_row + _dy + _lins) mod _lins;
            cursor_scale = 0.8; efeito_sonoro(sfx_menu_click, 50, 0.1);
            InputVibrateConstant(0.05, 0.0, 20)
        }
        
        if (_c.confirma) { 
            var _item = global.inventario[# cursor_col, cursor_row];
            if (is_struct(_item)) { _item.alterna_equipamento(); efeito_sonoro(sfx_pause, 50, 0.1); }
        }
    }
    // Listas
    else 
    {
        var _total = array_length(array_itens_filtrados);
        if (_total == 0) { if (_dx != 0) _troca_aba = _dx; }
        else
        {
            var _rows = max(1, ceil(_total / key_item_cols));
            if (_dx != 0) 
            {
                var _ncol = cursor_col + _dx;
                if (_ncol >= key_item_cols) _troca_aba = 1;
                else if (_ncol < 0) _troca_aba = -1;
                else {
                    var _idx = (cursor_row * key_item_cols) + _ncol;
                    if (_idx < _total) { cursor_col = _ncol; cursor_scale = 0.8; efeito_sonoro(sfx_menu_click, 50, 0.1); }
                    else if (_dx > 0) _troca_aba = 1; 
                }
            }
            if (_dy != 0) {
                var _nr = cursor_row + _dy;
                if (_nr >= 0 and _nr < _rows) {
                    var _idx = (_nr * key_item_cols) + cursor_col;
                    if (_idx >= _total) cursor_col = (_total - 1) % key_item_cols;
                    cursor_row = _nr;
                    cursor_scale = 0.8; efeito_sonoro(sfx_menu_click, 50, 0.1);
                    if (cursor_row < scroll_row) scroll_row = cursor_row;
                    if (cursor_row > scroll_row + 2) scroll_row = cursor_row - 2; 
                }
            }
        }
    }

    // Executa Troca de Aba
    if (_troca_aba != 0)
    {
        var _idx = 0;
        for (var i = 0; i < array_length(lista_abas); i++) if (lista_abas[i] == current_tab) { _idx = i; break; }
        current_tab = lista_abas[(_idx + _troca_aba + 4) % 4];
        
        cursor_lerp_x = -1; 
        atualiza_lista_filtrada();
        cursor_row = 0; scroll_row = 0;
        
        if (_troca_aba == 1) cursor_col = 0;
        else {
            if (current_tab == INVENTARIO_TAB.AMULETOS) cursor_col = ds_grid_width(global.inventario) - 1;
            else {
                cursor_col = key_item_cols - 1;
                var _tot = array_length(array_itens_filtrados);
                if (current_tab != INVENTARIO_TAB.AMULETOS and _tot > 0) 
                    while ((cursor_row * key_item_cols) + cursor_col >= _tot and cursor_col > 0) cursor_col--;
            }
        }
        efeito_sonoro(sfx_menu_click, 50, 0.15);
        InputVibrateConstant(0.1, 0.0, 30)
    }
    
    // Sair
    if (_c.voltar_btn or _c.abre_inventario or _c.aplica_pause) {
        InputVerbConsumeAll();
        global.abre_inventario = false;
        global.pause = false;
        instance_destroy();      
    }    
}

// Renderização Principal
desenha_inventario = function()
{
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    
    // --- 2. DEFINIÇÃO DE FONTE OBRIGATÓRIA ---
    // Isso conserta o problema de "sem fonte" e "texto pequeno"
    draw_set_font(fnt_dialogo); // <--- GARANTA QUE ESSA FONTE TENHA O RANGE LATIN 1 E SDF
    
    // Layout
    var _inv_w = _gui_w * 0.80; 
    var _inv_h = _gui_h * 0.80;
    var _inv_x = (_gui_w - _inv_w)/2; 
    var _inv_y = (_gui_h - _inv_h)/2;
    
    var _pad_x = _inv_w * 0.03; 
    var _pad_y = _inv_h * 0.05; 
    var _head_h = _inv_h * 0.15;
    
    var _cont_y = _inv_y + _head_h;
    var _cont_h = _inv_h - _head_h - _pad_y;
    
    var _area_itens_w = (_inv_w - (_pad_x*3)) * 0.60;
    var _area_desc_w  = (_inv_w - (_pad_x*3)) * 0.40;
    var _area_itens_x = _inv_x + _pad_x;
    var _area_desc_x  = _area_itens_x + _area_itens_w + _pad_x;
    
    draw_sprite_stretched(spr_inventario_fundo, 0, _inv_x, _inv_y, _inv_w, _inv_h);
    
    // Abas
    draw_set_valign(fa_middle); draw_set_halign(fa_center); 
    var _tab_y = _inv_y + (_head_h / 2);
    
    var _keys = ["tab_amuletos", "tab_itens", "tab_melhorias", "tab_essencias"];
    var _enums = [INVENTARIO_TAB.AMULETOS, INVENTARIO_TAB.ITENS, INVENTARIO_TAB.MELHORIAS, INVENTARIO_TAB.ESSENCIAS];
    var _div = _inv_w / 4; 
    
    for (var i = 0; i < 4; i++) {
        var _sel = (current_tab == _enums[i]);
        var _c = _sel ? c_white : c_gray;
        var _txt = get_text(_keys[i]);
        var _tx = _inv_x + (_div*i) + (_div/2);
        
        if (_sel) draw_text_color(_tx, _tab_y, "["+_txt+"]", c_yellow, c_yellow, c_yellow, c_yellow, 1);
        else draw_text_color(_tx, _tab_y, _txt, _c, _c, _c, _c, 0.4);
    }
    
    cursor_scale = lerp(cursor_scale, 1, 0.2);

    // --- GRID AMULETOS ---
    if (current_tab == INVENTARIO_TAB.AMULETOS)
    {
        var _cols = ds_grid_width(global.inventario);
        var _lins = ds_grid_height(global.inventario);
        var _sep = 8; 
        var _sz = min((_area_itens_w - ((_cols-1)*_sep))/_cols, ((_cont_h-30)-((_lins-1)*_sep))/_lins);
        
        var _tx = 0; var _ty = 0; 
        
        // 1. Desenha Fundos
        for (var _i = 0; _i < _lins; _i++) {
            for (var _j = 0; _j < _cols; _j++) {
                var _xx = _area_itens_x + _j * (_sz + _sep);
                var _yy = _cont_y + _i * (_sz + _sep);
                var _item = global.inventario[# _j, _i];
                
                if (cursor_col == _j and cursor_row == _i) { _tx = _xx; _ty = _yy; }
                
                var _frm = (is_struct(_item) and _item.equipado) ? 2 : 0;   
                draw_sprite_stretched(spr_inventario_caixa, _frm, _xx, _yy, _sz, _sz);
            }
        }
        
        // 2. Desenha Cursor (Em cima do fundo, Em baixo do item)
        if (cursor_lerp_x == -1) { cursor_lerp_x = _tx; cursor_lerp_y = _ty; }
        else { cursor_lerp_x = lerp(cursor_lerp_x, _tx, 0.25); cursor_lerp_y = lerp(cursor_lerp_y, _ty, 0.25); }
        
        var _csz = _sz * cursor_scale;
        draw_sprite_stretched(spr_inventario_caixa, 1, cursor_lerp_x + (_sz-_csz)/2, cursor_lerp_y + (_sz-_csz)/2, _csz, _csz);

        // 3. Desenha Itens
        for (var _i = 0; _i < _lins; _i++) {
            for (var _j = 0; _j < _cols; _j++) {
                var _xx = _area_itens_x + _j * (_sz + _sep);
                var _yy = _cont_y + _i * (_sz + _sep);
                var _item = global.inventario[# _j, _i];
                
                if (is_struct(_item)) {
                    var _p = _sz * 0.15;
                    draw_sprite_stretched(_item.spr, _item.meu_id, _xx+_p, _yy+_p, _sz-(_p*2), _sz-(_p*2));
                }
            }
        }
        
        draw_set_halign(fa_left); draw_set_valign(fa_bottom);
        draw_text(_area_itens_x, _inv_y + _inv_h - (_pad_y/2), get_text("inv_slots") + " " + string(global.player_slots_usados) + "/" + string(global.player_slots_maximos));
    }
    // --- LISTAS ---
    else 
    {
        var _cols = key_item_cols; var _sep = 8;
        var _sz = (_area_itens_w - ((_cols-1) * _sep)) / _cols;
        
        if (!surface_exists(surf_items)) surf_items = surface_create(_area_itens_w, _cont_h);
        
        surface_set_target(surf_items);
        draw_clear_alpha(c_black, 0); 
        
        var _len = array_length(array_itens_filtrados);
        if (_len == 0) { 
            draw_set_halign(fa_center); draw_set_valign(fa_middle);
            draw_set_color(c_gray); draw_text(_area_itens_w/2, _cont_h/2, get_text("inv_vazio"));
        }
        else
        {
            var _tx = -1; var _ty = -1;

            // 1. Fundos
            for (var i = 0; i < _len; i++) {
                var _c = i mod _cols; var _r = i div _cols;
                var _xx = _c * (_sz + _sep);
                var _yy = (_r * (_sz + _sep)) - (scroll_row * (_sz + _sep));
                
                if (cursor_col == _c and cursor_row == _r) { _tx = _xx; _ty = _yy; }
                if (_yy + _sz > 0 and _yy < _cont_h) draw_sprite_stretched(spr_inventario_caixa, 0, _xx, _yy, _sz, _sz);
            }

            // 2. Cursor
            if (_tx != -1) {
                if (cursor_lerp_x == -1) { cursor_lerp_x = _tx; cursor_lerp_y = _ty; }
                else { cursor_lerp_x = lerp(cursor_lerp_x, _tx, 0.25); cursor_lerp_y = lerp(cursor_lerp_y, _ty, 0.25); }
                var _csz = _sz * cursor_scale;
                draw_sprite_stretched(spr_inventario_caixa, 1, cursor_lerp_x + (_sz-_csz)/2, cursor_lerp_y + (_sz-_csz)/2, _csz, _csz);
            }

            // 3. Itens
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
        draw_surface(surf_items, _area_itens_x, _cont_y);
    }
    
    // Painel Info
    var _sel = undefined;
    if (current_tab == INVENTARIO_TAB.AMULETOS) _sel = global.inventario[# cursor_col, cursor_row];
    else {
        var _idx = cursor_col + (cursor_row * key_item_cols);
        if (_idx < array_length(array_itens_filtrados)) _sel = array_itens_filtrados[_idx];
    }
    
    if (_sel != undefined and _sel != 0) {
        var _d = pega_dados_item(_sel);
        if (_d != undefined) {
            var _isz = 96; var _ixc = _area_desc_x + (_area_desc_w - _isz)/2;
            var _frm = is_struct(_sel) ? _sel.meu_id : 0;
            draw_sprite_stretched(_d.spr, _frm, _ixc, _cont_y, _isz, _isz);
            
            draw_set_halign(fa_center); draw_set_valign(fa_top);
            draw_set_color(c_yellow); draw_text_ext(_area_desc_x + _area_desc_w/2, _cont_y + 120, get_text(_d.nome_key), 24, _area_desc_w);
            draw_set_color(c_white); 
            
            var _desc = get_text(_d.desc_key);
            if (current_tab != INVENTARIO_TAB.AMULETOS) {
                 var _q = global.itens_chave[? _sel];
                 if (_q > 1) _desc += "\n(x" + string(_q) + ")";
            }
            draw_text_ext(_area_desc_x + _area_desc_w/2, _cont_y + 160, _desc, 20, _area_desc_w);
        }
    }
    draw_set_halign(-1); draw_set_valign(-1); draw_set_font(-1); draw_set_color(c_white);
}