// Timer usando seu sistema dinâmico
timer = 0;
duracao_aviso = 1.2; // 1.2 segundos de aviso antes do bicho nascer

// Adicionando uma luz pulsante do Bulb para ficar cinematográfico!
if (instance_exists(obj_controla_luz)) {
    minha_luz = new BulbLight(obj_controla_luz.renderer, spr_luz, 0, x, y);
    minha_luz.blend = c_red; // Cor do perigo
    minha_luz.intensity = 0.1; 
    minha_luz.castShadows = false; // Aviso não precisa projetar sombra, fica mais leve
} else {
    minha_luz = undefined;
}