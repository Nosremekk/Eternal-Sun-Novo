is_pause_mode = global.pause;

enum MENU_TIPO {
    PRINCIPAL, PAUSE, SAVES, OPCOES, JOGO, SOM, VIDEO, TECLADO, CONTROLE,
    SLOT_CONFIRM, DELETE_CONFIRM, EXIT_CONFIRM
}

// Config
tipo_menu = is_pause_mode ? MENU_TIPO.PAUSE : MENU_TIPO.PRINCIPAL;
id_menu = 0;
history_menu = ds_stack_create();

// Audio & Input
musica_volume = global.music_volume * 10;
sfx_volume = global.sfx_volume * 10;
vibracao_ligada = !InputVibrateGetPause(0); 
ultimo_modo_era_gamepad = -1; 

// Idiomas
idiomas_codigos = ["pt", "en"];
idiomas_lista = ["Português", "English"];
idioma_index = 0;

for (var i = 0; i < array_length(idiomas_codigos); i++)
{
    if (global.idioma_atual == idiomas_codigos[i]) { idioma_index = i; break; }
}

// Video
modo_janela_lista = ["video_janela", "video_tela_cheia"];
modo_janela_index = window_get_fullscreen() ? 1 : 0;
vsync_ligado = display_get_frequency() >= 60;
resolucoes_lista = [[0, 0], [1280, 720], [1366, 768], [1920, 1080], [2560, 1440]];
timer_centralizar = 0;

get_res_text = function(_idx)
{
    if (_idx == 0) return get_text("video_res_auto");
    return string(resolucoes_lista[_idx][0]) + "x" + string(resolucoes_lista[_idx][1]);
}

// --- ESTRUTURA DOS MENUS ---
menu = [];
menu[MENU_TIPO.PRINCIPAL]      = ["menu_jogar", "menu_opcoes", "menu_sair"];
menu[MENU_TIPO.PAUSE]          = ["menu_continuar", "menu_opcoes", "menu_sair_titulo"];
menu[MENU_TIPO.SAVES]          = ["slot_1", "slot_2", "slot_3", "slot_4", "slot_5", "menu_voltar"];
menu[MENU_TIPO.SLOT_CONFIRM]   = ["menu_carregar", "menu_copiar", "menu_deletar", "menu_voltar"];
menu[MENU_TIPO.DELETE_CONFIRM] = ["menu_nao", "menu_sim"];
menu[MENU_TIPO.EXIT_CONFIRM]   = ["menu_nao", "menu_sim"];
menu[MENU_TIPO.JOGO]           = ["opt_idioma", "menu_voltar"];
menu[MENU_TIPO.SOM]            = ["opt_volume_mestre", "opt_volume_musica", "opt_volume_sfx", "opt_mute_foco", "menu_voltar"];
menu[MENU_TIPO.VIDEO]          = ["opt_modo_janela", "opt_resolucao", "opt_vsync", "opt_screenshake", "opt_ui_scale", "menu_voltar"];
menu[MENU_TIPO.OPCOES]         = [];

// --- MODIFICADO: Menu Teclado (Inserido "opt_teclado_magia") ---
menu[MENU_TIPO.TECLADO] = [
    "opt_teclado_cima", "opt_teclado_baixo", "opt_teclado_esquerda", "opt_teclado_direita",
    "opt_teclado_pular", "opt_teclado_atacar", "opt_teclado_dash", "opt_teclado_gancho", "opt_teclado_inventario", 
    "opt_teclado_magia", "opt_teclado_resetar", "menu_voltar"
];

// --- MODIFICADO: Menu Controle (Inserido "opt_controle_magia") ---
menu[MENU_TIPO.CONTROLE] = [
    "opt_controle_pular", "opt_controle_atacar", "opt_teclado_dash", "opt_teclado_gancho", "opt_teclado_inventario", 
    "opt_controle_magia", "opt_controle_vibrar", "opt_resetar_padrao", "menu_voltar"
];

// Sistema
slot_selecionado = -1;

