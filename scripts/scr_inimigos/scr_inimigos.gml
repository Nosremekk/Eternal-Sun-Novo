//Formulario de inimigo(variaveis padroes de cada um)
function formulario_inimigo(_vida = 5,_max_velh = 1,_max_velv = 4,_velh = 0,_velv = 0,_grav = .3,_xmax = 300,_ymax = 0)
{
    vida_max = _vida;
    vida_atual = vida_max;
    toquei_player = false;
    max_velh = _max_velh;
    max_velv = _max_velv;
    velh = _velh;
    velv = _velv;
    grav = _grav;
    x_max = _xmax;
    altura_max = _ymax;
}

//Função para criar o estado de knockout caso o inimigo sofra disso. Apenas chamar ela após criar a logica de todos os estados
function inicia_knock(_retorna_estado = estado_walk,_forca_x_knock = max_velh*2,_forca_y_knock = -max_velv,_voador = false)
{
    forca_x_knock = _forca_x_knock;
    forca_y_knock = _forca_y_knock;
    estado_retorna_knock = _retorna_estado;  
    //Sou voador?
    voador = _voador;  
    //Criando o estado de knock
    estado_knock = new estado();
    
    //Debug
    estado_knock.inicia = function()
    {
        image_blend = c_yellow;
    }
    
    estado_knock.roda = function()
    {
    aplica_knock();

    //Parei? posso sair desse estado e voltar pra logica comum(inimigo terreno)
    if (!voador)
    { 
        if (chao) troca_estado(estado_retorna_knock); 
    }
       else     //Inimigo voador
    {
        if (abs(velh) < .35) troca_estado(estado_retorna_knock);
    }
        
    
        
    }
    
}

//Função para criar a dobradinha knockout e pos_knock
function inicia_knock_wait(_duracao_knock = 1,_retorna_estado = estado_walk,_forca_x_knock = max_velh*2,_forca_y_knock = -max_velv,_voador = false)
{
    forca_x_knock = _forca_x_knock;
    forca_y_knock = _forca_y_knock;
    estado_retorna_knock = _retorna_estado;  
    //Sou voador?
    voador = _voador; 
    //Estou passivel de knock?(atacando, subindo, descendo)
    socavel = false; 
    timer_pos_knock = 0;
    duracao_pos_knock = _duracao_knock;
    //Criando o estado de knock
    estado_knock = new estado();
    estado_pos_knock = new estado();
    
    //Debug
    estado_knock.inicia = function()
    {
        image_blend = c_yellow;
    }
    
    estado_knock.roda = function()
    {
        aplica_knock();
        
        //Saindo do meu estado, seja voltando ao normal ou indo de wait
        //sou voador, primeiro caso
        if (voador)
        {
            if (abs(velh) < .35) and (!socavel) troca_estado(estado_retorna_knock);
            else if (socavel) troca_estado(estado_pos_knock);    
        }
        else // Segundo caso, não sou voador
        {
            if (chao) and (!socavel) troca_estado(estado_retorna_knock);
                else if (chao) and (socavel) troca_estado(estado_pos_knock);
        }
        
    }
    
    estado_pos_knock.inicia = function()//Iniciando o estado de pos knock
    {
        image_blend = c_black//Debug
        grav = .3;
    }
    
    estado_pos_knock.roda = function()
    {
         if (chao) velh = 0;
            
        timer_pos_knock += desconta_timer();
        
        //Voltando pro estado que deveria ir
        if (timer_pos_knock >= duracao_pos_knock) troca_estado(estado_retorna_knock);
        
    }
    
    estado_pos_knock.finaliza = function()
    {
        timer_pos_knock = 0;
        socavel = false;
        if (voador) grav = 0;
    }
    
}

//Iniciando boss
function inicia_boss(_nome,_estado,_align = fa_right,_marg_x = 32,_marg_y = display_get_gui_height()-120)
{
    nome = _nome;
    margem_x = _marg_x;
    margem_y = _marg_y;
    align = _align;
    tam_x = string_width(_nome);
    tam_y = string_height(_nome);

    vai_estado = _estado;
    
    show = false;
    alpha = 0;
    timer_nome = 0;
    duracao_nome = 1.5;
    
    //estado padrao de qualquer boss
    estado_boss = new estado();

    
    estado_boss.inicia = function()
    {
        //Ficando parado
        velh = 0;
        velv = 0;
    }
    
    estado_boss.roda = function()
    {
        //Dando zoom out na camera
        if (dist_x() < 800) and (dist_y() < 100) and (!show)
        {
            obj_cam.boss = true;
            show = true;
            obj_hud.talk = true;
        }
        
        //Ativando a batalha!
        if (dist_x() < 350) and (dist_y() < 100) troca_estado(vai_estado);
    }
    
    estado_boss.finaliza = function()
    {
        obj_cam.boss = false;
        obj_controla_musica.adiciona_musica(snd_fase1);
    }
}

