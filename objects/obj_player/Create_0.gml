event_inherited()

max_velh          = global.velh_calculada; 
max_velh_anterior = max_velh;
passo_sfx = false;
//Colisão e movimentação
grav       = .3;
grav_padrao= .3;
acel_chao  = .1;
acel_ar    = .07;
acel       = .1;
max_velv   = 7;     // impulso de pulo

entrou_porta = false;

// Timers de pulo 
limite_pulo   = 6;  // coyote
timer_pulo    = 0;
limite_buffer = 6;  // jump buffer
timer_queda   = 0;

//Timers combate
limite_buffer_atk = 6; // 6 frames 
timer_atk_buffer  = 0;

// Jumps extras no ar 
jump_extra_left = global.powerups[powerup.DOUBLE_J];

velh = 0;
velv = 0;
chao = false;


len   = 10;
dura_dash  = 1/4;  
desconta_dura_dash = dura_dash;
carga = global.max_carga;
dir   = 0;  

// Parede 
parede_dir   = false;
parede_esq   = false;
limite_parede = 6;
timer_parede = 0;
ultima_parede = 0;   // 0=dir, 1=esq
deslize       = 2;  

//Variaveis de ataque
hitbox = noone;
hitbox_x = 0;
hitbox_y = 0;
dir_atk = noone;
desliza_hit = false;
atacando_parede = false;
duracao_inv = 1.25;

// inputs 
up = false;
down = false;
left = false;
right = false;
jump = false;
jump_s = false;
dash = false;
attack = false;
marca_btn = false;

// visual
xscale = 1;
xscale_deslize = 1;
sprite = spr_player_idle;

//Combate
hurt_id = 0;
timer_dano = 0;
dispara_alarme = false;
timer_respawn = 0;
timer_recuo_ataque = 0;
inimigo_marcado_atingido = false;
cura = 1;

//Chao seguro
safe_x = x;
safe_y = y;
timer_solo_seguro = 0;
tempo_para_estabilizar = 1/12; //Em segundos
timer_intervalo_save = 0;
intervalo_entre_saves = 1/8 //Em segundos
tilemap_morte = layer_tilemap_get_id("Morte");

//Queda
tempo_queda_livre = 0;
limite_tempo_queda_land = 1.5;

//pogo
poguei = false;


//Variaveis de GUI
var _view_w = camera_get_view_width(view_camera[0]);
var _dis_w = display_get_gui_width();

//Escala do jogo
escala = _dis_w / _view_w;
//Tamanho do sprite da vida 
spr_vida_w = sprite_get_width(spr_life_empty);

//Camera
cam = noone;
luz = noone;

//Estados
estado_idle = new estado();
estado_walk = new estado();
estado_jump = new estado();
estado_dash  = new estado(); 
estado_attack = new estado(); 
estado_hurt = new estado();
estado_dead = new estado();
estado_wait = new estado();
estado_espinho = new estado();
estado_float = new estado();
estado_wakeup = new estado();
estado_land = new estado();

//Camera
instancia_camera = function()
{
    cam = instance_create_layer(x,y,"Controladores",obj_cam);
    luz = obj_controla_luz;
    hud = instance_create_layer(x,y,"Controladores",obj_hud);
}

controles = function() {
    left = InputCheck(INPUT_VERB.LEFT);
    right = InputCheck(INPUT_VERB.RIGHT);
    up = InputCheck(INPUT_VERB.UP);
    down = InputCheck(INPUT_VERB.DOWN);
    jump = InputPressed(INPUT_VERB.JUMP);
    jump_s = InputReleased(INPUT_VERB.JUMP);
    dash = InputPressed(INPUT_VERB.DASH);
    attack = InputPressed(INPUT_VERB.ATTACK);
    marca_btn = InputPressed(INPUT_VERB.HOOK);
    
    if (attack) timer_atk_buffer = limite_buffer_atk;
}

checando_paredes = function() 
{
    var _inst_dir = instance_place(x + 1, y, colisor);
    var _inst_esq = instance_place(x - 1, y, colisor);
    
    parede_dir = (_inst_dir != noone) and (_inst_dir.object_index != obj_plataforma_movel);
    parede_esq = (_inst_esq != noone) and (_inst_esq.object_index != obj_plataforma_movel);

    // --- COYOTE TIME DA PAREDE ---
    if (parede_dir or parede_esq) 
    {
        // Se estou colado, o relógio reseta e lembro de que lado era
        timer_parede = limite_parede;
        ultima_parede = parede_dir ? 0 : 1; // 0 = dir, 1 = esq
    } 
    else 
    {
        // Se desgrudei, o relógio começa a contagem regressiva
        if (timer_parede > 0) timer_parede--;
    }
}

direcao_dash = function() 
{
    if (global.powerups[powerup.DASH_CELESTE])
    {
        var _hor = right - left;
        var _ver = down - up;
        
        if (_hor == 0 and _ver == 0) return (xscale >= 0) ? 0 : 180;
        
        return point_direction(0, 0, _hor, _ver);
    }
    else
    {
        if (right) return 0;
        if (left)  return 180;
        return (xscale >= 0) ? 0 : 180;
    }
}

