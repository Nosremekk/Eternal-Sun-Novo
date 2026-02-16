if (global.pause) exit;
 
controles();
if (timer_atk_buffer > 0) timer_atk_buffer--; //Descontando buffer de combate
    
var _xscale_anterior = xscale;

ajusta_xscale_player();

if (_xscale_anterior != xscale) and (abs(velh) > 0.5) and (chao)
{
    cria_particula(x, bbox_bottom, TIPO_PARTICULA.POEIRA_PULO, 3);
}

roda_estado(); //Se começar a bugar lembrar de passar isso pra dps da colisao

// Colisão
plat_fina();
move_and_collide(velh * global.vel_scale, 0, colisor, 4);
move_and_collide(0,   velv * global.vel_scale, colisor,12);

verifica_espinho();

//Descontando o inv_timer e aplicando efeito de hit
blink();


animacao();
if (dispara_alarme) alarme_vida();
gerencia_timer_marca();    



// Sincroniza luz com player
if (!is_undefined(minha_luz))
{
    minha_luz.x = x;
    minha_luz.y = y - sprite_height/2;
}

