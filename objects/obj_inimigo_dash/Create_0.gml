/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

formulario_inimigo(5,1,4,,,,150)

//Timer para ir do walk, para dash
timer_walk_to_dash = 0;
duracao_walk_to_dash = .75;



//Este inimigo vai ficar andando e quando ver o player vai dar um dash e parar. Depois ele volta a andar
//Iniciando estados
estado_walk = new estado();
estado_espera_dash = new estado();
estado_dash = new estado();

//Andando
estado_walk.inicia = function()
{
    image_blend = c_blue;
    velh = choose(-max_velh,max_velh);
    socavel = false;
}

estado_walk.roda = function()
{
    bate_parede();
    volta_x();
    //Vi o player? dou dash
    if (seguindo(120,110)) troca_estado(estado_espera_dash);
    
}

estado_walk.finaliza = function()
{
    
}
//Pensando na vida e dps indo em direção ao player
estado_espera_dash.inicia = function()
{
    velh = 0;
    velv = 0;
    image_blend = c_maroon;
    dir = sign(obj_player.x-x);
    socavel = true;
}

estado_espera_dash.roda = function()
{
    timer_walk_to_dash += desconta_timer();
    if (timer_walk_to_dash >= duracao_walk_to_dash) troca_estado(estado_dash);
}

estado_espera_dash.finaliza = function()
{
    timer_walk_to_dash = 0;    
}

//Avançando em direção ao player
estado_dash.inicia = function()
{
    velh = 5* dir;
    image_blend = c_black
}

estado_dash.roda = function()
{
    velh = lerp(velh,0,.05);
    if (abs(velh) < .2) troca_estado(estado_pos_knock);
        
     
}

estado_dash.finaliza = function()
{
    dir = 0;
}


inicia_morte_inimigo();
inicia_knock_wait()

//Iniciando state machine
inicia_estado(estado_walk);



