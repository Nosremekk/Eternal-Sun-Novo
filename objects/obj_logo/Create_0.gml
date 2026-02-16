// --- CONFIGURAÇÃO ---
sprite_logo = spr_studio; 
alpha = 0;
timer = 0;
escala_pulse = 1;

// Tempos (em segundos)
tempo_fade_in  = 2.0; 
tempo_wait     = 2.5; 
tempo_fade_out = 1.5; 

proxima_sala = rm_menu; 

// --- CONFIGURAÇÃO DE ACELERAÇÃO ---
velocidade_mult = 1.0;     // Velocidade normal
velocidade_turbo = 8.0;    // Quão rápido vai quando aperta botão (8x mais rápido)

// Lista de verbos que ativam a aceleração (Cobrindo controle e teclado mapeado)
lista_verbos_skip = [
    INPUT_VERB.UI_CONFIRM, 
    INPUT_VERB.UI_CANCEL, 
    INPUT_VERB.JUMP, 
    INPUT_VERB.ATTACK, 
    INPUT_VERB.PAUSE,
    INPUT_VERB.DASH
];

// Função auxiliar para checar input
checar_aceleracao = function()
{
    // Verifica se algum verbo da lista está sendo segurado 
    var _input_ativo = InputCheckMany(lista_verbos_skip);
    
    // Fallback para qualquer tecla do teclado (para garantir em PC)
    var _teclado_ativo = keyboard_check(vk_anykey);
    
    // Se apertar, velocidade é turbo, senão é 1.0
    if (_input_ativo or _teclado_ativo) velocidade_mult = velocidade_turbo;
    else velocidade_mult = 1.0;
}

// --- ESTADOS ---

// --- ESTADOS ---

// 1. FADE IN
estado_fadein = new estado();
estado_fadein.inicia = function()
{
    alpha = 0;
    escala_pulse = 1; 
    efeito_sonoro(snd_test, 10);
}
estado_fadein.roda = function()
{
    // Chama o input
    checar_aceleracao();

    // Aplica Multiplicador no Alpha
    // (desconta_timer retorna o delta_time, multiplicamos pela velocidade)
    alpha += ((desconta_timer() * velocidade_mult) / tempo_fade_in);
    
    // Aplica Multiplicador no Zoom
    // Aumentamos a velocidade de interpolação proporcionalmente
    escala_pulse = lerp(escala_pulse, 1.15, 0.005 * velocidade_mult); 

    if (alpha >= 1)
    {
        alpha = 1;
        troca_estado(estado_wait);
    }
}

// 2. WAIT
estado_wait = new estado();
estado_wait.inicia = function()
{
    timer = tempo_wait;
}
estado_wait.roda = function()
{
    checar_aceleracao();

    // Aplica Multiplicador no Timer
    timer -= (desconta_timer() * velocidade_mult);

    // Zoom continua acelerado se segurar botão
    escala_pulse = lerp(escala_pulse, 1.15, 0.005 * velocidade_mult); 

    if (timer <= 0)
    {
        troca_estado(estado_fadeout);
    }
}

// 3. FADE OUT
estado_fadeout = new estado();
estado_fadeout.inicia = function() {}

estado_fadeout.roda = function()
{
    checar_aceleracao();

    // Aplica Multiplicador na Saída
    alpha -= ((desconta_timer() * velocidade_mult) / tempo_fade_out);
    
    escala_pulse = lerp(escala_pulse, 1.15, 0.005 * velocidade_mult); 
    
    if (alpha <= 0)
    {
        alpha = 0;
        audio_stop_sound(snd_test); // Corta o som se acelerou
        
        IniciarTransicao(proxima_sala);
        troca_estado(estado_fim); 
    }
}

// 4. FIM
estado_fim = new estado();
estado_fim.inicia = function() {};
estado_fim.roda = function() {};

inicia_estado(estado_fadein);