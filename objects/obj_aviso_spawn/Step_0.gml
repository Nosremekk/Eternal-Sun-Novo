if (global.pause) exit;

timer += desconta_timer();

// Faz a luz piscar e aumentar a intensidade conforme o tempo passa
if (minha_luz != undefined) {
    minha_luz.intensity = lerp(0.1, 1.2, timer / duracao_aviso);
}


if (random(100) < 15) {
    cria_particula(x, y, TIPO_PARTICULA.ALMA, 1); 
}

// O momento do Spawn!
if (timer >= duracao_aviso)
{
    // Cria o inimigo real que foi enviado pelo encontro
    var _inst = instance_create_layer(x, y, "Instances", inimigo_obj, {
        spawnado_por_encontro: true
    });
    
    // Entrega o inimigo para a lista do obj_encontro no exato lugar do aviso
    if (instance_exists(encontro_id)) {
        encontro_id.inimigos_vivos[array_index] = _inst;
    }
    
    // JUICE: Efeito visual e sonoro de explosão na hora que ele entra!
    cria_particula(x, y - 10, TIPO_PARTICULA.EXPLOSAO, 1);
    cria_particula(x, y, TIPO_PARTICULA.SHOCKWAVE, 5);
    
    // Tremer o controle um pouco (Você usa a biblioteca Input)
    InputVibrateConstant(0.4, 0.0, 150);
    
    instance_destroy();
}