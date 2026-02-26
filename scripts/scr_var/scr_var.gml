//Transição
global.transicao = false;
global.xstart = 0;
global.ystart = 0;

//Controle
global.pause = false;

//Tempo
global.vel_scale = 1;
global.slow_scale = .2;
global.lerp_slow_scale = .05;
global.slow_motion = false;

global.tempo_de_jogo_segundos = 0;
// Vida
global.vida_base = 5;                  // O quanto o player nasce no início do jogo (imutável)
global.fragmentos_vida = 0;            // Quantos pedaços ele tem no inventário
global.fragmentos_por_ponto = 4;       // Quantos precisa para ganhar 1 de vida
global.vida_permanente_memoria = 5;    // Usado para saber quando tocar o "som do Zelda"
global.vida_max = 5;                   // Vida máxima final (Base + Fragmentos + Amuletos)
global.vida_atual = 5;                 // Vida que o player tem agora


// Velocidade
global.velh_base      = 5; // Velocidade padrão
global.velh_calculada = 5; // Velocidade final (base + amuletos)

// Dano
global.dano_base = 1;
global.dano      = 1; // Dano final

//Combate e Combo
global.combo = 1;
global.limite_combo = 6;
global.dano_combo = 2;
global.timer_combo = 10; // Segundos

//Outros
global.permanentemente_quebrado = {};
global.itens_coletados = {};
global.respawn_anim = false;

//Ui
#macro ESCALA_UI 720 

// Recalculo de stats
function atualiza_stats_player()
{
    // --------------------------------------------------------
    // 1. CALCULA A NOVA VIDA PERMANENTE (Base + Fragmentos)
    // --------------------------------------------------------
    var _bonus_fragmentos = floor(global.fragmentos_vida / global.fragmentos_por_ponto);
    var _nova_vida_permanente = global.vida_base + _bonus_fragmentos;
    
    // Se a vida permanente AUMENTOU (o player completou 4 fragmentos agora)
    if (_nova_vida_permanente > global.vida_permanente_memoria) 
    {
        global.vida_atual = _nova_vida_permanente; // Cura o player
        // TODO: Tocar Efeito Sonoro de "Zelda Heart Container"
    }
    
    // Salva na memória para a próxima checagem
    global.vida_permanente_memoria = _nova_vida_permanente;

    // --------------------------------------------------------
    // 2. PREPARA OS STATS PARA RECEBER OS AMULETOS
    // --------------------------------------------------------
    global.vida_max       = _nova_vida_permanente; // A vida máxima começa com a permanente
    global.velh_calculada = global.velh_base;
    global.dano           = global.dano_base;
    
    // --------------------------------------------------------
    // 3. APLICA OS AMULETOS (Bônus Temporários)
    // --------------------------------------------------------
    if (variable_global_exists("amuletos_equipados") and ds_exists(global.amuletos_equipados, ds_type_list))
    {
        var _tam = ds_list_size(global.amuletos_equipados);
        for (var i = 0; i < _tam; i++)
        {
            var _amuleto = global.amuletos_equipados[| i];
            
            if (is_struct(_amuleto))
            {
                switch (_amuleto.tipo_efeito)
                {
                    case EFEITO.VIDA_MAXIMA:    global.vida_max       += _amuleto.valor_efeito; break;
                    case EFEITO.DANO_EXTRA:     global.dano           += _amuleto.valor_efeito; break;
                    case EFEITO.VELOCIDADE_MOV: global.velh_calculada += _amuleto.valor_efeito; break;
                }
            }
        }
    }
    
    // --------------------------------------------------------
    // 4. REGRAS DE SEGURANÇA E SINCRONIZAÇÃO
    // --------------------------------------------------------
    // Impede que a vida atual fique maior que a vida máxima (ex: tirou amuleto de vida)
    global.vida_atual = clamp(global.vida_atual, 0, global.vida_max);
    
    // Sincroniza a velocidade se o player estiver na sala
    if (instance_exists(obj_player))
    {
        obj_player.max_velh = global.velh_calculada;
    }
    
    show_debug_message("Stats Atualizados | Vida Max: " + string(global.vida_max) + " | Vel: " + string(global.velh_calculada) + " | Dano: " + string(global.dano));
}

