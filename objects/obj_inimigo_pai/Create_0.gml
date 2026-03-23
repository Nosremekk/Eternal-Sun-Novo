/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();
verifica_luz = false

if (!variable_instance_exists(id, "spawnado_por_encontro")) {
    spawnado_por_encontro = false;
}


//Ja fui morto?
inimigo_key = noone;
boss_key = noone;
meu_id_bestiario = "";

if (!e_boss) 
{
    inimigo_key = get_inimigo_key();
    if (!spawnado_por_encontro and variable_struct_exists(global.inimigos_mortos_temp, inimigo_key))
    {
        instance_destroy();
        exit; 
    }
}
else 
{ 
    boss_key = get_inimigo_key();
    // Trava do encontro para boss
    if (!spawnado_por_encontro and variable_struct_exists(global.bosses_mortos, boss_key))
    {
        instance_destroy(); 
        exit; 
    }
}

//Perigos
aquatico = false;
tilemap_morte = layer_tilemap_get_id("Morte"); 

verifica_perigos = function()
{
    var _agua = instance_place(x, y, obj_agua);
    if (_agua != noone and !aquatico)
    {
        recebe_dano(vida_max);
        exit;
    }

    var _espinho_obj = instance_place(x, y, obj_morte);
    var _espinho_tile = tilemap_get_at_pixel(tilemap_morte, x, y);

    if (_espinho_obj != noone or _espinho_tile > 0)
    {
        recebe_dano(vida_max);
    }
}


//Variaveis


toquei_player = false;

colisao_tile_map = layer_tilemap_get_id("Colisao_Tiles");

colisor = [obj_colisor,obj_parede_secreta,obj_colisor_fino,colisao_tile_map];

x_max = 0;
x_nativo = xstart;
y_nativo = ystart;
voltando = false;

combado = false;

//Metódo de knockback
knock_timer = inv_timer/3;
knock_timer_max = knock_timer;

knock_ativo = false;

forca_x_knock = max_velh*1.45;
forca_y_knock = -max_velv;





knockback = function(_forca_x = forca_x_knock, _forca_y = forca_y_knock)
{
    if (_forca_x == 0) exit;
    
    var _max_combo = global.limite_combo == global.combo
    //To no maximo do meu combo?
    var _mult = _max_combo ? 4 : random_range(.65,1.45);
    
    //aplicando a direção correta ao knock
    if (obj_player.x < x) _forca_x = _forca_x;
        else _forca_x = -_forca_x

    velh = _forca_x * _mult;
    velv = _max_combo ? _forca_y * 1.75 : _forca_y;
    
    //Trocando para o estado de knock
    troca_estado(estado_knock);
}

aplica_knock = function()
{
    var _desc = chao ? .045 : 0.03;
        
    velh = lerp(velh,0,_desc);
    velv = lerp(velv,0,_desc);
    
}








//Método para receber dano
function recebe_dano(_dano = 1)
{
    if(estado_atual == estado_morte) exit;
        
    var _combo = combado and obj_player.estado_atual == obj_player.estado_attack;
    //Estou marcando
    var _critico = false;
    if (global.inimigo_marcado == id)
    {
        if (_combo) adiciona_combo();
        
        if (instance_exists(obj_player)) obj_player.inimigo_marcado_atingido = true;
        
        // Se estiver com vida cheia, dá dano extra
        if (global.vida_atual >= global.vida_max)
        {
            _dano += 2;
        }
        _critico = true;
    }    
    
    //Diminuindo minha vida
    vida_atual -= _dano;
    vida_atual = clamp(vida_atual, 0, vida_max);
    
    // Squash de impacto
    escala_x = 2;
    escala_y = .5;
    
    var _centro_y = y - (sprite_height / 2);
     

    var _qtd_sangue = 4 + (global.combo * 3);
    
    // Opcional: Limitar para não travar o pc se o combo for infinito (ex: max 40 particulas)
    _qtd_sangue = clamp(_qtd_sangue, 4, 40); 

    cria_particula(x, _centro_y, TIPO_PARTICULA.SANGUE, _qtd_sangue);
    // ---------------------------------------
    
    //Empurrando o player
    if (instance_exists(obj_player)) obj_player.aplicar_recuo_ataque();
    
    //Vibrando
    if (_critico) InputVibrateConstant(0.6, 0.0, 200);
        else InputVibrateConstant(0.3, 0.0, 150)
    
    
    //Aplicando som dinamico conforme o combo
    var _pitch_combo = 0.9 + (global.combo * 0.1);
    
    var _is_max = (global.combo >= global.limite_combo);
    var _is_full_life = (global.vida_atual >= global.vida_max);
    
    if (_is_max and _is_full_life) 
    {
        _pitch_combo = 0.7;
        InputVibrateConstant(0.8, 0.0, 300)
    } 
    else 
    {
        // Limitando para nao ficar muito agudo
        _pitch_combo = clamp(_pitch_combo, 1.0, 1.6);
    }

    var _snd = efeito_sonoro_3d(sfx_hit, x, y, 100, 300, 70, 0.1)
    
    if (_snd != noone) {
        audio_sound_pitch(_snd, _pitch_combo);
    }

    if (_combo) adiciona_combo();
    
    //Recebi o dano fico transparente
    image_alpha = 0;
    
    //Morrendo caso a vida <= 0
    if (vida_atual <= 0)
    {
        if (!spawnado_por_encontro)
        {
            if (!e_boss) global.inimigos_mortos_temp[$ inimigo_key] = true;
            else 
            { 
                global.bosses_mortos[$ boss_key] = true
                salvando_jogo(global.save,false);
            }
        }
        
        if (global.inimigo_marcado == id)
        {
            var _volta = instance_create_layer(x, _centro_y, "Instances", obj_player_marca);
            
            //Configurando retorno
            _volta.fase = 1;
            _volta.speed = 2;
            
            global.inimigo_marcado = noone;
        }
        
        
        
    }
        


    
    knockback();
    
    //Pogo 
    obj_player.aplicar_pogo(true);
    
    //Tirando combo
    combado = false;
}

/*
 * // No create da porta
key_boss_requerido = "rm_arena_500_400"; // ID do boss (tem que saber a posição dele)

// No step ou interação
if (variable_struct_exists(global.bosses_mortos, key_boss_requerido))
{
    abrir_porta();
}
 * */