//Voltando X e Y
//Voltando caso tenha andado demais
function volta_x()
{
    if (abs(x-x_nativo) >= x_max) voltando = true;
    
    var _dir = x < x_nativo ? 1 : -1;
    
    if (voltando)
    {
        velh = max_velh * _dir;
        //Saindo da volta
        if (abs(x-x_nativo) < 32) voltando = false;    
            
        
        //Se eu bato na parede nesse processo eu inverto minha velh e defino isso como meu x nativo
        if (place_meeting(x+velh,y,colisor)) 
        {
            x_nativo = x;
            y_nativo = y;
            voltando = false;
        }
        
    }
}
//Caso tenha mudado de solo, mudo meu x padrão.
function muda_x(_altura = 100)
{
    //Estou em outro solo? mudo meu x nativo
    if (chao) and (abs(y-y_nativo) > _altura) 
    {
        x_nativo = x;     
        y_nativo = y;
    }
    
}
//Atirando
function formulario_tiro(_vel_tiro = 3,_min_dura = 2,_max_dura = 4,_diag = false,_random_diag = false)
{
    timer_tiro = 0;
    vel_tiro = _vel_tiro;
    duracao_timer_tiro = random_range(_min_dura,_max_dura);
    if (!_random_diag) diagonal = _diag;
        else diagonal = choose(true,false);
}
function tiro(_desliza = true)
{
    var _dx = obj_player.x - x;
    timer_tiro += desconta_timer();

    
    
    //Atirando reto
    if (!diagonal)
    {
        if (timer_tiro >= duracao_timer_tiro)
        {
            //Indo pra tras
            if (_desliza) velh = -xscale;
            
            //Atirando
            var _dist = point_distance(x, y, obj_player.x, obj_player.y);
            var _dy = obj_player.y - y;
            var _tiro = instance_create_layer(x,y - sprite_height/2,"Instances",obj_tiro);
            _tiro.hspeed = xscale * vel_tiro;
            _tiro.vspeed = (_dy / _dist) * vel_tiro;
            _tiro.velh = _tiro.hspeed;
            _tiro.velv = _tiro.vspeed;
            
            //Resetando 
            timer_tiro = 0;
        }
    }
    else//Atirando na diagonal
    {
        if (timer_tiro >= duracao_timer_tiro)
        {
            var _dist = (obj_player.x-x) + irandom_range(-12,12);
            var _tiro = instance_create_layer(x,y-sprite_height,"Instances",obj_tiro);
            _tiro.gravity = .3;
            _tiro.vspeed = -5;
            _tiro.hspeed = (_dist - xscale*sprite_width) * _tiro.gravity/-_tiro.vspeed/2;
            _tiro.velh = _tiro.hspeed;
            _tiro.velv = _tiro.vspeed;
            _tiro.grav = true;
            
            
            //Resetando
            timer_tiro = 0;
        }
    }
    
    //Olhando pro player
    xscale = sign(_dx);
    
    //Deslizando
    if (_desliza) velh = lerp(velh,0,.1);
    
    
    
}

//Funções para perseguir o player
function persegue(_voa = false,_dist_comeco = 180,_dist_para = 75,_alvo = obj_player, _olha = true,_suav = .06)
{
    var _dx = _alvo.x - x;
    var _dy = _alvo.y - y;
    var _dist = point_distance(x, y, _alvo.x, _alvo.y);
    
    //Olhando pro player
    if (_olha) xscale = sign(_dx);
        
    //Vetores
    var _vetor_x = 0;
    var _vetor_y = 0;
    
    //Estado para saber em que contexto eu estou
    estado_perseguicao = noone;
    
    if (_dist > _dist_comeco)
    {
        // Aproxima
        if (_dist != 0) 
        {
            _vetor_x = (_dx / _dist) * max_velh;
            _vetor_y = (_dy / _dist) * max_velh;
            estado_perseguicao = "aproxima";
        }
    }
    else if (_dist < _dist_para) 
    {
        // Afasta (oposto ao player)
        if (_dist != 0) {
            _vetor_x = -(_dx / _dist) * max_velh;
            _vetor_y = -(_dy / _dist) * max_velh;
            estado_perseguicao = "afasta";
        }
    }
    else//Parando
    {
        _vetor_x = 0;
        _vetor_y = 0;
        estado_perseguicao = "parado";
    }
    if (!_voa) _vetor_y  = 0;
    //Aplicando velocidade suavizada
    velh = lerp(velh,_vetor_x,_suav);
    if (_voa) velv = lerp(velv,_vetor_y,_suav);
}


function rastreia_tiro_volta()
{
    //Atualiza posição global da marca
   if (global.inimigo_marcado == id)
   {
       global.marca_pos_x = x;
       global.marca_pos_y = y - (sprite_height / 2);
       global.marca_room  = room;
   }
}

function step_inimigo(_muda_x = 100)
{
    if (global.pause) exit;
    event_inherited();
    checando_chao_geral();
    ajusta_xscale();
    movimento_vertical();
    roda_estado();
    causa_dano_contato();
    muda_x(_muda_x);
    rastreia_tiro_volta();
}

function get_inimigo_key()
{
    return room_get_name(room) + "_" + string(xstart) + "_" + string(ystart);
}