// Aceleração horizontal
movimento_horizontal = function() 
{
    var _input_ativo = (timer_recuo_ataque > 0) ? 0 : (right - left);
    
    // Usa velocidade atual (pode ter mudado por amuleto)
    var avanco_h = _input_ativo * max_velh; 
    
    acel = chao ? acel_chao : acel_ar;
    velh = lerp(velh, avanco_h, acel);
    
    if (timer_recuo_ataque > 0)
    {
        if (place_meeting(x + velh, y, colisor))
        {
            // Bati na parede! 
            velh = -velh * 0.5; 
            
            //Tocar som de bater na parede dps
        }
    }
    
    if (timer_recuo_ataque > 0) timer_recuo_ataque -= desconta_timer();
};

// Lógica de pulo
movimento_vertical = function() 
{
    if (chao) velv = 0;
    var _quer_descer = (down and jump); 
    
    // --- DESCER DA PLATAFORMA FINA ---
    if (_quer_descer)
    {
        var _plataforma = instance_place(x, y + 1, obj_colisor_fino);
        var _chao_solido = place_meeting(x, y + 1, colisor); 
        
        // Se tem plataforma fina, mas NÃO tem chão de pedra junto...
        if (_plataforma != noone and !_chao_solido) 
        {
            velv = 1;
            timer_pulo = 0; 
            timer_queda = 0; 
            chao = false; 
            
            y += 2; // O SEGREDO: Força o pé do player a atravessar a plataforma fina fisicamente!
            return; // Encerra a função AQUI. Sem risco do jogo tentar dar um pulo normal!
        }
    }
    
    // Coyote
    if (chao) timer_pulo = limite_pulo;
    else if (timer_pulo > 0) timer_pulo--;

    // Buffer
    if (jump) timer_queda = limite_buffer;

    // Executa pulo se puder
    if (timer_queda > 0 and (chao or timer_pulo > 0)) {
        velv = -max_velv;
        
        var _plat = instance_place(x, y + 2, obj_plataforma_movel);
        if (_plat != noone and _plat.vsp < 0) 
        {
            velv += _plat.vsp; 
        }
        
        timer_pulo  = 0;
        timer_queda = 0;
        cria_particula(x, bbox_bottom, TIPO_PARTICULA.POEIRA_PULO, 5)
        efeito_sonoro(sfx_jump, 50, 0.1)
    }

    // Gravidade
    if (!chao) velv += (grav * global.vel_scale);

    // Pulo variável 
    if (jump_s and velv < 0) velv *= 0.7;

    // Limite vertical
    velv = clamp(velv, -max_velv*3, max_velv);

    // Consome buffer gradualmente
    if (timer_queda > 0) timer_queda--;
};
// Colisao integrada
colisao = function()
{
    var _velh_final = velh * global.vel_scale;
    var _velv_final = velv * global.vel_scale;

    var _ignorando_sombrio = (estado_atual == estado_dash) and (global.powerups[powerup.DASH_FANTASMA]);
    if (_ignorando_sombrio) instance_deactivate_object(obj_colisor_sombrio);

    // --- HORIZONTAL ---
    if (place_meeting(x + _velh_final, y, colisor)) 
    {
       while (!place_meeting(x + sign(_velh_final), y, colisor)) 
       {
           x += sign(_velh_final);
       }
       _velh_final = 0;
       velh = 0;
    }
    x += _velh_final;
    
    // --- VERTICAL ---
    var _bateu_chao = false;
    var _dir_y = sign(_velv_final);

    // 1. Parede Sólida
    if (place_meeting(x, y + _velv_final, colisor)) 
    {
       while (!place_meeting(x, y + sign(_velv_final), colisor)) 
       {
           y += sign(_velv_final);
       }
       _velv_final = 0;
       velv = 0;
       if (_dir_y > 0) _bateu_chao = true; 
    }
    
    // 2. Plataforma Fina (One-Way)
    if (!_bateu_chao and _velv_final > 0) 
    {
        var _oneway = instance_place(x, y + _velv_final, obj_colisor_fino);
        if (_oneway != noone)
        {
            // Se o pé antes da queda estava ACIMA do topo, ele colide.
            // (Como a descida te forçou Y+2, isso aqui vira Falso e ele cai normal!)
            if (round(bbox_bottom) <= round(_oneway.bbox_top))
            {
                while (!place_meeting(x, y + sign(_velv_final), _oneway)) 
                {
                    y += sign(_velv_final);
                }
                _velv_final = 0;
                velv = 0;
                _bateu_chao = true;
            }
        }
    }
    
    y += _velv_final;

    // --- REATIVA FANTASMA E POUSO ---
    if (_ignorando_sombrio) instance_activate_object(obj_colisor_sombrio);
    
    if (_bateu_chao)
    {
        if (!chao)
        {
            restart_powerups(); 
            if (estado_atual == estado_jump or estado_atual == estado_float)
            {
                 cria_particula(x, bbox_bottom, TIPO_PARTICULA.POEIRA_PULO, 3);
                 if (abs(velh) > 0.1) troca_estado(estado_walk);
                 else troca_estado(estado_idle);
            }
        }
        tempo_queda_livre = 0;
    }
}


