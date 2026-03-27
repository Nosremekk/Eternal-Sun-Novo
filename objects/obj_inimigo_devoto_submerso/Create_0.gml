event_inherited();


formulario_inimigo(4, 5, 4, 0, 0, 0.3, 0, 0, true, spr_inimigo_devoto_submerso_morto);

estado_idle = new estado();
estado_dash = new estado();

estado_idle.inicia = function()
{
    sprite_index = spr_inimigo_devoto_submerso_idle; 
    image_index = 0;
    socavel = true;
    velh = 0;
    
    // Define um tempo aleatório para ele ficar parado antes de agir de novo
    timer_acao = random_range(0.8, 1.5); 
}

estado_idle.roda = function()
{
    timer_acao -= desconta_timer();
    
    // Olha para a Amanara se ela estiver razoavelmente perto
    if (dist_x() < 250)
    {
        var _dir = sign(obj_player.x - x);
        if (_dir != 0) xscale = _dir; // Só vira se não estiver no exato mesmo pixel
    }
    
    // Se o timer zerou e o player está na visão dele, ele ataca escorregando
    if (timer_acao <= 0 and dist_x() < 200 and dist_y() < 64)
    {
        troca_estado(estado_dash);
    }
}

// ---- ESTADO: DASH FLUIDO (ESCORREGADIO) ----
estado_dash.inicia = function()
{
    sprite_index = spr_inimigo_devoto_submerso_dash; // Sprite dele avançando
    image_index = 0;
    socavel = true;
    
    // Dá o impulso inicial na direção em que está olhando
    velh = max_velh * xscale;
    
    // Opcional: um pequeno pulinho imprevisível de vez em quando
    if (choose(true, false)) velv = -2;
}

estado_dash.roda = function()
{
    // A mágica da fluidez: ele vai perdendo a velocidade horizontal aos poucos (fricção)
    // Usamos o lerp para criar esse efeito escorregadio de água
    if (chao)
    {
        // Multiplicar o fator do lerp pelo vel_scale garante que respeite o Slow Motion
        var _friccao = 0.04 * global.vel_scale; 
        velh = lerp(velh, 0, _friccao);
    }
    
    // Se bater na parede enquanto escorrega, ele para na hora
    if (place_meeting(x + velh, y, colisor))
    {
        velh = 0;
        troca_estado(estado_idle);
    }
    
    // Quando ele finalmente escorregar até quase parar, volta pro Idle
    if (abs(velh) < 0.5 and chao)
    {
        velh = 0;
        troca_estado(estado_idle);
    }
}

// Usando o seu novo inicia_knock_wait turbinado com as sprites de hit!
inicia_knock_wait(
    spr_inimigo_devoto_submerso_hurt, // Sprite tomando o hit
    spr_inimigo_devoto_submerso_idle, // Sprite atordoado/esperando
    1,                                // Tempo de stun
    estado_idle                       // Volta pro idle depois de apanhar
); 

inicia_morte_inimigo();
inicia_estado(estado_idle);