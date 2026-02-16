// Aplicação de Load
if (global.dados_load_pendente != undefined) and (instance_exists(obj_player))
{
    var _dados = global.dados_load_pendente;

    // 1. Cronometro e Posição
    global.tempo_de_jogo_segundos = _dados.info.tempo_segundos
    obj_player.x = _dados.player.x_save;
    obj_player.y = _dados.player.y_save;
    
    // Snap Câmera
    if (instance_exists(obj_cam))
    {
        obj_cam.x = obj_player.x;
        obj_cam.y = obj_player.y;
    }

    // 2. RESET E CARREGAMENTO DE BASES (Nas Globais)
    // Recuperamos o quanto o player tinha de base (sem amuletos) no momento do save
    global.vida_base = _dados.player.vida_max; 
    global.velh_base = _dados.player.velh_base;
    
    // Reseta os calculados para o base antes de processar equipamentos
    global.vida_max       = global.vida_base;
    global.velh_calculada = global.velh_base;

    // Globais
    global.powerups = _dados.player.powerups;
    global.player_slots_maximos = _dados.amuletos.slots_max;

    // 3. INVENTÁRIO E EQUIPAMENTOS
    // Limpa tudo antes de preencher
    reset_inventario_completo(); 

    // A. Reconstrói Grid do Inventário
    var _inv_struct = _dados.amuletos.inventario_data;
    var _chaves = variable_struct_get_names(_inv_struct);

    for (var i = 0; i < array_length(_chaves); i++)
    {
        var _key_pos = _chaves[i]; 
        var _id_item = _inv_struct[$ _key_pos]; 
        var _amuleto_real = global.amuletos[| _id_item]; 
        
        var _coords = string_split(_key_pos, "_");
        var _xx = real(_coords[0]);
        var _yy = real(_coords[1]);
        
        global.inventario[# _xx, _yy] = _amuleto_real;
    }

    // B. Reconstrói Lista de Equipados
    var _equipados = _dados.amuletos.equipados_array;
    for (var i = 0; i < array_length(_equipados); i++)
    {
        var _id = _equipados[i];
        var _amuleto = global.amuletos[| _id]; 
        
        if (is_struct(_amuleto))
        {
            // NOTA: Não chamamos mais aplica_efeito() aqui individualmente.
            // Apenas marcamos como equipado e colocamos na lista.
            _amuleto.equipado = true;
            global.player_slots_usados += _amuleto.custo_slot;
            ds_list_add(global.amuletos_equipados, _amuleto);
        }
    }
    
    // 4. RECÁLCULO GERAL (O Pulo do Gato)
    // Agora que a lista 'global.amuletos_equipados' está pronta e a 'global.vida_base' carregada,
    // rodamos a função mestre para somar tudo.
    atualiza_stats_player();

    // 5. DEFINE VIDA ATUAL
    // Agora que 'global.vida_max' já cresceu (graças ao atualiza_stats_player),
    // podemos jogar a vida atual salva sem medo de ser cortada.
    global.vida_atual = _dados.player.vida; 

    // Itens Chave
    ds_map_clear(global.itens_chave);
    var _keys_struct = _dados.itens_chave_data;
    var _names = variable_struct_get_names(_keys_struct);
    
    for (var i = 0; i < array_length(_names); i++) 
    {
        var _k = _names[i];
        var _val = _keys_struct[$ _k];
        ds_map_add(global.itens_chave, _k, _val);
    }
    
    // Exploração, combate e eventos
    if (variable_struct_exists(_dados, "areas_visitadas")) global.areas_visitadas = _dados.areas_visitadas;
    else global.areas_visitadas = {}; 
        
    global.inimigos_mortos_temp = {}; 
    
    if (variable_struct_exists(_dados, "bosses_mortos")) global.bosses_mortos = _dados.bosses_mortos;
    else global.bosses_mortos = {}; 

    if (variable_struct_exists(_dados, "eventos_mundo")) global.eventos = _dados.eventos_mundo;
    else inicializa_eventos_mundo();

    // Finalização
    global.dados_load_pendente = undefined;
    
    show_debug_message("Sistema: Load aplicado com sucesso. Vida Global: " + string(global.vida_atual) + "/" + string(global.vida_max));
}

// Transição de Porta
if (global.target_x != noone) and (global.target_y != noone) and (instance_exists(obj_player))
{
    // Posição Player
    obj_player.x = global.target_x;
    obj_player.y = global.target_y;
    
    // Snap Câmera
    if (instance_exists(obj_cam))
    {
        obj_cam.x = obj_player.x;
        obj_cam.y = obj_player.y;
    }
    
    // Vida entre Salas 
    // (Com variáveis globais, isso é menos necessário para a vida em si, mas útil para resets específicos se houver)
    if (global.vida_player_transicao != -1)
    {
        global.vida_atual = global.vida_player_transicao;
        global.vida_player_transicao = -1; 
    }
    
    // Direção entre Salas
    if (global.xscale_player_transicao != 0)
    {
        obj_player.xscale = global.xscale_player_transicao;
        global.xscale_player_transicao = 0; 
    }
    
    // Invencibilidade Respawn
    if (global.player_nasce_invencivel)
    {
        obj_player.inv = true;
        obj_player.inv_timer = 1.0; 
        obj_player.image_alpha = 0.5;
        global.player_nasce_invencivel = false; 
    }
    
    // Limpa targets
    global.target_x = noone;
    global.target_y = noone;
    
    show_debug_message("Sistema: Posição de porta aplicada.");
}


// Arrumando gui
var _base_h = ESCALA_UI; 


// Verifica se está em fullscreen
var _w_display, _h_display;

if (window_get_fullscreen())
{
    _w_display = display_get_width();
    _h_display = display_get_height();
}
else
{
    _w_display = window_get_width();
    _h_display = window_get_height();
}

// Proteção contra divisão por zero
if (_h_display == 0) _h_display = 1;
if (global.ui_scale == 0) global.ui_scale = 1;

// Calcula nova GUI 
var _aspect = _w_display / _h_display;
var _gui_h_target = _base_h / global.ui_scale;
var _gui_w_target = _gui_h_target * _aspect;

display_set_gui_size(_gui_w_target, _gui_h_target)