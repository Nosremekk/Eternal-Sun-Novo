global.dados_load_pendente = undefined; 
global.idioma_atual = "pt";
global.text = {};

// Save System
function salvando_jogo(_save = global.save, _eh_checkpoint = false)
{
    // 1. Definição de nomes de arquivo (Real e Temporário)
    var _arquivo_real = "Save0" + string(_save+1) + ".json";
    var _arquivo_temp = _arquivo_real + ".tmp"; 

    // --- PREPARAÇÃO DOS DADOS ---

    // Atualiza Respawn
    if (_eh_checkpoint) and (instance_exists(obj_player))
    {
        global.respawn_room = room_get_name(room);
        global.respawn_x    = obj_player.x;
        global.respawn_y    = obj_player.y;
    }

    // Conversão: Inventário Grid -> Struct
    var _struct_inventario = {};
    if (variable_global_exists("inventario") and ds_exists(global.inventario, ds_type_grid))
    {
        var _cols = ds_grid_width(global.inventario);
        var _lins = ds_grid_height(global.inventario);
        
        for (var i = 0; i < _lins; i++)
        {
            for (var j = 0; j < _cols; j++)
            {
                var _item = global.inventario[# j, i];
                if (is_struct(_item))
                {
                    var _pos_key = string(j) + "_" + string(i);
                    _struct_inventario[$ _pos_key] = _item.meu_id; 
                }
            }
        }
    }

    // Conversão: Amuletos List -> Array
    var _array_equipados = [];
    if (variable_global_exists("amuletos_equipados") and ds_exists(global.amuletos_equipados, ds_type_list))
    {
        for (var i = 0; i < ds_list_size(global.amuletos_equipados); i++)
        {
            array_push(_array_equipados, global.amuletos_equipados[| i].meu_id); 
        }
    }

    // Conversão: Itens Chave Map -> Struct
    var _struct_itens_chave = {};
    if (variable_global_exists("itens_chave") and ds_exists(global.itens_chave, ds_type_map))
    {
        var _k = ds_map_find_first(global.itens_chave);
        while (!is_undefined(_k)) 
        {
            _struct_itens_chave[$ _k] = global.itens_chave[? _k];
            _k = ds_map_find_next(global.itens_chave, _k);
        }
    }

    // --- CÁLCULOS DE METADADOS ---
    var _segundos_total = variable_global_exists("tempo_de_jogo_segundos") ? global.tempo_de_jogo_segundos : 0;
    
    var _h = floor(_segundos_total / 3600);
    var _m = floor((_segundos_total % 3600) / 60);
    var _s = floor(_segundos_total % 60);
    
    var _tempo_str = string_replace_all(string_format(_h, 2, 0) + ":" + string_format(_m, 2, 0) + ":" + string_format(_s, 2, 0), " ", "0");
    
    // Porcentagem
    var _porcentagem = 0; 
    if (variable_global_exists("bosses_mortos")) 
    {
        if (is_struct(global.bosses_mortos)) {
            _porcentagem = min(100, variable_struct_names_count(global.bosses_mortos) * 10); 
        }
        else if (ds_exists(global.bosses_mortos, ds_type_map)) {
            _porcentagem = min(100, ds_map_size(global.bosses_mortos) * 10); 
        }
    }

    var _area_nome = "Desconhecido";
    if (variable_global_exists("respawn_room")) _area_nome = global.respawn_room;

    // Pacote de Dados
    var _dados =
    {
        info: {
            tempo_formatado: _tempo_str,
            tempo_segundos: _segundos_total,
            porcentagem: _porcentagem,
            area_atual: _area_nome,
            data_save: date_datetime_string(date_current_datetime())
        },
        player :
        {
            x_save    : global.respawn_x,
            y_save    : global.respawn_y, 
            room_save : global.respawn_room,
            
            // ATUALIZADO: Agora salva as globais corretas
            vida      : global.vida_atual, // Salva quanto de vida tem AGORA
            velh_base : global.velh_base,  // Salva a velocidade BASE
            
            powerups  : global.powerups,
            dinheiro : global.dinheiro
        },
        amuletos :
        {
            slots_max        : global.player_slots_maximos,
            inventario_data : _struct_inventario,
            equipados_array : _array_equipados 
        },
        itens_chave_data : _struct_itens_chave,
        areas_visitadas  : global.areas_visitadas,
        bestiario_kills  : global.bestiario_kills,
        bosses_mortos    : global.bosses_mortos,
        eventos_mundo    : global.eventos,
        objetos          : global.permanentemente_quebrado,
        
        // --- NOVIDADE: DADOS DE ITENS E FRAGMENTOS ---
        itens_coletados  : global.itens_coletados,
        fragmentos_vida  : global.fragmentos_vida
    };
    
    // --- GRAVAÇÃO SEGURA COM ENCODE ---
    
    var _string_json = json_stringify(_dados);
    var _string_final = base64_encode(_string_json);
    
    var _file = file_text_open_write(_arquivo_temp);
    
    if (_file == -1) 
    {
        show_debug_message("ERRO: Não foi possível criar arquivo temporário de save.");
        return;
    }
    
    file_text_write_string(_file, _string_final);
    file_text_close(_file);
    
    if (file_exists(_arquivo_temp))
    {
        if (file_exists(_arquivo_real)) file_delete(_arquivo_real);
        file_rename(_arquivo_temp, _arquivo_real);
        
        global.timer_icone_save = 2; 
        show_debug_message("Jogo salvo (Codificado) com segurança: " + _arquivo_real);
    }
    else
    {
        show_debug_message("ERRO CRÍTICO: Falha na validação do save temporário.");
    }
}

function carrega_jogo(_save = global.save)
{
    var _arquivo = "Save0" + string(_save+1) + ".json";
    if (!file_exists(_arquivo)) return;
    
    var _file = file_text_open_read(_arquivo);
    var _conteudo_arquivo = file_text_read_string(_file);
    file_text_close(_file);
    
    // --- DECODIFICAÇÃO (BASE64) ---
    try {
        var _json_string = base64_decode(_conteudo_arquivo);
        global.dados_load_pendente = json_parse(_json_string);
    } 
    catch(_error) {
        show_message("Save corrompido ou modificado.");
        return;
    }
    
    // Atualiza Globais de Transição (O resto é feito pelo obj_sistema_jogo)
    if (variable_struct_exists(global.dados_load_pendente, "player"))
    {
        var _p = global.dados_load_pendente.player;
        global.respawn_room = _p.room_save;
        global.respawn_x    = _p.x_save;
        global.respawn_y    = _p.y_save;
        
        if (variable_struct_exists(global.dados_load_pendente, "info")) {
            if (variable_struct_exists(global.dados_load_pendente.info, "tempo_segundos")) {
                global.tempo_de_jogo_segundos = global.dados_load_pendente.info.tempo_segundos;
            }
        }
    }
    
    if (variable_struct_exists(global.dados_load_pendente, "objetos"))
    {
        global.permanentemente_quebrado = global.dados_load_pendente.objetos;
    }
    else
    {
        // Se o save for antigo e não tiver essa chave, inicia vazio para evitar erros
        global.permanentemente_quebrado = {};
    }
    
    if (variable_struct_exists(global.dados_load_pendente, "bestiario_kills"))
    {
        global.bestiario_kills = global.dados_load_pendente.bestiario_kills;
    }
    else
    {
        // Se o save for antigo e não tiver, começa vazio
        global.bestiario_kills = {}; 
    }
    
    // --- NOVIDADE: CARREGANDO OS ITENS COLETADOS E FRAGMENTOS ---
    if (variable_struct_exists(global.dados_load_pendente, "itens_coletados"))
    {
        global.itens_coletados = global.dados_load_pendente.itens_coletados;
    }
    else
    {
        global.itens_coletados = {}; 
    }
    
    if (variable_struct_exists(global.dados_load_pendente, "fragmentos_vida"))
    {
        global.fragmentos_vida = global.dados_load_pendente.fragmentos_vida;
    }
    else
    {
        global.fragmentos_vida = 0; 
    }

    global.inimigos_mortos_temp = {}; 

    
    // Transição
    var _room_dest = asset_get_index(global.respawn_room);
    if (_room_dest == -1) _room_dest = rm_level_demo; 

    IniciarTransicao(_room_dest);
}

// Config System
function salvar_config()
{
    var _binds_kbm = InputBindingsExport(false, 0);
    var _binds_pad = InputBindingsExport(true, 0);

    var _dados = 
    {
        // Áudio
        volume_mestre: global.master_volume,
        volume_musica: global.music_volume,
        volume_sfx: global.sfx_volume,
        mute_foco: global.mute_on_focus_lost,
        
        // Vídeo
        idioma: global.idioma_atual,
        fullscreen: window_get_fullscreen(),
        resolucao_idx: global.resolucao_index,
        brilho: global.brilho_val,            
        ui_scale: global.ui_scale,            
        shake_mult: global.screenshake_mult,  
        timer_on: global.timer_speedrun,       
        
        // Inputs
        inputs_teclado: _binds_kbm,
        inputs_gamepad: _binds_pad,
        vibracao: InputVibrateGetPause(0)
    };
    
    var _string = json_stringify(_dados);
    var _file = file_text_open_write("config.json");
    file_text_write_string(_file, _string);
    file_text_close(_file);
}

function carregar_config()
{
    // Defaults
    global.master_volume = 1;
    global.music_volume = 1;
    global.sfx_volume = 1;
    global.mute_on_focus_lost = true;
    
    global.resolucao_index = 0; 
    global.brilho_val = 1;
    global.ui_scale = 1;
    global.screenshake_mult = 1;
    global.timer_speedrun = false;
    
    //Ingles como padrao e no resto do mundo portuguelas     
    var _idioma_para_carregar = "en";
    
    if (os_get_language() == "pt") _idioma_para_carregar = "pt";
    
    if (file_exists("config.json"))
    {
        try 
        {
            var _file = file_text_open_read("config.json");
            var _string = "";

            
            while (!file_text_eof(_file))
            {
                _string += file_text_readln(_file);
            }
            file_text_close(_file);
            
            var _dados = json_parse(_string);
            
            // Áudio
            if (variable_struct_exists(_dados, "volume_mestre")) global.master_volume = _dados.volume_mestre;
            if (variable_struct_exists(_dados, "volume_musica")) global.music_volume = _dados.volume_musica;
            if (variable_struct_exists(_dados, "volume_sfx"))    global.sfx_volume = _dados.volume_sfx;
            if (variable_struct_exists(_dados, "mute_foco"))     global.mute_on_focus_lost = _dados.mute_foco;
            
            // Vídeo
            if (variable_struct_exists(_dados, "idioma"))        _idioma_para_carregar = _dados.idioma;
            if (variable_struct_exists(_dados, "fullscreen"))    window_set_fullscreen(_dados.fullscreen);
            if (variable_struct_exists(_dados, "resolucao_idx")) global.resolucao_index = _dados.resolucao_idx;
            if (variable_struct_exists(_dados, "brilho"))        global.brilho_val = _dados.brilho;
            if (variable_struct_exists(_dados, "ui_scale"))      global.ui_scale = _dados.ui_scale;
            if (variable_struct_exists(_dados, "shake_mult"))    global.screenshake_mult = _dados.shake_mult;
            if (variable_struct_exists(_dados, "timer_on"))      global.timer_speedrun = _dados.timer_on;
            if (variable_struct_exists(_dados, "inputs_teclado")) InputBindingsImport(false, _dados.inputs_teclado, 0);
            if (variable_struct_exists(_dados, "vibracao")) InputVibrateSetPause(_dados.vibracao, 0);
        }
        catch(_error)
        {
            show_debug_message("Erro ao carregar config.json: " + _error.message);
        }
    }
    
    carregar_idioma(_idioma_para_carregar);
    audio_master_gain(global.master_volume);
}

// Config UI
function salvar_config_ui()
{
    var _dados = 
    {
        fullscreen: window_get_fullscreen(),
        resolucao_idx: global.resolucao_index,
        ui_scale: global.ui_scale,
        shake_mult: global.screenshake_mult
    };
    
    var _string = json_stringify(_dados);
    var _file = file_text_open_write("config_ui.json");
    file_text_write_string(_file, _string);
    file_text_close(_file);
}

function carregar_config_ui()
{
    var _fullscreen_target = true; 
    
    global.resolucao_index = 0; 
    global.ui_scale = 1;
    global.screenshake_mult = 1;
    
    if (file_exists("config_ui.json"))
    {
        try 
        {
            var _file = file_text_open_read("config_ui.json");
            var _string = "";

            // --- CORREÇÃO: Lê o arquivo inteiro linha por linha ---
            while (!file_text_eof(_file))
            {
                _string += file_text_readln(_file);
            }
            file_text_close(_file);

            var _dados = json_parse(_string);
            
            if (variable_struct_exists(_dados, "fullscreen"))    _fullscreen_target = _dados.fullscreen;
            if (variable_struct_exists(_dados, "resolucao_idx")) global.resolucao_index = _dados.resolucao_idx;
            if (variable_struct_exists(_dados, "ui_scale"))      global.ui_scale = _dados.ui_scale;
            if (variable_struct_exists(_dados, "shake_mult"))    global.screenshake_mult = _dados.shake_mult;
        }
        catch(_error)
        {
            show_debug_message("Erro ao ler config UI: " + _error.message);
        }
    }

    // --- CORREÇÃO DO ZOOM INICIAL ---
    var _w, _h;
    
    // Lista de resoluções (mantendo sua lógica original)
    var _lista_res = [[0, 0], [1280, 720], [1366, 768], [1920, 1080], [2560, 1440]];
    
    // Proteção de índice
    if (global.resolucao_index >= array_length(_lista_res)) global.resolucao_index = 0;
    
    if (_fullscreen_target)
    {
        _w = display_get_width();
        _h = display_get_height();
    }
    else
    {
        var _res = _lista_res[global.resolucao_index];
        // Se for [0,0] (Auto) ou índice inválido
        if (_res[0] == 0) { 
            _w = display_get_width() * 0.8; 
            _h = display_get_height() * 0.8; 
        } else {
            _w = _res[0];
            _h = _res[1];
        }
    }

    // Chama a função MESTRE que arruma a surface e a janela
    aplicar_resolucao(_w, _h, _fullscreen_target);
    
    // Reset extra para garantir VSync
    if (_fullscreen_target) display_reset(0, true); 
}

function copiar_save(_slot_origem_idx) 
{
    var _arquivo_origem = "Save0" + string(_slot_origem_idx + 1) + ".json";
    
    var _slot_destino = -1;
    for (var i = 0; i < 5; i++)
    {
        var _check = "Save0" + string(i + 1) + ".json";
        if (!file_exists(_check)) 
        {
            _slot_destino = i;
            break;
        }
    }
    
    if (_slot_destino == -1) return -1;
    
    var _arquivo_destino = "Save0" + string(_slot_destino + 1) + ".json";
    
    // file_copy funciona perfeitamente para arquivos binários ou base64
    file_copy(_arquivo_origem, _arquivo_destino);
    
    return _slot_destino; 
}

// Idioma
function carregar_idioma(_lang = "pt")
{
    var _arquivo = _lang + ".json";
    if (!file_exists(_arquivo)) return;
    
    var _file = file_text_open_read(_arquivo);
    var _string_json = "";
    while (!file_text_eof(_file))
    {
        _string_json += file_text_readln(_file);
    }
    file_text_close(_file);
    
    try 
    {
        global.text = json_parse(_string_json);
        global.idioma_atual = _lang;
        show_debug_message("Idioma '" + _lang + "' carregado.");
    } 
    catch(_error) 
    {
        show_debug_message("Erro idioma: " + _error.message);
    }
}

function get_text(_key)
{
    if (variable_struct_exists(global.text, _key))
    {
        return global.text[$ _key];
    }
    return "?? " + _key + " ??";
}