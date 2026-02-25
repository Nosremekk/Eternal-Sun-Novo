//Animação
function animacao()
{
    //Animação
    var _incremento_anim = anim_speed * desconta_timer();
    image_index += _incremento_anim;

    if (image_index >= image_number)
    {
        image_index -= image_number;
    }
}

//Finalizando animações
function finalizou_animacao()
{
    if (img_ind > image_index)
    {
        img_ind = 0;
        return true;
    }
    else     
    {
        img_ind = image_index;
        return false;	
    }
    
}

//Virando a sprite conforme a velocidade
function ajusta_xscale()
{
    if (velh != 0)
    {
        xscale = sign(velh);
    }
}

//Chao
function checando_chao() 
{
    var _chao_solido = place_meeting(x, y + 1, colisor);
    var _chao_fino = false;
    
    // Só verifica a plataforma se estiver caindo ou parado (nunca subindo)
    if (velv >= 0)
    {
        var _oneway = instance_place(x, y + 1, obj_colisor_fino);
        if (_oneway != noone)
        {
            if (round(bbox_bottom) <= round(_oneway.bbox_top))
            {
                _chao_fino = true;
            }
        }
    }
    
    chao = _chao_solido or _chao_fino;
}

function checando_chao_geral()   
{
    chao = place_meeting(x, y + 1, colisor);
}

//Descontando timer em segundos
function desconta_timer()
{
    return (delta_time / 1000000) * global.vel_scale;
}

//Olhos
function olho_coordenada(_inst)
{
    return _inst.bbox_top + (_inst.bbox_bottom - _inst.bbox_top) * 0.35;
}

//Verificando parede
function verifica_parede(_obj = obj_player)
{
    var x1 = x,           
      y1 = olho_coordenada(self);
    var x2 = _obj.x,  y2 = olho_coordenada(_obj);
        
    var hit = collision_line(x1, y1, x2, y2, colisor, false, true);
    var _parede = (hit == noone);
    
    return _parede;
}

//Verificando distancias
function dist_x(_obj = obj_player)
{
   return abs(x - _obj.x)
}

function dist_y(_obj = obj_player)
{
    return abs(y - _obj.y);
}

//Posso seguir? regra universal
function seguindo(_distx,_disty,_obj = obj_player)
{
    if (instance_exists(_obj)) 
    {
        if (dist_x(_obj) < _distx) and (dist_y(_obj) < _disty) and (verifica_parede(_obj)) return true;
    }
}


//Volto se bato na parede
function bate_parede()
{
    // Bati na parede (Horizontal)
    if (place_meeting(x + velh, y, colisor)) 
    {
        velh *= -1;
    }
       
    // Invertendo a velocidade caso a borda acabe
    if (grav != 0) // Só verifica buraco se tiver gravidade
    {
        var _dist_sensor = (sprite_width / 2) + 4; 
        var _check_x = x + (sign(velh) * _dist_sensor);
        
        // Se NÃO tem chão à frente E estou no chão agora
        if (!place_meeting(_check_x, y + 1, colisor) and chao) 
        {
            velh *= -1;
        }
    }
}


/// @function efeito_sonoro(sound_id, priority, [pitch_var=0], [gain_var=0])
/// @description Toca um efeito sonoro obedecendo a prioridade e o volume global.
/// @param {Asset.GMSound} sound_id    O recurso de som (ex: snd_player_jump)
/// @param {Real}          priority    A prioridade do som (ex: 10, 50, 100)
/// @param {Real}          [pitch_var] (Opcional) Variação de pitch (ex: 0.1 para +/- 10%)
/// @param {Real}          [gain_var]  (Opcional) Variação de volume (ex: 0.1 para +/- 10%)

function efeito_sonoro(sound_id, priority, pitch_var = 0, gain_var = 0) 
{
    if (global.pause)
    {
        // Descobre a qual grupo este som pertence
        var _group = audio_sound_get_audio_group(sound_id);

        if (_group == ag_gameplay)
        {
            return noone; 
        }
    }
    
    
    if (global.sfx_volume <= 0)
    {
        return noone; 
    }

    var _sound_instance = audio_play_sound(sound_id, priority, false); 

    var _final_gain = 1.0 * global.sfx_volume;


    if (gain_var > 0)
    {
        var _random_factor = random_range(1.0 - gain_var, 1.0 + gain_var);
        _final_gain *= _random_factor; 
        
 
        _final_gain = clamp(_final_gain, 0, 1);
    }
    
    audio_sound_gain(_sound_instance, _final_gain, 0);

    if (pitch_var > 0)
    {
        var _pitch = 1.0 + random_range(-pitch_var, pitch_var);
        audio_sound_pitch(_sound_instance, _pitch);
    }

    return _sound_instance;
}

/// @function efeito_sonoro_3d(sound_id, x, y, dist_min, dist_max, priority, [pitch_var])
/// @description Para sons únicos (Explosões, gritos, batidas). "Fire and Forget".
function efeito_sonoro_3d(_snd, _x, _y, _dist_min, _dist_max, _prio, _pitch_var = 0)
{
    if (global.sfx_volume <= 0) return noone;
    
    var _snd_inst = audio_play_sound_at(_snd, _x, _y, 0, _dist_min, _dist_max, 1, false, _prio);
    
    // Aplica o volume global
    audio_sound_gain(_snd_inst, global.sfx_volume, 0);

    // Variação de Pitch 
    if (_pitch_var > 0)
    {
        var _pitch = 1.0 + random_range(-_pitch_var, _pitch_var);
        audio_sound_pitch(_snd_inst, _pitch);
    }
    
    return _snd_inst;
}