ler_dados_save_simples = function(_idx)
{
    var _arquivo = "Save0" + string(_idx+1) + ".json";
    if (!file_exists(_arquivo)) return undefined;
    
    try {
        var _file = file_text_open_read(_arquivo);
        var _conteudo = "";

        while (!file_text_eof(_file)) {
            _conteudo += file_text_readln(_file);
        }
        file_text_close(_file);
        
        try {
            var _json_str = base64_decode(_conteudo);
            if (string_char_at(_json_str, 1) == "{") {
                return json_parse(_json_str);
            }
            throw("Formato inválido");
        } 
        catch(e) {
            return json_parse(_conteudo);
        }
    } catch(e) {
        return undefined;
    }
}

slots_info = array_create(5, undefined);
carregar_cache_saves = function() {
    for (var i = 0; i < 5; i++) {
        var _dados = ler_dados_save_simples(i);
        
        if (is_struct(_dados) and variable_struct_exists(_dados, "info")) {
            slots_info[i] = _dados.info;
        } 
        else if (is_struct(_dados)) {
            slots_info[i] = { area_atual: "???", tempo_formatado: "--:--", porcentagem: 0, data_save: "" };
        }
        else {
            slots_info[i] = undefined;
        }
    }
}
carregar_cache_saves(); 

mudar_menu = function(_novo_menu)
{
    InputVerbConsume(INPUT_VERB.UI_CONFIRM);
    InputVerbConsume(INPUT_VERB.JUMP);
    
    ds_stack_push(history_menu, tipo_menu);
    tipo_menu = _novo_menu;
    id_menu = 0;
}

voltar_menu = function()
{
    if (rebinding_mode)
    {
        InputDeviceStopAllRebinding();
        rebinding_mode = false;
        msg_erro_timer = 0;
        return;
    }

    if (ds_stack_empty(history_menu))
    {
        if (is_pause_mode)
        {
            global.pause = false;
            salvar_config(); 
            salvar_config_ui();
            InputVerbConsumeAll();
            instance_destroy(); 
        }
        return;
    }
    
    var _menu_anterior = tipo_menu;
    
    tipo_menu = ds_stack_pop(history_menu);
    id_menu = 0;
    efeito_sonoro(sfx_pause, 50, 0.05);
    
    if (_menu_anterior == MENU_TIPO.SOM or 
        _menu_anterior == MENU_TIPO.VIDEO or 
        _menu_anterior == MENU_TIPO.CONTROLE or
        _menu_anterior == MENU_TIPO.TECLADO)
    {
        salvar_config();
        salvar_config_ui();
        show_debug_message("Menu: Configs salvas ao voltar.");
    }
}

// Rebind Vars
rebinding_mode = false; 
verbo_em_edicao = undefined;
rebind_device = undefined; 
rebind_is_gamepad = false;
msg_erro_timer = 0; 

// --- MODIFICADO: Mapas de rebind (Adicionado INPUT_VERB.MAGIC no índice 9 e 5 respectivamente) ---
mapa_rebind_teclado = [
    INPUT_VERB.UP, INPUT_VERB.DOWN, INPUT_VERB.LEFT, INPUT_VERB.RIGHT,
    INPUT_VERB.JUMP, INPUT_VERB.ATTACK, INPUT_VERB.DASH, INPUT_VERB.HOOK, INPUT_VERB.OPEN_INVENTORY,
    INPUT_VERB.MAGIC, -1, -1 
];

mapa_rebind_controle = [
    INPUT_VERB.JUMP, INPUT_VERB.ATTACK, INPUT_VERB.DASH, INPUT_VERB.HOOK, INPUT_VERB.OPEN_INVENTORY, 
    INPUT_VERB.MAGIC, -1, -1, -1 
];

// Sistema de Notificação (Toast)
notificacao_texto = "";
notificacao_timer = 0; 
notificacao_cor   = c_lime;

