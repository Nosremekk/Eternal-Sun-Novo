estado_idle   = new estado();
estado_segue  = new estado();
estado_debug  = new estado();
estado_focus  = new estado();


alvo     = noone;
vel_cam  = .1;
arredonda = true;

//Se já existir player no início, define como alvo
if (instance_exists(obj_player)) alvo = obj_player;

// Começa centrado no alvo
if (instance_exists(alvo)) {
    x = alvo.x;
    y = alvo.y;
}


cam_w_base = camera_get_view_width(view_camera[0]);
cam_h_base = camera_get_view_height(view_camera[0]);

escala_atual = 1

escala_camera  = 1

hurt = false;
boss = false;
hurt_inimigo = false;

zoom_in_out = function(_p = alvo)
{
    if (hurt) 
    {
        zoom_alvo = 1.2;
    }
    else if (hurt_inimigo) 
    {
        zoom_alvo = 0.9;
    }
    else if (boss) 
    {
        zoom_alvo = 1.4;
    }
    else if (instance_exists(obj_dialogo)) 
    {
        zoom_alvo = 0.85;
    }
    
    else if (!_p.chao and abs(_p.velv) > 5) 
    {
        zoom_alvo = 0.85; 
    }
    else if (abs(_p.velh) > 4) 
    {
        zoom_alvo = 0.9;
    }
}



olharfrente_x = 0;    
olharfrente_y = 0;      
dist_olharfrente = 48; 
vel_olharfrente = 0.1; 

olha_timer = 0;
olha_timer_max = 45;

zoom_alvo = 1; 
zoom_vel  = .05;

//Screenshake
forca_shake = 0;
lerp_shake = .1;

aplicar_shake = function(_forca)
{
    // Multiplica pela configuração do menu
    var _forca_real = _forca * global.screenshake_mult;
    
    if (_forca_real > forca_shake) forca_shake = _forca_real;
}

//Timer de verificação
timer_ativacao = 0;
delay_ativacao = 12;

//Foco temporario para cutscene
focus_x = 0;
focus_y = 0;
focus_timer = 0;
focus_lock = false; // trava até liberar manualmente


// função auxiliar para disparar foco
/// camera_focus(_alvoOuX, [_y], _tempo, [_lock])
camera_focus = function(_arg0, _arg1, _arg2, _arg3) {
    if (is_real(_arg0)) 
    {
        focus_x = _arg0;
        focus_y = _arg1;
        focus_timer = _arg2;
        focus_lock = argument_count > 3 ? _arg3 : false;
    } 
    else 
    {
        if (instance_exists(_arg0)) 
        {
            focus_x = _arg0.x;
            focus_y = _arg0.y;
        }
        focus_timer = _arg1;
        focus_lock = argument_count > 2 ? _arg2 : false;
    }

    troca_estado(estado_focus);
};

// função para liberar foco manualmente
camera_release = function() {
    focus_lock = false;
    focus_timer = 0; 
};

//offset de dash/ataque
kick_x = 0;
kick_y = 0;
kick_decay = .15;


aplica_zoom = function() {
    var _vw = cam_w_base * escala_camera;
    var _vh = cam_h_base * escala_camera;
    camera_set_view_size(view_camera[0], _vw, _vh);
};

camera_apply_pos = function() {
    var _vw = camera_get_view_width(view_camera[0]);
    var _vh = camera_get_view_height(view_camera[0]);

    // AQUI ESTÁ A CORREÇÃO PRINCIPAL:
    // Mantemos o x/y do objeto decimais (suaves), mas desenhamos
    // a view em posições inteiras (floor) para encaixar no pixel art.
    var _cx = arredonda ? floor(x) : x;
    var _cy = arredonda ? floor(y) : y;
    
    //Calculando Shake
    var _shk_x = 0;
    var _shk_y = 0;
    
    if (forca_shake > 0) {
        _shk_x = random_range(-forca_shake, forca_shake);
        _shk_y = random_range(-forca_shake, forca_shake);
        
        // Reduz o shake
        forca_shake = lerp(forca_shake, 0, lerp_shake);
        if (forca_shake < 0.5) forca_shake = 0;
    }
    
    //Somando shake
    var _vx = (_cx + _shk_x) - _vw * 0.5;
    var _vy = (_cy + _shk_y) - _vh * 0.5;
    

    _vx = clamp(_vx, 0, max(0, room_width  - _vw));
    _vy = clamp(_vy, 0, max(0, room_height - _vh));

    camera_set_view_pos(view_camera[0], _vx, _vy);
    camera_set_view_angle(view_camera[0], _shk_x * 0.5);
};

//Função para olhar pra frente
olha_frente = function(_p = alvo)
{
    //Olhando para frente em movimento
    var _target_olharfrente_x = 0;
    if (abs(_p.velh) > 0.5) {
        _target_olharfrente_x = dist_olharfrente * sign(_p.velh);
    }
    else _target_olharfrente_x = dist_olharfrente * sign(_p.xscale);
    
    olharfrente_x = lerp(olharfrente_x, _target_olharfrente_x, vel_olharfrente);

}