//o chão é seguro para salvar?
verificar_solo_seguro = function()
{
    if (!place_meeting(x, y + 1, colisor)) return false;

    if (tilemap_get_at_pixel(tilemap_morte, x, bbox_bottom + 1)) return false;

    var _inst_chao = instance_place(x, y + 1, colisor);
    
    
    if (_inst_chao != noone)
    {

        if (object_is_ancestor(_inst_chao.object_index, obj_plataforma_movel) or (_inst_chao.object_index == obj_plataforma_movel))
        {
            return false; // É móvel
        }
        
        if (object_is_ancestor(_inst_chao.object_index, obj_plataforma_quebravel) or (_inst_chao.object_index == obj_plataforma_quebravel))
        {
            return false; // Cai
        }
    }
    

    var _margem = 6; 
    var _ponto_esq_tem_chao = position_meeting(bbox_left + _margem, bbox_bottom + 1, colisor);
    var _ponto_dir_tem_chao = position_meeting(bbox_right - _margem, bbox_bottom + 1, colisor);

    if (!_ponto_esq_tem_chao or !_ponto_dir_tem_chao) return false;
    
    // Inimigos proximos?
    var _raio_inimigo = 48;
    with (obj_inimigo_pai)
    {
        if ((point_distance(x,y,other.x,other.y)) < _raio_inimigo) return false;
    }
    
    return true; 
}

atualiza_safe_ground = function()
{
    // Desconta o cooldown se ele existir
    if (timer_intervalo_save > 0) timer_intervalo_save -= desconta_timer();

    // Lógica de estabilidade
    if (chao)
    {
        if (verificar_solo_seguro())
        {
            timer_solo_seguro += desconta_timer();
            
            //O chão está estável?
            if (timer_solo_seguro >= tempo_para_estabilizar)
            {
                // Posso salvar dnv?
                if (timer_intervalo_save <= 0)
                {
                    safe_x = x;
                    safe_y = y;
                    
                    timer_intervalo_save = intervalo_entre_saves;
                }
            }
        }
        else
        {
            timer_solo_seguro = 0; 
        }
    }
    else
    {
        timer_solo_seguro = 0;
    }
}

verifica_espinho = function()
{
    if (inv) or (estado_atual == estado_dead) or (estado_atual == estado_espinho) return;
        
    var _tocou_tile = tilemap_get_at_pixel(tilemap_morte, x, bbox_bottom - 1)
    
    if (_tocou_tile > 0) troca_estado(estado_espinho);
}

//Deliza hit
ajusta_xscale_player = function()
{
    if (timer_recuo_ataque > 0) exit;
    if (estado_atual == estado_attack) and (atacando_parede) exit;    
        
    if (abs(velh) > .5)
    {
        xscale = sign(velh);
    }
}

aplicar_recuo_ataque = function(_forca_extra = 0, _eh_parede = false)
{
    if (!_eh_parede) and (!chao) exit;

    var _pct = global.combo / global.limite_combo;
    
    var _forca = (_forca_extra > 0) ? _forca_extra : lerp(1, 8, _pct * _pct); 
    
    // Direção do recuo (contrária ao olhar)
    var _dir_recuo = -sign(xscale);
    var _vel_final = _dir_recuo * _forca;

    //Nao cair da borda
    if (chao)
    {
        var _check_dist = (sprite_width / 2) + 4; 
        var _ponto_atras = x + (_dir_recuo * _check_dist);
        
        // Se NÃO tem chão atrás cancela o recuo para não cair
        if (!place_meeting(_ponto_atras, y + 1, colisor))
        {
            return; 
        }
    }

    // Aplica
    velh = _vel_final;
    timer_recuo_ataque = .3; 
}

aplicar_recuo_parede = function()
{
    if (dir_atk != "horizontal") exit;

    if (instance_exists(hitbox)) and (!bateu_parede)
    {
        var _bateu = false;
        
        with (hitbox)
        {
            if (place_meeting(x, y, other.colisor)) 
            {
                _bateu = true;
            }
        }
        
        if (_bateu)
        {
            bateu_parede = true;
            aplicar_recuo_ataque(6, true); 
            aplica_screenshake(2); 
            aplica_hitstop(0.1);  
            InputVibrateConstant(0.5, 0.0, 120)
            
            var _parede_x = (xscale > 0) ? bbox_right : bbox_left;
            var _altura_y = hitbox.y; 
            cria_particula(_parede_x, _altura_y, TIPO_PARTICULA.FAISCA, 5, 0, 360);
            efeito_sonoro(sfx_wallhit, 50, 0.1)
        }
    }
}

//Atacando
atacando = function()
{   
    // ALTERADO: Verifica o Buffer ao invés do input direto "attack"
    if (timer_atk_buffer > 0) and (estado_atual != estado_attack) 
    {
        // Consome o buffer imediatamente
        timer_atk_buffer = 0; 
        
        troca_estado(estado_attack);
        
        // Na parede
        var _eh_wall_atk = (!chao) 
                           and (parede_dir or parede_esq) 
                           and (global.powerups[powerup.WALL]);

        if (_eh_wall_atk)
        {
            dir_atk = "horizontal";
        }
        else 
        {
            if (up + down != 0) and (!chao or !down) 
            {
                dir_atk = up ? "vertical_up" : "vertical_down";
            }
            else dir_atk = "horizontal";     
        }
    }
}

define_dano = function()
{
    //Defininido meu dano (Usa a global calculada)
    var _dano = global.dano;
    
    if (global.powerups[powerup.COMBO])
    {
        var _percentual_combo = (global.combo/global.limite_combo);
    
       _dano = global.dano + global.dano_combo * _percentual_combo;
    
       if (_percentual_combo >= 1) and (global.vida_atual == global.vida_max) _dano = global.dano + global.dano_combo * 1.25;
    }
    
    return _dano;
}