desenha_tooltip = function(_gui_w, _gui_h, _chave_desc) {
    if (_chave_desc == "" or !variable_struct_exists(global.text, _chave_desc)) return;
    var _s = 1.0; 
    var _texto_desc = global.text[$ _chave_desc];
    
    draw_set_font(fnt_dialogo); draw_set_halign(fa_center); draw_set_valign(fa_middle);
    var _cx = _gui_w / 2;
    var _desc_y = _gui_h - (60 * _s); 
    var _desc_scale = 0.65 * _s;
    var _linha_y = _desc_y - (25 * _s); 
    var _linha_largura = 300 * _s;
    
    draw_primitive_begin(pr_linestrip);
    draw_vertex_color(_cx - _linha_largura, _linha_y, c_white, 0); 
    draw_vertex_color(_cx, _linha_y, c_white, 0.5); 
    draw_vertex_color(_cx + _linha_largura, _linha_y, c_white, 0);
    draw_primitive_end();

    draw_set_color(c_black); draw_set_alpha(0.8);
    draw_text_transformed(_cx + 2, _desc_y + 2, _texto_desc, _desc_scale, _desc_scale, 0);
    draw_set_color(c_ltgray); draw_set_alpha(0.9);      
    draw_text_transformed(_cx, _desc_y, _texto_desc, _desc_scale, _desc_scale, 0);
    draw_set_alpha(1); draw_set_color(c_white);
}

desenha_notificacao = function(_gui_w, _gui_h) {
    if (notificacao_timer <= 0) return;
    var _s = 1.0;
    draw_set_font(fnt_dialogo);
    
    // Animação
    var _alpha_notif = 1;
    var _y_offset_anim = 0;
    var _timer_max = 2.0; 
    
    if (notificacao_timer > (_timer_max - 0.5)) {
        var _progresso = (_timer_max - notificacao_timer) / 0.5;
        var _ease = sin(_progresso * pi / 2); 
        _alpha_notif = _ease; 
        _y_offset_anim = 30 * (1 - _ease);
    } else if (notificacao_timer < 0.5) {
        _alpha_notif = notificacao_timer / 0.5;
    }
    
    var _margin_right = 10 * _s;     
    var _margin_bottom = 40 * _s;
    var _pad_x = 15 * _s;
    var _pad_y = 8 * _s;
    
    var _txt_w = string_width(notificacao_texto);
    var _txt_h = string_height(notificacao_texto);
    var _box_w = _txt_w + (_pad_x * 2) + 8;
    var _box_h = _txt_h + (_pad_y * 2);
    var _x2 = _gui_w - _margin_right;
    var _x1 = _x2 - _box_w;
    var _y2 = (_gui_h - _margin_bottom) + _y_offset_anim;
    var _y1 = _y2 - _box_h;
    
    // Fundo Vidro
    draw_set_alpha(0.7 * _alpha_notif); draw_set_color(c_dkgray);
    draw_roundrect_ext(_x1, _y1, _x2, _y2, 8, 8, false);
    
    // Borda Glow
    draw_set_alpha(_alpha_notif); draw_set_color(notificacao_cor);
    draw_roundrect_ext(_x1, _y1, _x2, _y2, 8, 8, true);
    draw_roundrect_ext(_x1+1, _y1+1, _x2-1, _y2-1, 8, 8, true);

    // Texto
    draw_set_halign(fa_right);
    draw_set_valign(fa_middle);
    var _texto_x = _x2 - (15 * _s); 
    var _texto_y = _y1 + (_box_h / 2);
    
    draw_set_alpha(0.8 * _alpha_notif);
    draw_set_color(c_black);
    draw_text_transformed(_texto_x + 2, _texto_y + 2, notificacao_texto, _s, _s, 0);
    
    draw_set_alpha(_alpha_notif); draw_set_color(c_white);
    draw_text_transformed(_texto_x, _texto_y, notificacao_texto, _s, _s, 0);
    
    draw_set_alpha(1);
    draw_set_color(c_white); draw_set_halign(-1); draw_set_valign(-1);
}

InputVerbConsumeAll();