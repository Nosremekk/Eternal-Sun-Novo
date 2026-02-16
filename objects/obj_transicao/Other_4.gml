if (instance_exists(obj_controla_luz)) and (!requer_interacao)
{
    // Cria no centro do objeto
    var _cx = x + sprite_width / 2;
    var _cy = y + sprite_height / 2;
    
    minha_luz = new BulbLight(obj_controla_luz.renderer, spr_luz, 0, _cx, _cy);
    
    // --- COR ETÉREA ---
    // Sugestão 1: Roxo Mágico Vibrante (Muito usado em portais)
    minha_luz.blend = make_color_rgb(160, 80, 255);
    // Sugestão 2: Ciano/Verde Água (Mais fantasmagórico)
    // minha_luz.blend = make_color_rgb(50, 255, 220);
    
    // --- FORMATO DE RAIO/FEIXE ---
    // O segredo: X muito comprido, Y mais estreito.
    minha_luz.xscale = 4; // O comprimento do raio
    minha_luz.yscale = 1; // A largura do raio
    
    // --- DIREÇÃO AUTOMÁTICA ---
    // Descobre se está na esquerda ou direita da sala e aponta para o centro
    if (x < room_width / 2)
    {
        minha_luz.angle = 0; // Está na esquerda, aponta para direita ->
    }
    else
    {
        minha_luz.angle = 180; // Está na direita, aponta para esquerda <-
    }

    // Configurações finais
    minha_luz.intensity = 0.8;
    minha_luz.penumbraSize = 200; // Penumbra gigante para suavizar o feixe
    minha_luz.castShadows = false; // Deixa atravessar paredes
}