coordenada_hitbox = function()
{
    switch(dir_atk)
    {
        case "horizontal":
            hitbox_x = x + sprite_width * xscale;
            hitbox_y = y - sprite_height/2
        break;
        
        case "vertical_up":
            hitbox_x = x;
            hitbox_y = y - sprite_height * 1.5;
        break;
        
        case "vertical_down":
            hitbox_x = x;
            hitbox_y = y + sprite_height/2;
        break;
    }
}

//Powerup de atirar
marcando_inimigo = function()
{
    if (marca_btn) and (global.powerups[powerup.MARK])
    {
        //Ida
        if (global.inimigo_marcado == noone) and (!instance_exists(obj_player_marca))
        {
            var _hor = right - left;
            var _ver = down - up;
            
            //Se neutro, usa o xscale
            if (_hor == 0 and _ver == 0) _hor = xscale;
            
            var _angulo = point_direction(0, 0, _hor, _ver);
            
            var _marca = instance_create_layer(x, y - sprite_height/2, "Instances", obj_player_marca);
            _marca.pai = self;      
            _marca.fase = 0; 
            _marca.direction = _angulo;
            _marca.image_angle = _angulo;
            InputVibrateConstant(0.15, 0.0, 80)
        }
        // Volta
        else if (global.inimigo_marcado != noone)
        {
            var _volta = instance_create_layer(global.marca_pos_x, global.marca_pos_y, "Instances", obj_player_marca);
            _volta.fase = 1; 
            _volta.speed = 2;
            
            //Resetando globais
            global.inimigo_marcado = noone;
            global.timer_marcado = 0;
            global.marca_room = noone;
        }
    }
}

gerencia_timer_marca = function()
{
    if (global.inimigo_marcado != noone)
    {
        global.timer_marcado -= desconta_timer();
        
        //Acabou o tempo
        if (global.timer_marcado <= 0)
        {
            //Cria efeito se estiver na mesma sala
            if (global.marca_room == room)
            {
                var _volta = instance_create_layer(global.marca_pos_x, global.marca_pos_y, "Instances", obj_player_marca);
                
                //Configura retorno
                _volta.fase = 1; 
                _volta.speed = 2; 
            }

            //Reset
            global.inimigo_marcado = noone;
            global.timer_marcado = 0;
            global.marca_room = noone;
        }
    }
}

//Função de aplicar dash
aplica_dash = function()
{
    if (dash and (carga > 0)) and (global.powerups[powerup.DASH]) 
    { 
        dir = direcao_dash();
        
        if (global.powerups[powerup.WALL])
        {
            
            if (parede_dir) and (dir == 0 or right) and (!chao) 
            {
                dir = 180; // Força dash pra esquerda
            }
            
           
            if (parede_esq) and (dir == 180 or left) and (!chao)
            {
                dir = 0; // Força dash pra direita
            }
        }
    
        troca_estado(estado_dash); exit;
    }
}

//Recebendo dano e executando estado de morte ao inves de apenas ser destruido
//Método para receber dano
function recebe_dano(_dano = 1)
{
    if (inv) or (estado_atual == estado_dead) exit;
    
    var _dano_definitivo = _dano;
    
    if (hurt_id == global.inimigo_marcado)
    {
        aplica_screenshake(10)
        _dano_definitivo += 1;
        global.inimigo_marcado = noone;
    }
    
    global.vida_atual -= _dano_definitivo;
    //Garantindo que a vida atual não fique abaixo de zero
    global.vida_atual = clamp(global.vida_atual, 0, global.vida_max);
    
    efeito_sonoro(sfx_hurt, 90, 0.1);
    
    troca_estado(estado_hurt);
}

//Knockback após receber dano
function knockback()
{
    // PROTEÇÃO AQUI: Garante que quem me bateu ainda existe na tela!
    if (hurt_id != 0 and instance_exists(hurt_id)) 
    {
        var _dir = sign(x - hurt_id.x);
        if (_dir == 0) _dir = 1; 
        
        forca_knock = _dir * max_velh * 0.8;
        velh = forca_knock;
        hurt_id = 0;
    }    
    else 
    {
        velh = max_velh * 0.8;
    }
        
    velv = -max_velv * 0.6; 
    y -= 2; // Desgruda do chão
}
//Recupera vida e dispara alarme
recupera_vida = function()
{
    if (!global.powerups[powerup.COMBO]) exit;
    
    if (global.combo >= global.limite_combo)
    {
        global.combo = 1;
        //Recuperando vida
        var _cura_extra = inimigo_marcado_atingido ? 1 : 0;
        var _cura_total = cura + _cura_extra    
    
        if (global.vida_atual < global.vida_max) 
        {
            global.vida_atual += _cura_total;
            InputVibrateConstant(0.2, 0.0, 300)    
            global.vida_atual = clamp(global.vida_atual, 0, global.vida_max);
            
            cria_particula(x, y - (sprite_height / 2), TIPO_PARTICULA.COLETAVEL, 15, 0, 360);
            efeito_sonoro(sfx_heal, 50, 0.1)
        }
    }
    
    //Disparando alarme de resetar combo
    if (global.combo < global.limite_combo)
    {
        dispara_alarme = true;
    }
    
    inimigo_marcado_atingido = false;
}

