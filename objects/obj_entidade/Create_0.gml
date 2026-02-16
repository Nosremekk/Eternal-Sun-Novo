/// @description 
vida_max = 10;
vida_atual = 10;

inv = false;
inv_timer = 0;
duracao_inv = .4;

xscale = image_xscale
img_ind = 0;
image_speed = 0;
anim_speed = 8;

velh =     0;
velv =     0;
max_velv = 0;
max_velh = 0;
chao = noone;
grav = .3;

colisao_tile_map = layer_tilemap_get_id("Colisao_Tiles");
colisor = [obj_colisor,obj_parede_secreta,colisao_tile_map]


//Gravidade
movimento_vertical = function()
{
        if (!chao)
        {

              if(velv < max_velv) velv += grav * global.vel_scale;
              else velv = max_velv;   
        }
        else //estou no chao
        {
            velv = 0;
        }

}

init_dano();

//Método para piscar
blink = function()
{
    if (inv)
    {
        //Aumentando o  valor do inv timer
        inv_timer += desconta_timer();
        
        var _sin = sin(inv_timer/5);
        _sin = (_sin + 1)/2;
        
        image_alpha = abs(_sin);
        
        
        if (inv_timer >= duracao_inv)
        {
            inv = false;        
            image_alpha = 1;
        }
    }
}


//Método para receber dano
function recebe_dano(_dano = 1)
{
    if (inv) exit;
    vida_atual -= _dano;
    //Garantindo que a vida atual não fique abaixo de zero
    vida_atual = clamp(vida_atual,0,vida_max);
    
    troca_estado(estado_hurt);
    
    //Morrendo caso a vida <= 0
    if (vida_atual <= 0)
    {
        instance_destroy();
    }
}

minha_luz = undefined;