function adiciona_combo()
{
    //Nao tenho entao nem roda
    if (!global.powerups[powerup.COMBO]) exit;
    
    // Incrementa e da Feedback Visual
    global.combo++;
    obj_cam.hurt_inimigo = true;
    
    // Reseta Timer
    obj_player.timer_dano = 0;
    obj_player.dispara_alarme = true;
    
    // Game Feel Progressivo
    var _pct = (global.combo / global.limite_combo);
    
    if (_pct < .35)
    {
        aplica_screenshake();     
        InputVibrateConstant(0.1, 0.0, 100)
    }
    else if (_pct >= .35 and _pct <= .50)
    {
        aplica_screenshake(3);
        InputVibrateConstant(0.2, 0.0, 120)
    }
    else if (_pct > .50 and _pct <= .75)
    {
        aplica_screenshake(5);
        aplica_hitstop();
        InputVibrateConstant(0.35, 0.0, 150)
    }
    else if (_pct > .75 and _pct < .90)
    {
        aplica_screenshake(7);
        aplica_hitstop(.2);
        InputVibrateConstant(0.5, 0.0, 180)
    }
    else
    {
        aplica_screenshake(11);
        aplica_hitstop(.35);
        InputVibrateConstant(0.7, 0.0, 250)
    }
}

//Configurações de audio
global.music_volume = 0;
global.sfx_volume = .1;

// Carrega Audio Groups
function inicializa_musicas()
{
    if (!audio_group_is_loaded(ag_gameplay)) audio_group_load(ag_gameplay);
    if (!audio_group_is_loaded(ag_ui))       audio_group_load(ag_ui);
}

//Save
enum saves
{
    save_01,
    save_02,
    save_03,
    save_04
}
global.save = saves.save_01;

// powerups do player
enum powerup
{
    DASH,
    WALL,
    DOUBLE_J,
    COMBO,
    FLOAT,
    MARK,
    DASH_CELESTE,
    DASH_FANTASMA,
    MAGIC_BUMERANGUE,
    MAGIC_GROUNDPOUND,
    MAGIC_TELEPORT
}

global.powerups = [false, false, 0,false,false,false,false,false,false,false,false];
global.max_carga = 1;

//Tiro
global.inimigo_marcado = noone;
global.timer_marcado = 0;
global.tempo_marcado = 15;
global.marca_pos_x = 0;
global.marca_pos_y = 0;

// Restaura estado físico (pulo/dash)
function restart_powerups()
{
    var _carga_extra = global.powerups[powerup.DASH_CELESTE] ? 1 : 0;
    
    obj_player.carga = global.max_carga + _carga_extra;
    obj_player.jump_extra_left = global.powerups[powerup.DOUBLE_J];
}

function reset_variaveis_jogo()
{
    //Limpa Estruturas de Dados
    if (variable_global_exists("inventario") and ds_exists(global.inventario, ds_type_grid)) 
        ds_grid_clear(global.inventario, 0);
    
    if (variable_global_exists("amuletos_equipados") and ds_exists(global.amuletos_equipados, ds_type_list)) 
        ds_list_clear(global.amuletos_equipados);
    
    if (variable_global_exists("itens_chave") and ds_exists(global.itens_chave, ds_type_map)) 
        ds_map_clear(global.itens_chave);
    
    // Isso garante que amuletos marcados como "equipado" na memória sejam limpos
    if (variable_global_exists("amuletos") and ds_exists(global.amuletos, ds_type_list))
    {
        var _tamanho = ds_list_size(global.amuletos);
        for (var i = 0; i < _tamanho; i++)
        {
            var _struct_amuleto = global.amuletos[| i];
            if (is_struct(_struct_amuleto))
            {
                _struct_amuleto.equipado = false; // Desmarca o visual
            }
        }
    }

    //Resetando variaveis
    global.powerups = [false, false, 0,false,false,false,false,false,false,false,false];
    global.max_carga = 1;
    
    // --- RESET DE STATS GLOBAIS ---
    global.vida_base = 5;                 
    global.fragmentos_vida = 0;           
    global.fragmentos_por_ponto = 4;      
    global.vida_permanente_memoria = 5;   
    global.vida_max = 5;                  
    global.vida_atual = 5;                
    
    global.velh_base      = 5;
    global.velh_calculada = 5;
    
    global.dano_base = 1;
    global.dano      = 1; 
    
    global.player_slots_maximos = 3; 
    global.player_slots_usados = 0;
    
    global.combo = 1;
    global.vida_player_transicao = -1;
    global.xscale_player_transicao = 0;
    global.player_nasce_invencivel = false;
    
    global.respawn_room = "rm_level_demo"; 
    global.respawn_x    = 256; 
    global.respawn_y    = 1568; 
    
    global.areas_visitadas = {};
    global.area_atual_memoria = "";
    global.player_slots_usados = 0;
    
    global.inimigos_mortos_temp = {};
    global.bosses_mortos        = {};
    global.bestiario_kills      = {};
    global.inimigo_marcado = noone;
    global.timer_marcado = 0;
    global.marca_pos_x = 0;
    global.marca_pos_y = 0;
    global.permanentemente_quebrado = {};
    global.itens_coletados = {};
    global.eventos = 
    { 
    npcs: {}, 
    mundo: {},
    cutscenes: {},
    tutorial :{}
    };
    
    //Reset de dados
    global.tempo_de_jogo_segundos = 0;
    global.respawn_anim = false;
    
    
    // Reset Variáveis de Controle
    global.dados_load_pendente = undefined;
    global.timer_icone_save = 0;
    
    show_debug_message("--- MEMÓRIA DE JOGO RESETADA ---");
}