alarme_vida = function()
{
    timer_dano += desconta_timer();
    if (timer_dano >= global.timer_combo)
    {
        timer_dano = 0;
        global.combo = 1;
        dispara_alarme = false;
    }
}

// Função para executar pogo
aplicar_pogo = function(_inimigo = false)
{
    // Só funciona se estiver atacando para baixo
    if (dir_atk != "vertical_down") exit;

    // Aplica o impulso para cima
    if (InputCheck(INPUT_VERB.JUMP))
    {
        velv = -max_velv * 1.3; 
    }
    else
    {
        velv = -max_velv * 0.9; 
    }
    
    // Reseta habilidades
    restart_powerups();
    
    // Feedback visual/sonoro
    aplica_screenshake(2);
    InputVibrateConstant(0.3, 0.0, 100);
    
 
    var _fx_x = x;
    var _fx_y = (instance_exists(hitbox)) ? hitbox.bbox_bottom : bbox_bottom;
    cria_particula(_fx_x, _fx_y, TIPO_PARTICULA.FAISCA, 5, 0, 360);
    
    // Som
    if (!_inimigo) efeito_sonoro(sfx_wallhit, 60, 0.1); 
    
    poguei = true;
}

//--Idle
estado_idle.inicia = function() 
{
    sprite = spr_player_idle;
    image_index  = 0;
}

estado_idle.roda = function() 
{
    // ambiente
    checando_chao();
    checando_paredes();
    // Idle
    movimento_horizontal();
    movimento_vertical();
    atualiza_safe_ground()
    //Atacando
    atacando();
    marcando_inimigo();

    if (chao) restart_powerups();
        
    //Trocando estado
    aplica_dash();

    if (right xor left) { troca_estado(estado_walk); exit; }
    if (!chao)        { troca_estado(estado_jump); exit; }
}

estado_walk.inicia = function() {
    sprite = spr_player_walk;
    image_index  = 0;
}

//--Walk
estado_walk.roda = function() 
{
    checando_chao();
    checando_paredes();
    movimento_horizontal();
    movimento_vertical();
    atualiza_safe_ground();
    atacando();
    marcando_inimigo();
    if (chao) restart_powerups(); 

    aplica_dash();
    if (!left and !right) or (left and right) { troca_estado(estado_idle); exit; }
    if (!chao)            { troca_estado(estado_jump); exit; }
    
    if (floor(image_index) == 3 or floor(image_index) == 7) 
    {
        // Verifica se já tocou som neste frame para não repetir
        if (passo_sfx != floor(image_index)) 
        {
            efeito_sonoro(sfx_steps, 10, 0.2, 0.3); 
            passo_sfx= floor(image_index);
        }
    }
    else
    {
        variavel_controle_passo = -1;
    }    
    
}

//--Jump
estado_jump.inicia = function() 
{
    sprite = spr_player_jump;
}

estado_jump.roda = function() 
{
    checando_chao();
    checando_paredes();
    movimento_horizontal();
    
    if (velv > 0) tempo_queda_livre += desconta_timer();
    else tempo_queda_livre = 0;
    
    // --- AS VARIÁVEIS COM A MÁGICA ---
    var tem_contato_fisico = (parede_dir or parede_esq); // Colisão exata
    var em_parede_coyote   = (!chao) and (tem_contato_fisico or timer_parede > 0); // Colisão + Tolerância
    var lado_atual         = ultima_parede; 
    
    if (sprite != spr_player_wall) 
    {
        atacando(); 
        marcando_inimigo();
    }

    // Usaremos isso para impedir que o Pulo Duplo saia junto
    var _deu_pulo_parede = false;

    // ===============================================
    // PRIORIDADE 1: WALL JUMP
    // ===============================================
    if (em_parede_coyote) and (global.powerups[powerup.WALL]) 
    {
        // O atrito da parede (escorregar) só funciona se eu estiver FISICAMENTE tocando nela
        if (tem_contato_fisico) 
        {
            if (velv > 0) 
            {
                velv = lerp(velv, deslize, 0.15);
                velv = max(velv, min(deslize, max_velv)); 
                sprite = spr_player_wall;
                restart_powerups();
                
                if (random(100) < 15) 
                {
                    var _x_wall = parede_dir ? bbox_right : bbox_left;
                    cria_particula(_x_wall, y, TIPO_PARTICULA.POEIRA_DASH, 1);
                    tempo_queda_livre = 0;    
                }
            } 
            else 
            {
                velv += (grav * global.vel_scale);
            }
        } 
        else 
        {
            // Se eu desgrudei, mas estou no Coyote Time, eu caio com gravidade normal
            movimento_vertical();
        }

        // O Wall Jump em si (Ele aceita a tolerância do Coyote Time!)
        if (jump) 
        {
            velv = -max_velv;
            velh = (lado_atual == 0) ? -max_velh : max_velh;
            
            timer_pulo  = 0;
            timer_queda = 0;
            timer_parede = 0; // Mata o Coyote Time instantaneamente
            
            sprite = spr_player_jump;
            InputVibrateConstant(0.2, 0.0, 100);
            cria_particula(x, bbox_bottom, TIPO_PARTICULA.POEIRA_PULO, 5);
            efeito_sonoro(sfx_jump, 50, 0.1);
            
            _deu_pulo_parede = true; // Avisa que eu usei a parede!
        }
    } 
    else 
    {
        // Ar livre padrão
        movimento_vertical();
    }

    // ===============================================
    // PRIORIDADE 2: DOUBLE JUMP
    // ===============================================
    // Só tenta dar o Double Jump se o Wall Jump NÃO foi executado e não estou mais no Coyote Time
    if (!_deu_pulo_parede and !em_parede_coyote and jump and jump_extra_left > 0) 
    {
        velv = -max_velv;
        jump_extra_left--;
        timer_pulo  = 0;    
        timer_queda = 0; 
        cria_particula(x, bbox_bottom, TIPO_PARTICULA.SHOCKWAVE, 1);
        efeito_sonoro(sfx_double_jump, 60, 0.1);
    }

    // ===============================================
    // MECÂNICAS AÉREAS PADRÕES
    // ===============================================
    aplica_dash();
    
    var _caindo = velv > 0;
    var _na_parede = parede_dir or parede_esq;
    
    if (_caindo) and (jump) and (global.powerups[powerup.FLOAT]) and (!_na_parede)
    {
        timer_queda = 0;
        troca_estado(estado_float);
        exit;
    }

    if (velv < 0) image_index = 0; 
    else image_index = clamp(image_index, 1, sprite_get_number(sprite) - 1);

    if (chao) 
    {
        if (tempo_queda_livre > limite_tempo_queda_land)
        {
            troca_estado(estado_land);
        }
        else 
        { 
            troca_estado((abs(velh) > 0.1) ? estado_walk : estado_idle);
            cria_particula(x, bbox_bottom, TIPO_PARTICULA.POEIRA_PULO, 3);
        }
        
        tempo_queda_livre = 0;
        exit;
    }
}



