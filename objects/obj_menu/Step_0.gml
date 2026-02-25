var _usa_gamepad = InputPlayerUsingGamepad(0);

if (_usa_gamepad != ultimo_modo_era_gamepad)
{
    ultimo_modo_era_gamepad = _usa_gamepad;
    var _btn_input = _usa_gamepad ? "menu_controle" : "menu_teclado";
    var _voltar_key = is_pause_mode ? "menu_voltar_jogo" : "menu_voltar";
    menu[MENU_TIPO.OPCOES] = ["menu_jogo", "menu_som", "menu_video", _btn_input, _voltar_key];
    
    if ((tipo_menu == MENU_TIPO.TECLADO and _usa_gamepad) or (tipo_menu == MENU_TIPO.CONTROLE and !_usa_gamepad))
    {
        if (rebinding_mode) {
            InputDeviceStopAllRebinding();
            rebinding_mode = false;
            verbo_em_edicao = undefined;
            rebind_device = undefined;
            msg_erro_timer = 0;
        }
        voltar_menu();
    }
}

if (rebinding_mode) 
{
    if (rebind_device != undefined) {
        var _novo_binding = InputDeviceGetRebindingResult(rebind_device);
        if (_novo_binding != undefined) {
            InputBindingSetSafe(rebind_is_gamepad, verbo_em_edicao, _novo_binding); 
            InputDeviceStopAllRebinding();
            rebinding_mode = false;
            verbo_em_edicao = undefined;
            rebind_device = undefined;
        }
    }
    if (InputPressed(INPUT_VERB.PAUSE)) {
        InputDeviceStopAllRebinding();
        rebinding_mode = false;
    }
    exit; 
}

if (msg_erro_timer > 0) msg_erro_timer--;

var _inputs = controles_menu();
id_menu = up_down(id_menu, menu[tipo_menu]);

if (_inputs.voltar_btn) voltar_menu();

var _change = (_inputs.direita - _inputs.esquerda);

if (_change != 0)
{
    switch (tipo_menu)
    {
        case MENU_TIPO.SOM:
            if (id_menu == 0) { global.master_volume = clamp(global.master_volume + (_change * 0.1), 0, 1);
            audio_master_gain(global.master_volume); }
            if (id_menu == 1) { global.music_volume = clamp(global.music_volume + (_change * 0.1), 0, 1);
            if (variable_global_exists("ag_gameplay")) audio_group_set_gain(ag_gameplay, global.music_volume, 0); }
            if (id_menu == 2) { 
                var _vol_ant = global.sfx_volume;
                global.sfx_volume = clamp(global.sfx_volume + (_change * 0.1), 0, 1);
                if (_vol_ant != global.sfx_volume) efeito_sonoro(sfx_menu_click, 50, 0.5);
            }
            if (id_menu == 3) { global.mute_on_focus_lost = !global.mute_on_focus_lost;
            }
        break;

        case MENU_TIPO.JOGO:
            if (id_menu == 0) { 
                idioma_index += _change;
                var _len = array_length(idiomas_codigos);
                if (idioma_index < 0) idioma_index = _len - 1;
                else if (idioma_index >= _len) idioma_index = 0;
                carregar_idioma(idiomas_codigos[idioma_index]);
            }
        break;

        case MENU_TIPO.VIDEO:
            var _precisa_atualizar_tela = false;
            var _fullscreen_alterado = false;

            if (id_menu == 0) { 
                modo_janela_index = !modo_janela_index;
                _precisa_atualizar_tela = true; 
                _fullscreen_alterado = true;
            }
            
            if (id_menu == 1) { 
                global.resolucao_index += _change;
                var _len = array_length(resolucoes_lista);
                if (global.resolucao_index < 0) global.resolucao_index = _len - 1;
                else if (global.resolucao_index >= _len) global.resolucao_index = 0;
                _precisa_atualizar_tela = true;
            }
            
            if (id_menu == 2) { vsync_ligado = !vsync_ligado;
            display_reset(0, vsync_ligado); }
            
            if (id_menu == 3) { global.screenshake_mult = clamp(global.screenshake_mult + (_change * 0.1), 0, 2.0); }
            
            if (id_menu == 4) { global.ui_scale = clamp(global.ui_scale + (_change * 0.1), 0.8, 1.2);
            _precisa_atualizar_tela = true; }
            
            if (_precisa_atualizar_tela) {
                var _w, _h;
                var _is_full = (modo_janela_index == 1);

                if (_is_full) { 
                    _w = display_get_width();
                    _h = display_get_height(); 
                }
                else {
                    var _res = resolucoes_lista[global.resolucao_index];
                    if (_res[0] == 0) { 
                        _w = display_get_width() * 0.8;
                        _h = display_get_height() * 0.8; 
                    }
                    else { 
                        _w = _res[0];
                        _h = _res[1]; 
                    }
                }
                
                aplicar_resolucao(_w, _h, _is_full);
                if (_fullscreen_alterado) {
                     display_reset(0, vsync_ligado);
                }

                if (!_is_full) {
                    timer_centralizar = 15;
                    alarm[0] = 1; 
                }
            }
        break;

        case MENU_TIPO.CONTROLE:
            // --- MODIFICADO: id_menu == 6 para Vibração (antes era 5) ---
            if (id_menu == 6) { 
                vibracao_ligada = !vibracao_ligada;
                InputVibrateSetPause(!vibracao_ligada, 0); 
                if (vibracao_ligada) InputVibrateConstant(0.5, 0, 200, 0, true); 
            }
        break;
    }
}