function inicializa_eventos_mundo()
{
    global.eventos = 
    {
        npcs: 
        {
            habitante_em_furia: false,
        },
        mundo: 
        {
            assistiu_cutscene_inicial: false
        },
        tutorial:
        {
            
        }
    };
}


function configurar_icones_input()
{
    // Xbox e Genéricos
    var _types_xbox = [
        INPUT_GAMEPAD_TYPE_XBOX,
        INPUT_GAMEPAD_TYPE_UNKNOWN
    ];
    
    // Playstation
    var _types_ps = [
        INPUT_GAMEPAD_TYPE_PS5,
        INPUT_GAMEPAD_TYPE_PS4
    ];

    // Config Xbox
    var i = 0; repeat(array_length(_types_xbox))
    {
        var _type = _types_xbox[i];
        
        InputIconDefineGamepad(_type, gp_face1,      { sprite: spr_ui_xbox, index: 0 });  // A
        InputIconDefineGamepad(_type, gp_face3,      { sprite: spr_ui_xbox, index: 1 });  // X
        InputIconDefineGamepad(_type, gp_face4,      { sprite: spr_ui_xbox, index: 2 });  // Y
        InputIconDefineGamepad(_type, gp_face2,      { sprite: spr_ui_xbox, index: 3 });  // B
        
        InputIconDefineGamepad(_type, gp_padl,       { sprite: spr_ui_xbox, index: 4 });  // Esq
        InputIconDefineGamepad(_type, gp_padd,       { sprite: spr_ui_xbox, index: 5 });  // Baixo
        InputIconDefineGamepad(_type, gp_padu,       { sprite: spr_ui_xbox, index: 6 });  // Cima
        InputIconDefineGamepad(_type, gp_padr,       { sprite: spr_ui_xbox, index: 7 });  // Dir
        
        InputIconDefineGamepad(_type, gp_stickl,     { sprite: spr_ui_xbox, index: 8 });  // LS
        InputIconDefineGamepad(_type, gp_stickr,     { sprite: spr_ui_xbox, index: 9 });  // RS
        
        InputIconDefineGamepad(_type, gp_shoulderlb, { sprite: spr_ui_xbox, index: 10 }); // LT
        InputIconDefineGamepad(_type, gp_shoulderrb, { sprite: spr_ui_xbox, index: 11 }); // RT
        InputIconDefineGamepad(_type, gp_shoulderl,  { sprite: spr_ui_xbox, index: 12 }); // LB
        InputIconDefineGamepad(_type, gp_shoulderr,  { sprite: spr_ui_xbox, index: 13 }); // RB
        
        InputIconDefineGamepad(_type, gp_select,     { sprite: spr_ui_xbox, index: 14 }); // View
        InputIconDefineGamepad(_type, gp_start,      { sprite: spr_ui_xbox, index: 15 }); // Menu
        
        i++;
    }

    // Config Playstation
    var j = 0; repeat(array_length(_types_ps))
    {
        var _type = _types_ps[j];
        
        InputIconDefineGamepad(_type, gp_face4,      { sprite: spr_ui_playstation, index: 0 }); // Tri
        InputIconDefineGamepad(_type, gp_face2,      { sprite: spr_ui_playstation, index: 1 }); // Cir
        InputIconDefineGamepad(_type, gp_face1,      { sprite: spr_ui_playstation, index: 2 }); // X
        InputIconDefineGamepad(_type, gp_face3,      { sprite: spr_ui_playstation, index: 3 }); // Quad
        
        InputIconDefineGamepad(_type, gp_stickl,     { sprite: spr_ui_playstation, index: 4 }); // L3
        InputIconDefineGamepad(_type, gp_stickr,     { sprite: spr_ui_playstation, index: 5 }); // R3

        InputIconDefineGamepad(_type, gp_shoulderlb, { sprite: spr_ui_playstation, index: 6 }); // L2
        InputIconDefineGamepad(_type, gp_shoulderrb, { sprite: spr_ui_playstation, index: 7 }); // R2
        InputIconDefineGamepad(_type, gp_shoulderl,  { sprite: spr_ui_playstation, index: 8 }); // L1
        InputIconDefineGamepad(_type, gp_shoulderr,  { sprite: spr_ui_playstation, index: 9 }); // R1
        
        InputIconDefineGamepad(_type, gp_padu,       { sprite: spr_ui_playstation, index: 10 }); // Cima
        InputIconDefineGamepad(_type, gp_padd,       { sprite: spr_ui_playstation, index: 11 }); // Baixo
        InputIconDefineGamepad(_type, gp_padl,       { sprite: spr_ui_playstation, index: 12 }); // Esq
        InputIconDefineGamepad(_type, gp_padr,       { sprite: spr_ui_playstation, index: 13 }); // Dir
        
        InputIconDefineGamepad(_type, gp_select,     { sprite: spr_ui_playstation, index: 14 }); // Share
        InputIconDefineGamepad(_type, gp_start,      { sprite: spr_ui_playstation, index: 14 }); // Options
        
        j++;
    }

    // Teclado - Setas
    InputIconDefineKeyboard(vk_up,    { sprite: spr_ui_teclado, index: 0 });
    InputIconDefineKeyboard(vk_left,  { sprite: spr_ui_teclado, index: 1 });
    InputIconDefineKeyboard(vk_down,  { sprite: spr_ui_teclado, index: 2 });
    InputIconDefineKeyboard(vk_right, { sprite: spr_ui_teclado, index: 3 });
    
    // Teclado - Letras
    InputIconDefineKeyboard(ord("Z"), { sprite: spr_ui_teclado, index: 4 });
    InputIconDefineKeyboard(ord("X"), { sprite: spr_ui_teclado, index: 5 });
    InputIconDefineKeyboard(ord("C"), { sprite: spr_ui_teclado, index: 6 });
    InputIconDefineKeyboard(ord("V"), { sprite: spr_ui_teclado, index: 7 });
    InputIconDefineKeyboard(ord("B"), { sprite: spr_ui_teclado, index: 8 });
    InputIconDefineKeyboard(ord("N"), { sprite: spr_ui_teclado, index: 9 });
    InputIconDefineKeyboard(ord("M"), { sprite: spr_ui_teclado, index: 10 });
    InputIconDefineKeyboard(ord("W"), { sprite: spr_ui_teclado, index: 11 });
    InputIconDefineKeyboard(ord("A"), { sprite: spr_ui_teclado, index: 12 });
    InputIconDefineKeyboard(ord("S"), { sprite: spr_ui_teclado, index: 13 });
    InputIconDefineKeyboard(ord("D"), { sprite: spr_ui_teclado, index: 14 });
    InputIconDefineKeyboard(ord("E"), { sprite: spr_ui_teclado, index: 15 });
    InputIconDefineKeyboard(ord("I"), { sprite: spr_ui_teclado, index: 16 });
    InputIconDefineKeyboard(ord("Q"), { sprite: spr_ui_teclado, index: 17 });
    InputIconDefineKeyboard(ord("G"), { sprite: spr_ui_teclado, index: 18 });
    InputIconDefineKeyboard(ord("F"), { sprite: spr_ui_teclado, index: 19 });
    InputIconDefineKeyboard(ord("J"), { sprite: spr_ui_teclado, index: 20 });
    InputIconDefineKeyboard(ord("K"), { sprite: spr_ui_teclado, index: 21 });
    InputIconDefineKeyboard(ord("L"), { sprite: spr_ui_teclado, index: 22 });
    
    // Teclado - Sistema
    InputIconDefineKeyboard(vk_escape,    { sprite: spr_ui_teclado, index: 23 });
    InputIconDefineKeyboard(vk_shift,     { sprite: spr_ui_teclado, index: 24 });
    InputIconDefineKeyboard(vk_control,   { sprite: spr_ui_teclado, index: 25 });
    InputIconDefineKeyboard(vk_alt,       { sprite: spr_ui_teclado, index: 26 });
    InputIconDefineKeyboard(vk_capslock,  { sprite: spr_ui_teclado, index: 27 });
    InputIconDefineKeyboard(vk_tab,       { sprite: spr_ui_teclado, index: 28 });
    InputIconDefineKeyboard(vk_backspace, { sprite: spr_ui_teclado, index: 29 });
    InputIconDefineKeyboard(vk_space, { sprite: spr_ui_teclado_espaco, index: 0 });
    
    

    // Fallback
    var _fallback = { sprite: spr_ui_teclado_vazio, index: 99 };
    InputIconDefineEmpty(_fallback); 
    InputIconDefineUnsupported(_fallback);
}
// Desenhando os inputs
/// @function desenha_input_verbo(verbo, x, y, scale)
/// @function desenha_input_verbo(verbo, x, y, scale)
function desenha_input_verbo(_verbo, _x, _y, _scale = 1)
{
    // Tenta pegar os dados do ícone (Pode retornar Struct ou String/Undefined)
    var _icon_data = InputIconGet(_verbo);
    var _desenhou_sprite = false;

    // --- A. Tenta Desenhar o Sprite Específico ---
    // Verifica se é struct E se possui a variável "sprite" (Safety Check)
    if (is_struct(_icon_data) && variable_struct_exists(_icon_data, "sprite"))
    {
        // Verifica se não é o fallback (index 99) e se o sprite existe
        if (_icon_data.index != 99 && sprite_exists(_icon_data.sprite))
        {
            // Desenha centralizado (assumindo que a origem do sprite é Middle Center)
            draw_sprite_ext(_icon_data.sprite, _icon_data.index, _x, _y, _scale, _scale, 0, c_white, draw_get_alpha());
            _desenhou_sprite = true;
        }
    }

    // --- B. Fallback (Botão Genérico + Texto da Tecla) ---
    if (!_desenhou_sprite)
    {
        // Obtém o nome da tecla (ex: "Space", "Enter", "K") [cite: 238]
        var _texto_tecla = InputVerbGetBindingName(_verbo);
        
        // Configurações de Fonte
        var _old_font = draw_get_font();
        draw_set_font(fnt_dialogo);
        
        // Configurações de Dimensão
        var _altura_alvo = 16 * _scale; // Altura base do botão (ajuste conforme seu sprite)
        var _padding_x   = 12 * _scale; // Espaço extra nas laterais
        var _largura_texto = string_width(_texto_tecla) * _scale;
        
        // A largura da caixa será o que for maior: o texto + padding OU a altura (para botões quadrados como "A")
        var _largura_box = max(_largura_texto + _padding_x, _altura_alvo);
        
        // Cálculo do Top-Left (necessário pois draw_sprite_stretched desenha a partir do canto superior esquerdo)
        var _draw_x = _x - (_largura_box / 2);
        var _draw_y = _y - (_altura_alvo / 2);
        
        // 1. Desenha o Fundo (Nine Slice)
        draw_sprite_stretched(spr_ui_teclado_vazio, 0, _draw_x, _draw_y, _largura_box, _altura_alvo);
        
        // 2. Desenha o Texto (Centralizado no _x, _y originais)
        var _old_halign = draw_get_halign();
        var _old_valign = draw_get_valign();
        var _old_color  = draw_get_color();
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white); // Use c_black se o botão for claro
        
        draw_text_transformed(_x, _y, _texto_tecla, _scale, _scale, 0);
        
        // Reset dos estados de desenho
        draw_set_halign(_old_halign);
        draw_set_valign(_old_valign);
        draw_set_color(_old_color);
        draw_set_font(_old_font);
    }
}

function aplicar_resolucao(_w, _h, _fullscreen) 
{
    if (_fullscreen) 
    {
        window_set_fullscreen(true);
        _w = display_get_width();
        _h = display_get_height();
    } 
    else 
    {
        window_set_fullscreen(false);
        window_set_size(_w, _h);
        window_center();
    }

    // Redimensiona a surface apenas UMA vez aqui
    if (surface_exists(application_surface)) {
        surface_resize(application_surface, _w, _h);
    }

    // Redimensiona a GUI
    var _aspect = _w / max(1, _h);
    var _gui_h = ESCALA_UI / global.ui_scale; 
    var _gui_w = _gui_h * _aspect;
    display_set_gui_size(_gui_w, _gui_h);
}