/// @function gerencia_som_loop_3d(variavel_som, asset_som, dist_max, [dist_min])
/// @description Para sons contínuos (Fogueiras, Cachoeiras). Colocar no STEP.
function gerencia_som_loop_3d(_som_inst, _asset, _dist_max, _dist_min = 100)
{
    var _cam_x = camera_get_view_x(view_camera[0]) + (camera_get_view_width(view_camera[0]) * 0.5);
    var _cam_y = camera_get_view_y(view_camera[0]) + (camera_get_view_height(view_camera[0]) * 0.5);
    
    var _dist = point_distance(x, y, _cam_x, _cam_y);

    // DENTRO DO ALCANCE
    if (_dist <= _dist_max)
    {
        if (!audio_is_playing(_som_inst))
        {
            // Toca em loop (true)
            _som_inst = audio_play_sound_at(_asset, x, y, 0, _dist_min, _dist_max, 1, true, 10);
        }
        
        if (audio_is_playing(_som_inst))
        {
            // Atualiza ganho global continuamente
            audio_sound_gain(_som_inst, global.sfx_volume, 0); 
            
            if (global.pause) audio_pause_sound(_som_inst);
            else audio_resume_sound(_som_inst);
        }
    }
    // FORA DO ALCANCE
    else
    {
        if (audio_is_playing(_som_inst))
        {
            audio_stop_sound(_som_inst);
            _som_inst = noone;
        }
    }
    
    return _som_inst;
}

/// @function               IniciarTransicao(_sala_destino, _funcao_callback)
/// @description            Inicia um fade out para uma nova sala.
/// @param {Asset.GMRoom}   _sala_destino     A sala para onde ir (ex: rm_level_2)
/// @param {Method}         _funcao_callback  Opcional. Função a ser executada na troca.

function IniciarTransicao(_sala_destino,x_destino = noone,y_destino = noone, _funcao_callback = undefined) 
{
    var _obj = instance_find(obj_transicao_mestre, 0);
    
    if (!instance_exists(_obj))
    {
        _obj = instance_create_depth(0, 0, -9999, obj_transicao_mestre);
        _obj.persistent = true;
    }
    
    
    
    if (_obj.mode == "idle")
    {
        with (_obj)
        {
            mode = "fade_out";
            room_destino = _sala_destino;
            acao_callback = _funcao_callback;
            alpha = 0; 
            //Passando coordenadas
            global.target_x = x_destino;
            global.target_y = y_destino;
        }
        return true; // Transição iniciada
    }
    
    return false; // Transição já estava em progresso
}

function criar_dialogo(_textos, _nome = undefined, _callback = undefined)
{
    if (instance_exists(obj_dialogo)) return;
    
    var _inst = instance_create_depth(0, 0, -9999, obj_dialogo);
    
    _inst.dialogo = {
        texto: _textos,
        nome: _nome,
        txt_vel: 0.4,
        fonte: fnt_dialogo,
        som: snd_test,
        callback: _callback 
    };
    
    _inst.player = obj_player;
    
    if (instance_exists(obj_player)) 
    {
        with (obj_player) 
        {
            troca_estado(estado_wait);
            velh = 0;
            velv = 0;
        }
    }
}

function pegar_config_luz()
{
    var _cfg = {
        ambiente: make_color_rgb(20, 20, 35),
        tem_sol: false,
        sol_angulo: 270,
        sol_forca: 0.5,
        sol_cor: c_white
    };

    
    if (asset_has_any_tag(room, "Luz_Praia"))
    {
        _cfg.ambiente = make_color_rgb(100, 100, 120);
        _cfg.tem_sol = true;
        _cfg.sol_cor = c_orange;
        _cfg.sol_angulo = 300; 
    }
    else if (asset_has_any_tag(room, "Luz_Caverna"))
    {
        _cfg.ambiente = make_color_rgb(20, 20, 40);
        _cfg.tem_sol = false;
    }
    else if (asset_has_any_tag(room, "Luz_Ruinas"))
    {
        _cfg.ambiente = make_color_rgb(10, 10, 20);
        _cfg.tem_sol = false;
    }
    else if (asset_has_any_tag(room, "Luz_Menu"))
    {
        _cfg.ambiente = c_white;
        _cfg.tem_sol = false;
    }

    // Exceções manuais continuam iguais
    switch(room)
    {
        case rm_arena: // Exemplo
              _cfg.ambiente = c_black; 
             _cfg.tem_sol = false;
        break;
    }

    return _cfg;
}

function get_permanentemente_quebrados_key()
{
    return room_get_name(room) + "_" + string(xstart) + "_" + string(ystart)
}

function get_item_coletado_key() 
{
    return room_get_name(room) + "_" + object_get_name(object_index) + "_" + string(x) + "_" + string(y);
}