//--Dash
estado_dash.inicia = function() 
{
    sprite = spr_player_dash;
    image_index  = 0;
    

    if (dir == 90 or dir == 270) desconta_dura_dash = dura_dash * 0.7;
    else desconta_dura_dash = dura_dash;
    
    carga--;
    InputVibrateConstant(0.3, 0.0, 150)
    cria_particula(x, y - (sprite_height / 2), TIPO_PARTICULA.POEIRA_DASH, 5)
    efeito_sonoro(sfx_dash, 50, 0.05)
    
    if (global.powerups[powerup.DASH_FANTASMA])
    {
        inv = true;
        image_alpha = 0.5;
    }
    
    dash_extensao_atual = 0;
    dash_extensao_maxima = 8;
    
    dei_long_jump = false;
}

estado_dash.roda = function() 
{
    // Se ainda não pulei, a velocidade é travada (dash normal)
    if (!dei_long_jump)
    {
        velh = lengthdir_x(len, dir);
        velv = lengthdir_y(len, dir);
    }
    else
    {
        // Se dei o long jump, a física do pulo (gravidade) toma conta!
        velv += (grav * global.vel_scale);
    }
    
    if (abs(velh) < 0.1) velh = 0;
    if (abs(velv) < 0.1) velv = 0;

    checando_chao();
    checando_paredes();
    atualiza_safe_ground();

    // ==========================================
    // GATILHO DO LONG JUMP
    // ==========================================
    if (jump and (chao or timer_pulo > 0) and !dei_long_jump)
    {
        if (dir == 0 or dir == 180 or dir == 315 or dir == 225)
        {
            dei_long_jump = true; // Entra no modo Long Jump!
            
            velh = sign(velh) * (max_velh * 2.5); // 2.5x a vel máxima pra voar longe
            velv = -max_velv * 0.7; // Pulo rasante
            
            // Opcional: Podemos aumentar o timer do dash aqui para o rastro durar o pulo todo
            desconta_dura_dash = dura_dash * 1.5; 
            
            cria_particula(x, bbox_bottom, TIPO_PARTICULA.POEIRA_PULO, 8);
            efeito_sonoro(sfx_jump, 50, 0.1);
            InputVibrateConstant(0.4, 0.0, 200);
            
            timer_pulo = 0; 
            timer_queda = 0;
            // NÃO DAMOS RETURN NEM TROCAMOS DE ESTADO! O PLAYER CONTINUA NO DASH!
        }
        else 
        {
             // Pulo normal pra cancelar dash vertical
             troca_estado(estado_jump);
             velh = sign(velh) * max_velh;
             velv = -max_velv;
             timer_pulo = 0; timer_queda = 0;
             return;
        }
    }
    // ==========================================

    desconta_dura_dash -= desconta_timer();
    
    // Fim do timer do Dash
    if (desconta_dura_dash <= 0) 
    {
        if (global.powerups[powerup.DASH_FANTASMA] and place_meeting(x, y, obj_colisor_sombrio))
        {
            if (dash_extensao_atual < dash_extensao_maxima)
            {
                desconta_dura_dash = desconta_timer(); 
                dash_extensao_atual++;
            }
            else
            {
                if (chao) troca_estado( (abs(velh) > 0.1) ? estado_walk : estado_idle );
                else      troca_estado(estado_jump);
                exit;
            }
        }
        else
        {
            if (chao) troca_estado( (abs(velh) > 0.1) ? estado_walk : estado_idle );
            else      troca_estado(estado_jump);
            exit;
        }
    }
    
    // Criando Rastro Fantasma do Dash
    if (current_time % 4 == 0) 
    {
        var _rastro = instance_create_depth(x, y, depth + 1, obj_rastro);
        _rastro.sprite_index = sprite_index;
        _rastro.image_index = image_index;
        _rastro.image_xscale = xscale; 
        _rastro.image_yscale = image_yscale; 
        
        if (global.powerups[powerup.DASH_FANTASMA]) _rastro.image_blend = c_dkgray; 
    }
};

