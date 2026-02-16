var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _s = 1.0; 

// 1. Fundo (Dimmer)
if (is_pause_mode) {
    draw_set_color(c_black); draw_set_alpha(0.7);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1.0); draw_set_color(c_white);
}

var _cx = _gui_w / 2;
var _cy = _gui_h / 2;
draw_set_halign(fa_center); draw_set_valign(fa_middle);
draw_set_font(fnt_dialogo);

var _array_atual = menu[tipo_menu];
var _y_spacing = 48 * _s; 
var _yy_start = _cy - (array_length(_array_atual) - 1) * _y_spacing / 2;
var _chave_descricao_selecionada = "";

// 2. Loop Principal de Desenho do Menu
for (var _i = 0; _i < array_length(_array_atual); _i++)
{
    var _chave = _array_atual[_i];
    var _texto = get_text(_chave);
    
    if (id_menu == _i) _chave_descricao_selecionada = "desc_" + _chave;
    
    var _verbo_icone = undefined;
    var _mostra_rebind_anim = false;

    // Lógica Específica por Menu
    if (tipo_menu == MENU_TIPO.TECLADO and _i < 9) {
        if (rebinding_mode and id_menu == _i) _mostra_rebind_anim = true; else _verbo_icone = mapa_rebind_teclado[_i];
    } else if (tipo_menu == MENU_TIPO.CONTROLE and _i < 5) {
        if (rebinding_mode and id_menu == _i) _mostra_rebind_anim = true; else _verbo_icone = mapa_rebind_controle[_i];
    }
    
    if (tipo_menu == MENU_TIPO.SAVES and _i < 5) {
        var _info = slots_info[_i];
        if (_info == undefined) _texto = get_text("menu_slot") + " " + string(_i+1) + " - " + get_text("menu_vazio");
        else {
            if (variable_struct_exists(_info, "tempo_formatado")) _texto = get_text("menu_slot") + " " + string(_i+1) + " | " + string(_info.porcentagem) + "% | " + _info.tempo_formatado;
            else _texto = get_text("menu_slot") + " " + string(_i+1) + " - " + get_text("menu_carregar");
        }
        if (id_menu == _i) _chave_descricao_selecionada = ""; 
    }

    switch (tipo_menu) {
       case MENU_TIPO.SOM:
           var _vals = [global.master_volume, global.music_volume, global.sfx_volume];
           if (_i < 3) _texto += " < " + string(round(_vals[_i] * 100)) + "% >";
           if (_i == 3) _texto += " < " + (global.mute_on_focus_lost ? get_text("opt_ligado") : get_text("opt_desligado")) + " >";
       break;
       case MENU_TIPO.JOGO: if (_i == 0) _texto += " < " + idiomas_lista[idioma_index] + " >"; break;
       case MENU_TIPO.VIDEO:
           if (_i == 0) _texto += " < " + get_text(modo_janela_lista[modo_janela_index]) + " >";
           if (_i == 1) _texto += " < " + get_res_text(global.resolucao_index) + " >";
           if (_i == 2) _texto += " < " + (vsync_ligado ? get_text("opt_ligado") : get_text("opt_desligado")) + " >";
           if (_i == 3) _texto += " < " + string(round(global.screenshake_mult * 100)) + "% >";
           if (_i == 4) _texto += " < " + string(round(global.ui_scale * 100)) + "% >";
       break;
       case MENU_TIPO.CONTROLE: if (_i == 5) _texto += " < " + (vibracao_ligada ? get_text("opt_ligado") : get_text("opt_desligado")) + " >"; break;
    }

    // Configura Cores e Escala
    var _color = (id_menu == _i) ? c_yellow : c_white;
    var _scale_base = _s; 
    var _scale_text = _scale_base;
    
    if (id_menu == _i) {
        _scale_text = _scale_base + (((sin(current_time / 250) + 1) / 2) * 0.1 * _s);
        if (msg_erro_timer > 0) _color = c_red;
    }
    
    if ((tipo_menu == MENU_TIPO.SLOT_CONFIRM and _i == 2 and id_menu == _i) or
        (tipo_menu == MENU_TIPO.DELETE_CONFIRM and _i == 1 and id_menu == 1)) {
        _color = c_red;
    }

    if (tipo_menu == MENU_TIPO.DELETE_CONFIRM and _i == 0) { draw_set_color(c_red); draw_text_transformed(_cx, _yy_start - _y_spacing * 1.5, get_text("menu_tem_certeza"), _s, _s, 0); }
    if (tipo_menu == MENU_TIPO.EXIT_CONFIRM and _i == 0) { draw_set_color(c_white); draw_text_transformed(_cx, _yy_start - _y_spacing * 1.5, get_text("menu_sair_confirmacao"), _s, _s, 0); }
    
    // Desenha o Item
    var _yy = _yy_start + (_y_spacing * _i);
    draw_set_color(_color);
    
    if (_mostra_rebind_anim) {
        var _msg = rebind_is_gamepad ? get_text("msg_aguardando_input_gamepad") : get_text("msg_aguardando_input");
        draw_set_halign(fa_center); draw_text_transformed(_cx, _yy, _msg, _scale_text, _scale_text, 0);
    } else if (_verbo_icone != undefined) {
        var _escala_icone = 3.0 * _s; var _gap_centro = 30 * _s;  
        draw_set_halign(fa_right); draw_text_transformed(_cx - _gap_centro, _yy, _texto, _scale_text, _scale_text, 0);
        var _icon_x = _cx + _gap_centro + (16 * _escala_icone / 2); 
        desenha_input_verbo(_verbo_icone, _icon_x, _yy, _escala_icone);
    } else {
        draw_set_halign(fa_center); draw_text_transformed(_cx, _yy, _texto, _scale_text, _scale_text, 0);
    }
}

// 3. Funções Auxiliares (Agora o Draw GUI só chama elas)
desenha_tooltip(_gui_w, _gui_h, _chave_descricao_selecionada);
desenha_notificacao(_gui_w, _gui_h);

// 4. Versão
draw_set_halign(fa_right); draw_set_valign(fa_bottom);
draw_set_font(fnt_versao); draw_set_color(c_gray); draw_set_alpha(0.5);
var _versao = "v0.1.0 (Alpha)";
draw_text(_gui_w - 10, _gui_h - 10, _versao);

// Reset Final
draw_set_alpha(1); draw_set_color(c_white); draw_set_halign(-1); draw_set_valign(-1); draw_set_font(-1);