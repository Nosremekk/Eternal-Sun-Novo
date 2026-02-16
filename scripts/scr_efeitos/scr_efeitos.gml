function aplica_screenshake(_valor = 2)
{
    obj_cam.aplicar_shake(_valor);
}

function aplica_hitstop(_tempo = .15)
{
    if (!instance_exists(obj_hitstop))
    {
        var _hit = instance_create_depth(0,0,0,obj_hitstop)
        _hit.tempo = _tempo;
    }
}

function desenha_nome(_nome, _font = fnt_dialogo)
{
    timer_nome += desconta_timer();
    
    if (timer_nome < duracao_nome) alpha = min(alpha + 0.03, 1);
    else alpha = max(alpha - 0.02, 0);

    // Visibilidade e Controle
    if (alpha <= 0) 
    {
        show = false;
        if (instance_exists(obj_hud)) obj_hud.talk = false; // Proteção extra
        return; 
    }

    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    
    var _s = max(1, _gui_h / ESCALA_UI); 
    
    var _scale_final = _s * 2.0; 

    // Posição
    var _pos_x = _gui_w / 2;
    var _pos_y = _gui_h * 0.15; 
    
    draw_set_alpha(alpha);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_set_font(_font);
    
    // Sombra 
    var _shadow_off = 2 * _s; 
    draw_set_color(c_black);
    draw_text_transformed(_pos_x + _shadow_off, _pos_y + _shadow_off, _nome, _scale_final, _scale_final, 0);
    
    // Texto
    draw_set_color(c_white);
    draw_text_transformed(_pos_x, _pos_y, _nome, _scale_final, _scale_final, 0);
    
    // Reset
    draw_set_font(-1);
    draw_set_alpha(1);
    draw_set_halign(-1); draw_set_valign(-1);
    draw_set_color(c_white);
}

function desenha_nome_npc(_nome, _alpha)
{
    if (_alpha <= 0) return;

    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    var _s = max(1, _gui_h / ESCALA_UI);
    
    var _scale_final = _s * 1.5; 
    
    // Posicionamento 
    var _marg_x = _gui_w * 0.05;
    var _marg_y = _gui_h * 0.05;
    
    var _pos_x = _gui_w - _marg_x;
    var _pos_y = _marg_y;
    
    draw_set_alpha(_alpha);
    draw_set_halign(fa_right); draw_set_valign(fa_top);    
    draw_set_font(fnt_dialogo);
    
    // Sombra
    var _shadow_off = 2 * _s;
    draw_set_color(c_black);
    draw_text_transformed(_pos_x + _shadow_off, _pos_y + _shadow_off, _nome, _scale_final, _scale_final, 0);
    
    // Texto
    draw_set_color(c_white); 
    draw_text_transformed(_pos_x, _pos_y, _nome, _scale_final, _scale_final, 0);
    
    // Reset
    draw_set_font(-1);
    draw_set_halign(-1); draw_set_valign(-1);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

function inicializa_nomes_areas()
{
    global.mapa_areas = {};
    
    // Controle de exibição imediata 
    global.area_atual_memoria = ""; 
    
    global.mapa_areas[$ rm_level_demo]   = "area_cavernas_esquecidas";
    global.mapa_areas[$ rm_level_demo_4]   = "area_ruinas";
    global.mapa_areas[$ rm_arena]        = "area_camara_guardiao";
    
    // Controle de histórico 
    if (!variable_global_exists("areas_visitadas")) 
    {
        global.areas_visitadas = {};
    }
}
function get_nome_area(_room_id)
{
    if (variable_struct_exists(global.mapa_areas, _room_id))
    {
        return global.mapa_areas[$ _room_id];
    }
    return undefined; 
}

//Particulas
enum TIPO_PARTICULA
{
    SANGUE,
    EXPLOSAO,
    POEIRA_PULO,
    POEIRA_DASH,
    FAISCA,
    SHOCKWAVE,
    COLETAVEL,
    ALMA
}

/// @function cria_particula(x, y, tipo, [quantidade], [dir_min], [dir_max])
function cria_particula(_x, _y, _tipo, _qtd = 1, _dir_min = 0, _dir_max = 360)
{
    // Verifica se o controlador existe
    if (!instance_exists(obj_controla_particulas)) return;
    
    var _sys = obj_controla_particulas.sistema_particulas;
    var _part = undefined;
    
    // Seleciona o tipo
    switch (_tipo)
    {
        case TIPO_PARTICULA.SANGUE:      _part = obj_controla_particulas.part_sangue; break;
        case TIPO_PARTICULA.EXPLOSAO:    _part = obj_controla_particulas.part_explosao; break;
        case TIPO_PARTICULA.POEIRA_PULO: _part = obj_controla_particulas.part_poeira; break;
        case TIPO_PARTICULA.POEIRA_DASH: _part = obj_controla_particulas.part_dash; break;
        case TIPO_PARTICULA.FAISCA:      _part = obj_controla_particulas.part_faisca; break;
        case TIPO_PARTICULA.SHOCKWAVE:      _part = obj_controla_particulas.part_shockwave; break;
        case TIPO_PARTICULA.COLETAVEL:      _part = obj_controla_particulas.part_brilho; break;
        case TIPO_PARTICULA.ALMA:      _part = obj_controla_particulas.part_alma; break;
    }
    
    if (!is_undefined(_part))
    {
        // Configura direção se for necessário
        part_particles_create(_sys, _x, _y, _part, _qtd);
    }
}