estado_dash.finaliza = function() {
    // reduz suavemente a velocidade ao sair do dash
    if (!dei_long_jump)
    {
        velh = max_velh * sign(velh) * .5;
        velv = max_velv * sign(velv) * 0.5;
    }

    
    if (global.powerups[powerup.DASH_FANTASMA])
    {
        if (inv_timer <= 0) 
        {
            inv = false;
            image_alpha = 1.0;
        }
    }
    
    if (place_meeting(x, y, obj_colisor_sombrio))
    {
        var _oposto = dir + 180;
        var _dx = lengthdir_x(1, _oposto);
        var _dy = lengthdir_y(1, _oposto);
        
        var _seguranca = 500; 
        while (place_meeting(x, y, obj_colisor_sombrio) and _seguranca > 0)
        {
            x += sign(_dx); // O sign garante que ele se mova de pixel em pixel
            y += sign(_dy);
            _seguranca--;
        }
    }
}



//Atacando
estado_attack.inicia = function()
{
    sprite = spr_player_attack;
    image_index = 0; 
    bateu_parede = false;
    
    atacando_parede = false; 

    if (!chao) and (global.powerups[powerup.WALL]) // Só se tiver powerup
    {
        // Se tem parede na direita, viro pra esquerda
        if (parede_dir) 
        { 
            xscale = -1; 
            atacando_parede = true; 
        }
        // Se tem parede na esquerda, viro pra direita
        else if (parede_esq) 
        { 
            xscale = 1; 
            atacando_parede = true; 
        }
    }
    
    efeito_sonoro(sfx_attack, 40, 0.2)
}

estado_attack.roda = function()
{  
    if (desliza_hit) xscale = -xscale_deslize;

    
    //Criando minha hitbox
    if (!instance_exists(hitbox)) 
    {
        hitbox = instance_create_layer(hitbox_x,hitbox_y,"Instances",obj_hit);
        hitbox.dano = define_dano();
    }
    
    coordenada_hitbox(); 
    
    checando_chao();
    checando_paredes();
    movimento_horizontal();
    movimento_vertical();
    atualiza_safe_ground();
    
    // Hitbox segue o player
    hitbox.x = hitbox_x;
    hitbox.y = hitbox_y;
    
    if (dir_atk == "vertical_down") and (instance_exists(hitbox)) and (!poguei)
    {
        var _tocou_morte = false;
        
        // Centro-Baixo da Hitbox
        if (tilemap_get_at_pixel(tilemap_morte, hitbox.x, hitbox.bbox_bottom) > 0) _tocou_morte = true;
        
        // Canto Esquerdo-Baixo da Hitbox
        else if (tilemap_get_at_pixel(tilemap_morte, hitbox.bbox_left, hitbox.bbox_bottom) > 0) _tocou_morte = true;
        
        // Canto Direito-Baixo da Hitbox
        else if (tilemap_get_at_pixel(tilemap_morte, hitbox.bbox_right, hitbox.bbox_bottom) > 0) _tocou_morte = true;

        // Se tocou, aplica o Pogo
        if (_tocou_morte)
        {
            aplicar_pogo();
        }
        

        var _morte = instance_place(hitbox.x, hitbox.y, obj_morte);
        if (_morte != noone) 
        {
            aplicar_pogo();
            if (_morte.recupera_combo) adiciona_combo();
            _morte.tempo_pogo = .35;
        }
    }
    
    //Saindo do estado de ataque
    if (finalizou_animacao()) 
    {
        if (!chao) troca_estado(estado_jump);
        else if (right xor left) troca_estado(estado_walk);
        else troca_estado(estado_idle);
        exit;
    }
    
    aplicar_recuo_parede();
}
 
estado_attack.finaliza = function()
{
    instance_destroy(hitbox);
        
    hitbox = noone;
    
    
    dir_atk = noone;
    
    recupera_vida()//Combei? recuro minha vida
    
    cam.hurt_inimigo = false;
    
    poguei = false;    
}
//--Hurt
estado_hurt.inicia = function()
{
    inv = true;
    inv_timer = 0; 
    timer_stun = 0.3; 
    
    InputVibrateConstant(0.8, 0, 350);
    aplica_screenshake();
    aplica_hitstop();
    knockback();
    cam.hurt = true;
    global.combo = 1;
    restart_powerups();
}

estado_hurt.roda = function()
{
    checando_chao();
    movimento_vertical();
    
    // Desconta o tempo de paralisia
    timer_stun -= desconta_timer();
    
    if (timer_stun <= 0)
    {
        if (global.vida_atual <= 0) troca_estado(estado_dead);
        else troca_estado(estado_idle);
    }
}

estado_hurt.finaliza = function()
{
    cam.hurt = false;
}

