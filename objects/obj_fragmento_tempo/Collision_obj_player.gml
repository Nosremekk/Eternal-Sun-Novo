global.itens_coletados[$ minha_chave] = true;

// Adiciona o fragmento de tempo e recalcula!
global.fragmentos_tempo++;
atualiza_stats_player();

cria_particula(x, y, TIPO_PARTICULA.SHOCKWAVE, 1);
// efeito_sonoro(snd_pegar_item, 50, 0);

//notificar_item("Pedaço de Foco", spr_fragmento_tempo); 

instance_destroy();