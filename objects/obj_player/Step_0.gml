if (global.pause) exit;
 
controles();
if (timer_atk_buffer > 0) timer_atk_buffer--; //Descontando buffer de combate
    
var _xscale_anterior = xscale;

ajusta_xscale_player();

if (_xscale_anterior != xscale) and (abs(velh) > 0.5) and (chao)
{
    cria_particula(x, bbox_bottom, TIPO_PARTICULA.POEIRA_PULO, 3);
}

escala_x = lerp(escala_x, 1, 0.25);
escala_y = lerp(escala_y, 1, 0.25);

verifica_agua();

roda_estado(); //Se começar a bugar lembrar de passar isso pra dps da colisao

// Colisão
colisao();
verifica_espinho();

//Descontando o inv_timer e aplicando efeito de hit
blink();


animacao();
if (dispara_alarme) alarme_vida();
gerencia_timer_marca();    

//Limita o combo
global.combo = clamp(global.combo,1,global.limite_combo);



// Sincroniza luz com player
if (!is_undefined(minha_luz))
{
    minha_luz.x = x;
    minha_luz.y = y - sprite_height/2;
}

