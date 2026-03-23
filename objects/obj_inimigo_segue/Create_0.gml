/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

formulario_inimigo(6,1,4,0,0,.3,200,0);

//Este inimigo vai ficar andando e quando ver o player vai correr na direção dele
//Iniciando estados
estado_walk = new estado();
estado_run = new estado();

//Andando
estado_walk.inicia = function()
{
    max_velh = 1;
    image_blend = c_blue;
    velh = choose(-max_velh,max_velh);
}

estado_walk.roda = function()
{
    bate_parede();
    volta_x();

    //Se eu estou a 160 px do inimigo(e num y parecido) ele me segue 
    if (seguindo(160,110)) troca_estado(estado_run);
}

estado_walk.finaliza = function()
{
    
}

//Avançando em direção ao player
estado_run.inicia = function()
{
    max_velh = 1.5;
    image_blend = c_teal
}

estado_run.roda = function()
{
    if (dist_x() >= 275) or (dist_y() >= 110) or (!verifica_parede()) troca_estado(estado_walk);    
    
    //Pegando a direção e indo ao player
    var _dir = sign(obj_player.x-x);
    velh = max_velh * _dir;
}

estado_run.finaliza = function()
{
    
}

inicia_morte_inimigo();
//Aplicando knockback
inicia_knock();

//Iniciando state machine
inicia_estado(estado_walk);