//--Dead
estado_dead.inicia = function()
{ 
  
    sprite = spr_player_idle
    image_index  = 0;
    
    velh = 0;
    velv = 0;
    
    global.inimigo_marcado = noone;
    
    global.vel_scale = 0.5; 
    
    timer_respawn = 1; 
    obj_hud.morto = true;
}

estado_dead.roda = function()
{
    // Mantém parado
    movimento_vertical(); 
    velh = 0;

    // Conta o tempo
    timer_respawn -= desconta_timer()

    // Quando o tempo acabar...
    if (timer_respawn <= 0)
    {
        //Recupero minha vida
        global.vida_atual = global.vida_max;
        
        salvando_jogo(global.save,false);
        // Restaura velocidade do jogo
        global.vel_scale = 1; 

        // Tenta carregar o último save
        var _arquivo = "Save0" + string(global.save + 1) + ".json";
        
        if (file_exists(_arquivo))
        {
            carrega_jogo(global.save); 
        }
        else
        {
            // Caso morra antes de salvar eu volto pro inicio da sala
            IniciarTransicao(room);
        }
        
        // Sai pra outro estado pra nao rodar mais de uma vez
        troca_estado(estado_wait); 
        

        
    }
}
//--Wait
estado_wait.inicia = function()
{
    velh = 0;
    velv = 0;
}

//Dano ambiente
estado_espinho.inicia = function()
{
    //Dano manual
    if (!inv)
    {
        global.vida_atual = clamp(global.vida_atual - 1, 0, global.vida_max);
        global.combo = 1; 
        
        // Efeitos de impacto
        aplica_screenshake(12);
        aplica_hitstop();
        cam.boss = true;
        InputVibrateConstant(1.0, 0.0, 400)
    }

    //Verifica se morreu
    if (global.vida_atual <= 0)
    {
        troca_estado(estado_dead);
        exit;
    }

    global.respawn_anim = true;
    global.player_nasce_invencivel = true;
    IniciarTransicao(room, safe_x, safe_y);
    velh = 0;
    velv = 0;
    image_alpha = 0.5; // Visual 
    
    inv = true; 
    obj_hud.morto = true;
}

estado_espinho.roda = function()
{
    velh = 0;
    velv = 0;
}

estado_espinho.finaliza = function()
{
    cam.hurt = false;
    obj_hud.morto = true;
}

//Flutuar
estado_float.inicia = function()
{
    sprite = spr_player_jump //Colocar especifica dps
    image_index = 0;
    
    max_velh_anterior = max_velh;
    max_velh = max_velh * .7;
    
    // Colocar som de vento dps
}

estado_float.roda = function()
{
    timer_queda = 0; 
    
    checando_chao();
    checando_paredes();
    movimento_horizontal();
    
    // Gravidade reduzida
    velv += (grav * 0.15) * global.vel_scale;
    var _max_fall_float = 2; 
    velv = min(velv, _max_fall_float);

    aplica_dash();
 
    // Assim, basta soltar o dedo para cair normal.
    if (!InputCheck(INPUT_VERB.JUMP)) 
    {
        troca_estado(estado_jump);
        exit;
    }

    if (chao) 
    {
        timer_queda = 0; // Garante que não pula ao tocar o chão
        troca_estado((abs(velh) > 0.1) ? estado_walk : estado_idle);
        exit;
    }
    
    // Wall Slide
    if ((parede_dir or parede_esq) and global.powerups[powerup.WALL])
    {
        timer_queda = 0; // Garante que não dá Wall Jump automático
        troca_estado(estado_jump);
        exit;
    }
}

estado_float.finaliza = function()
{
    // Desligar som aqui
    max_velh = max_velh_anterior;
}

//Acordando
estado_wakeup.inicia = function()
{
    sprite = spr_player_wakeup;
    image_index = 0;
    velh = 0;
    velv = 0;
    
    efeito_sonoro(sfx_heal, 100, 0.1);
}

estado_wakeup.roda = function()
{
    //movimento_vertical(); 
    // Atualiza o Safe Ground 
    checando_chao();
    atualiza_safe_ground();

    // Se acabou a animação, libera o player
    if (finalizou_animacao())
    {
        troca_estado(estado_idle);
    }
}

estado_wakeup.finaliza = function() { }

// -- LAND (Pouso Pesado)
estado_land.inicia = function()
{
    sprite = spr_player_wakeup; 
    image_index = 0;
    
    // Zera velocidade horizontal 
    velh = 0;
    tempo_queda_livre = 0;
    
    // Impacto visual
    cria_particula(x, bbox_bottom, TIPO_PARTICULA.POEIRA_PULO, 8); // Muita poeira
    aplica_screenshake(4); // Treme a tela
    InputVibrateConstant(0.4, 0.0, 150); // Vibra controle
    efeito_sonoro(sfx_wallhit, 60, 0.1); // Som de impacto
}

estado_land.roda = function()
{
    // Mantém física básica
    movimento_vertical();
    atualiza_safe_ground();

    //Saindo da animação caso tente pular
    if (jump) { troca_estado(estado_jump); exit; }
    if (dash) { aplica_dash(); exit; }

    if (finalizou_animacao())
    {
        troca_estado(estado_idle);
    }
}

estado_land.finaliza = function() { }



inicia_estado(estado_idle);
instancia_camera();

// Cria a luz 
minha_luz = undefined;