if (_inputs.confirma)
{
    var _toca_confirm = function() { efeito_sonoro(sfx_pause, 50, 0.1); };
    switch (tipo_menu)
    {
        case MENU_TIPO.PRINCIPAL:
            if (id_menu == 0) { _toca_confirm(); mudar_menu(MENU_TIPO.SAVES); }
            else if (id_menu == 1) { _toca_confirm(); mudar_menu(MENU_TIPO.OPCOES); }
            else if (id_menu == 2) { _toca_confirm(); mudar_menu(MENU_TIPO.EXIT_CONFIRM); } 
        break;

        case MENU_TIPO.PAUSE:
            if (id_menu == 0) { 
                _toca_confirm();
                InputVerbConsume(INPUT_VERB.JUMP); InputVerbConsume(INPUT_VERB.UI_CONFIRM);
                global.pause = false; salvar_config(); salvar_config_ui(); instance_destroy(); 
            }
            else if (id_menu == 1) { _toca_confirm(); mudar_menu(MENU_TIPO.OPCOES); }
            else if (id_menu == 2) { 
                _toca_confirm();
                InputVerbConsumeAll(); global.pause = false; 
                salvar_config(); salvar_config_ui(); salvando_jogo(global.save,false);
                reset_variaveis_jogo(); IniciarTransicao(rm_menu); 
            }
        break;

        case MENU_TIPO.SAVES:
            if (id_menu < 5) {
                var _arquivo = "Save0" + string(id_menu + 1) + ".json";
                if (file_exists(_arquivo)) {
                    _toca_confirm();
                    slot_selecionado = id_menu; mudar_menu(MENU_TIPO.SLOT_CONFIRM);
                } else {
                    _toca_confirm();
                    global.save = id_menu; reset_variaveis_jogo(); IniciarTransicao(rm_level_demo); 
                }
            } else voltar_menu();
        break;
    
        case MENU_TIPO.SLOT_CONFIRM:
            if (id_menu == 0) { 
                _toca_confirm();
                global.save = slot_selecionado; carrega_jogo(slot_selecionado); 
            }
            else if (id_menu == 1) {
                var _resultado = copiar_save(slot_selecionado);
                if (_resultado != -1) {
                    _toca_confirm();
                    notificacao_texto = get_text("msg_copia_sucesso") + string(_resultado + 1);
                    notificacao_timer = 2.0; 
                    notificacao_cor   = c_lime;
                    
                    var _info_origem = slots_info[slot_selecionado];
                    if (_info_origem != undefined) {
                        slots_info[_resultado] = {
                            tempo_formatado: _info_origem.tempo_formatado,
                            porcentagem:     _info_origem.porcentagem,
                            area_atual:      _info_origem.area_atual,
                            data_save:       _info_origem.data_save
                        };
                    } else {
                        slots_info[_resultado] = { area_atual: "???", tempo_formatado: "--:--", porcentagem: 0, data_save: "" };
                    }
                    voltar_menu();
                } else {
                    efeito_sonoro(sfx_error, 100, 0.1);
                    notificacao_texto = get_text("msg_erro_slots_cheios");
                    notificacao_timer = 2.0;
                    notificacao_cor   = c_red;
                }
            }
            else if (id_menu == 2) { 
                _toca_confirm();
                mudar_menu(MENU_TIPO.DELETE_CONFIRM); 
            }
            else if (id_menu == 3) { voltar_menu(); }
        break;
    
        case MENU_TIPO.DELETE_CONFIRM:
            if (id_menu == 0) voltar_menu();
            else if (id_menu == 1) {
                _toca_confirm();
                var _arquivo_del = "Save0" + string(slot_selecionado + 1) + ".json";
                if (file_exists(_arquivo_del)) file_delete(_arquivo_del);
                slots_info[slot_selecionado] = undefined;
                ds_stack_pop(history_menu); ds_stack_pop(history_menu);
                tipo_menu = MENU_TIPO.SAVES; id_menu = slot_selecionado; 
            }
        break;

        case MENU_TIPO.EXIT_CONFIRM:
            if (id_menu == 0) voltar_menu();
            else if (id_menu == 1) game_end();
        break;

        case MENU_TIPO.OPCOES:
            if (id_menu < 3) { _toca_confirm();
                var _maps = [MENU_TIPO.JOGO, MENU_TIPO.SOM, MENU_TIPO.VIDEO]; mudar_menu(_maps[id_menu]); }
            else if (id_menu == 3) { 
                _toca_confirm();
                if (InputPlayerUsingGamepad(0)) mudar_menu(MENU_TIPO.CONTROLE);
                else mudar_menu(MENU_TIPO.TECLADO);
            }
            else if (id_menu == 4) voltar_menu();
        break;

        case MENU_TIPO.TECLADO:
            // --- MODIFICADO: Índices reajustados para 10 (Reset) e 11 (Voltar) ---
            if (id_menu == 10) { _toca_confirm(); InputBindingsReset(false, 0); }
            else if (id_menu == 11) {
                if (InputBindingGet(false, INPUT_VERB.JUMP) != undefined and InputBindingGet(false, INPUT_VERB.DASH) != undefined) voltar_menu();
                else { efeito_sonoro(sfx_error, 100, 0.1); msg_erro_timer = 60; }
            } else { 
                if (InputPlayerUsingGamepad(0)) { msg_erro_timer = 30; break; }
                _toca_confirm();
                verbo_em_edicao = mapa_rebind_teclado[id_menu]; rebinding_mode = true; rebind_is_gamepad = false;
                var _devs = InputDeviceEnumerate(true); rebind_device = undefined;
                for(var i = 0; i < array_length(_devs); i++) if (!InputDeviceIsGamepad(_devs[i])) { rebind_device = _devs[i]; break; }
                if (rebind_device != undefined) InputDeviceSetRebinding(rebind_device, true, [vk_escape, vk_enter, vk_backspace]);
                else rebinding_mode = false; 
            }
        break;

        case MENU_TIPO.CONTROLE:
            // --- MODIFICADO: Índices reajustados para 6 (Vibrar), 7 (Reset) e 8 (Voltar) ---
            if (id_menu == 6) { vibracao_ligada = !vibracao_ligada;
                InputVibrateSetPause(!vibracao_ligada, 0); if (vibracao_ligada) InputVibrateConstant(0.5, 0, 200, 0, true); }
            else if (id_menu == 7) { _toca_confirm(); InputBindingsReset(true, 0); }
            else if (id_menu == 8) {
                if (InputBindingGet(true, INPUT_VERB.JUMP) != undefined and InputBindingGet(true, INPUT_VERB.DASH) != undefined) voltar_menu();
                else { efeito_sonoro(sfx_error, 100, 0.1); msg_erro_timer = 60; }
            } else { 
                if (!InputPlayerUsingGamepad(0)) { msg_erro_timer = 30; break; }
                _toca_confirm();
                verbo_em_edicao = mapa_rebind_controle[id_menu]; rebinding_mode = true; rebind_is_gamepad = true;
                var _dev = InputPlayerGetDevice(0);
                if (!InputDeviceIsGamepad(_dev)) {
                      var _devs = InputDeviceEnumerate();
                      for(var i = 0; i < array_length(_devs); i++) if (InputDeviceIsGamepad(_devs[i])) { _dev = _devs[i]; break; }
                }
                rebind_device = _dev;
                InputDeviceSetRebinding(rebind_device, true, [gp_start, gp_select, gp_padu, gp_padd, gp_padl, gp_padr, gp_axislh, gp_axislv, gp_axisrh, gp_axisrv]);
            }
        break;

        default: var _len = array_length(menu[tipo_menu]);
        if (id_menu == _len - 1) voltar_menu(); break;
    }
}

if (notificacao_timer > 0) {
    notificacao_timer -= desconta_timer();
}