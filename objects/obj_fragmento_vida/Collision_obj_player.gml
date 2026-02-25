
global.itens_coletados[$ minha_chave] = true;

global.fragmentos_vida++;
atualiza_stats_player();


cria_particula(x, y, TIPO_PARTICULA.SHOCKWAVE, 1);
// efeito_sonoro(...)


instance_destroy();