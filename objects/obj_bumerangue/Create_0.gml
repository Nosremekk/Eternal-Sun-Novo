// Herda variáveis do obj_hit (se houver)
event_inherited();

pai = noone;
xscale = 1;
vel = 8;           // Velocidade do projétil
tempo_ida = 25;    // Quantos frames ele vai para frente antes de voltar
timer = 0;
voltando = false;
dano = global.dano * .5;     
alvo = noone;

// Controle de fases do bumerangue
voltando = false;
timer_ida = 0;
limite_ida = 3; // Frames máximos antes dele desistir e voltar sozinho