//Função para olhar para cima e baixo
olha_vertical = function(_p = alvo)
{
    //Olhando para cima e para baixo
    var target_olharfrente_y = 0;
    var _dist_olhar = 48;

    
    if (_p.estado_atual == _p.estado_idle) and (InputCheck(INPUT_VERB.UP) xor InputCheck(INPUT_VERB.DOWN))
    {
        olha_timer++;
        if (olha_timer >= olha_timer_max)
        {
            if (InputCheck(INPUT_VERB.UP)) target_olharfrente_y = -_dist_olhar;
                else target_olharfrente_y = _dist_olhar;
        }
    }
    else olha_timer = 0;
        
    if (olha_timer < olha_timer_max) and (_p.velv > 4) target_olharfrente_y = _dist_olhar/2;
        
    if (hurt) target_olharfrente_y = _dist_olhar/1.5;



    olharfrente_y = lerp(olharfrente_y, target_olharfrente_y, vel_olharfrente);
}
//Função de zoom dinamico
zoom_dinamico = function(_p = alvo)
{
    zoom_alvo = 1.0; 
    // Decisão do Zoom
    zoom_in_out();  

    escala_atual = lerp(escala_atual, zoom_alvo, zoom_vel);

    if (_p.estado_atual == _p.estado_dash) kick_x = 32 * _p.xscale; 
    
    if (_p.estado_atual == _p.estado_attack) 
    {
        switch(_p.dir_atk) 
        {
            case "horizontal":    kick_x = 24 * _p.xscale; break;
            case "vertical_up":   kick_y = -24; break;
            case "vertical_down": kick_y = 24; break;
        }
    }

    
    kick_x = lerp(kick_x, 0, kick_decay);
    kick_y = lerp(kick_y, 0, kick_decay);
}

// Movimento da Câmera
move_camera = function(_p = alvo) 
{
    var _alvo_x = _p.x + olharfrente_x + kick_x;
    var _alvo_y = _p.y + olharfrente_y + kick_y;
    
    x = lerp(x, _alvo_x, vel_cam);
    y = lerp(y, _alvo_y, vel_cam);
}


estado_idle.inicia = function() { }

estado_idle.roda = function() {
    if (instance_exists(obj_player)) {
        alvo = obj_player;
        troca_estado(estado_segue);
        exit;
    }
    if (keyboard_check_pressed(vk_tab)) troca_estado(estado_debug);
}

estado_idle.finaliza = function() { }


estado_segue.inicia = function() {  }

estado_segue.roda = function()
{
    if (!instance_exists(alvo)) 
    {
        troca_estado(estado_idle);
        exit;
    }
    
    olha_frente();
    olha_vertical();
    move_camera();
    zoom_dinamico();
    // REMOVIDO: if (arredonda) { x = round(x); y = round(y); }
    // Isso destruía o movimento suave (sub-pixels) e causava o tremor.

    // Debug
    if (keyboard_check_pressed(vk_tab)) troca_estado(estado_debug);
}



estado_segue.finaliza = function() { }

// Estado de debug
estado_debug.inicia = function() { }

estado_debug.roda = function() {
    x = lerp(x, mouse_x, 0.10);
    y = lerp(y, mouse_y, 0.10);
    // REMOVIDO: Arredondamento destrutivo aqui também.
    if (keyboard_check_pressed(vk_tab)) troca_estado(estado_segue);
}

estado_debug.finaliza = function() { }



estado_focus.inicia = function() 
{
    if (alvo == obj_player) with(alvo) troca_estado(estado_wait);
}

estado_focus.roda = function() {
    x = lerp(x, focus_x, 0.1);
    y = lerp(y, focus_y, 0.1);
    
    // REMOVIDO: Arredondamento destrutivo.

    if (!focus_lock) {
        focus_timer--;
        if (focus_timer <= 0) {
            troca_estado(estado_segue);
        }
    }
};


estado_focus.finaliza = function() {
    // reseta timer
    focus_timer = 0; 
    if (alvo == obj_player) with(alvo) troca_estado(estado_idle);
}


// Inicia estado
if (instance_exists(alvo)) inicia_estado(estado_segue);
else inicia_estado(estado_idle);
    


//Função de ativar instancias
ativa_instancias = function()
{
//Regiao de desativar
instance_deactivate_object(obj_entidade)        
instance_deactivate_object(obj_inimigo_pai)        
instance_deactivate_object(obj_luz)        
instance_deactivate_object(obj_entidade_npc)        
instance_deactivate_object(obj_morte) 
instance_deactivate_object(obj_transicao) 
instance_deactivate_object(obj_powerup)
//instance_deactivate_object(obj_ocultador)
instance_deactivate_object(obj_parede_secreta)
//instance_deactivate_object(obj_plataforma_movel)
instance_deactivate_object(obj_plataforma_quebravel)
instance_deactivate_object(obj_colisor_fino)
instance_deactivate_object(obj_tutorial)
            
    
//Regiao de ativação    
var _cam_x = camera_get_view_x(view_camera[0]);
var _cam_y = camera_get_view_y(view_camera[0]);
var _cam_w = camera_get_view_width(view_camera[0]);
var _cam_h = camera_get_view_height(view_camera[0]);
var _margem = 300;

instance_activate_region( _cam_x - _margem, _cam_y - _margem, _cam_w + (_margem * 2), _cam_h + (_margem * 2), true );
instance_activate_object(obj_player);    
}

